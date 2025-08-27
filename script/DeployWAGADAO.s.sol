// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

// Mainnet contracts
import {MainnetCollateralManager} from "../src/mainnet/MainnetCollateralManager.sol";

// Base contracts  
import {DonationHandler} from "../src/base/DonationHandler.sol";
import {CooperativeGrantManagerV2} from "../src/base/CooperativeGrantManagerV2.sol";

// Manager contracts
import {GreenfieldProjectManager} from "../src/managers/GreenfieldProjectManager.sol";

// Arbitrum contracts
import {ArbitrumLendingManager} from "../src/arbitrum/ArbitrumLendingManager.sol";

// Shared contracts
import {VERTGovernanceToken} from "../src/shared/VERTGovernanceToken.sol";
import {WAGACoffeeInventoryTokenV2} from "../src/shared/WAGACoffeeInventoryTokenV2.sol";
import {IdentityRegistry} from "../src/shared/IdentityRegistry.sol";
import {WAGAGovernor} from "../src/shared/WAGAGovernor.sol";
import {WAGATimelock} from "../src/shared/WAGATimelock.sol";

/**
 * @title DeployWAGADAO
 * @dev Multi-chain deployment script for WAGA DAO
 * @author WAGA DAO - Regenerative Coffee Global Impact
 * 
 * Deploys appropriate contracts based on the target chain:
 * 
 * Ethereum Mainnet (Chain ID: 1):
 * - MainnetCollateralManager (PAXG donations via CCIP)
 * 
 * Base Network (Chain ID: 8453):
 * - Complete WAGA DAO ecosystem with CCIP receiving
 * - VERTGovernanceToken, IdentityRegistry, DonationHandler
 * - WAGAGovernor, WAGATimelock, WAGACoffeeInventoryToken
 * - CooperativeGrantManager
 * 
 * Arbitrum (Chain ID: 42161):
 * - ArbitrumLendingManager (USDC lending via Aave V3)
 */
