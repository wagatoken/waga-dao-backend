// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IZKProofVerifier} from "../interfaces/IZKProofVerifier.sol";

/**
 * @title CircomVerifier
 * @notice Verifies Circom zk-proofs for simple verifications
 * @author WAGA DAO - Regenerative Coffee Global Impact
 * @dev Handles simple verifications like identity checks, milestone completion, access control
 */
contract CircomVerifier is AccessControl, Pausable, ReentrancyGuard {
    
    // ============ CONSTANTS ============
    
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    
    // Circom specific constants
    uint256 public constant MAX_PROOF_SIZE = 50000; // Maximum proof size in bytes
    uint256 public constant MAX_PUBLIC_INPUTS_SIZE = 5000; // Maximum public inputs size
    uint256 public constant PROOF_EXPIRY_TIME = 30 days; // Default proof expiry time (longer for simple proofs)
    
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
    
    /// @dev Mapping of circuit hash to verification parameters
    mapping(bytes32 => CircuitParams) public circuitParams;
    
    /// @dev Total proofs verified
    uint256 public totalProofsVerified;
    
    /// @dev Total gas used for verification
    uint256 public totalGasUsed;
    
    /// @dev Proof expiry time
    uint256 public proofExpiryTime;
    
    // ============ STRUCTS ============
    
    struct CircuitParams {
        string name;           // Circuit name
        string version;        // Circuit version
        uint256 maxInputs;     // Maximum number of inputs
        uint256 maxOutputs;    // Maximum number of outputs
        bool isActive;         // Whether circuit is active
        uint256 gasLimit;      // Gas limit for verification
    }
    
    // ============ EVENTS ============
    
    event CircomProofVerified(
        bytes32 indexed proofHash,
        bytes32 indexed circuitHash,
        bool success,
        string reason,
        uint256 gasUsed,
        uint256 timestamp
    );
    
    event CircuitRegistered(
        bytes32 indexed circuitHash,
        string name,
        string version,
        uint256 maxInputs,
        uint256 maxOutputs,
        uint256 gasLimit
    );
    
    event CircuitDeactivated(
        bytes32 indexed circuitHash,
        string reason
    );
    
    event ProofExpired(
        bytes32 indexed proofHash,
        uint256 expiryTimestamp
    );
    
    // ============ ERRORS ============
    
    error CircomVerifier__ProofTooLarge();
    error CircomVerifier__PublicInputsTooLarge();
    error CircomVerifier__UnsupportedCircuit();
    error CircomVerifier__CircuitInactive();
    error CircomVerifier__ProofExpired();
    error CircomVerifier__InvalidProofFormat();
    error CircomVerifier__VerificationFailed();
    error CircomVerifier__ProofAlreadyVerified();
    error CircomVerifier__ProofNotFound();
    error CircomVerifier__InvalidCircuitParams();
    
    // ============ CONSTRUCTOR ============
    
    constructor(address admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(VERIFIER_ROLE, admin);
        
        proofExpiryTime = PROOF_EXPIRY_TIME;
    }
    
    // ============ CORE VERIFICATION FUNCTIONS ============
    
    /**
     * @notice Verify a Circom zk-proof
     * @param proofHash Hash of the proof to verify
     * @param proofData Raw proof data from Circom
     * @param publicInputs Public inputs for verification
     * @param circuitHash Hash of the circuit
     * @return success Whether verification was successful
     */
    function verifyCircomProof(
        bytes32 proofHash,
        bytes calldata proofData,
        bytes calldata publicInputs,
        bytes32 circuitHash
    ) external onlyRole(VERIFIER_ROLE) whenNotPaused returns (bool success) {
        
        // Validate proof size
        if (proofData.length > MAX_PROOF_SIZE) {
            revert CircomVerifier__ProofTooLarge();
        }
        
        // Validate public inputs size
        if (publicInputs.length > MAX_PUBLIC_INPUTS_SIZE) {
            revert CircomVerifier__PublicInputsTooLarge();
        }
        
        // Check if circuit is supported
        if (!supportedCircuits[circuitHash]) {
            revert CircomVerifier__UnsupportedCircuit();
        }
        
        // Check if circuit is active
        if (!circuitParams[circuitHash].isActive) {
            revert CircomVerifier__CircuitInactive();
        }
        
        // Check if proof already verified
        if (proofStatuses[proofHash] == IZKProofVerifier.VerificationStatus.VERIFIED) {
            revert CircomVerifier__ProofAlreadyVerified();
        }
        
        // Check if proof expired
        if (block.timestamp > verificationTimestamps[proofHash] + proofExpiryTime) {
            proofStatuses[proofHash] = IZKProofVerifier.VerificationStatus.EXPIRED;
            emit ProofExpired(proofHash, block.timestamp);
            revert CircomVerifier__ProofExpired();
        }
        
        // Record verification attempt
        uint256 gasBefore = gasleft();
        
        // Perform Circom verification
        success = _performCircomVerification(proofData, publicInputs, circuitHash);
        
        uint256 gasUsed = gasBefore - gasleft();
        
        // Check gas limit
        if (gasUsed > circuitParams[circuitHash].gasLimit) {
            revert CircomVerifier__VerificationFailed();
        }
        
        // Update proof status
        if (success) {
            proofStatuses[proofHash] = IZKProofVerifier.VerificationStatus.VERIFIED;
            totalProofsVerified++;
            verificationReasons[proofHash] = "Circom verification successful";
        } else {
            proofStatuses[proofHash] = IZKProofVerifier.VerificationStatus.REJECTED;
            verificationReasons[proofHash] = "Circom verification failed";
        }
        
        // Record verification details
        verificationTimestamps[proofHash] = block.timestamp;
        verificationGasUsed[proofHash] = gasUsed;
        totalGasUsed += gasUsed;
        
        emit CircomProofVerified(
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
     * @notice Batch verify multiple Circom proofs
     * @param proofHashes Array of proof hashes
     * @param proofDataArray Array of proof data
     * @param publicInputsArray Array of public inputs
     * @param circuitHashes Array of circuit hashes
     * @return results Array of verification results
     */
    function batchVerifyCircomProofs(
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
            try this.verifyCircomProof(
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
     * @dev Internal function to perform Circom verification
     * @param proofData Raw proof data
     * @param publicInputs Public inputs for verification
     * @param circuitHash Hash of the circuit
     * @return success Whether verification was successful
     */
    function _performCircomVerification(
        bytes calldata proofData,
        bytes calldata publicInputs,
        bytes32 circuitHash
    ) internal view returns (bool success) {
        
        // This is a placeholder for actual Circom verification
        // In production, this would integrate with Circom's verification library
        
        // For now, we'll implement a basic validation structure
        // that can be replaced with actual Circom verification
        
        // Basic validation checks
        if (proofData.length == 0) {
            return false;
        }
        
        if (publicInputs.length == 0) {
            return false;
        }
        
        // Check if proof data has valid Circom format
        // This would include checking for proper proof structure, Groth16 format, etc.
        
        // For demonstration purposes, we'll return true if basic checks pass
        // In production, this would call the actual Circom verifier
        
        return true;
    }
    
    // ============ ADMIN FUNCTIONS ============
    
    /**
     * @notice Register a new Circom circuit
     * @param circuitHash Hash of the circuit
     * @param name Circuit name
     * @param version Circuit version
     * @param maxInputs Maximum number of inputs
     * @param maxOutputs Maximum number of outputs
     * @param gasLimit Gas limit for verification
     */
    function registerCircuit(
        bytes32 circuitHash,
        string calldata name,
        string calldata version,
        uint256 maxInputs,
        uint256 maxOutputs,
        uint256 gasLimit
    ) external onlyRole(ADMIN_ROLE) {
        if (maxInputs == 0 || maxOutputs == 0 || gasLimit == 0) {
            revert CircomVerifier__InvalidCircuitParams();
        }
        
        supportedCircuits[circuitHash] = true;
        circuitParams[circuitHash] = CircuitParams({
            name: name,
            version: version,
            maxInputs: maxInputs,
            maxOutputs: maxOutputs,
            isActive: true,
            gasLimit: gasLimit
        });
        
        emit CircuitRegistered(circuitHash, name, version, maxInputs, maxOutputs, gasLimit);
    }
    
    /**
     * @notice Deactivate a circuit
     * @param circuitHash Hash of the circuit
     * @param reason Reason for deactivation
     */
    function deactivateCircuit(bytes32 circuitHash, string calldata reason) external onlyRole(ADMIN_ROLE) {
        require(supportedCircuits[circuitHash], "Circuit not found");
        
        circuitParams[circuitHash].isActive = false;
        
        emit CircuitDeactivated(circuitHash, reason);
    }
    
    /**
     * @notice Update circuit parameters
     * @param circuitHash Hash of the circuit
     * @param maxInputs New maximum inputs
     * @param maxOutputs New maximum outputs
     * @param gasLimit New gas limit
     */
    function updateCircuitParams(
        bytes32 circuitHash,
        uint256 maxInputs,
        uint256 maxOutputs,
        uint256 gasLimit
    ) external onlyRole(ADMIN_ROLE) {
        require(supportedCircuits[circuitHash], "Circuit not found");
        
        if (maxInputs == 0 || maxOutputs == 0 || gasLimit == 0) {
            revert CircomVerifier__InvalidCircuitParams();
        }
        
        circuitParams[circuitHash].maxInputs = maxInputs;
        circuitParams[circuitHash].maxOutputs = maxOutputs;
        circuitParams[circuitHash].gasLimit = gasLimit;
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
     * @notice Get circuit parameters
     * @param circuitHash Hash of the circuit
     * @return params Circuit parameters
     */
    function getCircuitParams(bytes32 circuitHash) external view returns (CircuitParams memory params) {
        return circuitParams[circuitHash];
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
