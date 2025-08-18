// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title IDonationHandler
 * @dev Interface for the Donation Handler contract
 * @author Lion Heart Football Centre DAO
 */
interface IDonationHandler {
    
    // ============ Structs ============
    
    struct DonationTotals {
        uint256 ethTotal;
        uint256 usdcTotal;
        uint256 paxgTotal;
        uint256 fiatTotal;
        uint256 lhgtMinted;
    }
    
    // ============ Events ============
    
    event EthDonationReceived(
        address indexed donor, 
        uint256 ethAmount, 
        uint256 lhgtMinted, 
        uint256 ethPriceUsed
    );
    
    event UsdcDonationReceived(
        address indexed donor, 
        uint256 usdcAmount, 
        uint256 lhgtMinted, 
        uint256 usdcPriceUsed
    );
    
    event PaxgDonationReceived(
        address indexed donor, 
        uint256 paxgAmount, 
        uint256 lhgtMinted, 
        uint256 paxgPriceUsed
    );
    
    event FiatDonationRecorded(
        address indexed donor, 
        uint256 fiatAmountCents, 
        uint256 lhgtMinted, 
        string currency
    );
    
    // ============ Donation Functions ============
    
    /**
     * @dev Receives ETH donations and mints LHGT tokens
     */
    function receiveEthDonation() external payable;
    
    /**
     * @dev Receives USDC donations and mints LHGT tokens
     * @param _amount Amount of USDC to donate
     */
    function receiveUsdcDonation(uint256 _amount) external;
    
    /**
     * @dev Receives PAXG donations and mints LHGT tokens
     * @param _amount Amount of PAXG to donate
     */
    function receivePaxgDonation(uint256 _amount) external;
    
    /**
     * @dev Records fiat donations and mints LHGT tokens
     * @param _donor Address of the donor
     * @param _fiatAmountCents Amount donated in fiat currency (in cents)
     * @param _currency Currency code
     */
    function donateFiat(
        address _donor, 
        uint256 _fiatAmountCents, 
        string calldata _currency
    ) external;
    
    // ============ View Functions ============
    
    /**
     * @dev Calculate LHGT tokens for a given ETH amount
     * @param ethAmount Amount of ETH
     * @return lhgtAmount Amount of LHGT tokens that would be minted
     */
    function calculateLhgtForEth(uint256 ethAmount) external view returns (uint256 lhgtAmount);
    
    /**
     * @dev Calculate LHGT tokens for a given USDC amount
     * @param usdcAmount Amount of USDC
     * @return lhgtAmount Amount of LHGT tokens that would be minted
     */
    function calculateLhgtForUsdc(uint256 usdcAmount) external view returns (uint256 lhgtAmount);
    
    /**
     * @dev Calculate LHGT tokens for a given PAXG amount
     * @param paxgAmount Amount of PAXG
     * @return lhgtAmount Amount of LHGT tokens that would be minted
     */
    function calculateLhgtForPaxg(uint256 paxgAmount) external view returns (uint256 lhgtAmount);
    
    /**
     * @dev Get donor's total contributions across all currencies
     * @param donor Address of the donor
     * @return ethContributed Total ETH contributed
     * @return usdcContributed Total USDC contributed
     * @return paxgContributed Total PAXG contributed
     * @return tokensReceived Total LHGT tokens received
     */
    function getDonorSummary(address donor) 
        external 
        view 
        returns (
            uint256 ethContributed,
            uint256 usdcContributed,
            uint256 paxgContributed,
            uint256 tokensReceived
        );
}
