import { useMemo } from "react";
import { Address } from "viem";
import { 
  RWA_TOKEN_ADDRESSES, 
  getRWATokenAddress, 
  type RWATokenType,
  ALL_RWA_TOKEN_ADDRESSES 
} from "@/config/rwaTokenFactory";

// Basic RWA Token ABI for common functions
export const RWA_TOKEN_ABI = [
  {
    inputs: [],
    name: "name",
    outputs: [{ internalType: "string", name: "", type: "string" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "symbol",
    outputs: [{ internalType: "string", name: "", type: "string" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "totalSupply",
    outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [{ internalType: "address", name: "account", type: "address" }],
    name: "balanceOf",
    outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "creator",
    outputs: [{ internalType: "address", name: "", type: "address" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "factory",
    outputs: [{ internalType: "address", name: "", type: "address" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getHolderCount",
    outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "transfersEnabled",
    outputs: [{ internalType: "bool", name: "", type: "bool" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      { internalType: "address", name: "to", type: "address" },
      { internalType: "uint256", name: "amount", type: "uint256" },
    ],
    name: "transfer",
    outputs: [{ internalType: "bool", name: "", type: "bool" }],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      { internalType: "address", name: "spender", type: "address" },
      { internalType: "uint256", name: "amount", type: "uint256" },
    ],
    name: "approve",
    outputs: [{ internalType: "bool", name: "", type: "bool" }],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;

export interface PredefinedTokenInfo {
  type: RWATokenType;
  address: Address;
  name: string;
  symbol: string;
  description: string;
  category: string;
}

const PREDEFINED_TOKEN_INFO: Record<RWATokenType, Omit<PredefinedTokenInfo, 'address'>> = {
  GOLD: {
    type: "GOLD",
    name: "HedVault Gold Token",
    symbol: "HVGOLD",
    description: "Tokenized gold reserves with verified authenticity",
    category: "Precious Metals",
  },
  SILVER: {
    type: "SILVER",
    name: "HedVault Silver Token",
    symbol: "HVSILVER",
    description: "Premium silver bullion backed tokens",
    category: "Precious Metals",
  },
  REAL_ESTATE: {
    type: "REAL_ESTATE",
    name: "HedVault Real Estate Token",
    symbol: "HVRE",
    description: "Fractionalized commercial real estate portfolio",
    category: "Real Estate",
  },
};

/**
 * Hook to get information about predefined RWA tokens
 */
export function usePredefinedRWATokens() {
  const tokens = useMemo(() => {
    return Object.entries(RWA_TOKEN_ADDRESSES).map(([type, address]) => ({
      ...PREDEFINED_TOKEN_INFO[type as RWATokenType],
      address: address as Address,
    }));
  }, []);

  const getTokenByType = (type: RWATokenType): PredefinedTokenInfo | undefined => {
    return tokens.find(token => token.type === type);
  };

  const getTokenByAddress = (address: string): PredefinedTokenInfo | undefined => {
    return tokens.find(token => 
      token.address.toLowerCase() === address.toLowerCase()
    );
  };

  const getTokensByCategory = (category: string): PredefinedTokenInfo[] => {
    return tokens.filter(token => token.category === category);
  };

  return {
    tokens,
    addresses: ALL_RWA_TOKEN_ADDRESSES,
    getTokenByType,
    getTokenByAddress,
    getTokensByCategory,
    categories: [...new Set(tokens.map(token => token.category))],
    count: tokens.length,
  };
}

/**
 * Hook to get a specific predefined RWA token
 */
export function usePredefinedRWAToken(type: RWATokenType) {
  const { getTokenByType } = usePredefinedRWATokens();
  
  return useMemo(() => {
    const token = getTokenByType(type);
    if (!token) return null;
    
    return {
      ...token,
      contractConfig: {
        address: token.address,
        abi: RWA_TOKEN_ABI,
      },
    };
  }, [type, getTokenByType]);
}

/**
 * Utility function to check if an address is a predefined RWA token
 */
export function isPredefinedRWAToken(address: string): boolean {
  return ALL_RWA_TOKEN_ADDRESSES.some(
    tokenAddress => tokenAddress.toLowerCase() === address.toLowerCase()
  );
}

/**
 * Get the token type from an address
 */
export function getTokenTypeFromAddress(address: string): RWATokenType | null {
  const entry = Object.entries(RWA_TOKEN_ADDRESSES).find(
    ([, tokenAddress]) => tokenAddress.toLowerCase() === address.toLowerCase()
  );
  return entry ? (entry[0] as RWATokenType) : null;
}