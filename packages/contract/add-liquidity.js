const { ethers } = require("ethers");

// RWA Token addresses from deployment
const RWA_TOKEN_ADDRESSES = {
  GOLD: "0x0000000000000000000000000000000000636359",
  SILVER: "0x00000000000000000000000000000000006363ad",
  REAL_ESTATE: "0x00000000000000000000000000000000006363ba",
};

// SwapEngine contract address from latest deployment
const SWAP_ENGINE_ADDRESS = "0x12354dC2fE41577989c4c82F68ac4d4F34d3572E";

// Anvil local network configuration
const RPC_URL = "https://testnet.hashio.io/api";
const PRIVATE_KEY =
  "0xea4627f1e2ca14f0b90163f99d4622de592d2d2487d87b2099602c9256af797e";

// Basic ERC20 ABI for token operations
const ERC20_ABI = [
  "function approve(address spender, uint256 amount) external returns (bool)",
  "function balanceOf(address account) external view returns (uint256)",
  "function allowance(address owner, address spender) external view returns (uint256)",
  "function symbol() external view returns (string)",
  "function decimals() external view returns (uint8)",
];

// SwapEngine ABI (key functions only)
const SWAP_ENGINE_ABI = [
  "function createPool(address tokenA, address tokenB, uint256 amountA, uint256 amountB, uint256 feeRate) external returns (uint256 poolId)",
  "function addSupportedToken(address token) external",
];

// Utility function for delay
const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

