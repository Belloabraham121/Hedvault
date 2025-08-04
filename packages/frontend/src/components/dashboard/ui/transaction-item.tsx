interface TransactionItemProps {
  type: string
  asset: string
  amount: string
  value: string
  time: string
}

export function TransactionItem({ type, asset, amount, value, time }: TransactionItemProps) {
  const getTypeColor = () => {
    switch (type) {
      case "Buy":
        return "bg-green-500/20 text-green-400 border-green-500/30"
      case "Swap":
        return "bg-blue-500/20 text-blue-400 border-blue-500/30"
      case "Lend":
        return "bg-purple-500/20 text-purple-400 border-purple-500/30"
      case "Reward":
        return "bg-yellow-500/20 text-yellow-400 border-yellow-500/30"
      default:
        return "bg-gray-500/20 text-gray-400 border-gray-500/30"
    }
  }

  return (
    <div className="flex items-center justify-between p-6 rounded-xl bg-gray-800/40 backdrop-blur-sm border border-gray-700/50 hover:bg-gray-800/60 transition-all duration-200">
      <div className="flex items-center space-x-4">
        <div className={`w-10 h-10 rounded-xl border flex items-center justify-center ${getTypeColor()}`}>
          <span className="text-xs font-bold">{type[0]}</span>
        </div>
        <div>
          <p className="text-white font-semibold">
            {type} {asset}
          </p>
          <p className="text-gray-400 text-sm">{time}</p>
        </div>
      </div>
      <div className="text-right">
        <p className="text-white font-semibold">{amount}</p>
        <p className="text-gray-400 text-sm">{value}</p>
      </div>
    </div>
  )
}
