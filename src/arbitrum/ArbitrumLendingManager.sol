// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {OwnerIsCreator} from "@chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title ArbitrumLendingManager  
 * @dev Manages USDC lending operations on Arbitrum for WAGA DAO coffee cooperative financing
 * @author WAGA DAO - Regenerative Coffee Global Impact
 * 
 * This contract handles USDC lending operations via Aave Protocol V3 on Arbitrum
 * to generate yield for coffee cooperative financing. It receives governance
 * instructions via Chainlink CCIP from the Base network and deploys funds
 * to optimize returns for regenerative agriculture projects.
 * 
 * Key Features:
 * - USDC lending operations via Aave Protocol V3
 * - Automated yield harvesting (3-5% APY target)
 * - Cross-chain governance execution via CCIP
 * - Emergency withdrawal and position management
 * - Coffee cooperative loan fund optimization
 * - Multi-year greenfield project financing support
 */
contract ArbitrumLendingManager is AccessControl, Pausable, ReentrancyGuard, CCIPReceiver, OwnerIsCreator {
    using SafeERC20 for IERC20;

    /* -------------------------------------------------------------------------- */
    /*                                    ROLES                                   */
    /* -------------------------------------------------------------------------- */
    
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant EMERGENCY_ROLE = keccak256("EMERGENCY_ROLE");
    bytes32 public constant YIELD_MANAGER_ROLE = keccak256("YIELD_MANAGER_ROLE");
    bytes32 public constant CCIP_MANAGER_ROLE = keccak256("CCIP_MANAGER_ROLE");

    /* -------------------------------------------------------------------------- */
    /*                                   STORAGE                                  */
    /* -------------------------------------------------------------------------- */
    
    /// @dev USDC token contract (Arbitrum: 0xA0b86a33E6417eFAe4D46b7D19FA6a5B1B7e96E6)
    IERC20 public immutable i_usdcToken;
    
    /// @dev aUSDC token from Aave (interest-bearing USDC)
    IERC20 public immutable i_aUsdcToken;
    
    /// @dev Aave Pool contract for lending operations
    address public immutable i_aavePool;
    
    /// @dev LINK token for CCIP fees
    IERC20 public immutable i_linkToken;
    
    /// @dev Treasury address for collecting yield
    address public s_treasury;
    
    /// @dev Allowed source chains for CCIP messages
    mapping(uint64 => bool) public s_allowedSourceChains;
    
    /// @dev Total USDC deployed to lending
    uint256 public s_totalDeployedAmount;
    
    /// @dev Total yield harvested from lending
    uint256 public s_totalYieldHarvested;
    
    /// @dev Mapping of cooperative addresses to their allocated lending amounts
    mapping(address => uint256) public s_cooperativeLendingAllocations;
    
    /// @dev Mapping of cooperative addresses to yield earned for their allocations
    mapping(address => uint256) public s_cooperativeYieldEarned;
    
    /// @dev Total amount allocated specifically for coffee cooperative lending
    uint256 public s_totalCooperativeAllocation;
    
    /// @dev Minimum amount for lending operations
    uint256 public s_minimumLendingAmount;
    
    /// @dev Last yield harvest timestamp
    uint256 public s_lastYieldHarvest;

    /* -------------------------------------------------------------------------- */
    /*                                   EVENTS                                   */
    /* -------------------------------------------------------------------------- */
    
    event LendingDeployed(uint256 amount, uint256 aTokensReceived, uint256 timestamp);
    event YieldHarvested(uint256 yieldAmount, uint256 totalYield, address indexed treasury);
    event EmergencyWithdrawal(uint256 amount, address indexed to, uint256 timestamp);
    event CooperativeAllocationUpdated(address indexed cooperative, uint256 oldAmount, uint256 newAmount);
    event CrossChainInstructionReceived(uint64 indexed sourceChain, bytes32 indexed messageId, string instruction);
    event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);
    event MinimumLendingAmountUpdated(uint256 oldAmount, uint256 newAmount);
    event SourceChainUpdated(uint64 indexed chainSelector, bool allowed);

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev Constructor for ArbitrumLendingManager
     * @param _router Chainlink CCIP router address
     * @param _usdcToken USDC token contract address
     * @param _aUsdcToken aUSDC token contract address
     * @param _aavePool Aave Pool contract address
     * @param _linkToken LINK token contract address
     * @param _treasury Treasury address for yield collection
     */
    constructor(
        address _router,
        address _usdcToken,
        address _aUsdcToken,
        address _aavePool,
        address _linkToken,
        address _treasury
    ) 
        CCIPReceiver(_router) 
        OwnerIsCreator()
    {
        require(_usdcToken != address(0), "Invalid USDC token address");
        require(_aUsdcToken != address(0), "Invalid aUSDC token address");
        require(_aavePool != address(0), "Invalid Aave pool address");
        require(_linkToken != address(0), "Invalid LINK token address");
        require(_treasury != address(0), "Invalid treasury address");

        i_usdcToken = IERC20(_usdcToken);
        i_aUsdcToken = IERC20(_aUsdcToken);
        i_aavePool = _aavePool;
        i_linkToken = IERC20(_linkToken);
        s_treasury = _treasury;
        
        s_minimumLendingAmount = 1000 * 1e6; // 1000 USDC minimum
        s_lastYieldHarvest = block.timestamp;

        // Set up roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(EMERGENCY_ROLE, msg.sender);
        _grantRole(YIELD_MANAGER_ROLE, msg.sender);
        _grantRole(CCIP_MANAGER_ROLE, msg.sender);
    }

    /* -------------------------------------------------------------------------- */
    /*                              CORE FUNCTIONS                               */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev Deploy USDC to Aave lending protocol for yield generation
     * @param amount Amount of USDC to deploy
     * @return aTokensReceived Amount of aUSDC tokens received
     */
    function deployToLending(uint256 amount) external onlyRole(YIELD_MANAGER_ROLE) nonReentrant whenNotPaused returns (uint256 aTokensReceived) {
        require(amount >= s_minimumLendingAmount, "Amount below minimum");
        require(i_usdcToken.balanceOf(address(this)) >= amount, "Insufficient USDC balance");

        // Deploy to Aave lending
        aTokensReceived = _deployToLending(amount);
        
        s_totalDeployedAmount += amount;
        
        emit LendingDeployed(amount, aTokensReceived, block.timestamp);
        return aTokensReceived;
    }

    /**
     * @dev Allocate lending yield to specific coffee cooperative
     * @param cooperative Address of the coffee cooperative
     * @param amount Amount to allocate from available funds
     */
    function allocateToCooperative(
        address cooperative,
        uint256 amount,
        string calldata /* purpose */
    ) external onlyRole(YIELD_MANAGER_ROLE) {
        require(cooperative != address(0), "Invalid cooperative address");
        require(amount > 0, "Amount must be greater than 0");
        require(i_usdcToken.balanceOf(address(this)) >= amount, "Insufficient USDC balance");

        uint256 oldAmount = s_cooperativeLendingAllocations[cooperative];
        s_cooperativeLendingAllocations[cooperative] += amount;
        s_totalCooperativeAllocation += amount;

        // Deploy allocated amount to lending for yield generation
        if (amount >= s_minimumLendingAmount) {
            _deployToLending(amount);
        }

        emit CooperativeAllocationUpdated(cooperative, oldAmount, s_cooperativeLendingAllocations[cooperative]);
    }

    /**
     * @dev Harvest yield from Aave lending positions
     * @return yieldHarvested Amount of yield harvested
     */
    function harvestYield() external onlyRole(YIELD_MANAGER_ROLE) nonReentrant whenNotPaused returns (uint256 yieldHarvested) {
        require(block.timestamp >= s_lastYieldHarvest + 1 hours, "Too frequent harvest");

        uint256 currentATokenBalance = i_aUsdcToken.balanceOf(address(this));
        
        // Calculate yield as difference between current aToken balance and deployed amount
        if (currentATokenBalance > s_totalDeployedAmount) {
            yieldHarvested = currentATokenBalance - s_totalDeployedAmount;
            
            if (yieldHarvested > 0) {
                // Withdraw yield from Aave
                _withdrawFromLending(yieldHarvested);
                
                s_totalYieldHarvested += yieldHarvested;
                s_lastYieldHarvest = block.timestamp;
                
                // Transfer harvested yield to treasury
                i_usdcToken.safeTransfer(s_treasury, yieldHarvested);
                
                emit YieldHarvested(yieldHarvested, s_totalYieldHarvested, s_treasury);
            }
        }
        
        return yieldHarvested;
    }

    /**
     * @dev Internal function to deploy USDC to Aave lending
     * @param amount Amount to deploy
     * @return aTokensReceived Amount of aUSDC received
     */
    function _deployToLending(uint256 amount) internal returns (uint256 aTokensReceived) {
        uint256 balanceBefore = i_aUsdcToken.balanceOf(address(this));
        
        // Approve Aave pool to spend USDC
        SafeERC20.forceApprove(i_usdcToken, i_aavePool, amount);
        
        // Supply USDC to Aave pool
        // Aave V3 supply function: supply(asset, amount, onBehalfOf, referralCode)
        (bool success, ) = i_aavePool.call(
            abi.encodeWithSignature(
                "supply(address,uint256,address,uint16)",
                address(i_usdcToken),
                amount,
                address(this),
                0
            )
        );
        require(success, "Aave supply failed");
        
        uint256 balanceAfter = i_aUsdcToken.balanceOf(address(this));
        aTokensReceived = balanceAfter - balanceBefore;
        
        return aTokensReceived;
    }

    /**
     * @dev Internal function to withdraw USDC from Aave lending
     * @param amount Amount to withdraw
     * @return amountWithdrawn Actual amount withdrawn
     */
    function _withdrawFromLending(uint256 amount) internal returns (uint256 amountWithdrawn) {
        uint256 balanceBefore = i_usdcToken.balanceOf(address(this));
        
        // Withdraw from Aave pool
        // Aave V3 withdraw function: withdraw(asset, amount, to)
        (bool success, ) = i_aavePool.call(
            abi.encodeWithSignature(
                "withdraw(address,uint256,address)",
                address(i_usdcToken),
                amount,
                address(this)
            )
        );
        require(success, "Aave withdrawal failed");
        
        uint256 balanceAfter = i_usdcToken.balanceOf(address(this));
        amountWithdrawn = balanceAfter - balanceBefore;
        
        return amountWithdrawn;
    }

    /**
     * @dev Handle received CCIP messages from Base network governance
     * @param any2EvmMessage Received CCIP message
     */
    function _ccipReceive(Client.Any2EVMMessage memory any2EvmMessage) internal override {
        require(s_allowedSourceChains[any2EvmMessage.sourceChainSelector], "Source chain not allowed");
        
        // Decode the instruction from governance
        string memory instruction = abi.decode(any2EvmMessage.data, (string));
        
        emit CrossChainInstructionReceived(
            any2EvmMessage.sourceChainSelector,
            any2EvmMessage.messageId,
            instruction
        );
        
        // Process governance instructions
        _processGovernanceInstruction(instruction);
    }

    /**
     * @dev Process governance instructions received via CCIP
     * @param instruction Governance instruction to process
     */
    function _processGovernanceInstruction(string memory instruction) internal {
        // Simple instruction processing - can be expanded
        bytes32 instructionHash = keccak256(abi.encodePacked(instruction));
        
        if (instructionHash == keccak256(abi.encodePacked("HARVEST_YIELD"))) {
            if (hasRole(YIELD_MANAGER_ROLE, address(this))) {
                // Auto-harvest if instructed by governance
                this.harvestYield();
            }
        } else if (instructionHash == keccak256(abi.encodePacked("EMERGENCY_PAUSE"))) {
            if (hasRole(PAUSER_ROLE, address(this))) {
                _pause();
            }
        }
        // Additional instructions can be added here
    }

    /* -------------------------------------------------------------------------- */
    /*                              VIEW FUNCTIONS                               */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev Get current lending position information
     * @return totalDeployed Total USDC deployed to lending
     * @return currentATokenBalance Current aUSDC balance
     * @return estimatedYield Estimated harvestable yield
     * @return currentAPY Estimated current APY
     */
    function getLendingPosition() external view returns (
        uint256 totalDeployed,
        uint256 currentATokenBalance,
        uint256 estimatedYield,
        uint256 currentAPY
    ) {
        totalDeployed = s_totalDeployedAmount;
        currentATokenBalance = i_aUsdcToken.balanceOf(address(this));
        
        if (currentATokenBalance > totalDeployed) {
            estimatedYield = currentATokenBalance - totalDeployed;
        } else {
            estimatedYield = 0;
        }
        
        // Calculate APY based on time elapsed and yield earned
        if (totalDeployed > 0 && block.timestamp > s_lastYieldHarvest) {
            uint256 timeElapsed = block.timestamp - s_lastYieldHarvest;
            uint256 yieldRate = (estimatedYield * 365 days * 10000) / (totalDeployed * timeElapsed);
            currentAPY = yieldRate; // APY in basis points (100 = 1%)
        }
        
        return (totalDeployed, currentATokenBalance, estimatedYield, currentAPY);
    }

    /**
     * @dev Get cooperative allocation information
     * @param cooperative Address of the cooperative
     * @return allocation Total allocation for the cooperative
     * @return yieldEarned Total yield earned for the cooperative
     */
    function getCooperativeInfo(address cooperative) external view returns (
        uint256 allocation,
        uint256 yieldEarned
    ) {
        return (s_cooperativeLendingAllocations[cooperative], s_cooperativeYieldEarned[cooperative]);
    }

    /**
     * @dev Get overall contract statistics
     * @return totalDeployed Total USDC deployed to lending
     * @return totalYieldHarvested Total yield harvested
     * @return totalCooperativeAllocation Total allocated to cooperatives
     * @return contractUSDCBalance Current USDC balance
     * @return contractAUSDCBalance Current aUSDC balance
     */
    function getContractStats() external view returns (
        uint256 totalDeployed,
        uint256 totalYieldHarvested,
        uint256 totalCooperativeAllocation,
        uint256 contractUSDCBalance,
        uint256 contractAUSDCBalance
    ) {
        return (
            s_totalDeployedAmount,
            s_totalYieldHarvested,
            s_totalCooperativeAllocation,
            i_usdcToken.balanceOf(address(this)),
            i_aUsdcToken.balanceOf(address(this))
        );
    }

    /* -------------------------------------------------------------------------- */
    /*                              ADMIN FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev Set allowed source chain for CCIP messages
     * @param chainSelector Chain selector to allow/disallow
     * @param allowed Whether the chain is allowed
     */
    function setAllowedSourceChain(uint64 chainSelector, bool allowed) external onlyRole(CCIP_MANAGER_ROLE) {
        s_allowedSourceChains[chainSelector] = allowed;
        emit SourceChainUpdated(chainSelector, allowed);
    }

    /**
     * @dev Update treasury address
     * @param newTreasury New treasury address
     */
    function setTreasury(address newTreasury) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newTreasury != address(0), "Invalid treasury address");
        address oldTreasury = s_treasury;
        s_treasury = newTreasury;
        emit TreasuryUpdated(oldTreasury, newTreasury);
    }

    /**
     * @dev Update minimum lending amount
     * @param newMinimum New minimum lending amount
     */
    function setMinimumLendingAmount(uint256 newMinimum) external onlyRole(YIELD_MANAGER_ROLE) {
        uint256 oldAmount = s_minimumLendingAmount;
        s_minimumLendingAmount = newMinimum;
        emit MinimumLendingAmountUpdated(oldAmount, newMinimum);
    }

    /**
     * @dev Emergency withdrawal function
     * @param amount Amount to withdraw from lending
     * @param to Destination address
     */
    function emergencyWithdraw(uint256 amount, address to) external onlyRole(EMERGENCY_ROLE) {
        require(to != address(0), "Invalid destination address");
        require(amount > 0, "Amount must be greater than 0");

        // Withdraw from Aave if needed
        uint256 usdcBalance = i_usdcToken.balanceOf(address(this));
        if (usdcBalance < amount) {
            uint256 toWithdrawFromAave = amount - usdcBalance;
            _withdrawFromLending(toWithdrawFromAave);
        }

        i_usdcToken.safeTransfer(to, amount);
        emit EmergencyWithdrawal(amount, to, block.timestamp);
    }

    /**
     * @dev Pause contract operations
     */
    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /**
     * @dev Unpause contract operations
     */
    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /* -------------------------------------------------------------------------- */
    /*                              SUPPORT FUNCTIONS                            */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev Support ERC165 interface detection
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl, CCIPReceiver) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Allow contract to receive ETH for potential future use
     */
    receive() external payable {
        // Allow receiving ETH for potential future use
    }
}
