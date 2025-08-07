# Single-Line Format for Remix

## createRWAToken Function Call

### Exact Parameters for Remix:

**Function:**
```solidity
createRWAToken(
    (PreciousMetals, LBMA Certified Vaults, London, 2000000000000000000000, 1754500596, ipfs://QmGoldCertification123, true, 0x6dCbEA0Fa11B21a6B9F72BccaceFeb0B1ED0B444, 10000000000000000000000, 100000000000000000000),
    "Gold Token",
    "HVGOLD",
    10000000000000000000000
)
```

### Transaction Details:
- **Value:** `100000000000000000000` (100 tokens)
- **Gas Limit:** `300000`

### Alternative Examples:

**Silver Token:**
```solidity
createRWAToken(
    (PreciousMetals, COMEX Certified Vaults, New York, 25000000000000000000, 1754500596, ipfs://QmSilverCertification456, true, 0x6dCbEA0Fa11B21a6B9F72BccaceFeb0B1ED0B444, 100000000000000000000000, 50000000000000000000),
    "Silver Token",
    "HVSILVER",
    100000000000000000000000
)
```

**Stock Token:**
```solidity
createRWAToken(
    (Bonds, NASDAQ, United States, 175000000000000000000, 1754500596, ipfs://QmAppleStockCertification, true, 0x6dCbEA0Fa11B21a6B9F72BccaceFeb0B1ED0B444, 1000000000000000000000000, 175000000000000000000),
    "Apple Stock Token",
    "HVAAPL",
    1000000000000000000000000
)
```