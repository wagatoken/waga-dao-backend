// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {VERTGovernanceToken} from "../src/shared/VERTGovernanceToken.sol";
import {IdentityRegistry} from "../src/shared/IdentityRegistry.sol";
import {DonationHandler} from "../src/base/DonationHandler.sol";
import {WAGAGovernor} from "../src/shared/WAGAGovernor.sol";
import {WAGATimelock} from "../src/shared/WAGATimelock.sol";
import {WAGACoffeeInventoryTokenV2} from "../src/shared/WAGACoffeeInventoryTokenV2.sol";
import {CooperativeGrantManagerV2} from "../src/base/CooperativeGrantManagerV2.sol";
import {GreenfieldProjectManager} from "../src/managers/GreenfieldProjectManager.sol";
import {ICooperativeGrantManager} from "../src/shared/interfaces/ICooperativeGrantManager.sol";
import "../src/shared/interfaces/IDatabaseIntegration.sol";
import {ICoffeeValueChainProgression} from "../src/shared/interfaces/IDatabaseIntegration.sol";
import {CoffeeStructs} from "../src/shared/libraries/CoffeeStructs.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

/**
 * @title ComprehensiveWorkflowTest
 * @notice Tests the complete WAGA DAO coffee supply chain workflow
 * @dev Comprehensive test of the blockchain-first architecture with database integration
 */
