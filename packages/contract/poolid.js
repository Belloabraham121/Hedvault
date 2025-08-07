const { ethers } = require("ethers");

// RWA Token addresses from deployment
const RWA_TOKEN_ADDRESSES = {
  GOLD: "0x0000000000000000000000000000000000636359",
  SILVER: "0x00000000000000000000000000000000006363ad",
};

// Anvil local network configuration
const RPC_URL = "https://testnet.hashio.io/api";
const PRIVATE_KEY =
  "0xea4627f1e2ca14f0b90163f99d4622de592d2d2487d87b2099602c9256af797e";

async function main() {
  console.log("🚀 Calculating Pool ID for HVGOLD/HVSILV");
  console.log("=====================================\n");

  // Setup provider
  let provider;
  try {
    provider = new ethers.JsonRpcProvider(RPC_URL);
  } catch (error) {
    console.error(`❌ Failed to connect to RPC: ${error.message}`);
    process.exit(1);
  }

  const signer = new ethers.Wallet(PRIVATE_KEY, provider);

  console.log(`📡 Connected to: ${RPC_URL}`);
  console.log(`👤 Using account: ${signer.address}`);

  // Get account balance
  let balance;
  try {
    balance = await provider.getBalance(signer.address);
    console.log(`💰 Account balance: ${ethers.formatEther(balance)} ETH\n`);
  } catch (error) {
    console.error(`❌ Failed to fetch account balance: ${error.message}`);
    process.exit(1);
  }

  // Define the token pair (HVGOLD/HVSILV)
  const tokenA = {
    address: RWA_TOKEN_ADDRESSES.GOLD,
    symbol: "HVGOLD",
  };

  const tokenB = {
    address: RWA_TOKEN_ADDRESSES.SILVER,
    symbol: "HVSILV",
  };

  console.log(
    `🔍 Calculating pool ID for ${tokenA.symbol}/${tokenB.symbol}...`
  );
  console.log(`====================================\n`);

  try {
    // Validate token addresses
    if (
      !ethers.isAddress(tokenA.address) ||
      !ethers.isAddress(tokenB.address)
    ) {
      console.error(
        `❌ Invalid token address: ${tokenA.address} or ${tokenB.address}`
      );
      process.exit(1);
    }

    // Compute poolId = keccak256(abi.encodePacked(tokenA, tokenB))
    console.log(`📝 Computing with input order (matches createPool):`);
    console.log(`   TokenA: ${tokenA.address} (${tokenA.symbol})`);
    console.log(`   TokenB: ${tokenB.address} (${tokenB.symbol})`);

    const encodedData = ethers.solidityPacked(
      ["address", "address"],
      [tokenA.address, tokenB.address]
    );
    const poolId = ethers.keccak256(encodedData);

    console.log(`\n✅ Pool ID calculated (input order)!`);
    console.log(`🆔 Pool ID: ${poolId}`);
    console.log(`📊 Pool: ${tokenA.symbol}/${tokenB.symbol}`);

    // Compute poolId for reversed order (matches getPoolByTokens)
    console.log(
      `\n🔄 Computing with reversed order (matches getPoolByTokens):`
    );
    console.log(`   TokenA: ${tokenB.address} (${tokenB.symbol})`);
    console.log(`   TokenB: ${tokenA.address} (${tokenA.symbol})`);

    const encodedDataReverse = ethers.solidityPacked(
      ["address", "address"],
      [tokenB.address, tokenA.address]
    );
    const poolIdReverse = ethers.keccak256(encodedDataReverse);

    console.log(`\n✅ Pool ID calculated (reversed order)!`);
    console.log(`🆔 Pool ID: ${poolIdReverse}`);
    console.log(`📊 Pool: ${tokenB.symbol}/${tokenA.symbol}`);
  } catch (error) {
    console.error(`❌ Failed to calculate pool ID: ${error.message}`);
    process.exit(1);
  }
}

// Handle script execution
if (require.main === module) {
  main()
    .then(() => {
      console.log(`\n✅ Script completed successfully!`);
      process.exit(0);
    })
    .catch((error) => {
      console.error(`\n❌ Script failed:`, error);
      process.exit(1);
    });
}

module.exports = { main };
