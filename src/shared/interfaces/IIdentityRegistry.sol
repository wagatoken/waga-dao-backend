// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title IIdentityRegistry
 * @dev Interface for the Identity Registry contract used for ERC-3643 compliance
 * @author WAGA Protocol
 * 
 * This interface defines the functions required for managing KYC/AML verified addresses
 * in the WAGA Protocol ecosystem. Only addresses verified through this registry
 * can participate in token transfers and governance.
 */
interface IIdentityRegistry {
    
    // ============ Events ============
    
    /// @dev Emitted when an identity is registered
    event IdentityRegistered(address indexed identity, address indexed registrar);
    
    /// @dev Emitted when an identity is revoked
    event IdentityRevoked(address indexed identity, address indexed registrar);
    
    // ============ View Functions ============
    
    /**
     * @dev Checks if an address is verified in the registry
     * @param identity The address to check
     * @return True if the address is verified, false otherwise
     */
    function isVerified(address identity) external view returns (bool);
    
    /**
     * @dev Returns the total number of verified identities
     * @return The count of verified addresses
     */
    function getVerifiedCount() external view returns (uint256);
    
    /**
     * @dev Checks if an address can receive tokens (verified and not frozen)
     * @param identity The address to check
     * @return True if the address can receive tokens
     */
    function canReceiveTokens(address identity) external view returns (bool);
    
    /**
     * @dev Checks if an address can send tokens (verified and not frozen)
     * @param identity The address to check
     * @return True if the address can send tokens
     */
    function canSendTokens(address identity) external view returns (bool);
    
    // ============ Administrative Functions ============
    
    /**
     * @dev Registers a new verified identity
     * @param identity The address to register as verified
     * 
     * Requirements:
     * - Caller must have REGISTRAR_ROLE
     * - Identity cannot be zero address
     * - Identity cannot already be registered
     */
    function registerIdentity(address identity) external;
    
    /**
     * @dev Revokes a verified identity
     * @param identity The address to revoke verification for
     * 
     * Requirements:
     * - Caller must have REGISTRAR_ROLE
     * - Identity must be currently verified
     */
    function revokeIdentity(address identity) external;
    
    /**
     * @dev Batch registers multiple identities
     * @param identities Array of addresses to register as verified
     * 
     * Requirements:
     * - Caller must have REGISTRAR_ROLE
     * - All identities must be valid addresses
     */
    function batchRegisterIdentities(address[] calldata identities) external;
    
    /**
     * @dev Batch revokes multiple identities
     * @param identities Array of addresses to revoke verification for
     * 
     * Requirements:
     * - Caller must have REGISTRAR_ROLE
     */
    function batchRevokeIdentities(address[] calldata identities) external;
}
