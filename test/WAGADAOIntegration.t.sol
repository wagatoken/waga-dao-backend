// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// import {Test, console} from "forge-std/Test.sol";
// import {LionHeartGovernanceToken} from "../src/LionHeartGovernanceToken.sol";
// import {IdentityRegistry} from "../src/IdentityRegistry.sol";
// import {DonationHandler} from "../src/DonationHandler.sol";
// import {LionHeartGovernor} from "../src/LionHeartGovernor.sol";
// import {LionHeartTimelock} from "../src/LionHeartTimelock.sol";
// import {DeployLionHeartDAO} from "../script/DeployLionHeartDAO.s.sol";
// import {HelperConfig} from "../script/HelperConfig.s.sol";
// import {RegisterIdentity, MakeDonationETH, CreateProposal} from "../script/Interactions.s.sol";
// import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

// /**
//  * @title LionHeartDAOIntegrationTest
//  * @notice Integration tests for the Lion Heart DAO system
//  * @dev Tests complex workflows and interaction between contracts
//  */
// contract LionHeartDAOIntegrationTest is Test {
//     /* -------------------------------------------------------------------------- */
//     /*                               STATE VARIABLES                              */
//     /* -------------------------------------------------------------------------- */
    
//     LionHeartGovernanceToken public lhgtToken;
//     IdentityRegistry public identityRegistry;
//     DonationHandler public donationHandler;
//     LionHeartGovernor public governor;
//     LionHeartTimelock public timelock;
//     HelperConfig public helperConfig;
    
//     DeployLionHeartDAO public deployer;
//     RegisterIdentity public registerIdentity;
//     MakeDonationETH public makeDonationETH;
//     CreateProposal public createProposal;
    
//     address public usdcToken;
//     address public paxgToken;
    
//     // Test users
//     address public alice = makeAddr("alice");
//     address public bob = makeAddr("bob");
//     address public charlie = makeAddr("charlie");
//     address public dao = makeAddr("dao");
    
//     // Constants
//     uint256 public constant LARGE_DONATION = 50 ether;
//     uint256 public constant MEDIUM_DONATION = 10 ether;
//     uint256 public constant SMALL_DONATION = 1 ether;

//     /* -------------------------------------------------------------------------- */
//     /*                                   SETUP                                    */
//     /* -------------------------------------------------------------------------- */
    
//     function setUp() public {
//         // Deploy the complete DAO system
//         deployer = new DeployLionHeartDAO();
//         (
//             lhgtToken,
//             identityRegistry,
//             donationHandler,
//             governor,
//             timelock,
//             helperConfig
//         ) = deployer.run();
        
//         // Deploy interaction scripts
//         registerIdentity = new RegisterIdentity();
//         makeDonationETH = new MakeDonationETH();
//         createProposal = new CreateProposal();
        
//         // Get network configuration
//         (usdcToken, paxgToken,) = helperConfig.activeNetworkConfig();
        
//         // Setup test users
//         _setupTestUsers();
//     }

//     /* -------------------------------------------------------------------------- */
//     /*                          COMPLEX WORKFLOW TESTS                           */
//     /* -------------------------------------------------------------------------- */
    
//     function testFullGovernanceWorkflow() public {
//         console.log("=== TESTING FULL GOVERNANCE WORKFLOW ===");
        
//         // Step 1: Large donations from multiple users
//         _makeLargeDonations();
        
//         // Step 2: Create a governance proposal
//         uint256 proposalId = _createTestProposal();
        
//         // Step 3: Vote on the proposal
//         _voteOnProposal(proposalId);
        
//         // Step 4: Execute the proposal
//         _executeProposal(proposalId);
        
//         console.log("Full governance workflow completed successfully!");
//     }
    
//     function testMultiCurrencyDonationScenario() public {
//         console.log("=== TESTING MULTI-CURRENCY DONATIONS ===");
        
//         // Alice donates ETH
//         vm.prank(alice);
//         donationHandler.receiveEthDonation{value: 5 ether}();
        
//         // Bob donates USDC
//         vm.startPrank(bob);
//         ERC20Mock(usdcToken).approve(address(donationHandler), 10000e6);
//         donationHandler.receiveUsdcDonation(10000e6);
//         vm.stopPrank();
        
//         // Charlie donates PAXG
//         vm.startPrank(charlie);
//         ERC20Mock(paxgToken).approve(address(donationHandler), 50e18);
//         donationHandler.receivePaxgDonation(50e18);
//         vm.stopPrank();
        
//         // Admin records fiat donation for Alice
//         donationHandler.receiveFiatDonation(alice, 2000e18); // $2000
        
//         // Check all balances
//         _logDonationSummary();
        
//         console.log("Multi-currency donation test completed!");
//     }
    
//     function testDAOTreasuryManagement() public {
//         console.log("=== TESTING DAO TREASURY MANAGEMENT ===");
        
//         // Setup: Make donations to build treasury
//         _buildTreasury();
        
//         // Create proposal to transfer funds
//         address recipient = makeAddr("recipient");
//         uint256 transferAmount = 5 ether;
        
