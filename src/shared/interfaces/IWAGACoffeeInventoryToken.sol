// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {CoffeeStructs} from "../libraries/CoffeeStructs.sol";

/**
 * @title IWAGACoffeeInventoryToken
 * @dev Simplified interface for the WAGA Coffee Inventory Token contract (blockchain-first approach)
 * @author WAGA DAO - Regenerative Coffee Global Impact
 */
interface IWAGACoffeeInventoryToken {
    
    // ============ Events ============
    
    event BatchCreated(
        uint256 indexed batchId, 
        uint256 quantity, 
        uint256 grantValue,
        string ipfsHash
    );
    
    event GreenfieldProjectCreated(
        uint256 indexed projectId,
        uint256 plantingDate,
        uint256 maturityDate,
        uint256 projectedYield,
        uint256 grantValue,
        string ipfsHash
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
    event GrantRepaid(uint256 indexed batchId, uint256 amount);
    
    // New dual tokenization events
    event BeansRoasted(
        uint256 indexed greenBatchId,
        uint256 indexed roastedBatchId,
        uint256 greenQuantity,
        uint256 roastedQuantity,
        string roastProfile
    );
    
    event CommodityPriceUpdated(
        uint256 indexed batchId,
        uint256 commodityPrice,
        uint256 premiumPercentage,
        uint256 finalPrice
    );
    
    event RevenueShared(
        uint256 indexed batchId,
        uint256 totalRevenue,
        uint256 daoShare,
        uint256 cooperativeShare
    );
    
    event FutureProductionTokenized(
        uint256 indexed projectId,
        uint256 capacityTokens,
        uint256 annualYield,
        uint256 yearsToMaturity
    );
    
    // ============ Core Functions (Simplified for blockchain-first approach) ============
    
    /**
     * @dev Creates a coffee batch with minimal on-chain data
     * @param params Simplified parameters with IPFS hash for rich metadata
     * @return batchId The unique identifier for the created batch
     */
    function createBatch(
        CoffeeStructs.BatchCreationParams memory params
    ) external returns (uint256 batchId);
    
    /**
     * @dev Creates a greenfield coffee production project
     * @param ipfsHash IPFS hash containing all project details
     * @param plantingDate When coffee trees will be planted
     * @param maturityDate When trees reach production maturity
     * @param projectedYield Expected annual yield in kg
     * @param grantValue Grant amount for the project
     * @return projectId The unique identifier for the created project
     */
    function createGreenfieldProject(
        string memory ipfsHash,
        uint256 plantingDate,
        uint256 maturityDate,
        uint256 projectedYield,
        uint256 grantValue
    ) external returns (uint256 projectId);
    
    /**
     * @dev Gets greenfield project details
     */
    function getGreenfieldProjectDetails(uint256 projectId) 
        external 
        view 
        returns (
            bool isGreenfield,
            uint256 plantingDate,
            uint256 maturityDate,
            uint256 projectedYield,
            uint256 investmentStage
        );
    
    /**
     * @dev Advances a greenfield project to the next stage
     */
    function advanceGreenfieldStage(
        uint256 projectId,
        uint256 stage,
        uint256 updatedYield,
        string memory milestoneEvidence
    ) external;
    
    /**
     * @dev Checks if a batch exists
     */
    function batchExists(uint256 batchId) external view returns (bool);
    
    /**
     * @dev Gets batch information
     */
    function getBatchInfo(uint256 batchId) 
        external view returns (CoffeeStructs.BatchInfo memory);
}