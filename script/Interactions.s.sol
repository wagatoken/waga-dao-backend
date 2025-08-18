// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {LionHeartGovernanceToken} from "../src/LionHeartGovernanceToken.sol";
import {IdentityRegistry} from "../src/IdentityRegistry.sol";
import {DonationHandler} from "../src/DonationHandler.sol";
import {LionHeartGovernor} from "../src/LionHeartGovernor.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

/**
 * @title RegisterIdentity
 * @notice Script to register a new identity for KYC/AML compliance
 */
contract RegisterIdentity is Script {
    function registerIdentity(address identityRegistry, address user) public {
        vm.startBroadcast();
        IdentityRegistry(identityRegistry).registerIdentity(user);
        vm.stopBroadcast();
        console.log("Registered identity for user:", user);
    }

    function run() external {
        CheckBalances checkScript = new CheckBalances();
        checkScript.run();
    }
}

/**
 * @title MakeDonationETH
 * @notice Script to make an ETH donation to the DAO
 */
contract MakeDonationETH is Script {
    uint256 constant DONATION_AMOUNT = 0.1 ether;

    function makeDonationEth(address donationHandler) public {
        vm.startBroadcast();
        DonationHandler(payable(donationHandler)).receiveEthDonation{value: DONATION_AMOUNT}();
        vm.stopBroadcast();
        console.log("Made ETH donation of:", DONATION_AMOUNT);
    }

    function run() external {
        address donationHandler = DevOpsTools.get_most_recent_deployment(
            "DonationHandler",
            block.chainid
        );
        makeDonationEth(donationHandler);
    }
}

/**
 * @title MakeDonationUSDC
 * @notice Script to make a USDC donation to the DAO
 */
contract MakeDonationUSDC is Script {
    uint256 constant DONATION_AMOUNT = 100e6; // 100 USDC

    function makeDonationUsdc(address donationHandler, address usdcToken) public {
        vm.startBroadcast();
        
        // First approve the donation handler to spend USDC
        ERC20Mock(usdcToken).approve(donationHandler, DONATION_AMOUNT);
        
        // Make the donation
        DonationHandler(donationHandler).receiveUsdcDonation(DONATION_AMOUNT);
        
        vm.stopBroadcast();
        console.log("Made USDC donation of:", DONATION_AMOUNT);
    }

    function run() external {
        address donationHandler = DevOpsTools.get_most_recent_deployment(
            "DonationHandler",
            block.chainid
        );
        // This would need to be configured per network
        address usdcToken = 0x036CbD53842c5426634e7929541eC2318f3dCF7e; // Base Sepolia USDC
        makeDonationUsdc(donationHandler, usdcToken);
    }
}

/**
 * @title CreateProposal
 * @notice Script to create a governance proposal
 */
contract CreateProposal is Script {
    function createProposal(
        address payable governor,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) public returns (uint256 proposalId) {
        vm.startBroadcast();
        proposalId = LionHeartGovernor(governor).propose(
            targets,
            values,
            calldatas,
            description
        );
        vm.stopBroadcast();
        console.log("Created proposal with ID:", proposalId);
        return proposalId;
    }

    function run() external {
        address governor = DevOpsTools.get_most_recent_deployment(
            "LionHeartGovernor",
            block.chainid
        );
        
        // Example proposal: Transfer 1 ETH from treasury
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        
        targets[0] = makeAddr("recipient");
        values[0] = 1 ether;
        calldatas[0] = "";
        
        createProposal(
            payable(governor),
            targets,
            values,
            calldatas,
            "Transfer 1 ETH from treasury to development fund"
        );
    }
}

/**
 * @title DelegateVotes
 * @notice Script to delegate voting power
 */
contract DelegateVotes is Script {
    function delegateVotes(address governanceToken, address delegatee) public {
        vm.startBroadcast();
        LionHeartGovernanceToken(governanceToken).delegate(delegatee);
        vm.stopBroadcast();
        console.log("Delegated votes to:", delegatee);
    }

    function run() external {
        address governanceToken = DevOpsTools.get_most_recent_deployment(
            "LionHeartGovernanceToken",
            block.chainid
        );
        address delegatee = makeAddr("delegate");
        delegateVotes(governanceToken, delegatee);
    }
}

/**
 * @title CheckBalances
 * @notice Script to check various balances and states
 */
contract CheckBalances is Script {
    function checkBalances(
        address governanceToken,
        address donationHandler,
        address user
    ) public view {
        LionHeartGovernanceToken token = LionHeartGovernanceToken(governanceToken);
        DonationHandler handler = DonationHandler(payable(donationHandler));
        
        console.log("=== LION HEART DAO BALANCES ===");
        console.log("User LHGT balance:", token.balanceOf(user));
        console.log("User voting power:", token.getVotes(user));
        console.log("Total LHGT supply:", token.totalSupply());
        console.log("DonationHandler ETH balance:", address(handler).balance);
        
        // Get the struct and access individual fields
        (uint256 ethTotal, uint256 usdcTotal, uint256 paxgTotal, uint256 fiatTotal, uint256 lhgtMinted) = handler.totalDonations();
        console.log("Total ETH donations:", ethTotal);
        console.log("Total USDC donations:", usdcTotal);
        console.log("Total PAXG donations:", paxgTotal);
        console.log("Total fiat donations:", fiatTotal);
        console.log("Total LHGT minted:", lhgtMinted);
    }

    function run() external {
        address governanceToken = DevOpsTools.get_most_recent_deployment(
            "LionHeartGovernanceToken",
            block.chainid
        );
        address donationHandler = DevOpsTools.get_most_recent_deployment(
            "DonationHandler",
            block.chainid
        );
        address user = address(0x1234567890123456789012345678901234567890); // Example user address
        
        checkBalances(governanceToken, donationHandler, user);
    }
}
