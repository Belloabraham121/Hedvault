# RWA Token Liquidity Addition Script

This script adds liquidity to the SwapEngine for RWA token pairs: Gold/Silver, Silver/Real Estate, and Gold/Real Estate.

## Prerequisites

1. **Anvil running**: Make sure Anvil is running on `http://127.0.0.1:8545`
2. **Contracts deployed**: Ensure all contracts are deployed (SwapEngine, RWA tokens)
3. **Node.js dependencies**: Install required packages

## Setup

1. Install dependencies:

```bash
npm install ethers
```

2. Make sure Anvil is running:

```bash
anvil --host 0.0.0.0 --port 8545
```

3. Ensure you have RWA tokens in your account (the script uses the first Anvil account)

## Configuration

The script is pre-configured with:

- **SwapEngine Address**: `0x2d23e4b771326626996f368422c7eea48b260f1d`
- **RWA Token Addresses**:
  - Gold: `0x0000000000000000000000000000000000636359`
  - Silver: `0x00000000000000000000000000000000006363ad`
  - Real Estate: `0x00000000000000000000000000000000006363ba`
- **Network**: Local Anvil (`http://127.0.0.1:8545`)
- **Account**: First Anvil account

## Liquidity Amounts

The script will add the following liquidity:

1. **Gold/Silver Pool**:

   - 1,000 HVGOLD + 2,000 HVSILV

2. **Silver/Real Estate Pool**:

   - 1,500 HVSILV + 500 HVRE

3. **Gold/Real Estate Pool**:
   - 800 HVGOLD + 400 HVRE

## Running the Script

```bash
node add-liquidity.js
```

## What the Script Does

1. **Connects** to the local Anvil network
2. **Checks** token balances and approvals
3. **Approves** tokens for the SwapEngine if needed
4. **Creates pools** or **adds liquidity** to existing pools
5. **Displays** pool information and transaction hashes

## Expected Output

```
🚀 Starting RWA Token Liquidity Addition Script
================================================
📡 Connected to: http://127.0.0.1:8545
👤 Using account: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
💰 Account balance: 10000.0 ETH

🔍 Checking token support...
   GOLD: ✅ Supported
   SILVER: ✅ Supported
   REAL_ESTATE: ✅ Supported

💧 Adding liquidity to RWA token pairs...
==========================================

📊 Processing Gold/Silver pair (1/3)
   💰 HVGOLD balance: 10000.0
   💰 HVSILV balance: 100000.0
   🔓 Checking approvals...
   📝 Approving HVGOLD...
   ✅ HVGOLD approved
   📝 Approving HVSILV...
   ✅ HVSILV approved
   🏗️  Creating new liquidity pool...
   ✅ Pool created! Transaction: 0x...
   🆔 Pool ID: 1
   📈 Pool reserves: 1000.0 / 2000.0
   🎯 Total liquidity: 1414.213562373095
   ✅ Gold/Silver liquidity addition completed!

...

🎉 All liquidity pairs processed successfully!

📊 Summary:
===========
1. Gold/Silver: 1000.0 HVGOLD + 2000.0 HVSILV
2. Silver/Real Estate: 1500.0 HVSILV + 500.0 HVRE
3. Gold/Real Estate: 800.0 HVGOLD + 400.0 HVRE

✅ Script completed successfully!
```

## Troubleshooting

- **"Insufficient balance"**: Make sure you have enough RWA tokens in your account
- **"Pool not found"**: The SwapEngine address might be incorrect
- **"Connection refused"**: Make sure Anvil is running on the correct port
- **"Token not supported"**: The script will automatically add tokens to the supported list

## Notes

- The script uses a 0.3% fee rate for new pools
- Minimum liquidity is set to 1 token
- The script will automatically handle token approvals
- If pools already exist, it will add liquidity to them instead of creating new ones
