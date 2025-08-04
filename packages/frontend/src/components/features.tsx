import { Grid3X3, Maximize2, Shield, ArrowLeftRight, Vault, Coins } from "lucide-react"

export default function Features() {
  const features = [
    {
      icon: Grid3X3,
      title: "Scalability for Global Assets",
      description:
        "HedVault uses Hedera Hashgraph to support high-volume transactions, allowing you to buy, sell, and swap RWAs with speed and efficiency.",
    },
    {
      icon: Maximize2,
      title: "Decentralized Control & Liquidity",
      description:
        "Your assets, your rules. HedVault ensures full control through transparent smart contracts and non-custodial DeFi mechanics.",
    },
    {
      icon: Shield,
      title: "Compliant & Secure Transactions",
      description:
        "KYC/AML-ready and audit-friendly. HedVault aligns with institutional-grade compliance standards for regulated DeFi operations.",
    },
    {
      icon: ArrowLeftRight,
      title: "Swap Between Tokenized Assets",
      description:
        "Seamlessly swap between RWA classes—real estate, invoices, or commodities—via decentralized, low-slippage pools with fair pricing.",
    },
    {
      icon: Vault,
      title: "Unlock Liquidity Without Selling",
      description:
        "Use your RWAs as collateral to borrow funds or lend assets to earn yield—without needing to sell or exit your position.",
    },
    {
      icon: Coins,
      title: "Earn While You Hold",
      description:
        "Stake RWAs to earn in multiple tokens—stablecoins, native tokens, and more. Customize your yield strategy to suit your goals.",
    },
  ]

  return (
    <section className="relative">
      {/* Black Background */}
      <div className="bg-black">
        {/* Content Container */}
        <div className="container mx-auto px-6 md:px-8 lg:px-12 pb-20 md:pb-32">
          {/* Section Header */}
          <div className="text-center mb-16 md:mb-20">
            {/* Features Badge */}
            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-gray-700 bg-gray-900/50 backdrop-blur-sm mb-8">
              <span className="text-sm font-medium text-green-400">Features</span>
            </div>

            {/* Title */}
            <h2 className="text-4xl md:text-5xl lg:text-6xl font-bold text-white mb-6">
              Your Gateway to Comprehensive RWA DeFi
            </h2>

            {/* Description */}
            <p className="text-lg md:text-xl text-gray-400 leading-relaxed max-w-2xl mx-auto">
              HedVault empowers you to buy, sell, swap, lend, borrow, and stake real-world assets—all through a
              seamless, secure, and compliant DeFi interface.
            </p>
          </div>

          {/* Features Grid */}
          <div className="grid md:grid-cols-3 lg:grid-cols-3 gap-6 md:gap-8">
            {features.map((feature, index) => {
              const IconComponent = feature.icon
              return (
                <div
                  key={index}
                  className="group p-8 rounded-2xl border border-gray-800 bg-gray-900/50 backdrop-blur-sm hover:bg-gray-800/50 transition-all duration-300"
                >
                  {/* Icon */}
                  <div className="mb-6">
                    <div className="w-12 h-12 rounded-lg bg-green-500/10 flex items-center justify-center group-hover:bg-green-500/20 transition-colors duration-300">
                      <IconComponent className="w-6 h-6 text-green-400" />
                    </div>
                  </div>

                  {/* Content */}
                  <div className="space-y-4">
                    <h3 className="text-xl md:text-2xl font-semibold text-white">{feature.title}</h3>
                    <p className="text-gray-400 leading-relaxed">{feature.description}</p>
                  </div>
                </div>
              )
            })}
          </div>
        </div>
      </div>
    </section>
  )
}