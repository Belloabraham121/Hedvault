#!/usr/bin/env node

/**
 * @title Debug RWATokenFactory
 * @description Debug script to check factory state
 */

const { ethers } = require("ethers");

// Configuration
const CONFIG = {
  RPC_URL: "http://localhost:8545", // Local Anvil network
  FACTORY_ADDRESS: "0x49033d8a5a530cd752881b54a5e52bad7cb83bc8", // Latest deployed address
};

const FACTORY_ABI = [
  "function tokenCreationFee() view returns (uint256)",
  "function paused() view returns (bool)",
  "function getTotalTokens() view returns (uint256)",
  "function isAssetTypeSupported(string) view returns (bool)",
];

async function debugFactory() {
  try {
    const provider = new ethers.JsonRpcProvider(CONFIG.RPC_URL);
    const factory = new ethers.Contract(
      CONFIG.FACTORY_ADDRESS,
      FACTORY_ABI,
      provider
    );

    console.log("🔍 Debugging RWATokenFactory...");
    console.log(`📍 Factory Address: ${CONFIG.FACTORY_ADDRESS}`);

    const isPaused = await factory.paused();
    const totalTokens = await factory.getTotalTokens();
    const isGoldSupported = await factory.isAssetTypeSupported(
      "PreciousMetals"
    );

    console.log(`💰 Creation Fee: Removed (no fee required)`);
    console.log(`⏸️  Contract Paused: ${isPaused}`);
    console.log(`🪙 Total Tokens Created: ${totalTokens}`);
    console.log(`✅ Gold (PreciousMetals) Supported: ${isGoldSupported}`);
  } catch (error) {
    console.error("❌ Error:", error.message);
  }
}

debugFactory();
