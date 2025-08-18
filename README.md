# ☕ WAGA DAO - Regenerative Coffee Global Impact

**A Swiss Verein-governed cooperative financing platform for regenerative coffee agriculture powered by blockchain technology**

[![Solidity](https://img.shields.io/badge/Solidity-^0.8.24-blue.svg)](https://soliditylang.org/)
[![Foundry](https://img.shields.io/badge/Built%20with-Foundry-orange.svg)](https://getfoundry.sh/)
[![OpenZeppelin](https://img.shields.io/badge/OpenZeppelin-Contracts-green.svg)](https://openzeppelin.com/contracts/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 📖 Overview

WAGA DAO is a revolutionary platform that combines Swiss Verein governance with blockchain technology to finance regenerative coffee agriculture across African cooperatives. Our mission is to create sustainable value chains that benefit coffee farmers, preserve ecosystems, and generate transparent returns for global investors.

### 🎯 Mission
- Finance regenerative coffee agriculture through blockchain-backed loans
- Support African coffee cooperatives with transparent, fair financing
- Create gold-backed treasury reserves (PAXG/XAUT) for USDC lending
- Provide decentralized governance for global stakeholders
- Promote sustainable farming practices and ecosystem regeneration

### 🏗️ Architecture
The project is built on six core smart contracts deployed on the Base network:

1. **VERTGovernanceToken (VERT)** - ERC-20 governance token with ERC-3643 compliance (Vertical Integration Token)
2. **IdentityRegistry** - KYC/AML verification system for permissioned transfers
3. **DonationHandler** - Multi-currency donation processor and token minter
4. **WAGAGovernor** - On-chain governance with proposal and voting mechanisms
5. **WAGATimelock** - Time-delayed execution for security and governance
6. **WAGACoffeeInventoryToken** - ERC-1155 tokens representing coffee batches as loan collateral
7. **CooperativeLoanManager** - USDC loan management backed by coffee inventory tokens

---

## 🚀 Quick Start

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

#### 💰 DonationHandler
**Location**: `src/DonationHandler.sol`

**Features**:
- Multi-currency donation support (ETH, USDC, PAXG, Fiat)
- Dynamic conversion rates for fair token distribution
- Automatic VERT minting upon donation
- Transparent tracking and reporting
- Treasury management with gold-backed reserves

#### ☕ WAGACoffeeInventoryToken
**Location**: `src/WAGACoffeeInventoryToken.sol`

**Features**:
- ERC-1155 tokens representing coffee batches
- Detailed batch information (origin, quality, cooperative)
- Loan collateral tracking
- Role-based access for batch creation and management
- Integration with cooperative payment systems

**Key Functions**:
```solidity
function createBatch(
    uint256 batchId,
    uint256 quantity,
    uint256 pricePerUnit,
    string memory origin,
    string memory quality,
    address cooperativeAddress,
    string memory cooperativeName,
    string memory cooperativeLocation
) external onlyRole(INVENTORY_MANAGER_ROLE)
```

#### � CooperativeLoanManager
**Location**: `src/CooperativeLoanManager.sol`

**Features**:
- USDC loan creation and management
- Coffee inventory token collateral backing
- Interest calculation and repayment tracking
- Loan default and liquidation mechanisms
- Integration with DAO governance for loan approval

**Key Functions**:
```solidity
function createLoan(
    address cooperative,
    uint256 amount,
    uint256 durationDays,
    uint256 interestRate,
    uint256[] memory batchIds,
    string memory purpose,
    string memory cooperativeName,
    string memory location
) external onlyRole(LOAN_MANAGER_ROLE) returns (uint256 loanId)

function repayLoan(uint256 loanId, uint256 amount) external
function disburseLoan(uint256 loanId) external
```

#### 🏛️ WAGAGovernor
**Location**: `src/WAGAGovernor.sol`

**Features**:
- OpenZeppelin Governor-based on-chain governance
- VERT token-based voting with delegation support
- Proposal creation for loan approvals and DAO management
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
6. Deploy CooperativeLoanManager
7. Deploy DonationHandler
8. Set up roles and permissions

### Interaction Scripts
**Location**: `script/WAGAInteractions.s.sol`

Operational scripts for:
- **RegisterIdentity**: KYC user registration
- **MakeDonationETH**: ETH donation workflow
- **MakeDonationUSDC**: USDC donation workflow
- **CreateCoffeeBatch**: Coffee batch creation for collateral
- **CreateLoan**: Cooperative loan creation
- **CreateProposal**: Governance proposal creation
- **DelegateVotes**: Vote delegation
- **CheckBalances**: System state inspection
- **RepayLoan**: Loan repayment processing

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

#### Create Cooperative Loan
```bash
forge script script/WAGAInteractions.s.sol:CreateLoan --rpc-url $RPC_URL --broadcast
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
- **Transparency**: All loan decisions and treasury management recorded on-chain

### VERT Token-Based Voting
- **1 VERT = 1 Vote**: Democratic governance structure
- **Proposal Threshold**: 1,000,000 VERT required to create proposals
- **Voting Delay**: 1 day (7,200 blocks)
- **Voting Period**: 7 days (50,400 blocks)
- **Timelock Delay**: 2 days for security

### Governance Process
1. **Proposal Creation**: VERT holders create loan approval or treasury management proposals
2. **Voting Delay**: 1-day period before voting begins
3. **Voting Period**: 7-day voting window
4. **Queuing**: Successful proposals queued in timelock
5. **Execution**: 2-day delay before execution

---

## 💰 Financial Model

### Treasury Structure
- **Gold-Backed Reserves**: PAXG/XAUT holdings provide stability
- **USDC Lending Pool**: Primary currency for cooperative loans
- **Coffee Inventory Collateral**: ERC-1155 tokens backing each loan
- **Risk Management**: Diversified collateral across multiple cooperatives

### Loan Parameters
- **Interest Rates**: 5-15% APR based on cooperative risk assessment
- **Loan Duration**: 6 months to 2 years
- **Collateral Ratio**: 1.2-1.5x coffee batch value
- **Minimum Loan**: $1,000 USDC
- **Maximum Loan Duration**: 730 days

### Supported Currencies

**Rate Structure**: 1 VERT = $1 USD equivalent

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
5. **Loan Collateral**: Tokens used as collateral for USDC loans

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
    uint256 loanValue;         // Associated loan value in USDC
    bool isVerified;           // Third-party verification status
}
```

### Cooperative Benefits
- **Fair Financing**: Market-rate loans without predatory terms
- **Transparent Process**: All loan terms and payments on-chain
- **Direct Payments**: USDC payments directly to cooperative wallets
- **Quality Incentives**: Better rates for higher quality coffee
- **Long-term Relationships**: Ongoing financing for sustainable practices

---

## 🧪 Testing Framework

### Test Structure
- **BasicTest.t.sol**: Core functionality testing
- **WAGADAO.t.sol**: Comprehensive unit tests
- **WAGADAOIntegration.t.sol**: Integration and workflow tests

### Test Categories

#### Unit Tests
- Individual contract functionality
- Access control verification
- Error condition testing
- Edge case validation

#### Integration Tests
- Multi-contract workflows
- End-to-end loan and donation process
- Governance proposal lifecycle
- Cross-contract interactions

#### Workflow Tests
- Complete donation and governance flow
- Multi-currency donation scenarios
- Loan creation and repayment cycles
- Coffee batch creation and collateral management

### Running Tests
```bash
# Run all tests
forge test

# Run with detailed output
forge test -vvv

# Run specific test file
forge test --match-path test/WAGADAO.t.sol

# Run specific test function
forge test --match-test testCompleteFlow

# Generate coverage report
forge coverage
```

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

### Loan Security
- **Collateralized lending** with coffee inventory tokens
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
- ✅ Swiss Verein establishment
- 🔄 Security audits and testing
- 🔄 Initial fundraising campaign

### Phase 2: Pilot Program (Q3 2025 - Q4 2025)
- 🔲 Partner with 3-5 African coffee cooperatives
- 🔲 Issue first $100,000 in USDC loans
- 🔲 Coffee batch tokenization pilot
- 🔲 Quality verification system implementation

### Phase 3: Scale-Up (Q1 2026 - Q4 2026)
- 🔲 Expand to 20+ cooperatives
- 🔲 $1M+ in active loans
- 🔲 Implement regenerative farming incentives
- 🔲 Launch secondary market for coffee tokens

### Phase 4: Global Expansion (2027+)
- 🔲 Expand beyond Africa to Latin America and Asia
- 🔲 $10M+ in loans outstanding
- 🔲 Carbon credit integration
- 🔲 Supply chain transparency platform

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
- **Custom Errors**: Follow `ContractName__ErrorDescription` pattern
- **Documentation**: Include NatSpec comments for all functions

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
git clone https://github.com/your-org/lion-heart-dao
cd lion-heart-dao

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


