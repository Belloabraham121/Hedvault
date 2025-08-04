import { Waves, Sparkles, Zap, Plus, Target } from "lucide-react"

export default function Partners() {
  const partners = [
    {
      name: "Logoipsum",
      icon: Waves,
    },
    {
      name: "Logoipsum",
      icon: Sparkles,
    },
    {
      name: "Logoipsum",
      icon: Zap,
    },
    {
      name: "Logoipsum",
      icon: Plus,
    },
    {
      name: "Logoipsum",
      icon: Target,
    },
  ]

  return (
    <section className="bg-black py-16 md:py-20">
      <div className="container mx-auto px-6 md:px-8 lg:px-12">
        {/* Section Title */}
        <div className="text-center mb-12">
          <h2 className="text-lg md:text-xl text-gray-400 font-medium">Trusted by Leading Innovators</h2>
        </div>

        {/* Partners Grid */}
        <div className="flex flex-wrap justify-center items-center gap-8 md:gap-12 lg:gap-16">
          {partners.map((partner, index) => {
            const IconComponent = partner.icon
            return (
              <div
                key={index}
                className="flex items-center gap-3 text-gray-400 hover:text-gray-300 transition-colors duration-300"
              >
                <IconComponent className="w-6 h-6 md:w-7 md:h-7" />
                <span className="text-lg md:text-xl font-medium">{partner.name}</span>
              </div>
            )
          })}
        </div>
      </div>
    </section>
  )
}