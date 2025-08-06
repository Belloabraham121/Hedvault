#!/usr/bin/env node

/**
 * @title Create Single RWA Token
 * @description Quick script to create a single RWA token
 * @usage node create-single-token.js [gold|silver|custom]
 */

const { ethers } = require("ethers");

// Configuration
const CONFIG = {
  RPC_URL: "https://testnet.hashio.io/api", // Hedera testnet
  PRIVATE_KEY:
    "0xea4627f1e2ca14f0b90163f99d4622de592d2d2487d87b2099602c9256af797e", // Default Anvil private key
  FACTORY_ADDRESS: "0x49c8F98ED7a2A44db95F2088225e2C0f77f61F71", // Latest deployed address
};

const FACTORY_ABI = [
  {
    type: "function",
    name: "createRWAToken",
    inputs: [
      {
        name: "metadata",
        type: "tuple",
        internalType: "struct DataTypes.RWAMetadata",
        components: [
          { name: "assetType", type: "string", internalType: "string" },
          { name: "location", type: "string", internalType: "string" },
          { name: "valuation", type: "uint256", internalType: "uint256" },
          {
            name: "lastValuationDate",
            type: "uint256",
            internalType: "uint256",
          },
          { name: "certificationHash", type: "string", internalType: "string" },
          { name: "isActive", type: "bool", internalType: "bool" },
          { name: "oracle", type: "address", internalType: "address" },
          { name: "totalSupply", type: "uint256", internalType: "uint256" },
          { name: "minInvestment", type: "uint256", internalType: "uint256" },
        ],
      },
      { name: "name", type: "string", internalType: "string" },
      { name: "symbol", type: "string", internalType: "string" },
      { name: "totalSupply", type: "uint256", internalType: "uint256" },
    ],
    outputs: [
      { name: "tokenAddress", type: "address", internalType: "address" },
    ],
    stateMutability: "payable",
  },
  {
    type: "event",
    name: "TokenCreated",
    inputs: [
      { name: "tokenId", type: "uint256", indexed: true },
      { name: "tokenAddress", type: "address", indexed: true },
      { name: "creator", type: "address", indexed: true },
      { name: "assetType", type: "string", indexed: false },
      { name: "totalSupply", type: "uint256", indexed: false },
    ],
  },
];

// Predefined token templates
const TOKENS = {
  gold: {
    name: "Gold Token",
    symbol: "HVGOLD",
    metadata: {
      assetType: "PreciousMetals",
      location: "LBMA Certified Vaults, London",
      valuation: ethers.parseEther("2000"),
      lastValuationDate: Math.floor(Date.now() / 1000),
      certificationHash: "ipfs://QmGoldCertification123",
      isActive: true,
      oracle: "0x6dCbEA0Fa11B21a6B9F72BccaceFeb0B1ED0B444",
      totalSupply: ethers.parseEther("10000"),
      minInvestment: ethers.parseEther("100"),
    },
    totalSupply: ethers.parseEther("10000"),
  },
  silver: {
    name: "Silver Token",
    symbol: "HVSILVER",
    metadata: {
      assetType: "PreciousMetals",
      location: "COMEX Certified Vaults, New York",
      valuation: ethers.parseEther("25"),
      lastValuationDate: Math.floor(Date.now() / 1000),
      certificationHash: "ipfs://QmSilverCertification456",
      isActive: true,
      oracle: "0x6dCbEA0Fa11B21a6B9F72BccaceFeb0B1ED0B444",
      totalSupply: ethers.parseEther("100000"),
      minInvestment: ethers.parseEther("50"),
    },
    totalSupply: ethers.parseEther("100000"),
  },
};

// Custom JSON serializer to handle BigInt
const bigIntSerializer = (key, value) =>
  typeof value === "bigint" ? value.toString() : value;

