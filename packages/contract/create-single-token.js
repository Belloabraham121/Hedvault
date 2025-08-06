#!/usr/bin/env node

/**
 * @title Create Single RWA Token
 * @description Quick script to create a single RWA token
 * @usage node create-single-token.js [gold|silver|custom]
 */

const { ethers } = require("ethers");

// Configuration
const CONFIG = {
  RPC_URL: "https://testnet.hashio.io/api", // Anvil local network
  PRIVATE_KEY:
    "0xea4627f1e2ca14f0b90163f99d4622de592d2d2487d87b2099602c9256af797e", // Anvil default account
  FACTORY_ADDRESS: "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9", // Update with your deployed address
  CREATION_FEE: ethers.parseEther("100"), // 100 tokens
};

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
    anonymous: false,
    inputs: [
      { indexed: true, internalType: "address", name: "tokenAddress", type: "address" },
      { indexed: true, internalType: "address", name: "creator", type: "address" },
      { indexed: false, internalType: "string", name: "name", type: "string" },
      { indexed: false, internalType: "string", name: "symbol", type: "string" }
    ],
    name: "TokenCreated",
    type: "event"
  }
];

// Predefined token templates
const TOKENS = {
  gold: {
    name: "Gold Token",
    symbol: "HVGOLD",
    metadata: {
      assetType: "PreciousMetals",
      location: "LBMA Certified Vaults, London",
      valuation: ethers.parseEther('2000'),
      lastValuationDate: Math.floor(Date.now() / 1000),
      certificationHash: "ipfs://QmGoldCertification123",
      isActive: true,
      oracle: "0x6dCbEA0Fa11B21a6B9F72BccaceFeb0B1ED0B444",
      totalSupply: ethers.parseEther('10000'),
      minInvestment: ethers.parseEther('100'),
    },
    totalSupply: ethers.parseEther('10000'),
  },
  silver: {
    name: "Silver Token",
    symbol: "HVSILVER",
    metadata: {
      assetType: "PreciousMetals",
      location: "COMEX Certified Vaults, New York",
      valuation: ethers.parseEther('25'),
      lastValuationDate: Math.floor(Date.now() / 1000),
      certificationHash: "ipfs://QmSilverCertification456",
      isActive: true,
      oracle: "0x6dCbEA0Fa11B21a6B9F72BccaceFeb0B1ED0B444",
      totalSupply: ethers.parseEther('100000'),
      minInvestment: ethers.parseEther('50'),
    },
    totalSupply: ethers.parseEther('100000'),
  },
  platinum: {
    name: "Platinum Token",
    symbol: "HVPLAT",
    metadata: {
      assetType: "PreciousMetals",
      location: "Johnson Matthey Refinery, London",
      valuation: ethers.parseEther('1000'),
      lastValuationDate: Math.floor(Date.now() / 1000),
      certificationHash: "ipfs://QmPlatinumCertification789",
      isActive: true,
      oracle: "0x6dCbEA0Fa11B21a6B9F72BccaceFeb0B1ED0B444",
      totalSupply: ethers.parseEther('5000'),
      minInvestment: ethers.parseEther('200'),
    },
    totalSupply: ethers.parseEther('5000'),
  },
  realEstate: {
    name: "Real Estate Token",
    symbol: "HVRE",
    metadata: {
      assetType: "RealEstate",
      location: "Manhattan Commercial District, New York",
      valuation: ethers.parseEther('5000000'),
      lastValuationDate: Math.floor(Date.now() / 1000),
      certificationHash: "ipfs://QmRealEstateCertABC",
      isActive: true,
      oracle: "0x6dCbEA0Fa11B21a6B9F72BccaceFeb0B1ED0B444",
      totalSupply: ethers.parseEther('1000'),
      minInvestment: ethers.parseEther('10000'),
    },
    totalSupply: ethers.parseEther('1000'),
  },
  stock: {
    name: "Tech Stock Token",
    symbol: "HVTECH",
    metadata: {
      assetType: "Stocks",
      location: "NASDAQ Listed Company",
      valuation: ethers.parseEther('500'),
      lastValuationDate: Math.floor(Date.now() / 1000),
      certificationHash: "ipfs://QmStockCertDEF",
      isActive: true,
      oracle: "0x6dCbEA0Fa11B21a6B9F72BccaceFeb0B1ED0B444",
      totalSupply: ethers.parseEther('10000'),
      minInvestment: ethers.parseEther('1000'),
    },
    totalSupply: ethers.parseEther('10000'),
  },
  bond: {
    name: "Corporate Bond Token",
    symbol: "HVBOND",
    metadata: {
      assetType: "Bonds",
      location: "Fortune 500 Corporate Bonds",
      valuation: ethers.parseEther('10000'),
      lastValuationDate: Math.floor(Date.now() / 1000),
      certificationHash: "ipfs://QmBondCertGHI",
      isActive: true,
      oracle: "0x6dCbEA0Fa11B21a6B9F72BccaceFeb0B1ED0B444",
      totalSupply: ethers.parseEther('500'),
      minInvestment: ethers.parseEther('5000'),
    },
    totalSupply: ethers.parseEther('500'),
  },
};

async function createToken(tokenType) {
  try {
    // Setup provider and wallet
    const provider = new ethers.JsonRpcProvider(CONFIG.RPC_URL);
    const wallet = new ethers.Wallet(CONFIG.PRIVATE_KEY, provider);

    const factory = new ethers.Contract(
      CONFIG.FACTORY_ADDRESS,
      FACTORY_ABI,
      wallet
    );

    let tokenConfig;

    if (tokenType === "custom") {
      // Interactive mode for custom token
      console.log("🎯 Creating custom token...");
      tokenConfig = {
        name: "Custom Token",
        symbol: "CUSTOM",
        metadata: {
          assetType: "RealEstate",
          location: "Custom Location",
          valuation: ethers.parseEther("1000"),
          lastValuationDate: Math.floor(Date.now() / 1000),
          certificationHash: "ipfs://QmCustomCert",
          isActive: true,
          oracle: "0x6dCbEA0Fa11B21a6B9F72BccaceFeb0B1ED0B444",
          totalSupply: ethers.parseEther("5000"),
          minInvestment: ethers.parseEther("50"),
        },
        totalSupply: ethers.parseEther("5000"),
      };
    } else {
      tokenConfig = TOKENS[tokenType];
      if (!tokenConfig) {
        console.error(`❌ Unknown token type: ${tokenType}`);
        console.log(`Available types: ${Object.keys(TOKENS).join(", ")}`);
        process.exit(1);
      }
    }

    console.log(`🚀 Creating ${tokenConfig.name}...`);

    const tx = await factory.createRWAToken(
      tokenConfig.metadata,
      tokenConfig.name,
      tokenConfig.symbol,
      tokenConfig.totalSupply,
      { value: CONFIG.CREATION_FEE }
    );

    console.log(`📋 Transaction: ${tx.hash}`);

    const receipt = await tx.wait();
    console.log(`✅ Confirmed in block ${receipt.blockNumber}`);
    
    // Get token address from logs
    let tokenAddress = null;
    for (const log of receipt.logs) {
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
    
    console.log(`🎉 ${tokenConfig.name} created successfully!`);
    console.log(`Token Address: ${tokenAddress}`);
  } catch (error) {
    console.error("❌ Error:", error.message);
    process.exit(1);
  }
}

async function main() {
  const args = process.argv.slice(2);
  const tokenType = args[0] || "gold";

  console.log("🎯 RWA Token Creator - Single Token Mode\n");

  await createToken(tokenType);
}

if (require.main === module) {
  main();
}
