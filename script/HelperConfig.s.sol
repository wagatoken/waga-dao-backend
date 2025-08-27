// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
import {MockCCIPRouter} from "@chainlink/contracts/src/v0.8/ccip/test/mocks/MockRouter.sol";

/**
 * @title HelperConfig (Enhanced Multi-Chain)
 * @dev Configuration helper for deploying WAGA DAO contracts across multiple networks
 * @dev Provides network-specific configurations for Ethereum, Base, and Arbitrum
 */
contract HelperConfig is Script {
    /* -------------------------------------------------------------------------- */
    /*                                   STRUCTS                                 */
    /* -------------------------------------------------------------------------- */
    
    struct NetworkConfig {
        // Token addresses
        address ethToken;           // ETH address (address(0) for native ETH)
        address usdcToken;          // USDC token address
        address paxgToken;          // PAXG token address (only on Ethereum)
        address linkToken;          // LINK token address
        
        // Price feed addresses
        address ethUsdPriceFeed;    // Chainlink ETH/USD price feed
        address xauUsdPriceFeed;    // Chainlink XAU/USD price feed (for PAXG)
        
        // CCIP configuration
        address ccipRouter;         // Chainlink CCIP router
        uint64 ethereumChainSelector; // Ethereum chain selector for CCIP
        uint64 baseChainSelector;   // Base chain selector for CCIP
        uint64 arbitrumChainSelector; // Arbitrum chain selector for CCIP
        
        // Aave configuration (Arbitrum only)
        address aavePool;           // Aave V3 Pool address
        address aUsdcToken;         // aUSDC token address
        
        // System addresses
        address identityRegistry;   // Identity registry (placeholder for cross-chain)
        address treasury;           // Treasury address
        
        // Deployment
        uint256 deployerKey;        // Private key for deployment
    }

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */
    
    mapping(uint256 => NetworkConfig) private s_networkConfigs;
    NetworkConfig public activeNetworkConfig;
    
    uint256 public constant DEFAULT_ANVIL_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    
    // Mock price feed constants
    uint8 public constant DECIMALS = 8;
    int256 public constant ETH_USD_PRICE = 3000e8;  // $3000 per ETH
    int256 public constant XAU_USD_PRICE = 2000e8;  // $2000 per ounce of gold (PAXG)
    
    // CCIP Chain Selectors (production values)
    uint64 public constant ETHEREUM_CHAIN_SELECTOR = 5009297550715157269;   // Ethereum mainnet
    uint64 public constant BASE_CHAIN_SELECTOR = 15971525489660198786;      // Base mainnet  
    uint64 public constant ARBITRUM_CHAIN_SELECTOR = 4949039107694359620;   // Arbitrum One

    /* -------------------------------------------------------------------------- */
    /*                                CONSTRUCTOR                                 */
    /* -------------------------------------------------------------------------- */
    
    constructor() {
        // Initialize network configurations for multi-chain deployment
        s_networkConfigs[1] = getEthereumMainnetConfig();      // Ethereum Mainnet
        s_networkConfigs[8453] = getBaseMainnetConfig();       // Base Mainnet
        s_networkConfigs[42161] = getArbitrumMainnetConfig();  // Arbitrum One
        s_networkConfigs[11155111] = getSepoliaEthConfig();    // Ethereum Sepolia
        s_networkConfigs[84532] = getBaseSepoliaConfig();      // Base Sepolia
        s_networkConfigs[421614] = getArbitrumSepoliaConfig(); // Arbitrum Sepolia

        // Set the active network configuration
        activeNetworkConfig = s_networkConfigs[block.chainid];

        // If no configuration exists for the current chain, create a default one
        if (activeNetworkConfig.usdcToken == address(0)) {
            activeNetworkConfig = getOrCreateAnvilConfig();
        }
    }

    /* -------------------------------------------------------------------------- */
    /*                          MAINNET CONFIGURATIONS                           */
    /* -------------------------------------------------------------------------- */

    /**
     * @dev Returns the configuration for Ethereum Mainnet
     */
    function getEthereumMainnetConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            ethToken: address(0), // Native ETH
            usdcToken: 0xA0B86A33E6441B8c7005aC4d2c1618F63d6d3c3a, // USDC on Ethereum
            paxgToken: 0x45804880De22913dAFE09f4980848ECE6EcbAf78, // PAXG on Ethereum
            linkToken: 0x514910771AF9Ca656af840dff83E8264EcF986CA, // LINK on Ethereum
            ethUsdPriceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419, // ETH/USD on Ethereum
            xauUsdPriceFeed: 0x214eD9Da11D2fbe465a6fc601a91E62EbEc1a0D6, // XAU/USD on Ethereum
            ccipRouter: 0x80226fc0Ee2b096224EeAc085Bb9a8cba1146f7D, // CCIP Router on Ethereum
            ethereumChainSelector: ETHEREUM_CHAIN_SELECTOR,
            baseChainSelector: BASE_CHAIN_SELECTOR,
            arbitrumChainSelector: ARBITRUM_CHAIN_SELECTOR,
            aavePool: address(0), // Not used on Ethereum
            aUsdcToken: address(0), // Not used on Ethereum
            identityRegistry: address(0), // Placeholder (will be on Base)
            treasury: 0x1234567890123456789012345678901234567890, // Replace with actual treasury
            deployerKey: 0 // Will be set from environment
        });
    }

    /**
     * @dev Returns the configuration for Base Mainnet
     */
    function getBaseMainnetConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            ethToken: address(0), // Native ETH
            usdcToken: 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913, // USDC on Base
            paxgToken: address(0), // PAXG not available on Base
            linkToken: 0x88Fb150BDc53A65fe94Dea0c9BA0a6dAf8C6e196, // LINK on Base
            ethUsdPriceFeed: 0x71041dddad3595F9CEd3DcCFBe3D1F4b0a16Bb70, // ETH/USD on Base
            xauUsdPriceFeed: address(0), // Will use Ethereum's XAU/USD via CCIP
            ccipRouter: 0x881e3A65B4d4a04dD529061dd0071cf975F58bCD, // CCIP Router on Base
            ethereumChainSelector: ETHEREUM_CHAIN_SELECTOR,
            baseChainSelector: BASE_CHAIN_SELECTOR,
            arbitrumChainSelector: ARBITRUM_CHAIN_SELECTOR,
            aavePool: address(0), // Not used on Base
            aUsdcToken: address(0), // Not used on Base
            identityRegistry: address(0), // Will be deployed on Base
            treasury: 0x1234567890123456789012345678901234567890, // Replace with actual treasury
            deployerKey: 0 // Will be set from environment
        });
    }

    /**
     * @dev Returns the configuration for Arbitrum One
     */
    function getArbitrumMainnetConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            ethToken: address(0), // Native ETH
            usdcToken: 0xaf88d065e77c8cC2239327C5EDb3A432268e5831, // USDC on Arbitrum
            paxgToken: address(0), // PAXG not available on Arbitrum
            linkToken: 0xf97f4df75117a78c1A5a0DBb814Af92458539FB4, // LINK on Arbitrum
            ethUsdPriceFeed: 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612, // ETH/USD on Arbitrum
            xauUsdPriceFeed: address(0), // Not needed on Arbitrum
            ccipRouter: 0x141fa059441E0ca23ce184B6A78bafD2A517DdE8, // CCIP Router on Arbitrum
            ethereumChainSelector: ETHEREUM_CHAIN_SELECTOR,
            baseChainSelector: BASE_CHAIN_SELECTOR,
            arbitrumChainSelector: ARBITRUM_CHAIN_SELECTOR,
            aavePool: 0x794a61358D6845594F94dc1DB02A252b5b4814aD, // Aave V3 Pool on Arbitrum
            aUsdcToken: 0x625E7708f30cA75bfd92586e17077590C60eb4cD, // aUSDC on Arbitrum
            identityRegistry: address(0), // Placeholder (will be on Base)
            treasury: 0x1234567890123456789012345678901234567890, // Replace with actual treasury
            deployerKey: 0 // Will be set from environment
        });
    }

    /**
     * @dev Returns the configuration for Ethereum Sepolia testnet
     */
    function getSepoliaEthConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            ethToken: address(0), // Native ETH
            usdcToken: 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238, // USDC on Sepolia
            paxgToken: 0x9999f7Fea5938fD3b1E26A12c3f2fb024e194f97, // Mock PAXG on Sepolia
            linkToken: 0x779877A7B0D9E8603169DdbD7836e478b4624789, // LINK on Sepolia
            ethUsdPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306, // ETH/USD on Sepolia
            xauUsdPriceFeed: 0xC5981F461d74c46eB4b0CF3f4Ec79f025573B0Ea, // XAU/USD on Sepolia
            ccipRouter: 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59, // CCIP Router on Sepolia
            ethereumChainSelector: 16015286601757825753, // Sepolia chain selector
            baseChainSelector: 10344971235874465080, // Base Sepolia chain selector
            arbitrumChainSelector: 3478487238524512106, // Arbitrum Sepolia chain selector
            aavePool: address(0), // Not used on Ethereum
            aUsdcToken: address(0), // Not used on Ethereum
            identityRegistry: address(0), // Placeholder
            treasury: 0x1234567890123456789012345678901234567890, // Replace with actual treasury
            deployerKey: vm.envUint("PRIVATE_KEY_SEP")
        });
    }

    /**
     * @dev Returns the configuration for Base Sepolia testnet
     */
    function getBaseSepoliaConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            ethToken: address(0), // Native ETH
            usdcToken: 0x036CbD53842c5426634e7929541eC2318f3dCF7e, // USDC on Base Sepolia
            paxgToken: address(0), // PAXG not available on Base
            linkToken: 0xE4aB69C077896252FAFBD49EFD26B5D171A32410, // LINK on Base Sepolia
            ethUsdPriceFeed: 0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc7cb1, // ETH/USD on Base Sepolia
            xauUsdPriceFeed: 0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc7cb1, // Using ETH/USD as XAU/USD placeholder for testing
            ccipRouter: 0xD3b06cEbF099CE7DA4AcCf578aaebFDBd6e88a93, // CCIP Router on Base Sepolia
            ethereumChainSelector: 16015286601757825753, // Sepolia chain selector
            baseChainSelector: 10344971235874465080, // Base Sepolia chain selector
            arbitrumChainSelector: 3478487238524512106, // Arbitrum Sepolia chain selector
            aavePool: address(0), // Not used on Base
            aUsdcToken: address(0), // Not used on Base
            identityRegistry: address(0), // Will be deployed on Base
            treasury: 0x1234567890123456789012345678901234567890, // Replace with actual treasury
            deployerKey: vm.envUint("PRIVATE_KEY_SEP")
        });
    }

    /**
     * @dev Returns the configuration for Arbitrum Sepolia testnet
     */
    function getArbitrumSepoliaConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            ethToken: address(0), // Native ETH
            usdcToken: 0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d, // USDC on Arbitrum Sepolia
            paxgToken: address(0), // PAXG not available on Arbitrum
            linkToken: 0xb1D4538B4571d411F07960EF2838Ce337FE1E80E, // LINK on Arbitrum Sepolia
            ethUsdPriceFeed: 0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165, // ETH/USD on Arbitrum Sepolia
            xauUsdPriceFeed: address(0), // Not needed on Arbitrum
            ccipRouter: 0x2a9C5afB0d0e4BAb2BCdaE109EC4b0c4Be15a165, // CCIP Router on Arbitrum Sepolia
            ethereumChainSelector: 16015286601757825753, // Sepolia chain selector
            baseChainSelector: 10344971235874465080, // Base Sepolia chain selector
            arbitrumChainSelector: 3478487238524512106, // Arbitrum Sepolia chain selector
            aavePool: 0xBfC91D59fdAA134A4ED45f7B584cAf96D7792Eff, // Aave V3 Pool on Arbitrum Sepolia
            aUsdcToken: 0x460b97BD498E1157530AEb3086301d5225b91216, // aUSDC on Arbitrum Sepolia
            identityRegistry: address(0), // Placeholder
            treasury: 0x1234567890123456789012345678901234567890, // Replace with actual treasury
            deployerKey: vm.envUint("PRIVATE_KEY_SEP")
        });
    }

    /**
     * @dev Creates or retrieves the configuration for the local Anvil network
     */
    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.usdcToken != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();

        // Deploy mock price feeds for local testing
        MockV3Aggregator ethUsdPriceFeed = new MockV3Aggregator(DECIMALS, ETH_USD_PRICE);
        MockV3Aggregator xauUsdPriceFeed = new MockV3Aggregator(DECIMALS, XAU_USD_PRICE);

        // Deploy mock tokens for local testing
        ERC20Mock usdcMock = new ERC20Mock();
        ERC20Mock paxgMock = new ERC20Mock();
        ERC20Mock linkMock = new ERC20Mock();
        ERC20Mock aUsdcMock = new ERC20Mock();
        
        // Deploy mock CCIP router for local testing
        MockCCIPRouter mockCcipRouter = new MockCCIPRouter();

        vm.stopBroadcast();

        return NetworkConfig({
            ethToken: address(0), // Native ETH
            usdcToken: address(usdcMock),
            paxgToken: address(paxgMock),
            linkToken: address(linkMock),
            ethUsdPriceFeed: address(ethUsdPriceFeed),
            xauUsdPriceFeed: address(xauUsdPriceFeed),
            ccipRouter: address(mockCcipRouter), // Mock CCIP router
            ethereumChainSelector: 1, // Mock chain selector
            baseChainSelector: 2, // Mock chain selector
            arbitrumChainSelector: 3, // Mock chain selector
            aavePool: address(0x2222222222222222222222222222222222222222), // Mock Aave pool
            aUsdcToken: address(aUsdcMock),
            identityRegistry: address(0), // Will be deployed
            treasury: address(0x3333333333333333333333333333333333333333), // Mock treasury
            deployerKey: DEFAULT_ANVIL_KEY
        });
    }

    /* -------------------------------------------------------------------------- */
    /*                              HELPER FUNCTIONS                             */
    /* -------------------------------------------------------------------------- */

    /**
     * @dev Get the configuration for a specific chain ID
     */
    function getConfigByChainId(uint256 chainId) public returns (NetworkConfig memory) {
        NetworkConfig memory config = s_networkConfigs[chainId];
        
        // If no configuration exists for the current chain, create a default one
        if (config.usdcToken == address(0)) {
            config = getOrCreateAnvilConfig();
            // Store it in the mapping for future use
            s_networkConfigs[chainId] = config;
        }
        
        return config;
    }

    /**
     * @dev Check if a chain has PAXG available (only Ethereum mainnet and testnets)
     */
    function hasPaxg(uint256 chainId) public pure returns (bool) {
        return chainId == 1 || chainId == 11155111; // Ethereum mainnet or Sepolia
    }

    /**
     * @dev Check if a chain has Aave integration (only Arbitrum)
     */
    function hasAave(uint256 chainId) public pure returns (bool) {
        return chainId == 42161 || chainId == 421614; // Arbitrum One or Sepolia
    }

    /**
     * @dev Get the current network's chain selector for CCIP
     */
    function getCurrentChainSelector() public view returns (uint64) {
        uint256 chainId = block.chainid;
        if (chainId == 1) return ETHEREUM_CHAIN_SELECTOR;
        if (chainId == 8453) return BASE_CHAIN_SELECTOR;
        if (chainId == 42161) return ARBITRUM_CHAIN_SELECTOR;
        if (chainId == 11155111) return 16015286601757825753; // Sepolia
        if (chainId == 84532) return 10344971235874465080; // Base Sepolia
        if (chainId == 421614) return 3478487238524512106; // Arbitrum Sepolia
        return 0; // Unknown chain
    }
}
