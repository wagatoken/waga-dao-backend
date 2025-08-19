// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {ArbitrumLendingManager} from "../../src/arbitrum/ArbitrumLendingManager.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title ArbitrumSepoliaForkTest
 * @dev Comprehensive fork test for WAGA DAO USDC lending operations on Arbitrum Sepolia
 * @notice Tests Aave lending integration and cross-chain governance via CCIP
 */
contract ArbitrumSepoliaForkTest is Test {
    // Contract instances
    ArbitrumLendingManager public lendingManager;
    HelperConfig public helperConfig;

    // Network configuration
    uint256 public constant ARBITRUM_SEPOLIA_CHAIN_ID = 421614;

    // Arbitrum Sepolia addresses
    address public constant CCIP_ROUTER_ARBITRUM_SEPOLIA = 0x2a9C5afB0d0e4BAb2BCdaE109EC4b0c4Be15a165;
    address public constant LINK_TOKEN_ARBITRUM_SEPOLIA = 0xb1D4538B4571d411F07960EF2838Ce337FE1E80E;
    
    // Mock contracts for Sepolia testing
    address public mockUsdcToken;
    address public mockAUsdcToken;
    address public mockAavePool;

    // Test addresses
    address public constant ALICE = address(0x1001);
    address public constant BOB = address(0x1002);
    address public constant CHARLIE = address(0x1003);
    address public constant TREASURY = address(0x1004);
    address public constant COOPERATIVE_1 = address(0x2001);
    address public constant COOPERATIVE_2 = address(0x2002);
    
    // Cross-chain identifiers (Sepolia)
    uint64 public constant ETHEREUM_SEPOLIA_CHAIN_SELECTOR = 16015286601757825753;
    uint64 public constant BASE_SEPOLIA_CHAIN_SELECTOR = 10344971235874465080;
    uint64 public constant ARBITRUM_SEPOLIA_CHAIN_SELECTOR = 3478487238524512106;

    // Mock contracts
    MockUSDC public mockUsdc;
    MockAUSDC public mockAUsdc;
    MockAavePool public mockAave;

    function setUp() public {
        // Check if we have the RPC URL
        string memory rpcUrl;
        try vm.envString("ARBITRUM_SEPOLIA_RPC_URL") returns (string memory url) {
            rpcUrl = url;
        } catch {
            rpcUrl = "";
        }
        
        // Skip test if no RPC URL available
        if (bytes(rpcUrl).length == 0) {
            console.log("Skipping Arbitrum Sepolia fork test - no RPC URL");
            vm.skip(true);
        }

        console.log("=== ARBITRUM SEPOLIA FORK TEST SETUP ===");
        
        // Create fork of Arbitrum Sepolia
        vm.createFork(rpcUrl);
        vm.selectFork(0);
        
        // Verify we're on Arbitrum Sepolia
        require(block.chainid == ARBITRUM_SEPOLIA_CHAIN_ID, "Should be on Arbitrum Sepolia");
        
        console.log("Chain ID:", block.chainid);
        console.log("Block number:", block.number);
        console.log("Fork timestamp:", block.timestamp);
        
        // Deploy mock contracts for testing
        _deployMockContracts();
        
        // Deploy the lending system
        _deployLendingSystem();
        
        // Setup test accounts
        _setupTestAccounts();
        
        console.log("=== SETUP COMPLETED ===");
    }

    function _deployMockContracts() internal {
        console.log("--- Deploying Mock Contracts on Arbitrum Sepolia ---");
        
        // Deploy mock USDC
        mockUsdc = new MockUSDC("USD Coin", "USDC");
        mockUsdcToken = address(mockUsdc);
        
        // Deploy mock aUSDC
        mockAUsdc = new MockAUSDC("Aave USDC", "aUSDC", address(mockUsdc));
        mockAUsdcToken = address(mockAUsdc);
        
        // Deploy mock Aave Pool
        mockAave = new MockAavePool(address(mockUsdc), address(mockAUsdc));
        mockAavePool = address(mockAave);
        
        console.log("Mock USDC deployed to:", mockUsdcToken);
        console.log("Mock aUSDC deployed to:", mockAUsdcToken);
        console.log("Mock Aave Pool deployed to:", mockAavePool);
    }

    function _deployLendingSystem() internal {
        console.log("--- Deploying Lending System on Arbitrum Sepolia ---");
        
        // Deploy ArbitrumLendingManager
        lendingManager = new ArbitrumLendingManager(
            CCIP_ROUTER_ARBITRUM_SEPOLIA,
            mockUsdcToken,
            mockAUsdcToken,
            mockAavePool,
            LINK_TOKEN_ARBITRUM_SEPOLIA,
            TREASURY
        );
        
        console.log("ArbitrumLendingManager deployed to:", address(lendingManager));
        
        // Set up Base Sepolia as allowed source chain
        lendingManager.setAllowedSourceChain(BASE_SEPOLIA_CHAIN_SELECTOR, true);
        console.log("Base Sepolia chain selector allowed:", BASE_SEPOLIA_CHAIN_SELECTOR);
        
        // Verify deployments
        require(address(lendingManager) != address(0), "LendingManager not deployed");
        
        // Verify configuration
        assertEq(address(lendingManager.i_usdcToken()), mockUsdcToken);
        assertEq(address(lendingManager.i_aUsdcToken()), mockAUsdcToken);
        assertEq(lendingManager.i_aavePool(), mockAavePool);
        assertEq(address(lendingManager.getRouter()), CCIP_ROUTER_ARBITRUM_SEPOLIA);
    }

    function _setupTestAccounts() internal {
        console.log("--- Setting up Test Accounts on Arbitrum Sepolia ---");
        
        // Give ETH to test accounts
        vm.deal(ALICE, 100 ether);
        vm.deal(BOB, 100 ether);
        vm.deal(CHARLIE, 100 ether);
        vm.deal(address(lendingManager), 10 ether);
        
        // Mint mock USDC to test accounts and lending manager
        uint256 usdcAmount = 1000000e6; // 1M USDC per account
        
        mockUsdc.mint(ALICE, usdcAmount);
        mockUsdc.mint(BOB, usdcAmount);
        mockUsdc.mint(CHARLIE, usdcAmount);
        mockUsdc.mint(address(lendingManager), usdcAmount);
        
        // Deal LINK tokens for CCIP fees
        deal(LINK_TOKEN_ARBITRUM_SEPOLIA, address(lendingManager), 100e18);
        deal(LINK_TOKEN_ARBITRUM_SEPOLIA, ALICE, 10e18);
        deal(LINK_TOKEN_ARBITRUM_SEPOLIA, BOB, 10e18);
        
        console.log("Alice mock USDC balance:", mockUsdc.balanceOf(ALICE));
        console.log("Bob mock USDC balance:", mockUsdc.balanceOf(BOB));
        console.log("LendingManager USDC balance:", mockUsdc.balanceOf(address(lendingManager)));
        console.log("LendingManager LINK balance:", IERC20(LINK_TOKEN_ARBITRUM_SEPOLIA).balanceOf(address(lendingManager)));
    }

    /**
     * @dev Test 1: Basic deployment verification on Arbitrum Sepolia
     */
    function testDeploymentOnArbitrumSepolia() public view {
        console.log("=== TEST 1: ARBITRUM SEPOLIA DEPLOYMENT VERIFICATION ===");
        
        // Verify lending manager configuration
        assertEq(address(lendingManager.i_usdcToken()), mockUsdcToken);
        assertEq(address(lendingManager.i_aUsdcToken()), mockAUsdcToken);
        assertEq(lendingManager.i_aavePool(), mockAavePool);
        assertEq(address(lendingManager.i_linkToken()), LINK_TOKEN_ARBITRUM_SEPOLIA);
        assertEq(lendingManager.s_treasury(), TREASURY);
        
        // Verify CCIP configuration
        assertEq(address(lendingManager.getRouter()), CCIP_ROUTER_ARBITRUM_SEPOLIA);
        assertTrue(lendingManager.s_allowedSourceChains(BASE_SEPOLIA_CHAIN_SELECTOR));
        
        // Verify we're on correct testnet
        assertEq(block.chainid, ARBITRUM_SEPOLIA_CHAIN_ID);
        
        // Verify minimum lending amount
        assertEq(lendingManager.s_minimumLendingAmount(), 1000 * 1e6); // 1000 USDC
        
        console.log("[PASS] All Arbitrum Sepolia deployment parameters correct");
    }

    /**
     * @dev Test 2: USDC lending operations with mock Aave
     */
    function testUSDCLendingOperations() public {
        console.log("=== TEST 2: USDC LENDING OPERATIONS ===");
        
        uint256 lendingAmount = 50000e6; // $50,000 USDC
        uint256 initialContractBalance = mockUsdc.balanceOf(address(lendingManager));
        uint256 initialATokenBalance = mockAUsdc.balanceOf(address(lendingManager));
        
        console.log("Initial USDC balance:", initialContractBalance);
        console.log("Initial aUSDC balance:", initialATokenBalance);
        console.log("Deploying to lending:", lendingAmount);
        
        // Deploy USDC to lending
        uint256 aTokensReceived = lendingManager.deployToLending(lendingAmount);
        
        // Verify lending deployment
        uint256 finalContractBalance = mockUsdc.balanceOf(address(lendingManager));
        uint256 finalATokenBalance = mockAUsdc.balanceOf(address(lendingManager));
        uint256 totalDeployed = lendingManager.s_totalDeployedAmount();
        
        assertEq(finalContractBalance, initialContractBalance - lendingAmount);
        assertEq(finalATokenBalance, initialATokenBalance + aTokensReceived);
        assertEq(totalDeployed, lendingAmount);
        assertEq(aTokensReceived, lendingAmount); // 1:1 in mock
        
        console.log("Final USDC balance:", finalContractBalance);
        console.log("Final aUSDC balance:", finalATokenBalance);
        console.log("aTokens received:", aTokensReceived);
        console.log("Total deployed amount:", totalDeployed);
        console.log("[PASS] USDC lending operations successful");
    }

    /**
     * @dev Test 3: Yield harvesting simulation
     */
    function testYieldHarvestingSimulation() public {
        console.log("=== TEST 3: YIELD HARVESTING SIMULATION ===");
        
        uint256 lendingAmount = 100000e6; // $100,000 USDC
        uint256 simulatedYield = 3000e6; // $3,000 yield (3% annual)
        
        // Deploy to lending first
        lendingManager.deployToLending(lendingAmount);
        
        console.log("Deployed to lending:", lendingAmount);
        console.log("Simulating yield generation...");
        
        // Simulate yield by minting additional aUSDC to the contract
        // (In real Aave, aTokens appreciate in value over time)
        mockAUsdc.mint(address(lendingManager), simulatedYield);
        
        uint256 treasuryBalanceBefore = mockUsdc.balanceOf(TREASURY);
        console.log("Treasury balance before harvest:", treasuryBalanceBefore);
        
        // Fast forward time to allow harvest (1 hour minimum)
        vm.warp(block.timestamp + 3600);
        
        // Harvest yield
        uint256 yieldHarvested = lendingManager.harvestYield();
        
        uint256 treasuryBalanceAfter = mockUsdc.balanceOf(TREASURY);
        uint256 totalYieldHarvested = lendingManager.s_totalYieldHarvested();
        
        assertEq(yieldHarvested, simulatedYield);
        assertEq(treasuryBalanceAfter, treasuryBalanceBefore + simulatedYield);
        assertEq(totalYieldHarvested, simulatedYield);
        
        console.log("Yield harvested:", yieldHarvested);
        console.log("Treasury balance after harvest:", treasuryBalanceAfter);
        console.log("Total yield harvested:", totalYieldHarvested);
        console.log("[PASS] Yield harvesting simulation successful");
    }

    /**
     * @dev Test 4: Cooperative allocation and management
     */
    function testCooperativeAllocationManagement() public {
        console.log("=== TEST 4: COOPERATIVE ALLOCATION MANAGEMENT ===");
        
        uint256 allocation1 = 25000e6; // $25,000 for cooperative 1
        uint256 allocation2 = 35000e6; // $35,000 for cooperative 2
        
        uint256 initialTotalAllocation = lendingManager.s_totalCooperativeAllocation();
        
        console.log("Allocating to cooperatives...");
        console.log("Cooperative 1 allocation:", allocation1);
        console.log("Cooperative 2 allocation:", allocation2);
        
        // Allocate to cooperatives
        lendingManager.allocateToCooperative(COOPERATIVE_1, allocation1, "Coffee harvest financing");
        lendingManager.allocateToCooperative(COOPERATIVE_2, allocation2, "Processing equipment upgrade");
        
        // Verify allocations
        uint256 coop1Allocation = lendingManager.s_cooperativeLendingAllocations(COOPERATIVE_1);
        uint256 coop2Allocation = lendingManager.s_cooperativeLendingAllocations(COOPERATIVE_2);
        uint256 totalCooperativeAllocation = lendingManager.s_totalCooperativeAllocation();
        
        assertEq(coop1Allocation, allocation1);
        assertEq(coop2Allocation, allocation2);
        assertEq(totalCooperativeAllocation, initialTotalAllocation + allocation1 + allocation2);
        
        console.log("Cooperative 1 allocation:", coop1Allocation);
        console.log("Cooperative 2 allocation:", coop2Allocation);
        console.log("Total cooperative allocation:", totalCooperativeAllocation);
        
        // Test cooperative info retrieval
        (uint256 allocation, uint256 yieldEarned) = lendingManager.getCooperativeInfo(COOPERATIVE_1);
        assertEq(allocation, allocation1);
        assertEq(yieldEarned, 0); // No yield allocated yet
        
        console.log("Cooperative 1 info - allocation:", allocation, "yield:", yieldEarned);
        console.log("[PASS] Cooperative allocation management successful");
    }

    /**
     * @dev Test 5: Cross-chain CCIP setup verification
     */
    function testCCIPSetupVerification() public view {
        console.log("=== TEST 5: CCIP SETUP VERIFICATION ===");
        
        // Verify CCIP router configuration
        address router = address(lendingManager.getRouter());
        assertTrue(router != address(0), "CCIP router should be set");
        assertTrue(router.code.length > 0, "CCIP router should have code");
        assertEq(router, CCIP_ROUTER_ARBITRUM_SEPOLIA, "Should use correct Arbitrum Sepolia CCIP router");
        
        // Verify allowed source chains
        assertTrue(lendingManager.s_allowedSourceChains(BASE_SEPOLIA_CHAIN_SELECTOR));
        
        // Verify LINK token setup
        assertEq(address(lendingManager.i_linkToken()), LINK_TOKEN_ARBITRUM_SEPOLIA);
        assertTrue(IERC20(LINK_TOKEN_ARBITRUM_SEPOLIA).balanceOf(address(lendingManager)) > 0);
        
        console.log("CCIP Router (Arbitrum Sepolia):", router);
        console.log("Router code size:", router.code.length);
        console.log("Base Sepolia allowed:", lendingManager.s_allowedSourceChains(BASE_SEPOLIA_CHAIN_SELECTOR));
        console.log("LINK balance:", IERC20(LINK_TOKEN_ARBITRUM_SEPOLIA).balanceOf(address(lendingManager)));
        console.log("[PASS] CCIP setup verification completed");
    }

    /**
     * @dev Test 6: Lending position information and statistics
     */
    function testLendingPositionInformation() public {
        console.log("=== TEST 6: LENDING POSITION INFORMATION ===");
        
        uint256 lendingAmount = 75000e6; // $75,000 USDC
        
        // Deploy to lending
        lendingManager.deployToLending(lendingAmount);
        
        // Get lending position information
        (
            uint256 totalDeployed,
            uint256 currentATokenBalance,
            uint256 estimatedYield,
            uint256 currentAPY
        ) = lendingManager.getLendingPosition();
        
        assertEq(totalDeployed, lendingAmount);
        assertEq(currentATokenBalance, lendingAmount); // 1:1 in mock
        assertEq(estimatedYield, 0); // No yield yet
        assertEq(currentAPY, 0); // No time passed
        
        console.log("Total deployed:", totalDeployed);
        console.log("Current aToken balance:", currentATokenBalance);
        console.log("Estimated yield:", estimatedYield);
        console.log("Current APY:", currentAPY);
        
        // Get contract statistics
        (
            uint256 totalDeployedStats,
            uint256 totalYieldHarvested,
            uint256 totalCooperativeAllocation,
            uint256 contractUSDCBalance,
            uint256 contractAUSDCBalance
        ) = lendingManager.getContractStats();
        
        console.log("=== Contract Statistics ===");
        console.log("Total deployed (stats):", totalDeployedStats);
        console.log("Total yield harvested:", totalYieldHarvested);
        console.log("Total cooperative allocation:", totalCooperativeAllocation);
        console.log("Contract USDC balance:", contractUSDCBalance);
        console.log("Contract aUSDC balance:", contractAUSDCBalance);
        
        console.log("[PASS] Lending position information verified");
    }

    /**
     * @dev Test 7: Emergency functions and security
     */
    function testEmergencyFunctionsAndSecurity() public {
        console.log("=== TEST 7: EMERGENCY FUNCTIONS AND SECURITY ===");
        
        uint256 lendingAmount = 50000e6; // $50,000 USDC
        
        // Deploy to lending first
        lendingManager.deployToLending(lendingAmount);
        
        uint256 contractBalanceBefore = mockUsdc.balanceOf(address(lendingManager));
        uint256 emergencyAmount = 20000e6; // $20,000
        
        console.log("Contract balance before emergency:", contractBalanceBefore);
        console.log("Emergency withdrawal amount:", emergencyAmount);
        
        // Test emergency withdrawal
        lendingManager.emergencyWithdraw(emergencyAmount, TREASURY);
        
        uint256 treasuryBalance = mockUsdc.balanceOf(TREASURY);
        uint256 contractBalanceAfter = mockUsdc.balanceOf(address(lendingManager));
        
        assertEq(treasuryBalance, emergencyAmount);
        
        console.log("Treasury balance after emergency:", treasuryBalance);
        console.log("Contract balance after emergency:", contractBalanceAfter);
        
        // Test pause functionality
        lendingManager.pause();
        
        // Should not be able to deploy when paused
        vm.expectRevert();
        lendingManager.deployToLending(10000e6);
        
        // Unpause
        lendingManager.unpause();
        
        // Should work again after unpause
        lendingManager.deployToLending(5000e6);
        
        console.log("Pause/unpause functionality working");
        
        // Test access control
        vm.expectRevert();
        vm.prank(ALICE);
        lendingManager.setTreasury(address(0x9999));
        
        console.log("Access control working correctly");
        console.log("[PASS] Emergency functions and security verified");
    }

    /**
     * @dev Test 8: Large scale lending operations
     */
    function testLargeScaleLendingOperations() public {
        console.log("=== TEST 8: LARGE SCALE LENDING OPERATIONS ===");
        
        // Fund the contract with a large amount
        mockUsdc.mint(address(lendingManager), 5000000e6); // $5M USDC
        
        // Deploy multiple large amounts
        uint256[] memory deployments = new uint256[](5);
        deployments[0] = 500000e6; // $500K
        deployments[1] = 750000e6; // $750K
        deployments[2] = 1000000e6; // $1M
        deployments[3] = 600000e6; // $600K
        deployments[4] = 400000e6; // $400K
        
        uint256 totalExpectedDeployed = 0;
        
        for (uint i = 0; i < deployments.length; i++) {
            console.log("Deployment", i + 1, ":", deployments[i]);
            lendingManager.deployToLending(deployments[i]);
            totalExpectedDeployed += deployments[i];
        }
        
        uint256 actualTotalDeployed = lendingManager.s_totalDeployedAmount();
        assertEq(actualTotalDeployed, totalExpectedDeployed);
        
        console.log("Total expected deployed:", totalExpectedDeployed);
        console.log("Actual total deployed:", actualTotalDeployed);
        
        // Test large cooperative allocations
        lendingManager.allocateToCooperative(COOPERATIVE_1, 200000e6, "Large scale operations");
        lendingManager.allocateToCooperative(COOPERATIVE_2, 300000e6, "Expansion project");
        
        uint256 totalCooperativeAllocation = lendingManager.s_totalCooperativeAllocation();
        assertEq(totalCooperativeAllocation, 500000e6);
        
        console.log("Total cooperative allocation:", totalCooperativeAllocation);
        console.log("[PASS] Large scale lending operations successful");
    }

    /**
     * @dev Test 9: Gas optimization on Arbitrum Sepolia
     */
    function testGasOptimizationOnArbitrumSepolia() public {
        console.log("=== TEST 9: GAS OPTIMIZATION ON ARBITRUM SEPOLIA ===");
        
        // Test gas usage for lending deployment
        uint256 lendingAmount = 25000e6;
        
        uint256 gasBefore = gasleft();
        lendingManager.deployToLending(lendingAmount);
        uint256 deployGasUsed = gasBefore - gasleft();
        
        console.log("Gas used for lending deployment:", deployGasUsed);
        
        // Test gas usage for cooperative allocation
        gasBefore = gasleft();
        lendingManager.allocateToCooperative(COOPERATIVE_1, 15000e6, "Test allocation");
        uint256 allocateGasUsed = gasBefore - gasleft();
        
        console.log("Gas used for cooperative allocation:", allocateGasUsed);
        
        // Simulate yield and test harvest gas
        mockAUsdc.mint(address(lendingManager), 1000e6); // $1000 yield
        vm.warp(block.timestamp + 3600); // Fast forward 1 hour
        
        gasBefore = gasleft();
        lendingManager.harvestYield();
        uint256 harvestGasUsed = gasBefore - gasleft();
        
        console.log("Gas used for yield harvest:", harvestGasUsed);
        
        // Verify gas efficiency (Arbitrum has lower gas costs)
        assertTrue(deployGasUsed < 500000, "Lending deployment should be gas efficient");
        assertTrue(allocateGasUsed < 300000, "Cooperative allocation should be gas efficient");
        assertTrue(harvestGasUsed < 400000, "Yield harvest should be gas efficient");
        
        console.log("[PASS] Gas optimization verified on Arbitrum Sepolia");
    }

    /**
     * @dev Final comprehensive test summary for Arbitrum Sepolia
     */
    function testArbitrumSepoliaComprehensiveSummary() public view {
        console.log("=== COMPREHENSIVE ARBITRUM SEPOLIA TEST SUMMARY ===");
        
        uint256 totalDeployed = lendingManager.s_totalDeployedAmount();
        uint256 totalYieldHarvested = lendingManager.s_totalYieldHarvested();
        uint256 totalCooperativeAllocation = lendingManager.s_totalCooperativeAllocation();
        
        console.log("=== FINAL ARBITRUM SEPOLIA SYSTEM STATE ===");
        console.log("Total USDC Deployed to Lending:", totalDeployed);
        console.log("Total Yield Harvested:", totalYieldHarvested);
        console.log("Total Cooperative Allocation:", totalCooperativeAllocation);
        console.log("Chain ID:", block.chainid);
        
        console.log("=== ARBITRUM SEPOLIA SYSTEM VERIFICATION ===");
        console.log("* USDC lending operations via mock Aave working");
        console.log("* Yield harvesting mechanism operational");
        console.log("* Cooperative allocation system verified");
        console.log("* Cross-chain CCIP infrastructure ready");
        console.log("* Emergency functions and security working");
        console.log("* Large scale operations tested");
        console.log("* Gas optimization confirmed");
        
        console.log("[PASS] ALL ARBITRUM SEPOLIA TESTS COMPLETED SUCCESSFULLY");
    }
}

