import { Zap, ArrowRight } from "lucide-react"
import Link from "next/link"
import { Button } from "@/components/ui/button"

export default function Footer() {
  const quickLinks = [
    { name: "Home", href: "/" },
    { name: "Features", href: "/features" },
    { name: "Solutions", href: "/solutions" },
    { name: "Community", href: "/community" },
    { name: "Support", href: "/support" },
  ]

  const helpLinks = [
    { name: "Help Centre", href: "/help" },
    { name: "FAQ", href: "/faq" },
    { name: "Forum", href: "/forum" },
  ]

  const socialLinks = [
    { name: "Twitter", href: "#" },
    { name: "LinkedIn", href: "#" },
    { name: "Telegram", href: "#" },
    { name: "Discord", href: "#" },
  ]

  return (
    <footer className="bg-black text-white py-16 md:py-20">
      <div className="container mx-auto px-6 md:px-8 lg:px-12">
        <div className="grid lg:grid-cols-4 gap-8 md:gap-12">
          {/* Logo */}
          <div className="lg:col-span-5 text-center mb-12">
            <Link href="/" className="flex items-center justify-center space-x-3">
              <div className="flex h-12 w-12 items-center justify-center rounded-full bg-green-500">
                <Zap className="h-7 w-7 text-black" />
              </div>
              <span className="text-3xl font-semibold">HedVault</span>
            </Link>
          </div>

          {/* Quick Links */}
          

          {/* Help */}
          

          {/* Social Media */}
          

          {/* Newsletter */}
          
        </div>

        {/* Copyright */}
        <div className="mt-16 pt-8 border-t border-gray-800 text-center">
          <p className="text-gray-400">© 2025 HedVault. All rights reserved.</p>
        </div>
      </div>
    </footer>
  )
}