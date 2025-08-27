// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title DatabaseIntegrationEvents
 * @notice Event definitions for database synchronization
 * @dev Events emitted by smart contracts to trigger off-chain database updates
 */
interface IDatabaseIntegration {
    
    /* -------------------------------------------------------------------------- */
    /*                              BATCH EVENTS                                 */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @notice Emitted when a new batch is created (blockchain-first approach)
     * @param batchId Blockchain-generated batch ID
     * @param productionDate Unix timestamp of production
     * @param expiryDate Unix timestamp when batch expires  
     * @param quantity Quantity in kilograms
     * @param pricePerKg Price per kilogram in USD (scaled by 1e18)
     * @param grantValue Associated grant value in USD (scaled by 1e18)
     * @param ipfsHash IPFS hash containing rich metadata
     * @param tokenType Type of token (0=GREEN_BEANS, 1=ROASTED_BEANS)
     */
    event BatchCreatedForDatabase(
        uint256 indexed batchId,
        uint256 productionDate,
        uint256 expiryDate,
        uint256 quantity,
        uint256 pricePerKg,
        uint256 grantValue,
        string ipfsHash,
        uint8 tokenType
    );
    
    /**
     * @notice Emitted when batch metadata is updated
     * @param batchId The batch ID
     * @param newIpfsHash Updated IPFS hash
     * @param verificationStatus New verification status
     */
    event BatchMetadataUpdatedForDatabase(
        uint256 indexed batchId,
        string newIpfsHash,
        bool verificationStatus
    );
    
    /**
     * @notice Emitted when green beans are converted to roasted beans
     * @param greenBatchId Original green beans batch ID
     * @param roastedBatchId New roasted beans batch ID
     * @param inputQuantity Green beans quantity used
     * @param outputQuantity Roasted beans quantity produced
     * @param roastingDate Unix timestamp of roasting
     * @param roasterAddress Address of the roaster
     */
    event RoastingCompletedForDatabase(
        uint256 indexed greenBatchId,
        uint256 indexed roastedBatchId,
        uint256 inputQuantity,
        uint256 outputQuantity,
        uint256 roastingDate,
        address indexed roasterAddress
    );
    
    /* -------------------------------------------------------------------------- */
    /*                            COOPERATIVE EVENTS                             */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @notice Emitted when cooperative information needs database sync
     * @param batchId Associated batch ID
     * @param paymentAddress Ethereum payment address
     * @param ipfsHash IPFS hash containing cooperative metadata
     */
    event CooperativeDataForDatabase(
        uint256 indexed batchId,
        address indexed paymentAddress,
        string ipfsHash
    );
    
    /* -------------------------------------------------------------------------- */
    /*                              GRANT EVENTS                                 */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @notice Emitted when a grant is created for a cooperative
     * @param grantId Unique grant identifier
     * @param cooperativeAddress Cooperative's payment address
     * @param grantAmount Grant amount in USD (scaled by 1e18)
     * @param revenueSharingPercentage Revenue sharing rate (basis points)
     * @param repaymentCapMultiplier Maximum repayment cap multiplier (scaled by 1e2)
     */
    event GrantCreatedForDatabase(
        uint256 indexed grantId,
        address indexed cooperativeAddress,
        uint256 grantAmount,
        uint256 revenueSharingPercentage,
        uint256 repaymentCapMultiplier
    );
    
    /**
     * @notice Emitted when revenue sharing payment is made
     * @param grantId Associated grant ID
     * @param batchId Associated batch ID (source of revenue)
     * @param saleAmount Total sale amount
     * @param paymentAmount Revenue sharing payment amount
     * @param paymentDate Unix timestamp of payment
     */
    event RevenuePaymentForDatabase(
        uint256 indexed grantId,
        uint256 indexed batchId,
        uint256 saleAmount,
        uint256 paymentAmount,
        uint256 paymentDate
    );
    
    /* -------------------------------------------------------------------------- */
    /*                              PRICING EVENTS                               */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @notice Emitted when pricing is updated for a batch
     * @param batchId The batch ID
     * @param eventType Type of pricing event ("CREATION", "ROASTING", "SALE", "MARKET_UPDATE")
     * @param baseCommodityPrice Base commodity price from Yahoo Finance
     * @param premiumAmount Premium amount added
     * @param totalPricePerKg Final price per kilogram
     * @param eventTimestamp Unix timestamp of the pricing event
     */
    event PricingUpdatedForDatabase(
        uint256 indexed batchId,
        string eventType,
        uint256 baseCommodityPrice,
        uint256 premiumAmount,
        uint256 totalPricePerKg,
        uint256 eventTimestamp
    );
    
    /* -------------------------------------------------------------------------- */
    /*                              IPFS EVENTS                                  */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @notice Emitted when IPFS content is uploaded
     * @param ipfsHash The IPFS hash
     * @param batchId Associated batch ID (if applicable)
     * @param contentType Type of content ("metadata", "images", "certificates")
     * @param uploadTimestamp Unix timestamp of upload
     */
    event IPFSContentForDatabase(
        string indexed ipfsHash,
        uint256 indexed batchId,
        string contentType,
        uint256 uploadTimestamp
    );
    
