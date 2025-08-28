// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IZKProofVerifier} from "./interfaces/IZKProofVerifier.sol";
import {RISCZeroVerifier} from "./verifiers/RISCZeroVerifier.sol";
import {CircomVerifier} from "./verifiers/CircomVerifier.sol";

/**
 * @title ZKProofManager
 * @notice Main contract for managing dual zk-proof verification system
 * @author WAGA DAO - Regenerative Coffee Global Impact
 * @dev Orchestrates RISC Zero (complex) and Circom (simple) verifiers
 */
contract ZKProofManager is IZKProofVerifier, AccessControl, Pausable, ReentrancyGuard {
    
    // ============ CONSTANTS ============
    
    bytes32 public constant PROOF_SUBMITTER_ROLE = keccak256("PROOF_SUBMITTER_ROLE");
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    
    // ============ STATE VARIABLES ============
    
    /// @dev RISC Zero verifier contract
    RISCZeroVerifier public riscZeroVerifier;
    
    /// @dev Circom verifier contract
    CircomVerifier public circomVerifier;
    
    /// @dev Mapping of proof hash to proof information
    mapping(bytes32 => ZKProof) public proofs;
    
    /// @dev Mapping of proof hash to verification result
    mapping(bytes32 => VerificationResult) public verificationResults;
    
    /// @dev Mapping of proof hash to IPFS metadata
    mapping(bytes32 => ProofMetadata) public proofMetadata;
    
    /// @dev Mapping of submitter to their proof hashes
    mapping(address => bytes32[]) public submitterProofs;
    
    /// @dev Mapping of proof type to status counts
    mapping(ProofType => mapping(VerificationStatus => uint256)) public proofTypeStatusCounts;
    
    /// @dev Total proofs submitted
    uint256 public totalProofsSubmitted;
    
    /// @dev Total proofs verified
    uint256 public totalProofsVerified;
    
    /// @dev Total proofs rejected
    uint256 public totalProofsRejected;
    
    /// @dev Total proofs expired
    uint256 public totalProofsExpired;
    
    // ============ EVENTS ============
    
    event ProofManagerInitialized(
        address indexed riscZeroVerifier,
        address indexed circomVerifier,
        address indexed admin
    );
    
    event VerifierUpdated(
        ProofType indexed proofType,
        address indexed oldVerifier,
        address indexed newVerifier
    );
    
    // ============ ERRORS ============
    
    error ZKProofManager__InvalidVerifierAddress();
    error ZKProofManager__ProofNotFound();
    error ZKProofManager__ProofAlreadySubmitted();
    error ZKProofManager__InvalidProofType();
    error ZKProofManager__VerificationFailed();
    error ZKProofManager__ProofExpired();
    error ZKProofManager__UnauthorizedOperation();
    
    // ============ CONSTRUCTOR ============
    
    constructor(
        address _riscZeroVerifier,
        address _circomVerifier,
        address admin
    ) {
        if (_riscZeroVerifier == address(0) || _circomVerifier == address(0)) {
            revert ZKProofManager__InvalidVerifierAddress();
        }
        
        riscZeroVerifier = RISCZeroVerifier(_riscZeroVerifier);
        circomVerifier = CircomVerifier(_circomVerifier);
        
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(VERIFIER_ROLE, admin);
        _grantRole(PROOF_SUBMITTER_ROLE, admin);
        
        emit ProofManagerInitialized(_riscZeroVerifier, _circomVerifier, admin);
    }
    
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
    ) external override whenNotPaused returns (bytes32 proofHash) {
        
        // Generate unique proof hash
        proofHash = keccak256(abi.encodePacked(
            proofType,
            proofData,
            publicInputsHash,
            metadata.circuitHash,
            block.timestamp,
            msg.sender
        ));
        
        // Check if proof already exists
        if (proofs[proofHash].timestamp != 0) {
            revert ZKProofManager__ProofAlreadySubmitted();
        }
        
        // Verify that public inputs hash matches the actual inputs
        require(
            keccak256(publicInputs) == publicInputsHash,
            "Public inputs hash mismatch"
        );
        
        // Validate that the circuit is supported
        if (proofType == ProofType.RISC_ZERO) {
            require(
                riscZeroVerifier.isCircuitSupported(metadata.circuitHash),
                "RISC Zero circuit not supported"
            );
        } else if (proofType == ProofType.CIRCOM) {
            require(
                circomVerifier.isCircuitSupported(metadata.circuitHash),
                "Circom circuit not supported"
            );
        }
        
        // Create proof record
        proofs[proofHash] = ZKProof({
            proofType: proofType,
            proofData: proofData,
            publicInputs: publicInputs,
            publicInputsHash: publicInputsHash,
            proofHash: proofHash,
            timestamp: block.timestamp,
            submitter: msg.sender,
            isValid: false
        });
        
        // Store metadata
        proofMetadata[proofHash] = metadata;
        
        // Update submitter's proof list
        submitterProofs[msg.sender].push(proofHash);
        
        // Update counters
        totalProofsSubmitted++;
        proofTypeStatusCounts[proofType][VerificationStatus.PENDING]++;
        
        emit ProofSubmitted(
            proofHash,
            proofType,
            msg.sender,
            publicInputsHash,
            block.timestamp
        );
        
        return proofHash;
    }
    
    /**
     * @notice Verify a submitted zk-proof
     * @param proofHash Hash of the proof to verify
     * @return result Verification result with success status and details
     */
    function verifyProof(bytes32 proofHash) external override whenNotPaused returns (VerificationResult memory result) {
        
        ZKProof memory proof = proofs[proofHash];
        if (proof.timestamp == 0) {
            revert ZKProofManager__ProofNotFound();
        }
        
        // Check if proof expired
        if (block.timestamp > proof.timestamp + _getProofExpiryTime(proof.proofType)) {
            _expireProof(proofHash, proof.proofType);
            revert ZKProofManager__ProofExpired();
        }
        
        // Perform verification based on proof type
        bool success;
        string memory reason;
        uint256 gasUsed;
        
        if (proof.proofType == ProofType.RISC_ZERO) {
            (success, reason, gasUsed) = _verifyRISCZeroProof(proofHash, proof);
        } else if (proof.proofType == ProofType.CIRCOM) {
            (success, reason, gasUsed) = _verifyCircomProof(proofHash, proof);
        } else {
            revert ZKProofManager__InvalidProofType();
        }
        
        // Create verification result
        result = VerificationResult({
            success: success,
            reason: reason,
            gasUsed: gasUsed,
            verificationTimestamp: block.timestamp
        });
        
        // Store result
        verificationResults[proofHash] = result;
        
        // Update proof validity
        proofs[proofHash].isValid = success;
        
        // Update counters
        if (success) {
            totalProofsVerified++;
            proofTypeStatusCounts[proof.proofType][VerificationStatus.PENDING]--;
            proofTypeStatusCounts[proof.proofType][VerificationStatus.VERIFIED]++;
        } else {
            totalProofsRejected++;
            proofTypeStatusCounts[proof.proofType][VerificationStatus.PENDING]--;
            proofTypeStatusCounts[proof.proofType][VerificationStatus.REJECTED]++;
        }
        
        emit ProofVerified(
            proofHash,
            proof.proofType,
            success,
            reason,
            gasUsed
        );
        
        return result;
    }
    
    /**
     * @notice Batch verify multiple proofs of the same type
     * @param proofHashes Array of proof hashes to verify
     * @param proofType Type of proofs to verify
     * @return results Array of verification results
     */
    function batchVerifyProofs(
        bytes32[] calldata proofHashes,
        ProofType proofType
    ) external override whenNotPaused returns (VerificationResult[] memory results) {
        
        results = new VerificationResult[](proofHashes.length);
        
        for (uint256 i = 0; i < proofHashes.length; i++) {
            try this.verifyProof(proofHashes[i]) returns (VerificationResult memory result) {
                results[i] = result;
            } catch {
                results[i] = VerificationResult({
                    success: false,
                    reason: "Verification failed",
                    gasUsed: 0,
                    verificationTimestamp: block.timestamp
                });
            }
        }
        
        return results;
    }
    
    // ============ INTERNAL VERIFICATION FUNCTIONS ============
    
    /**
     * @dev Internal function to verify RISC Zero proof
     * @param proofHash Hash of the proof
     * @param proof Proof information
     * @return success Whether verification was successful
     * @return reason Reason for success/failure
     * @return gasUsed Gas used for verification
     */
    function _verifyRISCZeroProof(
        bytes32 proofHash,
        ZKProof memory proof
    ) internal returns (bool success, string memory reason, uint256 gasUsed) {
        
        uint256 gasBefore = gasleft();
        
        try riscZeroVerifier.verifyRISCZeroProof(
            proofHash,
            proof.proofData,
            proof.publicInputs, // Use stored public inputs
            proofMetadata[proofHash].circuitHash
        ) returns (bool result) {
            success = result;
            reason = result ? "RISC Zero verification successful" : "RISC Zero verification failed";
        } catch Error(string memory errorReason) {
            success = false;
            reason = errorReason;
        } catch {
            success = false;
            reason = "RISC Zero verification reverted";
        }
        
        gasUsed = gasBefore - gasleft();
        
        return (success, reason, gasUsed);
    }
    
    /**
     * @dev Internal function to verify Circom proof
     * @param proofHash Hash of the proof
     * @param proof Proof information
     * @return success Whether verification was successful
     * @return reason Reason for success/failure
     * @return gasUsed Gas used for verification
     */
    function _verifyCircomProof(
        bytes32 proofHash,
        ZKProof memory proof
    ) internal returns (bool success, string memory reason, uint256 gasUsed) {
        
        uint256 gasBefore = gasleft();
        
        try circomVerifier.verifyCircomProof(
            proofHash,
            proof.proofData,
            proof.publicInputs, // Use stored public inputs
            proofMetadata[proofHash].circuitHash
        ) returns (bool result) {
            success = result;
            reason = result ? "Circom verification successful" : "Circom verification failed";
        } catch Error(string memory errorReason) {
            success = false;
            reason = errorReason;
        } catch {
            success = false;
            reason = "Circom verification reverted";
        }
        
        gasUsed = gasBefore - gasleft();
        
        return (success, reason, gasUsed);
    }
    
    /**
     * @dev Internal function to expire a proof
     * @param proofHash Hash of the proof
     * @param proofType Type of the proof
     */
    function _expireProof(bytes32 proofHash, ProofType proofType) internal {
        proofs[proofHash].isValid = false;
        proofTypeStatusCounts[proofType][VerificationStatus.PENDING]--;
        proofTypeStatusCounts[proofType][VerificationStatus.EXPIRED]++;
        totalProofsExpired++;
        
        emit ProofExpired(proofHash, proofType, block.timestamp);
    }
    
    /**
     * @dev Internal function to get proof expiry time
     * @param proofType Type of the proof
     * @return expiryTime Expiry time in seconds
     */
    function _getProofExpiryTime(ProofType proofType) internal view returns (uint256 expiryTime) {
        if (proofType == ProofType.RISC_ZERO) {
            return riscZeroVerifier.proofExpiryTime();
        } else if (proofType == ProofType.CIRCOM) {
            return circomVerifier.proofExpiryTime();
        }
        return 30 days; // Default
    }
    
    // ============ QUERY FUNCTIONS ============
    
    /**
     * @notice Get proof information by hash
     * @param proofHash Hash of the proof
     * @return proof Proof information
     */
    function getProof(bytes32 proofHash) external view override returns (ZKProof memory proof) {
        return proofs[proofHash];
    }
    
    /**
     * @notice Get verification status of a proof
     * @param proofHash Hash of the proof
     * @return status Current verification status
     */
    function getVerificationStatus(bytes32 proofHash) external view override returns (VerificationStatus status) {
        ZKProof memory proof = proofs[proofHash];
        if (proof.timestamp == 0) {
            return VerificationStatus.PENDING;
        }
        
        if (proof.isValid) {
            return VerificationStatus.VERIFIED;
        }
        
        if (block.timestamp > proof.timestamp + _getProofExpiryTime(proof.proofType)) {
            return VerificationStatus.EXPIRED;
        }
        
        VerificationResult memory result = verificationResults[proofHash];
        if (result.verificationTimestamp > 0) {
            return result.success ? VerificationStatus.VERIFIED : VerificationStatus.REJECTED;
        }
        
        return VerificationStatus.PENDING;
    }
    
    /**
     * @notice Check if a proof is valid and verified
     * @param proofHash Hash of the proof
     * @return isValid Whether the proof is valid and verified
     */
    function isProofValid(bytes32 proofHash) external view override returns (bool isValid) {
        return proofs[proofHash].isValid;
    }
    
    /**
     * @notice Get all proofs submitted by an address
     * @param submitter Address that submitted the proofs
     * @return proofHashes Array of proof hashes
     */
    function getProofsBySubmitter(address submitter) external view override returns (bytes32[] memory proofHashes) {
        return submitterProofs[submitter];
    }
    
    /**
     * @notice Get proofs by type and status
     * @param proofType Type of proof
     * @param status Verification status
     * @return proofHashes Array of proof hashes
     */
    function getProofsByTypeAndStatus(
        ProofType proofType,
        VerificationStatus status
    ) external view override returns (bytes32[] memory proofHashes) {
        // This would require additional storage to track proofs by type and status
        // For now, return empty array
        return new bytes32[](0);
    }
    
    // ============ ADMIN FUNCTIONS ============
    
    /**
     * @notice Update the verifier contract for a specific proof type
     * @param proofType Type of proof to update
     * @param newVerifier Address of the new verifier contract
     */
    function updateVerifier(ProofType proofType, address newVerifier) external override onlyRole(ADMIN_ROLE) {
        if (newVerifier == address(0)) {
            revert ZKProofManager__InvalidVerifierAddress();
        }
        
        address oldVerifier;
        
        if (proofType == ProofType.RISC_ZERO) {
            oldVerifier = address(riscZeroVerifier);
            riscZeroVerifier = RISCZeroVerifier(newVerifier);
        } else if (proofType == ProofType.CIRCOM) {
            oldVerifier = address(circomVerifier);
            circomVerifier = CircomVerifier(newVerifier);
        } else {
            revert ZKProofManager__InvalidProofType();
        }
        
        emit VerifierUpdated(proofType, oldVerifier, newVerifier);
    }
    
    /**
     * @notice Set proof expiry time for a specific proof type
     * @param proofType Type of proof
     * @param expiryTime Time in seconds after which proofs expire
     */
    function setProofExpiry(ProofType proofType, uint256 expiryTime) external override onlyRole(ADMIN_ROLE) {
        if (proofType == ProofType.RISC_ZERO) {
            riscZeroVerifier.setProofExpiryTime(expiryTime);
        } else if (proofType == ProofType.CIRCOM) {
            circomVerifier.setProofExpiryTime(expiryTime);
        }
    }
    
    /**
     * @notice Expire old proofs of a specific type
     * @param proofType Type of proof to expire
     * @return expiredCount Number of proofs expired
     */
    function expireOldProofs(ProofType proofType) external override onlyRole(ADMIN_ROLE) returns (uint256 expiredCount) {
        // Implementation would iterate through proofs and expire old ones
        // For now, return 0
        return 0;
    }
    
    /**
     * @notice Pause all operations
     */
    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }
    
    /**
     * @notice Unpause all operations
     */
    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }
    
    // ============ STATISTICS FUNCTIONS ============
    
    /**
     * @notice Get system statistics
     * @return totalSubmitted Total proofs submitted
     * @return totalVerified Total proofs verified
     * @return totalRejected Total proofs rejected
     * @return totalExpired Total proofs expired
     */
    function getSystemStats() external view returns (
        uint256 totalSubmitted,
        uint256 totalVerified,
        uint256 totalRejected,
        uint256 totalExpired
    ) {
        return (totalProofsSubmitted, totalProofsVerified, totalProofsRejected, totalProofsExpired);
    }
    
    /**
     * @notice Get proof type statistics
     * @param proofType Type of proof
     * @return pendingCount Count of pending proofs
     * @return verifiedCount Count of verified proofs
     * @return rejectedCount Count of rejected proofs
     * @return expiredCount Count of expired proofs
     */
    function getProofTypeStats(ProofType proofType) external view returns (
        uint256 pendingCount,
        uint256 verifiedCount,
        uint256 rejectedCount,
        uint256 expiredCount
    ) {
        return (
            proofTypeStatusCounts[proofType][VerificationStatus.PENDING],
            proofTypeStatusCounts[proofType][VerificationStatus.VERIFIED],
            proofTypeStatusCounts[proofType][VerificationStatus.REJECTED],
            proofTypeStatusCounts[proofType][VerificationStatus.EXPIRED]
        );
    }
}
