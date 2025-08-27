// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title SimpleGreenfieldManager
 * @dev Minimal greenfield project manager with blockchain-first approach
 * @notice Rich cooperative and project data stored in IPFS/database, minimal on-chain state
 */
contract SimpleGreenfieldManager is AccessControl, Pausable {
    
    bytes32 public constant PROJECT_MANAGER_ROLE = keccak256("PROJECT_MANAGER_ROLE");
    
    uint256 public nextProjectId = 1;
    
    // Minimal on-chain project info (blockchain-first approach)
    struct ProjectInfo {
        bool exists;
        uint256 plantingDate;
        uint256 maturityDate;
        uint256 projectedYield;
        uint256 investmentStage;
        string ipfsHash;           // All rich metadata in IPFS + database
    }
    
    mapping(uint256 => ProjectInfo) public projects;
    uint256[] public allProjectIds;
    
    event GreenfieldProjectCreated(
        uint256 indexed projectId,
        uint256 plantingDate,
        uint256 maturityDate,
        uint256 projectedYield,
        uint256 grantValue,
        string ipfsHash
    );
    
    event ProjectStageAdvanced(
        uint256 indexed projectId,
        uint256 previousStage,
        uint256 newStage,
        uint256 updatedYield
    );
    
    error SimpleGreenfieldManager__InvalidProject();
    error SimpleGreenfieldManager__InvalidStage();
    error SimpleGreenfieldManager__InvalidDates();
    error SimpleGreenfieldManager__InvalidYield();
    error SimpleGreenfieldManager__ProjectNotFound();
    
    constructor(address _admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(PROJECT_MANAGER_ROLE, _admin);
    }
    
    /**
     * @dev Creates a greenfield project with minimal on-chain data
     * @param ipfsHash IPFS hash containing all project and cooperative details
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
    ) external onlyRole(PROJECT_MANAGER_ROLE) whenNotPaused returns (uint256 projectId) {
        
        // Basic validation
        require(plantingDate < maturityDate, "Invalid dates");
        require(projectedYield > 0, "Invalid yield");
        require(bytes(ipfsHash).length > 0, "Invalid IPFS hash");
        
        projectId = nextProjectId++;
        
        projects[projectId] = ProjectInfo({
            exists: true,
            plantingDate: plantingDate,
            maturityDate: maturityDate,
            projectedYield: projectedYield,
            investmentStage: 0, // Starting stage
            ipfsHash: ipfsHash
        });
        
        allProjectIds.push(projectId);
        
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
    
    function advanceProjectStage(
        uint256 projectId,
        uint256 newStage,
        uint256 updatedYield,
        string memory
    ) external onlyRole(PROJECT_MANAGER_ROLE) {
        
        ProjectInfo storage project = projects[projectId];
        require(project.exists, "Project not found");
        require(newStage > project.investmentStage && newStage <= 5, "Invalid stage");
        require(updatedYield > 0, "Invalid yield");
        
        uint256 previousStage = project.investmentStage;
        project.investmentStage = newStage;
        project.projectedYield = updatedYield;
        
        emit ProjectStageAdvanced(projectId, previousStage, newStage, updatedYield);
    }
    
    function getGreenfieldProjectDetails(uint256 projectId) 
        external 
        view 
        returns (
            bool isGreenfield,
            uint256 plantingDate,
            uint256 maturityDate,
            uint256 projectedYield,
            uint256 investmentStage
        ) 
    {
        ProjectInfo storage project = projects[projectId];
        return (
            project.exists,
            project.plantingDate,
            project.maturityDate,
            project.projectedYield,
            project.investmentStage
        );
    }
    
    function getGreenfieldFinancials(uint256 projectId)
        external
        view
        returns (
            uint256 plantingDate,
            uint256 maturityDate,
            uint256 projectedYield,
            uint256 grantValue
        )
    {
        ProjectInfo storage project = projects[projectId];
        return (
            project.plantingDate,
            project.maturityDate,
            project.projectedYield,
            0 // grantValue tracked in main contract
        );
    }
    
    function projectExists(uint256 projectId) external view returns (bool) {
        return projects[projectId].exists;
    }
    
    function getProjectIPFS(uint256 projectId) external view returns (string memory) {
        return projects[projectId].ipfsHash;
    }
}
