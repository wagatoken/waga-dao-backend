// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {DeployWAGADAO} from "../script/DeployWAGADAO.s.sol";
import {VERTGovernanceToken} from "../src/VERTGovernanceToken.sol";
import {IdentityRegistry} from "../src/IdentityRegistry.sol";
import {DonationHandler} from "../src/DonationHandler.sol";
import {WAGAGovernor} from "../src/WAGAGovernor.sol";
import {WAGATimelock} from "../src/WAGATimelock.sol";
import {WAGACoffeeInventoryToken} from "../src/WAGACoffeeInventoryToken.sol";
import {CooperativeLoanManager} from "../src/CooperativeLoanManager.sol";
import {IWAGACoffeeInventoryToken} from "../src/interfaces/IWAGACoffeeInventoryToken.sol";
import {ICooperativeLoanManager} from "../src/interfaces/ICooperativeLoanManager.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

/**
 * @title WAGADAOBasicTest
 * @notice Basic test to verify deployment and core functionality
 */
contract WAGADAOBasicTest is Test {
    DeployWAGADAO deployer;
    VERTGovernanceToken vertToken;
    IdentityRegistry identityRegistry;
    DonationHandler donationHandler;
    WAGAGovernor governor;
    WAGATimelock timelock;
    WAGACoffeeInventoryToken coffeeInventoryToken;
    CooperativeLoanManager loanManager;
    HelperConfig helperConfig;
    
    address user = makeAddr("user");
    // Default Anvil account that will be used as deployer
    address deployerAccount = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    
    function setUp() public {
        // Deploy directly in test without using the deployment script
        // This avoids the vm.startBroadcast issue
        
        address admin = deployerAccount;
        
        // 1. Deploy IdentityRegistry first (no dependencies)
        identityRegistry = new IdentityRegistry(admin);

        // 2. Deploy VERTGovernanceToken with IdentityRegistry
        vertToken = new VERTGovernanceToken(
            address(identityRegistry),
            admin // initial owner
        );

        // 3. Deploy Timelock Controller (2 day delay)
        address[] memory proposers = new address[](1); 
        address[] memory executors = new address[](1);
        proposers[0] = admin; // Temporary proposer, will be changed to governor
        executors[0] = admin; // Temporary executor, will be changed to governor
        
        timelock = new WAGATimelock(
            2 days, // 2 day delay for security
            proposers,
            executors,
            admin // Admin initially, will be transferred to Governor
        );

        // 4. Deploy Governor with token and timelock
        governor = new WAGAGovernor(
            vertToken,
            timelock
        );

        // 5. Deploy Coffee Inventory Token
        coffeeInventoryToken = new WAGACoffeeInventoryToken(
            admin // Initial owner/admin
        );

        // 6. Create mock tokens for testing
        HelperConfig tempConfig = new HelperConfig();
        (
            , // address ethToken - not used yet
            address usdcToken, 
            address paxgToken,
            address ethUsdPriceFeed,
            address paxgUsdPriceFeed,
        ) = tempConfig.activeNetworkConfig();

        // 7. Deploy Cooperative Loan Manager
        loanManager = new CooperativeLoanManager(
            usdcToken,
            address(coffeeInventoryToken),
            admin, // Treasury address
            admin  // Initial admin
        );

        // 8. Deploy DonationHandler with all required contracts
        donationHandler = new DonationHandler(
            address(vertToken),
            address(identityRegistry),
            usdcToken,
            paxgToken,
            ethUsdPriceFeed,
            paxgUsdPriceFeed,
            admin, // treasury address
            admin  // initial owner
        );

        // 9. Set up roles and permissions (as admin)
        vm.startPrank(admin);
        _setupRolesAndPermissions();
        vm.stopPrank();
        
        vm.deal(user, 10 ether);
    }
    
    function testDeployment() public view {
        // Test that all contracts were deployed
        assertTrue(address(vertToken) != address(0));
        assertTrue(address(identityRegistry) != address(0));
        assertTrue(address(donationHandler) != address(0));
        assertTrue(address(governor) != address(0));
        assertTrue(address(timelock) != address(0));
        assertTrue(address(coffeeInventoryToken) != address(0));
        assertTrue(address(loanManager) != address(0));
        
        // Test basic contract properties
        assertEq(vertToken.name(), "WAGA Vertical Integration Token");
        assertEq(vertToken.symbol(), "VERT");
        assertEq(vertToken.decimals(), 18);
        
        console.log("All contracts deployed successfully");
        console.log("Token has correct name and symbol");
    }
    
    function testBasicWorkflow() public {
        // 1. Register user identity (admin operation)
        vm.prank(deployerAccount);
        identityRegistry.registerIdentity(user);
        assertTrue(identityRegistry.isVerified(user));
        console.log("User identity registered");
        
        // Track treasury balance before donation
        uint256 treasuryBalanceBefore = deployerAccount.balance;
        
        // 2. Make donation
        vm.prank(user);
        donationHandler.receiveEthDonation{value: 1 ether}();
        
        // Verify donation was received and tokens minted
        assertGt(vertToken.balanceOf(user), 0);
        assertEq(deployerAccount.balance, treasuryBalanceBefore + 1 ether); // ETH goes to treasury
        console.log("Donation made and tokens minted");
        console.log("   User VERT balance:", vertToken.balanceOf(user));
        
        // 3. Delegate votes
        vm.prank(user);
        vertToken.delegate(user);
        assertGt(vertToken.getVotes(user), 0);
        console.log("Votes delegated");
        console.log("   User voting power:", vertToken.getVotes(user));
    }
    
    function testGovernanceBasics() public view {
        // Test governance parameters
        assertEq(governor.proposalThreshold(), 1_000_000e18);
        assertEq(governor.votingDelay(), 7_200);
        assertEq(governor.votingPeriod(), 50_400);
        assertEq(timelock.getMinDelaySeconds(), 2 days);
        
        console.log("Governance parameters configured correctly");
    }
    
    /**
     * @dev Sets up roles and permissions for all contracts
     */
    function _setupRolesAndPermissions() internal {
        // 1. Grant minter role to DonationHandler for token minting
        vertToken.grantRole(vertToken.MINTER_ROLE(), address(donationHandler));

        // 2. Set up timelock roles for governance
        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(governor));
        
        // Revoke deployer's temporary roles
        timelock.revokeRole(timelock.PROPOSER_ROLE(), deployerAccount);
        timelock.revokeRole(timelock.EXECUTOR_ROLE(), deployerAccount);

        // 3. Set up coffee inventory token roles
        // Grant DAO roles to loan manager for inventory management
        coffeeInventoryToken.grantRole(coffeeInventoryToken.DAO_ADMIN_ROLE(), address(loanManager));
        coffeeInventoryToken.grantRole(coffeeInventoryToken.INVENTORY_MANAGER_ROLE(), address(loanManager));
        
        // Grant minter role to loan manager for batch creation
        coffeeInventoryToken.grantRole(coffeeInventoryToken.MINTER_ROLE(), address(loanManager));

        // 4. Set up loan manager roles
        // Grant treasury and loan management roles to DAO governance
        loanManager.grantRole(loanManager.DAO_TREASURY_ROLE(), address(timelock));
        loanManager.grantRole(loanManager.LOAN_MANAGER_ROLE(), address(timelock));
        
        // Allow governor to manage loans (proposals can create/manage loans)
        loanManager.grantRole(loanManager.LOAN_MANAGER_ROLE(), address(governor));
    }

    function testGreenfieldProjectCreation() public {
        // Setup greenfield project parameters
        IWAGACoffeeInventoryToken.GreenfieldProjectParams memory params = IWAGACoffeeInventoryToken.GreenfieldProjectParams({
            ipfsUri: "QmTestGreenfieldProject",
            plantingDate: block.timestamp + 30 days, // Plant in 30 days
            maturityDate: block.timestamp + 4 * 365 days, // Mature in 4 years
            projectedYield: 50_000, // 50,000 kg annual yield
            investmentStage: 0, // Planning stage
            pricePerKg: 8_000_000, // $8 per kg (6 decimals)
            loanValue: 250_000_000_000, // $250,000 loan (6 decimals)
            cooperativeName: "New Green Valley Cooperative",
            location: "Bamenda, Cameroon",
            paymentAddress: makeAddr("newCooperative"),
            certifications: "Organic, Regenerative",
            farmersCount: 150
        });

        // I need to create this manually since the test is calling the contract directly
        // Convert interface struct to contract struct for direct contract call
        WAGACoffeeInventoryToken.GreenfieldProjectParams memory contractParams = WAGACoffeeInventoryToken.GreenfieldProjectParams({
            ipfsUri: params.ipfsUri,
            plantingDate: params.plantingDate,
            maturityDate: params.maturityDate,
            projectedYield: params.projectedYield,
            investmentStage: params.investmentStage,
            pricePerKg: params.pricePerKg,
            loanValue: params.loanValue,
            cooperativeName: params.cooperativeName,
            location: params.location,
            paymentAddress: params.paymentAddress,
            certifications: params.certifications,
            farmersCount: params.farmersCount
        });

        // Create greenfield project
        vm.prank(deployerAccount);
        uint256 projectId = coffeeInventoryToken.createGreenfieldProject(contractParams);

        // Verify project creation
        assertTrue(coffeeInventoryToken.batchExists(projectId));
        
        // Check greenfield project details
        (
            bool isGreenfield,
            string memory cooperativeName,
            string memory location,
            uint256 investmentStage,
            string memory stageName
        ) = coffeeInventoryToken.getGreenfieldProjectDetails(projectId);
        
        assertTrue(isGreenfield);
        assertEq(cooperativeName, "New Green Valley Cooperative");
        assertEq(location, "Bamenda, Cameroon");
        assertEq(investmentStage, 0);
        assertEq(stageName, "Planning & Preparation");

        // Check greenfield financials
        (
            uint256 plantingDate,
            uint256 maturityDate,
            uint256 projectedYield,
            uint256 loanValue
        ) = coffeeInventoryToken.getGreenfieldFinancials(projectId);
        
        assertEq(plantingDate, params.plantingDate);
        assertEq(maturityDate, params.maturityDate);
        assertEq(projectedYield, 50_000);
        assertEq(loanValue, 250_000_000_000);

        console.log("Greenfield project created successfully");
        console.log("   Project ID:", projectId);
        console.log("   Cooperative:", cooperativeName);
        console.log("   Stage:", stageName);
    }

    function testGreenfieldLoanCreation() public {
        // Setup greenfield project parameters
        IWAGACoffeeInventoryToken.GreenfieldProjectParams memory params = IWAGACoffeeInventoryToken.GreenfieldProjectParams({
            ipfsUri: "QmTestGreenfieldLoan",
            plantingDate: block.timestamp + 60 days,
            maturityDate: block.timestamp + 5 * 365 days,
            projectedYield: 75_000,
            investmentStage: 0,
            pricePerKg: 9_000_000,
            loanValue: 0, // Will be set by loan creation
            cooperativeName: "Future Coffee Collective",
            location: "Mount Cameroon Region",
            paymentAddress: makeAddr("futureCooperative"),
            certifications: "Rainforest Alliance, Fair Trade",
            farmersCount: 200
        });

        // Create greenfield loan
        vm.prank(deployerAccount);
        (uint256 loanId, uint256 projectId) = loanManager.createGreenfieldLoan(
            makeAddr("futureCooperative"),
            300_000_000_000, // $300,000 loan
            7, // 7 years duration
            600, // 6% interest rate
            params
        );

        // Verify loan creation
        (
            address cooperative,
            uint256 amount,
            uint256 disbursedAmount,
            uint256 repaidAmount,
            uint256 interestRate,
            uint256 startTime,
            uint256 maturityTime,
            uint256[] memory batchIds,
            CooperativeLoanManager.LoanStatus status,
            string memory purpose,
            string memory cooperativeName,
            string memory location
        ) = loanManager.getLoanInfo(loanId);

        assertEq(cooperative, makeAddr("futureCooperative"));
        assertEq(amount, 300_000_000_000);
        assertEq(disbursedAmount, 0); // Not disbursed yet
        assertEq(repaidAmount, 0);
        assertEq(interestRate, 600);
        assertTrue(status == CooperativeLoanManager.LoanStatus.Pending);
        assertEq(purpose, "Greenfield Coffee Production Development");
        assertEq(cooperativeName, "Future Coffee Collective");
        assertEq(location, "Mount Cameroon Region");
        assertEq(batchIds.length, 1);
        assertEq(batchIds[0], projectId);

        // Verify the project was created with correct loan value
        (, , , uint256 loanValue) = coffeeInventoryToken.getGreenfieldFinancials(projectId);
        assertEq(loanValue, 300_000_000_000);

        console.log("Greenfield loan created successfully");
        console.log("   Loan ID:", loanId);
        console.log("   Project ID:", projectId);
        console.log("   Loan Amount: $", amount / 1e6);
    }
}
