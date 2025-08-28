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
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {IIdentityRegistry} from "../shared/interfaces/IIdentityRegistry.sol";

/**
 * @title MainnetCollateralManager
 * @dev Manages PAXG collateral donations on Ethereum mainnet for WAGA DAO
 * @author WAGA DAO - Regenerative Coffee Global Impact
 * 
 * This contract handles PAXG (gold-backed token) donations on Ethereum mainnet
 * and sends cross-chain messages via Chainlink CCIP to the Base network for
 * VERT token minting and coffee cooperative financing.
 * 
 * Key Features:
 * - PAXG donation processing with real-time XAU/USD pricing
 * - Chainlink CCIP integration for cross-chain messaging
 * - Emergency withdrawal and collateral tracking
 * - Identity verification integration for compliance
 * - Coffee-specific metadata tracking for regenerative agriculture
 * - Support for cooperative development project funding
 */
contract MainnetCollateralManager is AccessControl, Pausable, ReentrancyGuard, CCIPReceiver, OwnerIsCreator {
    using SafeERC20 for IERC20;

    /* -------------------------------------------------------------------------- */
    /*                                 CUSTOM ERRORS                             */
    /* -------------------------------------------------------------------------- */

    error MainnetCollateralManager__InvalidPaxgToken_constructor();
    error MainnetCollateralManager__InvalidLinkToken_constructor();
    error MainnetCollateralManager__InvalidPriceFeed_constructor();
    error MainnetCollateralManager__InvalidIdentityRegistry_constructor();
    error MainnetCollateralManager__InvalidTreasury_constructor();
    error MainnetCollateralManager__ZeroAmount_processPaxgDonation();
    error MainnetCollateralManager__AddressNotVerified_processPaxgDonation();
    error MainnetCollateralManager__DestinationChainNotSet_processPaxgDonation();
    error MainnetCollateralManager__DestinationContractNotSet_processPaxgDonation();
    error MainnetCollateralManager__InvalidPriceFromOracle();
    error MainnetCollateralManager__StalePriceData();
    error MainnetCollateralManager__InsufficientLinkForFees();
    error MainnetCollateralManager__InvalidDestinationContract_setDestinationContract();
    error MainnetCollateralManager__InvalidTreasury_setTreasury();
    error MainnetCollateralManager__InvalidIdentityRegistry_setIdentityRegistry();
    error MainnetCollateralManager__InvalidTokenAddress_emergencyWithdraw();
    error MainnetCollateralManager__InvalidDestinationAddress_emergencyWithdraw();
    error MainnetCollateralManager__ZeroAmount_emergencyWithdraw();

    /* -------------------------------------------------------------------------- */
    /*                                    ROLES                                   */
    /* -------------------------------------------------------------------------- */
    
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant TREASURER_ROLE = keccak256("TREASURER_ROLE");
    bytes32 public constant CCIP_MANAGER_ROLE = keccak256("CCIP_MANAGER_ROLE");

    /* -------------------------------------------------------------------------- */
    /*                                   STORAGE                                  */
    /* -------------------------------------------------------------------------- */
    
    /// @dev PAXG token contract (Ethereum mainnet: 0x45804880De22913dAFE09f4c7C32D4f71b54bdA02913)
    IERC20 public immutable i_paxgToken;
    
    /// @dev LINK token for CCIP fees
    IERC20 public immutable i_linkToken;
    
    /// @dev Chainlink XAU/USD price feed (for PAXG which tracks gold)
    AggregatorV3Interface public immutable i_xauUsdPriceFeed;
    
    /// @dev Identity registry for KYC verification
    IIdentityRegistry public s_identityRegistry;
    
    /// @dev Treasury address for collecting donations
    address public s_treasury;
    
    /// @dev Destination chain selector for CCIP messages (Base network)
    uint64 public s_destinationChainSelector;
    
    /// @dev Destination contract address on Base network (DonationHandler)
    address public s_destinationContract;
    
    /// @dev Total PAXG collateral held by the contract
    uint256 public s_totalPaxgCollateral;
    
    /// @dev Mapping of addresses to their PAXG contribution amounts
    mapping(address => uint256) public s_userPaxgContributions;

    /* -------------------------------------------------------------------------- */
    /*                                   EVENTS                                   */
    /* -------------------------------------------------------------------------- */
    
    event PaxgDonationProcessed(
        address indexed donor,
        uint256 paxgAmount,
        uint256 usdValue,
        uint256 vertToMint,
        uint256 priceUsed
    );
    
    event CrossChainMessageSent(
        uint64 indexed destinationChain,
        address indexed destinationContract,
        address indexed donor,
        uint256 paxgAmount,
        bytes32 messageId
    );
    
    event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);
    event DestinationChainUpdated(uint64 oldChain, uint64 newChain);
    event DestinationContractUpdated(address indexed oldContract, address indexed newContract);
    event CollateralWithdrawn(address indexed token, uint256 amount, address indexed to);
    event SourceChainUpdated(uint64 indexed chainSelector, bool allowed);
    event DestinationUpdated(uint64 indexed chainSelector, address indexed destination);

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev Constructor for MainnetCollateralManager
     * @param _router Chainlink CCIP router address
     * @param _paxgToken PAXG token contract address
     * @param _linkToken LINK token contract address  
     * @param _xauUsdPriceFeed Chainlink XAU/USD price feed address
     * @param _identityRegistry Identity registry contract address
     * @param _treasury Treasury address for donations
     */
    constructor(
        address _router,
        address _paxgToken,
        address _linkToken,
        address _xauUsdPriceFeed,
        address _identityRegistry,
        address _treasury
    ) 
        CCIPReceiver(_router)
    {
        if (_paxgToken == address(0)) revert MainnetCollateralManager__InvalidPaxgToken_constructor();
        if (_linkToken == address(0)) revert MainnetCollateralManager__InvalidLinkToken_constructor();
        if (_xauUsdPriceFeed == address(0)) revert MainnetCollateralManager__InvalidPriceFeed_constructor();
        if (_identityRegistry == address(0)) revert MainnetCollateralManager__InvalidIdentityRegistry_constructor();
        if (_treasury == address(0)) revert MainnetCollateralManager__InvalidTreasury_constructor();

        i_paxgToken = IERC20(_paxgToken);
        i_linkToken = IERC20(_linkToken);
        i_xauUsdPriceFeed = AggregatorV3Interface(_xauUsdPriceFeed);
        s_identityRegistry = IIdentityRegistry(_identityRegistry);
        s_treasury = _treasury;

        // Set up roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(TREASURER_ROLE, msg.sender);
        _grantRole(CCIP_MANAGER_ROLE, msg.sender);
    }

    /* -------------------------------------------------------------------------- */
    /*                              CORE FUNCTIONS                               */
    /* -------------------------------------------------------------------------- */
    
        /**
     * @dev Process PAXG donation and send cross-chain message
     * @param amount Amount of PAXG to donate
     */
    function processPaxgDonation(
        uint256 amount
    ) external nonReentrant whenNotPaused {
        if (amount == 0) revert MainnetCollateralManager__ZeroAmount_processPaxgDonation();
        if (!s_identityRegistry.isVerified(msg.sender)) revert MainnetCollateralManager__AddressNotVerified_processPaxgDonation();
        if (s_destinationChainSelector == 0) revert MainnetCollateralManager__DestinationChainNotSet_processPaxgDonation();
        if (s_destinationContract == address(0)) revert MainnetCollateralManager__DestinationContractNotSet_processPaxgDonation();

        // Transfer PAXG from donor to this contract
        i_paxgToken.safeTransferFrom(msg.sender, address(this), amount);

        // Get current XAU/USD price for PAXG valuation
        (, int256 price, , uint256 updatedAt, ) = i_xauUsdPriceFeed.latestRoundData();
        if (price <= 0) revert MainnetCollateralManager__InvalidPriceFromOracle();
        if (block.timestamp - updatedAt > 3600) revert MainnetCollateralManager__StalePriceData(); // 1 hour staleness check

        uint256 currentXauPrice = uint256(price); // Price has 8 decimals from Chainlink

        // Calculate USD value of PAXG donation (PAXG has 18 decimals, price is 8 decimals)
        uint256 usdValue = (amount * currentXauPrice) / 1e8;

        // Calculate VERT tokens to mint (1 USD = 1 VERT)
        uint256 vertToMint = usdValue;

        // Update storage
        s_totalPaxgCollateral += amount;
        s_userPaxgContributions[msg.sender] += amount;

        // Send cross-chain message to Base network
        bytes32 messageId = _sendCCIPMessage(
            s_destinationChainSelector,
            s_destinationContract,
            abi.encode(msg.sender, vertToMint)
        );

        emit PaxgDonationProcessed(
            msg.sender,
            amount,
            usdValue,
            vertToMint,
            currentXauPrice
        );

        emit CrossChainMessageSent(
            s_destinationChainSelector,
            s_destinationContract,
            msg.sender,
            amount,
            messageId
        );
    }

    /* -------------------------------------------------------------------------- */
    /*                            ADMIN FUNCTIONS                                */
    /* -------------------------------------------------------------------------- */

    /**
     * @dev Send CCIP message to destination chain
     * @param destinationChainSelector Target chain selector
     * @param receiver Contract address on destination chain
     * @param data Encoded message data
     * @return messageId CCIP message ID
     */
    function _sendCCIPMessage(
        uint64 destinationChainSelector,
        address receiver,
        bytes memory data
    ) internal returns (bytes32 messageId) {
        // Create an EVM2AnyMessage struct for cross-chain transfer
        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver),
            data: data,
            tokenAmounts: new Client.EVMTokenAmount[](0), // No tokens transferred
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 500_000}) // Gas limit for destination
            ),
            feeToken: address(i_linkToken) // Pay fees in LINK
        });

        // Get the fee required to send the CCIP message
        uint256 fees = IRouterClient(i_ccipRouter).getFee(destinationChainSelector, evm2AnyMessage);

        if (i_linkToken.balanceOf(address(this)) < fees) revert MainnetCollateralManager__InsufficientLinkForFees();

        // Approve the router to transfer LINK tokens on our behalf
        SafeERC20.forceApprove(i_linkToken, address(i_ccipRouter), fees);

        // Send the CCIP message
        messageId = IRouterClient(i_ccipRouter).ccipSend(destinationChainSelector, evm2AnyMessage);

        return messageId;
    }

    /**
     * @dev Handle received CCIP messages (for future cross-chain governance)
     * @param any2EvmMessage Received CCIP message
     */
    function _ccipReceive(Client.Any2EVMMessage memory any2EvmMessage) internal override {
        // Currently not implementing receiving logic
        // Future: Handle governance messages from Base network
        emit CrossChainMessageSent(
            any2EvmMessage.sourceChainSelector,
            abi.decode(any2EvmMessage.sender, (address)),
            address(0),
            0,
            any2EvmMessage.messageId
        );
    }

    /* -------------------------------------------------------------------------- */
    /*                              VIEW FUNCTIONS                               */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev Get current XAU/USD price from Chainlink oracle
     * @return price Current gold price in USD (8 decimals)
     * @return updatedAt Timestamp of last price update
     */
    function getCurrentXauPrice() external view returns (uint256 price, uint256 updatedAt) {
        (, int256 latestPrice, , uint256 latestUpdatedAt, ) = i_xauUsdPriceFeed.latestRoundData();
        if (latestPrice <= 0) revert MainnetCollateralManager__InvalidPriceFromOracle();
        return (uint256(latestPrice), latestUpdatedAt);
    }

    /**
     * @dev Calculate VERT tokens for a given PAXG amount
     * @param paxgAmount Amount of PAXG
     * @return vertAmount Amount of VERT tokens to mint
     */
    function calculateVertForPaxg(uint256 paxgAmount) external view returns (uint256 vertAmount) {
        (, int256 price, , , ) = i_xauUsdPriceFeed.latestRoundData();
        if (price <= 0) revert MainnetCollateralManager__InvalidPriceFromOracle();
        
        uint256 currentXauPrice = uint256(price);
        uint256 usdValue = (paxgAmount * currentXauPrice) / 1e8;
        return usdValue; // 1 USD = 1 VERT
    }

        /**
     * @dev Get user PAXG contribution info
     * @param user Address to query
     * @return contribution User's total PAXG contribution
     */
    function getUserContribution(address user) external view returns (uint256 contribution) {
        return s_userPaxgContributions[user];
    }

    /**
     * @dev Get overall contract statistics
     * @return totalPaxgCollateral Total PAXG held as collateral
     * @return contractPaxgBalance Current PAXG balance
     * @return contractLinkBalance Current LINK balance for CCIP fees
     */
    function getContractStats() external view returns (
        uint256 totalPaxgCollateral,
        uint256 contractPaxgBalance,
        uint256 contractLinkBalance
    ) {
        return (
            s_totalPaxgCollateral,
            i_paxgToken.balanceOf(address(this)),
            i_linkToken.balanceOf(address(this))
        );
    }

    /* -------------------------------------------------------------------------- */
    /*                              ADMIN FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev Set destination chain for CCIP messages
     * @param destinationChainSelector Chain selector for target network
     */
    function setDestinationChain(uint64 destinationChainSelector) external onlyRole(CCIP_MANAGER_ROLE) {
        uint64 oldChain = s_destinationChainSelector;
        s_destinationChainSelector = destinationChainSelector;
        emit DestinationChainUpdated(oldChain, destinationChainSelector);
    }

    /**
     * @dev Set destination contract address for CCIP messages
     * @param destinationContract Contract address on target network
     */
    function setDestinationContract(address destinationContract) external onlyRole(CCIP_MANAGER_ROLE) {
        if (destinationContract == address(0)) revert MainnetCollateralManager__InvalidDestinationContract_setDestinationContract();
        address oldContract = s_destinationContract;
        s_destinationContract = destinationContract;
        emit DestinationContractUpdated(oldContract, destinationContract);
    }

    /**
     * @dev Update treasury address
     * @param newTreasury New treasury address
     */
    function setTreasury(address newTreasury) external onlyRole(TREASURER_ROLE) {
        if (newTreasury == address(0)) revert MainnetCollateralManager__InvalidTreasury_setTreasury();
        address oldTreasury = s_treasury;
        s_treasury = newTreasury;
        emit TreasuryUpdated(oldTreasury, newTreasury);
    }

    /**
     * @dev Update identity registry address
     * @param newIdentityRegistry New identity registry address
     */
    function setIdentityRegistry(address newIdentityRegistry) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (newIdentityRegistry == address(0)) revert MainnetCollateralManager__InvalidIdentityRegistry_setIdentityRegistry();
        s_identityRegistry = IIdentityRegistry(newIdentityRegistry);
    }

    /**
     * @dev Emergency withdrawal function
     * @param token Token address to withdraw (PAXG, LINK, etc.)
     * @param amount Amount to withdraw
     * @param to Destination address
     */
    function emergencyWithdraw(
        address token,
        uint256 amount,
        address to
    ) external onlyRole(TREASURER_ROLE) {
        if (token == address(0)) revert MainnetCollateralManager__InvalidTokenAddress_emergencyWithdraw();
        if (to == address(0)) revert MainnetCollateralManager__InvalidDestinationAddress_emergencyWithdraw();
        if (amount == 0) revert MainnetCollateralManager__ZeroAmount_emergencyWithdraw();

        IERC20(token).safeTransfer(to, amount);
        emit CollateralWithdrawn(token, amount, to);
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
     * @dev Allow contract to receive LINK tokens for CCIP fees
     */
    receive() external payable {
        // Allow receiving ETH for potential future use
    }
}
