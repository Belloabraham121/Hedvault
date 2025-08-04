"use client"

import { Button } from "@/components/ui/button"

interface SwapInputProps {
  label: string
  placeholder?: string
  value?: string
  onValueChange?: (value: string) => void
  selectedAsset?: string
  onAssetSelect?: () => void
  className?: string
}

export function SwapInput({
  label,
  placeholder = "0.00",
  value,
  onValueChange,
  selectedAsset = "Select Asset",
  onAssetSelect,
  className,
}: SwapInputProps) {
  return (
    <div className={`p-4 rounded-lg bg-gray-800/50 ${className || ""}`}>
      <label className="text-sm text-gray-400 mb-2 block">{label}</label>
      <div className="flex items-center justify-between">
        <input
          type="text"
          placeholder={placeholder}
          value={value}
          onChange={(e) => onValueChange?.(e.target.value)}
          className="bg-transparent text-2xl text-white outline-none flex-1"
        />
        <Button variant="outline" className="border-gray-700 text-white bg-transparent" onClick={onAssetSelect}>
          {selectedAsset}
        </Button>
      </div>
    </div>
  )
}
