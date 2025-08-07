import { useReadContract, useWriteContract, useWaitForTransactionReceipt } from 'wagmi'
import { MarketplaceABI } from '@/lib/abis'
import { Address } from 'viem'
import { CONTRACT_ADDRESSES, HEDERA_TESTNET_CHAIN_ID } from '@/lib/contracts'

// Types based on the Marketplace contract
export interface Order {
  orderId: bigint
  maker: Address
  asset: Address
  paymentToken: Address
  amount: bigint
  price: bigint
  filled: bigint
  expiry: bigint
  orderType: number
  status: number
  createdAt: bigint
  fee: bigint
}

export interface AuctionData {
  auctionId: bigint
  seller: Address
  asset: Address
  amount: bigint
  startPrice: bigint
  reservePrice: bigint
  currentBid: bigint
  highestBidder: Address
  startTime: bigint
  endTime: bigint
  isActive: boolean
  isSettled: boolean
}

export interface MarketData {
  asset: Address
  lastPrice: bigint
  volume24h: bigint
  high24h: bigint
  low24h: bigint
  priceChange24h: bigint
  totalTrades: bigint
  lastTradeTime: bigint
}

export interface TradeData {
  tradeId: bigint
  buyOrderId: bigint
  sellOrderId: bigint
  buyer: Address
  seller: Address
  asset: Address
  amount: bigint
  price: bigint
  timestamp: bigint
  buyerFee: bigint
  sellerFee: bigint
}

// Read Hooks - Order Information
export function useGetOrder(orderId?: bigint) {
  return useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'getOrder',
    args: orderId ? [orderId] : undefined,
    chainId: HEDERA_TESTNET_CHAIN_ID,
    query: {
      enabled: !!orderId,
    },
  }) as { data: Order | undefined; isLoading: boolean; error: Error | null }
}

export function useGetAuction(auctionId?: bigint) {
  return useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'getAuction',
    args: auctionId ? [auctionId] : undefined,
    chainId: HEDERA_TESTNET_CHAIN_ID,
    query: {
      enabled: !!auctionId,
    },
  }) as { data: AuctionData | undefined; isLoading: boolean; error: Error | null }
}

export function useGetMarketData(asset?: Address) {
  return useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'getMarketData',
    args: asset ? [asset] : undefined,
    chainId: HEDERA_TESTNET_CHAIN_ID,
    query: {
      enabled: !!asset,
    },
  }) as { data: MarketData | undefined; isLoading: boolean; error: Error | null }
}

export function useGetAssetOrders(asset?: Address, orderType?: number) {
  return useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'getAssetOrders',
    args: asset && orderType !== undefined ? [asset, orderType] : undefined,
    chainId: HEDERA_TESTNET_CHAIN_ID,
    query: {
      enabled: !!asset && orderType !== undefined,
    },
  })
}

export function useGetUserOrders(user?: Address) {
  return useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'getUserOrders',
    args: user ? [user] : undefined,
    chainId: HEDERA_TESTNET_CHAIN_ID,
    query: {
      enabled: !!user,
    },
  })
}

export function useGetBestAskPrice(asset?: Address) {
  return useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'bestAskPrice',
    args: asset ? [asset] : undefined,
    chainId: HEDERA_TESTNET_CHAIN_ID,
    query: {
      enabled: !!asset,
    },
  })
}

export function useGetBestBidPrice(asset?: Address) {
  return useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'bestBidPrice',
    args: asset ? [asset] : undefined,
    chainId: HEDERA_TESTNET_CHAIN_ID,
    query: {
      enabled: !!asset,
    },
  })
}

// Read Hooks - Platform Information
export function useIsPaused() {
  return useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'paused',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  })
}

export function useGetNextOrderId() {
  return useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'nextOrderId',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  })
}

export function useGetNextAuctionId() {
  return useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'nextAuctionId',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  })
}

export function useGetNextTradeId() {
  return useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'nextTradeId',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  })
}

export function useGetHedVaultCore() {
  return useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'hedVaultCore',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  })
}

export function useGetPriceOracle() {
  return useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'priceOracle',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  })
}

export function useGetFeeRecipient() {
  return useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'feeRecipient',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  })
}

export function useGetMakerFee() {
  return useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'makerFee',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  })
}

export function useGetTakerFee() {
  return useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'takerFee',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  })
}

export function useGetAuctionFee() {
  return useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'auctionFee',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  })
}

export function useGetProtocolFee() {
  return useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'protocolFee',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  })
}

export function useGetTotalFeesCollected() {
  return useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'totalFeesCollected',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  })
}

export function useGetTotalTradesExecuted() {
  return useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'totalTradesExecuted',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  })
}

export function useGetTotalVolumeTraded() {
  return useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'totalVolumeTraded',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  })
}

