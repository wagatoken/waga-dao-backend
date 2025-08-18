// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// import {Test, console} from "forge-std/Test.sol";
// import {VERTGovernanceToken} from "../src/VERTGovernanceToken.sol";
// import {IdentityRegistry} from "../src/IdentityRegistry.sol";
// import {DonationHandler} from "../src/DonationHandler.sol";
// import {WAGAGovernor} from "../src/WAGAGovernor.sol";
// import {WAGATimelock} from "../src/WAGATimelock.sol";
// import {DeployWAGADAO} from "../script/DeployWAGADAO.s.sol";
// import {HelperConfig} from "../script/HelperConfig.s.sol";
// import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

// /**
//  * @title WAGADAOTest
//  * @notice Comprehensive test suite for the WAGA DAO system
//  * @dev Tests all core functionality including governance, donations, and identity management for regenerative coffee projects
//  */
// contract WAGADAOTest is Test {
//     /* -------------------------------------------------------------------------- */
//     /*                               STATE VARIABLES                              */
//     /* -------------------------------------------------------------------------- */
    
//     VERTGovernanceToken public vertToken;
//     IdentityRegistry public identityRegistry;
//     DonationHandler public donationHandler;
//     WAGAGovernor public governor;
//     WAGATimelock public timelock;
//     HelperConfig public helperConfig;
    
//     DeployWAGADAO public deployer;
    
//     address public usdcToken;
//     address public paxgToken;
    
//     // Test users
//     address public user = makeAddr("user");
//     address public donorETH = makeAddr("donorETH");
//     address public donorUSDC = makeAddr("donorUSDC");
//     address public donorPAXG = makeAddr("donorPAXG");
//     address public proposer = makeAddr("proposer");
    
//     // Test constants
//     uint256 public constant STARTING_ETH_BALANCE = 10 ether;
//     uint256 public constant STARTING_USDC_BALANCE = 100_000e6; // 100,000 USDC
//     uint256 public constant STARTING_PAXG_BALANCE = 1000e18; // 1000 PAXG
//     uint256 public constant ETH_DONATION_AMOUNT = 1 ether;
//     uint256 public constant USDC_DONATION_AMOUNT = 1000e6; // 1000 USDC
//     uint256 public constant PAXG_DONATION_AMOUNT = 10e18; // 10 PAXG
//     uint256 public constant FIAT_DONATION_AMOUNT = 5000e18; // $5000 worth

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
        
//         // Get network configuration
//         (usdcToken, paxgToken,) = helperConfig.activeNetworkConfig();
        
//         // Setup test users with ETH
//         vm.deal(user, STARTING_ETH_BALANCE);
//         vm.deal(donorETH, STARTING_ETH_BALANCE);
//         vm.deal(donorUSDC, STARTING_ETH_BALANCE);
//         vm.deal(donorPAXG, STARTING_ETH_BALANCE);
//         vm.deal(proposer, STARTING_ETH_BALANCE);
        
//         // Mint tokens to donors for testing
//         ERC20Mock(usdcToken).mint(donorUSDC, STARTING_USDC_BALANCE);
//         ERC20Mock(usdcToken).mint(user, STARTING_USDC_BALANCE);
//         ERC20Mock(paxgToken).mint(donorPAXG, STARTING_PAXG_BALANCE);
//         ERC20Mock(paxgToken).mint(user, STARTING_PAXG_BALANCE);
        
//         // Register all test users as verified identities
//         _registerTestUsers();
//     }

//     /* -------------------------------------------------------------------------- */
//     /*                              MODIFIERS                                    */
//     /* -------------------------------------------------------------------------- */
    
//     modifier withVerifiedUser(address userAddr) {
//         vm.startPrank(address(this));
//         identityRegistry.registerIdentity(userAddr);
//         vm.stopPrank();
//         _;
//     }
    
//     modifier withEthDonation() {
//         vm.prank(donorETH);
//         donationHandler.receiveEthDonation{value: ETH_DONATION_AMOUNT}();
//         _;
//     }
    
//     modifier withUsdcDonation() {
//         vm.startPrank(donorUSDC);
//         ERC20Mock(usdcToken).approve(address(donationHandler), USDC_DONATION_AMOUNT);
//         donationHandler.receiveUsdcDonation(USDC_DONATION_AMOUNT);
//         vm.stopPrank();
//         _;
//     }
    
