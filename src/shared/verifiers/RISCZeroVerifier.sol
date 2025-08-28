// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IZKProofVerifier} from "../interfaces/IZKProofVerifier.sol";

/**
 * @title RISCZeroVerifier
 * @notice Verifies RISC Zero zk-proofs for complex computations
 * @author WAGA DAO - Regenerative Coffee Global Impact
 * @dev Handles complex computations like coffee quality algorithms, financial modeling, sustainability metrics
 */
contract RISCZeroVerifier is AccessControl, Pausable, ReentrancyGuard {
    
    // ============ CONSTANTS ============
    
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    
    // RISC Zero specific constants
    uint256 public constant MAX_PROOF_SIZE = 100000; // Maximum proof size in bytes
    uint256 public constant MAX_PUBLIC_INPUTS_SIZE = 10000; // Maximum public inputs size
    uint256 public constant PROOF_EXPIRY_TIME = 7 days; // Default proof expiry time
    
    // ============ STATE VARIABLES ============
    
    /// @dev Mapping of proof hash to verification status
    mapping(bytes32 => IZKProofVerifier.VerificationStatus) public proofStatuses;
    
    /// @dev Mapping of proof hash to verification timestamp
    mapping(bytes32 => uint256) public verificationTimestamps;
    
    /// @dev Mapping of proof hash to gas used for verification
    mapping(bytes32 => uint256) public verificationGasUsed;
    
    /// @dev Mapping of proof hash to verification reason
    mapping(bytes32 => string) public verificationReasons;
    
    /// @dev Mapping of circuit hash to supported status
    mapping(bytes32 => bool) public supportedCircuits;
    
    /// @dev Total proofs verified
    uint256 public totalProofsVerified;
    
    /// @dev Total gas used for verification
    uint256 public totalGasUsed;
    
    /// @dev Proof expiry time
    uint256 public proofExpiryTime;
    
    // ============ EVENTS ============
    
    event RISCZeroProofVerified(
        bytes32 indexed proofHash,
        bytes32 indexed circuitHash,
        bool success,
        string reason,
        uint256 gasUsed,
        uint256 timestamp
    );
    
    event CircuitSupported(
        bytes32 indexed circuitHash,
        string circuitName,
        string version,
        bool supported
    );
    
    event ProofExpired(
        bytes32 indexed proofHash,
        uint256 expiryTimestamp
    );
    
    // ============ ERRORS ============
    
    error RISCZeroVerifier__ProofTooLarge();
    error RISCZeroVerifier__PublicInputsTooLarge();
    error RISCZeroVerifier__UnsupportedCircuit();
    error RISCZeroVerifier__ProofExpired();
    error RISCZeroVerifier__InvalidProofFormat();
    error RISCZeroVerifier__VerificationFailed();
    error RISCZeroVerifier__ProofAlreadyVerified();
    error RISCZeroVerifier__ProofNotFound();
    
    // ============ CONSTRUCTOR ============
    
    constructor(address admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(VERIFIER_ROLE, admin);
        
        proofExpiryTime = PROOF_EXPIRY_TIME;
    }
    
    // ============ CORE VERIFICATION FUNCTIONS ============
    
    /**
     * @notice Verify a RISC Zero zk-proof
     * @param proofHash Hash of the proof to verify
     * @param proofData Raw proof data from RISC Zero
     * @param publicInputs Public inputs for verification
     * @param circuitHash Hash of the circuit/program
     * @return success Whether verification was successful
     */
    function verifyRISCZeroProof(
        bytes32 proofHash,
        bytes calldata proofData,
        bytes calldata publicInputs,
        bytes32 circuitHash
    ) external onlyRole(VERIFIER_ROLE) whenNotPaused returns (bool success) {
        
        // Validate proof size
        if (proofData.length > MAX_PROOF_SIZE) {
            revert RISCZeroVerifier__ProofTooLarge();
        }
        
        // Validate public inputs size
        if (publicInputs.length > MAX_PUBLIC_INPUTS_SIZE) {
            revert RISCZeroVerifier__PublicInputsTooLarge();
        }
        
        // Check if circuit is supported
        if (!supportedCircuits[circuitHash]) {
            revert RISCZeroVerifier__UnsupportedCircuit();
        }
        
        // Check if proof already verified
        if (proofStatuses[proofHash] == IZKProofVerifier.VerificationStatus.VERIFIED) {
            revert RISCZeroVerifier__ProofAlreadyVerified();
        }
        
        // Check if proof expired
        if (block.timestamp > verificationTimestamps[proofHash] + proofExpiryTime) {
            proofStatuses[proofHash] = IZKProofVerifier.VerificationStatus.EXPIRED;
            emit ProofExpired(proofHash, block.timestamp);
            revert RISCZeroVerifier__ProofExpired();
        }
        
        // Record verification attempt
        uint256 gasBefore = gasleft();
        
        // Perform RISC Zero verification
        success = _performRISCZeroVerification(proofData, publicInputs, circuitHash);
        
        uint256 gasUsed = gasBefore - gasleft();
        
        // Update proof status
        if (success) {
            proofStatuses[proofHash] = IZKProofVerifier.VerificationStatus.VERIFIED;
            totalProofsVerified++;
            verificationReasons[proofHash] = "RISC Zero verification successful";
        } else {
            proofStatuses[proofHash] = IZKProofVerifier.VerificationStatus.REJECTED;
            verificationReasons[proofHash] = "RISC Zero verification failed";
        }
        
        // Record verification details
        verificationTimestamps[proofHash] = block.timestamp;
        verificationGasUsed[proofHash] = gasUsed;
        totalGasUsed += gasUsed;
        
        emit RISCZeroProofVerified(
            proofHash,
            circuitHash,
            success,
            verificationReasons[proofHash],
            gasUsed,
            block.timestamp
        );
        
        return success;
    }
    
    /**
     * @notice Batch verify multiple RISC Zero proofs
     * @param proofHashes Array of proof hashes
     * @param proofDataArray Array of proof data
     * @param publicInputsArray Array of public inputs
     * @param circuitHashes Array of circuit hashes
     * @return results Array of verification results
     */
    function batchVerifyRISCZeroProofs(
        bytes32[] calldata proofHashes,
        bytes[] calldata proofDataArray,
        bytes[] calldata publicInputsArray,
        bytes32[] calldata circuitHashes
    ) external onlyRole(VERIFIER_ROLE) whenNotPaused returns (bool[] memory results) {
        
        require(
            proofHashes.length == proofDataArray.length &&
            proofHashes.length == publicInputsArray.length &&
            proofHashes.length == circuitHashes.length,
            "Array lengths must match"
        );
        
        results = new bool[](proofHashes.length);
        
        for (uint256 i = 0; i < proofHashes.length; i++) {
            try this.verifyRISCZeroProof(
                proofHashes[i],
                proofDataArray[i],
                publicInputsArray[i],
                circuitHashes[i]
            ) returns (bool success) {
                results[i] = success;
            } catch {
                results[i] = false;
            }
        }
        
        return results;
    }
    
    // ============ INTERNAL VERIFICATION FUNCTIONS ============
    
    /**
     * @dev Internal function to perform RISC Zero verification
     * @param proofData Raw proof data
     * @param publicInputs Public inputs for verification
     * @param circuitHash Hash of the circuit
     * @return success Whether verification was successful
     */
    function _performRISCZeroVerification(
        bytes calldata proofData,
        bytes calldata publicInputs,
        bytes32 circuitHash
    ) internal view returns (bool success) {
        
        // This is a placeholder for actual RISC Zero verification
        // In production, this would integrate with RISC Zero's verification library
        
        // For now, we'll implement a basic validation structure
        // that can be replaced with actual RISC Zero verification
        
        // Basic validation checks
        if (proofData.length == 0) {
            return false;
        }
        
        if (publicInputs.length == 0) {
            return false;
        }
        
        // Check if proof data has valid RISC Zero format
        // This would include checking for proper proof structure, commitments, etc.
        
        // For demonstration purposes, we'll return true if basic checks pass
        // In production, this would call the actual RISC Zero verifier
        
        return true;
    }
    
    // ============ ADMIN FUNCTIONS ============
    
    /**
     * @notice Add or remove supported circuit
     * @param circuitHash Hash of the circuit
     * @param circuitName Name of the circuit
     * @param version Version of the circuit
     * @param supported Whether the circuit is supported
     */
    function setCircuitSupport(
        bytes32 circuitHash,
        string calldata circuitName,
        string calldata version,
        bool supported
    ) external onlyRole(ADMIN_ROLE) {
        supportedCircuits[circuitHash] = supported;
        
        emit CircuitSupported(circuitHash, circuitName, version, supported);
    }
    
    /**
     * @notice Set proof expiry time
     * @param newExpiryTime New expiry time in seconds
     */
    function setProofExpiryTime(uint256 newExpiryTime) external onlyRole(ADMIN_ROLE) {
        proofExpiryTime = newExpiryTime;
    }
    
    /**
     * @notice Pause verification operations
     */
    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }
    
    /**
     * @notice Unpause verification operations
     */
    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }
    
    // ============ QUERY FUNCTIONS ============
    
    /**
     * @notice Get verification status of a proof
     * @param proofHash Hash of the proof
     * @return status Current verification status
     */
    function getProofStatus(bytes32 proofHash) external view returns (IZKProofVerifier.VerificationStatus status) {
        return proofStatuses[proofHash];
    }
    
    /**
     * @notice Check if a circuit is supported
     * @param circuitHash Hash of the circuit
     * @return supported Whether the circuit is supported
     */
    function isCircuitSupported(bytes32 circuitHash) external view returns (bool supported) {
        return supportedCircuits[circuitHash];
    }
    
    /**
     * @notice Get verification statistics
     * @return totalVerified Total proofs verified
     * @return totalGas Total gas used
     * @return expiryTime Current proof expiry time
     */
    function getVerificationStats() external view returns (
        uint256 totalVerified,
        uint256 totalGas,
        uint256 expiryTime
    ) {
        return (totalProofsVerified, totalGasUsed, proofExpiryTime);
    }
    
    /**
     * @notice Get proof verification details
     * @param proofHash Hash of the proof
     * @return timestamp Verification timestamp
     * @return gasUsed Gas used for verification
     * @return reason Verification reason
     */
    function getProofVerificationDetails(bytes32 proofHash) external view returns (
        uint256 timestamp,
        uint256 gasUsed,
        string memory reason
    ) {
        return (
            verificationTimestamps[proofHash],
            verificationGasUsed[proofHash],
            verificationReasons[proofHash]
        );
    }
}
