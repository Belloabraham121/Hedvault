#!/usr/bin/env node

/**
 * @title Create RWA Token Script
 * @description Node.js script to create RWA tokens using RWATokenFactory
 * @usage node create-rwa-token.js
 */

const { ethers } = require("ethers");

// Configuration - Update these values
const CONFIG = {
  RPC_URL: "https://testnet.hashio.io/api", // Anvil local network
  PRIVATE_KEY:
    "0xea4627f1e2ca14f0b90163f99d4622de592d2d2487d87b2099602c9256af797e",
  FACTORY_ADDRESS: "0xf043b3b59127829673a46ed1db3e23d310bb508f",
  CREATION_FEE: ethers.parseEther("100"), // 100 tokens
};

// Contract ABI for RWATokenFactory
const FACTORY_ABI = [
  {
    inputs: [
      {
        components: [
          { internalType: "string", name: "assetType", type: "string" },
          { internalType: "string", name: "location", type: "string" },
          { internalType: "uint256", name: "valuation", type: "uint256" },
          {
            internalType: "uint256",
            name: "lastValuationDate",
            type: "uint256",
          },
          { internalType: "string", name: "certificationHash", type: "string" },
          { internalType: "bool", name: "isActive", type: "bool" },
          { internalType: "address", name: "oracle", type: "address" },
          { internalType: "uint256", name: "totalSupply", type: "uint256" },
          { internalType: "uint256", name: "minInvestment", type: "uint256" },
        ],
        internalType: "struct DataTypes.RWAMetadata",
        name: "metadata",
        type: "tuple",
      },
      { internalType: "string", name: "name", type: "string" },
      { internalType: "string", name: "symbol", type: "string" },
      { internalType: "uint256", name: "totalSupply", type: "uint256" },
    ],
    name: "createRWAToken",
    outputs: [
      { internalType: "address", name: "tokenAddress", type: "address" },
    ],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [],
    name: "tokenCreationFee",
    outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "tokenAddress",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "creator",
        type: "address",
      },
      { indexed: false, internalType: "string", name: "name", type: "string" },
      {
        indexed: false,
        internalType: "string",
        name: "symbol",
        type: "string",
      },
    ],
    name: "TokenCreated",
    type: "event",
  },
];

// Sample token configurations
const TOKEN_CONFIGS = [
  {
    name: "Gold Token",
    symbol: "HVGOLD",
    metadata: {
      assetType: "PreciousMetals",
      location: "LBMA Certified Vaults, London",
      valuation: ethers.parseEther("2000"), // $2000
      lastValuationDate: Math.floor(Date.now() / 1000),
      certificationHash: "ipfs://QmGoldCertification123",
      isActive: true,
      oracle: "0x6dCbEA0Fa11B21a6B9F72BccaceFeb0B1ED0B444",
      totalSupply: ethers.parseEther("10000"), // 10,000 tokens
      minInvestment: ethers.parseEther("100"), // $100 minimum
    },
    totalSupply: ethers.parseEther("10000"),
  },
  {
    name: "Silver Token",
    symbol: "HVSILVER",
    metadata: {
      assetType: "PreciousMetals",
      location: "COMEX Certified Vaults, New York",
      valuation: ethers.parseEther("25"), // $25
      lastValuationDate: Math.floor(Date.now() / 1000),
      certificationHash: "ipfs://QmSilverCertification456",
      isActive: true,
      oracle: "0x6dCbEA0Fa11B21a6B9F72BccaceFeb0B1ED0B444",
      totalSupply: ethers.parseEther("100000"), // 100,000 tokens
      minInvestment: ethers.parseEther("50"), // $50 minimum
    },
    totalSupply: ethers.parseEther("100000"),
  },
  {
    name: "Platinum Token",
    symbol: "HVPLAT",
    metadata: {
      assetType: "PreciousMetals",
      location: "Johnson Matthey Refinery, London",
      valuation: ethers.parseEther("1000"), // $1000
      lastValuationDate: Math.floor(Date.now() / 1000),
      certificationHash: "ipfs://QmPlatinumCertification789",
      isActive: true,
      oracle: "0x6dCbEA0Fa11B21a6B9F72BccaceFeb0B1ED0B444",
      totalSupply: ethers.parseEther("5000"), // 5,000 tokens
      minInvestment: ethers.parseEther("200"), // $200 minimum
    },
    totalSupply: ethers.parseEther("5000"),
  },
  {
    name: "Real Estate Token",
    symbol: "HVRE",
    metadata: {
      assetType: "RealEstate",
      location: "Manhattan Commercial District, New York",
      valuation: ethers.parseEther("5000000"), // $5,000,000
      lastValuationDate: Math.floor(Date.now() / 1000),
      certificationHash: "ipfs://QmRealEstateCertABC",
      isActive: true,
      oracle: "0x6dCbEA0Fa11B21a6B9F72BccaceFeb0B1ED0B444",
      totalSupply: ethers.parseEther("1000"), // 1,000 tokens
      minInvestment: ethers.parseEther("10000"), // $10,000 minimum
    },
    totalSupply: ethers.parseEther("1000"),
  },
  {
    name: "Tech Stock Token",
    symbol: "HVTECH",
    metadata: {
      assetType: "Stocks",
      location: "NASDAQ Listed Company",
      valuation: ethers.parseEther("500"), // $500
      lastValuationDate: Math.floor(Date.now() / 1000),
      certificationHash: "ipfs://QmStockCertDEF",
      isActive: true,
      oracle: "0x6dCbEA0Fa11B21a6B9F72BccaceFeb0B1ED0B444",
      totalSupply: ethers.parseEther("10000"), // 10,000 tokens
      minInvestment: ethers.parseEther("1000"), // $1,000 minimum
    },
    totalSupply: ethers.parseEther("10000"),
  },
  {
    name: "Corporate Bond Token",
    symbol: "HVBOND",
    metadata: {
      assetType: "Bonds",
      location: "Fortune 500 Corporate Bonds",
      valuation: ethers.parseEther("10000"), // $10,000
      lastValuationDate: Math.floor(Date.now() / 1000),
      certificationHash: "ipfs://QmBondCertGHI",
      isActive: true,
      oracle: "0x6dCbEA0Fa11B21a6B9F72BccaceFeb0B1ED0B444",
      totalSupply: ethers.parseEther("500"), // 500 tokens
      minInvestment: ethers.parseEther("5000"), // $5,000 minimum
    },
    totalSupply: ethers.parseEther("500"),
  },
];

