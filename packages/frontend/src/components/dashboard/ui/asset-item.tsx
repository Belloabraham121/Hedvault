interface AssetItemProps {
  asset: string
  symbol: string
  balance: string
  value: string
  change: string
}

export function AssetItem({ asset, symbol, balance, value, change }: AssetItemProps) {
  return (
    <div className="flex items-center justify-between p-6 rounded-xl bg-gray-800/40 backdrop-blur-sm border border-gray-700/50 hover:bg-gray-800/60 transition-all duration-200">
      <div className="flex items-center space-x-4">
        <div className="w-12 h-12 rounded-xl bg-green-500/10 border border-green-500/20 flex items-center justify-center">
          <span className="text-green-400 font-bold text-sm">{symbol}</span>
        </div>
        <div>
          <p className="text-white font-semibold text-lg">{asset}</p>
          <p className="text-gray-400 text-sm">
            {balance} {symbol}
          </p>
        </div>
      </div>
      <div className="text-right">
        <p className="text-white font-semibold text-lg">{value}</p>
        <p className="text-green-400 text-sm font-medium">{change}</p>
      </div>
    </div>
  )
}