async function createToken(tokenType) {
  try {
    // Setup provider and wallet
    const provider = new ethers.JsonRpcProvider(CONFIG.RPC_URL);
    const wallet = new ethers.Wallet(CONFIG.PRIVATE_KEY, provider);

    // Check wallet balance
    const balance = await provider.getBalance(wallet.address);
    console.log(`💰 Wallet address: ${wallet.address}`);
    console.log(`💰 Wallet balance: ${ethers.formatEther(balance)} HBAR`);

    // Basic balance check for gas
    const MIN_BALANCE = ethers.parseEther("0.1"); // Adjust based on Hedera gas costs
    if (balance < MIN_BALANCE) {
      throw new Error(
        `Insufficient funds for gas: Need at least ${ethers.formatEther(
          MIN_BALANCE
        )} HBAR, but have ${ethers.formatEther(balance)} HBAR`
      );
    }

    // Check if contract exists
    const code = await provider.getCode(CONFIG.FACTORY_ADDRESS);
    if (code === "0x") {
      throw new Error(`No contract deployed at ${CONFIG.FACTORY_ADDRESS}`);
    }
    console.log(`📜 Contract exists at ${CONFIG.FACTORY_ADDRESS}`);

    // Initialize contract
    const factory = new ethers.Contract(
      CONFIG.FACTORY_ADDRESS,
      FACTORY_ABI,
      wallet
    );

    let tokenConfig;
    if (tokenType === "custom") {
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
    console.log(
      "Token Config:",
      JSON.stringify(tokenConfig, bigIntSerializer, 2)
    );

    // Encode and log transaction data
    const data = factory.interface.encodeFunctionData("createRWAToken", [
      tokenConfig.metadata,
      tokenConfig.name,
      tokenConfig.symbol,
      tokenConfig.totalSupply,
    ]);
    console.log("📦 Encoded Transaction Data:", data);

    // Send transaction with fixed gas limit
    const tx = await factory.createRWAToken(
      tokenConfig.metadata,
      tokenConfig.name,
      tokenConfig.symbol,
      tokenConfig.totalSupply,
      {
        gasLimit: 3000000, // Increased to handle high gas usage
      }
    );

    console.log(`📋 Transaction: ${tx.hash}`);
    console.log(`📜 Transaction Details:`, JSON.stringify(tx, null, 2));

    // Wait for confirmation
    const receipt = await tx.wait();
    console.log(`✅ Confirmed in block ${receipt.blockNumber}`);
    console.log(`🎉 ${tokenConfig.name} created successfully!`);
    console.log(`📜 Receipt:`, JSON.stringify(receipt, null, 2));

    // Log created token address
    const tokenAddress = receipt.logs
      .map((log) => {
        try {
          return factory.interface.parseLog(log);
        } catch {
          return null;
        }
      })
      .filter((event) => event && event.name === "TokenCreated")
      .map((event) => event.args.tokenAddress)[0];
    if (tokenAddress) {
      console.log(`🏦 Token Address: ${tokenAddress}`);
    } else {
      console.warn("⚠️ No TokenCreated event found in transaction logs");
    }
  } catch (error) {
    console.error("❌ Error:", error.message);
    if (error.data) {
      try {
        const errorInterface = new ethers.Interface([
          "error ZeroAddress()",
          "error InvalidAmount(uint256 provided, uint256 min, uint256 max)",
          "error InvalidTokenMetadata(string field)",
          "error InvalidConfiguration(string field)",
          "error FeeCollectionFailed(string reason)",
        ]);
        const decodedError = errorInterface.parseError(error.data);
        console.error("🔍 Parsed Revert Reason:", decodedError);
      } catch (parseError) {
        console.error("🔍 Could not parse revert reason:", parseError.message);
        console.error("🔍 Raw Error Data:", error.data);
      }
    }
    console.error("🔍 Full Error Object:", JSON.stringify(error, null, 2));
    process.exit(1);
  }
}

async function main() {
  console.log("🎯 RWA Token Creator - Single Token Mode");
  console.log(`🕒 Current time: ${new Date().toLocaleString()}\n`);

  const args = process.argv.slice(2);
  const tokenType = args[0] || "gold";

  await createToken(tokenType);
}

if (require.main === module) {
  main();
}
