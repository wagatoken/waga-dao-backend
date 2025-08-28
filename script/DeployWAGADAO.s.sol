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

// ZK Proof System contracts
import {ZKProofManager} from "../src/shared/ZKProofManager.sol";
import {RISCZeroVerifier} from "../src/shared/verifiers/RISCZeroVerifier.sol";
import {CircomVerifier} from "../src/shared/verifiers/CircomVerifier.sol";

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
        
        // ZK Proof System
        address riscZeroVerifier;
        address circomVerifier;
        address zkProofManager;
        
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
        
        console.log("Deploying Base Network contracts...");
        
        DeploymentAddresses memory deployed;
        
        // 1. Identity Registry
        deployed.identityRegistry = address(new IdentityRegistry(admin));
        console.log("IdentityRegistry deployed at:", deployed.identityRegistry);
        
        // 2. VERT Governance Token
        deployed.vertGovernanceToken = address(new VERTGovernanceToken(
            deployed.identityRegistry,
            admin
        ));
        console.log("VERTGovernanceToken deployed at:", deployed.vertGovernanceToken);
        
        // 3. Timelock Controller
        address[] memory proposers = new address[](1);
        address[] memory executors = new address[](1);
        proposers[0] = admin;
        executors[0] = admin;
        
        deployed.wagaTimelock = address(new WAGATimelock(
            2 days,
            proposers,
            executors,
            admin
        ));
        console.log("WAGATimelock deployed at:", deployed.wagaTimelock);
        
        // 4. Governor
        deployed.wagaGovernor = address(new WAGAGovernor(
            VERTGovernanceToken(deployed.vertGovernanceToken),
            WAGATimelock(deployed.wagaTimelock)
        ));
        console.log("WAGAGovernor deployed at:", deployed.wagaGovernor);
        
        // 5. Greenfield Project Manager
        GreenfieldProjectManager greenfieldManager = new GreenfieldProjectManager(admin);
        console.log("GreenfieldProjectManager deployed at:", address(greenfieldManager));
        
        // 6. Coffee Inventory Token
        deployed.coffeeInventoryToken = address(new WAGACoffeeInventoryTokenV2(
            admin,
            address(greenfieldManager)
        ));
        console.log("WAGACoffeeInventoryTokenV2 deployed at:", deployed.coffeeInventoryToken);
        
        // 7. ZK Proof System
        deployed.riscZeroVerifier = address(new RISCZeroVerifier(admin));
        console.log("RISCZeroVerifier deployed at:", deployed.riscZeroVerifier);
        
        deployed.circomVerifier = address(new CircomVerifier(admin));
        console.log("CircomVerifier deployed at:", deployed.circomVerifier);
        
        deployed.zkProofManager = address(new ZKProofManager(
            deployed.riscZeroVerifier,
            deployed.circomVerifier,
            admin
        ));
        console.log("ZKProofManager deployed at:", deployed.zkProofManager);
        
        // 8. Cooperative Grant Manager (with ZK Proof integration)
        deployed.cooperativeGrantManager = address(new CooperativeGrantManagerV2(
            address(usdcToken),
            address(greenfieldManager),
            deployed.wagaTimelock, // Use timelock as treasury
            admin,
            deployed.zkProofManager // ZK Proof Manager integration
        ));
        console.log("CooperativeGrantManagerV2 deployed at:", deployed.cooperativeGrantManager);
        
        // 9. Donation Handler
        deployed.donationHandler = address(new DonationHandler(
            deployed.vertGovernanceToken,
            deployed.identityRegistry,
            deployed.wagaTimelock,
            admin
        ));
        console.log("DonationHandler deployed at:", deployed.donationHandler);
        
        // Setup roles and permissions
        _setupBaseRoles(deployed);
        
        console.log("Base Network deployment completed successfully!");
        return deployed;
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
    function _setupBaseRoles(DeploymentAddresses memory deployed) internal {
        console.log("Setting up Base Network roles and permissions...");
        
        // Grant Governor role to timelock
        WAGATimelock(deployed.wagaTimelock).grantRole(
            WAGATimelock(deployed.wagaTimelock).PROPOSER_ROLE(),
            deployed.wagaGovernor
        );
        
        // Grant Executor role to timelock
        WAGATimelock(deployed.wagaTimelock).grantRole(
            WAGATimelock(deployed.wagaTimelock).EXECUTOR_ROLE(),
            deployed.wagaGovernor
        );
        
        // Grant roles to Cooperative Grant Manager
        CooperativeGrantManagerV2(deployed.cooperativeGrantManager).grantRole(
            CooperativeGrantManagerV2(deployed.cooperativeGrantManager).GRANT_MANAGER_ROLE(),
            deployed.wagaGovernor
        );
        
        CooperativeGrantManagerV2(deployed.cooperativeGrantManager).grantRole(
            CooperativeGrantManagerV2(deployed.cooperativeGrantManager).MILESTONE_VALIDATOR_ROLE(),
            deployed.wagaGovernor
        );
        
        // Grant roles to ZK Proof Manager
        ZKProofManager(deployed.zkProofManager).grantRole(
            ZKProofManager(deployed.zkProofManager).VERIFIER_ROLE(),
            deployed.wagaGovernor
        );
        
        ZKProofManager(deployed.zkProofManager).grantRole(
            ZKProofManager(deployed.zkProofManager).PROOF_SUBMITTER_ROLE(),
            deployed.wagaGovernor
        );
        
        // Grant roles to RISC Zero Verifier
        RISCZeroVerifier(deployed.riscZeroVerifier).grantRole(
            RISCZeroVerifier(deployed.riscZeroVerifier).VERIFIER_ROLE(),
            deployed.zkProofManager
        );
        
        // Grant roles to Circom Verifier
        CircomVerifier(deployed.circomVerifier).grantRole(
            CircomVerifier(deployed.circomVerifier).VERIFIER_ROLE(),
            deployed.zkProofManager
        );
        
        // Setup supported circuits
        _setupSupportedCircuits(deployed);
        
        console.log("Base Network roles and permissions configured successfully!");
    }
    
    function _setupSupportedCircuits(DeploymentAddresses memory deployed) internal {
        console.log("Setting up supported ZK proof circuits...");
        
        // Setup RISC Zero circuits for coffee quality and financial modeling
        bytes32 coffeeQualityCircuit = keccak256("COFFEE_QUALITY_ALGORITHM_V1");
        bytes32 financialModelCircuit = keccak256("FINANCIAL_RISK_ASSESSMENT_V1");
        
        RISCZeroVerifier(deployed.riscZeroVerifier).setCircuitSupport(
            coffeeQualityCircuit,
            "Coffee Quality Algorithm V1",
            "1.0.0",
            true
        );
        
        RISCZeroVerifier(deployed.riscZeroVerifier).setCircuitSupport(
            financialModelCircuit,
            "Financial Risk Assessment V1",
            "1.0.0",
            true
        );
        
        // Setup Circom circuits for simple verifications
        bytes32 milestoneCircuit = keccak256("MILESTONE_COMPLETION_V1");
        bytes32 identityCircuit = keccak256("IDENTITY_VERIFICATION_V1");
        
        CircomVerifier(deployed.circomVerifier).registerCircuit(
            milestoneCircuit,
            "Milestone Completion V1",
            "1.0.0",
            5,  // max inputs
            1,  // max outputs
            300000  // gas limit
        );
        
        CircomVerifier(deployed.circomVerifier).registerCircuit(
            identityCircuit,
            "Identity Verification V1",
            "1.0.0",
            3,  // max inputs
            1,  // max outputs
            200000  // gas limit
        );
        
        console.log("Supported ZK proof circuits configured successfully!");
    }
}
