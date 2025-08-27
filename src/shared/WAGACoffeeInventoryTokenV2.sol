// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Supply} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import {ERC1155URIStorage} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import {IERC1155Receiver} from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {CoffeeStructs} from "./libraries/CoffeeStructs.sol";
import {IWAGACoffeeInventoryToken} from "./interfaces/IWAGACoffeeInventoryToken.sol";
import {IDatabaseIntegration, DatabaseEventEmitter, ICoffeeValueChainProgression} from "./interfaces/IDatabaseIntegration.sol";
import {GreenfieldProjectManager} from "../managers/GreenfieldProjectManager.sol";

/**
 * @title WAGACoffeeInventoryToken - Blockchain-First Coffee Tokenization
 * @author WAGA DAO - Regenerative Coffee Global Impact
 * @notice Core ERC1155 token contract with minimal on-chain storage + database integration
 * @dev Implements blockchain-first batch ID generation with database synchronization
 */
contract WAGACoffeeInventoryTokenV2 is 
    ERC1155, 
    ERC1155Supply, 
    ERC1155URIStorage, 
    AccessControl, 
    Pausable,
    IWAGACoffeeInventoryToken,
    DatabaseEventEmitter,
    ICoffeeValueChainProgression,
    IERC1155Receiver 
{
    using Strings for uint256;

    /* -------------------------------------------------------------------------- */
    /*                                  CONSTANTS                                 */
    /* -------------------------------------------------------------------------- */

    bytes32 public constant DAO_ADMIN_ROLE = keccak256("DAO_ADMIN_ROLE");
    bytes32 public constant INVENTORY_MANAGER_ROLE = keccak256("INVENTORY_MANAGER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// @dev Next batch ID to be assigned
    uint256 public nextBatchId = 1;

    /// @dev Mapping of batch ID to batch information
    mapping(uint256 => CoffeeStructs.BatchInfo) public batchInfo;

    // COOPERATIVE DATA REMOVED: All cooperative information stored in database only
    // Rich metadata accessed via IPFS hash and database integration

    /// @dev Array of all batch IDs for enumeration
    uint256[] public allBatchIds;

    /// @dev Array of active batch IDs
    uint256[] public activeBatchIds;

    /// @dev Mapping to track active batch status
    mapping(uint256 => bool) public isActiveBatch;

    /// @dev Reference to greenfield project manager
    GreenfieldProjectManager public immutable greenfieldManager;

    /* -------------------------------------------------------------------------- */
    /*                                   EVENTS                                   */
    /* -------------------------------------------------------------------------- */
    
    // Events are declared in IWAGACoffeeInventoryToken interface

    /* -------------------------------------------------------------------------- */
    /*                                   ERRORS                                   */
    /* -------------------------------------------------------------------------- */

    error WAGACoffeeInventoryToken__BatchNotFound();
    error WAGACoffeeInventoryToken__InvalidQuantity();
    error WAGACoffeeInventoryToken__InvalidPrice();
    error WAGACoffeeInventoryToken__InvalidDates();
    error WAGACoffeeInventoryToken__InsufficientInventory();
    error WAGACoffeeInventoryToken__UnauthorizedAccess();
    error WAGACoffeeInventoryToken__EmptyMetadata();

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    constructor(
        address _admin,
        address _greenfieldManager
    ) ERC1155("") {
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(DAO_ADMIN_ROLE, _admin);
        _grantRole(INVENTORY_MANAGER_ROLE, _admin);
        
        greenfieldManager = GreenfieldProjectManager(_greenfieldManager);
    }

    /* -------------------------------------------------------------------------- */
    /*                            BATCH MANAGEMENT                               */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Creates a new coffee batch with minimal on-chain data (blockchain-first approach)
     * @param params Batch creation parameters (only essential data)
     * @return batchId The created batch ID (blockchain-generated)
     */
    function createBatch(
        CoffeeStructs.BatchCreationParams memory params
    ) external onlyRole(DAO_ADMIN_ROLE) whenNotPaused returns (uint256 batchId) {
        
        _validateBatchParams(params);
        
        // BLOCKCHAIN-FIRST: Generate unique batch ID
        batchId = nextBatchId++;
        
        // MINIMAL on-chain storage - only essential data aligned with database schema
        batchInfo[batchId] = CoffeeStructs.BatchInfo({
            productionDate: params.productionDate,
            expiryDate: params.expiryDate,
            currentQuantity: params.quantity,
            pricePerKg: params.pricePerKg,
            grantValue: params.grantValue,
            isVerified: false,
            isMetadataVerified: false,
            lastVerifiedTimestamp: 0,
            tokenType: CoffeeStructs.TokenType.GREEN_BEANS,
            metadataHash: params.ipfsHash  // IPFS reference for rich metadata
        });

        // Set IPFS URI  
        _setURI(batchId, params.ipfsHash);

        // Add to tracking arrays
        allBatchIds.push(batchId);
        _addToActiveBatches(batchId);

        // Mint initial tokens to DAO (will be distributed later)
        _mint(address(this), batchId, params.quantity, "");

        emit BatchCreated(batchId, params.quantity, params.grantValue, params.ipfsHash);
        
        return batchId;
    }

    /* -------------------------------------------------------------------------- */
    /*                          GREENFIELD DELEGATION                            */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Creates a greenfield project with minimal on-chain data (blockchain-first approach)
     * @param ipfsHash IPFS hash containing all project details and cooperative information
     * @param plantingDate When coffee trees will be planted
     * @param maturityDate When trees reach production maturity
     * @param projectedYield Expected annual yield in kg
     * @param grantValue Grant amount for the project
     * @return projectId The created project ID
     */
    function createGreenfieldProject(
        string memory ipfsHash,
        uint256 plantingDate,
        uint256 maturityDate,
        uint256 projectedYield,
        uint256 grantValue
    ) external override onlyRole(DAO_ADMIN_ROLE) whenNotPaused returns (uint256 projectId) {
        
        // Generate unique project ID
        projectId = nextBatchId++; // Reuse batch ID counter for simplicity
        
        // Create project in GreenfieldProjectManager with the same ID
        greenfieldManager.createGreenfieldProject(
            ipfsHash,
            plantingDate,
            maturityDate,
            projectedYield,
            grantValue
        );
        
        // Create minimal batch info for greenfield project (simplified for blockchain-first storage)
        batchInfo[projectId] = CoffeeStructs.BatchInfo({
            productionDate: 0, // Future production
            expiryDate: maturityDate,
            currentQuantity: 0, // No current inventory
            pricePerKg: 0, // To be set later based on market conditions
            grantValue: grantValue,
            isVerified: false,
            isMetadataVerified: false,
            lastVerifiedTimestamp: 0,
            tokenType: CoffeeStructs.TokenType.GREEN_BEANS,
            metadataHash: ipfsHash // All detailed project data in IPFS + Database
        });

        // Set IPFS URI for rich metadata
        _setURI(projectId, ipfsHash);

        // Add to tracking
        allBatchIds.push(projectId);
        
        // Emit event with minimal on-chain data
        emit GreenfieldProjectCreated(
            projectId,
            plantingDate,
            maturityDate,
            projectedYield,
            grantValue,
            ipfsHash
        );
        
        return projectId;
    }

    /**
     * @notice Advances greenfield project stage by delegating to manager
     */
    function advanceGreenfieldStage(
        uint256 projectId,
        uint256 stage,
        uint256 updatedYield,
        string memory milestoneEvidence
    ) external override onlyRole(DAO_ADMIN_ROLE) {
        greenfieldManager.advanceProjectStage(projectId, stage, updatedYield, milestoneEvidence);
    }

    /**
     * @notice Gets greenfield project details from manager
     */
    function getGreenfieldProjectDetails(uint256 projectId) 
        external 
        view 
        override
        returns (
            bool isGreenfield,
            uint256 plantingDate,
            uint256 maturityDate,
            uint256 projectedYield,
            uint256 investmentStage
        ) 
    {
        return greenfieldManager.getGreenfieldProjectDetails(projectId);
    }

    /* -------------------------------------------------------------------------- */
    /*                        VALUE CHAIN PROGRESSION                            */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Convert green beans to roasted beans (core value chain progression)
     * @param greenBatchId Source green beans batch ID
     * @param roastingParams Roasting parameters and metadata
     * @return roastedBatchId New roasted beans batch ID
     */
    function progressToRoastedBeans(
        uint256 greenBatchId,
        RoastingParams memory roastingParams
    ) external override onlyRole(MINTER_ROLE) whenNotPaused returns (uint256 roastedBatchId) {
        
        // Validate green beans batch exists
        if (!exists(greenBatchId)) {
            revert WAGACoffeeInventoryToken__BatchNotFound();
        }
        
        CoffeeStructs.BatchInfo storage greenBatch = batchInfo[greenBatchId];
        
        // Must be green beans
        if (greenBatch.tokenType != CoffeeStructs.TokenType.GREEN_BEANS) {
            revert("Can only roast green beans");
        }
        
        // Validate sufficient quantity
        if (greenBatch.currentQuantity < roastingParams.inputQuantity) {
            revert WAGACoffeeInventoryToken__InsufficientInventory();
        }
        
        // Validate roasting parameters
        if (roastingParams.expectedOutputQuantity >= roastingParams.inputQuantity) {
            revert("Output quantity must be less than input (roasting loss expected)");
        }
        
        // Create new roasted beans batch (roasting loss calculated in database)
        roastedBatchId = nextBatchId++;
        
        // Copy essential data from green beans batch (simplified for minimal on-chain storage)
        batchInfo[roastedBatchId] = CoffeeStructs.BatchInfo({
            productionDate: greenBatch.productionDate,
            expiryDate: roastingParams.roastingDate + 30 days, // Roasted coffee expires in 30 days
            currentQuantity: roastingParams.expectedOutputQuantity,
            pricePerKg: greenBatch.pricePerKg, // Inherit base price (can be updated later)
            grantValue: (greenBatch.grantValue * roastingParams.expectedOutputQuantity) / roastingParams.inputQuantity, // Proportional grant value
            isVerified: false, // Needs re-verification after roasting
            isMetadataVerified: false,
            lastVerifiedTimestamp: 0,
            tokenType: CoffeeStructs.TokenType.ROASTED_BEANS,
            metadataHash: "" // Will be updated with roasting metadata in IPFS
        });
        
        // COOPERATIVE DATA REMOVED: All cooperative info stored in database
        // Roasted batch inherits cooperative association via database foreign keys
        
        // Update green beans batch (reduce quantity)
        greenBatch.currentQuantity -= roastingParams.inputQuantity;
        
        // Add to tracking arrays
        allBatchIds.push(roastedBatchId);
        _addToActiveBatches(roastedBatchId);
        
        // Mint roasted beans tokens to roaster
        _mint(roastingParams.roasterAddress, roastedBatchId, roastingParams.expectedOutputQuantity, "");
        
        // Burn consumed green beans tokens
        _burn(address(this), greenBatchId, roastingParams.inputQuantity);
        
        // Emit standard BeansRoasted event for database integration
        emit BeansRoasted(
            greenBatchId,
            roastedBatchId,
            roastingParams.inputQuantity,
            roastingParams.expectedOutputQuantity,
            roastingParams.roastProfile
        );
        
        // Emit batch created event
        emit BatchCreated(roastedBatchId, roastingParams.expectedOutputQuantity, batchInfo[roastedBatchId].grantValue, "Roasted Beans - See Database");
        
        return roastedBatchId;
    }

    /* -------------------------------------------------------------------------- */
    /*                               VIEW FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Checks if a batch exists
     */
    function batchExists(uint256 batchId) public view override returns (bool) {
        return batchId > 0 && batchId < nextBatchId;
    }

    /**
     * @notice Gets the total number of batches
     */
    function getTotalBatches() external view returns (uint256) {
        return allBatchIds.length;
    }

    /**
     * @notice Gets all batch IDs
     */
    function getAllBatchIds() external view returns (uint256[] memory) {
        return allBatchIds;
    }

    /**
     * @notice Gets active batch IDs
     */
    function getActiveBatchIds() external view returns (uint256[] memory) {
        return activeBatchIds;
    }

    /* -------------------------------------------------------------------------- */
    /*                             INTERNAL FUNCTIONS                            */
    /* -------------------------------------------------------------------------- */

    /**
     * @dev Validates batch creation parameters (blockchain-first minimal validation)
     */
    function _validateBatchParams(
        CoffeeStructs.BatchCreationParams memory params
    ) internal pure {
        if (params.productionDate >= params.expiryDate) {
            revert WAGACoffeeInventoryToken__InvalidDates();
        }
        if (params.quantity == 0) {
            revert WAGACoffeeInventoryToken__InvalidQuantity();
        }
        if (params.pricePerKg == 0) {
            revert WAGACoffeeInventoryToken__InvalidPrice();
        }
        if (bytes(params.ipfsHash).length == 0) {
            revert WAGACoffeeInventoryToken__EmptyMetadata();
        }
        // Note: Rich metadata validation happens off-chain via IPFS + database
    }

    /**
     * @dev Adds a batch to active batches tracking
     */
    function _addToActiveBatches(uint256 batchId) internal {
        if (!isActiveBatch[batchId]) {
            activeBatchIds.push(batchId);
            isActiveBatch[batchId] = true;
        }
    }

    /* -------------------------------------------------------------------------- */
    /*                              OVERRIDES                                    */
    /* -------------------------------------------------------------------------- */

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl, IERC165)
        returns (bool)
    {
        return 
            interfaceId == type(IERC1155Receiver).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._update(from, to, ids, values);
    }

    function uri(uint256 tokenId)
        public
        view
        override(ERC1155, ERC1155URIStorage)
        returns (string memory)
    {
        return super.uri(tokenId);
    }
    
    /**
     * @dev Gets batch information
     */
    function getBatchInfo(uint256 batchId) 
        external 
        view 
        returns (CoffeeStructs.BatchInfo memory) 
    {
        require(batchExists(batchId), "Batch does not exist");
        return batchInfo[batchId];
    }

    /* -------------------------------------------------------------------------- */
    /*                           ERC1155 RECEIVER                                */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Handle the receipt of a single ERC1155 token type
     * @dev This function is called at the end of a `safeTransferFrom` after the balance has been updated
     * @return bytes4 The function selector to confirm token transfer
     */
    function onERC1155Received(
        address /* operator */,
        address /* from */,
        uint256 /* id */,
        uint256 /* value */,
        bytes calldata /* data */
    ) external pure override returns (bytes4) {
        return IERC1155Receiver.onERC1155Received.selector;
    }

    /**
     * @notice Handle the receipt of multiple ERC1155 token types
     * @dev This function is called at the end of a `safeBatchTransferFrom` after the balances have been updated
     * @return bytes4 The function selector to confirm token transfer
     */
    function onERC1155BatchReceived(
        address /* operator */,
        address /* from */,
        uint256[] calldata /* ids */,
        uint256[] calldata /* values */,
        bytes calldata /* data */
    ) external pure override returns (bytes4) {
        return IERC1155Receiver.onERC1155BatchReceived.selector;
    }
}
