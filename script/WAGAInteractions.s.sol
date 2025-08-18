// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {VERTGovernanceToken} from "../src/VERTGovernanceToken.sol";
import {IdentityRegistry} from "../src/IdentityRegistry.sol";
import {DonationHandler} from "../src/DonationHandler.sol";
import {WAGAGovernor} from "../src/WAGAGovernor.sol";
import {WAGACoffeeInventoryToken} from "../src/WAGACoffeeInventoryToken.sol";
import {CooperativeLoanManager} from "../src/CooperativeLoanManager.sol";
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
        uint256 loanValue,
        string memory cooperativeName,
        string memory location,
        address paymentAddress,
        string memory certifications,
        uint256 farmersCount
    ) public returns (uint256 batchId) {
        vm.startBroadcast();
        
        batchId = WAGACoffeeInventoryToken(coffeeInventoryToken).createBatch(
            ipfsUri,
            productionDate,
            expiryDate,
            quantity,
            pricePerKg,
            loanValue,
            cooperativeName,
            location,
            paymentAddress,
            certifications,
            farmersCount
        );
        
        vm.stopBroadcast();
        console.log("Created coffee batch with ID:", batchId);
        console.log("Quantity:", quantity, "kg");
        console.log("Price per kg:", pricePerKg, "USDC");
        return batchId;
    }

    function run() external {
        address coffeeInventoryToken = DevOpsTools.get_most_recent_deployment(
            "WAGACoffeeInventoryToken",
            block.chainid
        );
        
        // Example coffee batch from Ethiopian cooperative
        createCoffeeBatch(
            coffeeInventoryToken,
            "QmExample123...", // IPFS URI
            block.timestamp - 30 days, // Production date (30 days ago)
            block.timestamp + 365 days, // Expiry date (1 year from now)
            5000, // 5,000 kg of coffee
            8500000, // $8.50 per kg (8.5 * 1e6 USDC)
            42500000000, // $42,500 loan value (42.5 * 1e6 USDC)
            "Sidamo Coffee Cooperative",
            "Sidamo, Ethiopia",
            address(0xabCDEF1234567890ABcDEF1234567890aBCDeF12), // Cooperative address
            "Fair Trade, Organic, Rainforest Alliance",
            250 // 250 farmers
        );
    }
}

/**
 * @title CreateLoan
 * @notice Script to create a new loan for a coffee cooperative
 */
contract CreateLoan is Script {
    function createLoan(
        address loanManager,
        address cooperative,
        uint256 amount,
        uint256 durationDays,
        uint256 interestRate,
        uint256[] memory batchIds,
        string memory purpose,
        string memory cooperativeName,
        string memory location
    ) public returns (uint256 loanId) {
        vm.startBroadcast();
        
        loanId = CooperativeLoanManager(loanManager).createLoan(
            cooperative,
            amount,
            durationDays,
            interestRate,
            batchIds,
            purpose,
            cooperativeName,
            location
        );
        
        vm.stopBroadcast();
        console.log("Created loan with ID:", loanId);
        console.log("Amount:", amount, "USDC");
        console.log("Duration:", durationDays, "days");
        return loanId;
    }

    function run() external {
        address loanManager = DevOpsTools.get_most_recent_deployment(
            "CooperativeLoanManager",
            block.chainid
        );
        
        // Example loan for coffee processing equipment
        uint256[] memory batchIds = new uint256[](1);
        batchIds[0] = 1; // Using batch created in CreateCoffeeBatch
        
        createLoan(
            loanManager,
            address(0xabCDEF1234567890ABcDEF1234567890aBCDeF12), // Cooperative address
            25000e6, // $25,000 USDC loan
            365, // 1 year duration
            800, // 8% annual interest rate
            batchIds,
            "Coffee processing equipment and infrastructure upgrade",
            "Sidamo Coffee Cooperative",
            "Sidamo, Ethiopia"
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
        address governor = DevOpsTools.get_most_recent_deployment(
            "WAGAGovernor",
            block.chainid
        );
        
        // Example proposal: Approve loan creation
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        
        address loanManager = DevOpsTools.get_most_recent_deployment(
            "CooperativeLoanManager",
            block.chainid
        );
        
        targets[0] = loanManager;
        values[0] = 0;
        
        // Create calldata for loan creation
        uint256[] memory batchIds = new uint256[](1);
        batchIds[0] = 1;
        
        calldatas[0] = abi.encodeWithSignature(
            "createLoan(address,uint256,uint256,uint256,uint256[],string,string,string)",
            address(0xabCDEF1234567890ABcDEF1234567890aBCDeF12), // cooperative
            25000e6, // amount
            365, // duration
            800, // interest rate
            batchIds, // batch IDs
            "Coffee processing equipment upgrade",
            "Sidamo Coffee Cooperative",
            "Sidamo, Ethiopia"
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
        address loanManager,
        address user
    ) public view {
        VERTGovernanceToken token = VERTGovernanceToken(governanceToken);
        DonationHandler handler = DonationHandler(payable(donationHandler));
        WAGACoffeeInventoryToken coffeeToken = WAGACoffeeInventoryToken(coffeeInventoryToken);
        CooperativeLoanManager loans = CooperativeLoanManager(loanManager);
        
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
        
        // Check loan statistics
        (uint256 totalLoans, uint256 activeLoans, uint256 totalDisbursed, uint256 totalRepaid) = loans.getLoanStatistics();
        console.log("=== LOAN STATISTICS ===");
        console.log("Total loans:", totalLoans);
        console.log("Active loans:", activeLoans);
        console.log("Total disbursed:", totalDisbursed);
        console.log("Total repaid:", totalRepaid);
        
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
            "WAGACoffeeInventoryToken",
            block.chainid
        );
        address loanManager = DevOpsTools.get_most_recent_deployment(
            "CooperativeLoanManager",
            block.chainid
        );
        address user = address(0x1234567890123456789012345678901234567890); // Example user
        
        checkBalances(governanceToken, donationHandler, coffeeInventoryToken, loanManager, user);
    }
}

/**
 * @title RepayLoan
 * @notice Script to repay a loan
 */
contract RepayLoan is Script {
    function repayLoan(address loanManager, address usdcToken, uint256 loanId, uint256 amount) public {
        vm.startBroadcast();
        
        // First approve the loan manager to spend USDC
        ERC20Mock(usdcToken).approve(loanManager, amount);
        
        // Make the repayment
        CooperativeLoanManager(loanManager).repayLoan(loanId, amount);
        
        vm.stopBroadcast();
        console.log("Repaid loan ID:", loanId);
        console.log("Amount:", amount, "USDC");
    }

    function run() external {
        address loanManager = DevOpsTools.get_most_recent_deployment(
            "CooperativeLoanManager",
            block.chainid
        );
        address usdcToken = 0x036CbD53842c5426634e7929541eC2318f3dCF7e; // Base Sepolia USDC
        
        // Example: Partial repayment of loan ID 1
        repayLoan(loanManager, usdcToken, 1, 5000e6); // $5,000 USDC repayment
    }
}