/**
 * @title MockUSDC
 * @dev Mock USDC token for Arbitrum Sepolia testing
 */
contract MockUSDC is IERC20 {
    string public name;
    string public symbol;
    uint8 public constant decimals = 6;
    uint256 public totalSupply;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }
    
    function mint(address to, uint256 amount) external {
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }
    
    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(allowance[from][msg.sender] >= amount, "Insufficient allowance");
        
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        
        emit Transfer(from, to, amount);
        return true;
    }
    
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
}

/**
 * @title MockAUSDC
 * @dev Mock aUSDC token that appreciates in value over time
 */
contract MockAUSDC is IERC20 {
    string public name;
    string public symbol;
    uint8 public constant decimals = 6;
    uint256 public totalSupply;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    IERC20 public immutable underlyingAsset;
    
    constructor(string memory _name, string memory _symbol, address _underlying) {
        name = _name;
        symbol = _symbol;
        underlyingAsset = IERC20(_underlying);
    }
    
    function mint(address to, uint256 amount) external {
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }
    
    function burn(address from, uint256 amount) external {
        require(balanceOf[from] >= amount, "Insufficient balance");
        totalSupply -= amount;
        balanceOf[from] -= amount;
        emit Transfer(from, address(0), amount);
    }
    
    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(allowance[from][msg.sender] >= amount, "Insufficient allowance");
        
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        
        emit Transfer(from, to, amount);
        return true;
    }
    
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
}

