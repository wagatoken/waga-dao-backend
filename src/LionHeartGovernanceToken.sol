// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Votes} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {Nonces} from "@openzeppelin/contracts/utils/Nonces.sol";
import {IIdentityRegistry} from "./interfaces/IIdentityRegistry.sol";

/**
 * @title LionHeartGovernanceToken
 * @dev ERC-20 governance token with ERC-3643 compliance for permissioned transfers
 * @author Lion Heart Football Centre DAO
 * 
 * This contract implements a governance token for the Lion Heart Football Centre DAO
 * with the following key features:
 * - ERC-20 standard with voting capabilities (ERC20Votes)
 * - ERC-3643 compliant permissioned transfers (only whitelisted addresses)
 * - Controlled minting (only authorized minters)
 * - Burning functionality for token holders
 * - Pausable for emergency situations
 * - Swiss Verein compliant governance structure
 */
contract LionHeartGovernanceToken is ERC20, ERC20Votes, ERC20Permit, Ownable, AccessControl, Pausable {
    
    /* -------------------------------------------------------------------------- */
    /*                                  CONSTANTS                                 */
    /* -------------------------------------------------------------------------- */
    
    /// @dev Role identifier for addresses authorized to mint tokens
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    /// @dev Role identifier for addresses authorized to manage the identity registry
    bytes32 public constant REGISTRY_MANAGER_ROLE = keccak256("REGISTRY_MANAGER_ROLE");
    
    /// @dev Token name (immutable)
    string private constant TOKEN_NAME = "Lion Heart Governance Token";
    
    /// @dev Token symbol (immutable)
    string private constant TOKEN_SYMBOL = "LHGT";
    
    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */
    
    /// @dev Identity registry contract for ERC-3643 compliance
    IIdentityRegistry public s_identityRegistry;
    
    /* -------------------------------------------------------------------------- */
    /*                                CUSTOM ERRORS                               */
    /* -------------------------------------------------------------------------- */
    
    /// @dev Error thrown when an address is not verified in the identity registry
    error LionHeartGovernanceToken__AddressNotVerified_mint(address account);
    
    /// @dev Error thrown when trying to set zero address for identity registry
    error LionHeartGovernanceToken__ZeroAddressNotAllowed_setIdentityRegistry();
    
    /// @dev Error thrown when unauthorized minting is attempted
    error LionHeartGovernanceToken__UnauthorizedMinting_mint(address account);
    
    /// @dev Error thrown when trying to transfer to/from unverified addresses
    error LionHeartGovernanceToken__TransferNotAllowed_update(address from, address to);
    
    /// @dev Error thrown when zero address provided in constructor
    error LionHeartGovernanceToken__ZeroAddressNotAllowed_constructor();
    
    /* -------------------------------------------------------------------------- */
    /*                                   EVENTS                                   */
    /* -------------------------------------------------------------------------- */
    
    /// @dev Emitted when the identity registry is updated
    event IdentityRegistryUpdated(address indexed oldRegistry, address indexed newRegistry);
    
    /// @dev Emitted when tokens are minted to a verified address
    event TokensMinted(address indexed to, uint256 amount, address indexed minter);
    
    /// @dev Emitted when tokens are burned
    event TokensBurned(address indexed from, uint256 amount);
    
    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev Constructor that initializes the token with governance capabilities
     * @param _identityRegistry Address of the identity registry contract
     * @param _initialOwner Address that will be the initial owner and admin
     */
    constructor(
        address _identityRegistry,
        address _initialOwner
    ) 
        ERC20(TOKEN_NAME, TOKEN_SYMBOL) 
        ERC20Permit(TOKEN_NAME)
        Ownable(_initialOwner)
    {
        if (_identityRegistry == address(0)) {
            revert LionHeartGovernanceToken__ZeroAddressNotAllowed_constructor();
        }
        if (_initialOwner == address(0)) {
            revert LionHeartGovernanceToken__ZeroAddressNotAllowed_constructor();
        }
        
        s_identityRegistry = IIdentityRegistry(_identityRegistry);
        
        // Set up access control roles
        _grantRole(DEFAULT_ADMIN_ROLE, _initialOwner);
        _grantRole(MINTER_ROLE, _initialOwner);
        _grantRole(REGISTRY_MANAGER_ROLE, _initialOwner);
        
        // Auto-delegate voting power to the initial owner
        _delegate(_initialOwner, _initialOwner);
        
        emit IdentityRegistryUpdated(address(0), _identityRegistry);
    }
    
    /* -------------------------------------------------------------------------- */
    /*                             MINTING FUNCTIONS                             */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev Mints tokens to a verified address
     * @param to The address to mint tokens to (must be verified in identity registry)
     * @param amount The amount of tokens to mint
     * 
     * Requirements:
     * - Caller must have MINTER_ROLE
     * - Recipient address must be verified in identity registry
     * - Contract must not be paused
     */
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) whenNotPaused {
        if (!s_identityRegistry.isVerified(to)) {
            revert LionHeartGovernanceToken__AddressNotVerified_mint(to);
        }
        
        _mint(to, amount);
        emit TokensMinted(to, amount, msg.sender);
    }
    
    /* -------------------------------------------------------------------------- */
    /*                             BURNING FUNCTIONS                             */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev Burns tokens from the caller's balance
     * @param amount The amount of tokens to burn
     */
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }
    
    /**
     * @dev Burns tokens from a specific address (requires allowance)
     * @param from The address to burn tokens from
     * @param amount The amount of tokens to burn
     */
    function burnFrom(address from, uint256 amount) external {
        _spendAllowance(from, msg.sender, amount);
        _burn(from, amount);
        emit TokensBurned(from, amount);
    }
    
    /* -------------------------------------------------------------------------- */
    /*                      IDENTITY REGISTRY MANAGEMENT                         */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev Updates the identity registry contract
     * @param _newRegistry Address of the new identity registry
     * 
     * Requirements:
     * - Caller must have REGISTRY_MANAGER_ROLE
     * - New registry address cannot be zero
     */
    function setIdentityRegistry(address _newRegistry) external onlyRole(REGISTRY_MANAGER_ROLE) {
        if (_newRegistry == address(0)) {
            revert LionHeartGovernanceToken__ZeroAddressNotAllowed_setIdentityRegistry();
        }
        
        address oldRegistry = address(s_identityRegistry);
        s_identityRegistry = IIdentityRegistry(_newRegistry);
        
        emit IdentityRegistryUpdated(oldRegistry, _newRegistry);
    }
    
    /* -------------------------------------------------------------------------- */
    /*                            PAUSABLE FUNCTIONS                             */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev Pauses all token transfers
     * 
     * Requirements:
     * - Caller must be the owner
     */
    function pause() external onlyOwner {
        _pause();
    }
    
    /**
     * @dev Unpauses all token transfers
     * 
     * Requirements:
     * - Caller must be the owner
     */
    function unpause() external onlyOwner {
        _unpause();
    }
    
    /* -------------------------------------------------------------------------- */
    /*                   TRANSFER HOOKS (ERC-3643 COMPLIANCE)                    */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev Hook called before any token transfer to enforce ERC-3643 compliance
     * @param from Address tokens are being transferred from
     * @param to Address tokens are being transferred to
     * @param amount Amount of tokens being transferred
     * 
     * Requirements:
     * - Both from and to addresses must be verified in identity registry (except for minting/burning)
     * - Contract must not be paused
     */
    function _update(address from, address to, uint256 amount) 
        internal 
        override(ERC20, ERC20Votes) 
        whenNotPaused
    {
        // Allow minting (from == address(0)) and burning (to == address(0))
        if (from != address(0) && !s_identityRegistry.isVerified(from)) {
            revert LionHeartGovernanceToken__TransferNotAllowed_update(from, to);
        }
        
        if (to != address(0) && !s_identityRegistry.isVerified(to)) {
            revert LionHeartGovernanceToken__TransferNotAllowed_update(from, to);
        }
        
        super._update(from, to, amount);
    }
    
    /* -------------------------------------------------------------------------- */
    /*                              VIEW FUNCTIONS                               */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev Returns the number of decimals used to get its user representation
     * @return The number of decimals (18)
     */
    function decimals() public pure override returns (uint8) {
        return 18;
    }
    
    /**
     * @dev Checks if an address is verified in the identity registry
     * @param account The address to check
     * @return True if the address is verified, false otherwise
     */
    function isVerified(address account) external view returns (bool) {
        return s_identityRegistry.isVerified(account);
    }
    
    /**
     * @dev Returns the current nonce for an account (used for meta-transactions)
     * @param owner The account to get the nonce for
     * @return The current nonce
     */
    function nonces(address owner) public view override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }
    
    /* -------------------------------------------------------------------------- */
    /*                          ACCESS CONTROL OVERRIDE                          */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev Override supportsInterface to include AccessControl
     * @param interfaceId The interface identifier to check
     * @return True if the interface is supported
     */
    function supportsInterface(bytes4 interfaceId) 
        public 
        view 
        override(AccessControl) 
        returns (bool) 
    {
        return super.supportsInterface(interfaceId);
    }
}
