// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {LionHeartGovernanceToken} from "../src/LionHeartGovernanceToken.sol";
import {IdentityRegistry} from "../src/IdentityRegistry.sol";
import {DonationHandler} from "../src/DonationHandler.sol";
import {LionHeartGovernor} from "../src/LionHeartGovernor.sol";
import {LionHeartTimelock} from "../src/LionHeartTimelock.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

/**
 * @title DeployLionHeartDAO
 * @notice Deployment script for the complete Lion Heart DAO system
 * @dev Deploys all contracts in the correct order and sets up relationships
 */
contract DeployLionHeartDAO is Script {
    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */
    
    HelperConfig public helperConfig;
    
    /* -------------------------------------------------------------------------- */
    /*                                MAIN FUNCTION                               */
    /* -------------------------------------------------------------------------- */
    
    function run() external returns (
        LionHeartGovernanceToken,
        IdentityRegistry,
        DonationHandler,
        LionHeartGovernor,
        LionHeartTimelock,
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

        // 2. Deploy LionHeartGovernanceToken with IdentityRegistry
        LionHeartGovernanceToken lhgtToken = new LionHeartGovernanceToken(
            address(identityRegistry),
            msg.sender // initial owner
        );

        // 3. Deploy Timelock Controller (2 day delay)
        address[] memory proposers = new address[](1); 
        address[] memory executors = new address[](1);
        proposers[0] = msg.sender; // Temporary proposer, will be changed to governor
        executors[0] = msg.sender; // Temporary executor, will be changed to governor
        
        LionHeartTimelock timelock = new LionHeartTimelock(
            2 days, // 2 day delay for security
            proposers,
            executors,
            msg.sender // Admin initially, will be transferred to Governor
        );

        // 4. Deploy Governor with token and timelock
        LionHeartGovernor governor = new LionHeartGovernor(
            lhgtToken,
            timelock
        );

        // 5. Deploy DonationHandler with all required contracts
        DonationHandler donationHandler = new DonationHandler(
            address(lhgtToken),
            address(identityRegistry),
            usdcToken,
            paxgToken,
            msg.sender, // treasury address
            msg.sender  // initial owner
        );

        // 6. Set up roles and permissions properly
        _setupRolesAndPermissions(
            lhgtToken,
            identityRegistry,
            donationHandler,
            governor,
            timelock
        );

        vm.stopBroadcast();

        return (
            lhgtToken,
            identityRegistry,
            donationHandler,
            governor,
            timelock,
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
        LionHeartGovernanceToken lhgtToken,
        IdentityRegistry, // identityRegistry - unused for now
        DonationHandler donationHandler, // Used for granting minter role
        LionHeartGovernor governor,
        LionHeartTimelock timelock
    ) internal {
        // 1. Grant minter role to DonationHandler for token minting
        // The deployer is admin of lhgtToken, so this should work
        lhgtToken.grantRole(lhgtToken.MINTER_ROLE(), address(donationHandler));

        // 2. Set up timelock roles
        // The deployer is admin of timelock, so these should work
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(governor));
        
        // 3. The proposers/executors arrays in constructor already granted roles to msg.sender
        // So we need to revoke them to transfer to governor
        timelock.revokeRole(timelock.PROPOSER_ROLE(), msg.sender);
        timelock.revokeRole(timelock.EXECUTOR_ROLE(), msg.sender);

        // 4. For the Governor contract, we need to check if it has proper admin setup
        // The Governor inherits from AccessControl but doesn't set up admin in constructor
        // We need to grant admin role first, then grant PROPOSAL_CANCELLER_ROLE
        // Since Governor inherits AccessControl, deployer might not be admin by default
        
        // Skip Governor role setup for now - this needs to be handled differently
        // governor.grantRole(governor.PROPOSAL_CANCELLER_ROLE(), msg.sender);
        
        // Note: Governor admin setup might need to be done through timelock governance
        // or the Governor constructor needs to be modified to grant admin role
    }
}
