import { Button } from "@/components/ui/button"
import Link from "next/link"

export default function CTASection() {
  return (
    <section className="bg-black py-20 md:py-32">
      <div className="container mx-auto px-6 md:px-8 lg:px-12 text-center">
        {/* Badge */}
        <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-gray-700 bg-gray-900/50 backdrop-blur-sm mb-8">
          <span className="text-sm font-medium text-green-400">Revolutionary</span>
        </div>

        {/* Heading */}
        <h2 className="text-4xl md:text-5xl lg:text-6xl font-bold text-white mb-6 leading-tight max-w-4xl mx-auto">
          Start Building Your Future with Real-World Assets
        </h2>

        {/* Description */}
        <p className="text-lg md:text-xl text-gray-400 leading-relaxed max-w-3xl mx-auto mb-12">
          Join a thriving community of investors and asset owners leveraging the power of tokenized real-world assets.
          Empower your financial journey with transparency, security, and unparalleled opportunities.
        </p>

        {/* CTA Button */}
        <Link href="/dashboard">
          <Button size="lg" className="bg-green-500 hover:bg-green-600 text-black font-semibold px-8 py-3 text-base">
            Get Started
          </Button>
        </Link>
      </div>
    </section>
  )
}