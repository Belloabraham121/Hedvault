import { useReadContract } from "wagmi";
import { useMemo } from "react";
import { RWATOKEN_FACTORY_ABI } from "../abis/RWATokenFactory";
import { RWATOKEN_FACTORY_ADDRESS } from "../config/rwaTokenFactory";

// Hook for getting all RWA token addresses
export function useGetAllRWATokens() {
  return useReadContract({
    address: RWATOKEN_FACTORY_ADDRESS,
    abi: RWATOKEN_FACTORY_ABI,
    functionName: "getAllRWATokens",
  });
}

// Hook for getting all RWA tokens with detailed info
export function useGetAllRWATokensWithInfo() {
  return useReadContract({
    address: RWATOKEN_FACTORY_ADDRESS,
    abi: RWATOKEN_FACTORY_ABI,
    functionName: "getAllRWATokensWithInfo",
  });
}

// Combined hook for both functions
export function useRWATokenFactoryTokens() {
  const allTokens = useGetAllRWATokens();
  const allTokensWithInfo = useGetAllRWATokensWithInfo();

  return useMemo(
    () => ({
      allTokens,
      allTokensWithInfo,
      isLoading: allTokens.isLoading || allTokensWithInfo.isLoading,
      isError: allTokens.isError || allTokensWithInfo.isError,
      error: allTokens.error || allTokensWithInfo.error,
      refetch: () => {
        allTokens.refetch();
        allTokensWithInfo.refetch();
      },
    }),
    [allTokens, allTokensWithInfo]
  );
}

// Usage example component
/*
import { useRWATokenFactoryTokens } from '../hooks/useRWATokenFactoryTokens';

function RWATokenList() {
  const { allTokens, allTokensWithInfo, isLoading, error } = useRWATokenFactoryTokens();

  if (isLoading) return <div>Loading tokens...</div>;
  if (error) return <div>Error loading tokens</div>;

  const tokens = allTokens.data || [];
  const tokensWithInfo = allTokensWithInfo.data || { tokenAddresses: [], assetInfos: [] };

  return (
    <div>
      <h2>All RWA Tokens ({tokens.length})</h2>
      <ul>
        {tokens.map((tokenAddress) => (
          <li key={tokenAddress}>{tokenAddress}</li>
        ))}
      </ul>

      <h2>Detailed Token Information</h2>
      {tokensWithInfo.tokenAddresses.map((address, index) => (
        <div key={address}>
          <h3>{address}</h3>
          <p>Asset Type: {tokensWithInfo.assetInfos[index]?.metadata.assetType}</p>
          <p>Location: {tokensWithInfo.assetInfos[index]?.metadata.location}</p>
          <p>Valuation: {tokensWithInfo.assetInfos[index]?.metadata.valuation?.toString()}</p>
        </div>
      ))}
    </div>
  );
}
*/