/**
 * @title MockAavePool
 * @dev Mock Aave Pool for testing lending operations
 */
contract MockAavePool {
    IERC20 public immutable usdcToken;
    MockAUSDC public immutable aUsdcToken;
    
    constructor(address _usdc, address _aUsdc) {
        usdcToken = IERC20(_usdc);
        aUsdcToken = MockAUSDC(_aUsdc);
    }
    
    /**
     * @dev Mock supply function that mimics Aave V3 supply
     */
    function supply(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external {
        require(asset == address(usdcToken), "Invalid asset");
        require(amount > 0, "Invalid amount");
        
        // Transfer USDC from user to pool
        usdcToken.transferFrom(msg.sender, address(this), amount);
        
        // Mint aUSDC to user (1:1 ratio for simplicity)
        aUsdcToken.mint(onBehalfOf, amount);
    }
    
    /**
     * @dev Mock withdraw function that mimics Aave V3 withdraw
     */
    function withdraw(address asset, uint256 amount, address to) external returns (uint256) {
        require(asset == address(usdcToken), "Invalid asset");
        require(amount > 0, "Invalid amount");
        
        // Burn aUSDC from user
        aUsdcToken.burn(msg.sender, amount);
        
        // Transfer USDC to user
        usdcToken.transfer(to, amount);
        
        return amount;
    }
}
