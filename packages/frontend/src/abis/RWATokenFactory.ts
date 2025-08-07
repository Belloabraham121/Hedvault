// Complete RWATokenFactory ABI for frontend integration
export const RWATOKEN_FACTORY_ABI = [
  {
    inputs: [
      {
        internalType: "address",
        name: "_hedVaultCore",
        type: "address",
      },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    inputs: [],
    name: "CREATOR_ROLE",
    outputs: [
      {
        internalType: "bytes32",
        name: "",
        type: "bytes32",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "ADMIN_ROLE",
    outputs: [
      {
        internalType: "bytes32",
        name: "",
        type: "bytes32",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "string",
        name: "assetType",
        type: "string",
      },
    ],
    name: "addAssetType",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "creator",
        type: "address",
      },
    ],
    name: "approveCreator",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    name: "assetInfo",
    outputs: [
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
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    name: "assetTypeCount",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    name: "approvedCreators",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
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
        internalType: "string",
        name: "name",
        type: "string",
      },
      {
        internalType: "string",
        name: "symbol",
        type: "string",
      },
      {
        internalType: "uint256",
        name: "totalSupply",
        type: "uint256",
      },
    ],
    name: "createRWAToken",
    outputs: [
      {
        internalType: "address",
        name: "tokenAddress",
        type: "address",
      },
    ],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "tokenAddress",
        type: "address",
      },
      {
        internalType: "string",
        name: "reason",
        type: "string",
      },
    ],
    name: "delistToken",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "creator",
        type: "address",
      },
    ],
    name: "getCreatorTokens",
    outputs: [
      {
        internalType: "uint256[]",
        name: "",
        type: "uint256[]",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
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
  {
    inputs: [
      {
        internalType: "string",
        name: "assetType",
        type: "string",
      },
    ],
    name: "getAssetTypeCount",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "tokenAddress",
        type: "address",
      },
    ],
    name: "getAssetInfo",
    outputs: [
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
        internalType: "struct DataTypes.AssetInfo",
        name: "",
        type: "tuple",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "getTotalTokens",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "hedVaultCore",
    outputs: [
      {
        internalType: "contract IHedVaultCore",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    name: "isRWAToken",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    name: "isAssetTypeSupported",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "tokenAddress",
        type: "address",
      },
    ],
    name: "listToken",
    outputs: [],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [],
    name: "listingFee",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "pause",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "string",
        name: "assetType",
        type: "string",
      },
    ],
    name: "removeAssetType",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "creator",
        type: "address",
      },
    ],
    name: "revokeCreator",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    name: "supportedAssetTypes",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "tokenCreationFee",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    name: "tokenToId",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    name: "tokenById",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "unpause",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "tokenAddress",
        type: "address",
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
        name: "newMetadata",
        type: "tuple",
      },
    ],
    name: "updateTokenMetadata",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "newFee",
        type: "uint256",
      },
    ],
    name: "updateTokenCreationFee",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "newFee",
        type: "uint256",
      },
    ],
    name: "updateListingFee",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;

// Type definitions for contract interaction
export interface RWAMetadata {
  assetType: string;
  location: string;
  valuation: bigint;
  oracle: `0x${string}`;
  totalSupply: bigint;
  minInvestment: bigint;
  certificationHash: string;
  additionalData: string;
}

export interface AssetInfo {
  tokenAddress: `0x${string}`;
  creator: `0x${string}`;
  creationTime: bigint;
  metadata: RWAMetadata;
  complianceLevel: number;
  isListed: boolean;
  tradingVolume: bigint;
  holders: bigint;
}

export interface RWATokenWithInfo {
  tokenAddress: `0x${string}`;
  assetInfo: AssetInfo;
}