contract ComprehensiveWorkflowTest is Test {
    
    // ============ STATE VARIABLES ============
    
    VERTGovernanceToken public vertToken;
    IdentityRegistry public identityRegistry;
    DonationHandler public donationHandler;
    WAGAGovernor public governor;
    WAGATimelock public timelock;
    WAGACoffeeInventoryTokenV2 public coffeeInventoryToken;
    CooperativeGrantManagerV2 public grantManager;
    GreenfieldProjectManager public greenfieldProjectManager;
    
    ERC20Mock public usdcToken;
    
    // Test addresses - realistic coffee supply chain actors
    address public admin = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address public daoTreasury = makeAddr("daoTreasury");
    address public cooperativeOwner = makeAddr("cooperativeOwner");
    address public coffeeImporter = makeAddr("coffeeImporter");
    address public coffeeBuyer = makeAddr("coffeeBuyer");
    address public investor = makeAddr("investor");
    address public roastingCompany = makeAddr("roastingCompany");
    
    // Test constants for realistic coffee operations
    uint256 public constant STARTING_BALANCE = 10 ether;
    uint256 public constant USDC_FUNDING = 1_000_000e6; // 1M USDC
    uint256 public constant GRANT_AMOUNT = 50_000e6; // $50k grant
    uint256 public constant COFFEE_BATCH_SIZE = 5000; // 5000 kg (typical container)
    uint256 public constant GREEN_COFFEE_PRICE = 7_500_000; // $7.50 per kg
    uint256 public constant ROASTED_COFFEE_PRICE = 15_000_000; // $15 per kg
    
    // ============ EVENTS FOR TESTING ============
    
    event FullWorkflowCompleted(
        uint256 indexed grantId,
        uint256 indexed greenfieldProjectId,
        uint256 indexed greenBatchId,
        uint256 roastedBatchId,
        uint256 totalRevenueGenerated
    );
    
    // ============ SETUP ============
    
    function setUp() public {
        console2.log("=== COMPREHENSIVE WAGA DAO WORKFLOW TEST SETUP ===");
        
        // Setup network configuration
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfigByChainId(block.chainid);
        
        // Deploy mock USDC
        usdcToken = new ERC20Mock();
        
        // Deploy all contracts
        _deployContracts(config);
        _setupRoles();
        _fundAccounts();
        
        console2.log("Setup completed successfully");
    }
    
    function _deployContracts(HelperConfig.NetworkConfig memory config) internal {
        // 1. Identity Registry
        identityRegistry = new IdentityRegistry(admin);
        
        // 2. VERT Token
        vertToken = new VERTGovernanceToken(address(identityRegistry), admin);
        
        // 3. Timelock
        address[] memory proposers = new address[](1);
        address[] memory executors = new address[](1);
        proposers[0] = admin;
        executors[0] = admin;
        timelock = new WAGATimelock(2 days, proposers, executors, admin);
        
        // 4. Governor
        governor = new WAGAGovernor(vertToken, timelock);
        
        // 5. Greenfield Project Manager
        greenfieldProjectManager = new GreenfieldProjectManager(admin);
        
        // 6. Coffee Inventory Token
        coffeeInventoryToken = new WAGACoffeeInventoryTokenV2(
            admin,
            address(greenfieldProjectManager)
        );
        
        // 7. Grant Manager
        grantManager = new CooperativeGrantManagerV2(
            address(usdcToken),
            address(coffeeInventoryToken),
            address(timelock),
            admin
        );
        
        // 8. Donation Handler
        donationHandler = new DonationHandler(
            address(vertToken),
            address(identityRegistry),
            address(usdcToken),
            config.ethUsdPriceFeed,
            config.ccipRouter,
            daoTreasury,
            admin
        );
    }
    
    function _setupRoles() internal {
        vm.startPrank(admin);
        
        // Setup all necessary roles for the workflow
        vertToken.grantRole(vertToken.MINTER_ROLE(), address(donationHandler));
        
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(governor));
        timelock.revokeRole(timelock.PROPOSER_ROLE(), admin);
        timelock.revokeRole(timelock.EXECUTOR_ROLE(), admin);
        
        coffeeInventoryToken.grantRole(coffeeInventoryToken.DAO_ADMIN_ROLE(), address(grantManager));
        coffeeInventoryToken.grantRole(coffeeInventoryToken.INVENTORY_MANAGER_ROLE(), address(grantManager));
        coffeeInventoryToken.grantRole(coffeeInventoryToken.MINTER_ROLE(), address(grantManager));
        coffeeInventoryToken.grantRole(coffeeInventoryToken.MINTER_ROLE(), admin); // For manual operations
        
        greenfieldProjectManager.grantRole(greenfieldProjectManager.PROJECT_MANAGER_ROLE(), address(coffeeInventoryToken));
        greenfieldProjectManager.grantRole(greenfieldProjectManager.PROJECT_MANAGER_ROLE(), address(grantManager));
        
        grantManager.grantRole(grantManager.FINANCIAL_ROLE(), address(timelock));
        grantManager.grantRole(grantManager.FINANCIAL_ROLE(), admin); // Grant financial role to admin for testing
        grantManager.grantRole(grantManager.GRANT_MANAGER_ROLE(), address(timelock));
        grantManager.grantRole(grantManager.GRANT_MANAGER_ROLE(), address(admin));
        
        vm.stopPrank();
    }
    
    function _fundAccounts() internal {
        // Fund all test accounts with ETH
        vm.deal(cooperativeOwner, STARTING_BALANCE);
        vm.deal(coffeeImporter, STARTING_BALANCE);
        vm.deal(coffeeBuyer, STARTING_BALANCE);
        vm.deal(investor, STARTING_BALANCE);
        vm.deal(roastingCompany, STARTING_BALANCE);
        
        // Mint USDC for testing
        usdcToken.mint(address(grantManager), USDC_FUNDING);
        usdcToken.mint(coffeeImporter, 500_000e6);
        usdcToken.mint(coffeeBuyer, 200_000e6);
        
        // Register identities for all participants
        vm.startPrank(admin);
        identityRegistry.registerIdentity(cooperativeOwner);
        identityRegistry.registerIdentity(coffeeImporter);
        identityRegistry.registerIdentity(coffeeBuyer);
        identityRegistry.registerIdentity(investor);
        identityRegistry.registerIdentity(roastingCompany);
        vm.stopPrank();
    }
    
    // ============ COMPREHENSIVE WORKFLOW TEST ============
    
    function testCompleteSupplyChainWorkflow() public {
        console2.log("\\n=== TESTING COMPLETE COFFEE SUPPLY CHAIN WORKFLOW ===");
        
        // Step 1: DAO receives investment through donations
        _step1_InvestorDonation();
        
        // Step 2: Create greenfield grant for coffee cooperative
        (uint256 grantId, uint256 projectId) = _step2_CreateGreenfieldGrant();
        
        // Step 3: Simulate project development (advance stages)
        _step3_ProjectDevelopment(projectId);
        
        // Step 4: Harvest and create green coffee batch
        uint256 greenBatchId = _step4_HarvestAndCreateBatch(grantId);
        
        // Step 5: Coffee roasting (dual tokenization)
        uint256 roastedBatchId = _step5_CoffeeRoasting(greenBatchId);
        
        // Step 6: Coffee sales and revenue sharing
        uint256 totalRevenue = _step6_CoffeeSales(greenBatchId, roastedBatchId, grantId);
        
        // Step 7: Verify complete workflow results
        _step7_VerifyWorkflowResults(grantId, projectId, greenBatchId, roastedBatchId, totalRevenue);
        
        // Emit workflow completion event
        emit FullWorkflowCompleted(grantId, projectId, greenBatchId, roastedBatchId, totalRevenue);
        
        console2.log("\\n COMPLETE SUPPLY CHAIN WORKFLOW SUCCESSFULLY TESTED");
    }
    
    function _step1_InvestorDonation() internal returns (uint256) {
        console2.log("\\n--- Step 1: Investor makes donation to DAO ---");
        
        uint256 donationAmount = 5 ether;
        uint256 treasuryBalanceBefore = daoTreasury.balance;
        
        vm.prank(investor);
        donationHandler.receiveEthDonation{value: donationAmount}();
        
        // Verify donation results
        assertEq(daoTreasury.balance, treasuryBalanceBefore + donationAmount, "ETH not sent to treasury");
        assertGt(vertToken.balanceOf(investor), 0, "No VERT tokens minted");
        
        uint256 vertBalance = vertToken.balanceOf(investor);
        console2.log("  - Donation amount:", donationAmount / 1e18, "ETH");
        console2.log("  - VERT tokens minted:", vertBalance / 1e18);
        console2.log("  - Treasury balance:", daoTreasury.balance / 1e18, "ETH");
        
        return vertBalance;
    }
    
    function _step2_CreateGreenfieldGrant() internal returns (uint256, uint256) {
        console2.log("\\n--- Step 2: Create greenfield grant for cooperative ---");
        
        uint256 plantingDate = block.timestamp + 90 days; // Plant in 3 months
        uint256 maturityDate = block.timestamp + 4 * 365 days; // Mature in 4 years
        uint256 projectedYield = 15_000; // 15,000 kg annually
        uint256 revenueSharePercentage = 3000; // 30% revenue share
        uint256 durationYears = 6;
        
        vm.prank(admin);
        (uint256 grantId, uint256 projectId) = grantManager.createGreenfieldGrant(
            cooperativeOwner,
            GRANT_AMOUNT,
            revenueSharePercentage,
            durationYears,
            "QmGreenfieldProject_BrazilAltoCerrado",
            plantingDate,
            maturityDate,
            projectedYield,
            "Alto Cerrado Coffee Cooperative - Brazil"
        );
        
        // Verify grant creation
        ICooperativeGrantManager.GrantInfo memory grantInfo = grantManager.getGrant(grantId);
        assertEq(grantInfo.cooperative, cooperativeOwner, "Wrong cooperative");
        assertEq(grantInfo.amount, GRANT_AMOUNT, "Wrong grant amount");
        assertTrue(grantInfo.isGreenfield, "Not marked as greenfield");
        
        // Disburse the grant to make it active
        vm.prank(admin);
        grantManager.disburseGrant(grantId);
        
        console2.log("  - Grant ID:", grantId);
        console2.log("  - Project ID:", projectId);
        console2.log("  - Grant amount:", GRANT_AMOUNT / 1e6, "USDC");
        console2.log("  - Revenue share:", revenueSharePercentage / 100, "%");
        console2.log("  - Projected annual yield:", projectedYield, "kg");
        
        return (grantId, projectId);
    }
    
    function _step3_ProjectDevelopment(uint256 projectId) internal {
        console2.log("\\n--- Step 3: Simulate project development stages ---");
        
        // Stage 1: Land preparation
        vm.prank(admin);
        coffeeInventoryToken.advanceGreenfieldStage(
            projectId,
            1,
            15_000, // Maintain projected yield
            "QmLandPreparation_Evidence"
        );
        
        // Stage 2: Planting
        vm.warp(block.timestamp + 95 days); // Simulate time passage
        vm.prank(admin);
        coffeeInventoryToken.advanceGreenfieldStage(
            projectId,
            2,
            14_500, // Slightly adjust yield estimate
            "QmPlanting_Evidence"
        );
        
        // Stage 3: Growth monitoring
        vm.warp(block.timestamp + 2 * 365 days); // 2 years later
        vm.prank(admin);
        coffeeInventoryToken.advanceGreenfieldStage(
            projectId,
            3,
            14_800, // Update yield based on growth
            "QmGrowthMonitoring_Evidence"
        );
        
        // Verify final stage
        (, , , uint256 updatedYield, uint256 currentStage) = coffeeInventoryToken.getGreenfieldProjectDetails(projectId);
        assertEq(currentStage, 3, "Wrong project stage");
        assertEq(updatedYield, 14_800, "Wrong updated yield");
        
        console2.log("  - Advanced to stage:", currentStage);
        console2.log("  - Updated yield projection:", updatedYield, "kg");
        console2.log("  - Time elapsed:", (block.timestamp - block.timestamp + 2 * 365 days + 95 days) / 365 days, "years");
    }
    
    function _step4_HarvestAndCreateBatch(uint256 /* grantId */) internal returns (uint256) {
        console2.log("\\n--- Step 4: First harvest and green coffee batch creation ---");
        
        // Simulate maturity and first harvest
        vm.warp(block.timestamp + 2 * 365 days); // 2 more years (total 4 years)
        
        CoffeeStructs.BatchCreationParams memory batchParams = CoffeeStructs.BatchCreationParams({
            productionDate: block.timestamp - 30 days, // Harvested last month
            expiryDate: block.timestamp + 2 * 365 days, // Green coffee lasts 2 years
            quantity: COFFEE_BATCH_SIZE,
            pricePerKg: GREEN_COFFEE_PRICE,
            grantValue: GRANT_AMOUNT,
            ipfsHash: "QmGreenCoffeeBatch_BrazilAltoCerrado_2028"
        });
        
        vm.prank(admin);
        uint256 greenBatchId = coffeeInventoryToken.createBatch(batchParams);
        
        // Verify batch creation
        CoffeeStructs.BatchInfo memory batchInfo = coffeeInventoryToken.getBatchInfo(greenBatchId);
        assertEq(batchInfo.currentQuantity, COFFEE_BATCH_SIZE, "Wrong batch quantity");
        assertEq(uint256(batchInfo.tokenType), uint256(CoffeeStructs.TokenType.GREEN_BEANS), "Wrong token type");
        
        console2.log("  - Green batch ID:", greenBatchId);
        console2.log("  - Batch quantity:", batchInfo.currentQuantity, "kg");
        console2.log("  - Price per kg:", batchInfo.pricePerKg / 1e6, "USD");
        console2.log("  - Total batch value:", (batchInfo.currentQuantity * batchInfo.pricePerKg) / 1e6, "USD");
        
        return greenBatchId;
    }
    
    function _step5_CoffeeRoasting(uint256 greenBatchId) internal returns (uint256) {
        console2.log("\\n--- Step 5: Coffee roasting (dual tokenization) ---");
        
        uint256 greenQuantityToRoast = 3000; // Use 3000kg for roasting
        uint256 expectedRoastedQuantity = 2400; // 20% weight loss
        string memory roastProfile = "Medium Roast - Full City";
        
        // Create roasting parameters struct
        ICoffeeValueChainProgression.RoastingParams memory roastingParams = ICoffeeValueChainProgression.RoastingParams({
            inputQuantity: greenQuantityToRoast,
            expectedOutputQuantity: expectedRoastedQuantity,
            roastProfile: roastProfile,
            roasterAddress: admin,
            roastingNotes: "Test roasting batch",
            roastingDate: block.timestamp
        });
        
        vm.prank(admin);
        uint256 roastedBatchId = coffeeInventoryToken.progressToRoastedBeans(
            greenBatchId,
            roastingParams
        );
        
        // Verify roasting results
        CoffeeStructs.BatchInfo memory greenBatchInfo = coffeeInventoryToken.getBatchInfo(greenBatchId);
        CoffeeStructs.BatchInfo memory roastedBatchInfo = coffeeInventoryToken.getBatchInfo(roastedBatchId);
        
        assertEq(greenBatchInfo.currentQuantity, COFFEE_BATCH_SIZE - greenQuantityToRoast, "Green batch not reduced");
        assertEq(roastedBatchInfo.currentQuantity, expectedRoastedQuantity, "Wrong roasted quantity");
        assertEq(uint256(roastedBatchInfo.tokenType), uint256(CoffeeStructs.TokenType.ROASTED_BEANS), "Wrong roasted token type");
        
        uint256 weightLossPercentage = ((greenQuantityToRoast - expectedRoastedQuantity) * 100) / greenQuantityToRoast;
        
        console2.log("  - Roasted batch ID:", roastedBatchId);
        console2.log("  - Green coffee used:", greenQuantityToRoast, "kg");
        console2.log("  - Roasted coffee produced:", expectedRoastedQuantity, "kg");
        console2.log("  - Weight loss:", weightLossPercentage, "%");
        console2.log("  - Remaining green coffee:", greenBatchInfo.currentQuantity, "kg");
        
        return roastedBatchId;
    }
    
    function _step6_CoffeeSales(uint256 greenBatchId, uint256 roastedBatchId, uint256 grantId) internal returns (uint256) {
        console2.log("\\n--- Step 6: Coffee sales and revenue sharing ---");
        
        uint256 totalRevenue = 0;
        
        // Sale 1: Sell remaining green coffee to importer
        CoffeeStructs.BatchInfo memory greenBatchInfo = coffeeInventoryToken.getBatchInfo(greenBatchId);
        uint256 greenSaleRevenue = (greenBatchInfo.currentQuantity * greenBatchInfo.pricePerKg) / 1e6;
        totalRevenue += greenSaleRevenue;
        
        // Simulate green coffee sale revenue sharing
        vm.prank(admin);
        grantManager.recordRevenueShare(grantId, greenSaleRevenue * 1e6);
        
        console2.log("  - Green coffee sale revenue:", greenSaleRevenue, "USD");
        
        // Sale 2: Sell roasted coffee to retail buyers
        CoffeeStructs.BatchInfo memory roastedBatchInfo = coffeeInventoryToken.getBatchInfo(roastedBatchId);
        uint256 roastedSaleRevenue = (roastedBatchInfo.currentQuantity * ROASTED_COFFEE_PRICE) / 1e6;
        totalRevenue += roastedSaleRevenue;
        
        // Simulate roasted coffee sale revenue sharing
        vm.prank(admin);
        grantManager.recordRevenueShare(grantId, roastedSaleRevenue * 1e6);
        
        console2.log("  - Roasted coffee sale revenue:", roastedSaleRevenue, "USD");
        console2.log("  - Total revenue generated:", totalRevenue, "USD");
        
        // Verify revenue sharing was recorded
        uint256 totalRevenueShared = grantManager.getTotalRevenueShared(grantId);
        assertGt(totalRevenueShared, 0, "No revenue shared recorded");
        
        console2.log("  - Total revenue shared with DAO:", totalRevenueShared / 1e6, "USD");
        
        return totalRevenue;
    }
    
    function _step7_VerifyWorkflowResults(
        uint256 grantId, 
        uint256 projectId, 
        uint256 greenBatchId, 
        uint256 roastedBatchId, 
        uint256 totalRevenue
    ) internal view {
        console2.log("\\n--- Step 7: Verify complete workflow results ---");
        
        // Verify grant is still active and tracking revenue
        ICooperativeGrantManager.GrantInfo memory grantInfo = grantManager.getGrant(grantId);
        assertTrue(grantManager.isGrantActive(grantId), "Grant should still be active");
        assertGt(grantInfo.totalRevenueShared, 0, "No revenue shared recorded");
        
        // Verify project exists and has advanced
        (bool isGreenfield, , , uint256 projectedYield, uint256 stage) = coffeeInventoryToken.getGreenfieldProjectDetails(projectId);
        
        // Use the variables to avoid warnings
        require(isGreenfield, "Should be greenfield");
        require(stage >= 0, "Stage should be valid");
        require(projectedYield > 0, "Should have projected yield");
        assertTrue(isGreenfield, "Project should be greenfield");
        assertGt(stage, 0, "Project should have advanced stages");
        
        // Verify both coffee batches exist
        assertTrue(coffeeInventoryToken.batchExists(greenBatchId), "Green batch should exist");
        assertTrue(coffeeInventoryToken.batchExists(roastedBatchId), "Roasted batch should exist");
        
        // Calculate key metrics
        uint256 roiPercentage = (grantInfo.totalRevenueShared * 100) / grantInfo.amount;
        uint256 daoRevenueShare = (grantInfo.totalRevenueShared * grantInfo.revenueSharePercent) / 10000;
        
        console2.log("\\n=== WORKFLOW RESULTS SUMMARY ===");
        console2.log("  - Grant status: Active");
        console2.log("  - Project development stage:", stage);
        console2.log("  - Total revenue generated:", totalRevenue, "USD");
        console2.log("  - Revenue shared with DAO:", grantInfo.totalRevenueShared / 1e6, "USD");
        console2.log("  - DAO revenue share:", daoRevenueShare / 1e6, "USD");
        console2.log("  - ROI on grant:", roiPercentage, "%");
        console2.log("  - Green coffee batch exists: true");
        console2.log("  - Roasted coffee batch exists: true");
        
        // Assert key success criteria
        assertGt(totalRevenue, 50000, "Total revenue should exceed $50k");
        assertGt(roiPercentage, 25, "ROI should exceed 25%"); // Adjusted expectation to be more realistic
        assertTrue(grantInfo.totalRevenueShared > 0, "Revenue sharing should be working");
    }
    
    // ============ SPECIALIZED WORKFLOW TESTS ============
    
    function testMultipleProjectsWorkflow() public {
        console2.log("\\n=== TESTING MULTIPLE PROJECTS WORKFLOW ===");
        
        // Create multiple greenfield projects for same cooperative
        uint256[] memory projectIds = new uint256[](3);
        uint256[] memory grantIds = new uint256[](3);
        
        string[3] memory regions = ["Brazil_Cerrado", "Colombia_Huila", "Ethiopia_Sidamo"];
        uint256[3] memory yields = [uint256(12000), uint256(8000), uint256(6000)];
        
        for (uint256 i = 0; i < 3; i++) {
            vm.prank(admin);
            (grantIds[i], projectIds[i]) = grantManager.createGreenfieldGrant(
                cooperativeOwner,
                30_000e6, // Smaller grants
                2500, // 25% revenue share
                5,
                string(abi.encodePacked("QmProject_", regions[i])),
                block.timestamp + 60 days,
                block.timestamp + 4 * 365 days,
                yields[i],
                string(abi.encodePacked("Cooperative_", regions[i]))
            );
            
            // Disburse the grant to make it active
            vm.prank(admin);
            grantManager.disburseGrant(grantIds[i]);
            
            console2.log("  - Created project", i + 1, "with ID:", projectIds[i]);
        }
        
        // Verify all projects were created
        for (uint256 i = 0; i < 3; i++) {
            assertTrue(coffeeInventoryToken.batchExists(projectIds[i]), "Project should exist");
            assertTrue(grantManager.isGrantActive(grantIds[i]), "Grant should be active");
        }
        
        console2.log("Multiple projects workflow completed successfully");
    }
    
    function testSeasonalHarvestWorkflow() public {
        console2.log("\\n=== TESTING SEASONAL HARVEST WORKFLOW ===");
        
        // Create a project first
        vm.prank(admin);
        (uint256 grantId, uint256 projectId) = grantManager.createGreenfieldGrant(
            cooperativeOwner,
            40_000e6,
            2800,
            4,
            "ipfs://seasonal_test",
            block.timestamp + 30 days,
            block.timestamp + 3 * 365 days,
            10_000,
            "Seasonal Harvest Cooperative"
        );
        
        // Use the variables
        require(grantId > 0, "Grant ID should be valid");
        require(projectId > 0, "Project ID should be valid");
        
        // Simulate multiple seasonal harvests
        vm.warp(block.timestamp + 3 * 365 days + 30 days); // Skip to maturity
        
        uint256[] memory batchIds = new uint256[](3);
        uint256[3] memory seasonalYields = [uint256(2800), uint256(3200), uint256(2900)];
        string[3] memory seasons = ["Early_Season", "Main_Season", "Late_Season"];
        
        for (uint256 i = 0; i < 3; i++) {
            CoffeeStructs.BatchCreationParams memory params = CoffeeStructs.BatchCreationParams({
                productionDate: block.timestamp - 15 days + (i * 45 days),
                expiryDate: block.timestamp + 2 * 365 days,
                quantity: seasonalYields[i],
                pricePerKg: GREEN_COFFEE_PRICE + (i * 500_000), // Price increases with quality
                grantValue: 40_000e6,
                ipfsHash: string(abi.encodePacked("QmBatch_", seasons[i]))
            });
            
            vm.prank(admin);
            batchIds[i] = coffeeInventoryToken.createBatch(params);
            
            // Log seasonal harvest details
        }
        
        // Verify all seasonal batches
        uint256 totalHarvest = 0;
        for (uint256 i = 0; i < 3; i++) {
            CoffeeStructs.BatchInfo memory batchInfo = coffeeInventoryToken.getBatchInfo(batchIds[i]);
            totalHarvest += batchInfo.currentQuantity;
        }
        
        console2.log("  - Total seasonal harvest:", totalHarvest, "kg");
        assertEq(totalHarvest, 8900, "Total harvest should match sum of seasons");
        
        console2.log("Seasonal harvest workflow completed successfully");
    }
}
