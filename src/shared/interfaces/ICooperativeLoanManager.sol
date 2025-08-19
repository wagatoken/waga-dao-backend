// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IWAGACoffeeInventoryToken} from "./IWAGACoffeeInventoryToken.sol";

/**
 * @title ICooperativeLoanManager
 * @author WAGA DAO - Regenerative Coffee Global Impact
 * @notice Interface for managing USDC loans to coffee cooperatives backed by inventory tokens
 */
interface ICooperativeLoanManager {
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
    /*                                  FUNCTIONS                                 */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Creates a new loan for a cooperative
     * @param cooperative Cooperative address
     * @param amount Loan amount in USDC (6 decimals)
     * @param durationDays Loan duration in days
     * @param interestRate Annual interest rate in basis points
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
    ) external returns (uint256 loanId);

    /**
     * @notice Creates a greenfield loan for new coffee project development
     * @param cooperative Address of the cooperative (can be newly formed)
     * @param amount Total loan amount in USDC (6 decimals)
     * @param durationYears Loan duration in years (typically 5-10 for greenfield)
     * @param interestRate Annual interest rate in basis points
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
    ) external returns (uint256 loanId, uint256 projectId);

    /**
     * @notice Disburses USDC loan to cooperative
     * @param loanId Loan ID to disburse
     */
    function disburseLoan(uint256 loanId) external;

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
    ) external;

    /**
     * @notice Allows cooperative to repay loan
     * @param loanId Loan ID to repay
     * @param amount Repayment amount in USDC
     */
    function repayLoan(uint256 loanId, uint256 amount) external;

    /**
     * @notice Marks loan as defaulted (past maturity with outstanding balance)
     * @param loanId Loan ID to mark as defaulted
     */
    function markLoanDefaulted(uint256 loanId) external;

    /**
     * @notice Liquidates collateral for defaulted loan
     * @param loanId Loan ID to liquidate
     */
    function liquidateCollateral(uint256 loanId) external;

    /* -------------------------------------------------------------------------- */
    /*                               VIEW FUNCTIONS                               */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Returns loan information
     */
    function getLoan(uint256 loanId) external view returns (LoanInfo memory);

    /**
     * @notice Returns all loans for a cooperative
     */
    function getCooperativeLoans(address cooperative) external view returns (uint256[] memory);

    /**
     * @notice Calculates current interest owed on a loan
     */
    function calculateInterest(uint256 loanId) external view returns (uint256);

    /**
     * @notice Returns total outstanding balance for a loan
     */
    function getOutstandingBalance(uint256 loanId) external view returns (uint256);

    /**
     * @notice Returns all loan IDs
     */
    function getAllLoans() external view returns (uint256[] memory);

    /**
     * @notice Returns loan statistics
     */
    function getLoanStatistics() external view returns (
        uint256 totalLoans,
        uint256 activeLoans,
        uint256 totalDisbursed,
        uint256 totalRepaid
    );

    /* -------------------------------------------------------------------------- */
    /*                            ADMIN FUNCTIONS                                */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Updates treasury address
     */
    function setTreasury(address newTreasury) external;

    /**
     * @notice Pause contract operations
     */
    function pause() external;

    /**
     * @notice Unpause contract operations
     */
    function unpause() external;

    /* -------------------------------------------------------------------------- */
    /*                               STATE GETTERS                               */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Returns USDC token address
     */
    function usdcToken() external view returns (address);

    /**
     * @notice Returns coffee inventory token address
     */
    function coffeeInventoryToken() external view returns (address);

    /**
     * @notice Returns treasury address
     */
    function treasury() external view returns (address);

    /**
     * @notice Returns next loan ID
     */
    function nextLoanId() external view returns (uint256);

    /**
     * @notice Returns loan information for a loan ID
     */
    function loans(uint256 loanId) external view returns (
        address cooperative,
        uint256 amount,
        uint256 disbursedAmount,
        uint256 repaidAmount,
        uint256 interestRate,
        uint256 startTime,
        uint256 maturityTime,
        LoanStatus status,
        string memory purpose,
        string memory cooperativeName,
        string memory location
    );

    /**
     * @notice Returns batch ID to loan ID mapping
     */
    function batchToLoan(uint256 batchId) external view returns (uint256);

    /**
     * @notice Returns all loan IDs for a cooperative
     */
    function cooperativeLoans(address cooperative, uint256 index) external view returns (uint256);

    /**
     * @notice Returns loan ID at index in all loans array
     */
    function allLoanIds(uint256 index) external view returns (uint256);
}
