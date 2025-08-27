// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IWAGACoffeeInventoryToken} from "./IWAGACoffeeInventoryToken.sol";

/**
 * @title ICooperativeGrantManager
 * @notice Interface for managing grants to coffee cooperatives with revenue sharing
 * @dev Defines functions for creating grants, managing revenue sharing, and cooperative support
 */
interface ICooperativeGrantManager {
    
    // ============ ENUMS ============
    
    enum GrantStatus {
        Pending,     // Grant created but not disbursed
        Active,      // Grant disbursed and active
        Completed,   // Grant obligations met through revenue sharing
        Matured      // Grant reached maturity time (success regardless)
    }
    
    // ============ STRUCTS ============
    
    // ============ STRUCTS ============
    
    struct PricingInfo {
        uint256 commodityPrice;        // Base ICO commodity price
        uint256 premiumPercentage;     // Premium above commodity (basis points)
        uint256 guaranteedMinPrice;    // Guaranteed minimum price per kg
        uint256 lastPriceUpdate;       // Last price update timestamp
        bool isPricingActive;          // Whether pricing guarantees are active
    }
    
    struct GrantInfo {
        address cooperative;            // Cooperative address
        uint256 amount;                // Grant amount in USDC (6 decimals)
        uint256 disbursedAmount;       // Amount actually disbursed
        uint256 daoOwnershipPercent;   // DAO ownership percentage (basis points)
        uint256 revenueSharePercent;   // DAO revenue share percentage (basis points)
        uint256 startTime;             // Grant start timestamp
        uint256 maturityTime;          // Grant completion target timestamp
        uint256[] batchIds;            // Associated coffee batch IDs
        uint256 totalRevenueShared;    // Total revenue shared with DAO
        uint256 minimumRevenueTarget;  // Minimum revenue to complete obligations
        GrantStatus status;            // Current grant status
        string purpose;                // Grant purpose description
        string cooperativeName;        // Cooperative name
        string location;               // Geographic location
        bool isGreenfield;             // Whether this is a greenfield project
        uint256 greenfieldProjectId;   // Associated greenfield project ID
        PricingInfo pricingInfo;       // Fair pricing information
    }

    // ============ PHASED DISBURSEMENT STRUCTURES ============
    
    struct MilestoneInfo {
        string description;           // Milestone description
        uint256 percentageShare;     // Percentage of total grant (basis points, e.g., 2500 = 25%)
        bool isCompleted;            // Whether milestone is completed
        string evidenceUri;          // IPFS/database URI for evidence
        uint256 completedTimestamp;  // When milestone was completed
        address validator;           // Who validated the milestone
        uint256 disbursedAmount;     // Amount disbursed for this milestone
    }
    
    struct DisbursementSchedule {
        MilestoneInfo[] milestones;   // Array of milestones
        uint256 totalMilestones;      // Total number of milestones
        uint256 completedMilestones;  // Number of completed milestones
        bool isActive;                // Whether phased disbursement is active
        uint256 escrowedAmount;       // Total amount held in escrow
    }

    // ============ EVENTS ============
    
    event GrantCreated(
        uint256 indexed grantId,
        address indexed cooperative,
        uint256 amount,
        uint256[] batchIds,
        uint256 revenueSharePercentage
    );
    
    event GreenfieldGrantCreated(
        uint256 indexed grantId,
        uint256 indexed projectId,
        address indexed cooperative,
        uint256 amount,
        string description,
        uint256 projectedYield
    );
    
    event RevenueShared(
        uint256 indexed grantId,
        uint256 revenueAmount,
        uint256 shareAmount,
        address indexed cooperative
    );
    
    event GrantCompleted(
        uint256 indexed grantId,
        uint256 totalRevenueShared
    );
    
    // ============ PHASED DISBURSEMENT EVENTS ============
    
    event DisbursementScheduleCreated(
        uint256 indexed grantId,
        uint256 totalMilestones,
        uint256 escrowedAmount
    );
    
    event MilestoneCompleted(
        uint256 indexed grantId,
        uint256 indexed milestoneIndex,
        string evidenceUri,
        address indexed validator,
        uint256 disbursedAmount
    );
    
    event MilestoneValidated(
        uint256 indexed grantId,
        uint256 indexed milestoneIndex,
        address indexed validator,
        bool approved
    );
    
    event AutoDisbursementExecuted(
        uint256 indexed grantId,
        uint256 indexed milestoneIndex,
        uint256 amount,
        address indexed recipient
    );

    event MilestoneCompleted(
        uint256 indexed grantId,
        uint256 stage,
        string milestoneEvidence
    );    // ============ ERRORS ============
    
