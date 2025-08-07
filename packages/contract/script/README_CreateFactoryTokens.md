# Create Factory Tokens Script

This script creates factory tokens for real-world assets including precious metals (gold, silver, platinum, palladium), major stocks (Apple, Microsoft, Tesla, Amazon, Google), commodities (oil, natural gas, wheat), and bonds (US Treasury, Corporate).

## Overview

The `CreateFactoryTokens.s.sol` script uses the existing `RWATokenFactory` contract to create multiple tokenized real-world assets. Each token represents fractional ownership of the underlying asset and can be traded on the HedVault platform.

## Assets Created

### Precious Metals (4 tokens)
- **HVGOLD** - HedVault Gold Token (10,000 tokens representing ounces)
- **HVSILVER** - HedVault Silver Token (100,000 tokens)
- **HVPLATINUM** - HedVault Platinum Token (5,000 tokens)
- **HVPALLADIUM** - HedVault Palladium Token (3,000 tokens)

### Stock Tokens (5 tokens)
- **HVAAPL** - HedVault Apple Stock Token (1M tokens)
- **HVMSFT** - HedVault Microsoft Stock Token (800K tokens)
- **HVTSLA** - HedVault Tesla Stock Token (500K tokens)
- **HVAMZN** - HedVault Amazon Stock Token (600K tokens)
- **HVGOOGL** - HedVault Google Stock Token (700K tokens)

### Commodities (3 tokens)
- **HVOIL** - HedVault Crude Oil Token (100K barrels)
- **HVGAS** - HedVault Natural Gas Token (1M MMBtu)
- **HVWHEAT** - HedVault Wheat Token (500K bushels)

### Bonds (2 tokens)
- **HVUST10Y** - HedVault US Treasury Bond Token (100K bonds)
- **HVCORP** - HedVault Corporate Bond Token (50K bonds)

## Prerequisites

1. **Deployed Contracts**: Ensure the following contracts are deployed:
   - `HedVaultCore`
   - `RWATokenFactory`

2. **Creator Approval**: The creator address must be approved by the RWATokenFactory admin:
   ```bash
   cast send $RWA_TOKEN_FACTORY_ADDRESS "approveCreator(address)" $CREATOR_ADDRESS --private-key $PRIVATE_KEY
   ```

3. **Sufficient Balance**: The creator needs enough HBAR/ETH to pay for:
   - Token creation fees: 100 HBAR per token
   - Listing fees: 50 HBAR per token
   - Total for 14 tokens: 2,100 HBAR (14 × 150 HBAR)

## Environment Variables

Create a `.env` file in the script directory with the following variables:

```bash
# Required addresses
RWA_TOKEN_FACTORY_ADDRESS=0x...
CREATOR_ADDRESS=0x...

# Network configuration
RPC_URL=https://testnet.hashio.io/api
PRIVATE_KEY=0x...

# Optional: Gas configuration
GAS_LIMIT=3000000
GAS_PRICE=20000000000
```

## Usage

### 1. Check Creator Approval Status

First, verify that the creator is approved:

```bash
forge script script/CreateFactoryTokens.s.sol:CreateFactoryTokens \
  --sig "checkCreatorApproval()" \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY
```

### 2. Check Required Balance

Calculate the total fees needed:

```bash
forge script script/CreateFactoryTokens.s.sol:CreateFactoryTokens \
  --sig "getRequiredBalance()" \
  --rpc-url $RPC_URL
```

### 3. Deploy All Factory Tokens

Run the main script to create all tokens:

```bash
forge script script/CreateFactoryTokens.s.sol:CreateFactoryTokens \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify
```

### 4. Deploy on Hedera Testnet

```bash
forge script script/CreateFactoryTokens.s.sol:CreateFactoryTokens \
  --rpc-url https://testnet.hashio.io/api \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --legacy
```

## Script Functions

### Main Functions
- `run()` - Main execution function that creates all tokens
- `checkCreatorApproval()` - Verify creator approval status
- `getRequiredBalance()` - Calculate total fees needed

### Internal Functions
- `_createPreciousMetalsTokens()` - Creates gold, silver, platinum, palladium tokens
- `_createStockTokens()` - Creates major stock tokens
- `_createCommodityTokens()` - Creates oil, gas, wheat tokens
- `_createBondTokens()` - Creates treasury and corporate bond tokens
- `_createAndListToken()` - Helper to create and list individual tokens

## Token Metadata Structure

Each token includes comprehensive metadata:

```solidity
struct RWAMetadata {
    string assetType;           // "PreciousMetals", "Bonds", "Commodities"
    string location;            // Physical/market location
    uint256 valuation;          // Current valuation in USD
    uint256 lastValuationDate; // Timestamp of valuation
    string certificationHash;  // IPFS hash of documents
    bool isActive;              // Asset status
    address oracle;             // Price oracle (set later)
    uint256 totalSupply;        // Total token supply
    uint256 minInvestment;      // Minimum investment amount
}
```

## Post-Deployment Steps

1. **Register with Oracle**: Register each token with the RWAOffchainOracle for price feeds
2. **Set Price Feeds**: Configure Chainlink or custom price feeds for each asset
3. **Update Metadata**: Add real certification documents to IPFS
4. **Configure Trading**: Set up trading pairs in the marketplace
5. **Add Liquidity**: Provide initial liquidity for trading

## Verification

After deployment, verify the tokens were created successfully:

```bash
# Check total tokens created
cast call $RWA_TOKEN_FACTORY_ADDRESS "getTotalTokens()" --rpc-url $RPC_URL

# Check creator's tokens
cast call $RWA_TOKEN_FACTORY_ADDRESS "getCreatorTokens(address)" $CREATOR_ADDRESS --rpc-url $RPC_URL

# Check specific token info
cast call $RWA_TOKEN_FACTORY_ADDRESS "getAssetInfo(address)" $TOKEN_ADDRESS --rpc-url $RPC_URL
```

## Troubleshooting

### Common Issues

1. **Creator Not Approved**
   ```
   Error: UnauthorizedAccess(address,string)
   ```
   Solution: Approve the creator using the admin account

2. **Insufficient Fees**
   ```
   Error: InsufficientFeePayment(uint256,uint256)
   ```
   Solution: Ensure creator has enough balance for all fees

3. **Unsupported Asset Type**
   ```
   Error: InvalidTokenMetadata(string)
   ```
   Solution: Verify asset types match factory's supported types

4. **Invalid Supply**
   ```
   Error: InvalidAmount(uint256,uint256,uint256)
   ```
   Solution: Ensure total supply is within min/max bounds

### Gas Optimization

For large deployments, consider:
- Splitting into multiple transactions
- Using higher gas limits
- Deploying in batches during low network usage

## Security Considerations

- Store private keys securely
- Use hardware wallets for mainnet deployments
- Verify all contract addresses before deployment
- Test on testnet first
- Review all metadata before creation

## Support

For issues or questions:
1. Check the HedVault documentation
2. Review contract source code
3. Test on Hedera testnet first
4. Contact the development team