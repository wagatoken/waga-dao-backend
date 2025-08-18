// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {VERTGovernanceToken} from "../src/VERTGovernanceToken.sol";
import {IdentityRegistry} from "../src/IdentityRegistry.sol";
import {DonationHandler} from "../src/DonationHandler.sol";
import {WAGAGovernor} from "../src/WAGAGovernor.sol";
import {WAGATimelock} from "../src/WAGATimelock.sol";
import {WAGACoffeeInventoryToken} from "../src/WAGACoffeeInventoryToken.sol";
import {CooperativeLoanManager} from "../src/CooperativeLoanManager.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

/**
 * @title DeployWAGADAO
 * @notice Deployment script for the complete WAGA DAO system
 * @dev Deploys all contracts in the correct order and sets up relationships for regenerative coffee projects
 */
contract DeployWAGADAO is Script {
    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */
    
    HelperConfig public helperConfig;
    
    /* -------------------------------------------------------------------------- */
    /*                                MAIN FUNCTION                               */
    /* -------------------------------------------------------------------------- */
    
    function run() external returns (
        VERTGovernanceToken,
        IdentityRegistry,
        DonationHandler,
        WAGAGovernor,
        WAGATimelock,
        WAGACoffeeInventoryToken,
        CooperativeLoanManager,
        HelperConfig
    ) {
        // Get network configuration
        helperConfig = new HelperConfig();
        (
            address usdcToken,
            address paxgToken,
            uint256 deployerKey
        ) = helperConfig.activeNetworkConfig();

        vm.startBroadcast(deployerKey);

        // 1. Deploy IdentityRegistry first (no dependencies)
        IdentityRegistry identityRegistry = new IdentityRegistry(msg.sender);

        // 2. Deploy VERTGovernanceToken with IdentityRegistry
        VERTGovernanceToken vertToken = new VERTGovernanceToken(
            address(identityRegistry),
            msg.sender // initial owner
        );

        // 3. Deploy Timelock Controller (2 day delay)
        address[] memory proposers = new address[](1); 
        address[] memory executors = new address[](1);
        proposers[0] = msg.sender; // Temporary proposer, will be changed to governor
        executors[0] = msg.sender; // Temporary executor, will be changed to governor
        
        WAGATimelock timelock = new WAGATimelock(
            2 days, // 2 day delay for security
            proposers,
            executors,
            msg.sender // Admin initially, will be transferred to Governor
        );

        // 4. Deploy Governor with token and timelock
        WAGAGovernor governor = new WAGAGovernor(
            vertToken,
            timelock
        );

        // 5. Deploy Coffee Inventory Token
        WAGACoffeeInventoryToken coffeeInventoryToken = new WAGACoffeeInventoryToken(
            msg.sender // Initial owner/admin
        );

        // 6. Deploy Cooperative Loan Manager
        CooperativeLoanManager loanManager = new CooperativeLoanManager(
            usdcToken,
            address(coffeeInventoryToken),
            msg.sender, // Treasury address
            msg.sender  // Initial admin
        );

        // 7. Deploy DonationHandler with all required contracts
        DonationHandler donationHandler = new DonationHandler(
            address(vertToken),
            address(identityRegistry),
            usdcToken,
            paxgToken,
            msg.sender, // treasury address
            msg.sender  // initial owner
        );

        // 8. Set up roles and permissions properly
        _setupRolesAndPermissions(
            vertToken,
            identityRegistry,
            donationHandler,
            governor,
            timelock,
            coffeeInventoryToken,
            loanManager
        );

        vm.stopBroadcast();

        return (
            vertToken,
            identityRegistry,
            donationHandler,
            governor,
            timelock,
            coffeeInventoryToken,
            loanManager,
            helperConfig
        );
    }

    /* -------------------------------------------------------------------------- */
    /*                            INTERNAL FUNCTIONS                             */
    /* -------------------------------------------------------------------------- */

    /**
     * @dev Sets up roles and permissions for all contracts
     */
    function _setupRolesAndPermissions(
        VERTGovernanceToken vertToken,
        IdentityRegistry, // identityRegistry - unused for now
        DonationHandler donationHandler, // Used for granting minter role
        WAGAGovernor governor,
        WAGATimelock timelock,
        WAGACoffeeInventoryToken coffeeInventoryToken,
        CooperativeLoanManager loanManager
    ) internal {
        // 1. Grant minter role to DonationHandler for token minting
        vertToken.grantRole(vertToken.MINTER_ROLE(), address(donationHandler));

        // 2. Set up timelock roles for governance
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(governor));
        
        // Revoke deployer's temporary roles
        timelock.revokeRole(timelock.PROPOSER_ROLE(), msg.sender);
        timelock.revokeRole(timelock.EXECUTOR_ROLE(), msg.sender);

        // 3. Set up coffee inventory token roles
        // Grant DAO roles to loan manager for inventory management
        coffeeInventoryToken.grantRole(coffeeInventoryToken.DAO_ADMIN_ROLE(), address(loanManager));
        coffeeInventoryToken.grantRole(coffeeInventoryToken.INVENTORY_MANAGER_ROLE(), address(loanManager));
        
        // Grant minter role to loan manager for creating batch tokens
        coffeeInventoryToken.grantRole(coffeeInventoryToken.MINTER_ROLE(), address(loanManager));

        // 4. Set up loan manager roles
        // Grant treasury and loan management roles to DAO governance
        loanManager.grantRole(loanManager.DAO_TREASURY_ROLE(), address(timelock));
        loanManager.grantRole(loanManager.LOAN_MANAGER_ROLE(), address(timelock));
        
        // Allow governor to manage loans (proposals can create/manage loans)
        loanManager.grantRole(loanManager.LOAN_MANAGER_ROLE(), address(governor));
    }
}