    error CooperativeGrantManager__InvalidGrantAmount();
    error CooperativeGrantManager__InvalidRevenueShare();
    error CooperativeGrantManager__GrantNotActive();
    error CooperativeGrantManager__UnauthorizedCoop();
    error CooperativeGrantManager__InvalidBatchIds();
    error CooperativeGrantManager__InsufficientFunds();
    error CooperativeGrantManager__InvalidDuration();
    error CooperativeGrantManager__GrantAlreadyCompleted();

    // ============ VIEW FUNCTIONS ============
    
    /**
     * @dev Returns grant details
     */
    function getGrant(uint256 grantId) external view returns (GrantInfo memory);
    
    /**
     * @dev Returns if a grant is active
     */
    function isGrantActive(uint256 grantId) external view returns (bool);
    
    /**
     * @dev Returns total revenue shared for a grant
     */
    function getTotalRevenueShared(uint256 grantId) external view returns (uint256);
    
    /**
     * @dev Returns all grants for a cooperative
     */
    function getCooperativeGrants(address cooperative) external view returns (uint256[] memory);
    
    /**
     * @dev Returns the next grant ID
     */
    function nextGrantId() external view returns (uint256);
    
    /**
     * @dev Returns the grant ID associated with a batch (returns 0 if no grant)
     */
    function getBatchGrant(uint256 batchId) external view returns (uint256 grantId);

    // ============ GRANT MANAGEMENT ============
    
    /**
     * @dev Creates a grant for existing coffee batches
     */
    function createGrant(
        address cooperative,
        uint256 amount,
        uint256[] memory batchIds,
        uint256 revenueSharePercentage,
        uint256 durationYears,
        string memory description
    ) external returns (uint256 grantId);
    
    /**
     * @dev Creates a grant for greenfield coffee projects
     */
    /**
     * @dev Creates a greenfield grant for future coffee production (blockchain-first approach)
     */
    function createGreenfieldGrant(
        address cooperative,
        uint256 amount,
        uint256 revenueSharePercentage,
        uint256 durationYears,
        string memory ipfsHash,
        uint256 plantingDate,
        uint256 maturityDate,
        uint256 projectedYield,
        string memory cooperativeName
    ) external returns (uint256 grantId, uint256 projectId);
    
    /**
     * @dev Records revenue sharing from coffee sales
     */
    function recordRevenueShare(
        uint256 grantId,
        uint256 revenueAmount
    ) external;
    
    // ============ PHASED DISBURSEMENT FUNCTIONS ============
    
    /**
     * @dev Creates a disbursement schedule for a greenfield grant
     * @param grantId The grant ID to create schedule for
     * @param milestoneDescriptions Array of milestone descriptions
     * @param milestonePercentages Array of percentage shares (basis points)
     */
    function createDisbursementSchedule(
        uint256 grantId,
        string[] memory milestoneDescriptions,
        uint256[] memory milestonePercentages
    ) external;
    
    /**
     * @dev Submits evidence for milestone completion and triggers auto-disbursement
     * @param grantId The grant ID
     * @param milestoneIndex The milestone index
     * @param evidenceUri IPFS or database URI for evidence
     */
    function submitMilestoneEvidence(
        uint256 grantId,
        uint256 milestoneIndex,
        string memory evidenceUri
    ) external;
    
    /**
     * @dev Validates milestone and triggers automatic disbursement
     * @param grantId The grant ID
     * @param milestoneIndex The milestone index
     * @param approved Whether the milestone is approved
     */
    function validateMilestone(
        uint256 grantId,
        uint256 milestoneIndex,
        bool approved
    ) external;
    
    /**
     * @dev Gets disbursement schedule for a grant
     */
    function getDisbursementSchedule(uint256 grantId) 
        external view returns (DisbursementSchedule memory);
    
    /**
     * @dev Gets specific milestone info
     */
    function getMilestoneInfo(uint256 grantId, uint256 milestoneIndex)
        external view returns (MilestoneInfo memory);
    
    /**
     * @dev Completes a grant (called when duration expires or goals met)
     */
    function completeGrant(uint256 grantId) external;
    
    /**
     * @dev Advances greenfield project milestone
     */
    function advanceGreenfieldMilestone(
        uint256 grantId,
        uint256 stage,
        string memory milestoneEvidence
    ) external;
    
    // ============ PRICING FUNCTIONS ============
    
    /**
     * @dev Calculates fair minimum price for coffee batches
     */
    function calculateFairMinPrice(
        uint256 batchId,
        uint256 currentMarketPrice
    ) external view returns (uint256 fairPrice);
    
    /**
     * @dev Gets current commodity price index
     */
    function getCurrentCommodityPrice() external view returns (uint256);
    
    /**
     * @dev Updates commodity price (admin function)
     */
    function updateCommodityPrice(uint256 newPrice) external;
}
