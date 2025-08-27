// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/base/CooperativeGrantManagerV2.sol";
import "../src/managers/GreenfieldProjectManager.sol";
import "../src/shared/WAGACoffeeInventoryTokenV2.sol";
import "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import "../src/shared/interfaces/ICooperativeGrantManager.sol";

contract PhasedDisbursementTest is Test {
    CooperativeGrantManagerV2 public grantManager;
    GreenfieldProjectManager public greenfieldManager;
    WAGACoffeeInventoryTokenV2 public coffeeToken;
    ERC20Mock public usdcToken;
    
    address public admin;
    address public cooperative;
    address public validator;
    address public treasury;
    
    uint256 public constant GRANT_AMOUNT = 100_000e6; // $100,000 USDC
    uint256 public constant REVENUE_SHARE = 2500; // 25%
    uint256 public constant DURATION_YEARS = 5;
    
    event DisbursementScheduleCreated(uint256 indexed grantId, uint256 totalMilestones, uint256 escrowedAmount);
    event MilestoneCompleted(uint256 indexed grantId, uint256 indexed milestoneIndex, string evidenceUri, address indexed validator, uint256 disbursedAmount);
    event AutoDisbursementExecuted(uint256 indexed grantId, uint256 indexed milestoneIndex, uint256 amount, address indexed recipient);

    function setUp() public {
        admin = makeAddr("admin");
        cooperative = makeAddr("cooperative");
        validator = makeAddr("validator");
        treasury = makeAddr("treasury");
        
        vm.startPrank(admin);
        
        // Deploy mock USDC
        usdcToken = new ERC20Mock();
        
        // Deploy greenfield manager
        greenfieldManager = new GreenfieldProjectManager(admin);
        
        // Deploy coffee token
        coffeeToken = new WAGACoffeeInventoryTokenV2(
            admin,
            address(greenfieldManager)
        );
        
        // Deploy grant manager
        grantManager = new CooperativeGrantManagerV2(
            address(usdcToken),
            address(greenfieldManager),
            treasury,
            admin
        );
        
        // Setup roles
        grantManager.grantRole(grantManager.MILESTONE_VALIDATOR_ROLE(), validator);
        greenfieldManager.grantRole(greenfieldManager.PROJECT_MANAGER_ROLE(), address(grantManager));
        
        // Fund grant manager
        usdcToken.mint(address(grantManager), 1_000_000e6);
        
        vm.stopPrank();
    }

    function testCreateDisbursementSchedule() public {
        console.log("\\n=== TESTING DISBURSEMENT SCHEDULE CREATION ===");
        
        // Create greenfield grant
        vm.prank(admin);
        (uint256 grantId, /* uint256 projectId */) = grantManager.createGreenfieldGrant(
            cooperative,
            GRANT_AMOUNT,
            REVENUE_SHARE,
            DURATION_YEARS,
            "QmTestProject",
            block.timestamp + 90 days,
            block.timestamp + 4 * 365 days,
            15000,
            "Test Cooperative"
        );
        
        // Create milestone descriptions and percentages
        string[] memory descriptions = new string[](4);
        descriptions[0] = "Land preparation and soil testing";
        descriptions[1] = "Coffee seedling planting";
        descriptions[2] = "Growth and maintenance phase";
        descriptions[3] = "Pre-harvest and quality assessment";
        
        uint256[] memory percentages = new uint256[](4);
        percentages[0] = 3000; // 30%
        percentages[1] = 3000; // 30%
        percentages[2] = 2500; // 25%
        percentages[3] = 1500; // 15%
        
        // Create disbursement schedule
        vm.expectEmit(true, false, false, true);
        emit DisbursementScheduleCreated(grantId, 4, GRANT_AMOUNT);
        
        vm.prank(admin);
        grantManager.createDisbursementSchedule(grantId, descriptions, percentages);
        
        // Verify schedule creation
        ICooperativeGrantManager.DisbursementSchedule memory schedule = 
            grantManager.getDisbursementSchedule(grantId);
        
        assertEq(schedule.totalMilestones, 4, "Wrong total milestones");
        assertEq(schedule.completedMilestones, 0, "Should have 0 completed milestones");
        assertTrue(schedule.isActive, "Schedule should be active");
        assertEq(schedule.escrowedAmount, GRANT_AMOUNT, "Wrong escrowed amount");
        
        // Verify first milestone
        ICooperativeGrantManager.MilestoneInfo memory milestone0 = 
            grantManager.getMilestoneInfo(grantId, 0);
        
        assertEq(milestone0.description, descriptions[0], "Wrong milestone description");
        assertEq(milestone0.percentageShare, percentages[0], "Wrong percentage share");
        assertFalse(milestone0.isCompleted, "Milestone should not be completed");
        
        console.log("  - Schedule created with 4 milestones");
        console.log("  - Total escrowed amount:", GRANT_AMOUNT / 1e6, "USDC");
        console.log("  - Milestone 0 percentage:", percentages[0] / 100, "%");
    }

    function testPhasedDisbursementWorkflow() public {
        console.log("\\n=== TESTING COMPLETE PHASED DISBURSEMENT WORKFLOW ===");
        
        // Setup grant and schedule
        uint256 grantId = _setupGrantWithSchedule();
        
        // Test milestone submissions and automatic disbursements
        string[] memory evidenceUris = new string[](4);
        evidenceUris[0] = "ipfs://QmEvidence1";
        evidenceUris[1] = "ipfs://QmEvidence2";
        evidenceUris[2] = "ipfs://QmEvidence3";
        evidenceUris[3] = "ipfs://QmEvidence4";
        
        uint256[] memory expectedAmounts = new uint256[](4);
        expectedAmounts[0] = (GRANT_AMOUNT * 3000) / 10000; // 30%
        expectedAmounts[1] = (GRANT_AMOUNT * 3000) / 10000; // 30%
        expectedAmounts[2] = (GRANT_AMOUNT * 2500) / 10000; // 25%
        expectedAmounts[3] = (GRANT_AMOUNT * 1500) / 10000; // 15%
        
        uint256 cooperativeBalanceBefore = usdcToken.balanceOf(cooperative);
        
        for (uint256 i = 0; i < 4; i++) {
            console.log("\\n--- Processing Milestone", i, "---");
            
            // Submit evidence (auto-approves in this implementation)
            vm.expectEmit(true, true, false, true);
            emit AutoDisbursementExecuted(grantId, i, expectedAmounts[i], cooperative);
            
            vm.prank(cooperative);
            grantManager.submitMilestoneEvidence(grantId, i, evidenceUris[i]);
            
            // Verify milestone completion
            ICooperativeGrantManager.MilestoneInfo memory milestone = 
                grantManager.getMilestoneInfo(grantId, i);
            
            assertTrue(milestone.isCompleted, "Milestone should be completed");
            assertEq(milestone.evidenceUri, evidenceUris[i], "Wrong evidence URI");
            assertEq(milestone.disbursedAmount, expectedAmounts[i], "Wrong disbursed amount");
            assertGt(milestone.completedTimestamp, 0, "Should have completion timestamp");
            
            // Verify cooperative received funds
            uint256 expectedBalance = cooperativeBalanceBefore;
            for (uint256 j = 0; j <= i; j++) {
                expectedBalance += expectedAmounts[j];
            }
            
            assertEq(usdcToken.balanceOf(cooperative), expectedBalance, "Wrong cooperative balance");
            
            console.log("  - Milestone", i, "completed");
            console.log("  - Disbursed amount:", expectedAmounts[i] / 1e6, "USDC");
            console.log("  - Cooperative balance:", usdcToken.balanceOf(cooperative) / 1e6, "USDC");
        }
        
        // Verify final state
        ICooperativeGrantManager.DisbursementSchedule memory finalSchedule = 
            grantManager.getDisbursementSchedule(grantId);
        
        assertEq(finalSchedule.completedMilestones, 4, "All milestones should be completed");
        assertFalse(finalSchedule.isActive, "Schedule should be inactive");
        
        ICooperativeGrantManager.GrantInfo memory grant = grantManager.getGrant(grantId);
        assertEq(grant.disbursedAmount, GRANT_AMOUNT, "All funds should be disbursed");
        assertEq(uint256(grant.status), uint256(ICooperativeGrantManager.GrantStatus.Active), "Grant should be active");
        
        // Verify escrow is empty
        assertEq(grantManager.getGrantEscrowBalance(grantId), 0, "Escrow should be empty");
        
        console.log("\\n=== PHASED DISBURSEMENT COMPLETED SUCCESSFULLY ===");
        console.log("  - Total disbursed:", GRANT_AMOUNT / 1e6, "USDC");
        console.log("  - All 4 milestones completed");
        console.log("  - Grant status: Active");
    }

    function testMilestoneValidation() public {
        console.log("\\n=== TESTING MILESTONE VALIDATION ===");
        
        uint256 grantId = _setupGrantWithSchedule();
        
        // Test manual validation by validator
        vm.prank(validator);
        grantManager.validateMilestone(grantId, 0, true);
        
        // Verify milestone was completed and funds disbursed
        ICooperativeGrantManager.MilestoneInfo memory milestone = 
            grantManager.getMilestoneInfo(grantId, 0);
        
        assertTrue(milestone.isCompleted, "Milestone should be completed");
        assertEq(milestone.validator, validator, "Wrong validator");
        
        uint256 expectedAmount = (GRANT_AMOUNT * 3000) / 10000; // 30%
        assertEq(milestone.disbursedAmount, expectedAmount, "Wrong disbursed amount");
        assertEq(usdcToken.balanceOf(cooperative), expectedAmount, "Cooperative should receive funds");
        
        console.log("  - Milestone validated and auto-disbursed");
        console.log("  - Amount disbursed:", expectedAmount / 1e6, "USDC");
    }

    function testErrorConditions() public {
        console.log("\\n=== TESTING ERROR CONDITIONS ===");
        
        uint256 grantId = _setupGrantWithSchedule();
        
        // Test unauthorized milestone submission
        vm.expectRevert();
        vm.prank(makeAddr("unauthorized"));
        grantManager.submitMilestoneEvidence(grantId, 0, "ipfs://test");
        
        // Test invalid milestone index
        vm.expectRevert();
        vm.prank(cooperative);
        grantManager.submitMilestoneEvidence(grantId, 10, "ipfs://test");
        
        // Complete a milestone
        vm.prank(cooperative);
        grantManager.submitMilestoneEvidence(grantId, 0, "ipfs://test");
        
        // Test duplicate milestone completion
        vm.expectRevert();
        vm.prank(cooperative);
        grantManager.submitMilestoneEvidence(grantId, 0, "ipfs://test2");
        
        console.log("  - All error conditions handled correctly");
    }

    function testEscrowManagement() public {
        console.log("\\n=== TESTING ESCROW MANAGEMENT ===");
        
        uint256 grantId = _setupGrantWithSchedule();
        
        // Verify initial escrow state
        assertEq(grantManager.getGrantEscrowBalance(grantId), GRANT_AMOUNT, "Wrong initial escrow");
        assertEq(grantManager.totalEscrowBalance(), GRANT_AMOUNT, "Wrong total escrow");
        assertTrue(grantManager.hasActiveDisbursementSchedule(grantId), "Should have active schedule");
        
        // Complete first milestone
        vm.prank(cooperative);
        grantManager.submitMilestoneEvidence(grantId, 0, "ipfs://test");
        
        uint256 expectedRemaining = GRANT_AMOUNT - ((GRANT_AMOUNT * 3000) / 10000);
        assertEq(grantManager.getGrantEscrowBalance(grantId), expectedRemaining, "Wrong remaining escrow");
        
        console.log("  - Escrow management working correctly");
        console.log("  - Remaining escrow:", expectedRemaining / 1e6, "USDC");
    }

    // Helper function to setup grant with disbursement schedule
    function _setupGrantWithSchedule() internal returns (uint256 grantId) {
        // Create greenfield grant
        vm.prank(admin);
        (grantId, ) = grantManager.createGreenfieldGrant(
            cooperative,
            GRANT_AMOUNT,
            REVENUE_SHARE,
            DURATION_YEARS,
            "QmTestProject",
            block.timestamp + 90 days,
            block.timestamp + 4 * 365 days,
            15000,
            "Test Cooperative"
        );
        
        // Create milestone schedule
        string[] memory descriptions = new string[](4);
        descriptions[0] = "Land preparation";
        descriptions[1] = "Planting";
        descriptions[2] = "Growth phase";
        descriptions[3] = "Pre-harvest";
        
        uint256[] memory percentages = new uint256[](4);
        percentages[0] = 3000; // 30%
        percentages[1] = 3000; // 30%
        percentages[2] = 2500; // 25%
        percentages[3] = 1500; // 15%
        
        vm.prank(admin);
        grantManager.createDisbursementSchedule(grantId, descriptions, percentages);
        
        // Move funds to escrow (simulate disburseGrant call)
        vm.prank(admin);
        grantManager.disburseGrant(grantId);
        
        return grantId;
    }
}
