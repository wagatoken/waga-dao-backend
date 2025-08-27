// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {ICooperativeGrantManager} from "../shared/interfaces/ICooperativeGrantManager.sol";
import {IWAGACoffeeInventoryToken} from "../shared/interfaces/IWAGACoffeeInventoryToken.sol";
import {GreenfieldProjectManager} from "../managers/GreenfieldProjectManager.sol";

/**
 * @title CooperativeGrantManagerV2 - Refactored Grant Management System
 * @author WAGA DAO
 * @notice Manages grants to coffee cooperatives with revenue sharing mechanisms
 * @dev Implements separation of concerns architecture to avoid stack too deep errors
 * 
 * Key architectural decisions:
 * 1. Uses composition pattern with GreenfieldProjectManager for greenfield projects
 * 2. Implements interface exactly as defined to ensure compatibility
 * 3. Simplified parameter handling to avoid stack issues
 * 4. Clear separation between grant creation, management, and revenue sharing
 */
contract CooperativeGrantManagerV2 is 
    ICooperativeGrantManager,
    AccessControl,
    Pausable,
    ReentrancyGuard 
{
    using SafeERC20 for IERC20;

    // ============ CONSTANTS ============
    
    bytes32 public constant GRANT_MANAGER_ROLE = keccak256("GRANT_MANAGER_ROLE");
    bytes32 public constant FINANCIAL_ROLE = keccak256("FINANCIAL_ROLE");
    bytes32 public constant REVENUE_MANAGER_ROLE = keccak256("REVENUE_MANAGER_ROLE");
    bytes32 public constant MILESTONE_VALIDATOR_ROLE = keccak256("MILESTONE_VALIDATOR_ROLE");
    
    uint256 public constant MAX_REVENUE_SHARE = 5000; // 50% in basis points
    uint256 public constant MAX_DURATION_YEARS = 10;
    uint256 public constant MIN_GRANT_AMOUNT = 1000e6; // $1000 USDC
    uint256 public constant MAX_MILESTONES = 10; // Maximum milestones per grant
    uint256 public constant BASIS_POINTS = 10000; // 100% in basis points

    // ============ STATE VARIABLES ============
    
    /// @dev USDC token contract
    IERC20 public immutable usdcToken;
    
    /// @dev Greenfield project manager
    GreenfieldProjectManager public immutable greenfieldManager;
    
    /// @dev Treasury address for receiving revenue shares
    address public treasury;
    
    /// @dev Next grant ID counter
    uint256 public override nextGrantId = 1;
    
    /// @dev Mapping of grant ID to grant information
    mapping(uint256 => GrantInfo) public grants;
    
    /// @dev Mapping of cooperative to their grant IDs
    mapping(address => uint256[]) public cooperativeGrants;
    
    /// @dev Mapping of grant ID to project ID (for greenfield grants)
    mapping(uint256 => uint256) public grantToProjectId;
    
    /// @dev Mapping of batch ID to grant ID
    mapping(uint256 => uint256) public batchToGrant;
    
    /// @dev Total grants disbursed
    uint256 public totalGrantsDisbursed;
    
    /// @dev Current commodity price for pricing calculations
    uint256 public currentCommodityPrice = 300e6; // $3.00 per kg
    
    // ============ PHASED DISBURSEMENT STATE ============
    
    /// @dev Mapping of grant ID to disbursement schedule
    mapping(uint256 => DisbursementSchedule) public disbursementSchedules;
    
    /// @dev Mapping of grant ID to escrow balance
    mapping(uint256 => uint256) public grantEscrowBalances;
    
    /// @dev Total amount held in escrow across all grants
    uint256 public totalEscrowBalance;

    // ============ ADDITIONAL EVENTS ============
    
    event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);
    event GrantDisbursed(uint256 indexed grantId, uint256 amount, address indexed recipient);
    event CommodityPriceUpdated(uint256 oldPrice, uint256 newPrice);

    // ============ CONSTRUCTOR ============
    
    constructor(
        address _usdcToken,
        address _greenfieldManager,
        address _treasury,
        address _admin
    ) {
        require(_usdcToken != address(0), "Invalid USDC token");
        require(_greenfieldManager != address(0), "Invalid greenfield manager");
        require(_treasury != address(0), "Invalid treasury");
        require(_admin != address(0), "Invalid admin");
        
        usdcToken = IERC20(_usdcToken);
        greenfieldManager = GreenfieldProjectManager(_greenfieldManager);
        treasury = _treasury;
        
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(GRANT_MANAGER_ROLE, _admin);
        _grantRole(FINANCIAL_ROLE, _admin);
        _grantRole(REVENUE_MANAGER_ROLE, _admin);
        _grantRole(MILESTONE_VALIDATOR_ROLE, _admin); // Admin can validate milestones
    }

    // ============ GRANT CREATION ============

    /**
     * @notice Creates a grant for existing coffee batches
     * @dev Implements interface specification exactly
     */
    function createGrant(
        address cooperative,
        uint256 amount,
        uint256[] memory batchIds,
        uint256 revenueSharePercentage,
        uint256 durationYears,
        string memory description
    ) external override onlyRole(GRANT_MANAGER_ROLE) whenNotPaused returns (uint256 grantId) {
        // Validate parameters
        if (amount < MIN_GRANT_AMOUNT) revert CooperativeGrantManager__InvalidGrantAmount();
        if (revenueSharePercentage > MAX_REVENUE_SHARE) revert CooperativeGrantManager__InvalidRevenueShare();
        if (durationYears == 0 || durationYears > MAX_DURATION_YEARS) revert CooperativeGrantManager__InvalidDuration();
        if (cooperative == address(0)) revert CooperativeGrantManager__UnauthorizedCoop();
        
        grantId = _createGrantInternal(
            cooperative,
            amount,
            revenueSharePercentage,
            durationYears,
            description,
            false, // Not greenfield
            0      // No project ID
        );
        
        // Set batch IDs for existing batches
        grants[grantId].batchIds = batchIds;
        
        // Update batchToGrant mapping for each batch
        for (uint256 i = 0; i < batchIds.length; i++) {
            batchToGrant[batchIds[i]] = grantId;
        }
        
        emit GrantCreated(grantId, cooperative, amount, batchIds, revenueSharePercentage);
        
        return grantId;
    }

    /**
     * @notice Creates a greenfield grant for future coffee production (blockchain-first approach)
     * @param cooperative The cooperative receiving the grant
     * @param amount The grant amount in USDC
     * @param revenueSharePercentage Percentage of revenue shared with DAO (basis points)
     * @param durationYears Grant duration in years
     * @param ipfsHash IPFS hash containing all project and cooperative details
     * @param plantingDate When coffee trees will be planted
     * @param maturityDate When trees reach production maturity
     * @param projectedYield Expected annual yield in kg
     * @param cooperativeName Name of the cooperative (for events only)
     * @return grantId The created grant ID
     * @return projectId The created greenfield project ID
     * @dev Rich cooperative and project data stored in IPFS + database, minimal on-chain state
     */
    function createGreenfieldGrant(
        address cooperative,
        uint256 amount,
        uint256 revenueSharePercentage,
        uint256 durationYears,
        string memory ipfsHash,
        uint256 plantingDate,
        uint256 maturityDate,
        uint256 projectedYield,
        string memory cooperativeName
    ) external onlyRole(GRANT_MANAGER_ROLE) whenNotPaused returns (uint256 grantId, uint256 projectId) {
        // Validate parameters
        if (amount < MIN_GRANT_AMOUNT) revert CooperativeGrantManager__InvalidGrantAmount();
        if (revenueSharePercentage > MAX_REVENUE_SHARE) revert CooperativeGrantManager__InvalidRevenueShare();
        if (durationYears == 0 || durationYears > MAX_DURATION_YEARS) revert CooperativeGrantManager__InvalidDuration();
        if (cooperative == address(0)) revert CooperativeGrantManager__UnauthorizedCoop();
        
        // Create greenfield project with simplified parameters
        projectId = greenfieldManager.createGreenfieldProject(
            ipfsHash,
            plantingDate,
            maturityDate,
            projectedYield,
            amount // grantValue
        );
        
        grantId = _createGrantInternal(
            cooperative,
            amount,
            revenueSharePercentage,
            durationYears,
            string(abi.encodePacked("Greenfield: ", cooperativeName)),
            true,     // Is greenfield
            projectId // Project ID
        );
        
        // Link grant to project
        grantToProjectId[grantId] = projectId;
        
        emit GreenfieldGrantCreated(
            grantId, 
            projectId, 
            cooperative, 
            amount, 
            string(abi.encodePacked("Greenfield: ", cooperativeName)), 
            projectedYield
        );
        
        return (grantId, projectId);
    }

    // ============ GRANT MANAGEMENT ============

    /**
     * @notice Disburses a grant to the cooperative
     */
    function disburseGrant(uint256 grantId) external onlyRole(FINANCIAL_ROLE) nonReentrant {
        GrantInfo storage grant = grants[grantId];
        
        if (grant.cooperative == address(0)) revert CooperativeGrantManager__InvalidGrantAmount();
        if (grant.status != GrantStatus.Pending) revert CooperativeGrantManager__GrantNotActive();

        uint256 contractBalance = usdcToken.balanceOf(address(this));
        if (contractBalance < grant.amount) revert CooperativeGrantManager__InsufficientFunds();

        // Check if grant has phased disbursement schedule
        DisbursementSchedule storage schedule = disbursementSchedules[grantId];
        if (schedule.isActive) {
            // For phased disbursement, escrow was already set up in createDisbursementSchedule
            // Just update status if not already set
            if (grantEscrowBalances[grantId] == 0) {
                grantEscrowBalances[grantId] = grant.amount;
                totalEscrowBalance += grant.amount;
            }
            grant.status = GrantStatus.Pending; // Stays pending until first milestone
            emit GrantDisbursed(grantId, 0, grant.cooperative); // 0 amount as it's escrowed
        } else {
            // Traditional full disbursement for non-phased grants
            grant.status = GrantStatus.Active;
            grant.disbursedAmount = grant.amount;
            usdcToken.safeTransfer(grant.cooperative, grant.amount);
            totalGrantsDisbursed += grant.amount;
            emit GrantDisbursed(grantId, grant.amount, grant.cooperative);
        }
    }

    /**
     * @notice Records revenue sharing from coffee sales
     * @dev Implements interface specification exactly
     */
    function recordRevenueShare(
        uint256 grantId,
        uint256 revenueAmount
    ) external override onlyRole(REVENUE_MANAGER_ROLE) {
        GrantInfo storage grant = grants[grantId];
        
        if (grant.cooperative == address(0)) revert CooperativeGrantManager__InvalidGrantAmount();
        if (grant.status != GrantStatus.Active) revert CooperativeGrantManager__GrantNotActive();

        uint256 shareAmount = (revenueAmount * grant.revenueSharePercent) / 10000;
        grant.totalRevenueShared += shareAmount;

        emit RevenueShared(grantId, revenueAmount, shareAmount, grant.cooperative);
        
        // Check if grant should be completed
        if (grant.totalRevenueShared >= grant.minimumRevenueTarget || 
            block.timestamp >= grant.maturityTime) {
            _completeGrant(grantId);
        }
    }

    /**
     * @notice Completes a grant
     * @dev Implements interface specification exactly
     */
    function completeGrant(uint256 grantId) external override onlyRole(GRANT_MANAGER_ROLE) {
        _completeGrant(grantId);
    }

    /**
     * @notice Advances greenfield project milestone
     * @dev Implements interface specification exactly
     */
    function advanceGreenfieldMilestone(
        uint256 grantId,
        uint256 stage,
        string memory milestoneEvidence
    ) external override onlyRole(GRANT_MANAGER_ROLE) {
        GrantInfo storage grant = grants[grantId];
        
        if (!grant.isGreenfield) revert CooperativeGrantManager__InvalidGrantAmount();
        
        greenfieldManager.advanceProjectStage(
            grant.greenfieldProjectId, 
            stage, 
            grant.amount, // Use grant amount as updated yield for simplicity
            milestoneEvidence
        );
        
        emit MilestoneCompleted(grantId, stage, milestoneEvidence);
    }

    // ============ PHASED DISBURSEMENT FUNCTIONS ============

    /**
     * @notice Creates a disbursement schedule for a greenfield grant
     * @param grantId The grant ID to create schedule for
     * @param milestoneDescriptions Array of milestone descriptions
     * @param milestonePercentages Array of percentage shares (basis points)
     */
    function createDisbursementSchedule(
        uint256 grantId,
        string[] memory milestoneDescriptions,
        uint256[] memory milestonePercentages
    ) external override onlyRole(GRANT_MANAGER_ROLE) {
        GrantInfo storage grant = grants[grantId];
        
        if (grant.cooperative == address(0)) revert CooperativeGrantManager__InvalidGrantAmount();
        if (!grant.isGreenfield) revert CooperativeGrantManager__InvalidGrantAmount();
        if (grant.status != GrantStatus.Pending) revert CooperativeGrantManager__GrantNotActive();
        if (milestoneDescriptions.length != milestonePercentages.length) revert CooperativeGrantManager__InvalidGrantAmount();
        if (milestoneDescriptions.length == 0 || milestoneDescriptions.length > MAX_MILESTONES) revert CooperativeGrantManager__InvalidGrantAmount();
        
        // Validate percentages sum to 100%
        uint256 totalPercentage = 0;
        for (uint256 i = 0; i < milestonePercentages.length; i++) {
            totalPercentage += milestonePercentages[i];
        }
        if (totalPercentage != BASIS_POINTS) revert CooperativeGrantManager__InvalidGrantAmount();
        
        DisbursementSchedule storage schedule = disbursementSchedules[grantId];
        schedule.isActive = true;
        schedule.totalMilestones = milestoneDescriptions.length;
        schedule.completedMilestones = 0;
        schedule.escrowedAmount = grant.amount;
        
        // Create milestone infos
        delete schedule.milestones; // Clear existing milestones
        for (uint256 i = 0; i < milestoneDescriptions.length; i++) {
            schedule.milestones.push(MilestoneInfo({
                description: milestoneDescriptions[i],
                percentageShare: milestonePercentages[i],
                isCompleted: false,
                evidenceUri: "",
                completedTimestamp: 0,
                validator: address(0),
                disbursedAmount: 0
            }));
        }
        
        // Move grant amount to escrow
        grantEscrowBalances[grantId] = grant.amount;
        totalEscrowBalance += grant.amount;
        
        emit DisbursementScheduleCreated(grantId, milestoneDescriptions.length, grant.amount);
    }

    /**
     * @notice Submits evidence for milestone completion and triggers auto-disbursement
     * @param grantId The grant ID
     * @param milestoneIndex The milestone index
     * @param evidenceUri IPFS or database URI for evidence
     */
    function submitMilestoneEvidence(
        uint256 grantId,
        uint256 milestoneIndex,
        string memory evidenceUri
    ) external override {
        GrantInfo storage grant = grants[grantId];
        DisbursementSchedule storage schedule = disbursementSchedules[grantId];
        
        if (grant.cooperative == address(0)) revert CooperativeGrantManager__InvalidGrantAmount();
        if (msg.sender != grant.cooperative) revert CooperativeGrantManager__UnauthorizedCoop();
        if (!schedule.isActive) revert CooperativeGrantManager__InvalidGrantAmount();
        if (milestoneIndex >= schedule.totalMilestones) revert CooperativeGrantManager__InvalidGrantAmount();
        
        MilestoneInfo storage milestone = schedule.milestones[milestoneIndex];
        if (milestone.isCompleted) revert CooperativeGrantManager__InvalidGrantAmount();
        
        // Store evidence and mark as pending validation
        milestone.evidenceUri = evidenceUri;
        
        // For now, auto-approve (in production, this would trigger validation workflow)
        _validateAndDisburseMilestone(grantId, milestoneIndex, true, msg.sender);
    }

    /**
     * @notice Validates milestone and triggers automatic disbursement
     * @param grantId The grant ID
     * @param milestoneIndex The milestone index
     * @param approved Whether the milestone is approved
     */
    function validateMilestone(
        uint256 grantId,
        uint256 milestoneIndex,
        bool approved
    ) external override onlyRole(MILESTONE_VALIDATOR_ROLE) {
        _validateAndDisburseMilestone(grantId, milestoneIndex, approved, msg.sender);
    }

    /**
     * @notice Internal function to validate milestone and auto-disburse
     */
    function _validateAndDisburseMilestone(
        uint256 grantId,
        uint256 milestoneIndex,
        bool approved,
        address validator
    ) internal nonReentrant {
        GrantInfo storage grant = grants[grantId];
        DisbursementSchedule storage schedule = disbursementSchedules[grantId];
        
        if (!schedule.isActive) revert CooperativeGrantManager__InvalidGrantAmount();
        if (milestoneIndex >= schedule.totalMilestones) revert CooperativeGrantManager__InvalidGrantAmount();
        
        MilestoneInfo storage milestone = schedule.milestones[milestoneIndex];
        if (milestone.isCompleted) revert CooperativeGrantManager__InvalidGrantAmount();
        
        emit MilestoneValidated(grantId, milestoneIndex, validator, approved);
        
        if (approved) {
            // Calculate disbursement amount
            uint256 disbursementAmount = (grant.amount * milestone.percentageShare) / BASIS_POINTS;
            
            // Verify escrow has sufficient funds
            if (grantEscrowBalances[grantId] < disbursementAmount) revert CooperativeGrantManager__InsufficientFunds();
            
            // Update milestone status
            milestone.isCompleted = true;
            milestone.completedTimestamp = block.timestamp;
            milestone.validator = validator;
            milestone.disbursedAmount = disbursementAmount;
            
            // Update counters
            schedule.completedMilestones++;
            grant.disbursedAmount += disbursementAmount;
            grantEscrowBalances[grantId] -= disbursementAmount;
            totalEscrowBalance -= disbursementAmount;
            totalGrantsDisbursed += disbursementAmount;
            
            // Transfer funds to cooperative
            usdcToken.safeTransfer(grant.cooperative, disbursementAmount);
            
            // Update grant status if this is the first disbursement
            if (grant.status == GrantStatus.Pending) {
                grant.status = GrantStatus.Active;
            }
            
            // Check if all milestones completed
            if (schedule.completedMilestones == schedule.totalMilestones) {
                schedule.isActive = false;
                // Grant remains Active for revenue sharing phase
            }
            
            emit MilestoneCompleted(grantId, milestoneIndex, milestone.evidenceUri, validator, disbursementAmount);
            emit AutoDisbursementExecuted(grantId, milestoneIndex, disbursementAmount, grant.cooperative);
        }
    }

    // ============ VIEW FUNCTIONS ============

    /**
     * @notice Returns grant details
     * @dev Implements interface specification exactly
     */
    function getGrant(uint256 grantId) external view override returns (GrantInfo memory) {
        return grants[grantId];
    }

    /**
     * @notice Returns if a grant is active
     * @dev Implements interface specification exactly
     */
    function isGrantActive(uint256 grantId) external view override returns (bool) {
        return grants[grantId].status == GrantStatus.Active;
    }

    /**
     * @notice Returns total revenue shared for a grant
     * @dev Implements interface specification exactly
     */
    function getTotalRevenueShared(uint256 grantId) external view override returns (uint256) {
        return grants[grantId].totalRevenueShared;
    }

    /**
     * @notice Returns all grants for a cooperative
     * @dev Implements interface specification exactly
     */
    function getCooperativeGrants(address cooperative) external view override returns (uint256[] memory) {
        return cooperativeGrants[cooperative];
    }

    // ============ PRICING FUNCTIONS ============

    /**
     * @notice Calculates fair minimum price for coffee batches
     * @dev Implements interface specification exactly
     */
    function calculateFairMinPrice(
        uint256 /* batchId */,
        uint256 currentMarketPrice
    ) external pure override returns (uint256 fairPrice) {
        // Add 10% premium over market price as fair minimum
        return currentMarketPrice + (currentMarketPrice * 1000) / 10000;
    }

    /**
     * @notice Gets current commodity price index
     * @dev Implements interface specification exactly
     */
    function getCurrentCommodityPrice() external view override returns (uint256) {
        return currentCommodityPrice;
    }

    /**
     * @notice Updates commodity price (admin function)
     * @dev Implements interface specification exactly
     */
    function updateCommodityPrice(uint256 newPrice) external override onlyRole(FINANCIAL_ROLE) {
        uint256 oldPrice = currentCommodityPrice;
        currentCommodityPrice = newPrice;
        
        emit CommodityPriceUpdated(oldPrice, newPrice);
    }

    // ============ INTERNAL FUNCTIONS ============

    /**
     * @dev Creates a grant internally with all required fields
     */
    function _createGrantInternal(
        address cooperative,
        uint256 amount,
        uint256 revenueSharePercentage,
        uint256 durationYears,
        string memory description,
        bool isGreenfield,
        uint256 projectId
    ) internal returns (uint256 grantId) {
        grantId = nextGrantId++;
        
        grants[grantId] = GrantInfo({
            cooperative: cooperative,
            amount: amount,
            disbursedAmount: 0,
            daoOwnershipPercent: 0, // Set to 0 for grants (vs equity)
            revenueSharePercent: revenueSharePercentage,
            startTime: block.timestamp,
            maturityTime: block.timestamp + (durationYears * 365 days),
            batchIds: new uint256[](0), // Will be set later for non-greenfield
            totalRevenueShared: 0,
            minimumRevenueTarget: amount, // Set minimum target to grant amount
            status: GrantStatus.Pending,
            purpose: description,
            cooperativeName: "", // To be set externally if needed
            location: "", // To be set externally if needed
            isGreenfield: isGreenfield,
            greenfieldProjectId: projectId,
            pricingInfo: PricingInfo({
                commodityPrice: currentCommodityPrice,
                premiumPercentage: 1000, // 10% premium
                guaranteedMinPrice: 0, // To be calculated when needed
                lastPriceUpdate: block.timestamp,
                isPricingActive: true
            })
        });
        
        // Track grants
        cooperativeGrants[cooperative].push(grantId);
        
        return grantId;
    }

    /**
     * @dev Completes a grant internally
     */
    function _completeGrant(uint256 grantId) internal {
        GrantInfo storage grant = grants[grantId];
        
        if (grant.status != GrantStatus.Active) {
            if (grant.status == GrantStatus.Completed) {
                revert CooperativeGrantManager__GrantAlreadyCompleted();
            }
            revert CooperativeGrantManager__GrantNotActive();
        }
        
        // Determine completion status based on time and revenue
        if (block.timestamp >= grant.maturityTime) {
            grant.status = GrantStatus.Matured;
        } else {
            grant.status = GrantStatus.Completed;
        }
        
        emit GrantCompleted(grantId, grant.totalRevenueShared);
    }

    // ============ ADMIN FUNCTIONS ============

    /**
     * @notice Updates treasury address
     */
    function setTreasury(address _treasury) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_treasury != address(0), "Invalid treasury");
        
        address oldTreasury = treasury;
        treasury = _treasury;
        
        emit TreasuryUpdated(oldTreasury, _treasury);
    }

    /**
     * @notice Pauses the contract
     */
    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    /**
     * @notice Unpauses the contract
     */
    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    /**
     * @notice Emergency withdrawal function
     */
    function emergencyWithdraw(address token, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        IERC20(token).safeTransfer(treasury, amount);
    }
    
    /**
     * @notice Returns the grant ID associated with a batch
     * @param batchId The batch ID to query
     * @return grantId The grant ID (0 if no grant associated)
     */
    function getBatchGrant(uint256 batchId) external view override returns (uint256 grantId) {
        return batchToGrant[batchId];
    }

    // ============ PHASED DISBURSEMENT VIEW FUNCTIONS ============

    /**
     * @notice Gets disbursement schedule for a grant
     * @param grantId The grant ID
     * @return schedule The disbursement schedule
     */
    function getDisbursementSchedule(uint256 grantId) 
        external view override returns (DisbursementSchedule memory schedule) {
        return disbursementSchedules[grantId];
    }

    /**
     * @notice Gets specific milestone info
     * @param grantId The grant ID
     * @param milestoneIndex The milestone index
     * @return milestone The milestone information
     */
    function getMilestoneInfo(uint256 grantId, uint256 milestoneIndex)
        external view override returns (MilestoneInfo memory milestone) {
        require(milestoneIndex < disbursementSchedules[grantId].totalMilestones, "Invalid milestone index");
        return disbursementSchedules[grantId].milestones[milestoneIndex];
    }

    /**
     * @notice Gets grant escrow balance
     * @param grantId The grant ID
     * @return balance The escrow balance for the grant
     */
    function getGrantEscrowBalance(uint256 grantId) external view returns (uint256 balance) {
        return grantEscrowBalances[grantId];
    }

    /**
     * @notice Checks if grant has active disbursement schedule
     * @param grantId The grant ID
     * @return hasSchedule Whether the grant has an active disbursement schedule
     */
    function hasActiveDisbursementSchedule(uint256 grantId) external view returns (bool hasSchedule) {
        return disbursementSchedules[grantId].isActive;
    }
}