contract DeployWAGADAO is Script {
    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */
    
    HelperConfig public helperConfig;
    
    struct DeploymentAddresses {
        // Mainnet contracts
        address mainnetCollateralManager;
        
        // Base contracts
        address vertGovernanceToken;
        address coffeeInventoryToken;
        address identityRegistry;
        address donationHandler;
        address cooperativeGrantManager;
        address wagaGovernor;
        address wagaTimelock;
        
        // Arbitrum contracts
        address arbitrumLendingManager;
    }
    
    /* -------------------------------------------------------------------------- */
    /*                                MAIN FUNCTION                               */
    /* -------------------------------------------------------------------------- */
    
    function run() external returns (DeploymentAddresses memory) {
        helperConfig = new HelperConfig();
        
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerKey);

        DeploymentAddresses memory deployed;

        // Deploy based on current chain
        uint256 chainId = block.chainid;
        
        if (chainId == 1) {
            // Ethereum Mainnet deployment
            deployed = _deployMainnetContracts();
        } else if (chainId == 8453) {
            // Base Mainnet deployment
            deployed = _deployBaseContracts();
        } else if (chainId == 42161) {
            // Arbitrum deployment
            deployed = _deployArbitrumContracts();
        } else {
            // Testnet/Local deployment (full ecosystem on one chain)
            deployed = _deployTestnetContracts();
        }

        vm.stopBroadcast();
        
        return deployed;
    }
    
    /* -------------------------------------------------------------------------- */
    /*                         CHAIN-SPECIFIC DEPLOYMENTS                        */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev Deploy MainnetCollateralManager on Ethereum Mainnet
     */
    function _deployMainnetContracts() internal returns (DeploymentAddresses memory deployed) {
        HelperConfig.NetworkConfig memory config = helperConfig.getConfigByChainId(block.chainid);
        
        console.log("Deploying on Ethereum Mainnet...");
        
        MainnetCollateralManager collateralManager = new MainnetCollateralManager(
            config.ccipRouter,
            config.paxgToken,
            config.linkToken,
            config.xauUsdPriceFeed,
            config.identityRegistry,
            config.treasury
        );
        
        deployed.mainnetCollateralManager = address(collateralManager);
        
        console.log("MainnetCollateralManager deployed at:", address(collateralManager));
    }
    
    /**
     * @dev Deploy complete ecosystem on Base Network
     */
    function _deployBaseContracts() internal returns (DeploymentAddresses memory deployed) {
        HelperConfig.NetworkConfig memory config = helperConfig.getConfigByChainId(block.chainid);
        
        console.log("Deploying on Base Network...");
        
        // 1. Deploy IdentityRegistry
        IdentityRegistry identityRegistry = new IdentityRegistry(msg.sender);
        deployed.identityRegistry = address(identityRegistry);
        
        // 2. Deploy VERTGovernanceToken
        VERTGovernanceToken vertToken = new VERTGovernanceToken(
            address(identityRegistry),
            msg.sender
        );
        deployed.vertGovernanceToken = address(vertToken);
        
        // 3. Deploy Timelock
        address[] memory proposers = new address[](1);
        address[] memory executors = new address[](1);
        proposers[0] = msg.sender;
        executors[0] = msg.sender;
        
        WAGATimelock timelock = new WAGATimelock(
            2 days,
            proposers,
            executors,
            msg.sender
        );
        deployed.wagaTimelock = address(timelock);
        
        // 4. Deploy Governor
        WAGAGovernor governor = new WAGAGovernor(vertToken, timelock);
        deployed.wagaGovernor = address(governor);
        
        // 5. Deploy GreenfieldProjectManager first
        GreenfieldProjectManager greenfieldManager = new GreenfieldProjectManager(msg.sender);
        
        // 6. Deploy Coffee Inventory Token
        WAGACoffeeInventoryTokenV2 coffeeToken = new WAGACoffeeInventoryTokenV2(
            msg.sender,
            address(greenfieldManager)
        );
        deployed.coffeeInventoryToken = address(coffeeToken);
        
        // 6. Deploy DonationHandler with CCIP support
        DonationHandler donationHandler = new DonationHandler(
            address(vertToken),
            address(identityRegistry),
            config.usdcToken,
            config.ethUsdPriceFeed,
            config.ccipRouter,
            msg.sender, // treasury
            msg.sender  // initial owner
        );
        deployed.donationHandler = address(donationHandler);
        
        // 7. Deploy Cooperative Grant Manager
        CooperativeGrantManagerV2 grantManager = new CooperativeGrantManagerV2(
            config.usdcToken,
            address(coffeeToken),
            msg.sender, // treasury
            msg.sender  // initial admin
        );
        deployed.cooperativeGrantManager = address(grantManager);
        
        // 8. Configure CCIP (allow Ethereum mainnet)
        DonationHandler(donationHandler).setCCIPConfig(config.ethereumChainSelector, true);
        
        // 9. Setup roles and permissions
        _setupBaseRoles(vertToken, identityRegistry, donationHandler, governor, timelock, coffeeToken, grantManager);
        
        console.log("Base ecosystem deployed successfully");
    }
    
    /**
     * @dev Deploy ArbitrumLendingManager on Arbitrum
     */
    function _deployArbitrumContracts() internal returns (DeploymentAddresses memory deployed) {
        HelperConfig.NetworkConfig memory config = helperConfig.getConfigByChainId(block.chainid);
        
        console.log("Deploying on Arbitrum...");
        
        ArbitrumLendingManager lendingManager = new ArbitrumLendingManager(
            config.ccipRouter,
            config.usdcToken,
            config.aUsdcToken,
            config.aavePool,
            config.linkToken,
            config.treasury
        );
        
        deployed.arbitrumLendingManager = address(lendingManager);
        
        console.log("ArbitrumLendingManager deployed at:", address(lendingManager));
    }
    
    /**
     * @dev Deploy full ecosystem for testnets/local development
     */
    function _deployTestnetContracts() internal returns (DeploymentAddresses memory deployed) {
        console.log("Deploying testnet/local environment...");
        
        // For testnets, deploy the full Base ecosystem
        // This allows testing the complete system on one chain
        return _deployBaseContracts();
    }
    
    /* -------------------------------------------------------------------------- */
    /*                            SETUP FUNCTIONS                                 */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @dev Setup roles and permissions for Base network contracts
     */
    function _setupBaseRoles(
        VERTGovernanceToken vertToken,
        IdentityRegistry /* identityRegistry */,
        DonationHandler donationHandler,
        WAGAGovernor governor,
        WAGATimelock timelock,
        WAGACoffeeInventoryTokenV2 coffeeToken,
        CooperativeGrantManagerV2 grantManager
    ) internal {
        // Grant minter role to DonationHandler
        vertToken.grantRole(vertToken.MINTER_ROLE(), address(donationHandler));
        
        // Setup governance roles
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(governor));
        timelock.revokeRole(timelock.PROPOSER_ROLE(), msg.sender);
        timelock.revokeRole(timelock.EXECUTOR_ROLE(), msg.sender);
        
        // Setup coffee token roles
        coffeeToken.grantRole(coffeeToken.DAO_ADMIN_ROLE(), address(grantManager));
        coffeeToken.grantRole(coffeeToken.INVENTORY_MANAGER_ROLE(), address(grantManager));
        coffeeToken.grantRole(coffeeToken.MINTER_ROLE(), address(grantManager));
        
        // Setup grant manager roles
        grantManager.grantRole(grantManager.FINANCIAL_ROLE(), address(timelock));
        grantManager.grantRole(grantManager.GRANT_MANAGER_ROLE(), address(timelock));
        grantManager.grantRole(grantManager.GRANT_MANAGER_ROLE(), address(governor));
    }
}
