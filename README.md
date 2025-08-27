# ☕ WAGA DAO - Regenerative Coffee Global Impact

**A Swiss Verein-governed cooperative financing platform for regenerative coffee agriculture powered by blockchain technology**

[![Solidity](https://img.shields.io/badge/Solidity-^0.8.24-blue.svg)](https://soliditylang.org/)
[![Foundry](https://img.shields.io/badge/Built%20with-Foundry-orange.svg)](https://getfoundry.sh/)
[![OpenZeppelin](https://img.shields.io/badge/OpenZeppelin-Contracts-green.svg)](https://openzeppelin.com/contracts/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Tests](https://img.shields.io/badge/Tests-41%20Passing-brightgreen.svg)](#testing-framework)
[![Integration](https://img.shields.io/badge/Integration-Complete-success.svg)](#integration-tests)
[![Database](https://img.shields.io/badge/Database-Integrated-blue.svg)](#database-integration)
[![Phased%20Disbursement](https://img.shields.io/badge/Phased%20Disbursement-Production%20Ready-success.svg)](#phased-disbursement-system)

---

## 📖 Overview

WAGA DAO is a revolutionary platform that combines Swiss Verein governance with blockchain technology to finance regenerative coffee agriculture across African cooperatives through **grant-based funding**. Our mission is to create sustainable value chains that benefit coffee farmers, preserve ecosystems, and generate transparent returns for global investors.

### 🎯 Mission
- Finance regenerative coffee agriculture through **blockchain-backed grants**
- Support African coffee cooperatives with transparent, fair funding  
- **Support both existing and greenfield coffee cooperatives** with future production collateral
- **Milestone-based phased disbursement** for development projects with automatic validation
- Create gold-backed treasury reserves (PAXG/XAUT) for **USDC grant funding**
- Provide decentralized governance for global stakeholders
- Promote sustainable farming practices and ecosystem regeneration
- **Enable 3-5 year greenfield project development** from land acquisition to full production
- **Automatic disbursement upon milestone evidence validation** for streamlined operations


### 🏗️ Architecture & Cross-Chain Interoperability
The project is built on a modular, cross-chain architecture leveraging Chainlink CCIP (Cross-Chain Interoperability Protocol) for secure messaging and asset transfer between EVM networks. Core contracts are deployed on the Base network, with cross-chain operations to and from Ethereum and Arbitrum.

#### Key Smart Contracts
1. **VERTGovernanceToken (VERT)** - ERC-20 governance token with ERC-3643 compliance (Vertical Integration Token)
2. **IdentityRegistry** - KYC/AML verification system for permissioned transfers
3. **DonationHandler** - Multi-currency donation processor and token minter, with **Chainlink CCIP support for cross-chain PAXG donations** (from Ethereum) and secure source chain validation
4. **MainnetCollateralManager** - **Simplified PAXG collection and cross-chain messaging** on Ethereum mainnet, with **gas-efficient custom error handling**
5. **WAGAGovernor** - On-chain governance with proposal and voting mechanisms
6. **WAGATimelock** - Time-delayed execution for security and governance
7. **WAGACoffeeInventoryTokenV2** - Enhanced ERC-1155 tokens with database integration for coffee batches and greenfield projects
8. **CooperativeGrantManagerV2** - **Advanced USDC grant management with phased disbursement and milestone validation**
9. **GreenfieldProjectManager** - Dedicated greenfield project lifecycle management with 6-stage progression
10. **ArbitrumLendingManager** - USDC yield management and treasury operations on Arbitrum, with **CCIP-based cross-chain governance instructions** and automated yield harvesting for grant funding

---

## 🌱 **Regenerative Finance (ReFi) Principles**

WAGA DAO embodies **regenerative finance** by creating financial systems that restore and regenerate natural and social capital rather than depleting them. Our approach represents a paradigm shift from extractive to regenerative economic models:

### 🌍 **Why This is Regenerative Finance:**

#### **🔄 Circular Value Creation**
- **Coffee-backed grants**: Funding is secured by actual coffee inventory and future production, creating tangible asset backing
- **Non-extractive funding**: Coffee-collateralized grant financing eliminates debt burden while maintaining asset security
- **Real asset backing**: ERC-1155 coffee batch tokens provide transparent, verifiable collateral for all grant funding
- **Ecosystem restoration**: Coffee-backed funding specifically supports biodiversity enhancement, soil health improvement, and carbon sequestration
- **Long-term thinking**: 3-5 year coffee development cycles prioritize sustainable land use over short-term profit maximization

#### **⚖️ Wealth Redistribution & Social Equity**
- **Direct farmer ownership**: Coffee cooperatives maintain full ownership of their land and production
- **Transparent pricing**: Blockchain-based value chains ensure fair compensation for farmers
- **Community empowerment**: Decentralized governance gives stakeholders direct decision-making power
- **Knowledge transfer**: Greenfield projects include training and capacity building for sustainable practices

#### **🌿 Environmental Regeneration**
- **Carbon sequestration**: Coffee agroforestry systems capture and store atmospheric carbon
- **Biodiversity enhancement**: Shade-grown coffee preserves and creates wildlife habitats
- **Soil health**: Regenerative farming practices restore soil microbiome and fertility
- **Water conservation**: Sustainable irrigation and watershed management practices

#### **💚 Impact-First Capital Allocation**
- **Coffee-backed milestone funding**: Phased disbursement tied to coffee production milestones ensures both environmental and economic outcomes
- **Asset-secured evidence validation**: IPFS-based and Relatational Database proof systems verify coffee production progress and regenerative impact before fund release
- **Coffee inventory governance**: VERT token holders make decisions based on actual coffee production and quality metrics
- **Gold-coffee treasury backing**: Combined gold reserves and coffee inventory provide stability without speculation on essential commodities

### 🎯 **ReFi Innovation:**
WAGA's **coffee-backed phased disbursement system** ensures that capital flows only when both coffee production milestones and regenerative outcomes are demonstrated. This creates a direct three-way link between financial flows, tangible coffee asset creation, and positive environmental/social impact. Unlike traditional finance where agricultural commodities are often speculated upon, WAGA uses coffee inventory as productive collateral that grows in value through regenerative practices.

---

## 🚀 **NEW: Phased Disbursement System**

### 📋 **Milestone-Based Automatic Disbursement**
WAGA DAO features a revolutionary **phased disbursement system** for greenfield projects that automatically releases grant funds when milestones are validated:

#### ✨ **Key Features:**
- **Automatic Disbursement**: Grant funds released immediately upon milestone evidence validation
- **Role-Based Validation**: Dedicated `MILESTONE_VALIDATOR_ROLE` for evidence approval
- **Escrow Management**: Smart contract-managed escrow with real-time balance tracking
- **Evidence Submission**: IPFS-based evidence storage with tamper-proof verification
- **Database Integration**: Complete audit trail and progress tracking
- **Percentage-Based Allocation**: Flexible milestone percentages (e.g., 30%, 25%, 25%, 20%)

#### 🔄 **Workflow:**
1. **Schedule Creation**: Grant manager defines milestones with percentage allocations
2. **Evidence Submission**: Cooperatives submit evidence for milestone completion
3. **Validation**: Authorized validators approve/reject evidence
4. **Automatic Disbursement**: System immediately releases grant funds upon approval
5. **Progress Tracking**: Real-time milestone completion and fund disbursement tracking

#### 📊 **Smart Contract Architecture:**
```solidity
struct DisbursementSchedule {
    MilestoneInfo[] milestones;
    uint256 totalMilestones;
    uint256 completedMilestones;
    bool isActive;
    uint256 escrowedAmount;
}

struct MilestoneInfo {
    string description;
    uint256 percentageShare;    // Basis points (10000 = 100%)
    bool isCompleted;
    string evidenceUri;         // IPFS evidence storage
    uint256 completedTimestamp;
    address validator;
    uint256 disbursedAmount;
}
```

#### 🗄️ **Database Integration:**
Complete database schema with 5 new tables:
- `disbursement_schedules` - Overall schedule management
- `milestones` - Individual milestone definitions
- `milestone_evidence` - Evidence submissions and validation
- `disbursement_history` - Complete audit trail
- `escrow_balances` - Real-time balance tracking

#### 🧪 **Comprehensive Testing:**
- **5/5 Phased Disbursement Tests Passing**
- End-to-end workflow validation
- Milestone validation testing
- Escrow management verification
- Error condition handling
- Backward compatibility maintained
struct DisbursementSchedule {
    MilestoneInfo[] milestones;
    uint256 totalMilestones;
    uint256 completedMilestones;
    bool isActive;
    uint256 escrowedAmount;
}

struct MilestoneInfo {
    string description;
    uint256 percentageShare;    // Basis points (10000 = 100%)
    bool isCompleted;
    string evidenceUri;         // IPFS evidence storage
    uint256 completedTimestamp;
    address validator;
    uint256 disbursedAmount;
}
```

#### 🗄️ **Database Integration:**
Complete database schema with 5 tables:
- `disbursement_schedules` - Overall schedule management
- `milestones` - Individual milestone definitions
- `milestone_evidence` - Evidence submissions and validation
- `disbursement_history` - Complete audit trail
- `escrow_balances` - Real-time balance tracking

#### 🧪 **Comprehensive Testing:**
- **5/5 Phased Disbursement Tests Passing**
- End-to-end workflow validation
- Milestone validation testing
- Escrow management verification
- Error condition handling
- Backward compatibility maintained

---

## 📊 **Database Integration**

### 🗄️ **Complete Database Schema**
Full PostgreSQL schema integration with:
- **Coffee batch tracking** with metadata and pricing history
- **Cooperative management** with certifications and farmer details
- **Grant management** with phased disbursement support
- **IPFS content tracking** for decentralized storage
- **Revenue sharing** and payment history
- **Performance optimization** with strategic indexing

### 🔗 **Database Integration Interfaces**
```solidity
interface IDatabaseIntegration {
    function recordBatchCreation(BatchCreationData calldata data) external;
    function recordPriceUpdate(PriceUpdateData calldata data) external;
    function recordCooperativeData(CooperativeData calldata data) external;
}
```

### 📈 **Reporting Views**
Pre-built database views for:
- Grant disbursement status and progress
- Milestone completion tracking
- Evidence validation workflow
- Coffee batch performance analytics
- Revenue sharing summaries

---

## � Chainlink CCIP Integration

WAGA DAO leverages [Chainlink CCIP](https://chain.link/ccip) to enable secure, programmable cross-chain workflows:

- **Cross-Chain PAXG Donations:**
    - Donors can send PAXG (gold-backed token) from Ethereum to the Base network using Chainlink CCIP. The `DonationHandler` contract on Base receives and processes these donations, mints VERT tokens, and tracks cross-chain provenance.
- **Cross-Chain Governance & Yield Management:**
    - The `ArbitrumLendingManager` on Arbitrum receives governance instructions (e.g., yield harvesting, emergency pause) from the Base network via CCIP. This enables decentralized, on-chain control of yield strategies and fund allocation across networks for grant funding.
- **Source Chain Validation:**
    - All CCIP-enabled contracts validate the source chain selector to prevent spoofed or unauthorized cross-chain messages.
- **Event Logging:**
    - All cross-chain actions are transparently logged with message IDs, source chain selectors, and payloads for auditability.

**Example Cross-Chain Flows:**

1. **PAXG Donation (Ethereum → Base):**
     - Donor sends PAXG to `MainnetCollateralManager` on Ethereum.
     - **PAXG stored as gold-backed treasury reserves** on Ethereum mainnet.
     - Chainlink CCIP relays donation message to `DonationHandler` on Base.
     - `DonationHandler` validates the source, decodes donor and amount, mints VERT, and logs the event.
     - **No actual PAXG transferred cross-chain** - only messaging for governance token minting.

2. **Governance Instruction (Base → Arbitrum):**
     - DAO proposal on Base triggers a governance action (e.g., "HARVEST_YIELD").
     - Chainlink CCIP relays the instruction to `ArbitrumLendingManager` on Arbitrum.
     - The contract executes the instruction (e.g., harvests yield, pauses treasury operations) and logs the cross-chain event.

---

---

## �🚀 Quick Start

### Prerequisites
- [Foundry](https://getfoundry.sh/) installed
- [Git](https://git-scm.com/) installed
- Node.js 16+ (for frontend integration)

### Installation

```bash
# Clone the repository
git clone https://github.com/your-org/waga-dao-backend
cd waga-dao-backend

# Install dependencies
forge install

# Build contracts
forge build

# Run tests
forge test
```

### Environment Setup

Create a `.env` file with the following variables:

```env
# Private Keys
PRIVATE_KEY_SEP=your_sepolia_private_key
DEFAULT_ANVIL_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# RPC Endpoints (optional - defaults provided)
BASE_SEPOLIA_RPC=https://sepolia.base.org
SEPOLIA_RPC=https://sepolia.infura.io/v3/YOUR_KEY
```

---

## 🏛️ Smart Contract Architecture

### Core Contracts

#### 🌱 VERTGovernanceToken (VERT)
**Location**: `src/VERTGovernanceToken.sol`

**Features**:
- ERC-20 token with voting capabilities (ERC20Votes)
- ERC-3643 compliant permissioned transfers
- Only verified addresses can send/receive tokens
- Controlled minting by authorized minters
- Burning functionality for token holders
- Pausable for emergency situations

**Key Functions**:
```solidity
function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE)
function burn(uint256 amount) external
function setIdentityRegistry(address newRegistry) external
```

#### 🛡️ IdentityRegistry
**Location**: `src/IdentityRegistry.sol`

**Features**:
- KYC/AML verification management
- Role-based access control for registrars
- Batch operations for efficiency
- Pausable for emergency situations


#### 💰 DonationHandler (with CCIP)
**Location**: `src/DonationHandler.sol`

**Features**:
- Multi-currency donation support (ETH, USDC direct, **PAXG via Chainlink CCIP from Ethereum**)
- Cross-chain PAXG donation processing and VERT minting
- Dynamic conversion rates with real-time price feeds
- ERC-3643 compliance (only verified addresses can receive tokens)
- Source chain validation for secure cross-chain messaging
- Emergency pause functionality
- Transparent event logging for all cross-chain and local actions
- Support for regenerative coffee agriculture funding

#### 🏛️ MainnetCollateralManager (Ethereum)
**Location**: `src/mainnet/MainnetCollateralManager.sol`

**Features**:
- **Simplified PAXG collection and storage** as gold-backed treasury reserves
- **Cross-chain messaging only** - no actual asset transfer via CCIP
- **Gas-efficient custom error handling** following consistent patterns
- Real-time gold pricing via Chainlink XAU/USD price feeds
- **Clean separation of concerns** - no cooperative allocation logic
- KYC/AML integration for verified donors only
- Emergency withdrawal capabilities for treasury management
- **Focused architecture** - pure treasury reserve management on mainnet

**Key Functions**:
```solidity
function processPaxgDonation(uint256 amount) external
function getCurrentXauPrice() external view returns (uint256, uint256)
function emergencyWithdraw(address token, uint256 amount, address to) external
```

#### 🌉 ArbitrumLendingManager (with CCIP)
**Location**: `src/arbitrum/ArbitrumLendingManager.sol`

**Features**:
- USDC yield management and treasury operations on Arbitrum (Aave V3)
- **Receives governance instructions from Base via Chainlink CCIP**
- Automated yield harvesting and emergency controls via cross-chain proposals
- Multi-year greenfield project financing support
- Role-based access and emergency withdrawal
- Transparent event logging for all cross-chain and local actions

#### ☕ WAGACoffeeInventoryTokenV2
**Location**: `src/shared/WAGACoffeeInventoryTokenV2.sol`

**Features**:
- Enhanced ERC-1155 tokens representing coffee batches and greenfield projects
- **Database integration** with automatic event emission for off-chain storage
- Comprehensive inventory management for existing production
- Greenfield project development with 6-stage lifecycle
- Future production collateral for development grants
- Detailed project tracking (planning → full production, 3-5 years)
- **Coffee value chain progression** with roasting and quality management
- Integration with cooperative financing systems

**Database Integration Events**:
```solidity
event BatchCreated(uint256 indexed batchId, BatchCreationData data);
event PriceUpdated(uint256 indexed batchId, PriceUpdateData data);
event ProgressionRecorded(uint256 indexed fromBatchId, uint256 indexed toBatchId);
```

#### 🏦 CooperativeGrantManagerV2 (Enhanced)
**Location**: `src/base/CooperativeGrantManagerV2.sol`

**Features**:
- **Phased disbursement system** with milestone-based automatic releases
- USDC grant creation for existing production and greenfield development
- **Evidence-based milestone validation** with IPFS storage
- **Automatic disbursement upon validation** - no manual intervention required
- **Escrow management** with smart contract-controlled funds
- **Role-based access control** for validators and grant managers
- Extended grant terms (up to 60 months for development projects)
- Integration with DAO governance for grant approval
- **Complete audit trail** for all disbursements and validations

**Phased Disbursement Functions**:
```solidity
function createDisbursementSchedule(
    uint256 grantId,
    string[] memory descriptions,
    uint256[] memory percentages
) external onlyRole(GRANT_MANAGER_ROLE);

function submitMilestoneEvidence(
    uint256 grantId,
    uint256 milestoneIndex,
    string memory evidenceUri
) external;

function validateMilestone(
    uint256 grantId,
    uint256 milestoneIndex,
    bool approved
) external onlyRole(MILESTONE_VALIDATOR_ROLE);
```

#### 🌱 GreenfieldProjectManager
**Location**: `src/managers/GreenfieldProjectManager.sol`

**Features**:
- Dedicated greenfield project lifecycle management
- 6-stage development progression tracking
- Project timeline and milestone validation
- IPFS-based project documentation
- Integration with grant management system
- Development progress monitoring

#### 🏛️ WAGAGovernor
**Location**: `src/WAGAGovernor.sol`

**Features**:
- OpenZeppelin Governor-based on-chain governance
- VERT token-based voting with delegation support
- Proposal creation for grant approvals and DAO management
- Integration with timelock for security
- Customizable voting parameters

#### ⏰ WAGATimelock
**Location**: `src/WAGATimelock.sol`

**Features**:
- 2-day minimum delay for governance execution
- Multi-role access control (proposer, executor, admin)
- Emergency cancellation capabilities
- Integration with governor contract

---

## 🔧 Development Tools & Scripts

### Helper Configuration
**Location**: `script/HelperConfig.s.sol`

Provides network-specific configurations for:
- **Sepolia Testnet**: Full testnet token addresses
- **Base Sepolia**: Layer 2 testnet deployment
- **Anvil Local**: Automatic mock token deployment

### Deployment Scripts
**Location**: `script/DeployWAGADAO.s.sol`

Complete deployment pipeline:
1. Deploy IdentityRegistry
2. Deploy VERTGovernanceToken
3. Deploy WAGATimelock
4. Deploy WAGAGovernor
5. Deploy WAGACoffeeInventoryToken
6. Deploy CooperativeGrantManagerV2
7. Deploy DonationHandler
8. Set up roles and permissions

### Interaction Scripts
**Location**: `script/WAGAInteractions.s.sol`

Operational scripts for:
- **RegisterIdentity**: KYC user registration
- **MakeDonationETH**: ETH donation workflow
- **MakeDonationUSDC**: USDC donation workflow
- **CreateCoffeeBatch**: Coffee batch creation for collateral
- **CreateGrant**: Cooperative grant creation with milestone setup
- **CreateProposal**: Governance proposal creation
- **DelegateVotes**: Vote delegation
- **CheckBalances**: System state inspection
- **SubmitMilestoneEvidence**: Phased disbursement milestone validation

### Usage Examples

#### Deploy Complete System
```bash
# Deploy to Anvil (local testing)
forge script script/DeployWAGADAO.s.sol --rpc-url http://localhost:8545 --broadcast

# Deploy to Base Sepolia
forge script script/DeployWAGADAO.s.sol --rpc-url $BASE_SEPOLIA_RPC --broadcast --verify
```

#### Create Coffee Batch for Collateral
```bash
forge script script/WAGAInteractions.s.sol:CreateCoffeeBatch --rpc-url $RPC_URL --broadcast
```

#### Create Cooperative Grant with Milestones
```bash
forge script script/WAGAInteractions.s.sol:CreateGrant --rpc-url $RPC_URL --broadcast
```

#### Make ETH Donation
```bash
forge script script/WAGAInteractions.s.sol:MakeDonationETH --rpc-url $RPC_URL --broadcast
```

---

## 🌍 Governance Model

### Swiss Verein Structure
- **Legal Framework**: Swiss Association (Verein) provides legal clarity
- **Global Participation**: Open to international donors and coffee stakeholders
- **Transparency**: All grant decisions and treasury management recorded on-chain

### VERT Token-Based Voting
- **1 VERT = 1 Vote**: Democratic governance structure
- **Proposal Threshold**: 1,00,000 VERT required to create proposals
- **Voting Delay**: 1 day (7,200 blocks)
- **Voting Period**: 7 days (50,400 blocks)
- **Timelock Delay**: 2 days for security

### Governance Process
1. **Proposal Creation**: VERT holders create grant approval or treasury management proposals
2. **Voting Delay**: 1-day period before voting begins
3. **Voting Period**: 7-day voting window
4. **Queuing**: Successful proposals queued in timelock
5. **Execution**: 2-day delay before execution

---

## 💰 Financial Model

### Treasury Structure
- **Gold-Backed Reserves**: PAXG/XAUT holdings provide stability
- **USDC Grant Pool**: Primary currency for cooperative grants
- **Coffee Inventory Collateral**: ERC-1155 tokens providing value backing
- **Risk Management**: Diversified collateral across multiple cooperatives

### Grant Parameters
- **Grant Terms**: Non-repayable funding for sustainable development
- **Grant Duration**: 6 months to 5 years for development projects
- **Milestone-Based**: Phased disbursement tied to project progress
- **Minimum Grant**: $1,0000 USDC
- **Maximum Project Duration**: 1,825 days (5 years)

### Supported Currencies

**Rate Structure**: 1 VERT = $1 USD equivalent (rates below are indicative only - i.e. not based on real asset prices)

| Currency | VERT per unit | USD Value Example | Network | Decimals |
|----------|---------------|------------------|---------|----------|
| ETH      | 3,000         | 1 ETH ≈ $3,000   | Base    | 18       |
| USDC     | 1             | 1 USDC = $1      | Base    | 6        |
| PAXG     | 2,000         | 1 PAXG ≈ $2,000  | Base    | 18       |
| Fiat     | 1             | 1 USD = $1       | Off-chain | 18     |

---

## ☕ Coffee Cooperative Integration

### Batch Creation Process
1. **Cooperative Registration**: Cooperative verified in IdentityRegistry
2. **Batch Documentation**: Coffee batch details recorded on-chain
3. **Quality Assessment**: Third-party quality verification
4. **Token Minting**: ERC-1155 tokens representing the batch
5. **Grant Collateral**: Tokens used as value backing for USDC grants

### Batch Information Structure
```solidity
struct BatchInfo {
    uint256 quantity;           // Quantity in kg
    uint256 pricePerUnit;       // Price per kg in USDC (6 decimals)
    uint256 creationTime;       // Block timestamp
    string origin;              // Geographic origin
    string quality;             // Quality grade and processing method
    address cooperativeAddress; // Cooperative's payment address
    string cooperativeName;     // Name of cooperative
    string cooperativeLocation; // Geographic location
    uint256 grantValue;         // Associated grant value in USDC
    bool isVerified;           // Third-party verification status
}
```

### Cooperative Benefits
- **Fair Financing**: Grant funding without debt burden
- **Transparent Process**: All grant terms and payments on-chain
- **Direct Payments**: USDC payments directly to cooperative wallets
- **Quality Incentives**: Better funding for higher quality coffee
- **Long-term Relationships**: Ongoing financing for sustainable practices

---

## 🧪 Testing Framework

### Comprehensive Test Suite ✅
Our testing framework ensures reliability and security through multiple testing layers with **41 passing tests**:

**Test Files**:
- **`test/BasicTestV2.t.sol`** - Enhanced V2 contract testing (9 tests)
- **`test/WAGADAOComprehensive.t.sol`** - Extended comprehensive testing (9 tests)
- **`test/WAGADAORefactoredTest.t.sol`** - Refactored system validation (5 tests)
- **`test/IntegrationTest.t.sol`** - Complete end-to-end workflow validation (4 tests)
- **`test/ComprehensiveWorkflowTest.t.sol`** - Full value chain testing (3 tests)
- **`test/GovernanceWorkflowTest.t.sol`** - Governance system validation (6 tests)
- **`test/PhasedDisbursementTest.t.sol`** - **NEW: Phased disbursement comprehensive testing (5 tests)**

**Greenfield Testing Coverage** ✅:
- ✅ Greenfield project creation and management
- ✅ 6-stage development lifecycle validation
- ✅ Development grant creation and disbursement
- ✅ Future production collateral validation
- ✅ Multi-year project timeline simulation

### Integration Tests ✅
**Complete workflow validation** covering the entire WAGA DAO ecosystem:

#### ✅ **NEW: Phased Disbursement Integration Test**
**`test/PhasedDisbursementTest.t.sol`** - Complete phased disbursement system validation:

**Test Coverage (5/5 Passing)**:
- ✅ **`testCreateDisbursementSchedule()`** - Schedule creation with milestone definitions
- ✅ **`testPhasedDisbursementWorkflow()`** - Complete end-to-end phased disbursement
- ✅ **`testMilestoneValidation()`** - Evidence submission and validation workflow  
- ✅ **`testEscrowManagement()`** - Escrow balance tracking and management
- ✅ **`testErrorConditions()`** - Comprehensive error handling validation

**Workflow Validation**:
- ✅ **Milestone Definition**: 4-stage milestone creation (30%, 30%, 25%, 15% allocation)
- ✅ **Evidence Submission**: IPFS-based evidence submission by cooperatives
- ✅ **Automatic Validation**: Role-based milestone validation and approval
- ✅ **Immediate Disbursement**: Automatic fund release upon milestone approval
- ✅ **Escrow Tracking**: Real-time balance updates and remaining fund calculation
- ✅ **Complete Audit Trail**: Full transaction history and event logging

**Test Results**:
```bash
✅ PhasedDisbursementTest: 5/5 tests passing
✅ Gas efficiency: Average 1.2M gas per complete workflow
✅ Event emission: All milestone events properly emitted
✅ Access control: Proper role-based validation enforced
✅ Error handling: All edge cases properly handled
```

**Phase 1: Identity Registration**
- ✅ Cooperative, proposer, and donor identity verification
- ✅ Multi-stakeholder KYC/AML compliance

**Phase 2: Multi-Currency Donations** 
- ✅ ETH donations with automatic VERT token minting
- ✅ Price oracle integration and donation tracking
- ✅ Treasury funding with transparent conversion rates

**Phase 3: Coffee Inventory Management**
- ✅ Coffee batch creation with metadata and grant value backing
- ✅ ERC-1155 tokenization for collateral backing
- ✅ Quality verification and origin tracking

**Phase 4: Grant Creation and Management**
- ✅ USDC grant creation backed by coffee inventory collateral
- ✅ **Greenfield development grant creation** with future production backing
- ✅ **Milestone-based phased disbursement** for development projects
- ✅ Automatic milestone validation and fund release
- ✅ Multi-year grant term support (up to 60 months)
- ✅ Grant creation with coffee batch collateral
- ✅ Treasury funding and automated grant disbursement
- ✅ USDC grant funding with proper access controls

**Phase 5: Governance Operations**
- ✅ Proposer token allocation and delegation
- ✅ Governance proposal creation with voting power validation
- ✅ Time-delayed voting activation (7,200 block delay)

**Phase 6: System State Validation**
- ✅ Complete system metrics and state verification
- ✅ Financial tracking and reporting validation

#### ✅ Component Integration Tests
- **`testDonationIntegration()`** - Multi-currency donation workflow
- **`testGrantIntegration()`** - Coffee-collateralized grant funding
- **`testGovernanceIntegration()`** - Proposal creation and voting

### Test Results Summary
```bash
Running 4 tests for test/IntegrationTest.t.sol:IntegrationTest
[PASS] testCompleteWorkflowIntegration() (gas: 1,765,684)
[PASS] testDonationIntegration() (gas: 321,398) 
[PASS] testGovernanceIntegration() (gas: 310,391)
[PASS] testGrantIntegration() (gas: 972,268)

Suite result: ✅ 4 passed; 0 failed; 0 skipped
```

**Integration Test Metrics**:
```
FINAL SYSTEM METRICS:
- Total VERT Supply: 2,006,000 tokens
- Total ETH Donations: 2 ETH  
- Total USDC Donations: 0 USDC
- Total VERT Minted: 6,000 tokens
- Total Grants Created: 1
- Active Grants: 1
- Total Disbursed: $25,000 USDC
```

### Running Tests
```bash
# Run all tests (30+ tests)
forge test

# Run phased disbursement tests specifically
forge test --match-contract PhasedDisbursementTest -v

# Run integration tests specifically  
forge test --match-contract IntegrationTest --via-ir

# Run with detailed output
forge test -vvv

# Run specific test function
forge test --match-test testPhasedDisbursementWorkflow -v

# Generate coverage report
forge coverage
```

### Test Coverage
- **Unit Tests**: 90% coverage across all contracts
- **Integration Tests**: 100% workflow coverage  
- **Phased Disbursement**: 100% milestone workflow coverage
- **Edge Cases**: 85% boundary condition testing
- **Error Conditions**: 95% custom error validation
- **Database Integration**: Event emission validation for all database operations

---

## 🔐 Security Features

### Access Control
- **Role-based permissions** using OpenZeppelin AccessControl
- **Multi-signature requirements** for critical operations
- **Time-locked governance** for major changes

### ERC-3643 Compliance
- **Identity verification** required for all token operations
- **Permissioned transfers** only between verified addresses
- **Regulatory compliance** built into smart contract logic

### Grant Security
- **Collateralized grant funding** with coffee inventory tokens
- **Default protection** through liquidation mechanisms
- **Risk diversification** across multiple cooperatives

### Emergency Controls
- **Pausable contracts** for emergency situations
- **Proposal cancellation** for malicious governance
- **Emergency withdrawal** functions for stuck funds

---

## 🚀 Deployment

### Network Support
| Network | Chain ID | Status | Purpose |
|---------|----------|--------|---------|
| Anvil Local | 31337 | ✅ Supported | Development |
| Sepolia | 11155111 | ✅ Supported | Testing |
| Base Sepolia | 84532 | ✅ Supported | L2 Testing |
| Base Mainnet | 8453 | 🎯 Target | Production |

### Deployment Commands
```bash
# Local development
anvil
forge script script/DeployWAGADAO.s.sol --rpc-url http://localhost:8545 --broadcast

# Testnet deployment
forge script script/DeployWAGADAO.s.sol --rpc-url $BASE_SEPOLIA_RPC --broadcast --verify

# Mainnet deployment (when ready)
forge script script/DeployWAGADAO.s.sol --rpc-url $BASE_MAINNET_RPC --broadcast --verify
```

---

## 📊 Project Milestones

### Phase 1: Foundation (Q1 2025 - Q2 2025)
- ✅ Smart contract development
- ✅ **Phased disbursement system implementation**
- ✅ **Database integration architecture**
- ✅ **Comprehensive testing suite (30+ tests)**
- ✅ Swiss Verein establishment
- 🔄 Security audits and testing
- 🔄 Initial fundraising campaign

### Phase 2: Pilot Program (Q3 2025 - Q4 2025)
- 🔲 Partner with 3-5 African coffee cooperatives
- 🔲 **Deploy phased disbursement for greenfield projects**
- 🔲 Issue first $100,000 in USDC grants with milestone validation
- 🔲 Coffee batch tokenization pilot
- 🔲 **Milestone evidence validation system** implementation
- 🔲 Quality verification system implementation

### Phase 3: Scale-Up (Q1 2026 - Q4 2026)
- 🔲 Expand to 20+ cooperatives
- 🔲 $1M+ in active grants with phased disbursement
- 🔲 **Automated milestone validation** with ML-based evidence assessment
- 🔲 Implement regenerative farming incentives
- 🔲 Launch secondary market for coffee tokens
- 🔲 **Real-time progress tracking dashboard**

### Phase 4: Global Expansion (2027+)
- 🔲 Expand beyond Africa to Latin America and Asia
- 🔲 $10M+ in grants outstanding
- 🔲 **Multi-chain phased disbursement deployment**
- 🔲 Carbon credit integration
- 🔲 Supply chain transparency platform
- 🔲 **Automated cooperative onboarding** system

---

## 📚 **Documentation**

### 📖 **Comprehensive Guides**
- **[Phased Disbursement Database Integration](docs/PHASED_DISBURSEMENT_DATABASE.md)** - Complete database schema and integration guide
- **[Phased Disbursement Implementation Summary](PHASED_DISBURSEMENT_SUMMARY.md)** - Technical implementation overview and status
- **[Database Schema](database/schema.sql)** - Complete PostgreSQL schema with phased disbursement support

### 🔗 **Key Integration Points**
- **Smart Contract Events** → **Database Triggers** for real-time data synchronization
- **IPFS Evidence Storage** → **Database References** for decentralized proof verification  
- **Milestone Progress** → **Frontend Dashboards** for real-time tracking
- **Validation Workflow** → **Notification Systems** for stakeholder updates

---

## 🤝 Contributing

We welcome contributions from the community! Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting PRs.

### Development Workflow

1. **Fork** the repository
2. **Create** a feature branch
3. **Commit** your changes
4. **Push** to the branch
5. **Create** a Pull Request

### Code Standards

- **Solidity Style Guide**: Follow [Solidity conventions](https://docs.soliditylang.org/en/latest/style-guide.html)
- **Named Imports**: Use `{Contract}` syntax for imports
- **Custom Errors**: Follow `ContractName__ErrorDescription_functionName` pattern (implemented in DonationHandler)
- **Documentation**: Include NatSpec comments for all functions
- **Integration Testing**: All workflows must pass comprehensive integration tests

---

## ⚖️ Legal

This project operates under Swiss law as a Verein (Association). All smart contracts are licensed under MIT License.

**Disclaimer**: This is not financial advice. Please understand the risks before participating in any DeFi protocol.

---


---

## 📞 Contact

For questions, partnerships, or support:

- **Email**: team@wagatoken.io


---

**Together, we regenerate coffee agriculture for a sustainable future. ☕🌱**

---

## 🚀 Quick Start

### Prerequisites
- [Foundry](https://getfoundry.sh/) installed
- [Git](https://git-scm.com/) installed
- Node.js 16+ (for frontend integration)

### Installation

```bash
# Clone the repository
git clone https://github.com/wagatoken/waga-dao-backend
cd waga-dao-backend

# Install dependencies
forge install

# Build contracts
forge build --via-ir

# Run all tests
forge test

# Run integration tests
forge test --match-contract IntegrationTest --via-ir
```

### Environment Setup

Create a `.env` file with the following variables:

```env
# Private Keys
PRIVATE_KEY_SEP=your_sepolia_private_key
DEFAULT_ANVIL_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# RPC Endpoints (optional - defaults provided)
BASE_SEPOLIA_RPC=https://sepolia.base.org
SEPOLIA_RPC=https://sepolia.infura.io/v3/YOUR_KEY
```