async function createRWAToken(config) {
  try {
    // Connect to provider
    const provider = new ethers.JsonRpcProvider(CONFIG.RPC_URL);
    const wallet = new ethers.Wallet(CONFIG.PRIVATE_KEY, provider);

    console.log(`Connected to: ${CONFIG.RPC_URL}`);
    console.log(`Using address: ${wallet.address}`);

    // Create factory contract instance
    const factory = new ethers.Contract(
      CONFIG.FACTORY_ADDRESS,
      FACTORY_ABI,
      wallet
    );

    // Check creation fee
    const fee = await factory.tokenCreationFee();
    console.log(`Token creation fee: ${ethers.formatEther(fee)} tokens`);

    // Create RWA token
    console.log(`Creating ${config.name} (${config.symbol})...`);
    console.log(`Metadata:`, config.metadata);

    const tx = await factory.createRWAToken(
      config.metadata,
      config.name,
      config.symbol,
      config.totalSupply,
      { value: CONFIG.CREATION_FEE }
    );

    console.log(`Transaction sent: ${tx.hash}`);

    const receipt = await tx.wait();
    console.log(`Transaction confirmed in block: ${receipt.blockNumber}`);

    // Get token address from logs
    const logs = receipt.logs;
    let tokenAddress = null;

    // Parse logs to find token address (assuming event is emitted)
    for (const log of logs) {
      try {
        const parsed = factory.interface.parseLog(log);
        if (parsed && parsed.name === "TokenCreated") {
          tokenAddress = parsed.args.tokenAddress;
          break;
        }
      } catch (e) {
        // Skip logs that don't match
      }
    }

    console.log(`Token created successfully!`);
    console.log(`Token Address: ${tokenAddress}`);

    return { txHash: tx.hash, tokenAddress };
  } catch (error) {
    console.error(`Error creating token: ${error.message}`);
    throw error;
  }
}

async function main() {
  console.log("🚀 RWA Token Creator");
  console.log("==================\n");

  try {
    // Create tokens one by one
    for (let i = 0; i < TOKEN_CONFIGS.length; i++) {
      const config = TOKEN_CONFIGS[i];
      console.log(`\n${i + 1}. Creating ${config.name}...`);

      const txHash = await createRWAToken(config);
      console.log(`✅ ${config.name} created: ${txHash}\n`);

      // Small delay between transactions
      await new Promise((resolve) => setTimeout(resolve, 1000));
    }

    console.log("🎉 All tokens created successfully!");
  } catch (error) {
    console.error("❌ Failed to create tokens:", error);
    process.exit(1);
  }
}

// Run if called directly
if (require.main === module) {
  main();
}

module.exports = { createRWAToken, TOKEN_CONFIGS };
