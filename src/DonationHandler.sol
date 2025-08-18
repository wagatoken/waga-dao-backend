// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {IIdentityRegistry} from "./interfaces/IIdentityRegistry.sol";

/**
 * @title DonationHandler
 * @dev Contract for handling multi-currency donations and minting VERT tokens
 * @author WAGA DAO - Regenerative Coffee Global Impact
 * 
 * This contract serves as the entry point for donations to WAGA DAO.
 * It accepts donations in multiple currencies (ETH, USDC, PAXG, and fiat) and
 * mints corresponding VERT governance tokens to verified donors.
 * 
 * Features:
 * - Multi-currency donation support (ETH, USDC, PAXG, fiat)
 * - Dynamic conversion rates for fair token distribution
 * - ERC-3643 compliance (only verified addresses can receive tokens)
 * - Emergency pause functionality
 * - Transparent event logging
 * - Gas-optimized operations
 * - Support for regenerative agriculture funding
 */
contract DonationHandler is Ownable, AccessControl, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Address for address payable;
    
    /* -------------------------------------------------------------------------- */
    /*                                 CONSTANTS                                  */
    /* -------------------------------------------------------------------------- */
    
    /// @dev Role identifier for addresses authorized to set conversion rates
    bytes32 public constant RATE_MANAGER_ROLE = keccak256("RATE_MANAGER_ROLE");
    
    /// @dev Role identifier for addresses authorized to record fiat donations
    bytes32 public constant FIAT_MANAGER_ROLE = keccak256("FIAT_MANAGER_ROLE");
    
    /// @dev Role identifier for addresses authorized to withdraw funds
    bytes32 public constant TREASURER_ROLE = keccak256("TREASURER_ROLE");
    
    /// @dev Precision for conversion rate calculations (6 decimals)
    uint256 public constant RATE_PRECISION = 1e6;
    
    /// @dev Base amount for token calculations (VERT has 18 decimals)
    uint256 public constant TOKEN_BASE = 1e18;
    
    // ============ State Variables ============
    
    /// @dev The WAGA Vertical Integration Token (VERT) contract
    address public immutable i_vertToken;
    
    /// @dev The Identity Registry contract
    IIdentityRegistry public immutable i_identityRegistry;
    
    /// @dev USDC token contract on Base network
    IERC20 public immutable i_usdcToken;
    
    /// @dev PAXG token contract on Base network
    IERC20 public immutable i_paxgToken;
    
    /// @dev Treasury address where funds are sent
    address public treasury;
    
    // ============ Conversion Rates (tokens per USD with 6 decimal precision) ============
    
    /// @dev VERT tokens per 1 USD (with RATE_PRECISION decimals)
    uint256 public vertPerUsd;
    
    /// @dev ETH price in USD (with RATE_PRECISION decimals)
    uint256 public ethPriceUsd;
    
    /// @dev USDC price in USD (with RATE_PRECISION decimals) - typically 1e6
    uint256 public usdcPriceUsd;
    
    /// @dev PAXG price in USD (with RATE_PRECISION decimals)
    uint256 public paxgPriceUsd;
    
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
    mapping(address => mapping(string => uint256)) public donorContributions;
    
    /// @dev Individual donor VERT tokens received
    mapping(address => uint256) public donorTokensReceived;
    
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
    
    /// @dev Emitted when PAXG donation is received
    event PaxgDonationReceived(
        address indexed donor, 
        uint256 paxgAmount, 
        uint256 vertMinted, 
        uint256 paxgPriceUsed
    );
    
    /// @dev Emitted when fiat donation is recorded
    event FiatDonationRecorded(
        address indexed donor, 
        uint256 fiatAmountCents, 
        uint256 vertMinted, 
        string currency
    );
    
    /// @dev Emitted when conversion rates are updated
    event ConversionRatesUpdated(
        uint256 vertPerUsd,
        uint256 ethPriceUsd,
        uint256 usdcPriceUsd,
        uint256 paxgPriceUsd,
        address indexed updatedBy
    );
    
    /// @dev Emitted when treasury address is updated
    event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);
    
    /// @dev Emitted when funds are withdrawn to treasury
    event FundsWithdrawn(address indexed token, uint256 amount, address indexed to);
    
    // ============ Custom Errors ============
    
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
     * @dev Constructor that initializes the donation handler
     * @param _vertToken Address of the WAGA Vertical Integration Token (VERT)
     * @param _identityRegistry Address of the Identity Registry
     * @param _usdcToken Address of USDC token on Base
     * @param _paxgToken Address of PAXG token on Base
     * @param _treasury Address where donations will be sent
     * @param _initialOwner Address that will be the initial owner
     */
    constructor(
        address _vertToken,
        address _identityRegistry,
        address _usdcToken,
        address _paxgToken,
        address _treasury,
        address _initialOwner
    ) Ownable(_initialOwner) {
        require(_vertToken != address(0), "Invalid VERT token address");
        require(_identityRegistry != address(0), "Invalid identity registry address");
        require(_usdcToken != address(0), "Invalid USDC token address");
        require(_paxgToken != address(0), "Invalid PAXG token address");
        require(_treasury != address(0), "Invalid treasury address");
        require(_initialOwner != address(0), "Invalid initial owner address");
        
        i_vertToken = _vertToken;
        i_identityRegistry = IIdentityRegistry(_identityRegistry);
        i_usdcToken = IERC20(_usdcToken);
        i_paxgToken = IERC20(_paxgToken);
        treasury = _treasury;
        
        // Grant roles to initial owner
        _grantRole(DEFAULT_ADMIN_ROLE, _initialOwner);
        _grantRole(RATE_MANAGER_ROLE, _initialOwner);
        _grantRole(FIAT_MANAGER_ROLE, _initialOwner);
        _grantRole(TREASURER_ROLE, _initialOwner);
        
        // Set initial conversion rates (these should be updated immediately after deployment)
        // Rate: 1 VERT = $1 USD, so 1 VERT per USD
        vertPerUsd = 1 * RATE_PRECISION; // 1 VERT per USD (1,000,000 with 6 decimals precision)
        ethPriceUsd = 3000 * RATE_PRECISION; // $3000 per ETH initially
        usdcPriceUsd = 1 * RATE_PRECISION; // $1 per USDC
        paxgPriceUsd = 2000 * RATE_PRECISION; // $2000 per PAXG initially
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
        if (msg.value == 0) revert ZeroDonationAmount();
        if (!i_identityRegistry.isVerified(msg.sender)) revert DonorNotVerified(msg.sender);
        if (ethPriceUsd == 0 || vertPerUsd == 0) revert InvalidConversionRate();
        
        // Calculate USD value of ETH donation
        uint256 usdValue = (msg.value * ethPriceUsd) / TOKEN_BASE;
        
        // Calculate VERT tokens to mint
        uint256 vertToMint = (usdValue * vertPerUsd) / RATE_PRECISION;
        
        // Update tracking
        totalDonations.ethTotal += msg.value;
        totalDonations.vertMinted += vertToMint;
        donorContributions[msg.sender]["ETH"] += msg.value;
        donorTokensReceived[msg.sender] += vertToMint;
        
        // Mint VERT tokens to donor
        _mintTokens(msg.sender, vertToMint);
        
        // Transfer ETH to treasury
        payable(treasury).sendValue(msg.value);
        
        emit EthDonationReceived(msg.sender, msg.value, vertToMint, ethPriceUsd);
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
    function receiveUsdcDonation(uint256 _amount) external whenNotPaused nonReentrant {
        if (_amount == 0) revert ZeroDonationAmount();
        if (!i_identityRegistry.isVerified(msg.sender)) revert DonorNotVerified(msg.sender);
        if (usdcPriceUsd == 0 || vertPerUsd == 0) revert InvalidConversionRate();
        
        // Check allowance
        uint256 allowance = i_usdcToken.allowance(msg.sender, address(this));
        if (allowance < _amount) revert InsufficientAllowance(_amount, allowance);
        
        // Calculate USD value (USDC typically has 6 decimals)
        uint256 usdValue = (_amount * usdcPriceUsd) / 1e6;
        
        // Calculate VERT tokens to mint
        uint256 vertToMint = (usdValue * vertPerUsd) / RATE_PRECISION;
        
        // Update tracking
        totalDonations.usdcTotal += _amount;
        totalDonations.vertMinted += vertToMint;
        donorContributions[msg.sender]["USDC"] += _amount;
        donorTokensReceived[msg.sender] += vertToMint;
        
        // Transfer USDC from donor to treasury
        i_usdcToken.safeTransferFrom(msg.sender, treasury, _amount);
        
        // Mint VERT tokens to donor
        _mintTokens(msg.sender, vertToMint);
        
        emit UsdcDonationReceived(msg.sender, _amount, vertToMint, usdcPriceUsd);
    }
    
    /**
     * @dev Receives PAXG donations and mints VERT tokens
     * @param _amount Amount of PAXG to donate (in PAXG decimals, typically 18)
     * 
     * Requirements:
     * - Donor must have approved this contract to spend PAXG
     * - Donor must be verified in identity registry
     * - Contract must not be paused
     * - Donation amount must be greater than 0
     */
    function receivePaxgDonation(uint256 _amount) external whenNotPaused nonReentrant {
        if (_amount == 0) revert ZeroDonationAmount();
        if (!i_identityRegistry.isVerified(msg.sender)) revert DonorNotVerified(msg.sender);
        if (paxgPriceUsd == 0 || vertPerUsd == 0) revert InvalidConversionRate();
        
        // Check allowance
        uint256 allowance = i_paxgToken.allowance(msg.sender, address(this));
        if (allowance < _amount) revert InsufficientAllowance(_amount, allowance);
        
        // Calculate USD value (PAXG typically has 18 decimals)
        uint256 usdValue = (_amount * paxgPriceUsd) / TOKEN_BASE;
        
        // Calculate VERT tokens to mint
        uint256 vertToMint = (usdValue * vertPerUsd) / RATE_PRECISION;
        
        // Update tracking
        totalDonations.paxgTotal += _amount;
        totalDonations.vertMinted += vertToMint;
        donorContributions[msg.sender]["PAXG"] += _amount;
        donorTokensReceived[msg.sender] += vertToMint;
        
        // Transfer PAXG from donor to treasury
        i_paxgToken.safeTransferFrom(msg.sender, treasury, _amount);
        
        // Mint VERT tokens to donor
        _mintTokens(msg.sender, vertToMint);
        
        emit PaxgDonationReceived(msg.sender, _amount, vertToMint, paxgPriceUsd);
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
        if (!i_identityRegistry.isVerified(_donor)) revert DonorNotVerified(_donor);
        if (vertPerUsd == 0) revert InvalidConversionRate();
        
        // Convert cents to USD value (assuming fiat is pegged to USD or converted)
        uint256 usdValue = (_fiatAmountCents * RATE_PRECISION) / 100;
        
        // Calculate VERT tokens to mint
        uint256 vertToMint = (usdValue * vertPerUsd) / RATE_PRECISION;
        
        // Update tracking
        totalDonations.fiatTotal += _fiatAmountCents;
        totalDonations.vertMinted += vertToMint;
        donorContributions[_donor][_currency] += _fiatAmountCents;
        donorTokensReceived[_donor] += vertToMint;
        
        // Mint VERT tokens to donor
        _mintTokens(_donor, vertToMint);
        
        emit FiatDonationRecorded(_donor, _fiatAmountCents, vertToMint, _currency);
    }
    
    // ============ Internal Functions ============
    
    /**
     * @dev Internal function to mint VERT tokens
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
     * @dev Updates conversion rates
     * @param _vertPerUsd VERT tokens per USD (with RATE_PRECISION)
     * @param _ethPriceUsd ETH price in USD (with RATE_PRECISION)
     * @param _usdcPriceUsd USDC price in USD (with RATE_PRECISION)
     * @param _paxgPriceUsd PAXG price in USD (with RATE_PRECISION)
     * 
     * Requirements:
     * - Caller must have RATE_MANAGER_ROLE
     */
    function setConversionRates(
        uint256 _vertPerUsd,
        uint256 _ethPriceUsd,
        uint256 _usdcPriceUsd,
        uint256 _paxgPriceUsd
    ) external onlyRole(RATE_MANAGER_ROLE) {
        require(_vertPerUsd > 0, "Invalid VERT rate");
        require(_ethPriceUsd > 0, "Invalid ETH price");
        require(_usdcPriceUsd > 0, "Invalid USDC price");
        require(_paxgPriceUsd > 0, "Invalid PAXG price");
        
        vertPerUsd = _vertPerUsd;
        ethPriceUsd = _ethPriceUsd;
        usdcPriceUsd = _usdcPriceUsd;
        paxgPriceUsd = _paxgPriceUsd;
        
        emit ConversionRatesUpdated(_vertPerUsd, _ethPriceUsd, _usdcPriceUsd, _paxgPriceUsd, msg.sender);
    }
    
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
    function emergencyWithdraw(address token, uint256 amount) 
        external 
        onlyRole(TREASURER_ROLE) 
    {
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
    function calculateVertForEth(uint256 ethAmount) external view returns (uint256 vertAmount) {
        if (ethPriceUsd == 0 || vertPerUsd == 0) return 0;
        uint256 usdValue = (ethAmount * ethPriceUsd) / TOKEN_BASE;
        return (usdValue * vertPerUsd) / RATE_PRECISION;
    }
    
    /**
     * @dev Calculate VERT tokens for a given USDC amount
     * @param usdcAmount Amount of USDC
     * @return vertAmount Amount of VERT tokens that would be minted
     */
    function calculateVertForUsdc(uint256 usdcAmount) external view returns (uint256 vertAmount) {
        if (usdcPriceUsd == 0 || vertPerUsd == 0) return 0;
        uint256 usdValue = (usdcAmount * usdcPriceUsd) / 1e6;
        return (usdValue * vertPerUsd) / RATE_PRECISION;
    }
    
    /**
     * @dev Calculate VERT tokens for a given PAXG amount
     * @param paxgAmount Amount of PAXG
     * @return vertAmount Amount of VERT tokens that would be minted
     */
    function calculateVertForPaxg(uint256 paxgAmount) external view returns (uint256 vertAmount) {
        if (paxgPriceUsd == 0 || vertPerUsd == 0) return 0;
        uint256 usdValue = (paxgAmount * paxgPriceUsd) / TOKEN_BASE;
        return (usdValue * vertPerUsd) / RATE_PRECISION;
    }
    
    /**
     * @dev Get donor's total contributions across all currencies
     * @param donor Address of the donor
     * @return ethContributed Total ETH contributed
     * @return usdcContributed Total USDC contributed
     * @return paxgContributed Total PAXG contributed
     * @return tokensReceived Total VERT tokens received
     */
    function getDonorSummary(address donor) 
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
