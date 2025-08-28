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
import {ICooperativeGrantManager} from "../src/shared/interfaces/ICooperativeGrantManager.sol";
import {IWAGACoffeeInventoryToken} from "../src/shared/interfaces/IWAGACoffeeInventoryToken.sol";
import {ICoffeeValueChainProgression} from "../src/shared/interfaces/IDatabaseIntegration.sol";
import {CoffeeStructs} from "../src/shared/libraries/CoffeeStructs.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

/**
 * @title BasicTestV2 - Blockchain-First WAGA DAO Test Suite
 * @notice Tests core functionality with simplified blockchain-first approach
 * @dev Tests the minimal on-chain storage + database integration architecture
 */
contract BasicTestV2 is Test {
    
    // ============ STATE VARIABLES ============
    
    VERTGovernanceToken public vertToken;
    IdentityRegistry public identityRegistry;
    DonationHandler public donationHandler;
    WAGAGovernor public governor;
    WAGATimelock public timelock;
    WAGACoffeeInventoryTokenV2 public coffeeInventoryToken;
    CooperativeGrantManagerV2 public grantManager;
    GreenfieldProjectManager public greenfieldProjectManager;
    HelperConfig public helperConfig;
    
    // Mock tokens for testing
    ERC20Mock public usdcToken;
    
    // Test addresses
    address public admin = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // Default Anvil account
    address public user = makeAddr("user");
    address public cooperative = makeAddr("cooperative");
    address public treasury = makeAddr("treasury");
    
    // ============ SETUP ============
    
    function setUp() public {
        console.log("=== Setting up Blockchain-First WAGA DAO Test ===");
        
        // Get network configuration
        helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfigByChainId(block.chainid);
        
        // Use mock USDC for testing
        usdcToken = new ERC20Mock();
        
        // 1. Deploy IdentityRegistry (no dependencies)
        identityRegistry = new IdentityRegistry(admin);
        
        // 2. Deploy VERT Token
        vertToken = new VERTGovernanceToken(
            address(identityRegistry),
            admin
        );
        
        // 3. Deploy Timelock
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
        
        // 4. Deploy Governor
        governor = new WAGAGovernor(vertToken, timelock);
        
        // 5. Deploy GreenfieldProjectManager
        greenfieldProjectManager = new GreenfieldProjectManager(admin);
        
        // 6. Deploy Coffee Inventory Token
        coffeeInventoryToken = new WAGACoffeeInventoryTokenV2(
            admin,
            address(greenfieldProjectManager)
        );
        
        // 7. Deploy Grant Manager
        grantManager = new CooperativeGrantManagerV2(
            address(usdcToken),
            address(greenfieldProjectManager),
            address(timelock),
            admin,
            address(0) // ZK Proof Manager - placeholder for now
        );
        
        // 8. Deploy Donation Handler
        donationHandler = new DonationHandler(
            address(vertToken),
            address(identityRegistry),
            address(usdcToken),
            config.ethUsdPriceFeed,
            config.ccipRouter,
            treasury,
            admin
        );
        
        // 9. Setup roles and permissions
        vm.startPrank(admin);
        _setupRoles();
        vm.stopPrank();
        
        // 10. Fund test accounts
        vm.deal(user, 10 ether);
        usdcToken.mint(admin, 1_000_000e6); // 1M USDC for grants
        usdcToken.mint(address(grantManager), 1_000_000e6); // Fund grant manager
    }
    
    // ============ ROLE SETUP ============
    
    function _setupRoles() internal {
        // VERT Token roles
        vertToken.grantRole(vertToken.MINTER_ROLE(), address(donationHandler));
        
        // Timelock roles for governance
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(governor));
        timelock.revokeRole(timelock.PROPOSER_ROLE(), admin);
        timelock.revokeRole(timelock.EXECUTOR_ROLE(), admin);
        
        // Coffee Inventory Token roles
        coffeeInventoryToken.grantRole(coffeeInventoryToken.DAO_ADMIN_ROLE(), address(grantManager));
        coffeeInventoryToken.grantRole(coffeeInventoryToken.INVENTORY_MANAGER_ROLE(), address(grantManager));
        coffeeInventoryToken.grantRole(coffeeInventoryToken.MINTER_ROLE(), address(grantManager));
        
        // Greenfield Project Manager roles
        greenfieldProjectManager.grantRole(greenfieldProjectManager.PROJECT_MANAGER_ROLE(), address(coffeeInventoryToken));
        greenfieldProjectManager.grantRole(greenfieldProjectManager.PROJECT_MANAGER_ROLE(), address(grantManager));
        
        // Grant Manager roles
        grantManager.grantRole(grantManager.FINANCIAL_ROLE(), address(timelock));
        grantManager.grantRole(grantManager.GRANT_MANAGER_ROLE(), address(timelock));
        grantManager.grantRole(grantManager.GRANT_MANAGER_ROLE(), address(governor));
        
        // Grant MINTER_ROLE to test users for coffee token operations
        coffeeInventoryToken.grantRole(coffeeInventoryToken.MINTER_ROLE(), admin);
        coffeeInventoryToken.grantRole(coffeeInventoryToken.MINTER_ROLE(), address(this));
        
        // Grant DAO_ADMIN_ROLE for createBatch operations
        coffeeInventoryToken.grantRole(coffeeInventoryToken.DAO_ADMIN_ROLE(), admin);
        coffeeInventoryToken.grantRole(coffeeInventoryToken.DAO_ADMIN_ROLE(), address(this));
        
        // Grant GRANT_MANAGER_ROLE to test accounts
        grantManager.grantRole(grantManager.GRANT_MANAGER_ROLE(), admin);
        grantManager.grantRole(grantManager.GRANT_MANAGER_ROLE(), address(this));
    }
    
    // ============ BASIC DEPLOYMENT TESTS ============
    
    function testDeployment() public view {
        // Test that all contracts were deployed correctly
        assertTrue(address(vertToken) != address(0), "VERT token not deployed");
        assertTrue(address(identityRegistry) != address(0), "Identity registry not deployed");
        assertTrue(address(donationHandler) != address(0), "Donation handler not deployed");
        assertTrue(address(governor) != address(0), "Governor not deployed");
        assertTrue(address(timelock) != address(0), "Timelock not deployed");
        assertTrue(address(coffeeInventoryToken) != address(0), "Coffee inventory token not deployed");
        assertTrue(address(grantManager) != address(0), "Grant manager not deployed");
        assertTrue(address(greenfieldProjectManager) != address(0), "Greenfield manager not deployed");
        
        // Test contract properties
        assertEq(vertToken.name(), "WAGA Vertical Integration Token");
        assertEq(vertToken.symbol(), "VERT");
        assertEq(vertToken.decimals(), 18);
        
        console.log("All contracts deployed successfully");
        console.log("Token properties verified");
    }
    
    function testGovernanceParameters() public view {
        // Test governance configuration
        assertEq(governor.proposalThreshold(), 100_000e18, "Wrong proposal threshold");
        assertEq(governor.votingDelay(), 7_200, "Wrong voting delay"); // 1 day in blocks
        assertEq(governor.votingPeriod(), 50_400, "Wrong voting period"); // 7 days in blocks
        assertEq(timelock.getMinDelaySeconds(), 2 days, "Wrong timelock delay");
        
        console.log("Governance parameters configured correctly");
    }
    
    // ============ IDENTITY & DONATION WORKFLOW ============
    
    function testBasicWorkflow() public {
        // 1. Register user identity
        vm.prank(admin);
        identityRegistry.registerIdentity(user);
        assertTrue(identityRegistry.isVerified(user), "User not verified");
        
        // 2. Make ETH donation
        uint256 treasuryBalanceBefore = treasury.balance;
        vm.prank(user);
        donationHandler.receiveEthDonation{value: 1 ether}();
        
        // Verify tokens minted and ETH sent to treasury
        assertGt(vertToken.balanceOf(user), 0, "No VERT tokens minted");
        assertEq(treasury.balance, treasuryBalanceBefore + 1 ether, "ETH not sent to treasury");
        
        // 3. Delegate votes to self
        vm.prank(user);
        vertToken.delegate(user);
        assertGt(vertToken.getVotes(user), 0, "No voting power delegated");
        
        console.log("Basic workflow completed");
        console.log("  - User VERT balance:", vertToken.balanceOf(user));
        console.log("  - User voting power:", vertToken.getVotes(user));
    }
    
    // ============ COFFEE BATCH CREATION (BLOCKCHAIN-FIRST) ============
    
    function testCreateCoffeeBatch() public {
        console.log("Starting batch creation test");
        
        // Create simplified batch parameters (blockchain-first approach)
        uint256 currentTime = block.timestamp;
        console.log("Current timestamp:", currentTime);
        
        CoffeeStructs.BatchCreationParams memory params = CoffeeStructs.BatchCreationParams({
            productionDate: currentTime,
            expiryDate: currentTime + 365 days,
            quantity: 1000, // 1000 kg
            pricePerKg: 8e6, // $8 per kg (6 decimals)
            grantValue: 50000e6, // $50,000 grant (6 decimals)
            ipfsHash: "QmTestCoffeeBatch123" // Rich metadata in IPFS
        });
        
        console.log("Batch params created");
        console.log("Calling createBatch...");
        
        // Create batch (only admin can mint)
        vm.prank(admin);
        uint256 batchId = coffeeInventoryToken.createBatch(params);
        
        // Verify batch creation
        assertTrue(coffeeInventoryToken.batchExists(batchId), "Batch not created");
        assertEq(batchId, 1, "Wrong batch ID");
        
        // Get batch info and verify
        CoffeeStructs.BatchInfo memory batchInfo = coffeeInventoryToken.getBatchInfo(batchId);
        assertEq(batchInfo.currentQuantity, 1000, "Wrong quantity");
        assertEq(batchInfo.pricePerKg, 8_000_000, "Wrong price");
        assertEq(batchInfo.grantValue, 50_000_000_000, "Wrong grant value");
        assertEq(batchInfo.metadataHash, "QmTestCoffeeBatch123", "Wrong IPFS hash");
        assertFalse(batchInfo.isVerified, "Batch should not be verified initially");
        
        console.log("Coffee batch created successfully");
        console.log("  - Batch ID:", batchId);
        console.log("  - Quantity:", batchInfo.currentQuantity, "kg");
        console.log("  - Price per kg:", batchInfo.pricePerKg / 1e6, "USD");
    }
    
    // ============ GREENFIELD PROJECT CREATION ============
    
    function testCreateGreenfieldProject() public {
        // Create greenfield project with minimal on-chain data
        string memory ipfsHash = "QmGreenfieldProject456";
        uint256 plantingDate = block.timestamp + 30 days;
        uint256 maturityDate = block.timestamp + 4 * 365 days;
        uint256 projectedYield = 25_000; // 25,000 kg annually
        uint256 grantValue = 100_000_000_000; // $100,000 grant
        
        vm.prank(admin);
        uint256 projectId = coffeeInventoryToken.createGreenfieldProject(
            ipfsHash,
            plantingDate,
            maturityDate,
            projectedYield,
            grantValue
        );
        
        // Verify project creation
        assertTrue(coffeeInventoryToken.batchExists(projectId), "Project not created");
        
        // Check project details
        (
            bool isGreenfield,
            uint256 returnedPlantingDate,
            uint256 returnedMaturityDate,
            uint256 returnedProjectedYield,
            uint256 investmentStage
        ) = coffeeInventoryToken.getGreenfieldProjectDetails(projectId);
        
        assertTrue(isGreenfield, "Not marked as greenfield");
        assertEq(returnedPlantingDate, plantingDate, "Wrong planting date");
        assertEq(returnedMaturityDate, maturityDate, "Wrong maturity date");
        assertEq(returnedProjectedYield, projectedYield, "Wrong projected yield");
        assertEq(investmentStage, 0, "Wrong initial stage");
        
        console.log("Greenfield project created successfully");
        console.log("  - Project ID:", projectId);
        console.log("  - Projected annual yield:", projectedYield, "kg");
        console.log("  - Years to maturity:", (maturityDate - plantingDate) / 365 days);
    }
    
    // ============ GRANT CREATION ============
    
    function testCreateGreenfieldGrant() public {
        // Grant parameters
        uint256 amount = 75_000e6; // $75,000 USDC
        uint256 revenueSharePercentage = 2500; // 25%
        uint256 durationYears = 5;
        string memory ipfsHash = "QmGreenfieldGrant789";
        uint256 plantingDate = block.timestamp + 60 days;
        uint256 maturityDate = block.timestamp + 5 * 365 days;
        uint256 projectedYield = 30_000; // 30,000 kg annually
        string memory cooperativeName = "Test Cooperative Brazil";
        
        // Create greenfield grant (combines grant + project creation)
        vm.prank(admin);
        (uint256 grantId, uint256 projectId) = grantManager.createGreenfieldGrant(
            cooperative,
            amount,
            revenueSharePercentage,
            durationYears,
            ipfsHash,
            plantingDate,
            maturityDate,
            projectedYield,
            cooperativeName
        );
        
        // Verify grant creation
        assertGt(grantId, 0, "Grant not created");
        assertGt(projectId, 0, "Project not created");
        
        // Check grant details
        ICooperativeGrantManager.GrantInfo memory grantInfo = grantManager.getGrant(grantId);
        assertEq(grantInfo.cooperative, cooperative, "Wrong cooperative");
        assertEq(grantInfo.amount, amount, "Wrong grant amount");
        assertEq(grantInfo.revenueSharePercent, revenueSharePercentage, "Wrong revenue share");
        assertTrue(grantInfo.isGreenfield, "Not marked as greenfield");
        assertEq(grantInfo.greenfieldProjectId, projectId, "Wrong project ID");
        
        // Verify project was created in greenfield manager
        assertTrue(greenfieldProjectManager.projectExists(projectId), "Project not created in greenfield manager");
        
        console.log("Greenfield grant created successfully");
        console.log("  - Grant ID:", grantId);
        console.log("  - Project ID:", projectId);
        console.log("  - Grant amount:", amount / 1e6, "USDC");
        console.log("  - Revenue share:", revenueSharePercentage / 100, "%");
    }
    
    // ============ COFFEE ROASTING (DUAL TOKENIZATION) ============
    
    function testCoffeeRoasting() public {
        // First create a green coffee batch
        uint256 currentTime = block.timestamp;
        CoffeeStructs.BatchCreationParams memory greenParams = CoffeeStructs.BatchCreationParams({
            productionDate: currentTime,
            expiryDate: currentTime + 365 days,
            quantity: 1000, // 1000 kg green coffee
            pricePerKg: 6e6, // $6 per kg (6 decimals)
            grantValue: 30000e6, // $30,000 grant (6 decimals)
            ipfsHash: "QmGreenCoffeeBatch"
        });
        
        vm.prank(admin);
        uint256 greenBatchId = coffeeInventoryToken.createBatch(greenParams);
        
        // Now roast the coffee (creates new roasted batch)
        uint256 greenQuantity = 800; // Use 800kg of green coffee
        uint256 roastedQuantity = 640; // Results in 640kg roasted (20% weight loss)
        string memory roastProfile = "Medium Roast - City+";
        
        // Create roasting parameters
        ICoffeeValueChainProgression.RoastingParams memory roastingParams = ICoffeeValueChainProgression.RoastingParams({
            inputQuantity: greenQuantity,
            expectedOutputQuantity: roastedQuantity,
            roastProfile: roastProfile,
            roasterAddress: admin,
            roastingNotes: "Basic test roasting",
            roastingDate: block.timestamp
        });
        
        vm.prank(admin);
        uint256 roastedBatchId = coffeeInventoryToken.progressToRoastedBeans(
            greenBatchId,
            roastingParams
        );
        
        // Verify roasted batch creation
        assertTrue(coffeeInventoryToken.batchExists(roastedBatchId), "Roasted batch not created");
        assertGt(roastedBatchId, greenBatchId, "Roasted batch ID should be higher");
        
        // Check that green batch quantity was reduced
        CoffeeStructs.BatchInfo memory greenBatchInfo = coffeeInventoryToken.getBatchInfo(greenBatchId);
        assertEq(greenBatchInfo.currentQuantity, 200, "Green batch quantity not reduced"); // 1000 - 800 = 200
        
        // Check roasted batch details
        CoffeeStructs.BatchInfo memory roastedBatchInfo = coffeeInventoryToken.getBatchInfo(roastedBatchId);
        assertEq(roastedBatchInfo.currentQuantity, roastedQuantity, "Wrong roasted quantity");
        assertEq(uint256(roastedBatchInfo.tokenType), uint256(CoffeeStructs.TokenType.ROASTED_BEANS), "Wrong token type");
        
        console.log("Coffee roasting completed successfully");
        console.log("  - Green batch ID:", greenBatchId);
        console.log("  - Roasted batch ID:", roastedBatchId);
        console.log("  - Weight loss:", ((greenQuantity - roastedQuantity) * 100) / greenQuantity, "%");
    }
    
    // ============ ACCESS CONTROL TESTS ============
    
    function testAccessControl() public {
        // Test that unauthorized users cannot create batches
        CoffeeStructs.BatchCreationParams memory params = CoffeeStructs.BatchCreationParams({
            productionDate: block.timestamp,
            expiryDate: block.timestamp + 365 days,
            quantity: 1000,
            pricePerKg: 8_000_000,
            grantValue: 50_000_000_000,
            ipfsHash: "QmUnauthorizedBatch"
        });
        
        vm.prank(user);
        vm.expectRevert();
        coffeeInventoryToken.createBatch(params);
        
        // Test that unauthorized users cannot create grants
        vm.prank(user);
        vm.expectRevert();
        grantManager.createGreenfieldGrant(
            cooperative,
            50_000e6,
            2000,
            3,
            "QmUnauthorized",
            block.timestamp + 30 days,
            block.timestamp + 3 * 365 days,
            25_000,
            "Unauthorized Coop"
        );
        
        console.log("Access control working correctly");
    }
    
    // ============ ERROR CONDITION TESTS ============
    
    function testErrorConditions() public {
        // Test creating grant with invalid parameters
        vm.startPrank(admin);
        
        // Too small grant amount
        vm.expectRevert();
        grantManager.createGreenfieldGrant(
            cooperative,
            100e6, // Too small (min is 1000 USDC)
            2000,
            3,
            "QmSmallGrant",
            block.timestamp + 30 days,
            block.timestamp + 3 * 365 days,
            25_000,
            "Small Grant Coop"
        );
        
        // Too high revenue share
        vm.expectRevert();
        grantManager.createGreenfieldGrant(
            cooperative,
            50_000e6,
            6000, // Too high (max is 50%)
            3,
            "QmHighShare",
            block.timestamp + 30 days,
            block.timestamp + 3 * 365 days,
            25_000,
            "High Share Coop"
        );
        
        vm.stopPrank();
        
        console.log("Error conditions handled correctly");
    }
}
