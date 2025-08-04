import { Link2, Shield, Atom } from "lucide-react";

export default function FeatureDetail() {
  const features = [
    {
      icon: Link2,
      title: "Plug into the Wider DeFi Ecosystem",
      description:
        "RWAs on HedVault are compatible with dApps, wallets, and protocols across Hedera—ensuring seamless movement of assets.",
    },
    {
      icon: Shield,
      title: "Bank-Grade Security for Every Transaction",
      description:
        "Hedera's hashgraph consensus guarantees tamper-proof records and reliable transaction finality for all DeFi operations.",
    },
    {
      icon: Atom,
      title: "Transparent & Decentralized RWA Management",
      description:
        "Every token, loan, swap, and reward is verifiable and immutable—instilling long-term confidence for both retail and institutional users.",
    },
  ];

  return (
    <section className="bg-black py-20 md:py-32">
      <div className="container mx-auto px-6 md:px-8 lg:px-12">
        {/* Header */}
        <div className="text-center mb-16">
          {/* Badge */}
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-gray-700 bg-gray-900/50 backdrop-blur-sm mb-8">
            <span className="text-sm font-medium text-green-400">Feature</span>
          </div>

          {/* Heading */}
          <h2 className="text-4xl md:text-5xl lg:text-6xl font-bold text-white mb-6 leading-tight">
            The Hedera Advantage: Powering Your RWA DeFi Journey
          </h2>

          {/* Description */}
          <p className="text-lg md:text-xl text-gray-400 leading-relaxed max-w-4xl mx-auto mb-16">
            Unleash institutional-grade DeFi powered by Hedera&apos;s speed,
            security, and consensus finality.
          </p>
        </div>

        {/* Content Grid */}
        <div className="grid lg:grid-cols-2 gap-12 lg:gap-20 items-center">
          {/* Left - 3D Shape */}
          <div className="relative flex justify-center lg:justify-start">
            <div className="relative w-full max-w-lg aspect-square">
              {/* Background Glow Effects */}
              <div className="absolute inset-0 bg-gradient-to-br from-green-400 via-green-500 to-green-600 rounded-full opacity-20 blur-3xl animate-pulse" />

              {/* 3D Shape Image */}
              <div className="relative w-full h-full flex items-center justify-center">
                <img
                  src="/images/hero-3d-shape-alt.svg"
                  alt="3D Abstract Green Spiral Shape"
                  className="w-full h-full object-contain max-w-md lg:max-w-lg animate-float"
                />
              </div>

              {/* Additional Glow Effects */}
              <div className="absolute top-1/4 right-1/4 w-32 h-32 bg-green-500 rounded-full opacity-10 blur-2xl" />
              <div className="absolute bottom-1/4 left-1/4 w-24 h-24 bg-purple-500 rounded-full opacity-10 blur-xl" />
            </div>
          </div>

          {/* Right - Feature Cards */}
          <div className="space-y-6">
            {features.map((feature, index) => {
              const IconComponent = feature.icon;
              return (
                <div
                  key={index}
                  className="group p-6 rounded-2xl border border-gray-800 bg-gray-900/50 backdrop-blur-sm hover:bg-gray-800/50 transition-all duration-300"
                >
                  <div className="flex items-start gap-4">
                    {/* Icon */}
                    <div className="flex-shrink-0">
                      <div className="w-10 h-10 rounded-lg bg-green-500/10 flex items-center justify-center group-hover:bg-green-500/20 transition-colors duration-300">
                        <IconComponent className="w-5 h-5 text-green-400" />
                      </div>
                    </div>

                    {/* Content */}
                    <div className="space-y-3">
                      <h3 className="text-xl font-semibold text-white">
                        {feature.title}
                      </h3>
                      <p className="text-gray-400 leading-relaxed">
                        {feature.description}
                      </p>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>
    </section>
  );
}