//     modifier withTokensForProposal() {
//         // Give proposer enough tokens to create proposals (1M tokens required)
//         vm.startPrank(donorETH);
//         donationHandler.receiveEthDonation{value: 100 ether}(); // Large donation to get enough tokens
//         lhgtToken.transfer(proposer, 2_000_000e18); // Transfer 2M tokens to proposer
//         vm.stopPrank();
        
//         // Delegate votes to self
//         vm.prank(proposer);
//         lhgtToken.delegate(proposer);
//         _;
//     }

//     /* -------------------------------------------------------------------------- */
//     /*                          IDENTITY REGISTRY TESTS                          */
//     /* -------------------------------------------------------------------------- */
    
//     function testIdentityRegistryDeployment() public view {
//         assertTrue(address(identityRegistry) != address(0));
//         assertTrue(identityRegistry.hasRole(identityRegistry.DEFAULT_ADMIN_ROLE(), address(this)));
//     }
    
//     function testRegisterIdentity() public {
//         address newUser = makeAddr("newUser");
//         assertFalse(identityRegistry.isVerified(newUser));
        
//         identityRegistry.registerIdentity(newUser);
        
//         assertTrue(identityRegistry.isVerified(newUser));
//         assertEq(identityRegistry.s_verifiedCount(), 5); // 4 from setup + 1 new
//     }
    
//     function testBatchRegisterIdentities() public {
//         address[] memory newUsers = new address[](3);
//         newUsers[0] = makeAddr("batchUser1");
//         newUsers[1] = makeAddr("batchUser2");
//         newUsers[2] = makeAddr("batchUser3");
        
//         identityRegistry.batchRegisterIdentities(newUsers);
        
//         for (uint256 i = 0; i < newUsers.length; i++) {
//             assertTrue(identityRegistry.isVerified(newUsers[i]));
//         }
//         assertEq(identityRegistry.s_verifiedCount(), 7); // 4 from setup + 3 new
//     }
    
//     function testOnlyManagerCanRegisterIdentity() public {
//         address newUser = makeAddr("newUser");
        
//         vm.prank(user);
//         vm.expectRevert();
//         identityRegistry.registerIdentity(newUser);
//     }

//     /* -------------------------------------------------------------------------- */
//     /*                        GOVERNANCE TOKEN TESTS                             */
//     /* -------------------------------------------------------------------------- */
    
//     function testGovernanceTokenDeployment() public view {
//         assertTrue(address(lhgtToken) != address(0));
//         assertEq(lhgtToken.name(), "Lion Heart Governance Token");
//         assertEq(lhgtToken.symbol(), "LHGT");
//         assertEq(lhgtToken.decimals(), 18);
//     }
    
//     function testTokenTransferRequiresVerification() public {
//         // Mint tokens to user
//         vm.prank(address(donationHandler));
//         lhgtToken.mint(user, 1000e18);
        
//         address unverifiedUser = makeAddr("unverified");
        
//         // Transfer should fail to unverified user
//         vm.prank(user);
//         vm.expectRevert();
//         lhgtToken.transfer(unverifiedUser, 100e18);
        
//         // Register the user
//         identityRegistry.registerIdentity(unverifiedUser);
        
//         // Transfer should now succeed
//         vm.prank(user);
//         lhgtToken.transfer(unverifiedUser, 100e18);
//         assertEq(lhgtToken.balanceOf(unverifiedUser), 100e18);
//     }
    
//     function testOnlyMinterCanMint() public {
//         vm.prank(user);
//         vm.expectRevert();
//         lhgtToken.mint(user, 1000e18);
//     }

//     /* -------------------------------------------------------------------------- */
//     /*                          DONATION HANDLER TESTS                           */
//     /* -------------------------------------------------------------------------- */
    
//     function testDonationHandlerDeployment() public view {
//         assertTrue(address(donationHandler) != address(0));
//         assertEq(donationHandler.i_lhgtToken(), address(lhgtToken));
//         assertEq(address(donationHandler.i_identityRegistry()), address(identityRegistry));
//     }
    
//     function testReceiveEthDonation() public withVerifiedUser(donorETH) {
//         uint256 initialBalance = lhgtToken.balanceOf(donorETH);
//         uint256 initialEthDonations = donationHandler.s_totalEthDonations();
        
