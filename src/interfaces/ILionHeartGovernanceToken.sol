// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title ILionHeartGovernanceToken
 * @dev Interface for the Lion Heart Governance Token with minting capabilities
 * @author Lion Heart Football Centre DAO
 */
interface ILionHeartGovernanceToken is IERC20 {
    
    // ============ Minting Functions ============
    
    /**
     * @dev Mints tokens to a verified address
     * @param to The address to mint tokens to
     * @param amount The amount of tokens to mint
     */
    function mint(address to, uint256 amount) external;
    
    /**
     * @dev Burns tokens from the caller's balance
     * @param amount The amount of tokens to burn
     */
    function burn(uint256 amount) external;
    
    /**
     * @dev Burns tokens from a specific address (requires allowance)
     * @param from The address to burn tokens from
     * @param amount The amount of tokens to burn
     */
    function burnFrom(address from, uint256 amount) external;
    
    // ============ Verification Functions ============
    
    /**
     * @dev Checks if an address is verified in the identity registry
     * @param account The address to check
     * @return True if the address is verified
     */
    function isVerified(address account) external view returns (bool);
    
    // ============ Governance Functions ============
    
    /**
     * @dev Delegates voting power to another address
     * @param delegatee The address to delegate to
     */
    function delegate(address delegatee) external;
    
    /**
     * @dev Gets the current votes balance for an account
     * @param account The address to get votes for
     * @return The number of current votes for account
     */
    function getVotes(address account) external view returns (uint256);
    
    /**
     * @dev Gets the prior votes balance for an account at a specific block
     * @param account The address to get votes for
     * @param blockNumber The block number to get votes at
     * @return The number of votes for account at blockNumber
     */
    function getPastVotes(address account, uint256 blockNumber) external view returns (uint256);
}
