"use client";

import { useState } from "react";
import { ArrowLeftRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { SwapInput } from "../ui/swap-input";

export function SwapTab() {
  const [fromValue, setFromValue] = useState("");
  const [toValue, setToValue] = useState("");

  return (
    <div className="space-y-6">
      <Card className="bg-gray-950/80 border-gray-800">
        <CardHeader>
          <CardTitle className="text-white">Swap Assets</CardTitle>
          <p className="text-gray-400">
            Exchange between different tokenized real-world assets
          </p>
        </CardHeader>
        <CardContent>
          <div className="space-y-6">
            <div className="space-y-4">
              <SwapInput
                label="From"
                value={fromValue}
                onValueChange={setFromValue}
                onAssetSelect={() => console.log("Select from asset")}
                className="bg-gray-900/70"
              />

              <div className="flex justify-center">
                <Button
                  variant="ghost"
                  size="sm"
                  className="rounded-full bg-gray-800 hover:bg-gray-700"
                >
                  <ArrowLeftRight className="h-4 w-4 text-green-400" />
                </Button>
              </div>

              <SwapInput
                label="To"
                value={toValue}
                onValueChange={setToValue}
                onAssetSelect={() => console.log("Select to asset")}
                className="bg-gray-900/70"
              />
            </div>

            <Button className="w-full bg-green-500 hover:bg-green-600 text-black">
              Connect Wallet to Swap
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
