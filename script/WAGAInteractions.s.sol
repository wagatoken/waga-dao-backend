// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {VERTGovernanceToken} from "src/shared/VERTGovernanceToken.sol";
import {IdentityRegistry} from "src/shared/IdentityRegistry.sol";
import {DonationHandler} from "src/base/DonationHandler.sol";
import {WAGAGovernor} from "src/shared/WAGAGovernor.sol";
import {WAGACoffeeInventoryTokenV2} from "src/shared/WAGACoffeeInventoryTokenV2.sol";
import {CooperativeGrantManagerV2} from "src/base/CooperativeGrantManagerV2.sol";
import {CoffeeStructs} from "src/shared/libraries/CoffeeStructs.sol";
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
        address identityRegistry = DevOpsTools.get_most_recent_deployment(
            "IdentityRegistry",
            block.chainid
        );
        address user = address(0x1234567890123456789012345678901234567890); // Example user
        registerIdentity(identityRegistry, user);
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
 * @title CreateCoffeeBatch
 * @notice Script to create a new coffee batch for collateral
 */
contract CreateCoffeeBatch is Script {
    function createCoffeeBatch(
        address coffeeInventoryToken,
        string memory ipfsUri,
        uint256 productionDate,
        uint256 expiryDate,
        uint256 quantity,
        uint256 pricePerKg,
        uint256 grantValue
    ) public returns (uint256 batchId) {
        vm.startBroadcast();
        
        // Create simplified batch creation parameters (blockchain-first approach)
        CoffeeStructs.BatchCreationParams memory params = CoffeeStructs.BatchCreationParams({
            productionDate: productionDate,
            expiryDate: expiryDate,
            quantity: quantity,
            pricePerKg: pricePerKg,
            grantValue: grantValue,
            ipfsHash: ipfsUri  // All rich metadata goes to IPFS + database
        });
        
        batchId = WAGACoffeeInventoryTokenV2(coffeeInventoryToken).createBatch(params);
        
        vm.stopBroadcast();
        console.log("Created coffee batch with ID:", batchId);
        console.log("Quantity:", quantity, "kg");
        console.log("Price per kg:", pricePerKg, "USDC");
        console.log("NOTE: Cooperative details stored off-chain via database API");
        return batchId;
    }

    function run() external {
        address coffeeInventoryToken = DevOpsTools.get_most_recent_deployment(
            "WAGACoffeeInventoryTokenV2",
            block.chainid
        );
        
        // Example coffee batch from Ethiopian cooperative
        createCoffeeBatch(
            coffeeInventoryToken,
            "QmExample123...", // IPFS URI with rich metadata
            block.timestamp - 30 days, // Production date (30 days ago)
            block.timestamp + 365 days, // Expiry date (1 year from now)
            5000, // 5,000 kg of coffee
            8500000, // $8.50 per kg (8.5 * 1e6 USDC)
            42500000000 // $42,500 grant value (42.5 * 1e6 USDC)
            // NOTE: Cooperative details (name, location, farmers count, etc.) stored off-chain
        );
    }
}

/**
 * @title CreateGrant
 * @notice Script to create a new grant for a coffee cooperative
 */
