import type React from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"

interface PortfolioCardProps {
  title: string
  value: string
  change?: string
  changeType?: "positive" | "negative" | "neutral"
  children?: React.ReactNode
  className?: string
}

export function PortfolioCard({
  title,
  value,
  change,
  changeType = "neutral",
  children,
  className = "",
}: PortfolioCardProps) {
  const getChangeColor = () => {
    switch (changeType) {
      case "positive":
        return "text-green-400"
      case "negative":
        return "text-red-400"
      default:
        return "text-gray-400"
    }
  }

  return (
    <Card
      className={`bg-gray-950/80 backdrop-blur-sm border-gray-800 hover:bg-gray-950/90 transition-all duration-200 ${className}`}
    >
      <CardHeader className="pb-4">
        <CardTitle className="text-sm font-medium text-gray-400 uppercase tracking-wide">{title}</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="flex items-center justify-between">
          <div className="text-3xl font-bold text-white">{value}</div>
          {children}
        </div>
        {change && <p className={`text-sm mt-2 font-medium ${getChangeColor()}`}>{change}</p>}
      </CardContent>
    </Card>
  )
}
