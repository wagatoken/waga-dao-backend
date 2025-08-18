// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {VERTGovernanceToken} from "../src/VERTGovernanceToken.sol";
import {IdentityRegistry} from "../src/IdentityRegistry.sol";
import {DonationHandler} from "../src/DonationHandler.sol";
import {WAGAGovernor} from "../src/WAGAGovernor.sol";
import {WAGATimelock} from "../src/WAGATimelock.sol";
import {WAGACoffeeInventoryToken} from "../src/WAGACoffeeInventoryToken.sol";
import {CooperativeLoanManager} from "../src/CooperativeLoanManager.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {MockV3Aggregator} from "./mocks/MockV3Aggregator.sol";

/**
 * @title WAGADAOComprehensiveTest
 * @notice Comprehensive test suite for the WAGA DAO system
 * @dev Tests all core functionality including governance, donations, loans, and coffee inventory management
 */
contract WAGADAOComprehensiveTest is Test {
    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */
    
    VERTGovernanceToken public vertToken;
    IdentityRegistry public identityRegistry;
    DonationHandler public donationHandler;
    WAGAGovernor public governor;
    WAGATimelock public timelock;
    WAGACoffeeInventoryToken public coffeeInventoryToken;
    CooperativeLoanManager public loanManager;
    
    ERC20Mock public usdcToken;
    ERC20Mock public paxgToken;
    
    // Test users
    address public admin = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // Default Anvil account
    address public user = makeAddr("user");
    address public donorETH = makeAddr("donorETH");
    address public donorUSDC = makeAddr("donorUSDC");
    address public donorPAXG = makeAddr("donorPAXG");
    address public proposer = makeAddr("proposer");
    address public cooperative = makeAddr("cooperative");
    
    // Test constants
    uint256 public constant STARTING_ETH_BALANCE = 10 ether;
    uint256 public constant STARTING_USDC_BALANCE = 100_000e6; // 100,000 USDC
    uint256 public constant STARTING_PAXG_BALANCE = 1000e18; // 1000 PAXG
    uint256 public constant ETH_DONATION_AMOUNT = 1 ether;
    uint256 public constant USDC_DONATION_AMOUNT = 1000e6; // 1000 USDC
    uint256 public constant PAXG_DONATION_AMOUNT = 10e18; // 10 PAXG
    uint256 public constant FIAT_DONATION_AMOUNT = 5000e18; // $5000 worth

    /* -------------------------------------------------------------------------- */
    /*                                   SETUP                                    */
    /* -------------------------------------------------------------------------- */
    
    function setUp() public {
        // Deploy all contracts directly in test (similar to BasicTest.t.sol approach)
        _deployContracts();
        _setupRoles();
        _setupTestUsers();
    }

    function _deployContracts() internal {
        // 1. Deploy IdentityRegistry first (no dependencies)
        identityRegistry = new IdentityRegistry(admin);

        // 2. Deploy VERTGovernanceToken with IdentityRegistry
        vertToken = new VERTGovernanceToken(
            address(identityRegistry),
            admin // initial owner
        );

        // 3. Deploy Timelock Controller (2 day delay)
        address[] memory proposers = new address[](1); 
        address[] memory executors = new address[](1);
        proposers[0] = admin;
        executors[0] = admin;
        
        timelock = new WAGATimelock(
            2 days,
            proposers,
            executors,
            admin
        );

        // 4. Deploy Governor with token and timelock
        governor = new WAGAGovernor(vertToken, timelock);

        // 5. Deploy Coffee Inventory Token
        coffeeInventoryToken = new WAGACoffeeInventoryToken(admin);

        // 6. Create mock tokens and price feeds for testing
        usdcToken = new ERC20Mock();
        paxgToken = new ERC20Mock();
        
        // Create mock price feeds
        MockV3Aggregator ethUsdPriceFeed = new MockV3Aggregator(8, 3000e8); // $3000 ETH
        MockV3Aggregator paxgUsdPriceFeed = new MockV3Aggregator(8, 2000e8); // $2000 PAXG

        // 7. Deploy Cooperative Loan Manager
        loanManager = new CooperativeLoanManager(
            address(usdcToken),
            address(coffeeInventoryToken),
            admin, // Treasury address
            admin  // Initial admin
        );

        // 8. Deploy DonationHandler with all required contracts
        donationHandler = new DonationHandler(
            address(vertToken),
            address(identityRegistry),
            address(usdcToken),
            address(paxgToken),
            address(ethUsdPriceFeed),
            address(paxgUsdPriceFeed),
            admin, // treasury address
            admin  // initial owner
        );
    }

    function _setupRoles() internal {
        vm.startPrank(admin);
        
        // Grant minter role to DonationHandler for token minting
        vertToken.grantRole(vertToken.MINTER_ROLE(), address(donationHandler));

        // Set up timelock roles for governance
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(governor));
        timelock.revokeRole(timelock.PROPOSER_ROLE(), admin);
        timelock.revokeRole(timelock.EXECUTOR_ROLE(), admin);

        // Set up coffee inventory token roles
        coffeeInventoryToken.grantRole(coffeeInventoryToken.DAO_ADMIN_ROLE(), address(loanManager));
        coffeeInventoryToken.grantRole(coffeeInventoryToken.INVENTORY_MANAGER_ROLE(), address(loanManager));
        coffeeInventoryToken.grantRole(coffeeInventoryToken.MINTER_ROLE(), address(loanManager));

        // Set up loan manager roles
        loanManager.grantRole(loanManager.DAO_TREASURY_ROLE(), address(timelock));
        loanManager.grantRole(loanManager.LOAN_MANAGER_ROLE(), address(timelock));
        loanManager.grantRole(loanManager.LOAN_MANAGER_ROLE(), address(governor));
        
        vm.stopPrank();
    }

    function _setupTestUsers() internal {
        // Give ETH to test users
        vm.deal(user, STARTING_ETH_BALANCE);
        vm.deal(donorETH, STARTING_ETH_BALANCE);
        vm.deal(donorUSDC, STARTING_ETH_BALANCE);
        vm.deal(donorPAXG, STARTING_ETH_BALANCE);
        vm.deal(proposer, STARTING_ETH_BALANCE);
        vm.deal(cooperative, STARTING_ETH_BALANCE);
        
        // Mint tokens to test users
        usdcToken.mint(donorUSDC, STARTING_USDC_BALANCE);
        usdcToken.mint(user, STARTING_USDC_BALANCE);
        usdcToken.mint(admin, STARTING_USDC_BALANCE); // For loan disbursement
        
        paxgToken.mint(donorPAXG, STARTING_PAXG_BALANCE);
        paxgToken.mint(user, STARTING_PAXG_BALANCE);
        
        // Register all users
        vm.startPrank(admin);
        identityRegistry.registerIdentity(user);
        identityRegistry.registerIdentity(donorETH);
        identityRegistry.registerIdentity(donorUSDC);
        identityRegistry.registerIdentity(donorPAXG);
        identityRegistry.registerIdentity(proposer);
        identityRegistry.registerIdentity(cooperative);
        vm.stopPrank();
    }

    /* -------------------------------------------------------------------------- */
    /*                        GOVERNANCE TOKEN TESTS                             */
    /* -------------------------------------------------------------------------- */
    
    function testGovernanceTokenDeployment() public view {
        assertTrue(address(vertToken) != address(0));
        assertEq(vertToken.name(), "WAGA Vertical Integration Token");
        assertEq(vertToken.symbol(), "VERT");
        assertEq(vertToken.decimals(), 18);
    }
    
    function testTokenTransferRequiresVerification() public {
        // Mint tokens to user
        vm.prank(admin);
        vertToken.mint(user, 1000e18);
        
        address unverifiedUser = makeAddr("unverified");
        
        // Transfer should fail to unverified user
        vm.prank(user);
        vm.expectRevert();
        vertToken.transfer(unverifiedUser, 100e18);
        
        // Register the user
        vm.prank(admin);
        identityRegistry.registerIdentity(unverifiedUser);
        
        // Transfer should now succeed
        vm.prank(user);
        vertToken.transfer(unverifiedUser, 100e18);
        assertEq(vertToken.balanceOf(unverifiedUser), 100e18);
    }

    /* -------------------------------------------------------------------------- */
    /*                          DONATION HANDLER TESTS                           */
    /* -------------------------------------------------------------------------- */
    
    function testReceiveEthDonation() public {
        uint256 initialBalance = vertToken.balanceOf(donorETH);
        uint256 initialTreasuryBalance = admin.balance;
        
        vm.prank(donorETH);
        donationHandler.receiveEthDonation{value: ETH_DONATION_AMOUNT}();
        
        // Check ETH was received by treasury
        assertEq(admin.balance, initialTreasuryBalance + ETH_DONATION_AMOUNT);
        
        // Check tokens were minted (rate: 1 VERT per USD, ETH = $3000, so 3000 VERT per ETH)
        uint256 expectedTokens = 3000e18; // 3000 VERT tokens (18 decimals - now properly converted)
        assertEq(vertToken.balanceOf(donorETH), initialBalance + expectedTokens);
        
        // Log the actual balance to verify the decimal precision
        console.log("Donor VERT balance:", vertToken.balanceOf(donorETH));
        console.log("Expected tokens:", expectedTokens);
        console.log("Balance as VERT (18 decimals):", vertToken.balanceOf(donorETH) / 1e18);
        
        console.log("ETH donation successful. Tokens minted:", expectedTokens);
    }
    
    function testReceiveUsdcDonation() public {
        uint256 initialBalance = vertToken.balanceOf(donorUSDC);
        
        vm.startPrank(donorUSDC);
        usdcToken.approve(address(donationHandler), USDC_DONATION_AMOUNT);
        donationHandler.receiveUsdcDonation(USDC_DONATION_AMOUNT);
        vm.stopPrank();
        
        // Check USDC was received by treasury
        assertEq(usdcToken.balanceOf(admin), STARTING_USDC_BALANCE + USDC_DONATION_AMOUNT);
        
        // Check tokens were minted (rate: 1 VERT per USD, USDC = $1, so 1000 VERT for 1000 USDC)
        uint256 expectedTokens = 1000e18; // 1000 VERT tokens (18 decimals)
        assertEq(vertToken.balanceOf(donorUSDC), initialBalance + expectedTokens);
        
        // Log the actual balance to verify the decimal precision
        console.log("Donor VERT balance:", vertToken.balanceOf(donorUSDC));
        console.log("Expected tokens:", expectedTokens);
        console.log("Balance as VERT (18 decimals):", vertToken.balanceOf(donorUSDC) / 1e18);
        console.log("USDC donation successful");
    }

    function testReceivePaxgDonation() public {
        uint256 initialBalance = vertToken.balanceOf(donorPAXG);
        
        vm.startPrank(donorPAXG);
        paxgToken.approve(address(donationHandler), PAXG_DONATION_AMOUNT);
        donationHandler.receivePaxgDonation(PAXG_DONATION_AMOUNT);
        vm.stopPrank();
        
        // Check PAXG was received by treasury
        assertEq(paxgToken.balanceOf(admin), PAXG_DONATION_AMOUNT);
        
        // Check tokens were minted (rate: 1 VERT per USD, PAXG = $2000, so 20000 VERT for 10 PAXG)
        uint256 expectedTokens = 20000e18; // 20000 VERT tokens (18 decimals)
        assertEq(vertToken.balanceOf(donorPAXG), initialBalance + expectedTokens);
        
        // Log the actual balance to verify the decimal precision
        console.log("Donor VERT balance:", vertToken.balanceOf(donorPAXG));
        console.log("Expected tokens:", expectedTokens);
        console.log("Balance as VERT (18 decimals):", vertToken.balanceOf(donorPAXG) / 1e18);
        console.log("PAXG donation successful");
    }

    /* -------------------------------------------------------------------------- */
    /*                        COFFEE INVENTORY TESTS                             */
    /* -------------------------------------------------------------------------- */
    
    function testCreateCoffeeBatch() public {
        string memory ipfsUri = "ipfs://QmTestHash";
        uint256 productionDate = block.timestamp;
        uint256 expiryDate = block.timestamp + 365 days;
        uint256 quantity = 1000; // 1000 kg
        uint256 pricePerKg = 8e6; // $8 per kg (6 decimals)
        uint256 loanValue = 5000e6; // $5000 USDC loan
        string memory cooperativeName = "Bamendakwe Cooperative";
        string memory location = "Cameroon";
        string memory certifications = "Organic, Fair Trade";
        uint256 farmersCount = 50;
        
        vm.prank(admin);
        uint256 batchId = coffeeInventoryToken.createBatch(
            ipfsUri,
            productionDate,
            expiryDate,
            quantity,
            pricePerKg,
            loanValue,
            cooperativeName,
            location,
            cooperative, // payment address
            certifications,
            farmersCount
        );
        
        assertEq(batchId, 1);
        assertTrue(coffeeInventoryToken.batchExists(batchId));
        
        // Check batch info
        (
            uint256 retrievedProductionDate,
            uint256 retrievedExpiryDate,
            uint256 currentQuantity,
            uint256 retrievedPricePerKg,
            uint256 retrievedLoanValue,
            bool isVerified,
            , // bool isMetadataVerified - not used in this test
            , // string memory packagingInfo - not used in this test
            , // string memory metadataHash - not used in this test
              // uint256 lastVerifiedTimestamp - not used in this test
        ) = coffeeInventoryToken.batchInfo(batchId);
        
        assertEq(retrievedProductionDate, productionDate);
        assertEq(retrievedExpiryDate, expiryDate);
        assertEq(currentQuantity, quantity);
        assertEq(retrievedPricePerKg, pricePerKg);
        assertEq(retrievedLoanValue, loanValue);
        assertFalse(isVerified);
        
        console.log("Coffee batch created successfully with ID:", batchId);
    }

    /* -------------------------------------------------------------------------- */
    /*                        COOPERATIVE LOAN TESTS                             */
    /* -------------------------------------------------------------------------- */
    
    function testCreateAndDisburseLoan() public {
        // First create a coffee batch as collateral
        vm.prank(admin);
        uint256 batchId = coffeeInventoryToken.createBatch(
            "ipfs://QmTestHash",
            block.timestamp,
            block.timestamp + 365 days,
            1000, // 1000 kg
            8e6, // $8 per kg
            5000e6, // $5000 loan value
            "Test Cooperative",
            "Test Location",
            cooperative,
            "Organic",
            50
        );
        
        // Create array of batch IDs for collateral
        uint256[] memory batchIds = new uint256[](1);
        batchIds[0] = batchId;
        
        // Fund admin's USDC balance for loan disbursement
        usdcToken.mint(admin, 10000e6);
        
        // Create loan
        vm.prank(admin);
        uint256 loanId = loanManager.createLoan(
            cooperative,
            5000e6, // $5000 USDC
            365, // 1 year
            800, // 8% APR
            batchIds,
            "Coffee production financing",
            "Test Cooperative",
            "Test Location"
        );
        
        assertEq(loanId, 1);
        
        // Check loan was created correctly using getLoan function
        CooperativeLoanManager.LoanInfo memory loanInfo = loanManager.getLoan(loanId);
        
        assertEq(loanInfo.cooperative, cooperative);
        assertEq(loanInfo.amount, 5000e6);
        assertEq(loanInfo.disbursedAmount, 0); // Not disbursed yet
        assertEq(loanInfo.interestRate, 800);
        assertEq(loanInfo.batchIds.length, 1);
        assertEq(loanInfo.batchIds[0], batchId);
        
        // Approve USDC for loan disbursement
        vm.prank(admin);
        usdcToken.approve(address(loanManager), 5000e6);
        
        // Disburse loan
        vm.prank(admin);
        loanManager.disburseLoan(loanId);
        
        // Check loan was disbursed
        CooperativeLoanManager.LoanInfo memory updatedLoanInfo = loanManager.getLoan(loanId);
        assertEq(updatedLoanInfo.disbursedAmount, 5000e6);
        
        // Check cooperative received USDC
        assertEq(usdcToken.balanceOf(cooperative), 5000e6);
        
        console.log("Loan created and disbursed successfully");
    }

    /* -------------------------------------------------------------------------- */
    /*                           GOVERNANCE TESTS                                */
    /* -------------------------------------------------------------------------- */
    
    function testCreateProposal() public {
        // Give proposer enough tokens for proposal threshold
        vm.prank(admin);
        vertToken.mint(proposer, 2_000_000e18); // 2M tokens (threshold is 1M)
        
        vm.prank(proposer);
        vertToken.delegate(proposer);
        
        // Advance block number to make voting power active
        vm.roll(block.number + 1);
        
        // Verify proposer has enough voting power
        uint256 votingPower = vertToken.getVotes(proposer);
        uint256 proposalThreshold = governor.proposalThreshold();
        assertTrue(votingPower >= proposalThreshold, "Proposer should have enough voting power");
        
        // Create a simple proposal
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        
        targets[0] = makeAddr("recipient");
        values[0] = 1 ether;
        calldatas[0] = "";
        
        string memory description = "Transfer 1 ETH to development fund";
        
        vm.prank(proposer);
        uint256 proposalId = governor.propose(targets, values, calldatas, description);
        
        assertTrue(proposalId > 0);
        console.log("Proposal created with ID:", proposalId);
        console.log("Proposer voting power:", votingPower);
        console.log("Required threshold:", proposalThreshold);
    }

    /* -------------------------------------------------------------------------- */
    /*                          INTEGRATION TESTS                                */
    /* -------------------------------------------------------------------------- */
    
    function testCompleteWorkflow() public {
        console.log("=== TESTING COMPLETE WAGA DAO WORKFLOW ===");
        
        // 1. Multiple donations to build treasury
        vm.prank(donorETH);
        donationHandler.receiveEthDonation{value: 5 ether}();
        
        vm.startPrank(donorUSDC);
        usdcToken.approve(address(donationHandler), 10000e6);
        donationHandler.receiveUsdcDonation(10000e6);
        vm.stopPrank();
        
        console.log("1. Donations made to build treasury");
        console.log("   Total VERT supply:", vertToken.totalSupply());
        
        // 2. Create coffee batch inventory
        vm.prank(admin);
        uint256 batchId = coffeeInventoryToken.createBatch(
            "ipfs://QmRealHash",
            block.timestamp,
            block.timestamp + 365 days,
            2000, // 2000 kg
            10e6, // $10 per kg
            15000e6, // $15000 loan value
            "Bamendakwe Cooperative",
            "Cameroon",
            cooperative,
            "Organic, Fair Trade",
            100
        );
        
        console.log("2. Coffee batch created with ID:", batchId);
        
        // 3. Create and disburse loan
        uint256[] memory batchIds = new uint256[](1);
        batchIds[0] = batchId;
        
        // Fund treasury for loan
        vm.prank(admin);
        usdcToken.approve(address(loanManager), 15000e6);
        
        vm.prank(admin);
        uint256 loanId = loanManager.createLoan(
            cooperative,
            15000e6,
            730, // 2 years
            600, // 6% APR
            batchIds,
            "Regenerative coffee production",
            "Bamendakwe Cooperative",
            "Cameroon"
        );
        
        vm.prank(admin);
        loanManager.disburseLoan(loanId);
        
        console.log("3. Loan created and disbursed with ID:", loanId);
        console.log("   Cooperative USDC balance:", usdcToken.balanceOf(cooperative));
        
        // 4. Verify batch and loan integration
        assertTrue(coffeeInventoryToken.batchExists(batchId));
        assertEq(loanManager.batchToLoan(batchId), loanId);
        
        console.log("4. Integration verified: batch linked to loan");
        
        console.log("=== COMPLETE WORKFLOW SUCCESS ===");
    }
}