export function useIsAssetTradingEnabled(asset?: Address) {
  return useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'assetTradingEnabled',
    args: asset ? [asset] : undefined,
    chainId: HEDERA_TESTNET_CHAIN_ID,
    query: {
      enabled: !!asset,
    },
  })
}

export function useIsSupportedAsset(asset?: Address) {
  return useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'supportedAssets',
    args: asset ? [asset] : undefined,
    chainId: HEDERA_TESTNET_CHAIN_ID,
    query: {
      enabled: !!asset,
    },
  })
}

export function useIsSupportedPaymentToken(token?: Address) {
  return useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'supportedPaymentTokens',
    args: token ? [token] : undefined,
    chainId: HEDERA_TESTNET_CHAIN_ID,
    query: {
      enabled: !!token,
    },
  })
}

export function useIsEmergencyStop() {
  return useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'emergencyStop',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  })
}

// Read Hooks - Constants
export function useMarketplaceConstants() {
  const defaultAdminRole = useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'DEFAULT_ADMIN_ROLE',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  })

  const emergencyRole = useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'EMERGENCY_ROLE',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  })

  const feeManagerRole = useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'FEE_MANAGER_ROLE',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  })

  const marketplaceAdminRole = useReadContract({
    address: CONTRACT_ADDRESSES.Marketplace,
    abi: MarketplaceABI,
    functionName: 'MARKETPLACE_ADMIN_ROLE',
    chainId: HEDERA_TESTNET_CHAIN_ID,
  })

  return {
    DEFAULT_ADMIN_ROLE: defaultAdminRole.data,
    EMERGENCY_ROLE: emergencyRole.data,
    FEE_MANAGER_ROLE: feeManagerRole.data,
    MARKETPLACE_ADMIN_ROLE: marketplaceAdminRole.data,
  }
}

// Write Hooks - Order Management
export function useCreateOrder() {
  const { writeContract, data: hash, error, isPending } = useWriteContract()

  const createOrder = (
    asset: Address,
    paymentToken: Address,
    amount: bigint,
    price: bigint,
    orderType: number,
    expiry: bigint
  ) => {
    writeContract({
      address: CONTRACT_ADDRESSES.Marketplace,
      abi: MarketplaceABI,
      functionName: 'createOrder',
      args: [asset, paymentToken, amount, price, orderType, expiry],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    })
  }

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  })

  return {
    createOrder,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  }
}

export function useCancelOrder() {
  const { writeContract, data: hash, error, isPending } = useWriteContract()

  const cancelOrder = (orderId: bigint) => {
    writeContract({
      address: CONTRACT_ADDRESSES.Marketplace,
      abi: MarketplaceABI,
      functionName: 'cancelOrder',
      args: [orderId],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    })
  }

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  })

  return {
    cancelOrder,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  }
}

export function useMarketOrder() {
  const { writeContract, data: hash, error, isPending } = useWriteContract()

  const marketOrder = (
    asset: Address,
    paymentToken: Address,
    amount: bigint,
    orderType: number,
    maxSlippage: bigint
  ) => {
    writeContract({
      address: CONTRACT_ADDRESSES.Marketplace,
      abi: MarketplaceABI,
      functionName: 'marketOrder',
      args: [asset, paymentToken, amount, orderType, maxSlippage],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    })
  }

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  })

  return {
    marketOrder,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  }
}

// Write Hooks - Auction Management
export function useCreateAuction() {
  const { writeContract, data: hash, error, isPending } = useWriteContract()

  const createAuction = (
    asset: Address,
    amount: bigint,
    startPrice: bigint,
    reservePrice: bigint,
    duration: bigint
  ) => {
    writeContract({
      address: CONTRACT_ADDRESSES.Marketplace,
      abi: MarketplaceABI,
      functionName: 'createAuction',
      args: [asset, amount, startPrice, reservePrice, duration],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    })
  }

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  })

  return {
    createAuction,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  }
}

export function usePlaceBid() {
  const { writeContract, data: hash, error, isPending } = useWriteContract()

  const placeBid = (auctionId: bigint, bidAmount: bigint) => {
    writeContract({
      address: CONTRACT_ADDRESSES.Marketplace,
      abi: MarketplaceABI,
      functionName: 'placeBid',
      args: [auctionId, bidAmount],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    })
  }

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  })

  return {
    placeBid,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  }
}

export function useSettleAuction() {
  const { writeContract, data: hash, error, isPending } = useWriteContract()

  const settleAuction = (auctionId: bigint) => {
    writeContract({
      address: CONTRACT_ADDRESSES.Marketplace,
      abi: MarketplaceABI,
      functionName: 'settleAuction',
      args: [auctionId],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    })
  }

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  })

  return {
    settleAuction,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  }
}

// Write Hooks - Admin Functions
export function useAddSupportedAsset() {
  const { writeContract, data: hash, error, isPending } = useWriteContract()

  const addSupportedAsset = (asset: Address) => {
    writeContract({
      address: CONTRACT_ADDRESSES.Marketplace,
      abi: MarketplaceABI,
      functionName: 'addSupportedAsset',
      args: [asset],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    })
  }

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  })

  return {
    addSupportedAsset,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  }
}