    /* -------------------------------------------------------------------------- */
    /*                            VERIFICATION EVENTS                            */
    /* -------------------------------------------------------------------------- */
    
    /**
     * @notice Emitted when batch verification status changes
     * @param batchId The batch ID
     * @param verifierAddress Address of the verifier
     * @param verificationType Type of verification ("QUALITY", "ORGANIC", "FAIR_TRADE")
     * @param verificationResult Verification result (true/false)
     * @param verificationTimestamp Unix timestamp of verification
     */
    event VerificationForDatabase(
        uint256 indexed batchId,
        address indexed verifierAddress,
        string verificationType,
        bool verificationResult,
        uint256 verificationTimestamp
    );
}

/**
 * @title DatabaseEventEmitter
 * @notice Utility contract for emitting database synchronization events
 * @dev Can be inherited by main contracts to standardize database integration
 */
abstract contract DatabaseEventEmitter is IDatabaseIntegration {
    
    /**
     * @notice Emit batch creation event for database sync
     */
    function _emitBatchCreatedForDatabase(
        uint256 batchId,
        uint256 productionDate,
        uint256 expiryDate,
        uint256 quantity,
        uint256 pricePerKg,
        uint256 grantValue,
        string memory ipfsHash,
        uint8 tokenType
    ) internal {
        emit BatchCreatedForDatabase(
            batchId,
            productionDate,
            expiryDate,
            quantity,
            pricePerKg,
            grantValue,
            ipfsHash,
            tokenType
        );
    }
    
    /**
     * @notice Emit roasting completion event for database sync
     */
    function _emitRoastingCompletedForDatabase(
        uint256 greenBatchId,
        uint256 roastedBatchId,
        uint256 inputQuantity,
        uint256 outputQuantity,
        uint256 roastingDate,
        address roasterAddress
    ) internal {
        emit RoastingCompletedForDatabase(
            greenBatchId,
            roastedBatchId,
            inputQuantity,
            outputQuantity,
            roastingDate,
            roasterAddress
        );
    }
    
    /**
     * @notice Emit grant creation event for database sync
     */
    function _emitGrantCreatedForDatabase(
        uint256 grantId,
        address cooperativeAddress,
        uint256 grantAmount,
        uint256 revenueSharingPercentage,
        uint256 repaymentCapMultiplier
    ) internal {
        emit GrantCreatedForDatabase(
            grantId,
            cooperativeAddress,
            grantAmount,
            revenueSharingPercentage,
            repaymentCapMultiplier
        );
    }
    
    /**
     * @notice Emit pricing update event for database sync
     */
    function _emitPricingUpdatedForDatabase(
        uint256 batchId,
        string memory eventType,
        uint256 baseCommodityPrice,
        uint256 premiumAmount,
        uint256 totalPricePerKg
    ) internal {
        emit PricingUpdatedForDatabase(
            batchId,
            eventType,
            baseCommodityPrice,
            premiumAmount,
            totalPricePerKg,
            block.timestamp
        );
    }
}

/**
 * @title CoffeeValueChainProgression
 * @notice Interface for GREEN_BEANS -> ROASTED_BEANS conversion logic
 */
interface ICoffeeValueChainProgression {
    
    /**
     * @notice Convert green beans to roasted beans
     * @param greenBatchId Source green beans batch
     * @param roastingParams Roasting parameters
     * @return roastedBatchId New roasted beans batch ID
     */
    function progressToRoastedBeans(
        uint256 greenBatchId,
        RoastingParams memory roastingParams
    ) external returns (uint256 roastedBatchId);
    
    /**
     * @notice Roasting parameters structure
     */
    struct RoastingParams {
        uint256 inputQuantity;          // Green beans quantity to roast
        uint256 expectedOutputQuantity; // Expected roasted beans output
        string roastProfile;            // "Light", "Medium", "Dark", etc.
        address roasterAddress;         // Address of the roaster
        string roastingNotes;          // Additional roasting information
        uint256 roastingDate;          // Unix timestamp of roasting
    }
}

/**
 * @title YahooFinanceIntegration
 * @notice Interface for Yahoo Finance API integration
 */
interface IYahooFinanceIntegration {
    
    /**
     * @notice Update commodity pricing from Yahoo Finance
     * @param coffeeFuturesPrice Latest coffee futures price ($/lb)
     * @param premiumPercentage WAGA premium percentage (basis points)
     * @return wagaBasePrice Final WAGA base price
     */
    function updateCommodityPricing(
        uint256 coffeeFuturesPrice,
        uint256 premiumPercentage
    ) external returns (uint256 wagaBasePrice);
    
    /**
     * @notice Get current WAGA pricing for a batch
     * @param batchId The batch ID
     * @return currentPrice Current price per kg
     * @return lastUpdated Timestamp of last price update
     */
    function getCurrentPricing(
        uint256 batchId
    ) external view returns (uint256 currentPrice, uint256 lastUpdated);
}
