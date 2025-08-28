// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title IZKProofVerifier
 * @notice Interface for dual zk-proof verification system (RISC Zero + Circom)
 * @author WAGA DAO - Regenerative Coffee Global Impact
 * @dev Supports both RISC Zero (complex computations) and Circom (simple verifications)
 */
interface IZKProofVerifier {
    
    // ============ ENUMS ============
    
    enum ProofType {
        RISC_ZERO,      // For complex computations (coffee quality, financial modeling)
        CIRCOM          // For simple verifications (identity, milestones)
    }
    
    enum VerificationStatus {
        PENDING,
        VERIFIED,
        REJECTED,
        EXPIRED
    }
    
    // ============ STRUCTS ============
    
    struct ZKProof {
        ProofType proofType;
        bytes proofData;           // Raw proof data
        bytes publicInputs;        // Actual public inputs (not just hash)
        bytes32 publicInputsHash;  // Hash of public inputs for integrity
        bytes32 proofHash;         // IPFS hash of proof metadata
        uint256 timestamp;
        address submitter;
        bool isValid;
    }
    
    struct VerificationResult {
        bool success;
        string reason;
        uint256 gasUsed;
        uint256 verificationTimestamp;
    }
    
    struct ProofMetadata {
        string proofName;          // Human-readable proof name
        string description;        // Proof description
        string version;            // Proof version
        bytes32 circuitHash;      // Hash of the circuit/program
        uint256 maxGasLimit;      // Maximum gas for verification
    }
    
    // ============ EVENTS ============
    
    event ProofSubmitted(
        bytes32 indexed proofHash,
        ProofType indexed proofType,
        address indexed submitter,
        bytes32 publicInputsHash,
        uint256 timestamp
    );
    
    event ProofVerified(
        bytes32 indexed proofHash,
        ProofType indexed proofType,
        bool success,
        string reason,
        uint256 gasUsed
    );
    
    event ProofExpired(
        bytes32 indexed proofHash,
        ProofType indexed proofType,
        uint256 expiryTimestamp
    );
    

    
    // ============ CORE FUNCTIONS ============
    
    /**
     * @notice Submit a zk-proof for verification
     * @param proofType Type of proof (RISC_ZERO or CIRCOM)
     * @param proofData Raw proof data
     * @param publicInputs Actual public inputs
     * @param publicInputsHash Hash of public inputs for integrity
     * @param metadata Proof metadata
     * @return proofHash Unique identifier for the submitted proof
     */
    function submitProof(
        ProofType proofType,
        bytes calldata proofData,
        bytes calldata publicInputs,
        bytes32 publicInputsHash,
        ProofMetadata calldata metadata
    ) external returns (bytes32 proofHash);
    
    /**
     * @notice Verify a submitted zk-proof
     * @param proofHash Hash of the proof to verify
     * @return result Verification result with success status and details
     */
    function verifyProof(bytes32 proofHash) external returns (VerificationResult memory result);
    
    /**
     * @notice Batch verify multiple proofs of the same type
     * @param proofHashes Array of proof hashes to verify
     * @param proofType Type of proofs to verify
     * @return results Array of verification results
     */
    function batchVerifyProofs(
        bytes32[] calldata proofHashes,
        ProofType proofType
    ) external returns (VerificationResult[] memory results);
    
    // ============ QUERY FUNCTIONS ============
    
    /**
     * @notice Get proof information by hash
     * @param proofHash Hash of the proof
     * @return proof Proof information
     */
    function getProof(bytes32 proofHash) external view returns (ZKProof memory proof);
    
    /**
     * @notice Get verification status of a proof
     * @param proofHash Hash of the proof
     * @return status Current verification status
     */
    function getVerificationStatus(bytes32 proofHash) external view returns (VerificationStatus status);
    
    /**
     * @notice Check if a proof is valid and verified
     * @param proofHash Hash of the proof
     * @return isValid Whether the proof is valid and verified
     */
    function isProofValid(bytes32 proofHash) external view returns (bool isValid);
    
    /**
     * @notice Get all proofs submitted by an address
     * @param submitter Address that submitted the proofs
     * @return proofHashes Array of proof hashes
     */
    function getProofsBySubmitter(address submitter) external view returns (bytes32[] memory proofHashes);
    
    /**
     * @notice Get proofs by type and status
     * @param proofType Type of proof
     * @param status Verification status
     * @return proofHashes Array of proof hashes
     */
    function getProofsByTypeAndStatus(
        ProofType proofType,
        VerificationStatus status
    ) external view returns (bytes32[] memory proofHashes);
    
    // ============ ADMIN FUNCTIONS ============
    
    /**
     * @notice Update the verifier contract for a specific proof type
     * @param proofType Type of proof to update
     * @param newVerifier Address of the new verifier contract
     */
    function updateVerifier(ProofType proofType, address newVerifier) external;
    
    /**
     * @notice Set proof expiry time
     * @param proofType Type of proof
     * @param expiryTime Time in seconds after which proofs expire
     */
    function setProofExpiry(ProofType proofType, uint256 expiryTime) external;
    
    /**
     * @notice Expire old proofs
     * @param proofType Type of proof to expire
     * @return expiredCount Number of proofs expired
     */
    function expireOldProofs(ProofType proofType) external returns (uint256 expiredCount);
}
