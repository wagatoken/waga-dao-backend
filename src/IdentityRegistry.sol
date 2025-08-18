// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IIdentityRegistry} from "./interfaces/IIdentityRegistry.sol";

/**
 * @title IdentityRegistry
 * @dev Implementation of IIdentityRegistry for managing KYC/AML verified addresses
 * @author Lion Heart Football Centre DAO
 * 
 * This contract manages the whitelist of verified addresses that can participate
 * in the Lion Heart DAO ecosystem. It implements the ERC-3643 standard for
 * identity verification and compliance.
 * 
 * Features:
 * - Role-based access control for registrars
 * - Batch operations for efficiency
 * - Pausable for emergency situations
 * - Event logging for transparency
 * - Gas-optimized storage
 */
contract IdentityRegistry is IIdentityRegistry, AccessControl, Pausable, ReentrancyGuard {
    
    /* -------------------------------------------------------------------------- */
    /*                                 CONSTANTS                                  */
    /* -------------------------------------------------------------------------- */
    
    /// @dev Role identifier for addresses authorized to register/revoke identities
    bytes32 public constant REGISTRAR_ROLE = keccak256("REGISTRAR_ROLE");
    
    /// @dev Role identifier for addresses authorized to pause the contract
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    
    /// @dev Maximum batch size to prevent gas limit issues
    uint256 public constant MAX_BATCH_SIZE = 100;
    
    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */
    
    /// @dev Mapping to track verified addresses
    mapping(address => bool) private s_verifiedIdentities;
    
    /// @dev Count of verified identities
    uint256 private s_verifiedCount;
    
    /* -------------------------------------------------------------------------- */
    /*                                CUSTOM ERRORS                               */
    /* -------------------------------------------------------------------------- */
    
    /// @dev Error thrown when trying to register zero address
    error IdentityRegistry__ZeroAddressNotAllowed();
    
    /// @dev Error thrown when trying to register an already verified identity
    error IdentityRegistry__IdentityAlreadyRegistered(address identity);
    
    /// @dev Error thrown when trying to revoke a non-verified identity
    error IdentityRegistry__IdentityNotRegistered(address identity);
    
    /// @dev Error thrown when batch arrays are empty
    error IdentityRegistry__EmptyBatchArray();
    
    /// @dev Error thrown when batch arrays are too large
    error IdentityRegistry__BatchSizeTooLarge(uint256 size, uint256 maxSize);
    
    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev Constructor that sets up the identity registry
     * @param admin Address that will have admin role and can grant other roles
     */
    constructor(address admin) {
        if (admin == address(0)) revert IdentityRegistry__ZeroAddressNotAllowed();
        
        // Grant roles to admin
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(REGISTRAR_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);
    }
    
    /* -------------------------------------------------------------------------- */
    /*                               VIEW FUNCTIONS                               */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev See {IIdentityRegistry-isVerified}
     */
    function isVerified(address identity) external view override returns (bool) {
        return s_verifiedIdentities[identity];
    }
    
    /**
     * @dev See {IIdentityRegistry-getVerifiedCount}
     */
    function getVerifiedCount() external view override returns (uint256) {
        return s_verifiedCount;
    }
    
    /**
     * @dev See {IIdentityRegistry-canReceiveTokens}
     */
    function canReceiveTokens(address identity) external view override returns (bool) {
        return s_verifiedIdentities[identity] && !paused();
    }
    
    /**
     * @dev See {IIdentityRegistry-canSendTokens}
     */
    function canSendTokens(address identity) external view override returns (bool) {
        return s_verifiedIdentities[identity] && !paused();
    }
    
    // ============ Identity Management Functions ============
    
    /**
     * @dev See {IIdentityRegistry-registerIdentity}
     */
    function registerIdentity(address identity) 
        external 
        override 
        onlyRole(REGISTRAR_ROLE) 
        whenNotPaused 
        nonReentrant 
    {
        _registerIdentity(identity);
    }
    
    /**
     * @dev See {IIdentityRegistry-revokeIdentity}
     */
    function revokeIdentity(address identity) 
        external 
        override 
        onlyRole(REGISTRAR_ROLE) 
        whenNotPaused 
        nonReentrant 
    {
        _revokeIdentity(identity);
    }
    
    /**
     * @dev See {IIdentityRegistry-batchRegisterIdentities}
     */
    function batchRegisterIdentities(address[] calldata identities) 
        external 
        override 
        onlyRole(REGISTRAR_ROLE) 
        whenNotPaused 
        nonReentrant 
    {
        uint256 length = identities.length;
        if (length == 0) revert IdentityRegistry__EmptyBatchArray();
        if (length > MAX_BATCH_SIZE) revert IdentityRegistry__BatchSizeTooLarge(length, MAX_BATCH_SIZE);
        
        for (uint256 i = 0; i < length;) {
            _registerIdentity(identities[i]);
            unchecked {
                ++i;
            }
        }
    }
    
    /**
     * @dev See {IIdentityRegistry-batchRevokeIdentities}
     */
    function batchRevokeIdentities(address[] calldata identities) 
        external 
        override 
        onlyRole(REGISTRAR_ROLE) 
        whenNotPaused 
        nonReentrant 
    {
        uint256 length = identities.length;
        if (length == 0) revert IdentityRegistry__EmptyBatchArray();
        if (length > MAX_BATCH_SIZE) revert IdentityRegistry__BatchSizeTooLarge(length, MAX_BATCH_SIZE);
        
        for (uint256 i = 0; i < length;) {
            _revokeIdentity(identities[i]);
            unchecked {
                ++i;
            }
        }
    }
    
    // ============ Internal Functions ============
    
    /**
     * @dev Internal function to register an identity
     * @param identity The address to register
     */
    function _registerIdentity(address identity) internal {
        if (identity == address(0)) revert IdentityRegistry__ZeroAddressNotAllowed();
        if (s_verifiedIdentities[identity]) revert IdentityRegistry__IdentityAlreadyRegistered(identity);
        
        s_verifiedIdentities[identity] = true;
        unchecked {
            ++s_verifiedCount;
        }
        
        emit IdentityRegistered(identity, msg.sender);
    }
    
    /**
     * @dev Internal function to revoke an identity
     * @param identity The address to revoke
     */
    function _revokeIdentity(address identity) internal {
        if (!s_verifiedIdentities[identity]) revert IdentityRegistry__IdentityNotRegistered(identity);
        
        s_verifiedIdentities[identity] = false;
        unchecked {
            --s_verifiedCount;
        }
        
        emit IdentityRevoked(identity, msg.sender);
    }
    
    // ============ Emergency Functions ============
    
    /**
     * @dev Pauses the contract, preventing new registrations and revocations
     * 
     * Requirements:
     * - Caller must have PAUSER_ROLE
     */
    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }
    
    /**
     * @dev Unpauses the contract
     * 
     * Requirements:
     * - Caller must have PAUSER_ROLE
     */
    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }
    
    // ============ Administrative Functions ============
    
    /**
     * @dev Grants registrar role to an address
     * @param account The address to grant the role to
     * 
     * Requirements:
     * - Caller must have DEFAULT_ADMIN_ROLE
     */
    function grantRegistrarRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(REGISTRAR_ROLE, account);
    }
    
    /**
     * @dev Revokes registrar role from an address
     * @param account The address to revoke the role from
     * 
     * Requirements:
     * - Caller must have DEFAULT_ADMIN_ROLE
     */
    function revokeRegistrarRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(REGISTRAR_ROLE, account);
    }
    
    /**
     * @dev Grants pauser role to an address
     * @param account The address to grant the role to
     * 
     * Requirements:
     * - Caller must have DEFAULT_ADMIN_ROLE
     */
    function grantPauserRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(PAUSER_ROLE, account);
    }
    
    /**
     * @dev Revokes pauser role from an address
     * @param account The address to revoke the role from
     * 
     * Requirements:
     * - Caller must have DEFAULT_ADMIN_ROLE
     */
    function revokePauserRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(PAUSER_ROLE, account);
    }
}
