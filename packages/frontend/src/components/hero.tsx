"use client";
import { Button } from "@/components/ui/button";
import Link from "next/link";
import Image from "next/image";

export default function Hero() {
  return (
    <section className="relative min-h-screen bg-black text-white overflow-hidden">
      {/* Grid Pattern Background */}
      <div className="absolute inset-0 bg-[linear-gradient(rgba(255,255,255,0.02)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,0.02)_1px,transparent_1px)] bg-[size:50px_50px]" />

      <div className="relative z-10 container mx-auto px-6 md:px-8 lg:px-12 py-20 lg:py-32">
        <div className="grid lg:grid-cols-2 gap-12 lg:gap-20 items-center">
          {/* Left Content */}
          <div className="space-y-8">
            {/* Badge */}
            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-gray-700 bg-gray-900/50 backdrop-blur-sm">
              <div className="w-2 h-2 bg-green-500 rounded-full" />
              <span className="text-sm font-medium text-green-400">
                Decentralized | RWA-Powered
              </span>
            </div>

            {/* Heading */}
            <div className="space-y-4">
              <h1 className="text-5xl md:text-6xl lg:text-7xl font-bold leading-tight">
                Unlock the Power of Real-World Asset DeFi
              </h1>
            </div>

            {/* Description */}
            <p className="text-lg md:text-xl text-gray-400 leading-relaxed max-w-lg">
              Buy, Sell, Swap, Lend, and Borrow against tokenized real-world
              assets. HedVault provides secure, scalable, and decentralized
              solutions for fractional ownership and comprehensive DeFi
              opportunities on Hedera.
            </p>

            {/* CTA Buttons */}
            <div className="flex flex-col sm:flex-row gap-4">
              <Link href="/dashboard">
                <Button
                  size="lg"
                  className="bg-green-500 hover:bg-green-600 text-black font-semibold px-8 py-3 rounded-full text-base"
                >
                  Get Started
                </Button>
              </Link>
            </div>
          </div>

          {/* Right Visual */}
          <div className="relative flex justify-center lg:justify-end">
            <div className="relative w-full max-w-lg aspect-square">
              {/* Background Glow Effects */}
              <div className="absolute inset-0 bg-gradient-to-br from-green-400 via-green-500 to-green-600 rounded-full opacity-20 blur-3xl animate-pulse" />

              {/* 3D Shape Image */}
              <div className="relative w-full h-full flex items-center justify-center">
                <Image
                  src="/images/hero-3d-shape.svg"
                  alt="3D Abstract Green Spiral Shape"
                  width={500}
                  height={500}
                  className="w-full h-full object-contain max-w-md lg:max-w-lg animate-float"
                />
              </div>

              {/* Additional Glow Effects */}
              <div className="absolute top-1/4 right-1/4 w-32 h-32 bg-green-500 rounded-full opacity-10 blur-2xl" />
              <div className="absolute bottom-1/4 left-1/4 w-24 h-24 bg-purple-500 rounded-full opacity-10 blur-xl" />
            </div>
          </div>
        </div>
      </div>

      {/* Additional Background Elements */}
      <div className="absolute top-1/4 left-1/4 w-2 h-2 bg-green-500 rounded-full opacity-30" />
      <div className="absolute top-1/3 right-1/3 w-1 h-1 bg-green-400 rounded-full opacity-40" />
      <div className="absolute bottom-1/4 left-1/3 w-1.5 h-1.5 bg-green-300 rounded-full opacity-20" />
    </section>
  );
}
<style jsx>{`
  @keyframes float {
    0%,
    100% {
      transform: translateY(0px) rotate(0deg);
    }
    50% {
      transform: translateY(-10px) rotate(2deg);
    }
  }
  .animate-float {
    animation: float 6s ease-in-out infinite;
  }
`}</style>;
