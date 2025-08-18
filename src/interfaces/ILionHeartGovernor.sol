// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IGovernor} from "@openzeppelin/contracts/governance/IGovernor.sol";

/**
 * @title ILionHeartGovernor
 * @dev Interface for the Lion Heart Governor contract
 * @author Lion Heart Football Centre DAO
 */
interface ILionHeartGovernor is IGovernor {
    
    // ============ Events ============
    
    event ProposalCreated(
        uint256 indexed proposalId,
        address indexed proposer,
        string description
    );
    
    event VoteCast(
        uint256 indexed proposalId,
        address indexed voter,
        uint8 support,
        uint256 weight,
        string reason
    );
    
    // ============ Governance Parameters ============
    
    /**
     * @dev Returns the governance token address
     * @return The address of the LHGT governance token
     */
    function getGovernanceToken() external view returns (address);
    
    /**
     * @dev Returns the timelock controller address
     * @return The address of the timelock controller
     */
    function getTimelock() external view returns (address);
    
    /**
     * @dev Returns the current governance parameters
     * @return votingDelay_ The current voting delay in blocks
     * @return votingPeriod_ The current voting period in blocks
     * @return proposalThreshold_ The current proposal threshold
     * @return quorum_ The current quorum at the latest block
     */
    function getGovernanceParameters() 
        external 
        view 
        returns (
            uint256 votingDelay_,
            uint256 votingPeriod_,
            uint256 proposalThreshold_,
            uint256 quorum_
        );
    
    // ============ Voting Functions ============
    
    /**
     * @dev Cast a vote on a proposal with reason
     * @param proposalId The ID of the proposal to vote on
     * @param support The vote direction (0=Against, 1=For, 2=Abstain)
     * @param reason The reason for the vote
     * @return weight The voting weight of the voter
     */
    function castVoteWithReason(
        uint256 proposalId,
        uint8 support,
        string calldata reason
    ) external returns (uint256 weight);
}
