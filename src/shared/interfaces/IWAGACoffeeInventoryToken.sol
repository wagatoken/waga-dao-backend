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

    struct GreenfieldInfo {
        bool isGreenfieldProject;
        bool isFutureProduction;
        uint256 plantingDate;
        uint256 maturityDate;
        uint256 projectedYield;
        uint256 investmentStage;
    }

    struct GreenfieldProjectParams {
        string ipfsUri;
        uint256 plantingDate;
        uint256 maturityDate;
        uint256 projectedYield;
        uint256 investmentStage;
        uint256 pricePerKg;
        uint256 loanValue;
        string cooperativeName;
        string location;
        address paymentAddress;
        string certifications;
        uint256 farmersCount;
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
    
    event GreenfieldProjectCreated(
        uint256 indexed projectId,
        string cooperativeName,
        uint256 plantingDate,
        uint256 maturityDate,
        uint256 projectedYield,
        uint256 loanValue
    );
    
    event GreenfieldStageAdvanced(
        uint256 indexed projectId,
        uint256 previousStage,
        uint256 newStage,
        uint256 updatedYield
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
     * @dev Creates a greenfield coffee production project
     */
    function createGreenfieldProject(
        GreenfieldProjectParams memory params
    ) external returns (uint256 projectId);
    
    /**
     * @dev Advances a greenfield project to the next development stage
     */
    function advanceGreenfieldStage(
        uint256 projectId,
        uint256 newStage,
        uint256 updatedYield,
        string memory milestoneEvidence
    ) external;
    
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
     * @dev Returns greenfield information
     */
    function getGreenfieldInfo(uint256 batchId) external view returns (GreenfieldInfo memory);
    
    /**
     * @dev Returns detailed greenfield project information
     */
    function getGreenfieldProjectDetails(uint256 projectId) external view returns (
        bool isGreenfield,
        string memory cooperativeName,
        string memory location,
        uint256 investmentStage,
        string memory stageName
    );
    
    /**
     * @dev Returns financial information about a greenfield project
     */
    function getGreenfieldFinancials(uint256 projectId) external view returns (
        uint256 plantingDate,
        uint256 maturityDate,
        uint256 projectedYield,
        uint256 loanValue
    );
    
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
