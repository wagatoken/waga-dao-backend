// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

/**
 * @title HelperConfig
 * @notice Configuration helper for deploying Lion Heart DAO contracts across different networks
 * @dev Provides network-specific configurations for deployment scripts
 */
contract HelperConfig is Script {
    /* -------------------------------------------------------------------------- */
    /*                                   STRUCTS                                 */
    /* -------------------------------------------------------------------------- */
    
    struct NetworkConfig {
        address usdcToken;      // USDC token address
        address paxgToken;      // PAXG token address  
        uint256 deployerKey;    // Private key for deployment
    }

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */
    
    mapping(uint256 => NetworkConfig) private s_networkConfigs;
    NetworkConfig public activeNetworkConfig;
    
    uint256 public constant DEFAULT_ANVIL_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

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
            usdcToken: 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238, // USDC on Sepolia
            paxgToken: 0x9999f7Fea5938fD3b1E26A12c3f2fb024e194f97, // Mock PAXG on Sepolia
            deployerKey: vm.envUint("PRIVATE_KEY_SEP")
        });
    }

    /**
     * @dev Returns the configuration for Base Sepolia testnet
     */
    function getBaseSepoliaConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            usdcToken: 0x036CbD53842c5426634e7929541eC2318f3dCF7e, // USDC on Base Sepolia
            paxgToken: 0x9999f7Fea5938fD3b1E26A12c3f2fb024e194f97, // Mock PAXG on Base Sepolia
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

        // Deploy mock tokens for local testing
        ERC20Mock usdcMock = new ERC20Mock();
        ERC20Mock paxgMock = new ERC20Mock();

        vm.stopBroadcast();

        return NetworkConfig({
            usdcToken: address(usdcMock),
            paxgToken: address(paxgMock),
            deployerKey: DEFAULT_ANVIL_KEY
        });
    }
}
