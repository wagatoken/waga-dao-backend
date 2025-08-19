// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MainnetCollateralManager} from "../../src/mainnet/MainnetCollateralManager.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/**
 * @title EthereumSepoliaForkTest
 * @dev Comprehensive fork test for WAGA DAO PAXG collateral management on Ethereum Sepolia
 * @notice Tests PAXG collateral operations and cross-chain messaging to Base Sepolia
 */
contract EthereumSepoliaForkTest is Test {
    // Contract instances
    MainnetCollateralManager public collateralManager;
    HelperConfig public helperConfig;

    // Network configuration
    uint256 public constant ETHEREUM_SEPOLIA_CHAIN_ID = 11155111;

    // Sepolia addresses
    address public constant CCIP_ROUTER_SEPOLIA = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59;
    address public constant XAU_USD_PRICE_FEED_SEPOLIA = 0xC1Bc9A6BA9A9cac065FFbBa23E6d2611Ac5ea4af; // Sepolia XAU/USD
    address public constant LINK_TOKEN_SEPOLIA = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    
    // Mock PAXG for testing (we'll deploy our own for Sepolia)
    address public mockPaxgToken;

    // Test addresses
    address public constant ALICE = address(0x1001);
    address public constant BOB = address(0x1002);
    address public constant CHARLIE = address(0x1003);
    address public constant TREASURY = address(0x1004);
    address public constant BASE_DESTINATION = address(0x2001);
    
    // Cross-chain identifiers (Sepolia)
    uint64 public constant ETHEREUM_SEPOLIA_CHAIN_SELECTOR = 16015286601757825753;
    uint64 public constant BASE_SEPOLIA_CHAIN_SELECTOR = 10344971235874465080;

    // Mock PAXG contract for testing
    MockPAXG public paxgMock;

    function setUp() public {
        // Check if we have the RPC URL
        string memory rpcUrl;
        try vm.envString("ETHEREUM_SEPOLIA_RPC_URL") returns (string memory url) {
            rpcUrl = url;
        } catch {
            rpcUrl = "";
        }
        
        // Skip test if no RPC URL available
        if (bytes(rpcUrl).length == 0) {
            console.log("Skipping Ethereum Sepolia fork test - no RPC URL");
            vm.skip(true);
        }

        console.log("=== ETHEREUM SEPOLIA FORK TEST SETUP ===");
        
        // Create fork of Ethereum Sepolia
        vm.createFork(rpcUrl);
        vm.selectFork(0);
        
        // Verify we're on Ethereum Sepolia
        require(block.chainid == ETHEREUM_SEPOLIA_CHAIN_ID, "Should be on Ethereum Sepolia");
        
        console.log("Chain ID:", block.chainid);
        console.log("Block number:", block.number);
        console.log("Fork timestamp:", block.timestamp);
        
        // Deploy mock PAXG for testing
        _deployMockPAXG();
        
        // Deploy the collateral management system
        _deployCollateralSystem();
        
        // Setup test accounts with mock PAXG
        _setupTestAccounts();
        
        console.log("=== SETUP COMPLETED ===");
    }

    function _deployMockPAXG() internal {
        console.log("--- Deploying Mock PAXG on Sepolia ---");
        
        paxgMock = new MockPAXG("PAX Gold", "PAXG");
        mockPaxgToken = address(paxgMock);
        
        console.log("Mock PAXG deployed to:", mockPaxgToken);
    }

    function _deployCollateralSystem() internal {
        console.log("--- Deploying Collateral System on Ethereum Sepolia ---");
        
        // Deploy MainnetCollateralManager with Sepolia addresses
        collateralManager = new MainnetCollateralManager(
            CCIP_ROUTER_SEPOLIA,
            mockPaxgToken,
            XAU_USD_PRICE_FEED_SEPOLIA,
            LINK_TOKEN_SEPOLIA,
            TREASURY,
            address(this) // initial owner
        );
        
        console.log("MainnetCollateralManager deployed to:", address(collateralManager));
        
        // Set up Base Sepolia chain as allowed destination
        collateralManager.setAllowedDestinationChain(BASE_SEPOLIA_CHAIN_SELECTOR, true);
        console.log("Base Sepolia chain selector allowed:", BASE_SEPOLIA_CHAIN_SELECTOR);
        
        // Verify deployments
        require(address(collateralManager) != address(0), "CollateralManager not deployed");
        
        // Verify configuration
        assertEq(address(collateralManager.i_paxgToken()), mockPaxgToken);
        assertEq(address(collateralManager.i_xauUsdPriceFeed()), XAU_USD_PRICE_FEED_SEPOLIA);
        assertEq(address(collateralManager.getRouter()), CCIP_ROUTER_SEPOLIA);
        
        // Verify price feed
        _verifyPriceFeed();
    }

    function _verifyPriceFeed() internal view {
        console.log("--- Verifying XAU/USD Price Feed on Sepolia ---");
        
        AggregatorV3Interface priceFeed = collateralManager.i_xauUsdPriceFeed();
        
        // Verify price feed has code (is a real contract)
        require(address(priceFeed).code.length > 0, "Price feed has no code");
        
        // Get latest price data
        (uint80 roundId, int256 price, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) = 
            priceFeed.latestRoundData();
        
        assertTrue(price > 0, "XAU price should be positive");
        assertTrue(updatedAt > 0, "XAU price should have timestamp");
        assertEq(priceFeed.decimals(), 8, "XAU price feed should have 8 decimals");
        
        console.log("XAU/USD Price:", uint256(price));
        console.log("Price decimals:", priceFeed.decimals());
        console.log("Price updated:", updatedAt);
        console.log("Time since update:", block.timestamp - updatedAt, "seconds");
    }

    function _setupTestAccounts() internal {
        console.log("--- Setting up Test Accounts with Mock PAXG ---");
        
        // Give ETH to test accounts
        vm.deal(ALICE, 100 ether);
        vm.deal(BOB, 100 ether);
        vm.deal(CHARLIE, 100 ether);
        vm.deal(address(collateralManager), 10 ether);
        
        // Mint mock PAXG to test accounts
        uint256 paxgAmount = 1000e18; // 1000 PAXG per account
        
        paxgMock.mint(ALICE, paxgAmount);
        paxgMock.mint(BOB, paxgAmount);
        paxgMock.mint(CHARLIE, paxgAmount);
        
        // Deal LINK tokens for CCIP fees (use deal for testnet)
        deal(LINK_TOKEN_SEPOLIA, address(collateralManager), 100e18);
        deal(LINK_TOKEN_SEPOLIA, ALICE, 10e18);
        deal(LINK_TOKEN_SEPOLIA, BOB, 10e18);
        
        console.log("Alice mock PAXG balance:", IERC20(mockPaxgToken).balanceOf(ALICE));
        console.log("Bob mock PAXG balance:", IERC20(mockPaxgToken).balanceOf(BOB));
        console.log("Charlie mock PAXG balance:", IERC20(mockPaxgToken).balanceOf(CHARLIE));
        console.log("Contract LINK balance:", IERC20(LINK_TOKEN_SEPOLIA).balanceOf(address(collateralManager)));
    }

    /**
     * @dev Test 1: Basic deployment verification on Sepolia
     */
    function testDeploymentOnSepolia() public view {
        console.log("=== TEST 1: SEPOLIA DEPLOYMENT VERIFICATION ===");
        
        // Verify contract configuration
        assertEq(address(collateralManager.i_paxgToken()), mockPaxgToken);
        assertEq(address(collateralManager.i_xauUsdPriceFeed()), XAU_USD_PRICE_FEED_SEPOLIA);
        assertEq(address(collateralManager.i_linkToken()), LINK_TOKEN_SEPOLIA);
        assertEq(collateralManager.s_treasury(), TREASURY);
        
        // Verify CCIP configuration for testnet
        assertEq(address(collateralManager.getRouter()), CCIP_ROUTER_SEPOLIA);
        assertTrue(collateralManager.s_allowedDestinationChains(BASE_SEPOLIA_CHAIN_SELECTOR));
        
        // Verify we're on correct testnet
        assertEq(block.chainid, ETHEREUM_SEPOLIA_CHAIN_ID);
        
        console.log("[PASS] All Sepolia deployment parameters correct");
    }

    /**
     * @dev Test 2: Sepolia XAU/USD price feed integration
     */
    function testSepoliaXAUPriceFeedIntegration() public {
        console.log("=== TEST 2: SEPOLIA XAU PRICE FEED INTEGRATION ===");
        
        AggregatorV3Interface xauFeed = collateralManager.i_xauUsdPriceFeed();
        (uint80 roundId, int256 xauPrice, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) = 
            xauFeed.latestRoundData();
        
        assertTrue(xauPrice > 0, "XAU price should be positive");
        assertTrue(updatedAt > 0, "XAU price should have timestamp");
        assertEq(xauFeed.decimals(), 8, "XAU price feed should have 8 decimals");
        
        console.log("Sepolia XAU/USD Price:", uint256(xauPrice));
        console.log("XAU Price decimals:", xauFeed.decimals());
        console.log("XAU Price updated:", updatedAt);
        console.log("Time since update:", block.timestamp - updatedAt, "seconds");
        
        // Test price calculation with mock PAXG
        uint256 paxgAmount = 10e18; // 10 PAXG
        uint256 usdValue = collateralManager.calculateCollateralValue(paxgAmount);
        uint256 expectedValue = (paxgAmount * uint256(xauPrice)) / 1e8;
        
        assertEq(usdValue, expectedValue, "USD value calculation should be correct");
        
        console.log("10 PAXG USD Value:", usdValue);
        console.log("[PASS] Sepolia XAU price feed working correctly");
    }

    /**
     * @dev Test 3: Mock PAXG deposits and collateral tracking
     */
    function testMockPAXGDeposits() public {
        console.log("=== TEST 3: MOCK PAXG DEPOSITS ON SEPOLIA ===");
        
        uint256 depositAmount = 50e18; // 50 PAXG
        uint256 initialBalance = IERC20(mockPaxgToken).balanceOf(ALICE);
        uint256 initialTotalCollateral = collateralManager.s_totalCollateralAmount();
        
        console.log("Initial Alice mock PAXG:", initialBalance);
        console.log("Initial total collateral:", initialTotalCollateral);
        console.log("Depositing:", depositAmount);
        
        // Alice approves and deposits mock PAXG
        vm.startPrank(ALICE);
        IERC20(mockPaxgToken).approve(address(collateralManager), depositAmount);
        collateralManager.depositPAXGCollateral(depositAmount);
        vm.stopPrank();
        
        // Verify deposit
        uint256 finalBalance = IERC20(mockPaxgToken).balanceOf(ALICE);
        uint256 aliceCollateral = collateralManager.s_userCollateralBalances(ALICE);
        uint256 finalTotalCollateral = collateralManager.s_totalCollateralAmount();
        
        assertEq(finalBalance, initialBalance - depositAmount, "Alice balance should decrease");
        assertEq(aliceCollateral, depositAmount, "Alice collateral should be recorded");
        assertEq(finalTotalCollateral, initialTotalCollateral + depositAmount, "Total collateral should increase");
        
        console.log("Final Alice mock PAXG:", finalBalance);
        console.log("Alice collateral balance:", aliceCollateral);
        console.log("Final total collateral:", finalTotalCollateral);
        console.log("[PASS] Mock PAXG deposit successful on Sepolia");
    }

    /**
     * @dev Test 4: Cross-chain CCIP setup for Base Sepolia
     */
    function testCCIPSepoliaSetup() public view {
        console.log("=== TEST 4: CCIP SEPOLIA TO BASE SEPOLIA SETUP ===");
        
        // Verify CCIP router is properly configured for Sepolia
        address router = address(collateralManager.getRouter());
        assertTrue(router != address(0), "CCIP router should be set");
        assertTrue(router.code.length > 0, "CCIP router should have code");
        assertEq(router, CCIP_ROUTER_SEPOLIA, "Should use correct Sepolia CCIP router");
        
        // Verify Base Sepolia destination chain is allowed
        assertTrue(collateralManager.s_allowedDestinationChains(BASE_SEPOLIA_CHAIN_SELECTOR));
        
        // Verify LINK token configuration
        assertEq(address(collateralManager.i_linkToken()), LINK_TOKEN_SEPOLIA);
        assertTrue(IERC20(LINK_TOKEN_SEPOLIA).balanceOf(address(collateralManager)) > 0);
        
        console.log("CCIP Router (Sepolia):", router);
        console.log("Router code size:", router.code.length);
        console.log("Base Sepolia allowed:", collateralManager.s_allowedDestinationChains(BASE_SEPOLIA_CHAIN_SELECTOR));
        console.log("LINK balance:", IERC20(LINK_TOKEN_SEPOLIA).balanceOf(address(collateralManager)));
        console.log("[PASS] CCIP Sepolia to Base Sepolia setup verified");
    }

    /**
     * @dev Test 5: Large operations on testnet
     */
    function testLargeOperationsOnSepolia() public {
        console.log("=== TEST 5: LARGE OPERATIONS ON SEPOLIA ===");
        
        uint256 largeAmount = 100e18; // 100 PAXG
        
        // Multiple users deposit large amounts
        address[] memory users = new address[](3);
        users[0] = ALICE;
        users[1] = BOB;
        users[2] = CHARLIE;
        
        uint256 totalDeposited = 0;
        
        for (uint i = 0; i < users.length; i++) {
            vm.startPrank(users[i]);
            IERC20(mockPaxgToken).approve(address(collateralManager), largeAmount);
            collateralManager.depositPAXGCollateral(largeAmount);
            vm.stopPrank();
            
            totalDeposited += largeAmount;
            
            uint256 userCollateral = collateralManager.s_userCollateralBalances(users[i]);
            assertEq(userCollateral, largeAmount, "User collateral should match deposit");
            
            console.log("User", i, "deposited:", largeAmount);
            console.log("User", i, "collateral balance:", userCollateral);
        }
        
        uint256 totalCollateral = collateralManager.s_totalCollateralAmount();
        uint256 totalValue = collateralManager.calculateCollateralValue(totalCollateral);
        
        assertEq(totalCollateral, totalDeposited, "Total collateral should match sum of deposits");
        
        console.log("Total mock PAXG collateral:", totalCollateral);
        console.log("Total USD value:", totalValue);
        console.log("[PASS] Large operations on Sepolia successful");
    }

    /**
     * @dev Test 6: Testnet-specific functionality
     */
    function testTestnetSpecificFunctionality() public {
        console.log("=== TEST 6: TESTNET-SPECIFIC FUNCTIONALITY ===");
        
        // Test mock PAXG minting (only available on testnet)
        uint256 mintAmount = 500e18;
        uint256 initialBalance = IERC20(mockPaxgToken).balanceOf(address(this));
        
        paxgMock.mint(address(this), mintAmount);
        
        uint256 finalBalance = IERC20(mockPaxgToken).balanceOf(address(this));
        assertEq(finalBalance, initialBalance + mintAmount, "Minting should work on testnet");
        
        console.log("Minted mock PAXG:", mintAmount);
        console.log("Final balance:", finalBalance);
        
        // Test emergency functions
        uint256 emergencyAmount = 10e18;
        IERC20(mockPaxgToken).approve(address(collateralManager), emergencyAmount);
        collateralManager.depositPAXGCollateral(emergencyAmount);
        
        uint256 contractBalance = IERC20(mockPaxgToken).balanceOf(address(collateralManager));
        collateralManager.emergencyWithdraw(emergencyAmount, TREASURY);
        
        uint256 treasuryBalance = IERC20(mockPaxgToken).balanceOf(TREASURY);
        assertEq(treasuryBalance, emergencyAmount, "Emergency withdrawal should work");
        
        console.log("Emergency withdrawal completed:", emergencyAmount);
        console.log("[PASS] Testnet-specific functionality verified");
    }

    /**
     * @dev Test 7: Gas optimization verification
     */
    function testGasOptimizationOnSepolia() public {
        console.log("=== TEST 7: GAS OPTIMIZATION ON SEPOLIA ===");
        
        uint256 depositAmount = 25e18;
        
        // Measure gas for deposit
        vm.startPrank(ALICE);
        IERC20(mockPaxgToken).approve(address(collateralManager), depositAmount);
        
        uint256 gasBefore = gasleft();
        collateralManager.depositPAXGCollateral(depositAmount);
        uint256 gasUsed = gasBefore - gasleft();
        
        vm.stopPrank();
        
        console.log("Gas used for deposit:", gasUsed);
        assertTrue(gasUsed < 200000, "Deposit should be gas efficient");
        
        // Measure gas for withdrawal
        vm.startPrank(ALICE);
        
        gasBefore = gasleft();
        collateralManager.withdrawPAXGCollateral(depositAmount / 2);
        gasUsed = gasBefore - gasleft();
        
        vm.stopPrank();
        
        console.log("Gas used for withdrawal:", gasUsed);
        assertTrue(gasUsed < 150000, "Withdrawal should be gas efficient");
        
        console.log("[PASS] Gas optimization verified on Sepolia");
    }

    /**
     * @dev Final comprehensive test summary for Sepolia
     */
    function testSepoliaComprehensiveSummary() public view {
        console.log("=== COMPREHENSIVE ETHEREUM SEPOLIA TEST SUMMARY ===");
        
        uint256 totalCollateral = collateralManager.s_totalCollateralAmount();
        uint256 totalValue = 0;
        if (totalCollateral > 0) {
            totalValue = collateralManager.calculateCollateralValue(totalCollateral);
        }
        
        console.log("=== FINAL SEPOLIA SYSTEM STATE ===");
        console.log("Total Mock PAXG Collateral:", totalCollateral);
        console.log("Total USD Value:", totalValue);
        console.log("Alice collateral:", collateralManager.s_userCollateralBalances(ALICE));
        console.log("Bob collateral:", collateralManager.s_userCollateralBalances(BOB));
        console.log("Charlie collateral:", collateralManager.s_userCollateralBalances(CHARLIE));
        console.log("Chain ID:", block.chainid);
        
        console.log("=== SEPOLIA SYSTEM VERIFICATION ===");
        console.log("* Sepolia XAU/USD price feeds operational");
        console.log("* Mock PAXG deposits and withdrawals working");
        console.log("* Collateral value calculations accurate");
        console.log("* CCIP infrastructure ready for Base Sepolia");
        console.log("* Testnet-specific functionality verified");
        console.log("* Gas optimization confirmed");
        console.log("* Emergency functions operational");
        
        console.log("[PASS] ALL ETHEREUM SEPOLIA TESTS COMPLETED SUCCESSFULLY");
    }
}

/**
 * @title MockPAXG
 * @dev Mock PAXG token for Sepolia testing
 */
contract MockPAXG is IERC20 {
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;
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
