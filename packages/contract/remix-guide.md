# Using RWATokenFactory with Remix

## Step 1: Deploy RWATokenFactory
1. Copy the flattened contract from `flattened/RWATokenFactory_flattened.sol`
2. In Remix, create a new file and paste the flattened contract
3. Compile with Solidity 0.8.20
4. Deploy with constructor parameter: HedVaultCore address (use a test address if not available)

## Step 2: Create RWA Token via createRWAToken

### Function Signature:
```solidity
function createRWAToken(
    DataTypes.RWAMetadata calldata metadata,
    string calldata name,
    string calldata symbol,
    uint256 totalSupply
) external payable returns (address tokenAddress)
```

### Parameters Structure:

**metadata (DataTypes.RWAMetadata struct):**
- `assetType`: string (e.g., "PreciousMetals", "RealEstate", "Art")
- `location`: string (e.g., "LBMA Certified Vaults, London")
- `valuation`: uint256 (asset value in wei, 1e18 = $1)
- `lastValuationDate`: uint256 (Unix timestamp)
- `certificationHash`: string (IPFS hash or certification identifier)
- `isActive`: bool (true/false)
- `oracle`: address (price oracle contract address)
- `totalSupply`: uint256 (total token supply in wei)
- `minInvestment`: uint256 (minimum investment in wei)

**Additional parameters:**
- `name`: string (token name, e.g., "Gold Token")
- `symbol`: string (token symbol, e.g., "HVGOLD")
- `totalSupply`: uint256 (must match metadata.totalSupply)

### Example Values for Remix:

```json
{
  "metadata": {
    "assetType": "PreciousMetals",
    "location": "LBMA Certified Vaults, London",
    "valuation": "2000000000000000000000",
    "lastValuationDate": "1754500596",
    "certificationHash": "ipfs://QmGoldCertification123",
    "isActive": true,
    "oracle": "0x0000000000000000000000000000000000000000",
    "totalSupply": "10000000000000000000000",
    "minInvestment": "100000000000000000000"
  },
  "name": "Gold Token",
  "symbol": "HVGOLD",
  "totalSupply": "10000000000000000000000"
}
```

### Transaction Details:
- **Value**: 100000000000000000000 (100 tokens as creation fee)
- **Function**: createRWAToken
- **Expected result**: New RWA token contract address

## Step 3: Verify Token Creation
After successful creation, you can:
1. Call `getTotalTokens()` to see total tokens created
2. Call `getAllRWATokens()` to get array of all token addresses
3. Call `getAssetInfo(tokenAddress)` to get details of specific token