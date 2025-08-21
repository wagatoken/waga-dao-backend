// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IIdentityRegistry} from "../shared/interfaces/IIdentityRegistry.sol";
import {OracleLib} from "../libraries/OracleLib.sol";

/**
 * @title DonationHandler (Enhanced Multi-Chain)
 * @dev Contract for handling multi-currency donations with CCIP support
 * @author WAGA DAO - Regenerative Coffee Global Impact
 *
 * This contract serves as the Base network hub for donations to WAGA DAO.
 * It accepts direct donations (ETH, USDC, fiat) and receives cross-chain
 * PAXG donations from Ethereum via Chainlink CCIP.
 *
 * Features:
 * - Multi-currency donation support (ETH, USDC direct + PAXG via CCIP)
 * - Cross-chain PAXG donation processing via Chainlink CCIP
 * - Dynamic conversion rates with real-time price feeds
 * - ERC-3643 compliance (only verified addresses can receive tokens)
 * - Source chain validation for security
 * - Emergency pause functionality
 * - Transparent event logging
 * - Support for regenerative coffee agriculture funding
 */
contract DonationHandler is
    Ownable,
    AccessControl,
    Pausable,
    ReentrancyGuard,
    CCIPReceiver
{
    using SafeERC20 for IERC20;
    using Address for address payable;
    using OracleLib for AggregatorV3Interface;

    /* -------------------------------------------------------------------------- */
    /*                                 CUSTOM ERRORS                             */
    /* -------------------------------------------------------------------------- */

    error DonationHandler__InvalidAddress_constructor();
    error DonationHandler__NoEthSent_receiveEthDonation();
    error DonationHandler__NoUsdcSent_receiveUsdcDonation();
    error DonationHandler__UnverifiedAddress_receiveEthDonation();
    error DonationHandler__UnverifiedAddress_receiveUsdcDonation();
    error DonationHandler__InvalidSourceChain_ccipReceive();
    error DonationHandler__InvalidMessageData_ccipReceive();

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTANTS                                  */
    /* -------------------------------------------------------------------------- */

    /// @dev Role identifier for addresses authorized to record fiat donations
    bytes32 public constant FIAT_MANAGER_ROLE = keccak256("FIAT_MANAGER_ROLE");

    /// @dev Role identifier for addresses authorized to withdraw funds
    bytes32 public constant TREASURER_ROLE = keccak256("TREASURER_ROLE");

    /// @dev Base amount for token calculations (VERT has 18 decimals)
    uint256 public constant TOKEN_BASE = 1e18;
    
    /// @dev USDC precision multiplier (USDC has 6 decimals, so we use 1e12 for conversion)
    uint256 private constant USDC_PRECISION = 1e12;
    
    /// @dev Fixed VERT token price in USD (with 18 decimals) - $10.00 USD
    uint256 public constant VERT_PRICE_USD = 10e18;

    // ============ State Variables ============

    /// @dev The WAGA Vertical Integration Token (VERT) contract
    address public immutable i_vertToken;

    /// @dev The Identity Registry contract
    IIdentityRegistry public immutable i_identityRegistry;

    /// @dev USDC token contract on Base network
    IERC20 public immutable i_usdcToken;

    /// @dev Chainlink ETH/USD price feed (for ETH donations on Base)
    AggregatorV3Interface public immutable i_ethUsdPriceFeed;

    /// @dev Chainlink XAU/USD price feed (for PAXG which tracks gold)
    AggregatorV3Interface public immutable i_xauUsdPriceFeed;

    /// @dev Treasury address where funds are sent
    address public treasury;

    /// @dev Mapping of allowed source chains for CCIP messages
    mapping(uint64 => bool) public allowedSourceChains;

    // ============ Donation Tracking ============

    /// @dev Total donations received per currency type
    struct DonationTotals {
        uint256 ethTotal;
        uint256 usdcTotal;
        uint256 paxgTotal;
        uint256 fiatTotal; // In USD cents
        uint256 vertMinted;
    }

    /// @dev Global donation totals
    DonationTotals public totalDonations;

    /// @dev Individual donor contributions (donor => currency => amount)
    mapping(address donor => mapping(string currency => uint256 amount))
        public donorContributions;

    /// @dev Individual donor VERT tokens received
    mapping(address donor => uint256 tokensReceived) public donorTokensReceived;

    // ============ Events ============

    /// @dev Emitted when ETH donation is received
    event EthDonationReceived(
        address indexed donor,
        uint256 ethAmount,
        uint256 vertMinted,
        uint256 ethPriceUsed
    );

    /// @dev Emitted when USDC donation is received
    event UsdcDonationReceived(
        address indexed donor,
        uint256 usdcAmount,
        uint256 vertMinted,
        uint256 usdcPriceUsed
    );

    /// @dev Emitted when PAXG donation is received via CCIP
    event PaxgDonationReceived(
        address indexed donor,
        uint256 paxgAmount,
        uint256 vertMinted,
        uint256 xauPriceUsed,
        uint64 sourceChain
    );

    /// @dev Emitted when CCIP message is received
    event CCIPMessageReceived(
        bytes32 indexed messageId,
        uint64 indexed sourceChainSelector,
        address sender,
        bytes data
    );

    /// @dev Emitted when source chain allowance is updated
    event SourceChainUpdated(uint64 indexed chainSelector, bool allowed);

    /// @dev Emitted when fiat donation is recorded
    event FiatDonationRecorded(
        address indexed donor,
        uint256 fiatAmountCents,
        uint256 vertMinted,
        string currency
    );

    /// @dev Emitted when treasury address is updated
    event TreasuryUpdated(
        address indexed oldTreasury,
        address indexed newTreasury
    );

    /// @dev Emitted when funds are withdrawn to treasury
    event FundsWithdrawn(
        address indexed token,
        uint256 amount,
        address indexed to
    );

    // ============ Legacy Errors (for backwards compatibility) ============

    /// @dev Error thrown when donation amount is zero
    error ZeroDonationAmount();

    /// @dev Error thrown when donor is not verified
    error DonorNotVerified(address donor);

    /// @dev Error thrown when conversion rate is zero
    error InvalidConversionRate();

    /// @dev Error thrown when treasury address is zero
    error ZeroTreasuryAddress();

    /// @dev Error thrown when token transfer fails
    error TokenTransferFailed();

    /// @dev Error thrown when ETH transfer fails
    error EthTransferFailed();

    /// @dev Error thrown when insufficient allowance
    error InsufficientAllowance(uint256 required, uint256 available);

    // ============ Constructor ============

    /**
     * @dev Constructor that initializes the donation handler with CCIP support
     * @param _vertToken Address of the WAGA Vertical Integration Token (VERT)
     * @param _identityRegistry Address of the Identity Registry
     * @param _usdcToken Address of USDC token on Base
     * @param _ethUsdPriceFeed Address of Chainlink ETH/USD price feed
     * @param _xauUsdPriceFeed Address of Chainlink XAU/USD price feed (for PAXG)
     * @param _ccipRouter Address of Chainlink CCIP router
     * @param _treasury Address where donations will be sent
     * @param _initialOwner Address that will be the initial owner
     */
    constructor(
        address _vertToken,
        address _identityRegistry,
        address _usdcToken,
        address _ethUsdPriceFeed,
        address _xauUsdPriceFeed,
        address _ccipRouter,
        address _treasury,
        address _initialOwner
    ) Ownable(_initialOwner) CCIPReceiver(_ccipRouter) {
        if (
            _vertToken == address(0) ||
            _identityRegistry == address(0) ||
            _usdcToken == address(0) ||
            _ethUsdPriceFeed == address(0) ||
            _xauUsdPriceFeed == address(0) ||
            _ccipRouter == address(0) ||
            _treasury == address(0) ||
            _initialOwner == address(0)
        ) {
            revert DonationHandler__InvalidAddress_constructor();
        }

        i_vertToken = _vertToken;
        i_identityRegistry = IIdentityRegistry(_identityRegistry);
        i_usdcToken = IERC20(_usdcToken);
        i_ethUsdPriceFeed = AggregatorV3Interface(_ethUsdPriceFeed);
        i_xauUsdPriceFeed = AggregatorV3Interface(_xauUsdPriceFeed);
        treasury = _treasury;

        // Grant roles to initial owner
        _grantRole(DEFAULT_ADMIN_ROLE, _initialOwner);
        _grantRole(FIAT_MANAGER_ROLE, _initialOwner);
        _grantRole(TREASURER_ROLE, _initialOwner);
    }

    // ============ CCIP Functions ============

    /**
     * @dev Called by the CCIP router when a message is received from another chain
     * @param any2EvmMessage The CCIP message containing donor address and PAXG amount
     */
    function _ccipReceive(
        Client.Any2EVMMessage memory any2EvmMessage
    ) internal override {
        // Validate source chain is allowed
        if (!allowedSourceChains[any2EvmMessage.sourceChainSelector]) {
            revert DonationHandler__InvalidSourceChain_ccipReceive();
        }

        // Decode message data (donor address and PAXG amount)
        (address donor, uint256 paxgAmount) = abi.decode(
            any2EvmMessage.data,
            (address, uint256)
        );

        // Process the PAXG donation
        _processPaxgDonation(
            donor,
            paxgAmount,
            any2EvmMessage.sourceChainSelector
        );

        // Emit CCIP message received event
        emit CCIPMessageReceived(
            any2EvmMessage.messageId,
            any2EvmMessage.sourceChainSelector,
            abi.decode(any2EvmMessage.sender, (address)),
            any2EvmMessage.data
        );
    }

    /**
     * @dev Process PAXG donation received via CCIP
     * @param donor Address of the donor on the destination chain
     * @param paxgAmount Amount of PAXG donated
     * @param sourceChain Chain selector of the source chain
     */
    function _processPaxgDonation(
        address donor,
        uint256 paxgAmount,
        uint64 sourceChain
    ) internal {
        if (paxgAmount == 0)
            revert DonationHandler__InvalidMessageData_ccipReceive();
        if (!i_identityRegistry.isVerified(donor))
            revert DonorNotVerified(donor);

        // Get current XAU (gold) price from Chainlink
        // PAXG tracks the price of gold, so we use XAU/USD price feed
        uint256 currentXauPrice = i_xauUsdPriceFeed.getPriceWith18Decimals();

        // Calculate USD value of PAXG donation (PAXG has 18 decimals, price is 18 decimals)
        uint256 usdValue = (paxgAmount * currentXauPrice) / TOKEN_BASE;
        
        // Calculate VERT tokens to mint: usdValue / VERT_PRICE_USD
        uint256 vertToMint = (usdValue * TOKEN_BASE) / VERT_PRICE_USD;

        // Track donation totals and contributions
        totalDonations.paxgTotal += paxgAmount;
        totalDonations.vertMinted += vertToMint;
        donorContributions[donor]["PAXG"] += paxgAmount;
        donorTokensReceived[donor] += vertToMint;

        // Mint VERT tokens to the donor
        _mintTokens(donor, vertToMint);
        emit PaxgDonationReceived(
            donor,
            paxgAmount,
            vertToMint,
            currentXauPrice,
            sourceChain
        );
    }

    /**
     * @dev Set allowed source chains for CCIP messages
     * @param chainSelector Chain selector to allow/disallow
     * @param allowed Whether the chain is allowed
     */
    function setCCIPConfig(
        uint64 chainSelector,
        bool allowed
    ) external onlyOwner {
        allowedSourceChains[chainSelector] = allowed;
        emit SourceChainUpdated(chainSelector, allowed);
    }

    /**
     * @dev Override supportsInterface to handle multiple inheritance
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(AccessControl, CCIPReceiver) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // ============ Donation Functions ============

    /**
     * @dev Receives ETH donations and mints VERT tokens
     *
     * Requirements:
     * - Donor must be verified in identity registry
     * - Contract must not be paused
     * - Donation amount must be greater than 0
     */
    function receiveEthDonation() external payable whenNotPaused nonReentrant {
        if (msg.value == 0)
            revert DonationHandler__NoEthSent_receiveEthDonation();
        if (!i_identityRegistry.isVerified(msg.sender))
            revert DonationHandler__UnverifiedAddress_receiveEthDonation();

        // Get current ETH price from Chainlink (with stale price check)
        uint256 currentEthPrice = i_ethUsdPriceFeed.getPriceWith18Decimals();

        // Calculate USD value of ETH donation
        uint256 usdValue = (msg.value * currentEthPrice) / TOKEN_BASE;

        // Calculate VERT tokens to mint: usdValue / VERT_PRICE_USD
        uint256 vertToMint = (usdValue * TOKEN_BASE) / VERT_PRICE_USD;

        // Update tracking
        totalDonations.ethTotal += msg.value;
        totalDonations.vertMinted += vertToMint;
        donorContributions[msg.sender]["ETH"] += msg.value;
        donorTokensReceived[msg.sender] += vertToMint;

        // Mint VERT tokens to donor
        _mintTokens(msg.sender, vertToMint);

        // Transfer ETH to treasury
        payable(treasury).sendValue(msg.value);

        emit EthDonationReceived(
            msg.sender,
            msg.value,
            vertToMint,
            currentEthPrice
        );
    }

    /**
     * @dev Receives USDC donations and mints VERT tokens
     * @param _amount Amount of USDC to donate (in USDC decimals, typically 6)
     *
     * Requirements:
     * - Donor must have approved this contract to spend USDC
     * - Donor must be verified in identity registry
     * - Contract must not be paused
     * - Donation amount must be greater than 0
     */
    function receiveUsdcDonation(
        uint256 _amount
    ) external whenNotPaused nonReentrant {
        if (_amount == 0)
            revert DonationHandler__NoUsdcSent_receiveUsdcDonation();
        if (!i_identityRegistry.isVerified(msg.sender))
            revert DonationHandler__UnverifiedAddress_receiveUsdcDonation();

        // Check allowance
        uint256 allowance = i_usdcToken.allowance(msg.sender, address(this));
        if (allowance < _amount)
            revert InsufficientAllowance(_amount, allowance);

        // Calculate USD value (USDC has 6 decimals, convert to 18 decimals)
        uint256 usdValue = _amount * USDC_PRECISION;

        // Calculate VERT tokens to mint: usdValue / VERT_PRICE_USD
        uint256 vertToMint = (usdValue * TOKEN_BASE) / VERT_PRICE_USD;

        // Update tracking
        totalDonations.usdcTotal += _amount;
        totalDonations.vertMinted += vertToMint;
        donorContributions[msg.sender]["USDC"] += _amount;
        donorTokensReceived[msg.sender] += vertToMint;

        // Transfer USDC from donor to treasury
        i_usdcToken.safeTransferFrom(msg.sender, treasury, _amount);

        // Mint VERT tokens to donor
        _mintTokens(msg.sender, vertToMint);

        emit UsdcDonationReceived(
            msg.sender,
            _amount,
            vertToMint,
            1e18 // USDC is assumed to be $1
        );
    }

    /**
     * @dev Records fiat donations and mints VERT tokens (off-chain donations)
     * @param _donor Address of the donor (must be verified)
     * @param _fiatAmountCents Amount donated in fiat currency (in cents)
     * @param _currency Currency code (e.g., "USD", "EUR", "CHF")
     *
     * Requirements:
     * - Caller must have FIAT_MANAGER_ROLE
     * - Donor must be verified in identity registry
     * - Contract must not be paused
     * - Donation amount must be greater than 0
     */
    function donateFiat(
        address _donor,
        uint256 _fiatAmountCents,
        string calldata _currency
    ) external onlyRole(FIAT_MANAGER_ROLE) whenNotPaused nonReentrant {
        if (_fiatAmountCents == 0) revert ZeroDonationAmount();
        if (!i_identityRegistry.isVerified(_donor))
            revert DonorNotVerified(_donor);

        // Convert cents to USD value (in 18 decimals)
        uint256 usdValue = (_fiatAmountCents * TOKEN_BASE) / 100;

        // Calculate VERT tokens to mint: usdValue / VERT_PRICE_USD
        uint256 vertToMint = (usdValue * TOKEN_BASE) / VERT_PRICE_USD;

        // Update tracking
        totalDonations.fiatTotal += _fiatAmountCents;
        totalDonations.vertMinted += vertToMint;
        donorContributions[_donor][_currency] += _fiatAmountCents;
        donorTokensReceived[_donor] += vertToMint;

        // Mint VERT tokens to donor
        _mintTokens(_donor, vertToMint);

        emit FiatDonationRecorded(
            _donor,
            _fiatAmountCents,
            vertToMint,
            _currency
        );
    }

    // ============ Internal Functions ============

    /**
     * @dev Internal function to mint VERT tokens using improved interface approach
     * @param to Address to mint tokens to
     * @param amount Amount of tokens to mint
     */
    function _mintTokens(address to, uint256 amount) internal {
        // Call the mint function on the VERT token contract
        (bool success, ) = i_vertToken.call(
            abi.encodeWithSignature("mint(address,uint256)", to, amount)
        );
        if (!success) revert TokenTransferFailed();
    }

    // ============ Administrative Functions ============

    /**
     * @dev Updates the treasury address
     * @param _newTreasury New treasury address
     *
     * Requirements:
     * - Caller must be the owner
     * - New treasury cannot be zero address
     */
    function setTreasury(address _newTreasury) external onlyOwner {
        if (_newTreasury == address(0)) revert ZeroTreasuryAddress();

        address oldTreasury = treasury;
        treasury = _newTreasury;

        emit TreasuryUpdated(oldTreasury, _newTreasury);
    }

    // ============ Emergency Functions ============

    /**
     * @dev Pauses the contract
     *
     * Requirements:
     * - Caller must be the owner
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses the contract
     *
     * Requirements:
     * - Caller must be the owner
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev Emergency withdrawal of stuck tokens
     * @param token Address of token to withdraw (address(0) for ETH)
     * @param amount Amount to withdraw
     *
     * Requirements:
     * - Caller must have TREASURER_ROLE
     */
    function emergencyWithdraw(
        address token,
        uint256 amount
    ) external onlyRole(TREASURER_ROLE) {
        if (token == address(0)) {
            // Withdraw ETH
            payable(treasury).sendValue(amount);
            emit FundsWithdrawn(address(0), amount, treasury);
        } else {
            // Withdraw ERC20 token
            IERC20(token).safeTransfer(treasury, amount);
            emit FundsWithdrawn(token, amount, treasury);
        }
    }

    // ============ View Functions ============

    /**
     * @dev Calculate VERT tokens for a given ETH amount
     * @param ethAmount Amount of ETH
     * @return vertAmount Amount of VERT tokens that would be minted
     */
    function calculateVertForEth(
        uint256 ethAmount
    ) external view returns (uint256 vertAmount) {
        uint256 currentEthPrice = i_ethUsdPriceFeed.getPriceWith18Decimals();
        uint256 usdValue = (ethAmount * currentEthPrice) / TOKEN_BASE;
        return (usdValue * TOKEN_BASE) / VERT_PRICE_USD;
    }

    /**
     * @dev Calculate VERT tokens for a given USDC amount
     * @param usdcAmount Amount of USDC (6 decimals)
     * @return vertAmount Amount of VERT tokens that would be minted
     */
    function calculateVertForUsdc(
        uint256 usdcAmount
    ) external pure returns (uint256 vertAmount) {
        uint256 usdValue = usdcAmount * USDC_PRECISION;
        return (usdValue * TOKEN_BASE) / VERT_PRICE_USD;
    }

    /**
     * @dev Calculate VERT tokens for a given PAXG amount
     * @param paxgAmount Amount of PAXG
     * @return vertAmount Amount of VERT tokens that would be minted
     */
    function calculateVertForPaxg(
        uint256 paxgAmount
    ) external view returns (uint256 vertAmount) {
        uint256 currentXauPrice = i_xauUsdPriceFeed.getPriceWith18Decimals();
        uint256 usdValue = (paxgAmount * currentXauPrice) / TOKEN_BASE;
        return (usdValue * TOKEN_BASE) / VERT_PRICE_USD;
    }

    /**
     * @dev Calculate VERT tokens for a given USD amount (in cents)
     * @param fiatAmountCents Amount in cents
     * @return vertAmount Amount of VERT tokens that would be minted
     */
    function calculateVertForFiat(
        uint256 fiatAmountCents
    ) external pure returns (uint256 vertAmount) {
        uint256 usdValue = (fiatAmountCents * TOKEN_BASE) / 100;
        return (usdValue * TOKEN_BASE) / VERT_PRICE_USD;
    }

    /**
     * @dev Get donor's total contributions across all currencies
     * @param donor Address of the donor
     * @return ethContributed Total ETH contributed
     * @return usdcContributed Total USDC contributed
     * @return paxgContributed Total PAXG contributed
     * @return tokensReceived Total VERT tokens received
     */
    function getDonorSummary(
        address donor
    )
        external
        view
        returns (
            uint256 ethContributed,
            uint256 usdcContributed,
            uint256 paxgContributed,
            uint256 tokensReceived
        )
    {
        return (
            donorContributions[donor]["ETH"],
            donorContributions[donor]["USDC"],
            donorContributions[donor]["PAXG"],
            donorTokensReceived[donor]
        );
    }
}

/// 1000000000000000000 / 100000000000000000 = 10
