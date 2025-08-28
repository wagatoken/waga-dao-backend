// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {ZKProofManager} from "../src/shared/ZKProofManager.sol";
import {RISCZeroVerifier} from "../src/shared/verifiers/RISCZeroVerifier.sol";
import {CircomVerifier} from "../src/shared/verifiers/CircomVerifier.sol";
import {IZKProofVerifier} from "../src/shared/interfaces/IZKProofVerifier.sol";
import {CooperativeGrantManagerV2} from "../src/base/CooperativeGrantManagerV2.sol";
import {GreenfieldProjectManager} from "../src/managers/GreenfieldProjectManager.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

/**
 * @title ZKProofSystemTest
 * @notice Comprehensive test suite for the dual zk-proof system
 * @author WAGA DAO - Regenerative Coffee Global Impact
 * @dev Tests RISC Zero (complex) and Circom (simple) zk-proof verification
 */
contract ZKProofSystemTest is Test {
    
    // ============ STATE VARIABLES ============
    
    ZKProofManager public zkProofManager;
    RISCZeroVerifier public riscZeroVerifier;
    CircomVerifier public circomVerifier;
    CooperativeGrantManagerV2 public grantManager;
    GreenfieldProjectManager public greenfieldManager;
    ERC20Mock public usdcToken;
    
    // Test addresses
    address public admin = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address public verifier = makeAddr("verifier");
    address public submitter = makeAddr("submitter");
    address public cooperative = makeAddr("cooperative");
    address public treasury = makeAddr("treasury");
    
    // Test constants
    uint256 public constant GRANT_AMOUNT = 100_000e6; // $100,000 USDC
    uint256 public constant REVENUE_SHARE = 2500; // 25%
    uint256 public constant DURATION_YEARS = 5;
    
    // Circuit hashes
    bytes32 public constant COFFEE_QUALITY_CIRCUIT = keccak256("COFFEE_QUALITY_ALGORITHM_V1");
    bytes32 public constant FINANCIAL_MODEL_CIRCUIT = keccak256("FINANCIAL_RISK_ASSESSMENT_V1");
    bytes32 public constant MILESTONE_CIRCUIT = keccak256("MILESTONE_COMPLETION_V1");
    bytes32 public constant IDENTITY_CIRCUIT = keccak256("IDENTITY_VERIFICATION_V1");
    
    // ============ SETUP ============
    
    function setUp() public {
        console2.log("=== ZK PROOF SYSTEM TEST SETUP ===");
        
        // Deploy mock USDC
        usdcToken = new ERC20Mock();
        
        // Deploy Greenfield Project Manager
        greenfieldManager = new GreenfieldProjectManager(admin);
        
        // Deploy ZK Proof verifiers
        riscZeroVerifier = new RISCZeroVerifier(admin);
        circomVerifier = new CircomVerifier(admin);
        
        // Deploy ZK Proof Manager
        zkProofManager = new ZKProofManager(
            address(riscZeroVerifier),
            address(circomVerifier),
            admin
        );
        
        // Deploy Grant Manager with ZK Proof integration
        grantManager = new CooperativeGrantManagerV2(
            address(usdcToken),
            address(greenfieldManager),
            treasury,
            admin,
            address(zkProofManager)
        );
        
        // Setup roles and permissions
        _setupRoles();
        
        // Setup supported circuits
        _setupSupportedCircuits();
        
        // Fund accounts
        _fundAccounts();
        
        console2.log("ZK Proof System test setup completed successfully");
    }
    
    function _setupRoles() internal {
        // Grant verifier role to test verifier
        riscZeroVerifier.grantRole(riscZeroVerifier.VERIFIER_ROLE(), verifier);
        circomVerifier.grantRole(circomVerifier.VERIFIER_ROLE(), verifier);
        
        // Grant proof submitter role
        zkProofManager.grantRole(zkProofManager.PROOF_SUBMITTER_ROLE(), submitter);
        
        // Grant milestone validator role
        grantManager.grantRole(grantManager.MILESTONE_VALIDATOR_ROLE(), verifier);
        
        // Grant ZK proof manager role
        grantManager.grantRole(grantManager.ZK_PROOF_MANAGER_ROLE(), submitter);
    }
    
    function _setupSupportedCircuits() internal {
        // Setup RISC Zero circuits
        riscZeroVerifier.setCircuitSupport(
            COFFEE_QUALITY_CIRCUIT,
            "Coffee Quality Algorithm V1",
            "1.0.0",
            true
        );
        
        riscZeroVerifier.setCircuitSupport(
            FINANCIAL_MODEL_CIRCUIT,
            "Financial Risk Assessment V1",
            "1.0.0",
            true
        );
        
        // Setup Circom circuits
        circomVerifier.registerCircuit(
            MILESTONE_CIRCUIT,
            "Milestone Completion V1",
            "1.0.0",
            5,  // max inputs
            1,  // max outputs
            300000  // gas limit
        );
        
        circomVerifier.registerCircuit(
            IDENTITY_CIRCUIT,
            "Identity Verification V1",
            "1.0.0",
            3,  // max inputs
            1,  // max outputs
            200000  // gas limit
        );
    }
    
    function _fundAccounts() internal {
        // Fund grant manager with USDC
        usdcToken.mint(address(grantManager), 1_000_000e6);
        
        // Fund verifier with ETH for gas
        vm.deal(verifier, 100 ether);
        vm.deal(submitter, 100 ether);
    }
    
    // ============ RISC ZERO VERIFICATION TESTS ============
    
    function testRISCZeroProofVerification() public {
        console2.log("\n=== TESTING RISC ZERO PROOF VERIFICATION ===");
        
        // Create sample proof data
        bytes memory proofData = _createSampleRISCZeroProof();
        bytes memory publicInputs = _createSamplePublicInputs();
        
        // Submit proof
        vm.prank(submitter);
        bytes32 proofHash = zkProofManager.submitProof(
            IZKProofVerifier.ProofType.RISC_ZERO,
            proofData,
            keccak256(publicInputs),
            IZKProofVerifier.ProofMetadata({
                proofName: "Coffee Quality Test",
                description: "Test proof for coffee quality algorithm",
                version: "1.0.0",
                circuitHash: COFFEE_QUALITY_CIRCUIT,
                maxGasLimit: 500000
            })
        );
        
        console2.log("Proof submitted with hash:", proofHash);
        
        // Verify proof
        vm.prank(verifier);
        IZKProofVerifier.VerificationResult memory result = zkProofManager.verifyProof(proofHash);
        
        assertTrue(result.success, "RISC Zero proof verification should succeed");
        console2.log("RISC Zero proof verified successfully");
        console2.log("Gas used:", result.gasUsed);
        console2.log("Reason:", result.reason);
    }
    
    function testRISCZeroBatchVerification() public {
        console2.log("\n=== TESTING RISC ZERO BATCH VERIFICATION ===");
        
        // Create multiple proofs
        bytes32[] memory proofHashes = new bytes32[](3);
        bytes[] memory proofDataArray = new bytes[](3);
        bytes[] memory publicInputsArray = new bytes[](3);
        bytes32[] memory circuitHashes = new bytes32[](3);
        
        for (uint256 i = 0; i < 3; i++) {
            proofDataArray[i] = _createSampleRISCZeroProof();
            publicInputsArray[i] = _createSamplePublicInputs();
            circuitHashes[i] = COFFEE_QUALITY_CIRCUIT;
            
            vm.prank(submitter);
            proofHashes[i] = zkProofManager.submitProof(
                IZKProofVerifier.ProofType.RISC_ZERO,
                proofDataArray[i],
                keccak256(publicInputsArray[i]),
                IZKProofVerifier.ProofMetadata({
                    proofName: string(abi.encodePacked("Coffee Quality Test ", i)),
                    description: "Test proof for coffee quality algorithm",
                    version: "1.0.0",
                    circuitHash: COFFEE_QUALITY_CIRCUIT,
                    maxGasLimit: 500000
                })
            );
        }
        
        // Batch verify
        vm.prank(verifier);
        bool[] memory results = riscZeroVerifier.batchVerifyRISCZeroProofs(
            proofHashes,
            proofDataArray,
            publicInputsArray,
            circuitHashes
        );
        
        for (uint256 i = 0; i < results.length; i++) {
            assertTrue(results[i], "Batch verification should succeed for all proofs");
        }
        
        console2.log("RISC Zero batch verification completed successfully");
    }
    
    // ============ CIRCOM VERIFICATION TESTS ============
    
    function testCircomProofVerification() public {
        console2.log("\n=== TESTING CIRCOM PROOF VERIFICATION ===");
        
        // Create sample proof data
        bytes memory proofData = _createSampleCircomProof();
        bytes memory publicInputs = _createSamplePublicInputs();
        
        // Submit proof
        vm.prank(submitter);
        bytes32 proofHash = zkProofManager.submitProof(
            IZKProofVerifier.ProofType.CIRCOM,
            proofData,
            keccak256(publicInputs),
            IZKProofVerifier.ProofMetadata({
                proofName: "Milestone Completion Test",
                description: "Test proof for milestone completion",
                version: "1.0.0",
                circuitHash: MILESTONE_CIRCUIT,
                maxGasLimit: 300000
            })
        );
        
        console2.log("Proof submitted with hash:", proofHash);
        
        // Verify proof
        vm.prank(verifier);
        IZKProofVerifier.VerificationResult memory result = zkProofManager.verifyProof(proofHash);
        
        assertTrue(result.success, "Circom proof verification should succeed");
        console2.log("Circom proof verified successfully");
        console2.log("Gas used:", result.gasUsed);
        console2.log("Reason:", result.reason);
    }
    
    function testCircomBatchVerification() public {
        console2.log("\n=== TESTING CIRCOM BATCH VERIFICATION ===");
        
        // Create multiple proofs
        bytes32[] memory proofHashes = new bytes32[](2);
        bytes[] memory proofDataArray = new bytes[](2);
        bytes[] memory publicInputsArray = new bytes[](2);
        bytes32[] memory circuitHashes = new bytes32[](2);
        
        for (uint256 i = 0; i < 2; i++) {
            proofDataArray[i] = _createSampleCircomProof();
            publicInputsArray[i] = _createSamplePublicInputs();
            circuitHashes[i] = MILESTONE_CIRCUIT;
            
            vm.prank(submitter);
            proofHashes[i] = zkProofManager.submitProof(
                IZKProofVerifier.ProofType.CIRCOM,
                proofDataArray[i],
                keccak256(publicInputsArray[i]),
                IZKProofVerifier.ProofMetadata({
                    proofName: string(abi.encodePacked("Milestone Test ", i)),
                    description: "Test proof for milestone completion",
                    version: "1.0.0",
                    circuitHash: MILESTONE_CIRCUIT,
                    maxGasLimit: 300000
                })
            );
        }
        
        // Batch verify
        vm.prank(verifier);
        bool[] memory results = circomVerifier.batchVerifyCircomProofs(
            proofHashes,
            proofDataArray,
            publicInputsArray,
            circuitHashes
        );
        
        for (uint256 i = 0; i < results.length; i++) {
            assertTrue(results[i], "Batch verification should succeed for all proofs");
        }
        
        console2.log("Circom batch verification completed successfully");
    }
    
    // ============ INTEGRATION TESTS ============
    
    function testGrantMilestoneWithZKProof() public {
        console2.log("\n=== TESTING GRANT MILESTONE WITH ZK PROOF ===");
        
        // Create a grant with milestones
        uint256 grantId = _createGrantWithMilestones();
        
        // Submit milestone proof
        vm.prank(submitter);
        bytes32 proofHash = grantManager.submitMilestoneProof(
            grantId,
            0, // first milestone
            IZKProofVerifier.ProofType.CIRCOM,
            _createSampleCircomProof(),
            keccak256("milestone_completion"),
            IZKProofVerifier.ProofMetadata({
                proofName: "Milestone 1 Completion",
                description: "Proof that milestone 1 is completed",
                version: "1.0.0",
                circuitHash: MILESTONE_CIRCUIT,
                maxGasLimit: 300000
            })
        );
        
        console2.log("Milestone proof submitted:", proofHash);
        
        // Verify the proof
        vm.prank(verifier);
        bool success = grantManager.validateMilestoneWithProof(grantId, 0, proofHash);
        
        assertTrue(success, "Milestone validation with ZK proof should succeed");
        
        // Check milestone status
        ICooperativeGrantManager.MilestoneInfo memory milestone = grantManager.getMilestoneInfo(grantId, 0);
        assertTrue(milestone.isCompleted, "Milestone should be marked as completed");
        assertEq(milestone.validator, verifier, "Validator should be set correctly");
        
        console2.log("Grant milestone validated with ZK proof successfully");
    }
    
    function testCoffeeQualityWithRISCZero() public {
        console2.log("\n=== TESTING COFFEE QUALITY WITH RISC ZERO ===");
        
        // Create a coffee batch
        uint256 batchId = _createCoffeeBatch();
        
        // Submit quality proof using RISC Zero
        vm.prank(submitter);
        bytes32 proofHash = zkProofManager.submitProof(
            IZKProofVerifier.ProofType.RISC_ZERO,
            _createSampleRISCZeroProof(),
            keccak256("coffee_quality_metrics"),
            IZKProofVerifier.ProofMetadata({
                proofName: "Coffee Quality Assessment",
                description: "RISC Zero proof for coffee quality algorithm",
                version: "1.0.0",
                circuitHash: COFFEE_QUALITY_CIRCUIT,
                maxGasLimit: 500000
            })
        );
        
        console2.log("Coffee quality proof submitted:", proofHash);
        
        // Verify the proof
        vm.prank(verifier);
        IZKProofVerifier.VerificationResult memory result = zkProofManager.verifyProof(proofHash);
        
        assertTrue(result.success, "Coffee quality proof verification should succeed");
        
        // Check proof status
        IZKProofVerifier.VerificationStatus status = zkProofManager.getVerificationStatus(proofHash);
        assertEq(uint256(status), uint256(IZKProofVerifier.VerificationStatus.VERIFIED), "Proof should be verified");
        
        console2.log("Coffee quality validated with RISC Zero proof successfully");
    }
    
    // ============ ERROR CONDITION TESTS ============
    
    function testInvalidProofType() public {
        console2.log("\n=== TESTING INVALID PROOF TYPE ===");
        
        vm.prank(submitter);
        vm.expectRevert();
        zkProofManager.submitProof(
            IZKProofVerifier.ProofType(2), // Invalid proof type
            _createSampleRISCZeroProof(),
            keccak256("test"),
            IZKProofVerifier.ProofMetadata({
                proofName: "Test",
                description: "Test",
                version: "1.0.0",
                circuitHash: COFFEE_QUALITY_CIRCUIT,
                maxGasLimit: 500000
            })
        );
    }
    
    function testUnsupportedCircuit() public {
        console2.log("\n=== TESTING UNSUPPORTED CIRCUIT ===");
        
        bytes32 unsupportedCircuit = keccak256("UNSUPPORTED_CIRCUIT");
        
        vm.prank(submitter);
        bytes32 proofHash = zkProofManager.submitProof(
            IZKProofVerifier.ProofType.RISC_ZERO,
            _createSampleRISCZeroProof(),
            keccak256("test"),
            IZKProofVerifier.ProofMetadata({
                proofName: "Test",
                description: "Test",
                version: "1.0.0",
                circuitHash: unsupportedCircuit,
                maxGasLimit: 500000
            })
        );
        
        // Try to verify with unsupported circuit
        vm.prank(verifier);
        vm.expectRevert();
        zkProofManager.verifyProof(proofHash);
    }
    
    function testProofExpiry() public {
        console2.log("\n=== TESTING PROOF EXPIRY ===");
        
        // Submit proof
        vm.prank(submitter);
        bytes32 proofHash = zkProofManager.submitProof(
            IZKProofVerifier.ProofType.CIRCOM,
            _createSampleCircomProof(),
            keccak256("test"),
            IZKProofVerifier.ProofMetadata({
                proofName: "Test",
                description: "Test",
                version: "1.0.0",
                circuitHash: MILESTONE_CIRCUIT,
                maxGasLimit: 300000
            })
        );
        
        // Fast forward time past expiry
        vm.warp(block.timestamp + 31 days);
        
        // Try to verify expired proof
        vm.prank(verifier);
        vm.expectRevert();
        zkProofManager.verifyProof(proofHash);
    }
    
    // ============ PERFORMANCE TESTS ============
    
    function testGasOptimization() public {
        console2.log("\n=== TESTING GAS OPTIMIZATION ===");
        
        // Test RISC Zero proof gas usage
        uint256 gasBefore = gasleft();
        
        vm.prank(submitter);
        bytes32 proofHash = zkProofManager.submitProof(
            IZKProofVerifier.ProofType.RISC_ZERO,
            _createSampleRISCZeroProof(),
            keccak256("test"),
            IZKProofVerifier.ProofMetadata({
                proofName: "Gas Test",
                description: "Test for gas optimization",
                version: "1.0.0",
                circuitHash: COFFEE_QUALITY_CIRCUIT,
                maxGasLimit: 500000
            })
        );
        
        uint256 submitGas = gasBefore - gasleft();
        console2.log("Proof submission gas used:", submitGas);
        
        // Test verification gas usage
        gasBefore = gasleft();
        
        vm.prank(verifier);
        zkProofManager.verifyProof(proofHash);
        
        uint256 verifyGas = gasBefore - gasleft();
        console2.log("Proof verification gas used:", verifyGas);
        
        // Assert reasonable gas limits
        assertLt(submitGas, 200000, "Proof submission should use less than 200k gas");
        assertLt(verifyGas, 500000, "Proof verification should use less than 500k gas");
    }
    
    // ============ HELPER FUNCTIONS ============
    
    function _createSampleRISCZeroProof() internal pure returns (bytes memory) {
        // Sample RISC Zero proof data (placeholder)
        return abi.encode(
            "RISC_ZERO_PROOF",
            "sample_proof_data",
            "sample_commitment",
            "sample_journal"
        );
    }
    
    function _createSampleCircomProof() internal pure returns (bytes memory) {
        // Sample Circom proof data (placeholder)
        return abi.encode(
            "CIRCOM_PROOF",
            "sample_proof_a",
            "sample_proof_b",
            "sample_proof_c"
        );
    }
    
    function _createSamplePublicInputs() internal pure returns (bytes memory) {
        // Sample public inputs
        return abi.encode(
            "coffee_quality_score",
            85,
            "sustainability_rating",
            90
        );
    }
    
    function _createGrantWithMilestones() internal returns (uint256 grantId) {
        // Create greenfield grant
        vm.prank(admin);
        (grantId, ) = grantManager.createGreenfieldGrant(
            cooperative,
            GRANT_AMOUNT,
            REVENUE_SHARE,
            DURATION_YEARS,
            "QmTestProject",
            block.timestamp + 90 days,
            block.timestamp + 4 * 365 days,
            15000,
            "Test Cooperative"
        );
        
        // Create milestone schedule
        string[] memory descriptions = new string[](2);
        descriptions[0] = "Land preparation";
        descriptions[1] = "Planting";
        
        uint256[] memory percentages = new uint256[](2);
        percentages[0] = 5000; // 50%
        percentages[1] = 5000; // 50%
        
        vm.prank(admin);
        grantManager.createDisbursementSchedule(grantId, descriptions, percentages);
        
        // Move funds to escrow
        vm.prank(admin);
        grantManager.disburseGrant(grantId);
        
        return grantId;
    }
    
    function _createCoffeeBatch() internal returns (uint256 batchId) {
        // This would create a coffee batch in the coffee inventory token
        // For now, return a mock batch ID
        return 1;
    }
    
    // ============ STATISTICS TESTS ============
    
    function testSystemStatistics() public {
        console2.log("\n=== TESTING SYSTEM STATISTICS ===");
        
        // Submit multiple proofs
        for (uint256 i = 0; i < 5; i++) {
            vm.prank(submitter);
            zkProofManager.submitProof(
                IZKProofVerifier.ProofType.RISC_ZERO,
                _createSampleRISCZeroProof(),
                keccak256(abi.encodePacked("test", i)),
                IZKProofVerifier.ProofMetadata({
                    proofName: string(abi.encodePacked("Test ", i)),
                    description: "Test proof",
                    version: "1.0.0",
                    circuitHash: COFFEE_QUALITY_CIRCUIT,
                    maxGasLimit: 500000
                })
            );
        }
        
        // Check system stats
        (uint256 totalSubmitted, uint256 totalVerified, uint256 totalRejected, uint256 totalExpired) = 
            zkProofManager.getSystemStats();
        
        assertEq(totalSubmitted, 5, "Total submitted should be 5");
        assertEq(totalVerified, 0, "Total verified should be 0 initially");
        assertEq(totalRejected, 0, "Total rejected should be 0 initially");
        assertEq(totalExpired, 0, "Total expired should be 0 initially");
        
        console2.log("System statistics working correctly");
    }
}
