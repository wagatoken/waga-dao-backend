// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Supply} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import {ERC1155URIStorage} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title WAGACoffeeInventoryToken
 * @author WAGA DAO - Regenerative Coffee Global Impact
 * @notice ERC1155 token contract for WAGA DAO coffee batch inventory management
 * @dev Implements batch-based coffee inventory tokens for cooperative financing and supply chain tracking
 * 
 * Each token ID represents a unique coffee batch from African cooperatives with production details,
 * verification status, and metadata. Used by the DAO to manage inventory backing USDC loans.
 */
contract WAGACoffeeInventoryToken is 
    ERC1155, 
    ERC1155Supply, 
    ERC1155URIStorage, 
    AccessControl, 
    Pausable 
{
    using Strings for uint256;

    /* -------------------------------------------------------------------------- */
    /*                                  CONSTANTS                                 */
    /* -------------------------------------------------------------------------- */

    /// @dev Role for DAO treasury/admin operations
    bytes32 public constant DAO_ADMIN_ROLE = keccak256("DAO_ADMIN_ROLE");
    
    /// @dev Role for inventory management operations
    bytes32 public constant INVENTORY_MANAGER_ROLE = keccak256("INVENTORY_MANAGER_ROLE");
    
    /// @dev Role for minting inventory tokens (typically loans contracts)
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    /// @dev Role for burning tokens during sales/distribution
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    
    /// @dev Role for verifying batch metadata and quality
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");
    
    /// @dev Role for infrastructure investment management
    bytes32 public constant INFRASTRUCTURE_MANAGER_ROLE = keccak256("INFRASTRUCTURE_MANAGER_ROLE");
    
    /// @dev Role for revenue distribution management
    bytes32 public constant REVENUE_MANAGER_ROLE = keccak256("REVENUE_MANAGER_ROLE");

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// @dev Mapping from batch ID to batch information
    mapping(uint256 => BatchInfo) public batchInfo;
    
    /// @dev Mapping from batch ID to greenfield information  
    mapping(uint256 => GreenfieldInfo) public greenfieldInfo;
    
    /// @dev Mapping from batch ID to cooperative information
    mapping(uint256 => CooperativeInfo) public cooperativeInfo;
    
    /// @dev Array of all batch IDs for enumeration
    uint256[] public allBatchIds;
    
    /// @dev Array of active batch IDs
    uint256[] public activeBatchIds;
    
    /// @dev Mapping to check if batch is active
    mapping(uint256 => bool) public isActiveBatch;
    
    /// @dev Mapping from batch ID to its index in activeBatchIds array
    mapping(uint256 => uint256) public activeBatchIndex;
    
    /// @dev Next batch ID to be assigned
    uint256 public nextBatchId = 1;
    
    /* -------------------------------------------------------------------------- */
    /*                          INFRASTRUCTURE TOKENIZATION                       */
    /* -------------------------------------------------------------------------- */
    
    /// @dev Mapping from token ID to asset type (batch vs infrastructure)
    mapping(uint256 => AssetType) public assetType;
    
    /// @dev Mapping from infrastructure token ID to infrastructure details
    mapping(uint256 => InfrastructureAsset) public infrastructureAssets;
    
    /// @dev Mapping from infrastructure token ID to ownership structure
    mapping(uint256 => InfrastructureOwnership) public infrastructureOwnership;
    
    /// @dev Mapping from infrastructure token ID to revenue distributions
    mapping(uint256 => RevenueDistribution[]) public revenueDistributions;

    /* -------------------------------------------------------------------------- */
    /*                                   STRUCTS                                  */
    /* -------------------------------------------------------------------------- */

    enum AssetType { COFFEE_BATCH, INFRASTRUCTURE_ASSET }

    struct BatchInfo {
        uint256 productionDate;      // When coffee was processed (0 for future/greenfield)
        uint256 expiryDate;         // Quality expiry date (maturity date for greenfield)
        uint256 currentQuantity;    // Current inventory quantity (0 for future/greenfield)
        uint256 pricePerKg;         // Price per kilogram in USD (projected for greenfield)
        uint256 loanValue;          // USDC loan value backing this batch
        bool isVerified;            // Quality and quantity verified
        bool isMetadataVerified;    // Metadata verified off-chain
        string packagingInfo;       // Packaging details
        string metadataHash;        // IPFS hash of detailed metadata
        uint256 lastVerifiedTimestamp; // Last verification timestamp
    }

    struct GreenfieldInfo {
        bool isGreenfieldProject;   // True for new cooperative formation
        bool isFutureProduction;    // True for future production (existing or greenfield)
        uint256 plantingDate;       // When coffee trees planted (greenfield)
        uint256 maturityDate;       // When trees reach full production
        uint256 projectedYield;     // Expected annual production at maturity
        uint256 investmentStage;    // Current development stage (0-5)
    }

    struct CooperativeInfo {
        string cooperativeName;     // Name of the cooperative
        string location;           // Geographic location (e.g., "Bamendakwe, Cameroon")
        address paymentAddress;    // Address for loan disbursement
        string certifications;     // Quality certifications (e.g., "Organic, Fair Trade")
        uint256 farmersCount;      // Number of farmers in cooperative
    }
    
    struct GreenfieldProjectParams {
        string ipfsUri;
        uint256 plantingDate;
        uint256 maturityDate;
        uint256 projectedYield;
        uint256 investmentStage;
        uint256 pricePerKg;
        uint256 loanValue;
        string cooperativeName;
        string location;
        address paymentAddress;
        string certifications;
        uint256 farmersCount;
    }
    
    struct InfrastructureAsset {
        string assetName;               // "Coffee Processing Plant - Bamendakwe"
        string assetType;               // "Wet Processing Plant", "Drying Beds", "Storage Facility"
        uint256 totalInvestment;        // Total cost in USDC (6 decimals)
        uint256 expectedLifespan;       // Useful life in seconds
        uint256 dailyCapacity;          // Processing capacity (kg/day)
        uint256 processingFeePerKg;     // Revenue per kg processed (USDC, 6 decimals)
        uint256 expectedAnnualRevenue;  // Projected yearly income
        uint256 maintenanceCostPerYear; // Annual upkeep costs
        uint256 installationDate;      // When installed (timestamp)
        uint256 lastMaintenanceDate;   // Last maintenance timestamp
        address equipmentSupplier;      // Verified supplier address
        bool isInstalled;               // Installation status
        bool isOperational;             // Currently generating revenue
        string technicalSpecs;          // IPFS hash of technical specifications
        string maintenanceSchedule;     // IPFS hash of maintenance plan
    }
    
    struct InfrastructureOwnership {
        address cooperative;            // Primary owner (cooperative)
        uint256 totalShares;            // Total ownership shares
        uint256 sharesPerToken;         // Shares represented per ERC1155 token
        uint256 revenuePerShare;        // Last revenue distribution per share
        uint256 totalRevenueGenerated;  // Cumulative revenue
        uint256 lastDistribution;       // Last revenue distribution timestamp
    }
    
    struct RevenueDistribution {
        uint256 totalRevenue;           // Monthly revenue collected
        uint256 operatingExpenses;      // Maintenance, labor, utilities
        uint256 netIncome;              // Revenue - expenses
        uint256 daoFee;                 // DAO management fee
        uint256 cooperativeShare;       // Cooperative's portion
        uint256 distributionDate;       // When distributed
        string reportHash;              // IPFS hash of financial report
    }

    /* -------------------------------------------------------------------------- */
    /*                                CUSTOM ERRORS                               */
    /* -------------------------------------------------------------------------- */

    error WAGACoffeeInventoryToken__InvalidBatchId();
    error WAGACoffeeInventoryToken__BatchAlreadyExists();
    error WAGACoffeeInventoryToken__InvalidDates();
    error WAGACoffeeInventoryToken__InvalidQuantity();
    error WAGACoffeeInventoryToken__InvalidPrice();
    error WAGACoffeeInventoryToken__InvalidLoanValue();
    error WAGACoffeeInventoryToken__BatchNotVerified();
    error WAGACoffeeInventoryToken__BatchExpired();
    error WAGACoffeeInventoryToken__InsufficientInventory();
    error WAGACoffeeInventoryToken__EmptyMetadata();
    error WAGACoffeeInventoryToken__UnauthorizedAccess();
    error WAGACoffeeInventoryToken__InvalidInfrastructureType();
    error WAGACoffeeInventoryToken__InfrastructureNotOperational();
    error WAGACoffeeInventoryToken__InvalidRevenueData();
    error WAGACoffeeInventoryToken__InsufficientInfrastructureShares();

    /* -------------------------------------------------------------------------- */
    /*                                   EVENTS                                   */
    /* -------------------------------------------------------------------------- */

    event BatchCreated(
        uint256 indexed batchId, 
        string cooperativeName, 
        uint256 quantity, 
        uint256 loanValue
    );
    
    event GreenfieldProjectCreated(
        uint256 indexed projectId,
        string cooperativeName,
        uint256 plantingDate,
        uint256 maturityDate,
        uint256 projectedYield,
        uint256 loanValue
    );
    
    event GreenfieldStageAdvanced(
        uint256 indexed projectId,
        uint256 previousStage,
        uint256 newStage,
        uint256 updatedYield
    );
    
    event BatchVerified(uint256 indexed batchId, address verifier);
    event InventoryUpdated(uint256 indexed batchId, uint256 newQuantity);
    event BatchSold(uint256 indexed batchId, uint256 quantity, address buyer);
    event LoanRepaid(uint256 indexed batchId, uint256 amount);
    event BatchExpired(uint256 indexed batchId);
    event CooperativeUpdated(uint256 indexed batchId, string cooperativeName);

    /* -------------------------------------------------------------------------- */
    /*                                  MODIFIERS                                 */
    /* -------------------------------------------------------------------------- */

    modifier validBatchId(uint256 batchId) {
        if (batchId == 0 || batchId >= nextBatchId) {
            revert WAGACoffeeInventoryToken__InvalidBatchId();
        }
        _;
    }

    modifier onlyVerifiedBatch(uint256 batchId) {
        if (!batchInfo[batchId].isVerified) {
            revert WAGACoffeeInventoryToken__BatchNotVerified();
        }
        _;
    }

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
     * @dev Initializes the contract with roles
     * @param _admin Address to be granted DAO_ADMIN_ROLE
     */
    constructor(address _admin) ERC1155("") {
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(DAO_ADMIN_ROLE, _admin);
        _grantRole(INVENTORY_MANAGER_ROLE, _admin);
        _grantRole(VERIFIER_ROLE, _admin);
    }

    /* -------------------------------------------------------------------------- */
    /*                              EXTERNAL FUNCTIONS                            */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Creates a new coffee batch with cooperative and loan information
     * @param ipfsUri IPFS URI for batch metadata
     * @param productionDate Batch production timestamp
     * @param expiryDate Batch expiry timestamp
     * @param quantity Initial quantity in kg
     * @param pricePerKg Price per kg in USD (6 decimals)
     * @param loanValue USDC loan value backing this batch
     * @param cooperativeName Name of the producing cooperative
     * @param location Geographic location
     * @param paymentAddress Address for loan disbursement
     * @param certifications Quality certifications
     * @param farmersCount Number of farmers in cooperative
     * @return batchId The newly created batch ID
     */
    function createBatch(
        string memory ipfsUri,
        uint256 productionDate,
        uint256 expiryDate,
        uint256 quantity,
        uint256 pricePerKg,
        uint256 loanValue,
        string memory cooperativeName,
        string memory location,
        address paymentAddress,
        string memory certifications,
        uint256 farmersCount
    ) external onlyRole(DAO_ADMIN_ROLE) whenNotPaused returns (uint256 batchId) {
        // Validation
        if (productionDate >= expiryDate || expiryDate <= block.timestamp) {
            revert WAGACoffeeInventoryToken__InvalidDates();
        }
        if (quantity == 0) {
            revert WAGACoffeeInventoryToken__InvalidQuantity();
        }
        if (pricePerKg == 0) {
            revert WAGACoffeeInventoryToken__InvalidPrice();
        }
        if (loanValue == 0) {
            revert WAGACoffeeInventoryToken__InvalidLoanValue();
        }
        if (bytes(ipfsUri).length == 0 || bytes(cooperativeName).length == 0) {
            revert WAGACoffeeInventoryToken__EmptyMetadata();
        }

        batchId = nextBatchId++;

        // Store batch information
        batchInfo[batchId] = BatchInfo({
            productionDate: productionDate,
            expiryDate: expiryDate,
            currentQuantity: quantity,
            pricePerKg: pricePerKg,
            loanValue: loanValue,
            isVerified: false,
            isMetadataVerified: false,
            packagingInfo: "25kg bags", // Default packaging
            metadataHash: "",
            lastVerifiedTimestamp: 0
        });

        // Store greenfield information (not a greenfield project)
        greenfieldInfo[batchId] = GreenfieldInfo({
            isGreenfieldProject: false,   // Standard existing cooperative batch
            isFutureProduction: false,    // Current production, not future
            plantingDate: 0,              // Not applicable for existing production
            maturityDate: 0,              // Not applicable for existing production  
            projectedYield: 0,            // Not applicable for existing production
            investmentStage: 6            // Stage 6 = Completed production
        });

        // Store cooperative information
        cooperativeInfo[batchId] = CooperativeInfo({
            cooperativeName: cooperativeName,
            location: location,
            paymentAddress: paymentAddress,
            certifications: certifications,
            farmersCount: farmersCount
        });

        // Set IPFS URI
        _setURI(batchId, ipfsUri);

        // Add to tracking arrays
        allBatchIds.push(batchId);
        _addToActiveBatches(batchId);

        emit BatchCreated(batchId, cooperativeName, quantity, loanValue);
        return batchId;
    }

    /**
     * @notice Creates a greenfield coffee production project for new cooperatives
     * @param params Struct containing all project parameters
     * @return projectId The newly created project ID
     */
    function createGreenfieldProject(
        GreenfieldProjectParams memory params
    ) external onlyRole(DAO_ADMIN_ROLE) whenNotPaused returns (uint256 projectId) {
        _validateGreenfieldParams(params);
        
        projectId = nextBatchId++;
        _createGreenfieldBatchInfo(projectId, params);
        _createCooperativeInfo(projectId, params);
        
        // Set IPFS URI for project documentation
        _setURI(projectId, params.ipfsUri);

        // Add to tracking arrays
        allBatchIds.push(projectId);
        _addToActiveBatches(projectId);

        emit GreenfieldProjectCreated(
            projectId, 
            params.cooperativeName, 
            params.plantingDate, 
            params.maturityDate, 
            params.projectedYield, 
            params.loanValue
        );
        return projectId;
    }

    /**
     * @notice Advances a greenfield project to the next development stage
     * @param projectId The greenfield project ID
     * @param newStage The new development stage (0-5)
     * @param updatedYield Updated yield projection (if changed)
     * @param milestoneEvidence IPFS hash of milestone completion evidence
     */
    function advanceGreenfieldStage(
        uint256 projectId,
        uint256 newStage,
        uint256 updatedYield,
        string memory milestoneEvidence
    ) external onlyRole(DAO_ADMIN_ROLE) validBatchId(projectId) {
        GreenfieldInfo storage greenfield = greenfieldInfo[projectId];
        BatchInfo storage batch = batchInfo[projectId];
        
        // Validation
        if (!greenfield.isGreenfieldProject) {
            revert("Not a greenfield project");
        }
        if (newStage > 5) {
            revert("Invalid stage");
        }
        if (newStage <= greenfield.investmentStage) {
            revert("Stage must advance forward");
        }
        
        // Update project stage
        uint256 previousStage = greenfield.investmentStage;
        greenfield.investmentStage = newStage;
        
        // Update yield projection if provided
        if (updatedYield > 0) {
            greenfield.projectedYield = updatedYield;
        }
        
        // Add milestone evidence to metadata
        if (bytes(milestoneEvidence).length > 0) {
            batch.metadataHash = milestoneEvidence;
        }
        
        // If reaching full production (stage 5), convert to active production
        if (newStage == 5) {
            greenfield.isFutureProduction = false; // Now producing
            batch.productionDate = block.timestamp; // Mark production start
            batch.currentQuantity = greenfield.projectedYield; // Set initial capacity
        }
        
        emit GreenfieldStageAdvanced(projectId, previousStage, newStage, updatedYield);
    }

    /**
     * @notice Verifies a batch's quality and quantity
     * @param batchId Batch to verify
     * @param actualQuantity Verified quantity
     * @param metadataHash IPFS metadata hash
     */
    function verifyBatch(
        uint256 batchId,
        uint256 actualQuantity,
        string memory metadataHash
    ) external onlyRole(VERIFIER_ROLE) validBatchId(batchId) {
        BatchInfo storage batch = batchInfo[batchId];
        
        batch.isVerified = true;
        batch.isMetadataVerified = true;
        batch.currentQuantity = actualQuantity;
        batch.metadataHash = metadataHash;
        batch.lastVerifiedTimestamp = block.timestamp;

        emit BatchVerified(batchId, msg.sender);
        emit InventoryUpdated(batchId, actualQuantity);
    }

    /**
     * @notice Mints inventory tokens representing coffee batches to the DAO
     * @param to Address to mint to (typically DAO treasury)
     * @param batchId Batch to mint tokens for
     * @param amount Amount of tokens to mint (represents kg of coffee)
     */
    function mintInventoryTokens(
        address to,
        uint256 batchId,
        uint256 amount
    ) external onlyRole(MINTER_ROLE) validBatchId(batchId) onlyVerifiedBatch(batchId) {
        if (amount > batchInfo[batchId].currentQuantity) {
            revert WAGACoffeeInventoryToken__InsufficientInventory();
        }

        _mint(to, batchId, amount, "");
    }

    /**
     * @notice Burns inventory tokens when coffee is sold/distributed
     * @param from Address to burn from
     * @param batchId Batch to burn tokens for
     * @param amount Amount to burn
     */
    function burnInventoryTokens(
        address from,
        uint256 batchId,
        uint256 amount
    ) external onlyRole(BURNER_ROLE) validBatchId(batchId) {
        _burn(from, batchId, amount);
        
        BatchInfo storage batch = batchInfo[batchId];
        batch.currentQuantity -= amount;

        if (batch.currentQuantity == 0) {
            _removeFromActiveBatches(batchId);
        }

        emit BatchSold(batchId, amount, from);
        emit InventoryUpdated(batchId, batch.currentQuantity);
    }

    /**
     * @notice Updates inventory quantity (for verified adjustments)
     * @param batchId Batch to update
     * @param newQuantity New quantity
     */
    function updateInventory(
        uint256 batchId,
        uint256 newQuantity
    ) external onlyRole(INVENTORY_MANAGER_ROLE) validBatchId(batchId) {
        BatchInfo storage batch = batchInfo[batchId];
        uint256 oldQuantity = batch.currentQuantity;
        
        batch.currentQuantity = newQuantity;

        // Update active status
        if (newQuantity == 0 && oldQuantity > 0) {
            _removeFromActiveBatches(batchId);
        } else if (newQuantity > 0 && oldQuantity == 0) {
            _addToActiveBatches(batchId);
        }

        emit InventoryUpdated(batchId, newQuantity);
    }

    /**
     * @notice Marks a batch as expired
     * @param batchId Batch to expire
     */
    function markBatchExpired(
        uint256 batchId
    ) external onlyRole(INVENTORY_MANAGER_ROLE) validBatchId(batchId) {
        if (block.timestamp < batchInfo[batchId].expiryDate) {
            revert WAGACoffeeInventoryToken__BatchNotVerified();
        }

        _removeFromActiveBatches(batchId);
        emit BatchExpired(batchId);
    }

    /**
     * @notice Records loan repayment for a batch
     * @param batchId Batch associated with loan
     * @param amount Repayment amount
     */
    function recordLoanRepayment(
        uint256 batchId,
        uint256 amount
    ) external onlyRole(DAO_ADMIN_ROLE) validBatchId(batchId) {
        emit LoanRepaid(batchId, amount);
    }

    /* -------------------------------------------------------------------------- */
    /*                               VIEW FUNCTIONS                               */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Returns batch information
     */
    function getBatchInfo(uint256 batchId) external view validBatchId(batchId) returns (BatchInfo memory) {
        return batchInfo[batchId];
    }

    /**
     * @notice Returns cooperative information
     */
    function getCooperativeInfo(uint256 batchId) external view validBatchId(batchId) returns (CooperativeInfo memory) {
        return cooperativeInfo[batchId];
    }

    /**
     * @notice Returns all active batch IDs
     */
    function getActiveBatchIds() external view returns (uint256[] memory) {
        return activeBatchIds;
    }

    /**
     * @notice Returns total number of batches
     */
    function getTotalBatches() external view returns (uint256) {
        return allBatchIds.length;
    }

    /**
     * @notice Checks if a batch exists
     */
    function batchExists(uint256 batchId) external view returns (bool) {
        return batchId > 0 && batchId < nextBatchId;
    }

    /**
     * @notice Returns the URI for a token ID
     */
    function uri(uint256 tokenId) public view override(ERC1155, ERC1155URIStorage) returns (string memory) {
        return ERC1155URIStorage.uri(tokenId);
    }

    /**
     * @notice Returns detailed information about a greenfield project
     * @param projectId The project ID to query
     */
    function getGreenfieldProjectDetails(uint256 projectId) 
        external 
        view 
        validBatchId(projectId) 
        returns (
            bool isGreenfield,
            string memory cooperativeName,
            string memory location,
            uint256 investmentStage,
            string memory stageName
        ) 
    {
        GreenfieldInfo storage greenfield = greenfieldInfo[projectId];
        CooperativeInfo storage coop = cooperativeInfo[projectId];
        
        // Stage name mapping
        string[6] memory stageNames = [
            "Planning & Preparation",      // 0
            "Land Acquisition",            // 1 
            "Planting & Infrastructure",   // 2
            "Growth & Development",        // 3
            "Initial Production",          // 4
            "Full Production Capacity"     // 5
        ];
        
        return (
            greenfield.isGreenfieldProject,
            coop.cooperativeName,
            coop.location,
            greenfield.investmentStage,
            greenfield.investmentStage < 6 ? stageNames[greenfield.investmentStage] : "Unknown"
        );
    }

    /**
     * @notice Returns financial information about a greenfield project
     * @param projectId The project ID to query
     */
    function getGreenfieldFinancials(uint256 projectId)
        external
        view
        validBatchId(projectId)
        returns (
            uint256 plantingDate,
            uint256 maturityDate,
            uint256 projectedYield,
            uint256 loanValue
        )
    {
        GreenfieldInfo storage greenfield = greenfieldInfo[projectId];
        BatchInfo storage batch = batchInfo[projectId];
        return (
            greenfield.plantingDate,
            greenfield.maturityDate,
            greenfield.projectedYield,
            batch.loanValue
        );
    }

    /* -------------------------------------------------------------------------- */
    /*                            ADMIN FUNCTIONS                                */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Pause contract operations
     */
    function pause() external onlyRole(DAO_ADMIN_ROLE) {
        _pause();
    }

    /**
     * @notice Unpause contract operations
     */
    function unpause() external onlyRole(DAO_ADMIN_ROLE) {
        _unpause();
    }

    /* -------------------------------------------------------------------------- */
    /*                          INTERNAL HELPER FUNCTIONS                        */
    /* -------------------------------------------------------------------------- */

    /**
     * @dev Validates greenfield project parameters
     */
    function _validateGreenfieldParams(GreenfieldProjectParams memory params) internal view {
        if (params.plantingDate >= params.maturityDate) {
            revert WAGACoffeeInventoryToken__InvalidDates();
        }
        if (params.maturityDate <= block.timestamp + (2 * 365 * 24 * 60 * 60)) {
            revert WAGACoffeeInventoryToken__InvalidDates(); // Must be at least 2 years in future
        }
        if (params.projectedYield == 0) {
            revert WAGACoffeeInventoryToken__InvalidQuantity();
        }
        if (params.pricePerKg == 0) {
            revert WAGACoffeeInventoryToken__InvalidPrice();
        }
        if (params.loanValue == 0) {
            revert WAGACoffeeInventoryToken__InvalidLoanValue();
        }
        if (params.investmentStage > 5) {
            revert("Invalid investment stage"); // Stages 0-5 only
        }
        if (bytes(params.ipfsUri).length == 0 || bytes(params.cooperativeName).length == 0) {
            revert WAGACoffeeInventoryToken__EmptyMetadata();
        }
    }

    /**
     * @dev Creates batch info for greenfield project
     */
    function _createGreenfieldBatchInfo(uint256 projectId, GreenfieldProjectParams memory params) internal {
        batchInfo[projectId] = BatchInfo({
            productionDate: 0,              // No production yet
            expiryDate: params.maturityDate, // Repurposed as maturity/loan maturity date
            currentQuantity: 0,             // No current inventory
            pricePerKg: params.pricePerKg,  // Projected price at maturity
            loanValue: params.loanValue,    // Total development loan
            isVerified: false,              // Project verification pending
            isMetadataVerified: false,      // Metadata verification pending
            packagingInfo: "Greenfield Coffee Production Project",
            metadataHash: "",
            lastVerifiedTimestamp: 0
        });

        greenfieldInfo[projectId] = GreenfieldInfo({
            isGreenfieldProject: true,      // This is a greenfield project
            isFutureProduction: true,       // All production is future
            plantingDate: params.plantingDate, // When trees planted/will be planted
            maturityDate: params.maturityDate, // When full production capacity reached
            projectedYield: params.projectedYield, // Expected annual yield at maturity
            investmentStage: params.investmentStage // Current development stage
        });
    }

    /**
     * @dev Creates cooperative info for greenfield project
     */
    function _createCooperativeInfo(uint256 projectId, GreenfieldProjectParams memory params) internal {
        cooperativeInfo[projectId] = CooperativeInfo({
            cooperativeName: params.cooperativeName,
            location: params.location,
            paymentAddress: params.paymentAddress,
            certifications: params.certifications, // Planned certifications
            farmersCount: params.farmersCount
        });
    }

    /* -------------------------------------------------------------------------- */
    /*                             INTERNAL FUNCTIONS                             */
    /* -------------------------------------------------------------------------- */

    /**
     * @dev Adds batch to active tracking
     */
    function _addToActiveBatches(uint256 batchId) internal {
        if (!isActiveBatch[batchId]) {
            isActiveBatch[batchId] = true;
            activeBatchIndex[batchId] = activeBatchIds.length;
            activeBatchIds.push(batchId);
        }
    }

    /**
     * @dev Removes batch from active tracking
     */
    function _removeFromActiveBatches(uint256 batchId) internal {
        if (isActiveBatch[batchId]) {
            uint256 index = activeBatchIndex[batchId];
            uint256 lastIndex = activeBatchIds.length - 1;
            
            if (index != lastIndex) {
                uint256 lastBatchId = activeBatchIds[lastIndex];
                activeBatchIds[index] = lastBatchId;
                activeBatchIndex[lastBatchId] = index;
            }
            
            activeBatchIds.pop();
            delete isActiveBatch[batchId];
            delete activeBatchIndex[batchId];
        }
    }

    /**
     * @dev Required override for ERC1155Supply
     */
    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal override(ERC1155, ERC1155Supply) whenNotPaused {
        super._update(from, to, ids, values);
    }

    /**
     * @dev Interface support
     */
    function supportsInterface(bytes4 interfaceId) 
        public 
        view 
        override(ERC1155, AccessControl) 
        returns (bool) 
    {
        return super.supportsInterface(interfaceId);
    }
}
