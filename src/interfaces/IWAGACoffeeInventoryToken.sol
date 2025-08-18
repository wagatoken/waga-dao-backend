// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title IWAGACoffeeInventoryToken
 * @dev Interface for the WAGA Coffee Inventory Token contract
 * @author WAGA DAO - Regenerative Coffee Global Impact
 */
interface IWAGACoffeeInventoryToken {
    
    // ============ Structs ============
    
    struct BatchInfo {
        uint256 productionDate;
        uint256 expiryDate;
        uint256 currentQuantity;
        uint256 pricePerKg;
        uint256 loanValue;
        bool isVerified;
        bool isMetadataVerified;
        string packagingInfo;
        string metadataHash;
        uint256 lastVerifiedTimestamp;
    }

    struct CooperativeInfo {
        string cooperativeName;
        string location;
        address paymentAddress;
        string certifications;
        uint256 farmersCount;
    }
    
    // ============ Events ============
    
    event BatchCreated(
        uint256 indexed batchId, 
        string cooperativeName, 
        uint256 quantity, 
        uint256 loanValue
    );
    
    event BatchVerified(uint256 indexed batchId, address verifier);
    event InventoryUpdated(uint256 indexed batchId, uint256 newQuantity);
    event BatchSold(uint256 indexed batchId, uint256 quantity, address buyer);
    event LoanRepaid(uint256 indexed batchId, uint256 amount);
    
    // ============ Core Functions ============
    
    /**
     * @dev Creates a new coffee batch with cooperative information
     */
    function createBatch(
        string memory ipfsUri,
        uint256 productionDate,
        uint256 expiryDate,
        uint256 quantity,
        uint256 pricePerKg,
        uint256 loanValue,
        string memory cooperativeName,
        string memory location,
        address paymentAddress,
        string memory certifications,
        uint256 farmersCount
    ) external returns (uint256 batchId);
    
    /**
     * @dev Verifies a batch's quality and quantity
     */
    function verifyBatch(
        uint256 batchId,
        uint256 actualQuantity,
        string memory metadataHash
    ) external;
    
    /**
     * @dev Mints inventory tokens to represent coffee ownership
     */
    function mintInventoryTokens(
        address to,
        uint256 batchId,
        uint256 amount
    ) external;
    
    /**
     * @dev Burns inventory tokens when coffee is sold
     */
    function burnInventoryTokens(
        address from,
        uint256 batchId,
        uint256 amount
    ) external;
    
    /**
     * @dev Records loan repayment for a batch
     */
    function recordLoanRepayment(
        uint256 batchId,
        uint256 amount
    ) external;
    
    // ============ View Functions ============
    
    /**
     * @dev Returns batch information
     */
    function getBatchInfo(uint256 batchId) external view returns (BatchInfo memory);
    
    /**
     * @dev Returns cooperative information
     */
    function getCooperativeInfo(uint256 batchId) external view returns (CooperativeInfo memory);
    
    /**
     * @dev Returns all active batch IDs
     */
    function getActiveBatchIds() external view returns (uint256[] memory);
    
    /**
     * @dev Checks if a batch exists
     */
    function batchExists(uint256 batchId) external view returns (bool);
    
    /**
     * @dev Returns total number of batches
     */
    function getTotalBatches() external view returns (uint256);
}
