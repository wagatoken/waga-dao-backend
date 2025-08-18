// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IWAGACoffeeInventoryToken} from "./interfaces/IWAGACoffeeInventoryToken.sol";

/**
 * @title CooperativeLoanManager
 * @author WAGA DAO - Regenerative Coffee Global Impact
 * @notice Manages USDC loans to coffee cooperatives backed by inventory tokens
 * @dev Implements the core loan lifecycle from disbursement to repayment with inventory backing
 * 
 * This contract manages the WAGA DAO's loan system where:
 * 1. DAO issues USDC loans to verified cooperatives
 * 2. Loans are backed by coffee inventory tokens (representing future coffee batches)
 * 3. Cooperatives repay loans through coffee sales or direct USDC payments
 * 4. DAO retains inventory tokens until loan is fully repaid
 */
contract CooperativeLoanManager is AccessControl, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /* -------------------------------------------------------------------------- */
    /*                                  CONSTANTS                                 */
    /* -------------------------------------------------------------------------- */

    /// @dev Role for DAO treasury operations
    bytes32 public constant DAO_TREASURY_ROLE = keccak256("DAO_TREASURY_ROLE");
    
    /// @dev Role for loan management operations
    bytes32 public constant LOAN_MANAGER_ROLE = keccak256("LOAN_MANAGER_ROLE");
    
    /// @dev Role for cooperative operations
    bytes32 public constant COOPERATIVE_ROLE = keccak256("COOPERATIVE_ROLE");

    /// @dev Maximum loan duration (2 years)
    uint256 public constant MAX_LOAN_DURATION = 730 days;
    
    /// @dev Minimum loan amount ($1,000 USDC)
    uint256 public constant MIN_LOAN_AMOUNT = 1000e6;

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// @dev USDC token contract
    IERC20 public immutable usdcToken;
    
    /// @dev Coffee inventory token contract
    IWAGACoffeeInventoryToken public immutable coffeeInventoryToken;
    
    /// @dev DAO treasury address
    address public treasury;
    
    /// @dev Next loan ID
    uint256 public nextLoanId = 1;
    
    /// @dev Mapping from loan ID to loan info
    mapping(uint256 => LoanInfo) public loans;
    
    /// @dev Mapping from cooperative address to active loan IDs
    mapping(address => uint256[]) public cooperativeLoans;
    
    /// @dev Mapping from batch ID to loan ID
    mapping(uint256 => uint256) public batchToLoan;
    
    /// @dev Array of all loan IDs
    uint256[] public allLoanIds;

    /* -------------------------------------------------------------------------- */
    /*                                   STRUCTS                                  */
    /* -------------------------------------------------------------------------- */

    struct LoanInfo {
        address cooperative;        // Cooperative address
        uint256 amount;            // Loan amount in USDC (6 decimals)
        uint256 disbursedAmount;   // Amount actually disbursed
        uint256 repaidAmount;      // Amount repaid so far
        uint256 interestRate;      // Annual interest rate (basis points)
        uint256 startTime;         // Loan start timestamp
        uint256 maturityTime;      // Loan maturity timestamp
        uint256[] batchIds;        // Associated coffee batch IDs
        LoanStatus status;         // Current loan status
        string purpose;            // Loan purpose description
        string cooperativeName;    // Name of cooperative
        string location;           // Geographic location
    }

    enum LoanStatus {
        Pending,     // Loan approved but not disbursed
        Active,      // Loan disbursed and active
        Repaid,      // Loan fully repaid
        Defaulted,   // Loan in default
        Liquidated   // Collateral liquidated
    }

    /* -------------------------------------------------------------------------- */
    /*                                CUSTOM ERRORS                               */
    /* -------------------------------------------------------------------------- */

    error CooperativeLoanManager__InvalidLoanAmount();
    error CooperativeLoanManager__InvalidDuration();
    error CooperativeLoanManager__InvalidInterestRate();
    error CooperativeLoanManager__InsufficientTreasuryBalance();
    error CooperativeLoanManager__LoanNotFound();
    error CooperativeLoanManager__LoanNotActive();
    error CooperativeLoanManager__LoanAlreadyRepaid();
    error CooperativeLoanManager__InvalidRepaymentAmount();
    error CooperativeLoanManager__UnauthorizedCooperative();
    error CooperativeLoanManager__InvalidBatchIds();
    error CooperativeLoanManager__LoanPastMaturity();

    /* -------------------------------------------------------------------------- */
    /*                                   EVENTS                                   */
    /* -------------------------------------------------------------------------- */

    event LoanCreated(
        uint256 indexed loanId,
        address indexed cooperative,
        uint256 amount,
        uint256 maturityTime,
        uint256[] batchIds
    );
    
    event GreenfieldLoanCreated(
        uint256 indexed loanId,
        uint256 indexed projectId,
        address indexed cooperative,
        uint256 amount,
        uint256 durationYears
    );
    
    event GreenfieldStageCompleted(
        uint256 indexed loanId,
        uint256 indexed projectId,
        uint256 stage,
        uint256 disbursementAmount
    );
    
    event LoanDisbursed(uint256 indexed loanId, uint256 amount);
    event LoanRepayment(uint256 indexed loanId, uint256 amount, uint256 remainingBalance);
    event LoanDefaulted(uint256 indexed loanId);
    event CollateralLiquidated(uint256 indexed loanId, uint256[] batchIds);
    event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);

    /* -------------------------------------------------------------------------- */
    /*                                  MODIFIERS                                 */
    /* -------------------------------------------------------------------------- */

    modifier validLoanId(uint256 loanId) {
        if (loanId == 0 || loanId >= nextLoanId) {
            revert CooperativeLoanManager__LoanNotFound();
        }
        _;
    }

    modifier onlyCooperative(uint256 loanId) {
        if (loans[loanId].cooperative != msg.sender) {
            revert CooperativeLoanManager__UnauthorizedCooperative();
        }
        _;
    }

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
     * @dev Initializes the loan manager
     * @param _usdcToken USDC token contract address
     * @param _coffeeInventoryToken Coffee inventory token contract address
     * @param _treasury DAO treasury address
     * @param _admin Initial admin address
     */
    constructor(
        address _usdcToken,
        address _coffeeInventoryToken,
        address _treasury,
        address _admin
    ) {
        require(_usdcToken != address(0), "Invalid USDC address");
        require(_coffeeInventoryToken != address(0), "Invalid inventory token address");
        require(_treasury != address(0), "Invalid treasury address");
        require(_admin != address(0), "Invalid admin address");

        usdcToken = IERC20(_usdcToken);
        coffeeInventoryToken = IWAGACoffeeInventoryToken(_coffeeInventoryToken);
        treasury = _treasury;

        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(DAO_TREASURY_ROLE, _admin);
        _grantRole(LOAN_MANAGER_ROLE, _admin);
    }

    /* -------------------------------------------------------------------------- */
    /*                              EXTERNAL FUNCTIONS                            */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Creates a new loan for a cooperative
     * @param cooperative Cooperative address
     * @param amount Loan amount in USDC (6 decimals)
     * @param durationDays Loan duration in days
     * @param interestRate Annual interest rate in basis points (e.g., 500 = 5%)
     * @param batchIds Array of coffee batch IDs as collateral
     * @param purpose Loan purpose description
     * @param cooperativeName Name of the cooperative
     * @param location Geographic location
     * @return loanId The newly created loan ID
     */
    function createLoan(
        address cooperative,
        uint256 amount,
        uint256 durationDays,
        uint256 interestRate,
        uint256[] memory batchIds,
        string memory purpose,
        string memory cooperativeName,
        string memory location
    ) external onlyRole(LOAN_MANAGER_ROLE) whenNotPaused returns (uint256 loanId) {
        // Validation
        if (amount < MIN_LOAN_AMOUNT) {
            revert CooperativeLoanManager__InvalidLoanAmount();
        }
        if (durationDays == 0 || durationDays > MAX_LOAN_DURATION / 1 days) {
            revert CooperativeLoanManager__InvalidDuration();
        }
        if (interestRate > 5000) { // Max 50% APR
            revert CooperativeLoanManager__InvalidInterestRate();
        }
        if (batchIds.length == 0) {
            revert CooperativeLoanManager__InvalidBatchIds();
        }

        // Verify all batch IDs exist and are not already used as collateral
        for (uint256 i = 0; i < batchIds.length; i++) {
            if (!coffeeInventoryToken.batchExists(batchIds[i])) {
                revert CooperativeLoanManager__InvalidBatchIds();
            }
            if (batchToLoan[batchIds[i]] != 0) {
                revert CooperativeLoanManager__InvalidBatchIds();
            }
        }

        loanId = nextLoanId++;
        uint256 maturityTime = block.timestamp + (durationDays * 1 days);

        // Create loan
        loans[loanId] = LoanInfo({
            cooperative: cooperative,
            amount: amount,
            disbursedAmount: 0,
            repaidAmount: 0,
            interestRate: interestRate,
            startTime: block.timestamp,
            maturityTime: maturityTime,
            batchIds: batchIds,
            status: LoanStatus.Pending,
            purpose: purpose,
            cooperativeName: cooperativeName,
            location: location
        });

        // Update mappings
        cooperativeLoans[cooperative].push(loanId);
        allLoanIds.push(loanId);
        
        for (uint256 i = 0; i < batchIds.length; i++) {
            batchToLoan[batchIds[i]] = loanId;
        }

        // Grant cooperative role for loan management
        _grantRole(COOPERATIVE_ROLE, cooperative);

        emit LoanCreated(loanId, cooperative, amount, maturityTime, batchIds);
        return loanId;
    }

    /**
     * @notice Creates a loan for greenfield coffee project development
     * @param cooperative Address of the cooperative (can be newly formed)
     * @param amount Total loan amount in USDC (6 decimals)
     * @param durationYears Loan duration in years (typically 5-10 for greenfield)
     * @param interestRate Annual interest rate in basis points (e.g., 500 = 5%)
     * @param projectParams Parameters for the greenfield project
     * @return loanId The newly created loan ID
     * @return projectId The newly created greenfield project ID
     */
    function createGreenfieldLoan(
        address cooperative,
        uint256 amount,
        uint256 durationYears,
        uint256 interestRate,
        IWAGACoffeeInventoryToken.GreenfieldProjectParams memory projectParams
    ) external onlyRole(LOAN_MANAGER_ROLE) whenNotPaused returns (uint256 loanId, uint256 projectId) {
        // Validation for greenfield loans
        if (amount < MIN_LOAN_AMOUNT) {
            revert CooperativeLoanManager__InvalidLoanAmount();
        }
        if (durationYears == 0 || durationYears > 10) { // Max 10 years for greenfield
            revert CooperativeLoanManager__InvalidDuration();
        }
        if (interestRate > 8000) { // Max 80% APR for greenfield (higher risk)
            revert CooperativeLoanManager__InvalidInterestRate();
        }

        // Set the loan value in the project parameters
        projectParams.loanValue = amount;

        // Create the greenfield project first
        projectId = coffeeInventoryToken.createGreenfieldProject(projectParams);

        loanId = nextLoanId++;
        uint256 maturityTime = block.timestamp + (durationYears * 365 days);

        // Create array with single greenfield project ID
        uint256[] memory batchIds = new uint256[](1);
        batchIds[0] = projectId;

        // Create loan
        loans[loanId] = LoanInfo({
            cooperative: cooperative,
            amount: amount,
            disbursedAmount: 0,
            repaidAmount: 0,
            interestRate: interestRate,
            startTime: block.timestamp,
            maturityTime: maturityTime,
            batchIds: batchIds,
            status: LoanStatus.Pending,
            purpose: "Greenfield Coffee Production Development",
            cooperativeName: projectParams.cooperativeName,
            location: projectParams.location
        });

        // Update mappings
        cooperativeLoans[cooperative].push(loanId);
        allLoanIds.push(loanId);
        batchToLoan[projectId] = loanId;

        // Grant cooperative role for loan management
        _grantRole(COOPERATIVE_ROLE, cooperative);

        emit LoanCreated(loanId, cooperative, amount, maturityTime, batchIds);
        emit GreenfieldLoanCreated(loanId, projectId, cooperative, amount, durationYears);
        return (loanId, projectId);
    }

    /**
     * @notice Disburses USDC loan to cooperative
     * @param loanId Loan ID to disburse
     */
    function disburseLoan(
        uint256 loanId
    ) external onlyRole(LOAN_MANAGER_ROLE) validLoanId(loanId) nonReentrant {
        LoanInfo storage loan = loans[loanId];
        
        if (loan.status != LoanStatus.Pending) {
            revert CooperativeLoanManager__LoanNotActive();
        }

        // Check treasury has sufficient balance
        uint256 treasuryBalance = usdcToken.balanceOf(treasury);
        if (treasuryBalance < loan.amount) {
            revert CooperativeLoanManager__InsufficientTreasuryBalance();
        }

        // Update loan status and disbursed amount
        loan.status = LoanStatus.Active;
        loan.disbursedAmount = loan.amount;

        // Transfer USDC from treasury to cooperative
        usdcToken.safeTransferFrom(treasury, loan.cooperative, loan.amount);

        emit LoanDisbursed(loanId, loan.amount);
    }

    /**
     * @notice Disburses greenfield loan in stages based on project milestones
     * @param loanId Loan ID to disburse
     * @param stage Project stage that has been completed (0-5)
     * @param disbursementAmount Amount to disburse for this stage
     * @param milestoneEvidence IPFS hash of milestone completion evidence
     */
    function disburseGreenfieldStage(
        uint256 loanId,
        uint256 stage,
        uint256 disbursementAmount,
        string memory milestoneEvidence
    ) external onlyRole(LOAN_MANAGER_ROLE) validLoanId(loanId) nonReentrant {
        LoanInfo storage loan = loans[loanId];
        
        if (loan.status != LoanStatus.Pending && loan.status != LoanStatus.Active) {
            revert CooperativeLoanManager__LoanNotActive();
        }
        
        // Check that this is a greenfield project (single batch ID that is a greenfield project)
        if (loan.batchIds.length != 1) {
            revert("Not a greenfield loan");
        }
        
        uint256 projectId = loan.batchIds[0];
        
        // Verify this is actually a greenfield project
        (bool isGreenfield,,,,) = coffeeInventoryToken.getGreenfieldProjectDetails(projectId);
        if (!isGreenfield) {
            revert("Not a greenfield project");
        }
        
        // Check treasury has sufficient balance
        uint256 treasuryBalance = usdcToken.balanceOf(treasury);
        if (treasuryBalance < disbursementAmount) {
            revert CooperativeLoanManager__InsufficientTreasuryBalance();
        }
        
        // Check total disbursements don't exceed loan amount
        if (loan.disbursedAmount + disbursementAmount > loan.amount) {
            revert("Disbursement exceeds loan amount");
        }

        // Advance the greenfield project stage
        coffeeInventoryToken.advanceGreenfieldStage(projectId, stage, 0, milestoneEvidence);

        // Update loan status and disbursed amount
        if (loan.status == LoanStatus.Pending) {
            loan.status = LoanStatus.Active;
        }
        loan.disbursedAmount += disbursementAmount;

        // Transfer USDC from treasury to cooperative
        usdcToken.safeTransferFrom(treasury, loan.cooperative, disbursementAmount);

        emit LoanDisbursed(loanId, disbursementAmount);
        emit GreenfieldStageCompleted(loanId, projectId, stage, disbursementAmount);
    }

    /**
     * @notice Allows cooperative to repay loan
     * @param loanId Loan ID to repay
     * @param amount Repayment amount in USDC
     */
    function repayLoan(
        uint256 loanId,
        uint256 amount
    ) external validLoanId(loanId) onlyCooperative(loanId) nonReentrant {
        LoanInfo storage loan = loans[loanId];
        
        if (loan.status != LoanStatus.Active) {
            revert CooperativeLoanManager__LoanNotActive();
        }
        if (amount == 0) {
            revert CooperativeLoanManager__InvalidRepaymentAmount();
        }

        // Calculate total amount owed (principal + interest)
        uint256 interest = _calculateInterest(loanId);
        uint256 totalOwed = loan.amount + interest;
        uint256 remainingBalance = totalOwed - loan.repaidAmount;

        // Ensure repayment doesn't exceed remaining balance
        if (amount > remainingBalance) {
            amount = remainingBalance;
        }

        // Update repaid amount
        loan.repaidAmount += amount;

        // Transfer USDC from cooperative to treasury
        usdcToken.safeTransferFrom(msg.sender, treasury, amount);

        // Check if loan is fully repaid
        if (loan.repaidAmount >= totalOwed) {
            loan.status = LoanStatus.Repaid;
            
            // Release collateral by allowing DAO to transfer inventory tokens
            // In practice, DAO would decide whether to sell or hold the coffee
        }

        emit LoanRepayment(loanId, amount, totalOwed - loan.repaidAmount);
    }

    /**
     * @notice Marks loan as defaulted (past maturity with outstanding balance)
     * @param loanId Loan ID to mark as defaulted
     */
    function markLoanDefaulted(
        uint256 loanId
    ) external onlyRole(LOAN_MANAGER_ROLE) validLoanId(loanId) {
        LoanInfo storage loan = loans[loanId];
        
        if (loan.status != LoanStatus.Active) {
            revert CooperativeLoanManager__LoanNotActive();
        }
        if (block.timestamp <= loan.maturityTime) {
            revert CooperativeLoanManager__LoanPastMaturity();
        }

        // Calculate if there's outstanding balance
        uint256 interest = _calculateInterest(loanId);
        uint256 totalOwed = loan.amount + interest;
        
        if (loan.repaidAmount < totalOwed) {
            loan.status = LoanStatus.Defaulted;
            emit LoanDefaulted(loanId);
        }
    }

    /**
     * @notice Liquidates collateral for defaulted loan
     * @param loanId Loan ID to liquidate
     */
    function liquidateCollateral(
        uint256 loanId
    ) external onlyRole(DAO_TREASURY_ROLE) validLoanId(loanId) {
        LoanInfo storage loan = loans[loanId];
        
        if (loan.status != LoanStatus.Defaulted) {
            revert CooperativeLoanManager__LoanNotActive();
        }

        loan.status = LoanStatus.Liquidated;

        // DAO now owns the coffee inventory tokens and can sell them
        // Implementation would involve transferring tokens to DAO treasury
        
        emit CollateralLiquidated(loanId, loan.batchIds);
    }

    /* -------------------------------------------------------------------------- */
    /*                               VIEW FUNCTIONS                               */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Returns loan information
     */
    function getLoan(uint256 loanId) external view validLoanId(loanId) returns (LoanInfo memory) {
        return loans[loanId];
    }

    /**
     * @notice Returns loan information with individual fields for easier testing
     */
    function getLoanInfo(uint256 loanId) external view validLoanId(loanId) returns (
        address cooperative,
        uint256 amount,
        uint256 disbursedAmount,
        uint256 repaidAmount,
        uint256 interestRate,
        uint256 startTime,
        uint256 maturityTime,
        uint256[] memory batchIds,
        LoanStatus status,
        string memory purpose,
        string memory cooperativeName,
        string memory location
    ) {
        LoanInfo storage loan = loans[loanId];
        return (
            loan.cooperative,
            loan.amount,
            loan.disbursedAmount,
            loan.repaidAmount,
            loan.interestRate,
            loan.startTime,
            loan.maturityTime,
            loan.batchIds,
            loan.status,
            loan.purpose,
            loan.cooperativeName,
            loan.location
        );
    }

    /**
     * @notice Returns all loans for a cooperative
     */
    function getCooperativeLoans(address cooperative) external view returns (uint256[] memory) {
        return cooperativeLoans[cooperative];
    }

    /**
     * @notice Calculates current interest owed on a loan
     */
    function calculateInterest(uint256 loanId) external view validLoanId(loanId) returns (uint256) {
        return _calculateInterest(loanId);
    }

    /**
     * @notice Returns total outstanding balance for a loan
     */
    function getOutstandingBalance(uint256 loanId) external view validLoanId(loanId) returns (uint256) {
        LoanInfo memory loan = loans[loanId];
        uint256 interest = _calculateInterest(loanId);
        uint256 totalOwed = loan.amount + interest;
        return totalOwed > loan.repaidAmount ? totalOwed - loan.repaidAmount : 0;
    }

    /**
     * @notice Returns all loan IDs
     */
    function getAllLoans() external view returns (uint256[] memory) {
        return allLoanIds;
    }

    /**
     * @notice Returns loan statistics
     */
    function getLoanStatistics() external view returns (
        uint256 totalLoans,
        uint256 activeLoans,
        uint256 totalDisbursed,
        uint256 totalRepaid
    ) {
        totalLoans = allLoanIds.length;
        
        for (uint256 i = 0; i < allLoanIds.length; i++) {
            LoanInfo memory loan = loans[allLoanIds[i]];
            
            if (loan.status == LoanStatus.Active) {
                activeLoans++;
            }
            
            totalDisbursed += loan.disbursedAmount;
            totalRepaid += loan.repaidAmount;
        }
    }

    /* -------------------------------------------------------------------------- */
    /*                            ADMIN FUNCTIONS                                */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Updates treasury address
     */
    function setTreasury(address newTreasury) external onlyRole(DAO_TREASURY_ROLE) {
        require(newTreasury != address(0), "Invalid treasury address");
        address oldTreasury = treasury;
        treasury = newTreasury;
        emit TreasuryUpdated(oldTreasury, newTreasury);
    }

    /**
     * @notice Pause contract operations
     */
    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    /**
     * @notice Unpause contract operations
     */
    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    /* -------------------------------------------------------------------------- */
    /*                             INTERNAL FUNCTIONS                             */
    /* -------------------------------------------------------------------------- */

    /**
     * @dev Calculates interest owed on a loan
     */
    function _calculateInterest(uint256 loanId) internal view returns (uint256) {
        LoanInfo memory loan = loans[loanId];
        
        if (loan.status == LoanStatus.Pending) {
            return 0;
        }

        uint256 timeElapsed = block.timestamp - loan.startTime;
        if (timeElapsed == 0) {
            return 0;
        }

        // Simple interest calculation: Principal * Rate * Time / (365 days * 10000 basis points)
        return (loan.amount * loan.interestRate * timeElapsed) / (365 days * 10000);
    }
}
