"use client"

import { Vault } from "lucide-react"
import Link from "next/link"
import { Button } from "@/components/ui/button"

export default function Component() {
  return (
    <header className="w-full bg-black text-white">
      <div className="flex h-16 items-center justify-between px-6 md:px-8 lg:px-12">
        {/* Logo */}
        <Link href="/" className="flex items-center space-x-2 cursor-pointer">
          <div className="flex h-8 w-8 items-center justify-center rounded-full bg-green-500">
            <Vault className="h-5 w-5 text-black" />
          </div>
          <span className="text-xl font-semibold">HedVault</span>
        </Link>

        {/* Navigation Links */}
        <nav className="hidden md:flex items-center space-x-8">
          <Link href="/" className="text-white hover:text-green-400 transition-colors font-medium cursor-pointer">
            Home
          </Link>
          <Link href="/features" className="text-gray-300 hover:text-green-400 transition-colors font-medium cursor-pointer">
            Features
          </Link>
          <Link href="/solutions" className="text-gray-300 hover:text-green-400 transition-colors font-medium cursor-pointer">
            Solutions
          </Link>
          <Link href="/faq" className="text-gray-300 hover:text-green-400 transition-colors font-medium cursor-pointer">
            FAQ
          </Link>
        </nav>

        {/* Action Buttons */}
        <div className="flex items-center space-x-4">
          <Link href="/dashboard">
            <Button className="bg-green-500 hover:bg-green-600 text-black font-semibold px-6 rounded-full">
              Launch App
            </Button>
          </Link>
        </div>
      </div>
    </header>
  )
}