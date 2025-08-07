const { ethers } = require("ethers");

// RWA Token addresses from deployment
const RWA_TOKEN_ADDRESSES = {
  GOLD: "0x0000000000000000000000000000000000636359",
  SILVER: "0x00000000000000000000000000000000006363ad",
};

// SwapEngine contract address from latest deployment
const SWAP_ENGINE_ADDRESS = "0x4536B242ea3D3b5C412F5dB159353B7ca6ed003E";

// Anvil local network configuration
const RPC_URL = "https://testnet.hashio.io/api";
const PRIVATE_KEY =
  "0xea4627f1e2ca14f0b90163f99d4622de592d2d2487d87b2099602c9256af797e";

// SwapEngine ABI (only getPoolByTokens)
const SWAP_ENGINE_ABI = [
  "function getPoolByTokens(address tokenA, address tokenB) external view returns (uint256 poolId)",
];

async function main() {
  console.log("🚀 Querying Pool ID for HVRE/HVSILV");
  console.log("==================================\n");

  // Setup provider and signer
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

  // Contract instance
  const swapEngine = new ethers.Contract(
    SWAP_ENGINE_ADDRESS,
    SWAP_ENGINE_ABI,
    signer
  );

  // Define the token pair (HVRE/HVSILV)
  const tokenA = {
    address: RWA_TOKEN_ADDRESSES.GOLD,
    symbol: "HVGLD",
  };

  const tokenB = {
    address: RWA_TOKEN_ADDRESSES.SILVER,
    symbol: "HVSILV",
  };

  console.log(`🔍 Querying pool ID for ${tokenA.symbol}/${tokenB.symbol}...`);
  console.log(`====================================\n`);

  try {
    // Ensure correct token order (tokenA < tokenB)
    let finalTokenA = tokenA;
    let finalTokenB = tokenB;

    if (tokenA.address > tokenB.address) {
      console.log(`🔄 Swapping token order to ensure tokenA < tokenB`);
      finalTokenA = tokenB;
      finalTokenB = tokenA;
    }

    console.log(`📝 Querying with:`);
    console.log(`   TokenA: ${finalTokenA.address} (${finalTokenA.symbol})`);
    console.log(`   TokenB: ${finalTokenB.address} (${finalTokenB.symbol})`);

    // Call getPoolByTokens
    const poolId = await swapEngine.getPoolByTokens(
      finalTokenA.address,
      finalTokenB.address
    );

    if (poolId === 0n || poolId === 0) {
      console.log(
        `\nℹ️ No pool found for ${finalTokenA.symbol}/${finalTokenB.symbol}`
      );
    } else {
      console.log(`\n✅ Pool found!`);
      console.log(`🆔 Pool ID: ${poolId}`);
      console.log(`📊 Pool: ${finalTokenA.symbol}/${finalTokenB.symbol}`);
    }
  } catch (error) {
    console.error(`❌ Failed to query pool ID: ${error.message}`);
    if (error.data) console.error(`Error data: ${error.data}`);
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