//         address[] memory targets = new address[](1);
//         uint256[] memory values = new uint256[](1);
//         bytes[] memory calldatas = new bytes[](1);
        
//         targets[0] = recipient;
//         values[0] = transferAmount;
//         calldatas[0] = "";
        
//         // Alice creates proposal (she has enough tokens)
//         vm.prank(alice);
//         uint256 proposalId = governor.propose(
//             targets,
//             values,
//             calldatas,
//             "Transfer 5 ETH from treasury to development fund"
//         );
        
//         // Wait for voting delay
//         vm.warp(block.timestamp + 7201);
        
//         // Multiple users vote
//         vm.prank(alice);
//         governor.castVote(proposalId, 1); // For
        
//         vm.prank(bob);
//         governor.castVote(proposalId, 1); // For
        
//         // Wait for voting period to end
//         vm.warp(block.timestamp + 50401);
        
//         // Queue the proposal
//         governor.queue(targets, values, calldatas, keccak256(bytes("Transfer 5 ETH from treasury to development fund")));
        
//         // Wait for timelock delay
//         vm.warp(block.timestamp + 2 days + 1);
        
//         // Execute the proposal
//         uint256 initialRecipientBalance = recipient.balance;
//         governor.execute(targets, values, calldatas, keccak256(bytes("Transfer 5 ETH from treasury to development fund")));
        
//         // Verify transfer happened
//         assertEq(recipient.balance, initialRecipientBalance + transferAmount);
        
//         console.log("Treasury management test completed!");
//     }
    
//     function testVotingPowerDistribution() public {
//         console.log("=== TESTING VOTING POWER DISTRIBUTION ===");
        
//         // Different donation amounts create different voting power
//         vm.prank(alice);
//         donationHandler.receiveEthDonation{value: 10 ether}(); // 10,000 LHGT
        
//         vm.prank(bob);
//         donationHandler.receiveEthDonation{value: 5 ether}(); // 5,000 LHGT
        
//         vm.prank(charlie);
//         donationHandler.receiveEthDonation{value: 1 ether}(); // 1,000 LHGT
        
//         // Delegate votes to themselves
//         vm.prank(alice);
//         lhgtToken.delegate(alice);
        
//         vm.prank(bob);
//         lhgtToken.delegate(bob);
        
//         vm.prank(charlie);
//         lhgtToken.delegate(charlie);
        
//         // Check voting power
//         console.log("Alice voting power:", lhgtToken.getVotes(alice));
//         console.log("Bob voting power:", lhgtToken.getVotes(bob));
//         console.log("Charlie voting power:", lhgtToken.getVotes(charlie));
        
//         // Test delegation
//         vm.prank(charlie);
//         lhgtToken.delegate(alice); // Charlie delegates to Alice
        
//         console.log("After delegation - Alice voting power:", lhgtToken.getVotes(alice));
//         console.log("After delegation - Charlie voting power:", lhgtToken.getVotes(charlie));
        
//         console.log("Voting power distribution test completed!");
//     }
    
//     function testEmergencyScenarios() public {
//         console.log("=== TESTING EMERGENCY SCENARIOS ===");
        
//         // Setup large donation to get proposal power
//         vm.prank(alice);
//         donationHandler.receiveEthDonation{value: 100 ether}();
        
//         vm.prank(alice);
//         lhgtToken.delegate(alice);
        
//         // Create a malicious proposal
//         address[] memory targets = new address[](1);
//         uint256[] memory values = new uint256[](1);
//         bytes[] memory calldatas = new bytes[](1);
        
//         targets[0] = alice;
//         values[0] = address(donationHandler).balance; // Try to drain treasury
//         calldatas[0] = "";
        
//         vm.prank(alice);
//         uint256 proposalId = governor.propose(
//             targets,
//             values,
//             calldatas,
//             "Emergency transfer"
//         );
        
//         // Admin can cancel malicious proposals using PROPOSAL_CANCELLER_ROLE
//         vm.prank(address(this)); // Admin has canceller role
//         governor.cancel(targets, values, calldatas, keccak256(bytes("Emergency transfer")));
        
//         // Verify proposal is cancelled
//         assertEq(uint256(governor.state(proposalId)), 2); // Cancelled state
        
//         console.log("Emergency scenario test completed!");
//     }

//     /* -------------------------------------------------------------------------- */
//     /*                           HELPER FUNCTIONS                                */
//     /* -------------------------------------------------------------------------- */
    
//     function _setupTestUsers() internal {
//         // Give ETH to test users
//         vm.deal(alice, 100 ether);
//         vm.deal(bob, 100 ether);
//         vm.deal(charlie, 100 ether);
        
//         // Mint tokens to test users
//         ERC20Mock(usdcToken).mint(alice, 100000e6);
//         ERC20Mock(usdcToken).mint(bob, 100000e6);
//         ERC20Mock(usdcToken).mint(charlie, 100000e6);
        
//         ERC20Mock(paxgToken).mint(alice, 1000e18);
//         ERC20Mock(paxgToken).mint(bob, 1000e18);
//         ERC20Mock(paxgToken).mint(charlie, 1000e18);
        
