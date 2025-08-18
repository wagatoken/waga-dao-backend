// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

/**
 * @title HelperConfig
 * @dev Configuration helper for deploying WAGA DAO contracts across different networks
 * @dev Provides network-specific configurations including price feeds for dynamic conversions
 */
contract HelperConfig is Script {
    /* -------------------------------------------------------------------------- */
    /*                                   STRUCTS                                 */
    /* -------------------------------------------------------------------------- */
    
    struct NetworkConfig {
        address ethToken;           // ETH address (address(0) for native ETH)
        address usdcToken;          // USDC token address
        address paxgToken;          // PAXG token address
        address ethUsdPriceFeed;    // Chainlink ETH/USD price feed
        address paxgUsdPriceFeed;   // Chainlink PAXG/USD price feed
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
    int256 public constant PAXG_USD_PRICE = 2000e8; // $2000 per PAXG

    /* -------------------------------------------------------------------------- */
    /*                                CONSTRUCTOR                                 */
    /* -------------------------------------------------------------------------- */
    
    constructor() {
        // Initialize network configurations for primary networks only
        s_networkConfigs[11155111] = getSepoliaEthConfig();    // Ethereum Sepolia
        s_networkConfigs[84532] = getBaseSepoliaConfig();      // Base Sepolia

        // Set the active network configuration
        activeNetworkConfig = s_networkConfigs[block.chainid];

        // If no configuration exists for the current chain, create a default one
        if (activeNetworkConfig.usdcToken == address(0)) {
            activeNetworkConfig = getOrCreateAnvilConfig();
        }
    }

    /* -------------------------------------------------------------------------- */
    /*                          NETWORK CONFIGURATIONS                           */
    /* -------------------------------------------------------------------------- */

    /**
     * @dev Returns the configuration for Ethereum Sepolia testnet
     */
    function getSepoliaEthConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            ethToken: address(0), // Native ETH
            usdcToken: 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238, // USDC on Sepolia
            paxgToken: 0x9999f7Fea5938fD3b1E26A12c3f2fb024e194f97, // Mock PAXG on Sepolia
            ethUsdPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306, // ETH/USD on Sepolia
            paxgUsdPriceFeed: 0x9999f7Fea5938fD3b1E26A12c3f2fb024e194f97, // Mock PAXG/USD on Sepolia (placeholder)
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
            paxgToken: 0x9999f7Fea5938fD3b1E26A12c3f2fb024e194f97, // Mock PAXG on Base Sepolia
            ethUsdPriceFeed: 0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc7cb1, // ETH/USD on Base Sepolia
            paxgUsdPriceFeed: 0x9999f7Fea5938fD3b1E26A12c3f2fb024e194f97, // Mock PAXG/USD on Base Sepolia (placeholder)
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
        MockV3Aggregator paxgUsdPriceFeed = new MockV3Aggregator(DECIMALS, PAXG_USD_PRICE);

        // Deploy mock tokens for local testing
        ERC20Mock usdcMock = new ERC20Mock();
        ERC20Mock paxgMock = new ERC20Mock();

        vm.stopBroadcast();

        return NetworkConfig({
            ethToken: address(0), // Native ETH
            usdcToken: address(usdcMock),
            paxgToken: address(paxgMock),
            ethUsdPriceFeed: address(ethUsdPriceFeed),
            paxgUsdPriceFeed: address(paxgUsdPriceFeed),
            deployerKey: DEFAULT_ANVIL_KEY
        });
    }
}
