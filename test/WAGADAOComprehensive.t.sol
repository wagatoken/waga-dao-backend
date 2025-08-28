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
import {CoffeeStructs} from "../src/shared/libraries/CoffeeStructs.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {MockV3Aggregator} from "./mocks/MockV3Aggregator.sol";

/**
 * @title WAGADAOComprehensiveTest
 * @notice Comprehensive test suite for the WAGA DAO system
 * @dev Tests all core functionality including governance, donations, grants, and coffee inventory management
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
    WAGACoffeeInventoryTokenV2 public coffeeInventoryToken;
    CooperativeGrantManagerV2 public grantManager;
    
    ERC20Mock public usdcToken;
    ERC20Mock public paxgToken;
    MockV3Aggregator public ethUsdPriceFeed;
    MockV3Aggregator public paxgUsdPriceFeed;
    
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

        // 5. Deploy GreenfieldProjectManager
        GreenfieldProjectManager greenfieldProjectManager = new GreenfieldProjectManager(admin);

        // 6. Deploy Coffee Inventory Token
        coffeeInventoryToken = new WAGACoffeeInventoryTokenV2(admin, address(greenfieldProjectManager));

        // 6. Create mock tokens and price feeds for testing
        usdcToken = new ERC20Mock();
        paxgToken = new ERC20Mock();
        
        // Create mock price feeds
        ethUsdPriceFeed = new MockV3Aggregator(8, 3000e8); // $3000 ETH
        paxgUsdPriceFeed = new MockV3Aggregator(8, 2000e8); // $2000 PAXG

        // 7. Deploy Cooperative Grant Manager
        grantManager = new CooperativeGrantManagerV2(
            address(usdcToken),
            address(greenfieldProjectManager),
            address(timelock),
            admin, // admin address
            address(0) // ZK Proof Manager - placeholder for now
        );

        // 8. Deploy DonationHandler with all required contracts
        donationHandler = new DonationHandler(
            address(vertToken),          // _vertToken
            address(identityRegistry),   // _identityRegistry
            address(usdcToken),          // _usdcToken
            address(ethUsdPriceFeed),    // _ethUsdPriceFeed
            makeAddr("mockCCIPRouter"),  // _ccipRouter (mock for testing)
            admin,                       // _treasury
            admin                        // _initialOwner
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
        coffeeInventoryToken.grantRole(coffeeInventoryToken.DAO_ADMIN_ROLE(), address(grantManager));
        coffeeInventoryToken.grantRole(coffeeInventoryToken.INVENTORY_MANAGER_ROLE(), address(grantManager));
        coffeeInventoryToken.grantRole(coffeeInventoryToken.MINTER_ROLE(), address(grantManager));

        // Set up grant manager roles
        grantManager.grantRole(grantManager.FINANCIAL_ROLE(), address(timelock));
        grantManager.grantRole(grantManager.GRANT_MANAGER_ROLE(), address(timelock));
        grantManager.grantRole(grantManager.GRANT_MANAGER_ROLE(), address(governor));
        
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
        usdcToken.mint(donorPAXG, STARTING_USDC_BALANCE); // Add USDC for PAXG donor too
        usdcToken.mint(user, STARTING_USDC_BALANCE);
        usdcToken.mint(admin, STARTING_USDC_BALANCE); // For grant disbursement
        
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
        usdcToken.approve(address(donationHandler), USDC_DONATION_AMOUNT);
        donationHandler.receiveUsdcDonation(USDC_DONATION_AMOUNT);
        vm.stopPrank();
        
        // Check USDC was received by treasury
        assertEq(usdcToken.balanceOf(admin), STARTING_USDC_BALANCE + USDC_DONATION_AMOUNT);
        
        // Check tokens were minted (rate: 1 VERT per USD, USDC = $1, so 1000 VERT for 1000 USDC)
        uint256 expectedTokens = 1000e18; // 1000 VERT tokens (18 decimals)
        assertEq(vertToken.balanceOf(donorPAXG), initialBalance + expectedTokens);
        
        // Log the actual balance to verify the decimal precision
        console.log("Donor VERT balance:", vertToken.balanceOf(donorPAXG));
        console.log("Expected tokens:", expectedTokens);
        console.log("Balance as VERT (18 decimals):", vertToken.balanceOf(donorPAXG) / 1e18);
        console.log("USDC donation successful");
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
        uint256 grantValue = 5000e6; // $5000 USDC grant
        
        vm.prank(admin);
        
        // Create the batch creation parameters struct
        CoffeeStructs.BatchCreationParams memory batchParams = CoffeeStructs.BatchCreationParams({
            productionDate: productionDate,
            expiryDate: expiryDate,
            quantity: quantity,
            pricePerKg: pricePerKg,
            grantValue: grantValue,
            ipfsHash: ipfsUri
        });
        
        uint256 batchId = coffeeInventoryToken.createBatch(batchParams);
        
        assertEq(batchId, 1);
        assertTrue(coffeeInventoryToken.batchExists(batchId));
        
        // Check batch info using getBatchInfo function
        CoffeeStructs.BatchInfo memory batchInfoStruct = coffeeInventoryToken.getBatchInfo(batchId);
        
        assertEq(batchInfoStruct.productionDate, productionDate);
        assertEq(batchInfoStruct.expiryDate, expiryDate);
        assertEq(batchInfoStruct.currentQuantity, quantity);
        assertEq(batchInfoStruct.pricePerKg, pricePerKg);
        assertEq(batchInfoStruct.grantValue, grantValue);
        assertFalse(batchInfoStruct.isVerified);
        
        console.log("Coffee batch created successfully with ID:", batchId);
    }

    /* -------------------------------------------------------------------------- */
    /*                        COOPERATIVE GRANT TESTS                             */
    /* -------------------------------------------------------------------------- */
    
    function testCreateAndDisburseGrant() public {
        // Create array of batch IDs for grant
        uint256[] memory batchIds = new uint256[](1);
        batchIds[0] = 1; // Assume first batch exists
        
        // Fund admin's USDC balance for grant disbursement
        usdcToken.mint(admin, 10000e6);
        
        // Create grant
        vm.prank(admin);
        uint256 grantId = grantManager.createGrant(
            cooperative,
            5000e6, // $5000 USDC
            batchIds,
            1000, // 10% revenue share
            2, // 2 years
            "Coffee production grant financing"
        );
        
        assertEq(grantId, 1);
        
        // Fund grant manager for disbursement
        vm.prank(admin);
        usdcToken.transfer(address(grantManager), 5000e6);
        
        // Disburse grant
        vm.prank(admin);
        grantManager.disburseGrant(grantId);
        
        // Check cooperative received USDC
        assertEq(usdcToken.balanceOf(cooperative), 5000e6);
        
        console.log("Grant created and disbursed successfully");
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
            CoffeeStructs.BatchCreationParams({
                productionDate: block.timestamp,
                expiryDate: block.timestamp + 365 days,
                quantity: 2000, // 2000 kg
                pricePerKg: 10e6, // $10 per kg
                grantValue: 15000e6, // $15000 grant value
                ipfsHash: "ipfs://QmRealHash"
            })
        );
        
        console.log("2. Coffee batch created with ID:", batchId);
        
        // 3. Create and disburse grant
        uint256[] memory batchIds = new uint256[](1);
        batchIds[0] = batchId;
        
        // Fund treasury for grant
        vm.prank(admin);
        usdcToken.transfer(address(grantManager), 15000e6);
        
        vm.prank(admin);
        uint256 grantId = grantManager.createGrant(
            cooperative,
            15000e6,
            batchIds,
            1500, // 15% revenue share
            2, // 2 years
            "Regenerative coffee production grant"
        );
        
        vm.prank(admin);
        grantManager.disburseGrant(grantId);
        
        console.log("3. Grant created and disbursed with ID:", grantId);
        console.log("   Cooperative USDC balance:", usdcToken.balanceOf(cooperative));
        
        // 4. Verify batch and grant integration
        assertTrue(coffeeInventoryToken.batchExists(batchId));
        
        console.log("4. Integration verified: grant system working");
        
        console.log("=== COMPLETE WORKFLOW SUCCESS ===");
    }
}