//         vm.prank(donorETH);
//         donationHandler.receiveEthDonation{value: ETH_DONATION_AMOUNT}();
        
//         // Check ETH was received
//         assertEq(address(donationHandler).balance, ETH_DONATION_AMOUNT);
//         assertEq(donationHandler.s_totalEthDonations(), initialEthDonations + ETH_DONATION_AMOUNT);
        
//         // Check tokens were minted (rate: 1000 LHGT per 1 ETH)
//         uint256 expectedTokens = ETH_DONATION_AMOUNT * 1000;
//         assertEq(lhgtToken.balanceOf(donorETH), initialBalance + expectedTokens);
        
//         console.log("ETH donation successful. Tokens minted:", expectedTokens);
//     }
    
//     function testReceiveUsdcDonation() public withVerifiedUser(donorUSDC) {
//         uint256 initialBalance = lhgtToken.balanceOf(donorUSDC);
//         uint256 initialUsdcDonations = donationHandler.s_totalUsdcDonations();
        
//         vm.startPrank(donorUSDC);
//         ERC20Mock(usdcToken).approve(address(donationHandler), USDC_DONATION_AMOUNT);
//         donationHandler.receiveUsdcDonation(USDC_DONATION_AMOUNT);
//         vm.stopPrank();
        
//         // Check USDC was received
//         assertEq(ERC20Mock(usdcToken).balanceOf(address(donationHandler)), USDC_DONATION_AMOUNT);
//         assertEq(donationHandler.s_totalUsdcDonations(), initialUsdcDonations + USDC_DONATION_AMOUNT);
        
//         // Check tokens were minted (rate: 500 LHGT per 1 USDC)
//         uint256 expectedTokens = USDC_DONATION_AMOUNT * 500;
//         assertEq(lhgtToken.balanceOf(donorUSDC), initialBalance + expectedTokens);
        
//         console.log("USDC donation successful. Tokens minted:", expectedTokens);
//     }
    
//     function testReceivePaxgDonation() public withVerifiedUser(donorPAXG) {
//         uint256 initialBalance = lhgtToken.balanceOf(donorPAXG);
//         uint256 initialPaxgDonations = donationHandler.s_totalPaxgDonations();
        
//         vm.startPrank(donorPAXG);
//         ERC20Mock(paxgToken).approve(address(donationHandler), PAXG_DONATION_AMOUNT);
//         donationHandler.receivePaxgDonation(PAXG_DONATION_AMOUNT);
//         vm.stopPrank();
        
//         // Check PAXG was received
//         assertEq(ERC20Mock(paxgToken).balanceOf(address(donationHandler)), PAXG_DONATION_AMOUNT);
//         assertEq(donationHandler.s_totalPaxgDonations(), initialPaxgDonations + PAXG_DONATION_AMOUNT);
        
//         // Check tokens were minted (rate: 100 LHGT per 1 PAXG)
//         uint256 expectedTokens = PAXG_DONATION_AMOUNT * 100;
//         assertEq(lhgtToken.balanceOf(donorPAXG), initialBalance + expectedTokens);
        
//         console.log("PAXG donation successful. Tokens minted:", expectedTokens);
//     }
    
//     function testReceiveFiatDonation() public withVerifiedUser(user) {
//         uint256 initialBalance = lhgtToken.balanceOf(user);
//         uint256 initialFiatDonations = donationHandler.s_totalFiatDonations();
        
//         donationHandler.receiveFiatDonation(user, FIAT_DONATION_AMOUNT);
        
//         // Check fiat donation was recorded
//         assertEq(donationHandler.s_totalFiatDonations(), initialFiatDonations + FIAT_DONATION_AMOUNT);
        
//         // Check tokens were minted (rate: 1000 LHGT per 1 USD)
//         uint256 expectedTokens = FIAT_DONATION_AMOUNT * 1000;
//         assertEq(lhgtToken.balanceOf(user), initialBalance + expectedTokens);
        
//         console.log("Fiat donation successful. Tokens minted:", expectedTokens);
//     }
    
//     function testDonationRequiresVerification() public {
//         address unverifiedDonor = makeAddr("unverified");
//         vm.deal(unverifiedDonor, 1 ether);
        