export function useAddSupportedPaymentToken() {
  const { writeContract, data: hash, error, isPending } = useWriteContract()

  const addSupportedPaymentToken = (token: Address) => {
    writeContract({
      address: CONTRACT_ADDRESSES.Marketplace,
      abi: MarketplaceABI,
      functionName: 'addSupportedPaymentToken',
      args: [token],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    })
  }

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  })

  return {
    addSupportedPaymentToken,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  }
}

export function useSetAssetTradingEnabled() {
  const { writeContract, data: hash, error, isPending } = useWriteContract()

  const setAssetTradingEnabled = (asset: Address, enabled: boolean) => {
    writeContract({
      address: CONTRACT_ADDRESSES.Marketplace,
      abi: MarketplaceABI,
      functionName: 'setAssetTradingEnabled',
      args: [asset, enabled],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    })
  }

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  })

  return {
    setAssetTradingEnabled,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  }
}

export function useUpdateFees() {
  const { writeContract, data: hash, error, isPending } = useWriteContract()

  const updateFees = (makerFee: bigint, takerFee: bigint, auctionFee: bigint) => {
    writeContract({
      address: CONTRACT_ADDRESSES.Marketplace,
      abi: MarketplaceABI,
      functionName: 'updateFees',
      args: [makerFee, takerFee, auctionFee],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    })
  }

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  })

  return {
    updateFees,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  }
}

export function useUpdateTradingLimits() {
  const { writeContract, data: hash, error, isPending } = useWriteContract()

  const updateTradingLimits = (maxActiveOrdersPerUser: bigint, maxSlippageAllowed: bigint) => {
    writeContract({
      address: CONTRACT_ADDRESSES.Marketplace,
      abi: MarketplaceABI,
      functionName: 'updateTradingLimits',
      args: [maxActiveOrdersPerUser, maxSlippageAllowed],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    })
  }

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  })

  return {
    updateTradingLimits,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  }
}

// Write Hooks - Emergency Functions
export function useActivateEmergencyStop() {
  const { writeContract, data: hash, error, isPending } = useWriteContract()

  const activateEmergencyStop = () => {
    writeContract({
      address: CONTRACT_ADDRESSES.Marketplace,
      abi: MarketplaceABI,
      functionName: 'activateEmergencyStop',
      chainId: HEDERA_TESTNET_CHAIN_ID,
    })
  }

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  })

  return {
    activateEmergencyStop,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  }
}

export function useDeactivateEmergencyStop() {
  const { writeContract, data: hash, error, isPending } = useWriteContract()

  const deactivateEmergencyStop = () => {
    writeContract({
      address: CONTRACT_ADDRESSES.Marketplace,
      abi: MarketplaceABI,
      functionName: 'deactivateEmergencyStop',
      chainId: HEDERA_TESTNET_CHAIN_ID,
    })
  }

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  })

  return {
    deactivateEmergencyStop,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  }
}

export function usePause() {
  const { writeContract, data: hash, error, isPending } = useWriteContract()

  const pause = () => {
    writeContract({
      address: CONTRACT_ADDRESSES.Marketplace,
      abi: MarketplaceABI,
      functionName: 'pause',
      chainId: HEDERA_TESTNET_CHAIN_ID,
    })
  }

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  })

  return {
    pause,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  }
}

export function useUnpause() {
  const { writeContract, data: hash, error, isPending } = useWriteContract()

  const unpause = () => {
    writeContract({
      address: CONTRACT_ADDRESSES.Marketplace,
      abi: MarketplaceABI,
      functionName: 'unpause',
      chainId: HEDERA_TESTNET_CHAIN_ID,
    })
  }

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  })

  return {
    unpause,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  }
}

// Write Hooks - Role Management
export function useGrantRole() {
  const { writeContract, data: hash, error, isPending } = useWriteContract()

  const grantRole = (role: `0x${string}`, account: Address) => {
    writeContract({
      address: CONTRACT_ADDRESSES.Marketplace,
      abi: MarketplaceABI,
      functionName: 'grantRole',
      args: [role, account],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    })
  }

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  })

  return {
    grantRole,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  }
}

export function useRevokeRole() {
  const { writeContract, data: hash, error, isPending } = useWriteContract()

  const revokeRole = (role: `0x${string}`, account: Address) => {
    writeContract({
      address: CONTRACT_ADDRESSES.Marketplace,
      abi: MarketplaceABI,
      functionName: 'revokeRole',
      args: [role, account],
      chainId: HEDERA_TESTNET_CHAIN_ID,
    })
  }

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  })

  return {
    revokeRole,
    hash,
    error,
    isPending,
    isConfirming,
    isConfirmed,
  }
}