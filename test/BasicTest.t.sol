// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {DeployWAGADAO} from "../script/DeployWAGADAO.s.sol";
import {VERTGovernanceToken} from "../src/VERTGovernanceToken.sol";
import {IdentityRegistry} from "../src/IdentityRegistry.sol";
import {DonationHandler} from "../src/DonationHandler.sol";
import {WAGAGovernor} from "../src/WAGAGovernor.sol";
import {WAGATimelock} from "../src/WAGATimelock.sol";
import {WAGACoffeeInventoryToken} from "../src/WAGACoffeeInventoryToken.sol";
import {CooperativeLoanManager} from "../src/CooperativeLoanManager.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

/**
 * @title WAGADAOBasicTest
 * @notice Basic test to verify deployment and core functionality
 */
contract WAGADAOBasicTest is Test {
    DeployWAGADAO deployer;
    VERTGovernanceToken vertToken;
    IdentityRegistry identityRegistry;
    DonationHandler donationHandler;
    WAGAGovernor governor;
    WAGATimelock timelock;
    WAGACoffeeInventoryToken coffeeInventoryToken;
    CooperativeLoanManager loanManager;
    HelperConfig helperConfig;
    
    address user = makeAddr("user");
    
    function setUp() public {
        deployer = new DeployWAGADAO();
        
        try deployer.run() returns (
            VERTGovernanceToken _vertToken,
            IdentityRegistry _identityRegistry,
            DonationHandler _donationHandler,
            WAGAGovernor _governor,
            WAGATimelock _timelock,
            WAGACoffeeInventoryToken _coffeeInventoryToken,
            CooperativeLoanManager _loanManager,
            HelperConfig _helperConfig
        ) {
            vertToken = _vertToken;
            identityRegistry = _identityRegistry;
            donationHandler = _donationHandler;
            governor = _governor;
            timelock = _timelock;
            coffeeInventoryToken = _coffeeInventoryToken;
            loanManager = _loanManager;
            helperConfig = _helperConfig;
        } catch Error(string memory reason) {
            console.log("Deployment failed with reason:", reason);
            revert("Deployment failed");
        } catch (bytes memory lowLevelData) {
            console.log("Deployment failed with low level error");
            console.logBytes(lowLevelData);
            revert("Deployment failed");
        }
        
        vm.deal(user, 10 ether);
    }
    
    function testDeployment() public view {
        // Test that all contracts were deployed
        assertTrue(address(vertToken) != address(0));
        assertTrue(address(identityRegistry) != address(0));
        assertTrue(address(donationHandler) != address(0));
        assertTrue(address(governor) != address(0));
        assertTrue(address(timelock) != address(0));
        assertTrue(address(coffeeInventoryToken) != address(0));
        assertTrue(address(loanManager) != address(0));
        
        // Test basic contract properties
        assertEq(vertToken.name(), "VERT Governance Token");
        assertEq(vertToken.symbol(), "VERT");
        assertEq(vertToken.decimals(), 18);
        
        console.log("All contracts deployed successfully");
        console.log("Token has correct name and symbol");
    }
    
    function testBasicWorkflow() public {
        // 1. Register user identity
        identityRegistry.registerIdentity(user);
        assertTrue(identityRegistry.isVerified(user));
        console.log("User identity registered");
        
        // 2. Make donation
        vm.prank(user);
        donationHandler.receiveEthDonation{value: 1 ether}();
        
        // Verify donation was received and tokens minted
        assertGt(vertToken.balanceOf(user), 0);
        assertEq(address(donationHandler).balance, 1 ether);
        console.log("Donation made and tokens minted");
        console.log("   User VERT balance:", vertToken.balanceOf(user));
        
        // 3. Delegate votes
        vm.prank(user);
        vertToken.delegate(user);
        assertGt(vertToken.getVotes(user), 0);
        console.log("Votes delegated");
        console.log("   User voting power:", vertToken.getVotes(user));
    }
    
    function testGovernanceBasics() public view {
        // Test governance parameters
        assertEq(governor.proposalThreshold(), 1_000_000e18);
        assertEq(governor.votingDelay(), 7_200);
        assertEq(governor.votingPeriod(), 50_400);
        assertEq(timelock.getMinDelaySeconds(), 2 days);
        
        console.log("Governance parameters configured correctly");
    }
}