//         // Register all users
//         identityRegistry.registerIdentity(alice);
//         identityRegistry.registerIdentity(bob);
//         identityRegistry.registerIdentity(charlie);
//     }
    
//     function _makeLargeDonations() internal {
//         console.log("Making large donations...");
        
//         // Alice makes large ETH donation
//         vm.prank(alice);
//         donationHandler.receiveEthDonation{value: LARGE_DONATION}();
        
//         // Bob makes medium ETH donation
//         vm.prank(bob);
//         donationHandler.receiveEthDonation{value: MEDIUM_DONATION}();
        
//         // Charlie makes small ETH donation
//         vm.prank(charlie);
//         donationHandler.receiveEthDonation{value: SMALL_DONATION}();
        
//         // Delegate votes
//         vm.prank(alice);
//         lhgtToken.delegate(alice);
        
//         vm.prank(bob);
//         lhgtToken.delegate(bob);
        
//         vm.prank(charlie);
//         lhgtToken.delegate(charlie);
        
//         console.log("Large donations completed");
//     }
    
//     function _createTestProposal() internal returns (uint256) {
//         console.log("Creating test proposal...");
        
//         address[] memory targets = new address[](1);
//         uint256[] memory values = new uint256[](1);
//         bytes[] memory calldatas = new bytes[](1);
        
//         targets[0] = dao;
//         values[0] = 1 ether;
//         calldatas[0] = "";
        
//         vm.prank(alice); // Alice has enough tokens
//         uint256 proposalId = governor.propose(
//             targets,
//             values,
//             calldatas,
//             "Fund DAO operations with 1 ETH"
//         );
        
//         console.log("Proposal created with ID:", proposalId);
//         return proposalId;
//     }
    
//     function _voteOnProposal(uint256 proposalId) internal {
//         console.log("Voting on proposal...");
        
//         // Wait for voting delay
//         vm.warp(block.timestamp + 7201);
        
//         // All users vote in favor
//         vm.prank(alice);
//         governor.castVoteWithReason(proposalId, 1, "Supporting DAO operations");
        
//         vm.prank(bob);
//         governor.castVoteWithReason(proposalId, 1, "Good use of funds");
        
//         vm.prank(charlie);
//         governor.castVoteWithReason(proposalId, 1, "Agree with proposal");
        
//         (uint256 againstVotes, uint256 forVotes, uint256 abstainVotes) = governor.proposalVotes(proposalId);
//         console.log("Voting completed - For:", forVotes, "Against:", againstVotes, "Abstain:", abstainVotes);
//     }
    
//     function _executeProposal(uint256 proposalId) internal {
//         console.log("Executing proposal...");
        
//         // Wait for voting period to end
//         vm.warp(block.timestamp + 50401);
        
//         address[] memory targets = new address[](1);
//         uint256[] memory values = new uint256[](1);
//         bytes[] memory calldatas = new bytes[](1);
        
//         targets[0] = dao;
//         values[0] = 1 ether;
//         calldatas[0] = "";
        
//         bytes32 descriptionHash = keccak256(bytes("Fund DAO operations with 1 ETH"));
        
//         // Queue the proposal
//         governor.queue(targets, values, calldatas, descriptionHash);
        
//         // Wait for timelock delay
//         vm.warp(block.timestamp + 2 days + 1);
        
//         // Execute
//         uint256 initialBalance = dao.balance;
//         governor.execute(targets, values, calldatas, descriptionHash);
        
//         assertEq(dao.balance, initialBalance + 1 ether);
//         console.log("Proposal executed successfully");
//     }
    
//     function _buildTreasury() internal {
//         // Multiple large donations to build treasury
//         vm.prank(alice);
//         donationHandler.receiveEthDonation{value: 20 ether}();
        
//         vm.prank(bob);
//         donationHandler.receiveEthDonation{value: 15 ether}();
        
//         vm.prank(charlie);
//         donationHandler.receiveEthDonation{value: 10 ether}();
        
//         // Delegate votes
//         vm.prank(alice);
//         lhgtToken.delegate(alice);
        
//         vm.prank(bob);
//         lhgtToken.delegate(bob);
        
//         vm.prank(charlie);
//         lhgtToken.delegate(charlie);
        
//         console.log("Treasury built. Total ETH:", address(donationHandler).balance);
//     }
    
//     function _logDonationSummary() internal view {
//         console.log("=== DONATION SUMMARY ===");
//         console.log("Total ETH donations:", donationHandler.s_totalEthDonations());
//         console.log("Total USDC donations:", donationHandler.s_totalUsdcDonations());
//         console.log("Total PAXG donations:", donationHandler.s_totalPaxgDonations());
//         console.log("Total fiat donations:", donationHandler.s_totalFiatDonations());
//         console.log("Alice LHGT balance:", lhgtToken.balanceOf(alice));
//         console.log("Bob LHGT balance:", lhgtToken.balanceOf(bob));
//         console.log("Charlie LHGT balance:", lhgtToken.balanceOf(charlie));
//         console.log("Total LHGT supply:", lhgtToken.totalSupply());
//     }
// }
