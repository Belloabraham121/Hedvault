# HedVault: The Complete RWA Financial Ecosystem

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Solidity](https://img.shields.io/badge/Solidity-^0.8.20-blue)](https://docs.soliditylang.org/)
[![Foundry](https://img.shields.io/badge/Built%20with-Foundry-orange)](https://getfoundry.sh/)

> The first comprehensive financial infrastructure for tokenized Real World Assets (RWAs), providing institutional-grade trading, lending, portfolio management, and compliance in one unified protocol.

## 🌟 Overview

HedVault is a modular DeFi protocol designed to bring professional financial services to the rapidly growing $25.46B tokenized Real World Asset (RWA) market. Unlike existing solutions that focus solely on tokenization, HedVault provides the complete financial ecosystem that RWA investors need.

### 🏗️ Architecture

HedVault consists of 10 specialized smart contracts working together to provide:

- **Asset Tokenization** - Compliant RWA token creation with metadata validation
- **Professional Trading** - Advanced DEX and marketplace with institutional features
- **Collateralized Lending** - Dynamic lending against RWA portfolios
- **Portfolio Management** - Automated rebalancing and risk analytics
- **Compliance Engine** - Multi-jurisdiction KYC/AML and regulatory reporting
- **Cross-Chain Bridge** - Seamless asset mobility across blockchains

## 🚀 Key Features

### 💼 For Asset Managers
- **Professional Trading Tools**: Advanced order books, market making, and price discovery
- **Portfolio Analytics**: Real-time performance tracking, risk scoring, and attribution analysis
- **Compliance Dashboard**: Automated regulatory reporting and monitoring
- **Cross-Chain Management**: Unified interface for multi-chain asset management

### 🏦 For Individual Investors
- **Easy RWA Access**: Fractional ownership of real estate, commodities, and other assets
- **Automated Strategies**: AI-powered portfolio rebalancing and optimization
- **Lending Services**: Borrow against RWA holdings with competitive rates
- **Mobile-First Design**: Intuitive interface for retail investors

### 🏭 For Asset Issuers
- **Streamlined Tokenization**: One-click asset tokenization with compliance built-in
- **Instant Distribution**: Direct access to qualified investor network
- **Regulatory Automation**: Automated compliance checks and reporting
- **Market Making Support**: Professional liquidity provision services

## 📊 Market Opportunity

- **Current RWA Market**: $25.46B onchain value (August 2025)
- **Growth Rate**: +19.97% user growth, +1.84% monthly value increase
- **Market Participants**: 342,936 holders across 259 issuers
- **Future Projections**: $50B by end of 2025, $10-30T by 2030

## 🛠️ Technology Stack

### Smart Contracts
- **Language**: Solidity ^0.8.20
- **Framework**: OpenZeppelin v5 (AccessControl, ReentrancyGuard, Pausable)
- **Architecture**: Modular design with upgradeable contracts
- **Security**: Multi-signature validation, emergency controls, comprehensive testing

### Development Tools
- **Build System**: Foundry for compilation, testing, and deployment
- **Testing**: Comprehensive test suite with >95% coverage
- **Security**: Static analysis with Slither, formal verification ready
- **Documentation**: NatSpec comments throughout codebase

### Supported Networks
- Ethereum Mainnet (Primary)
- Polygon (Layer 2 scaling)
- Avalanche (Alternative L1)
- Hedera (Enterprise focus)
- *Additional chains via governance*

## 🏗️ Contract Architecture

### Core Contracts

#### 1. **HedVaultCore** - Protocol Coordinator
Central hub managing all protocol modules, fees, and governance.

```solidity
// Key functions
function initialize(address[10] calldata _modules) external onlyOwner;
function updateModule(string calldata moduleType, address newModule) external onlyOwner;
function getProtocolFee(string calldata operation) external view returns (uint256);
```

#### 2. **RWATokenFactory** - Asset Tokenization
Creates compliant ERC20 tokens representing real-world assets.

```solidity
// Create new RWA token
function createRWAToken(
    DataTypes.RWAMetadata calldata metadata,
    string calldata name,
    string calldata symbol,
    uint256 totalSupply
) external payable returns (address tokenAddress);
```

#### 3. **Marketplace** - Professional Trading
Advanced DEX with order books, auctions, and institutional features.

```solidity
// Create trading order
function createOrder(
    address asset,
    address paymentToken,
    uint256 amount,
    uint256 price,
    uint8 orderType,
    uint256 expiry
) external returns (uint256 orderId);
```

#### 4. **LendingPool** - Collateralized Lending
Dynamic lending protocol with RWA-specific risk models.

```solidity
// Create collateralized loan
function createLoan(
    address collateralToken,
    address borrowToken,
    uint256 collateralAmount,
    uint256 borrowAmount
) external returns (uint256 loanId);
```

### Supporting Contracts

- **SwapEngine** - AMM for RWA-to-RWA swaps
- **PortfolioManager** - Automated portfolio optimization
- **ComplianceManager** - KYC/AML and regulatory compliance
- **PriceOracle** - Multi-source price feeds with Chainlink integration
- **CrossChainBridge** - Multi-chain asset mobility
- **RWAToken** - Enhanced ERC20 with compliance features

## 🚦 Getting Started

### Prerequisites

- Node.js 18+ and npm/yarn
- [Foundry](https://getfoundry.sh/) installed
- Git for version control

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/your-org/hedvault.git
cd hedvault
```

2. **Install dependencies**
```bash
# Install Foundry dependencies
forge install

# Install Node.js dependencies (if using additional tooling)
npm install
```

3. **Set up environment**
```bash
cp .env.example .env
# Edit .env with your configuration
```

### Local Development

1. **Compile contracts**
```bash
forge build
```

2. **Run tests**
```bash
# Run all tests
forge test

# Run specific test with verbose output
forge test --match-test "test_CreateRWAToken" -vvvv

# Check test coverage
forge coverage
```

3. **Start local network**
```bash
# Start Anvil (local Ethereum node)
anvil

# In another terminal, deploy contracts
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY --broadcast
```

### Deployment

#### Testnet Deployment

```bash
# Deploy to Sepolia
forge script script/Deploy.s.sol \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify

# Deploy to Polygon Mumbai
forge script script/Deploy.s.sol \
  --rpc-url $MUMBAI_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify
```

#### Mainnet Deployment

```bash
# Deploy to Ethereum Mainnet (use with caution)
forge script script/Deploy.s.sol \
  --rpc-url $MAINNET_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --slow
```

## 💡 Usage Examples

### Creating an RWA Token

```solidity
// 1. Set up metadata
DataTypes.RWAMetadata memory metadata = DataTypes.RWAMetadata({
    assetType: "RealEstate",
    location: "New York, NY",
    valuation: 10000000 * 10**18, // $10M
    lastValuationDate: block.timestamp,
    certificationHash: "ipfs://Qm...",
    isActive: true,
    oracle: oracleAddress,
    totalSupply: 10000 * 10**18, // 10,000 tokens
    minInvestment: 1000 * 10**18 // $1,000 minimum
});

// 2. Create token (requires creation fee)
address tokenAddress = rwaTokenFactory.createRWAToken{value: 100 * 10**18}(
    metadata,
    "Manhattan Office Building",
    "MOB",
    10000 * 10**18
);
```

### Trading RWA Tokens

```solidity
// 1. Create sell order
uint256 orderId = marketplace.createOrder(
    rwaTokenAddress,
    usdcAddress,
    100 * 10**18,        // 100 tokens
    1000 * 10**18,       // $1,000 per token
    1,                   // SELL order
    block.timestamp + 7 days
);

// 2. Execute market order
marketplace.marketOrder(
    rwaTokenAddress,
    usdcAddress,
    50 * 10**18,         // 50 tokens
    0,                   // BUY order
    500                  // 5% max slippage
);
```

### Borrowing Against RWA

```solidity
// 1. Create collateralized loan
uint256 loanId = lendingPool.createLoan(
    rwaTokenAddress,     // Collateral token
    usdcAddress,         // Borrow token
    1000 * 10**18,       // 1,000 RWA tokens as collateral
    500000 * 10**6       // Borrow $500,000 USDC
);

// 2. Repay loan
lendingPool.repayLoan(loanId, 0); // 0 = full repayment
```

### Portfolio Management

```solidity
// 1. Create portfolio
uint256 portfolioId = portfolioManager.createPortfolio(
    "Diversified RWA Portfolio",
    5,      // Medium risk level
    500     // 5% rebalance threshold
);

// 2. Add assets with target allocations
portfolioManager.addAsset(
    portfolioId,
    rwaToken1,
    1000 * 10**18,  // Amount
    4000            // 40% target allocation
);

// 3. Rebalance portfolio
portfolioManager.rebalancePortfolio(portfolioId);
```

## 🧪 Testing

The project includes comprehensive tests covering all major functionality:

```bash
# Run all tests
forge test

# Run tests with gas reporting
forge test --gas-report

# Run specific test file
forge test --match-path test/Marketplace.t.sol

# Run with coverage
forge coverage --report lcov
```

### Test Categories

- **Unit Tests**: Individual contract functionality
- **Integration Tests**: Cross-contract interactions
- **Scenario Tests**: End-to-end user workflows
- **Fuzz Tests**: Property-based testing with random inputs
- **Invariant Tests**: System-wide invariant checking

## 🛡️ Security

### Security Measures

- **Multi-signature controls** for all admin functions
- **Emergency pause mechanisms** across all contracts
- **Reentrancy protection** on all external calls
- **Access control** with role-based permissions
- **Rate limiting** to prevent abuse
- **Circuit breakers** for anomalous conditions

### Audit Status

- [ ] **Formal Audit**: Pending (Q4 2025)
- [x] **Static Analysis**: Passed (Slither)
- [x] **Test Coverage**: >95%
- [ ] **Formal Verification**: In Progress

### Bug Bounty

We run a responsible disclosure program. Please report security vulnerabilities to security@hedvault.io.

## 📚 Documentation

### Developer Resources

- [Smart Contract Documentation](./docs/contracts/)
- [Integration Guide](./docs/integration.md)
- [API Reference](./docs/api.md)
- [Architecture Overview](./docs/architecture.md)

### User Guides

- [Asset Tokenization Guide](./docs/tokenization.md)
- [Trading Guide](./docs/trading.md)
- [Lending Guide](./docs/lending.md)
- [Portfolio Management Guide](./docs/portfolio.md)

## 🤝 Contributing

We welcome contributions from the community! Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting pull requests.

### Development Process

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Write** tests for your changes
4. **Run** the test suite (`forge test`)
5. **Commit** your changes (`git commit -m 'Add amazing feature'`)
6. **Push** to the branch (`git push origin feature/amazing-feature`)
7. **Open** a Pull Request

### Code Standards

- Follow [Solidity Style Guide](https://docs.soliditylang.org/en/latest/style-guide.html)
- Write comprehensive tests for new features
- Document all public functions with NatSpec
- Ensure gas optimization where possible

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- **Website**: https://hedvault.io
- **Documentation**: https://docs.hedvault.io
- **Discord**: https://discord.gg/hedvault
- **Twitter**: https://twitter.com/hedvault
- **Telegram**: https://t.me/hedvault

## 📞 Contact

- **General**: hello@hedvault.io
- **Technical**: dev@hedvault.io
- **Security**: security@hedvault.io
- **Partnerships**: partnerships@hedvault.io

---

**Built with ❤️ for the future of decentralized finance**

*Making every valuable real-world asset as liquid and accessible as Bitcoin.*
