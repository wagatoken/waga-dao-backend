// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {VERTGovernanceToken} from "../src/shared/VERTGovernanceToken.sol";
import {IdentityRegistry} from "../src/shared/IdentityRegistry.sol";
import {DonationHandler} from "../src/base/DonationHandler.sol";
import {WAGAGovernor} from "../src/shared/WAGAGovernor.sol";
import {WAGATimelock} from "../src/shared/WAGATimelock.sol";
import {WAGACoffeeInventoryTokenV2} from "../src/shared/WAGACoffeeInventoryTokenV2.sol";
import {CooperativeGrantManagerV2} from "../src/base/CooperativeGrantManagerV2.sol";
import {GreenfieldProjectManager} from "../src/managers/GreenfieldProjectManager.sol";
import {IGovernor} from "@openzeppelin/contracts/governance/IGovernor.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

/**
 * @title GovernanceWorkflowTest
 * @notice Tests DAO governance functionality for coffee-related decisions
 * @dev Tests proposal creation, voting, and execution of coffee industry operations
 */
contract GovernanceWorkflowTest is Test {
    
    // ============ STATE VARIABLES ============
    
    VERTGovernanceToken public vertToken;
    IdentityRegistry public identityRegistry;
    DonationHandler public donationHandler;
    WAGAGovernor public governor;
    WAGATimelock public timelock;
    WAGACoffeeInventoryTokenV2 public coffeeInventoryToken;
    CooperativeGrantManagerV2 public grantManager;
    GreenfieldProjectManager public greenfieldProjectManager;
    
    ERC20Mock public usdcToken;
    
    // Test addresses representing DAO stakeholders
    address public admin = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address public daoTreasury = makeAddr("daoTreasury");
    address public majorInvestor = makeAddr("majorInvestor");
    address public coffeeExpert = makeAddr("coffeeExpert");
    address public sustainabilityAdvocate = makeAddr("sustainabilityAdvocate");
    address public smallInvestor = makeAddr("smallInvestor");
    address public proposedCooperative = makeAddr("proposedCooperative");
    
    // Governance test constants
    uint256 public constant MAJOR_INVESTMENT = 350 ether; // Large enough for proposal threshold (350 ETH * $3000 = $1.05M)
    uint256 public constant MEDIUM_INVESTMENT = 10 ether;
    uint256 public constant SMALL_INVESTMENT = 1 ether;
    uint256 public constant PROPOSAL_THRESHOLD = 1_000_000e18; // 1M VERT tokens
    
    // Proposal parameters for reuse
    address[] public proposalTargets;
    uint256[] public proposalValues;
    bytes[] public proposalCalldatas;
    string public proposalDescription;
    
    // ============ SETUP ============
    
    function setUp() public {
        console.log("=== GOVERNANCE WORKFLOW TEST SETUP ===");
        
        _deployContracts();
        _setupRoles();
        _setupGovernanceParticipants();
        
        console.log("Governance test setup completed");
    }
    
    function _deployContracts() internal {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfigByChainId(block.chainid);
        
        usdcToken = new ERC20Mock();
        
        // Deploy all contracts
        identityRegistry = new IdentityRegistry(admin);
        vertToken = new VERTGovernanceToken(address(identityRegistry), admin);
        
        address[] memory proposers = new address[](1);
        address[] memory executors = new address[](1);
        proposers[0] = admin;
        executors[0] = admin;
        timelock = new WAGATimelock(2 days, proposers, executors, admin);
        
        governor = new WAGAGovernor(vertToken, timelock);
        greenfieldProjectManager = new GreenfieldProjectManager(admin);
        
        coffeeInventoryToken = new WAGACoffeeInventoryTokenV2(
            admin,
            address(greenfieldProjectManager)
        );
        
        grantManager = new CooperativeGrantManagerV2(
            address(usdcToken),
            address(greenfieldProjectManager), // Should be greenfieldProjectManager, not coffeeInventoryToken
            address(timelock), // timelock as treasury
            admin,
            address(0) // ZK Proof Manager - placeholder for now
        );
        
        donationHandler = new DonationHandler(
            address(vertToken),
            address(identityRegistry),
            address(usdcToken),
            config.ethUsdPriceFeed,
            config.ccipRouter,
            daoTreasury,
            admin
        );
    }
    
    function _setupRoles() internal {
        vm.startPrank(admin);
        
        vertToken.grantRole(vertToken.MINTER_ROLE(), address(donationHandler));
        
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(governor));
        timelock.revokeRole(timelock.PROPOSER_ROLE(), admin);
        timelock.revokeRole(timelock.EXECUTOR_ROLE(), admin);
        
        grantManager.grantRole(grantManager.FINANCIAL_ROLE(), address(timelock));
        grantManager.grantRole(grantManager.GRANT_MANAGER_ROLE(), address(timelock));
        
        // Grant necessary roles for the grantManager to work with other contracts
        greenfieldProjectManager.grantRole(greenfieldProjectManager.PROJECT_MANAGER_ROLE(), address(grantManager));
        
        // Grant necessary roles to timelock for proposal execution
        coffeeInventoryToken.grantRole(coffeeInventoryToken.DAO_ADMIN_ROLE(), address(timelock));
        coffeeInventoryToken.grantRole(coffeeInventoryToken.MINTER_ROLE(), address(timelock));
        greenfieldProjectManager.grantRole(greenfieldProjectManager.PROJECT_MANAGER_ROLE(), address(timelock));
        
        vm.stopPrank();
    }
    
    function _setupGovernanceParticipants() internal {
        // Register all participants as verified identities
        vm.startPrank(admin);
        identityRegistry.registerIdentity(majorInvestor);
        identityRegistry.registerIdentity(coffeeExpert);
        identityRegistry.registerIdentity(sustainabilityAdvocate);
        identityRegistry.registerIdentity(smallInvestor);
        identityRegistry.registerIdentity(proposedCooperative);
        vm.stopPrank();
        
        // Fund participants with ETH
        vm.deal(majorInvestor, 400 ether); // Need enough for the major investment
        vm.deal(coffeeExpert, 50 ether);
        vm.deal(sustainabilityAdvocate, 50 ether);
        vm.deal(smallInvestor, 10 ether);
        
        // Make donations to get VERT tokens
        vm.prank(majorInvestor);
        donationHandler.receiveEthDonation{value: MAJOR_INVESTMENT}();
        
        vm.prank(coffeeExpert);
        donationHandler.receiveEthDonation{value: MEDIUM_INVESTMENT}();
        
        vm.prank(sustainabilityAdvocate);
        donationHandler.receiveEthDonation{value: MEDIUM_INVESTMENT}();
        
        vm.prank(smallInvestor);
        donationHandler.receiveEthDonation{value: SMALL_INVESTMENT}();
        
        // Delegate voting power to themselves
        vm.prank(majorInvestor);
        vertToken.delegate(majorInvestor);
        
        vm.prank(coffeeExpert);
        vertToken.delegate(coffeeExpert);
        
        vm.prank(sustainabilityAdvocate);
        vertToken.delegate(sustainabilityAdvocate);
        
        vm.prank(smallInvestor);
        vertToken.delegate(smallInvestor);
        
        // Wait for voting power to become active
        vm.roll(block.number + 1);
        
        console.log("Participants setup with voting power:");
        console.log("  - Major investor:", vertToken.getVotes(majorInvestor) / 1e18, "VERT");
        console.log("  - Coffee expert:", vertToken.getVotes(coffeeExpert) / 1e18, "VERT");
        console.log("  - Sustainability advocate:", vertToken.getVotes(sustainabilityAdvocate) / 1e18, "VERT");
        console.log("  - Small investor:", vertToken.getVotes(smallInvestor) / 1e18, "VERT");
    }
    
    // ============ GOVERNANCE TESTS ============
    
    function testProposalThresholdRequirement() public view {
        // Test that major investor has enough tokens to propose
        uint256 majorInvestorVotes = vertToken.getVotes(majorInvestor);
        assertGe(majorInvestorVotes, PROPOSAL_THRESHOLD, "Major investor should meet proposal threshold");
        
        // Test that smaller investors cannot propose
        uint256 smallInvestorVotes = vertToken.getVotes(smallInvestor);
        assertLt(smallInvestorVotes, PROPOSAL_THRESHOLD, "Small investor should not meet proposal threshold");
        
        console.log("Proposal threshold requirements verified");
    }
    
    function testCreateNewGreenfieldGrantProposal() public {
        console.log("\\n=== TESTING GREENFIELD GRANT PROPOSAL ===");
        
        // Prepare grant parameters
        uint256 grantAmount = 75_000e6; // $75,000 USDC
        uint256 revenueShare = 2500; // 25%
        uint256 duration = 5; // 5 years
        
        // Create proposal to fund a new greenfield grant
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        
        targets[0] = address(grantManager);
        values[0] = 0;
        calldatas[0] = abi.encodeWithSignature(
            "createGreenfieldGrant(address,uint256,uint256,uint256,string,uint256,uint256,uint256,string)",
            proposedCooperative,
            grantAmount,
            revenueShare,
            duration,
            "QmProposedGrant_CostaRica",
            block.timestamp + 90 days,
            block.timestamp + 4 * 365 days,
            20000,
            "Tarrazu Mountains Coffee Cooperative - Costa Rica"
        );
        
        string memory description = "Proposal: Fund Costa Rica Tarrazu Mountains Coffee Cooperative with $75,000 greenfield grant for sustainable coffee production. Expected annual yield: 20,000kg. Revenue share: 25% to DAO.";
        
        // Create proposal (only major investor has enough voting power)
        vm.prank(majorInvestor);
        uint256 proposalId = governor.propose(targets, values, calldatas, description);
        
        console.log("  - Proposal ID:", proposalId);
        console.log("  - Proposal state:", uint256(governor.state(proposalId))); // Should be Pending (0)
        
        // Wait for voting delay to pass
        vm.roll(block.number + governor.votingDelay() + 1);
        
        // Verify proposal is now active
        assertEq(uint256(governor.state(proposalId)), uint256(IGovernor.ProposalState.Active), "Proposal should be active");
        
        console.log("Greenfield grant proposal created successfully");
    }
    
    function testVotingProcess() public {
        console.log("\\n=== TESTING VOTING PROCESS ===");
        
        // Create a proposal first
        uint256 proposalId = _createSampleProposal();
        
        // Wait for voting delay
        vm.roll(block.number + governor.votingDelay() + 1);
        
        // Vote on the proposal
        vm.prank(majorInvestor);
        governor.castVote(proposalId, 1); // Vote FOR
        
        vm.prank(coffeeExpert);
        governor.castVote(proposalId, 1); // Vote FOR
        
        vm.prank(sustainabilityAdvocate);
        governor.castVote(proposalId, 1); // Vote FOR
        
        vm.prank(smallInvestor);
        governor.castVote(proposalId, 0); // Vote AGAINST
        
        // Check vote counts
        (uint256 againstVotes, uint256 forVotes, uint256 abstainVotes) = governor.proposalVotes(proposalId);
        
        console.log("  - Votes FOR:", forVotes / 1e18);
        console.log("  - Votes AGAINST:", againstVotes / 1e18);
        console.log("  - Abstain votes:", abstainVotes / 1e18);
        
        assertGt(forVotes, againstVotes, "FOR votes should exceed AGAINST votes");
        
        console.log("Voting process completed successfully");
    }
    
    function testProposalExecution() public {
        console.log("\\n=== TESTING PROPOSAL EXECUTION ===");
        
        // Fund the grant manager with USDC first
        usdcToken.mint(address(grantManager), 1_000_000e6);
        
        // Create and pass a proposal
        uint256 proposalId = _createAndPassProposal();
        
        // Define the proposal parameters (same as in _createAndPassProposal)
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        
        targets[0] = address(grantManager);
        values[0] = 0;
        calldatas[0] = abi.encodeWithSignature(
            "createGreenfieldGrant(address,uint256,uint256,uint256,string,uint256,uint256,uint256,string)",
            proposedCooperative,
            25_000e6, // Small grant for testing
            2000, // 20% revenue share
            3, // 3 years
            "QmTestGrant",
            block.timestamp + 60 days,
            block.timestamp + 3 * 365 days,
            10000, // Must match _createAndPassProposal
            "Test Cooperative" // Must match _createAndPassProposal
        );
        
        string memory description = "Create test grant for proposal execution"; // Must match _createAndPassProposal
        
        // Wait for voting period to end
        vm.roll(block.number + governor.votingPeriod() + 1);
        
        // Verify proposal succeeded
        assertEq(uint256(governor.state(proposalId)), uint256(IGovernor.ProposalState.Succeeded), "Proposal should have succeeded");
        
        // Queue the proposal in timelock
        vm.prank(majorInvestor);
        governor.queue(targets, values, calldatas, keccak256(bytes(description)));
        
        // Wait for timelock delay
        vm.warp(block.timestamp + timelock.getMinDelaySeconds() + 1);
        
        // Execute the proposal
        vm.prank(majorInvestor);
        governor.execute(targets, values, calldatas, keccak256(bytes(description)));
        
        // Verify proposal was executed
        assertEq(uint256(governor.state(proposalId)), uint256(IGovernor.ProposalState.Executed), "Proposal should be executed");
        
        // Verify the grant was actually created
        uint256 nextGrantId = grantManager.nextGrantId();
        assertGt(nextGrantId, 1, "Grant should have been created");
        
        console.log("  - Proposal executed successfully");
        console.log("  - Next grant ID:", nextGrantId);
        console.log("Full governance workflow completed");
    }
    
    function testGovernanceParameterUpdate() public {
        console.log("\\n=== TESTING GOVERNANCE PARAMETER UPDATE ===");
        
        // Create proposal to update commodity price (admin function via governance)
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        
        targets[0] = address(grantManager);
        values[0] = 0;
        calldatas[0] = abi.encodeWithSignature("updateCommodityPrice(uint256)", 5_000_000); // $5.00 per kg
        
        string memory description = "Update commodity price to $5.00 per kg for fair pricing calculations";
        
        vm.prank(majorInvestor);
        uint256 proposalId = governor.propose(targets, values, calldatas, description);
        
        // Fast-track the proposal
        vm.roll(block.number + governor.votingDelay() + 1);
        
        // Vote FOR the proposal
        vm.prank(majorInvestor);
        governor.castVote(proposalId, 1);
        
        vm.prank(coffeeExpert);
        governor.castVote(proposalId, 1);
        
        // Complete voting period
        vm.roll(block.number + governor.votingPeriod() + 1);
        
        // Queue and execute
        vm.prank(majorInvestor);
        governor.queue(targets, values, calldatas, keccak256(bytes(description)));
        
        vm.warp(block.timestamp + timelock.getMinDelaySeconds() + 1);
        
        vm.prank(majorInvestor);
        governor.execute(targets, values, calldatas, keccak256(bytes(description)));
        
        // Verify parameter was updated
        uint256 newPrice = grantManager.getCurrentCommodityPrice();
        assertEq(newPrice, 5_000_000, "Commodity price should be updated");
        
        console.log("  - New commodity price:", newPrice / 1e6, "USD per kg");
        console.log("Governance parameter update successful");
    }
    
    function test_Revert_WhenProposalDefeated() public {
        console.log("\\n=== TESTING FAILED PROPOSAL ===");
        
        uint256 proposalId = _createSampleProposal();
        
        // Wait for voting delay
        vm.roll(block.number + governor.votingDelay() + 1);
        
        // Vote AGAINST the proposal with majority
        vm.prank(majorInvestor);
        governor.castVote(proposalId, 0); // Vote AGAINST
        
        vm.prank(coffeeExpert);
        governor.castVote(proposalId, 0); // Vote AGAINST
        
        vm.prank(sustainabilityAdvocate);
        governor.castVote(proposalId, 1); // Vote FOR (minority)
        
        // Complete voting period
        vm.roll(block.number + governor.votingPeriod() + 1);
        
        // Verify proposal failed
        assertEq(uint256(governor.state(proposalId)), uint256(IGovernor.ProposalState.Defeated), "Proposal should be defeated");
        
        console.log("  - Proposal correctly failed due to majority AGAINST votes");
        console.log("Failed proposal handling verified");
    }
    
    // ============ HELPER FUNCTIONS ============
    
    function _createSampleProposal() internal returns (uint256) {
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        
        targets[0] = address(grantManager);
        values[0] = 0;
        calldatas[0] = abi.encodeWithSignature("updateCommodityPrice(uint256)", 6_000_000);
        
        string memory description = "Sample proposal to update commodity price";
        
        vm.prank(majorInvestor);
        return governor.propose(targets, values, calldatas, description);
    }
    
    function _createAndPassProposal() internal returns (uint256) {
        // Create proposal for a small grant
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        
        targets[0] = address(grantManager);
        values[0] = 0;
        calldatas[0] = abi.encodeWithSignature(
            "createGreenfieldGrant(address,uint256,uint256,uint256,string,uint256,uint256,uint256,string)",
            proposedCooperative,
            25_000e6, // Small grant for testing
            2000, // 20% revenue share
            3, // 3 years
            "QmTestGrant",
            block.timestamp + 60 days,
            block.timestamp + 3 * 365 days,
            10000,
            "Test Cooperative"
        );
        
        string memory description = "Create test grant for proposal execution";
        
        vm.prank(majorInvestor);
        uint256 proposalId = governor.propose(targets, values, calldatas, description);
        
        // Wait for voting delay
        vm.roll(block.number + governor.votingDelay() + 1);
        
        // Vote FOR with majority
        vm.prank(majorInvestor);
        governor.castVote(proposalId, 1);
        
        vm.prank(coffeeExpert);
        governor.castVote(proposalId, 1);
        
        vm.prank(sustainabilityAdvocate);
        governor.castVote(proposalId, 1);
        
        return proposalId;
    }
}