contract CreateGrant is Script {
    function createGrant(
        address grantManager,
        address cooperative,
        uint256 amount,
        uint256[] memory batchIds,
        uint256 revenueSharePercentage,
        uint256 durationYears,
        string memory description
    ) public returns (uint256 grantId) {
        vm.startBroadcast();
        
        grantId = CooperativeGrantManagerV2(grantManager).createGrant(
            cooperative,
            amount,
            batchIds,
            revenueSharePercentage,
            durationYears,
            description
        );
        
        vm.stopBroadcast();
        console.log("Created grant with ID:", grantId);
        console.log("Amount:", amount, "USDC");
        console.log("Duration:", durationYears, "years");
        return grantId;
    }

    function run() external {
        address grantManager = DevOpsTools.get_most_recent_deployment(
            "CooperativeGrantManager",
            block.chainid
        );
        
        // Example grant for coffee processing equipment
        uint256[] memory batchIds = new uint256[](1);
        batchIds[0] = 1; // Using batch created in CreateCoffeeBatch
        
        createGrant(
            grantManager,
            address(0xabCDEF1234567890ABcDEF1234567890aBCDeF12), // Cooperative address
            25000e6, // $25,000 USDC grant
            batchIds,
            3000, // 30% revenue share to DAO
            3, // 3 years duration
            "Coffee processing equipment and infrastructure upgrade"
        );
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
        proposalId = WAGAGovernor(governor).propose(
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
        address payable governor = payable(DevOpsTools.get_most_recent_deployment(
            "WAGAGovernor",
            block.chainid
        ));
        
        // Example proposal: Approve grant creation
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        
        address grantManager = DevOpsTools.get_most_recent_deployment(
            "CooperativeGrantManager",
            block.chainid
        );
        
        targets[0] = grantManager;
        values[0] = 0;
        
                // Create calldata for grant creation (simplified for now)
        calldatas[0] = "";
        
        uint256 proposalId = WAGAGovernor(governor).propose(
            targets,
            values,
            calldatas,
            "Approve $25,000 USDC grant to Sidamo Coffee Cooperative for processing equipment upgrade"
        );
        
        createProposal(
            payable(governor),
            targets,
            values,
            calldatas,
            "Approve $25,000 USDC loan to Sidamo Coffee Cooperative for processing equipment upgrade"
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
        VERTGovernanceToken(governanceToken).delegate(delegatee);
        vm.stopBroadcast();
        console.log("Delegated votes to:", delegatee);
    }

    function run() external {
        address governanceToken = DevOpsTools.get_most_recent_deployment(
            "VERTGovernanceToken",
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
        address coffeeInventoryToken,
        address grantManager,
        address user
    ) public view {
        VERTGovernanceToken token = VERTGovernanceToken(governanceToken);
        DonationHandler handler = DonationHandler(payable(donationHandler));
        WAGACoffeeInventoryTokenV2 coffeeToken = WAGACoffeeInventoryTokenV2(coffeeInventoryToken);
        CooperativeGrantManagerV2 grants = CooperativeGrantManagerV2(grantManager);
        
        console.log("=== WAGA DAO BALANCES & STATUS ===");
        console.log("User VERT balance:", token.balanceOf(user));
        console.log("User voting power:", token.getVotes(user));
        console.log("Total VERT supply:", token.totalSupply());
        console.log("DonationHandler ETH balance:", address(handler).balance);
        
        // Get donation totals
        (uint256 ethTotal, uint256 usdcTotal, uint256 paxgTotal, uint256 fiatTotal, uint256 vertMinted) = handler.totalDonations();
        console.log("Total ETH donations:", ethTotal);
        console.log("Total USDC donations:", usdcTotal);
        console.log("Total PAXG donations:", paxgTotal);
        console.log("Total fiat donations:", fiatTotal);
        console.log("Total VERT minted:", vertMinted);
        
        // Check grant statistics (simplified for transformation)
        console.log("=== GRANT STATISTICS ===");
        console.log("Grant system active - statistics available via getGrantStatistics()");
        // (uint256 totalGrants, uint256 activeGrants, uint256 totalDisbursed, uint256 totalRevenueShared) = grants.getGrantStatistics();
        console.log("Grant system transformed from loan-based to equity-sharing model");
        
        // Check next coffee batch ID
        console.log("=== COFFEE INVENTORY ===");
        console.log("Next batch ID:", coffeeToken.nextBatchId());
    }

    function run() external {
        address governanceToken = DevOpsTools.get_most_recent_deployment(
            "VERTGovernanceToken",
            block.chainid
        );
        address donationHandler = DevOpsTools.get_most_recent_deployment(
            "DonationHandler",
            block.chainid
        );
        address coffeeInventoryToken = DevOpsTools.get_most_recent_deployment(
            "WAGACoffeeInventoryTokenV2",
            block.chainid
        );
        address grantManager = DevOpsTools.get_most_recent_deployment(
            "CooperativeGrantManager",
            block.chainid
        );
        address user = address(0x1234567890123456789012345678901234567890); // Example user
        
        checkBalances(governanceToken, donationHandler, coffeeInventoryToken, grantManager, user);
    }
}

/**
 * @title RecordRevenueShare
 * @notice Script to record revenue sharing from coffee sales
 */
contract RecordRevenueShare is Script {
    function recordRevenueShare(address grantManager, uint256 grantId, uint256 revenueAmount) public {
        vm.startBroadcast();
        
        CooperativeGrantManagerV2(grantManager).recordRevenueShare(grantId, revenueAmount);
        
        vm.stopBroadcast();
        console.log("Recorded revenue share for grant ID:", grantId);
        console.log("Revenue amount:", revenueAmount, "USDC");
    }

    function run() external {
        address grantManager = DevOpsTools.get_most_recent_deployment(
            "CooperativeGrantManager",
            block.chainid
        );
        
        // Example: Record revenue share for grant ID 1
        recordRevenueShare(grantManager, 1, 10000e6); // $10,000 USDC revenue
    }
}
