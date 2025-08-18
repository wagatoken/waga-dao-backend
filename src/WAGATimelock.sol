// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";

/**
 * @title WAGATimelock
 * @dev Timelock controller for WAGA DAO (Regenerative Coffee Global Impact)
 * @author WAGA DAO - Regenerative Coffee Global Impact
 * 
 * This contract implements a time-delayed execution system for governance proposals.
 * After a proposal passes through the governor, it must wait in the timelock before
 * execution to provide security and allow community review.
 * 
 * Features:
 * - Minimum delay before execution (2 days for security)
 * - Role-based access control
 * - Swiss Verein compliant governance structure
 * - Emergency cancellation capabilities
 * 
 * Roles:
 * - PROPOSER_ROLE: Can schedule operations (typically the Governor contract)
 * - EXECUTOR_ROLE: Can execute operations (typically anyone after delay)
 * - DEFAULT_ADMIN_ROLE: Can manage roles (initially deployer, then revoked)
 */
contract WAGATimelock is TimelockController {
    
    /* -------------------------------------------------------------------------- */
    /*                                  CONSTANTS                                 */
    /* -------------------------------------------------------------------------- */
    
    /// @dev Minimum delay before execution (2 days = 172,800 seconds)
    uint256 public constant MIN_DELAY = 2 days;
    
    /* -------------------------------------------------------------------------- */
    /*                                CUSTOM ERRORS                               */
    /* -------------------------------------------------------------------------- */
    
    /// @dev Error thrown when invalid delay is provided
    error WAGATimelock__InvalidDelay_constructor();
    
    /// @dev Error thrown when proposers array is empty
    error WAGATimelock__EmptyProposers_constructor();
    
    /* -------------------------------------------------------------------------- */
    /*                                   EVENTS                                   */
    /* -------------------------------------------------------------------------- */
    
    /// @dev Emitted when timelock is deployed
    event TimelockDeployed(
        uint256 minDelay,
        address[] proposers,
        address[] executors,
        address admin
    );
    
    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev Constructor that initializes the timelock controller
     * @param minDelay Minimum delay before execution (must be >= MIN_DELAY)
     * @param proposers Array of addresses that can propose operations
     * @param executors Array of addresses that can execute operations
     * @param admin Address that can manage roles (typically deployer)
     * 
     * Note: The admin should revoke their role after setup for decentralization
     */
    constructor(
        uint256 minDelay,
        address[] memory proposers,
        address[] memory executors,
        address admin
    ) TimelockController(minDelay, proposers, executors, admin) {
        
        // Validate minimum delay
        if (minDelay < MIN_DELAY) {
            revert WAGATimelock__InvalidDelay_constructor();
        }
        
        // Validate proposers array
        if (proposers.length == 0) {
            revert WAGATimelock__EmptyProposers_constructor();
        }
        
        emit TimelockDeployed(minDelay, proposers, executors, admin);
    }
    
    /* -------------------------------------------------------------------------- */
    /*                              VIEW FUNCTIONS                               */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev Returns the minimum delay
     * @return The minimum delay in seconds
     */
    function getMinDelaySeconds() external view returns (uint256) {
        return getMinDelay();
    }
    
    /**
     * @dev Checks if an address has the proposer role
     * @param account The address to check
     * @return True if the address has proposer role
     */
    function isProposer(address account) external view returns (bool) {
        return hasRole(PROPOSER_ROLE, account);
    }
    
    /**
     * @dev Checks if an address has the executor role
     * @param account The address to check
     * @return True if the address has executor role
     */
    function isExecutor(address account) external view returns (bool) {
        return hasRole(EXECUTOR_ROLE, account);
    }
    
    /**
     * @dev Checks if an address has the admin role
     * @param account The address to check
     * @return True if the address has admin role
     */
    function isAdmin(address account) external view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }
    
    /**
     * @dev Returns information about the timelock configuration
     * @return minDelay_ The minimum delay in seconds
     * @return proposerCount The number of proposers
     * @return executorCount The number of executors
     */
    function getTimelockInfo() 
        external 
        view 
        returns (
            uint256 minDelay_,
            uint256 proposerCount,
            uint256 executorCount
        ) 
    {
        // Note: We can't easily count role members without storing them separately
        // This would require additional state variables or events parsing
        return (
            getMinDelay(),
            0, // Would need additional implementation to track count
            0  // Would need additional implementation to track count
        );
    }
}
