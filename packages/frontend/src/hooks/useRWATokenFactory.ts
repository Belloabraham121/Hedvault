import { useReadContract } from "wagmi";
import { Address } from "viem";

// ABI for RWATokenFactory - focusing on the two required functions
export const RWATOKEN_FACTORY_ABI = [
  {
    inputs: [],
    name: "getAllRWATokens",
    outputs: [
      {
        internalType: "address[]",
        name: "tokens",
        type: "address[]",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getAllRWATokensWithInfo",
    outputs: [
      {
        internalType: "address[]",
        name: "tokenAddresses",
        type: "address[]",
      },
      {
        components: [
          {
            internalType: "address",
            name: "tokenAddress",
            type: "address",
          },
          {
            internalType: "address",
            name: "creator",
            type: "address",
          },
          {
            internalType: "uint256",
            name: "creationTime",
            type: "uint256",
          },
          {
            components: [
              {
                internalType: "string",
                name: "assetType",
                type: "string",
              },
              {
                internalType: "string",
                name: "location",
                type: "string",
              },
              {
                internalType: "uint256",
                name: "valuation",
                type: "uint256",
              },
              {
                internalType: "address",
                name: "oracle",
                type: "address",
              },
              {
                internalType: "uint256",
                name: "totalSupply",
                type: "uint256",
              },
              {
                internalType: "uint256",
                name: "minInvestment",
                type: "uint256",
              },
              {
                internalType: "string",
                name: "certificationHash",
                type: "string",
              },
              {
                internalType: "string",
                name: "additionalData",
                type: "string",
              },
            ],
            internalType: "struct DataTypes.RWAMetadata",
            name: "metadata",
            type: "tuple",
          },
          {
            internalType: "uint8",
            name: "complianceLevel",
            type: "uint8",
          },
          {
            internalType: "bool",
            name: "isListed",
            type: "bool",
          },
          {
            internalType: "uint256",
            name: "tradingVolume",
            type: "uint256",
          },
          {
            internalType: "uint256",
            name: "holders",
            type: "uint256",
          },
        ],
        internalType: "struct DataTypes.AssetInfo[]",
        name: "assetInfos",
        type: "tuple[]",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
] as const;

// Type definitions for the contract data
export interface RWAMetadata {
  assetType: string;
  location: string;
  valuation: bigint;
  oracle: Address;
  totalSupply: bigint;
  minInvestment: bigint;
  certificationHash: string;
  additionalData: string;
}

export interface AssetInfo {
  tokenAddress: Address;
  creator: Address;
  creationTime: bigint;
  metadata: RWAMetadata;
  complianceLevel: number;
  isListed: boolean;
  tradingVolume: bigint;
  holders: bigint;
}

export interface RWATokenWithInfo {
  tokenAddress: Address;
  assetInfo: AssetInfo;
}

// Hook to get all RWA token addresses
export function useGetAllRWATokens(factoryAddress: Address) {
  return useReadContract({
    address: factoryAddress,
    abi: RWATOKEN_FACTORY_ABI,
    functionName: "getAllRWATokens",
  });
}

// Hook to get all RWA tokens with their asset info
export function useGetAllRWATokensWithInfo(factoryAddress: Address) {
  const { data, error, isLoading, refetch } = useReadContract({
    address: factoryAddress,
    abi: RWATOKEN_FACTORY_ABI,
    functionName: "getAllRWATokensWithInfo",
  });

  const tokensWithInfo: RWATokenWithInfo[] = data
    ? data[0].map((tokenAddress, index) => ({
        tokenAddress,
        assetInfo: data[1][index] as AssetInfo,
      }))
    : [];

  return {
    data: tokensWithInfo,
    rawData: data,
    error,
    isLoading,
    refetch,
  };
}

// Combined hook for both functions
export function useRWATokenFactory(factoryAddress: Address) {
  const tokensQuery = useGetAllRWATokens(factoryAddress);
  const tokensWithInfoQuery = useGetAllRWATokensWithInfo(factoryAddress);

  return {
    tokens: tokensQuery.data,
    tokensWithInfo: tokensWithInfoQuery.data,
    isLoading: tokensQuery.isLoading || tokensWithInfoQuery.isLoading,
    error: tokensQuery.error || tokensWithInfoQuery.error,
    refetch: () => {
      tokensQuery.refetch();
      tokensWithInfoQuery.refetch();
    },
  };
}
