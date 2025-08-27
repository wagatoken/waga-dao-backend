// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title CoffeeStructs
 * @dev Shared data structures for the WAGA coffee ecosystem
 */
library CoffeeStructs {
    
    /// @dev Token types for dual tokenization model
    enum TokenType {
        GREEN_BEANS,
        ROASTED_BEANS
    }
    
    /// @dev Production timeframe categories
    enum ProductionTimeframe {
        CURRENT,
        FUTURE
    }
    
    /// @dev Grant stages for greenfield projects
    enum GrantStage {
        PENDING,
        APPROVED,
        DISBURSED,
        ACTIVE,
        COMPLETED,
        DEFAULTED
    }
    
    /// @dev MINIMAL on-chain batch information (blockchain-first approach aligned with DB schema)
    struct BatchInfo {
        // Essential production data (matches coffee_batches table)
        uint256 productionDate;
        uint256 expiryDate;
        uint256 currentQuantity;        // kg
        uint256 pricePerKg;            // USD with 6 decimals
        uint256 grantValue;            // USD with 6 decimals
        
        // Verification status
        bool isVerified;
        bool isMetadataVerified;
        uint256 lastVerifiedTimestamp;
        
        // Token type for dual tokenization
        TokenType tokenType;           // GREEN_BEANS or ROASTED_BEANS
        
        // IPFS reference for rich metadata (links to database)
        string metadataHash;           // All detailed data in IPFS + Database
    }
    
    /// @dev Cooperative information
    struct CooperativeInfo {
        string name;
        string location;
        address paymentAddress;
        string certifications;
        uint256 farmersCount;
        bool isVerified;
        uint256 verificationDate;
        string contactInfo;
        string website;
        uint256 establishedYear;
        string legalStatus;
        string primaryCrops;
        uint256 totalFarmArea;
        string sustainabilityPractices;
        uint256 annualProduction;
        string marketingChannels;
    }
    
    /// @dev Greenfield project information
    struct GreenfieldInfo {
        bool isGreenfieldProject;
        bool isFutureProduction;
        uint256 plantingDate;
        uint256 maturityDate;
        uint256 projectedYield;
        uint256 investmentStage;
        ProductionTimeframe timeframe;
        uint256 futureCapacityTokens;
        uint256 annualYieldProjection;
        uint256 yearsToMaturity;
        uint256 yieldGrowthRate;
    }
    
    /// @dev Grant information
    struct GrantInfo {
        uint256 grantAmount;
        uint256 daoOwnershipPercent;
        uint256 cooperativeOwnershipPercent;
        uint256 revenueSharePercent;
        uint256 grantDate;
        bool isRepaid;
        uint256 totalRevenueShared;
        uint256 minimumRevenueTarget;
        string grantPurpose;
    }
    
    /// @dev Pricing information
    struct PricingInfo {
        uint256 lastCommodityPrice;
        uint256 commodityPriceDate;
        uint256 premiumPercentage;
        uint256 calculatedPrice;
        uint256 lastPriceUpdate;
        string priceSource;
        bool isManualOverride;
        uint256 priceValidityPeriod;
        uint256 minimumPrice;
        uint256 maximumPrice;
        string currency;
        uint256 conversionRate;
        uint256 conversionDate;
        string region;
        string quality;
        string grade;
    }
    
    /// @dev MINIMAL on-chain batch data (blockchain-first approach)
    struct BatchCreationParams {
        uint256 productionDate;
        uint256 expiryDate;          // CRITICAL for roasted coffee freshness
        uint256 quantity;
        uint256 pricePerKg;
        uint256 grantValue;
        string ipfsHash;             // All rich metadata goes to IPFS + Database
    }
    
    /// @dev Rich metadata for off-chain storage (database + IPFS)
    struct BatchMetadata {
        string cooperativeName;
        string location;
        address paymentAddress;
        string certifications;
        uint256 farmersCount;
        string processingMethod;
        uint256 qualityScore;
        string sustainabilityPractices;
        // All other rich data goes to database
    }
    
    /// @dev Greenfield creation parameters
    struct GreenfieldCreationParams {
        uint256 timeframe;
        uint256 annualYieldProjection;
        uint256 daoOwnershipPercent;
        uint256 revenueSharePercent;
        uint256 premiumPercentage;
    }
}
