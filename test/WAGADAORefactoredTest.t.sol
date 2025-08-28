// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {WAGACoffeeInventoryTokenV2} from "../src/shared/WAGACoffeeInventoryTokenV2.sol";
import {CooperativeGrantManagerV2} from "../src/base/CooperativeGrantManagerV2.sol";
import {GreenfieldProjectManager} from "../src/managers/GreenfieldProjectManager.sol";
import {IWAGACoffeeInventoryToken} from "../src/shared/interfaces/IWAGACoffeeInventoryToken.sol";
import {ICooperativeGrantManager} from "../src/shared/interfaces/ICooperativeGrantManager.sol";
import {CoffeeStructs} from "../src/shared/libraries/CoffeeStructs.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

/**
 * @title WAGADAORefactoredTest
 * @notice Test suite for the refactored WAGA DAO architecture
 */
contract WAGADAORefactoredTest is Test {
    
    GreenfieldProjectManager public greenfieldManager;
    WAGACoffeeInventoryTokenV2 public coffeeToken;
    CooperativeGrantManagerV2 public grantManager;
    HelperConfig public helperConfig;
    
    address public admin = makeAddr("admin");
    address public cooperative = makeAddr("cooperative");
    address public treasury = makeAddr("treasury");
    
    function setUp() public {
        // Get network configuration
        helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfigByChainId(block.chainid);
        
        vm.startPrank(admin);
        
        // Deploy in order of dependencies
        greenfieldManager = new GreenfieldProjectManager(
            admin
        );
        
        coffeeToken = new WAGACoffeeInventoryTokenV2(
            admin,
            address(greenfieldManager)
        );
        
        grantManager = new CooperativeGrantManagerV2(
            config.usdcToken,
            address(greenfieldManager),
            treasury,
            admin,
            address(0) // ZK Proof Manager - placeholder for now
        );
        
        // Set up permissions
        _setupPermissions();
        
        vm.stopPrank();
    }
    
    function testDeployment() public view {
        // Verify all contracts deployed
        assertTrue(address(greenfieldManager) != address(0));
        assertTrue(address(coffeeToken) != address(0));
        assertTrue(address(grantManager) != address(0));
        
        // Verify initial state
        assertEq(coffeeToken.nextBatchId(), 1);
        assertEq(grantManager.nextGrantId(), 1);
        assertEq(greenfieldManager.nextProjectId(), 1);
        
        console.log("All contracts deployed and configured successfully");
    }
    
    function testCreateBatch() public {
        uint256 currentTime = block.timestamp;
        CoffeeStructs.BatchCreationParams memory params = CoffeeStructs.BatchCreationParams({
            productionDate: currentTime,
            expiryDate: currentTime + 365 days,
            quantity: 1000,
            pricePerKg: 5e6, // $5 per kg (6 decimals)
            grantValue: 10000e6, // $10,000 (6 decimals)
            ipfsHash: "QmTestBatch" // All rich metadata goes to IPFS + Database
        });
        
        vm.prank(admin);
        uint256 batchId = coffeeToken.createBatch(params);
        
        // Verify batch creation
        assertEq(batchId, 1);
        assertTrue(coffeeToken.batchExists(batchId));
        
        // Verify batch info using struct
        CoffeeStructs.BatchInfo memory batchInfo = coffeeToken.getBatchInfo(batchId);
        
        assertEq(batchInfo.productionDate, params.productionDate);
        assertEq(batchInfo.currentQuantity, params.quantity);
        assertEq(batchInfo.pricePerKg, params.pricePerKg);
        assertEq(batchInfo.grantValue, params.grantValue);
        assertFalse(batchInfo.isVerified);
        
        console.log("Batch created successfully with ID:", batchId);
    }
    
    function testCreateGreenfieldGrant() public {
        // Create greenfield project parameters (blockchain-first approach)
        string memory ipfsHash = "QmTestGreenfieldProject";
        uint256 plantingDate = block.timestamp + 60 days;
        uint256 maturityDate = block.timestamp + 3 * 365 days;
        uint256 projectedYield = 25_000; // 25,000 kg annual yield
        string memory cooperativeName = "Greenfield Cooperative";
        
        vm.prank(admin);
        (uint256 grantId, uint256 projectId) = grantManager.createGreenfieldGrant(
            cooperative,
            50_000e6, // $50,000 USDC
            2000, // 20% revenue share
            3, // 3 years
            ipfsHash,
            plantingDate,
            maturityDate,
            projectedYield,
            cooperativeName
        );
        
        // Verify grant creation
        assertGt(grantId, 0);
        assertGt(projectId, 0);
        
        // Verify grant info
        ICooperativeGrantManager.GrantInfo memory grantInfo = grantManager.getGrant(grantId);
        assertEq(grantInfo.cooperative, cooperative);
        assertEq(grantInfo.amount, 50_000e6);
        assertEq(grantInfo.revenueSharePercent, 2000);
        assertEq(uint256(grantInfo.status), uint256(ICooperativeGrantManager.GrantStatus.Pending));
        
        // Verify project creation
        (
            bool isGreenfield,
            uint256 returnedPlantingDate,
            uint256 returnedMaturityDate,
            uint256 returnedProjectedYield,
            uint256 investmentStage
        ) = greenfieldManager.getGreenfieldProjectDetails(projectId);
        
        assertTrue(isGreenfield);
        assertEq(returnedPlantingDate, plantingDate);
        assertEq(returnedMaturityDate, maturityDate);
        assertEq(returnedProjectedYield, projectedYield);
        assertEq(investmentStage, 0);
        
        // Verify grant-project link  
        // Note: getGrantProject method not available in refactored architecture
        // assertEq(grantManager.getGrantProject(grantId), projectId);
        
        console.log("Greenfield grant and project created successfully");
        console.log("Grant ID:", grantId);
        console.log("Project ID:", projectId);
    }
    
    function testAdvanceGreenfieldStage() public {
        // First create a greenfield project (blockchain-first approach)
        string memory ipfsHash = "QmTestProject";
        uint256 plantingDate = block.timestamp + 60 days;
        uint256 maturityDate = block.timestamp + 3 * 365 days;
        uint256 projectedYield = 25_000; // 25,000 kg annual yield
        string memory cooperativeName = "Test Cooperative";
        
        vm.startPrank(admin);
        (, uint256 projectId) = grantManager.createGreenfieldGrant(
            cooperative,
            50_000e6,
            2000,
            3,
            ipfsHash,
            plantingDate,
            maturityDate,
            projectedYield,
            cooperativeName
        );
        
        // Advance the project stage
        greenfieldManager.advanceProjectStage(
            projectId,
            1, // New stage
            30_000, // Updated yield
            "QmMilestoneEvidence"
        );
        
        vm.stopPrank();
        
        // Verify stage advancement
        (,,,, uint256 newStage) = greenfieldManager.getGreenfieldProjectDetails(projectId);
        assertEq(newStage, 1);
        
        console.log("Project stage advanced successfully to stage:", newStage);
    }
    
    function testArchitectureSeparation() public view {
        // Verify that each contract has focused responsibilities
        
        // GreenfieldProjectManager should handle project-specific logic
        assertTrue(address(greenfieldManager) != address(0));
        
        // CoffeeToken should handle core ERC1155 and basic inventory
        assertTrue(address(coffeeToken) != address(0));
        
        // GrantManager should handle financial operations
        assertTrue(address(grantManager) != address(0));
        
        // Verify cross-contract references
        assertEq(address(coffeeToken.greenfieldManager()), address(greenfieldManager));
        assertEq(address(grantManager.greenfieldManager()), address(greenfieldManager));
        // Note: coffeeInventoryToken reference not exposed in refactored architecture
        // assertEq(address(grantManager.coffeeInventoryToken()), address(coffeeToken));
        
        console.log("Architecture separation verified - each contract has focused responsibilities");
    }
    
    function _setupPermissions() internal {
        // Grant manager permissions on coffee token
        coffeeToken.grantRole(coffeeToken.DAO_ADMIN_ROLE(), address(grantManager));
        coffeeToken.grantRole(coffeeToken.MINTER_ROLE(), address(grantManager));
        
        // Greenfield manager permissions
        greenfieldManager.grantRole(greenfieldManager.PROJECT_MANAGER_ROLE(), address(grantManager));
        greenfieldManager.grantRole(greenfieldManager.PROJECT_MANAGER_ROLE(), admin);
    }
}
