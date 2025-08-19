// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Governor} from "@openzeppelin/contracts/governance/Governor.sol";
import {GovernorSettings} from "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import {GovernorCountingSimple} from "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import {GovernorVotes} from "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import {GovernorVotesQuorumFraction} from "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import {GovernorTimelockControl} from "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";
import {IVotes} from "@openzeppelin/contracts/interfaces/IERC5805.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title WAGAGovernor
 * @notice Governance contract for WAGA DAO with VERT token-based voting
 * @dev Implements OpenZeppelin Governor pattern with timelock control for regenerative coffee projects
 */
contract WAGAGovernor is
    Governor,
    GovernorSettings,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorVotesQuorumFraction,
    GovernorTimelockControl,
    AccessControl
{
    /// Constants ///
    uint48 private constant VOTING_DELAY = 7_200; // 1 day in blocks (12 second blocks)
    uint32 private constant VOTING_PERIOD = 50_400; // 7 days in blocks
    uint256 private constant PROPOSAL_THRESHOLD = 1_000_000e18; // 1M tokens to propose
    
    /* -------------------------------------------------------------------------- */
    /*                                  CONSTANTS                                 */
    /* -------------------------------------------------------------------------- */
    
    bytes32 public constant PROPOSAL_CANCELLER_ROLE = keccak256("PROPOSAL_CANCELLER_ROLE");

    /// @dev Proposal threshold: 0.5% of total token supply
    uint256 public constant PROPOSAL_THRESHOLD_PERCENTAGE = 50; // 50 basis points = 0.5%
    
    /// @dev Quorum threshold: 4% of total token supply
    uint256 public constant QUORUM_PERCENTAGE = 4;
    
    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */
    
    /// @dev The VERT governance token contract
    IVotes private immutable i_governanceToken;
    
    /// @dev The timelock controller for delayed execution
    TimelockController private immutable i_timelock;
    
    /* -------------------------------------------------------------------------- */
    /*                                CUSTOM ERRORS                               */
    /* -------------------------------------------------------------------------- */
    
    /// @dev Error thrown when governance token address is zero
    error WAGAGovernor__ZeroTokenAddress_constructor();
    
    /// @dev Error thrown when timelock address is zero
    error WAGAGovernor__ZeroTimelockAddress_constructor();
    
    /* -------------------------------------------------------------------------- */
    /*                                   EVENTS                                   */
    /* -------------------------------------------------------------------------- */
    
    /// @dev Emitted when a proposal is created
    event ProposalCreated(
        uint256 indexed proposalId,
        address indexed proposer,
        string description
    );
    
    /// @dev Emitted when a vote is cast
    event VoteCast(
        uint256 indexed proposalId,
        address indexed voter,
        uint8 support,
        uint256 weight,
        string reason
    );
    
    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev Constructor that initializes the governor with token and timelock
     * @param _governanceToken Address of the VERT governance token
     * @param _timelock Address of the timelock controller
     */
    constructor(
        IVotes _governanceToken,
        TimelockController _timelock
    )
        Governor("WAGAGovernor")
        GovernorSettings(
            VOTING_DELAY,    // Voting delay in blocks
            VOTING_PERIOD,   // Voting period in blocks
            0                // Proposal threshold (calculated dynamically)
        )
        GovernorVotes(_governanceToken)
        GovernorVotesQuorumFraction(QUORUM_PERCENTAGE)
        GovernorTimelockControl(_timelock)
    {
        if (address(_governanceToken) == address(0)) {
            revert WAGAGovernor__ZeroTokenAddress_constructor();
        }
        if (address(_timelock) == address(0)) {
            revert WAGAGovernor__ZeroTimelockAddress_constructor();
        }
        
        i_governanceToken = _governanceToken;
        i_timelock = _timelock;
        
        // Grant DEFAULT_ADMIN_ROLE to deployer for initial setup
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    
    /* -------------------------------------------------------------------------- */
    /*                          GOVERNANCE PARAMETERS                            */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev Returns the voting delay
     * @return The voting delay in blocks  
     */
    function votingDelay()
        public
        view
        override(Governor, GovernorSettings) 
        returns (uint256)
    {
        return super.votingDelay();
    }

    /**
     * @dev Returns the voting period
     * @return The voting period in blocks
     */
    function votingPeriod()
        public
        view
        override(Governor, GovernorSettings) 
        returns (uint256)
    {
        return super.votingPeriod();
    }

    /**
     * @dev Returns the quorum for a given block number
     * @param blockNumber The block number to check quorum for
     * @return The quorum amount in tokens
     */
    function quorum(uint256 blockNumber)
        public
        view
        override(Governor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }
    
    /**
     * @dev Returns the number of votes required in order for a voter to become a proposer
     * @return The proposal threshold in tokens
     */
    function proposalThreshold()
        public
        pure
        override(Governor, GovernorSettings)
        returns (uint256)
    {
        return PROPOSAL_THRESHOLD;
    }    
    
    /* -------------------------------------------------------------------------- */
    /*                            PROPOSAL MANAGEMENT                            */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev Returns the state of a proposal
     * @param proposalId The ID of the proposal
     * @return The current state of the proposal
     */
    function state(uint256 proposalId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }
    
    /**
     * @dev Creates a new proposal
     * @param targets Array of target contract addresses
     * @param values Array of ETH values to send
     * @param calldatas Array of function call data
     * @param description Human-readable description of the proposal
     * @return proposalId The ID of the created proposal
     */
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) 
        public 
        override(Governor) 
        returns (uint256 proposalId) 
    {
        proposalId = super.propose(targets, values, calldatas, description);
        
        emit ProposalCreated(proposalId, msg.sender, description);
        
        return proposalId;
    }
    
    /* -------------------------------------------------------------------------- */
    /*                              VOTING FUNCTIONS                             */
    /* -------------------------------------------------------------------------- */
    
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
    ) 
        public 
        override 
        returns (uint256 weight) 
    {
        weight = super.castVoteWithReason(proposalId, support, reason);
        
        emit VoteCast(proposalId, msg.sender, support, weight, reason);
        
        return weight;
    }
    
    /* -------------------------------------------------------------------------- */
    /*                         EXECUTION & TIMELOCK                              */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev Internal function to cancel a proposal
     * @param targets Array of target contract addresses
     * @param values Array of ETH values to send
     * @param calldatas Array of function call data
     * @param descriptionHash Hash of the proposal description
     * @return proposalId The ID of the cancelled proposal
     */
    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) 
        internal 
        override(Governor, GovernorTimelockControl) 
        returns (uint256 proposalId) 
    {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }
    
    /**
     * @dev Returns the executor (timelock controller)
     * @return The address of the executor
     */
    function _executor() 
        internal 
        view 
        override(Governor, GovernorTimelockControl) 
        returns (address) 
    {
        return super._executor();
    }
    
    /* -------------------------------------------------------------------------- */
    /*                              VIEW FUNCTIONS                               */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev Returns the governance token address
     * @return The address of the VERT governance token
     */
    function getGovernanceToken() external view returns (address) {
        return address(i_governanceToken);
    }
    
    /**
     * @dev Returns the timelock controller address
     * @return The address of the timelock controller
     */
    function getTimelock() external view returns (address) {
        return address(i_timelock);
    }
    
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
        ) 
    {
        return (
            votingDelay(),
            votingPeriod(),
            proposalThreshold(),
            quorum(block.number - 1)
        );
    }
    
    /* -------------------------------------------------------------------------- */
    /*                          REQUIRED OVERRIDES                               */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev Queue operations before execution when timelock is required
     */
    function _queueOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) returns (uint48) {
        return super._queueOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    /**
     * @dev Execute queued operations
     */
    function _executeOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) {
        super._executeOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    /**
     * @dev Check if proposal needs to be queued in timelock
     */
    function proposalNeedsQueuing(uint256 proposalId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (bool)
    {
        return super.proposalNeedsQueuing(proposalId);
    }
    
    /* -------------------------------------------------------------------------- */
    /*                          INTERFACE SUPPORT                                */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev Returns whether the contract supports a given interface
     * @param interfaceId The interface identifier
     * @return True if the interface is supported
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(Governor, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
