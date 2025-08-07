# Fix: Correct Parameter Count for Remix

## Error: `too many arguments: types/values length mismatch`

**Problem:** You're passing too many arguments. The function expects 4 parameters, not 7+.

## Correct Format:

**Function expects:**
```solidity
createRWAToken(metadataTuple, name, symbol, totalSupply)
```

**9-field tuple for RWAMetadata:**
```
(assetType, location, valuation, lastValuationDate, certificationHash, isActive, oracle, totalSupply, minInvestment)
```

## Copy-Paste Ready:

**Metadata Tuple:**
```
("PreciousMetals", "LBMA Certified Vaults, London", 2000000000000000000000, 1754500596, "ipfs://QmGoldCertification123", true, 0x6dCbEA0Fa11B21a6B9F72BccaceFeb0B1ED0B444, 10000000000000000000000, 100000000000000000000)
```

**Complete Function Call:**
```
createRWAToken(
    ("PreciousMetals", "LBMA Certified Vaults, London", 2000000000000000000000, 1754500596, "ipfs://QmGoldCertification123", true, 0x6dCbEA0Fa11B21a6B9F72BccaceFeb0B1ED0B444, 10000000000000000000000, 100000000000000000000),
    "Gold Token",
    "HVGOLD",
    10000000000000000000000
)
```

## Transaction Value: 100000000000000000000 (100 tokens)