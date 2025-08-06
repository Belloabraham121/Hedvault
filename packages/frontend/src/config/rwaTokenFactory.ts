// Configuration file for RWATokenFactory contract
// This file helps extract the contract address from the broadcast JSON

// Import the broadcast JSON file
// You can use this to programmatically get the address from your deployment
export const getRWATokenFactoryAddress = () => {
  // The actual address should be extracted from your broadcast file:
  // /Users/iteoluwakisibello/Documents/Hedvault/packages/contract/broadcast/DeployRWATokenFactory.s.sol/296/run-1754499082.json
  
  // For now, replace this with the actual address from your broadcast file
  // Look for "contractAddress" or "transactionReceipt.contractAddress" in the JSON
  return '0xYourActualContractAddressHere' as const;
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

// Default address - update this with your actual deployed address
export const RWATOKEN_FACTORY_ADDRESS = getRWATokenFactoryAddress();