// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// import {Test, console} from "forge-std/Test.sol";
// import {DeployLionHeartDAO} from "../script/DeployLionHeartDAO.s.sol";
// import {LionHeartGovernanceToken} from "../src/LionHeartGovernanceToken.sol";
// import {IdentityRegistry} from "../src/IdentityRegistry.sol";
// import {DonationHandler} from "../src/DonationHandler.sol";
// import {LionHeartGovernor} from "../src/LionHeartGovernor.sol";
// import {LionHeartTimelock} from "../src/LionHeartTimelock.sol";
// import {HelperConfig} from "../script/HelperConfig.s.sol";

// /**
//  * @title LionHeartDAOBasicTest
//  * @notice Basic test to verify deployment and core functionality
//  */
// contract LionHeartDAOBasicTest is Test {
//     DeployLionHeartDAO deployer;
//     LionHeartGovernanceToken lhgtToken;
//     IdentityRegistry identityRegistry;
//     DonationHandler donationHandler;
//     LionHeartGovernor governor;
//     LionHeartTimelock timelock;
//     HelperConfig helperConfig;
    
//     address user = makeAddr("user");
    
//     function setUp() public {
//         deployer = new DeployLionHeartDAO();
        
//         try deployer.run() returns (
//             LionHeartGovernanceToken _lhgtToken,
//             IdentityRegistry _identityRegistry,
//             DonationHandler _donationHandler,
//             LionHeartGovernor _governor,
//             LionHeartTimelock _timelock,
//             HelperConfig _helperConfig
//         ) {
//             lhgtToken = _lhgtToken;
//             identityRegistry = _identityRegistry;
//             donationHandler = _donationHandler;
//             governor = _governor;
//             timelock = _timelock;
//             helperConfig = _helperConfig;
//         } catch Error(string memory reason) {
//             console.log("Deployment failed with reason:", reason);
//             revert("Deployment failed");
//         } catch (bytes memory lowLevelData) {
//             console.log("Deployment failed with low level error");
//             console.logBytes(lowLevelData);
//             revert("Deployment failed");
//         }
        
//         vm.deal(user, 10 ether);
//     }
    
//     function testDeployment() public view {
//         // Test that all contracts were deployed
//         assertTrue(address(lhgtToken) != address(0));
//         assertTrue(address(identityRegistry) != address(0));
//         assertTrue(address(donationHandler) != address(0));
//         assertTrue(address(governor) != address(0));
//         assertTrue(address(timelock) != address(0));
        
//         // Test basic contract properties
//         assertEq(lhgtToken.name(), "Lion Heart Governance Token");
//         assertEq(lhgtToken.symbol(), "LHGT");
//         assertEq(lhgtToken.decimals(), 18);
        
//         console.log("All contracts deployed successfully");
//         console.log("Token has correct name and symbol");
//     }
    
//     function testBasicWorkflow() public {
//         // 1. Register user identity
//         identityRegistry.registerIdentity(user);
//         assertTrue(identityRegistry.isVerified(user));
//         console.log("User identity registered");
        
//         // 2. Make donation
//         vm.prank(user);
//         donationHandler.receiveEthDonation{value: 1 ether}();
        
//         // Verify donation was received and tokens minted
//         assertGt(lhgtToken.balanceOf(user), 0);
//         assertEq(address(donationHandler).balance, 1 ether);
//         console.log("Donation made and tokens minted");
//         console.log("   User LHGT balance:", lhgtToken.balanceOf(user));
        
//         // 3. Delegate votes
//         vm.prank(user);
//         lhgtToken.delegate(user);
//         assertGt(lhgtToken.getVotes(user), 0);
//         console.log("Votes delegated");
//         console.log("   User voting power:", lhgtToken.getVotes(user));
//     }
    
//     function testGovernanceBasics() public view {
//         // Test governance parameters
//         assertEq(governor.proposalThreshold(), 1_000_000e18);
//         assertEq(governor.votingDelay(), 7_200);
//         assertEq(governor.votingPeriod(), 50_400);
//         assertEq(timelock.getMinDelaySeconds(), 2 days);
        
//         console.log("Governance parameters configured correctly");
//     }
// }
