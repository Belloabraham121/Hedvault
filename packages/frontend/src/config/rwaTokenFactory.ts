// Configuration file for RWATokenFactory contract
// This file helps extract the contract address from the broadcast JSON

// Import the broadcast JSON file
// You can use this to programmatically get the address from your deployment
export const getRWATokenFactoryAddress = () => {
  // The actual address should be extracted from your broadcast file:
  // /Users/iteoluwakisibello/Documents/Hedvault/packages/contract/broadcast/DeployRWATokenFactory.s.sol/296/run-1754499082.json

  // For now, replace this with the actual address from your broadcast file
  // Look for "contractAddress" or "transactionReceipt.contractAddress" in the JSON
  return "0xYourActualContractAddressHere" as const;
};

// Example of how to use the broadcast JSON:
/*
// In your component or setup file:
import broadcastData from '../../../contract/broadcast/DeployRWATokenFactory.s.sol/296/run-1754499082.json';

const getAddressFromBroadcast = () => {
  // Assuming the broadcast JSON has transactions array
  const deploymentTransaction = broadcastData.transactions?.find(
    (tx: any) => tx.contractName === 'RWATokenFactory'
  );
  return deploymentTransaction?.contractAddress || deploymentTransaction?.transactionReceipt?.contractAddress;
};
*/

// RWATokenFactory address from deployment
export const RWATOKEN_FACTORY_ADDRESS =
  "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9" as const;

// RWA Token addresses for frontend integration
// These are Hedera token addresses in EVM format (long-zero format)
export const RWA_TOKEN_ADDRESSES = {
  GOLD: "0x0000000000000000000000000000000000636359" as const,
  SILVER: "0x00000000000000000000000000000000006363ad" as const,
  REAL_ESTATE: "0x00000000000000000000000000000000006363ba" as const,
} as const;

// Alternative: If the above addresses don't work, try these converted formats
// These convert the Hedera token IDs to proper EVM addresses
export const ALTERNATIVE_TOKEN_ADDRESSES = {
  // Token ID 0.0.6513497 (636359 in hex) -> proper EVM format
  GOLD: "0x0000000000000000000000000000000000636359" as const,
  // Token ID 0.0.6513581 (6363ad in hex) -> proper EVM format
  SILVER: "0x00000000000000000000000000000000006363ad" as const,
  // Token ID 0.0.6513594 (6363ba in hex) -> proper EVM format
  REAL_ESTATE: "0x00000000000000000000000000000000006363ba" as const,
} as const;

// Type for RWA token types
export type RWATokenType = keyof typeof RWA_TOKEN_ADDRESSES;

// Helper function to get token address by type
export const getRWATokenAddress = (tokenType: RWATokenType): string => {
  return RWA_TOKEN_ADDRESSES[tokenType];
};

// All RWA token addresses as an array
export const ALL_RWA_TOKEN_ADDRESSES = Object.values(RWA_TOKEN_ADDRESSES);
