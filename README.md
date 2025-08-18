# 🦁 Lion Heart Football Centre DAO

**A Swiss Verein-governed football academy and professional club powered by blockchain technology**

[![Solidity](https://img.shields.io/badge/Solidity-^0.8.24-blue.svg)](https://soliditylang.org/)
[![Foundry](https://img.shields.io/badge/Built%20with-Foundry-orange.svg)](https://getfoundry.sh/)
[![OpenZeppelin](https://img.shields.io/badge/OpenZeppelin-Contracts-green.svg)](https://openzeppelin.com/contracts/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 📖 Overview

Project Lion Heart is a groundbreaking initiative to establish a world-class football academy and professional club in Cameroon. The project combines traditional Swiss Verein governance with modern blockchain technology to create a transparent, globally accessible donation and governance system.

### 🎯 Mission
- Cultivate elite football talent through comprehensive development
- Achieve promotion to Cameroonian Elite One championship
- Create significant social and economic impact in Cameroon
- Provide transparent, decentralized governance for global stakeholders

### 🏗️ Architecture
The project is built on five core smart contracts deployed on the Base network:

1. **LionHeartGovernanceToken (LHGT)** - ERC-20 governance token with ERC-3643 compliance
2. **IdentityRegistry** - KYC/AML verification system for permissioned transfers
3. **DonationHandler** - Multi-currency donation processor and token minter
4. **LionHeartGovernor** - On-chain governance with proposal and voting mechanisms
5. **LionHeartTimelock** - Time-delayed execution for security and governance

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

---

## 🏛️ Smart Contract Architecture

### Core Contracts

#### 🎫 LionHeartGovernanceToken (LHGT)
**Location**: `src/LionHeartGovernanceToken.sol`

**Features**:
- ERC-20 token with voting capabilities (ERC20Votes)
- ERC-3643 compliant permissioned transfers
- Only whitelisted addresses can send/receive tokens
- Controlled minting by authorized minters
- Burning functionality for token holders
- Pausable for emergency situations

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
- Automatic LHGT minting upon donation
- Transparent tracking and reporting
- Emergency withdrawal functionality

#### 🏛️ LionHeartGovernor
**Location**: `src/LionHeartGovernor.sol`

**Features**:
- OpenZeppelin Governor-based on-chain governance
- Token-based voting with delegation support
- Proposal creation, voting, and execution
- Integration with timelock for security
- Customizable voting parameters

#### ⏰ LionHeartTimelock
**Location**: `src/LionHeartTimelock.sol`

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
**Location**: `script/DeployLionHeartDAO.s.sol`

Complete deployment pipeline:
1. Deploy IdentityRegistry
2. Deploy LionHeartGovernanceToken
3. Deploy LionHeartTimelock
4. Deploy LionHeartGovernor
5. Deploy DonationHandler
6. Set up roles and permissions

### Interaction Scripts
**Location**: `script/Interactions.s.sol`

Operational scripts for:
- **RegisterIdentity**: KYC user registration
- **MakeDonationETH**: ETH donation workflow
- **MakeDonationUSDC**: USDC donation workflow
- **CreateProposal**: Governance proposal creation
- **DelegateVotes**: Vote delegation
- **CheckBalances**: System state inspection

### Usage Examples

#### Deploy Complete System
```bash
# Deploy to Anvil (local testing)
forge script script/DeployLionHeartDAO.s.sol --rpc-url http://localhost:8545 --broadcast

# Deploy to Base Sepolia
forge script script/DeployLionHeartDAO.s.sol --rpc-url $BASE_SEPOLIA_RPC --broadcast --verify
```

#### Register a User for KYC
```bash
forge script script/Interactions.s.sol:RegisterIdentity --rpc-url $RPC_URL --broadcast
```

#### Make ETH Donation
```bash
forge script script/Interactions.s.sol:MakeDonationETH --rpc-url $RPC_URL --broadcast
```

#### Check System Balances
```bash
forge script script/Interactions.s.sol:CheckBalances --rpc-url $RPC_URL
```

---

## 🌍 Governance Model

### Swiss Verein Structure
- **Legal Framework**: Swiss Association (Verein) provides legal clarity
- **Global Participation**: Open to international donors and members
- **Transparency**: All decisions recorded on-chain

### Token-Based Voting
- **1 LHGT = 1 Vote**: Democratic governance structure
- **Proposal Threshold**: 1,000,000 LHGT required to create proposals
- **Voting Delay**: 1 day (7,200 blocks)
- **Voting Period**: 7 days (50,400 blocks)
- **Timelock Delay**: 2 days for security

### Governance Process
1. **Proposal Creation**: Token holders with sufficient balance create proposals
2. **Voting Delay**: 1-day period before voting begins
3. **Voting Period**: 7-day voting window
4. **Queuing**: Successful proposals queued in timelock
5. **Execution**: 2-day delay before execution

---

## 🧪 Testing Framework

### Test Structure
- **BasicTest.t.sol**: Core functionality testing
- **LionHeartDAO.t.sol**: Comprehensive unit tests
- **LionHeartDAOIntegration.t.sol**: Integration and workflow tests

### Test Categories

#### Unit Tests
- Individual contract functionality
- Access control verification
- Error condition testing
- Edge case validation

#### Integration Tests
- Multi-contract workflows
- End-to-end donation process
- Governance proposal lifecycle
- Cross-contract interactions

#### Workflow Tests
- Complete donation and governance flow
- Multi-currency donation scenarios
- Emergency scenario testing
- Treasury management workflows

### Running Tests
```bash
# Run all tests
forge test

# Run with detailed output
forge test -vvv

# Run specific test file
forge test --match-path test/LionHeartDAO.t.sol

# Run specific test function
forge test --match-test testCompleteFlow

# Generate coverage report
forge coverage
```

---

## 💰 Donation System

### Supported Currencies

**Rate Structure**: 1 LHGT = $1 USD equivalent

| Currency | LHGT per unit | USD Value Example | Network | Decimals |
|----------|---------------|------------------|---------|----------|
| ETH      | 3,000         | 1 ETH ≈ $3,000   | Base    | 18       |
| USDC     | 1             | 1 USDC = $1      | Base    | 6        |
| PAXG     | 2,000         | 1 PAXG ≈ $2,000  | Base    | 18       |
| Fiat     | 1             | 1 USD = $1       | Off-chain | 18     |

*Note: Actual rates are dynamic and updated by rate managers based on current market prices*

### Donation Process
1. **KYC Verification**: User must be registered in IdentityRegistry
2. **Token Approval**: For ERC-20 donations (USDC, PAXG)
3. **Donation Execution**: Call appropriate donation function
4. **Token Minting**: LHGT automatically minted to donor
5. **Treasury Forwarding**: Funds forwarded to treasury

### Rate Calculation Examples
With 1 LHGT = $1 USD:
- **ETH at $3,000**: 1 ETH = 3,000 LHGT tokens (3000 ÷ 1)
- **USDC at $1**: 1 USDC = 1 LHGT token (1 ÷ 1)
- **PAXG at $2,000**: 1 PAXG = 2,000 LHGT tokens (2000 ÷ 1)
- **Fiat at $1**: $1 USD = 1 LHGT token (1 ÷ 1)

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
forge script script/DeployLionHeartDAO.s.sol --rpc-url http://localhost:8545 --broadcast

# Testnet deployment
forge script script/DeployLionHeartDAO.s.sol --rpc-url $BASE_SEPOLIA_RPC --broadcast --verify

# Mainnet deployment (when ready)
forge script script/DeployLionHeartDAO.s.sol --rpc-url $BASE_MAINNET_RPC --broadcast --verify
```

---

## 📚 Documentation

- [Technical Specification](docs/TECHNICAL_SPEC.md)
- [Governance Guide](docs/GOVERNANCE.md)
- [API Reference](docs/API.md)
- [Deployment Guide](docs/DEPLOYMENT.md)
- [Security Audit](docs/SECURITY_AUDIT.md)

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
- **Custom Errors**: Follow `ContractName__ErrorDescription_functionName` pattern
- **Documentation**: Include NatSpec comments for all functions

---

## 🔗 Links

- **Website**: [https://lionheart-dao.org](https://lionheart-dao.org)
- **Whitepaper**: [Project Lion Heart Whitepaper](docs/WHITEPAPER.md)
- **Governance Portal**: [https://gov.lionheart-dao.org](https://gov.lionheart-dao.org)
- **Discord**: [Join our community](https://discord.gg/lionheart-dao)
- **Twitter**: [@LionHeartDAO](https://twitter.com/LionHeartDAO)

---

## ⚖️ Legal

This project operates under Swiss law as a Verein (Association). All smart contracts are licensed under MIT License.

**Disclaimer**: This is not financial advice. Please understand the risks before participating in any DeFi protocol.

---

## 🙏 Acknowledgments

- **OpenZeppelin** for secure smart contract templates
- **Foundry** for development framework
- **Base Network** for L2 infrastructure
- **Swiss Legal Framework** for governance structure
- **Cameroon Football Community** for inspiration and support

---

## 📞 Contact

For questions, partnerships, or support:

- **Email**: contact@lionheart-dao.org
- **Telegram**: [@LionHeartDAO](https://t.me/LionHeartDAO)
- **GitHub Issues**: [Report bugs or request features](https://github.com/your-org/lion-heart-dao/issues)

---

**Together, we build the pride of Cameroon. 🦁⚽**

---

## 🏛️ Smart Contract Architecture

### Core Contracts

#### 🎫 LionHeartGovernanceToken (LHGT)
**Location**: `src/LionHeartGovernanceToken.sol`

**Features**:
- ERC-20 token with voting capabilities (ERC20Votes)
- ERC-3643 compliant permissioned transfers
- Only whitelisted addresses can send/receive tokens
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

**Key Functions**:
```solidity
function registerIdentity(address identity) external onlyRole(REGISTRAR_ROLE)
function revokeIdentity(address identity) external onlyRole(REGISTRAR_ROLE)
function isVerified(address identity) external view returns (bool)
function batchRegisterIdentities(address[] calldata identities) external
```

#### 💰 DonationHandler
**Location**: `src/DonationHandler.sol`

**Features**:
- Multi-currency donation support (ETH, USDC, PAXG, Fiat)
- Dynamic conversion rates for fair token distribution
- Automatic LHGT minting upon donation
- Transparent tracking and reporting
- Emergency withdrawal functionality

**Key Functions**:
```solidity
function receiveEthDonation() external payable
function receiveUsdcDonation(uint256 amount) external
function receivePaxgDonation(uint256 amount) external
function donateFiat(address donor, uint256 fiatAmountCents, string currency) external
```

### Supported Currencies

| Currency | Network | Contract Address | Decimals |
|----------|---------|------------------|----------|
| ETH      | Base    | Native           | 18       |
| USDC     | Base    | TBD              | 6        |
| PAXG     | Base    | TBD              | 18       |
| Fiat     | Off-chain | N/A            | N/A      |

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

### Emergency Controls
- **Pausable contracts** for emergency situations
- **Upgrade mechanisms** for future improvements
- **Emergency withdrawal** functions for stuck funds

---

## 🌍 Governance Model

### Swiss Verein Structure
- **Legal Framework**: Swiss Association (Verein) provides legal clarity
- **Global Participation**: Open to international donors and members
- **Transparency**: All decisions recorded on-chain

### Token-Based Voting
- **1 LHGT = 1 Vote**: Democratic governance structure
- **Proposal System**: Submit and vote on governance proposals
- **Delegation**: Delegate voting power to trusted representatives

### Membership Tiers

| Tier | Requirements | Benefits |
|------|--------------|----------|
| **General Member** | Hold LHGT tokens | Voting rights, updates |
| **Strategic Partner** | Major donations | First-look rights, scouting access |

---

## 💡 Usage Examples

### For Donors

#### Donate ETH
```solidity
// Ensure you're verified in IdentityRegistry first
DonationHandler.receiveEthDonation{value: 1 ether}();
```

#### Donate USDC
```solidity
// Approve USDC spending
USDC.approve(donationHandlerAddress, 1000 * 1e6); // 1000 USDC
// Make donation
DonationHandler.receiveUsdcDonation(1000 * 1e6);
```

### For Governance

#### Delegate Voting Power
```solidity
LHGT.delegate(delegateAddress);
```

#### Check Voting Power
```solidity
uint256 votes = LHGT.getVotes(voterAddress);
```

---

## 📊 Project Milestones

### Phase 1: Foundation (Q4 2024 - Q2 2025)
- ✅ Smart contract development
- ✅ Swiss Verein establishment
- 🔄 Fundraising campaign launch
- 🔄 Team formation

### Phase 2: Infrastructure (Q3 2025 - Q2 2026)
- 🔲 Land acquisition in Cameroon
- 🔲 Academy construction
- 🔲 Facility equipment

### Phase 3: Operations (Q3 2026 - Q2 2027)
- 🔲 Academy launch
- 🔲 Professional club registration
- 🔲 First player recruitment

### Phase 4: Competition (Q3 2027+)
- 🔲 League participation
- 🔲 Player development
- 🔲 Elite One promotion

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
- **Custom Errors**: Follow `ContractName__ErrorDescription_functionName` pattern
- **Documentation**: Include NatSpec comments for all functions

---

## 🧪 Testing

### Run Tests
```bash
# Run all tests
forge test

# Run with verbosity
forge test -vvv

# Run specific test file
forge test --match-path test/LionHeartGovernanceToken.t.sol

# Run with gas reporting
forge test --gas-report
```

### Coverage
```bash
# Generate coverage report
forge coverage

# Generate detailed coverage
forge coverage --report lcov
```

---

## 🚀 Deployment

### Testnet Deployment
```bash
# Deploy to Base Goerli
forge script script/Deploy.s.sol --rpc-url $BASE_GOERLI_RPC --broadcast --verify
```

### Mainnet Deployment
```bash
# Deploy to Base Mainnet
forge script script/Deploy.s.sol --rpc-url $BASE_MAINNET_RPC --broadcast --verify
```

### Verification
```bash
# Verify contracts on Etherscan
forge verify-contract <contract_address> <contract_name> --chain-id 8453
```

---

## 📚 Documentation

- [Technical Specification](docs/TECHNICAL_SPEC.md)
- [Governance Guide](docs/GOVERNANCE.md)
- [API Reference](docs/API.md)
- [Deployment Guide](docs/DEPLOYMENT.md)
- [Security Audit](docs/SECURITY_AUDIT.md)

---

## 🔗 Links

- **Website**: [https://lionheart-dao.org](https://lionheart-dao.org)
- **Whitepaper**: [Project Lion Heart Whitepaper](docs/WHITEPAPER.md)
- **Governance Portal**: [https://gov.lionheart-dao.org](https://gov.lionheart-dao.org)
- **Discord**: [Join our community](https://discord.gg/lionheart-dao)
- **Twitter**: [@LionHeartDAO](https://twitter.com/LionHeartDAO)

---

## ⚖️ Legal

This project operates under Swiss law as a Verein (Association). All smart contracts are licensed under MIT License.

**Disclaimer**: This is not financial advice. Please understand the risks before participating in any DeFi protocol.

---

## 🙏 Acknowledgments

- **OpenZeppelin** for secure smart contract templates
- **Foundry** for development framework
- **Base Network** for L2 infrastructure
- **Swiss Legal Framework** for governance structure
- **Cameroon Football Community** for inspiration and support

---

## 📞 Contact

For questions, partnerships, or support:

- **Email**: contact@lionheart-dao.org
- **Telegram**: [@LionHeartDAO](https://t.me/LionHeartDAO)
- **GitHub Issues**: [Report bugs or request features](https://github.com/your-org/lion-heart-dao/issues)

---

**Together, we build the pride of Cameroon. 🦁⚽**