//         vm.prank(unverifiedDonor);
//         vm.expectRevert();
//         donationHandler.receiveEthDonation{value: 0.1 ether}();
//     }

//     /* -------------------------------------------------------------------------- */
//     /*                           GOVERNANCE TESTS                                */
//     /* -------------------------------------------------------------------------- */
    
//     function testGovernorDeployment() public view {
//         assertTrue(address(governor) != address(0));
//         assertTrue(address(timelock) != address(0));
//         assertEq(address(governor.token()), address(lhgtToken));
//         assertEq(address(governor.timelock()), address(timelock));
//     }
    
//     function testCreateProposal() public withTokensForProposal {
//         // Create a simple proposal to transfer ETH
//         address[] memory targets = new address[](1);
//         uint256[] memory values = new uint256[](1);
//         bytes[] memory calldatas = new bytes[](1);
        
//         targets[0] = makeAddr("recipient");
//         values[0] = 1 ether;
//         calldatas[0] = "";
        
//         string memory description = "Transfer 1 ETH to development fund";
        
//         vm.prank(proposer);
//         uint256 proposalId = governor.propose(targets, values, calldatas, description);
        
//         assertTrue(proposalId > 0);
//         console.log("Proposal created with ID:", proposalId);
//     }
    
//     function testVoteOnProposal() public withTokensForProposal {
//         // Create proposal
//         address[] memory targets = new address[](1);
//         uint256[] memory values = new uint256[](1);
//         bytes[] memory calldatas = new bytes[](1);
        
//         targets[0] = makeAddr("recipient");
//         values[0] = 1 ether;
//         calldatas[0] = "";
        
//         vm.prank(proposer);
//         uint256 proposalId = governor.propose(targets, values, calldatas, "Test proposal");
        
//         // Wait for voting delay
//         vm.warp(block.timestamp + 7201); // 1 day + 1 second
        
//         // Vote on proposal (1 = For, 0 = Against, 2 = Abstain)
//         vm.prank(proposer);
//         governor.castVote(proposalId, 1);
        
//         // Check vote was recorded
//         (uint256 againstVotes, uint256 forVotes, uint256 abstainVotes) = governor.proposalVotes(proposalId);
//         assertGt(forVotes, 0);
//         console.log("Votes cast - For:", forVotes, "Against:", againstVotes, "Abstain:", abstainVotes);
//     }
    
//     function testProposalThreshold() public view {
//         assertEq(governor.proposalThreshold(), 1_000_000e18); // 1M tokens required
//     }

//     /* -------------------------------------------------------------------------- */
//     /*                          INTEGRATION TESTS                                */
//     /* -------------------------------------------------------------------------- */
    
//     function testCompleteFlow() public {
//         console.log("=== TESTING COMPLETE DAO FLOW ===");
        
//         // 1. Register identity
//         address newUser = makeAddr("flowUser");
//         vm.deal(newUser, 5 ether);
//         identityRegistry.registerIdentity(newUser);
//         console.log("1. Identity registered for user");
        
//         // 2. Make donation
//         vm.prank(newUser);
//         donationHandler.receiveEthDonation{value: 2 ether}();
//         console.log("2. Donation made: 2 ETH");
//         console.log("   Tokens received:", lhgtToken.balanceOf(newUser));
        
//         // 3. Delegate votes
//         vm.prank(newUser);
//         lhgtToken.delegate(newUser);
//         console.log("3. Votes delegated");
//         console.log("   Voting power:", lhgtToken.getVotes(newUser));
        
//         // 4. Check total supply and donations
//         console.log("4. Final state:");
//         console.log("   Total LHGT supply:", lhgtToken.totalSupply());
//         console.log("   Total ETH donations:", donationHandler.s_totalEthDonations());
//         console.log("   DAO ETH balance:", address(donationHandler).balance);
//     }

//     /* -------------------------------------------------------------------------- */
//     /*                           HELPER FUNCTIONS                                */
//     /* -------------------------------------------------------------------------- */
    
//     function _registerTestUsers() internal {
//         identityRegistry.registerIdentity(user);
//         identityRegistry.registerIdentity(donorETH);
//         identityRegistry.registerIdentity(donorUSDC);
//         identityRegistry.registerIdentity(donorPAXG);
//     }
// }
