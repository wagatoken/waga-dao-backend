// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

/**
 * @title ILionHeartTimelock
 * @dev Interface for the Lion Heart Timelock contract
 * @author Lion Heart Football Centre DAO
 */
interface ILionHeartTimelock is IAccessControl {
    
    // ============ Events ============
    
    event TimelockDeployed(
        uint256 minDelay,
        address[] proposers,
        address[] executors,
        address admin
    );
    
    // ============ View Functions ============
    
    /**
     * @dev Returns the minimum delay
     * @return The minimum delay in seconds
     */
    function getMinDelay() external view returns (uint256);
    
    /**
     * @dev Checks if an address has the proposer role
     * @param account The address to check
     * @return True if the address has proposer role
     */
    function isProposer(address account) external view returns (bool);
    
    /**
     * @dev Checks if an address has the executor role
     * @param account The address to check
     * @return True if the address has executor role
     */
    function isExecutor(address account) external view returns (bool);
    
    /**
     * @dev Checks if an address has the admin role
     * @param account The address to check
     * @return True if the address has admin role
     */
    function isAdmin(address account) external view returns (bool);
    
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
        );
    
    // ============ Timelock Functions ============
    
    /**
     * @dev Schedule an operation in the timelock
     * @param target Target contract address
     * @param value ETH value to send
     * @param data Function call data
     * @param predecessor Operation that must be executed first
     * @param salt Random value for uniqueness
     * @param delay Delay before execution
     */
    function schedule(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt,
        uint256 delay
    ) external;
    
    /**
     * @dev Execute a scheduled operation
     * @param target Target contract address
     * @param value ETH value to send
     * @param data Function call data
     * @param predecessor Operation that must be executed first
     * @param salt Random value for uniqueness
     */
    function execute(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt
    ) external;
    
    /**
     * @dev Cancel a scheduled operation
     * @param id The operation identifier
     */
    function cancel(bytes32 id) external;
}