async function main() {
  console.log("🚀 Creating RWA Token Pool");
  console.log("===========================\n");

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

  // Contract instances
  const goldtoken = new ethers.Contract(
    RWA_TOKEN_ADDRESSES.GOLD,
    ERC20_ABI,
    signer
  );
  const silverToken = new ethers.Contract(
    RWA_TOKEN_ADDRESSES.SILVER,
    ERC20_ABI,
    signer
  );
  const swapEngine = new ethers.Contract(
    SWAP_ENGINE_ADDRESS,
    SWAP_ENGINE_ABI,
    signer
  );

  // Define the token pair (RealEstate/Silver)
  const tokenA = {
    contract: goldtoken,
    address: RWA_TOKEN_ADDRESSES.GOLD,
    symbol: "HVGLD",
    amountRaw: "1000", // Amount in human-readable form
  };

  const tokenB = {
    contract: silverToken,
    address: RWA_TOKEN_ADDRESSES.SILVER,
    symbol: "HVSILV",
    amountRaw: "2000", // Amount in human-readable form
  };

  console.log(`\n💧 Creating RealEstate/Silver liquidity pool...`);
  console.log(`==========================================\n`);

  try {
    // Check token decimals and adjust amounts
    const decimalsA = await tokenA.contract.decimals();
    const decimalsB = await tokenB.contract.decimals();
    console.log(`🔢 ${tokenA.symbol} decimals: ${decimalsA}`);
    console.log(`🔢 ${tokenB.symbol} decimals: ${decimalsB}`);

    const amountA = ethers.parseUnits(tokenA.amountRaw, decimalsA);
    const amountB = ethers.parseUnits(tokenB.amountRaw, decimalsB);

    // Check token balances
    const balanceA = await tokenA.contract.balanceOf(signer.address);
    const balanceB = await tokenB.contract.balanceOf(signer.address);

    console.log(
      `💰 ${tokenA.symbol} balance: ${ethers.formatUnits(balanceA, decimalsA)}`
    );
    console.log(
      `💰 ${tokenB.symbol} balance: ${ethers.formatUnits(balanceB, decimalsB)}`
    );

    if (balanceA < amountA) {
      console.error(`❌ Insufficient ${tokenA.symbol} balance`);
      process.exit(1);
    }
    if (balanceB < amountB) {
      console.error(`❌ Insufficient ${tokenB.symbol} balance`);
      process.exit(1);
    }

    // Ensure correct token order (tokenA < tokenB)
    let finalTokenA = tokenA;
    let finalTokenB = tokenB;
    let finalAmountA = amountA;
    let finalAmountB = amountB;

    if (tokenA.address > tokenB.address) {
      console.log(`\n🔄 Swapping token order to ensure tokenA < tokenB`);
      finalTokenA = tokenB;
      finalTokenB = tokenA;
      finalAmountA = amountB;
      finalAmountB = amountA;
    }

    // Ensure tokens are supported (REQUIRED before createPool)
    console.log(`\n🔍 Adding token support if needed...`);

    console.log(`📝 Adding ${finalTokenA.symbol} to supported tokens...`);
    try {
      const txA = await swapEngine.addSupportedToken(finalTokenA.address, {
        gasLimit: 200000,
      });
      await txA.wait();
      console.log(`✅ ${finalTokenA.symbol} added to supported tokens`);
    } catch (error) {
      if (error.message.includes("TokenNotListed")) {
        console.error(
          `❌ ${finalTokenA.symbol} not supported, and addSupportedToken failed: ${error.message}`
        );
        process.exit(1);
      } else {
        console.log(
          `✅ ${finalTokenA.symbol} likely already supported or addSupportedToken not needed`
        );
      }
    }

    console.log(`📝 Adding ${finalTokenB.symbol} to supported tokens...`);
    try {
      const txB = await swapEngine.addSupportedToken(finalTokenB.address, {
        gasLimit: 200000,
      });
      await txB.wait();
      console.log(`✅ ${finalTokenB.symbol} added to supported tokens`);
    } catch (error) {
      if (error.message.includes("TokenNotListed")) {
        console.error(
          `❌ ${finalTokenB.symbol} not supported, and addSupportedToken failed: ${error.message}`
        );
        process.exit(1);
      } else {
        console.log(
          `✅ ${finalTokenB.symbol} likely already supported or addSupportedToken not needed`
        );
      }
    }

    // Check and approve tokens for SwapEngine
    console.log(`\n🔓 Checking approvals...`);

    const allowanceA = await finalTokenA.contract.allowance(
      signer.address,
      SWAP_ENGINE_ADDRESS
    );
    const allowanceB = await finalTokenB.contract.allowance(
      signer.address,
      SWAP_ENGINE_ADDRESS
    );

    console.log(
      `🔍 ${finalTokenA.symbol} allowance: ${ethers.formatUnits(
        allowanceA,
        await finalTokenA.contract.decimals()
      )}`
    );
    console.log(
      `🔍 ${finalTokenB.symbol} allowance: ${ethers.formatUnits(
        allowanceB,
        await finalTokenB.contract.decimals()
      )}`
    );

    if (allowanceA < finalAmountA) {
      console.log(`📝 Approving ${finalTokenA.symbol}...`);
      try {
        const approveTxA = await finalTokenA.contract.approve(
          SWAP_ENGINE_ADDRESS,
          finalAmountA,
          { gasLimit: 200000 }
        );
        await approveTxA.wait();
        console.log(`✅ ${finalTokenA.symbol} approved`);
      } catch (error) {
        console.error(
          `❌ Failed to approve ${finalTokenA.symbol}: ${error.message}`
        );
        process.exit(1);
      }
    } else {
      console.log(`✅ ${finalTokenA.symbol} already approved`);
    }

    if (allowanceB < finalAmountB) {
      console.log(`📝 Approving ${finalTokenB.symbol}...`);
      try {
        const approveTxB = await finalTokenB.contract.approve(
          SWAP_ENGINE_ADDRESS,
          finalAmountB,
          { gasLimit: 200000 }
        );
        await approveTxB.wait();
        console.log(`✅ ${finalTokenB.symbol} approved`);
      } catch (error) {
        console.error(
          `❌ Failed to approve ${finalTokenB.symbol}: ${error.message}`
        );
        process.exit(1);
      }
    } else {
      console.log(`✅ ${finalTokenB.symbol} already approved`);
    }

    // Create new pool
    console.log(`\n🏗️ Creating new liquidity pool...`);
    const feeRate = 30; // 0.3% fee

    console.log(`📝 Creating pool with:`);
    console.log(`   TokenA: ${finalTokenA.address} (${finalTokenA.symbol})`);
    console.log(`   TokenB: ${finalTokenB.address} (${finalTokenB.symbol})`);
    console.log(
      `   AmountA: ${ethers.formatUnits(
        finalAmountA,
        await finalTokenA.contract.decimals()
      )}`
    );
    console.log(
      `   AmountB: ${ethers.formatUnits(
        finalAmountB,
        await finalTokenB.contract.decimals()
      )}`
    );
    console.log(`   Fee Rate: ${feeRate} basis points`);

    console.log(`⏳ Waiting 3 seconds before creating pool...`);
    await delay(3000); // 3-second delay

    try {
      const createTx = await swapEngine.createPool(
        finalTokenA.address,
        finalTokenB.address,
        finalAmountA,
        finalAmountB,
        feeRate,
        { gasLimit: 2000000 } // Increased gas limit for pool creation
      );

      const receipt = await createTx.wait();
      console.log(`\n✅ Pool created successfully!`);
      console.log(`📋 Transaction hash: ${receipt.hash}`);
    } catch (error) {
      console.error(`❌ Failed to create pool: ${error.message}`);
      if (error.data) {
        console.error(`Error data: ${error.data}`);
        try {
          const iface = new ethers.Interface(SWAP_ENGINE_ABI);
          const decodedError = iface.parseError(error.data);
          console.error(
            `❌ Revert reason: ${decodedError.name} - ${decodedError.args.join(
              ", "
            )}`
          );
        } catch (decodeError) {
          console.error(
            `❌ Could not decode revert reason: ${decodeError.message}`
          );
        }
      }
      process.exit(1);
    }

    console.log(
      `\n🎉 ${finalTokenA.symbol}/${finalTokenB.symbol} pool creation completed!`
    );
    console.log(`\n📊 Summary:`);
    console.log(`===========`);
    console.log(`Pool: ${finalTokenA.symbol}/${finalTokenB.symbol}`);
    console.log(
      `Liquidity: ${ethers.formatUnits(
        finalAmountA,
        await finalTokenA.contract.decimals()
      )} ${finalTokenA.symbol} + ${ethers.formatUnits(
        finalAmountB,
        await finalTokenB.contract.decimals()
      )} ${finalTokenB.symbol}`
    );
  } catch (error) {
    console.error(`❌ Error during pool creation: ${error.message}`);
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
