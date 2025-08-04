import { ChevronDown } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"

export function BuySellTab() {
  return (
    <div className="space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <Card className="bg-gray-950/80 border-gray-800">
          <CardHeader>
            <CardTitle className="text-white">Buy Assets</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div className="p-4 rounded-lg bg-gray-900/70">
                <label className="text-sm text-gray-400 mb-2 block">Asset</label>
                <Button variant="outline" className="w-full border-gray-700 text-white justify-between bg-transparent">
                  Select Asset <ChevronDown className="h-4 w-4" />
                </Button>
              </div>
              <div className="p-4 rounded-lg bg-gray-900/70">
                <label className="text-sm text-gray-400 mb-2 block">Amount (USD)</label>
                <input
                  type="text"
                  placeholder="0.00"
                  className="w-full bg-transparent text-white outline-none text-lg"
                />
              </div>
              <Button className="w-full bg-green-500 hover:bg-green-600 text-black">Buy Asset</Button>
            </div>
          </CardContent>
        </Card>

        <Card className="bg-gray-950/80 border-gray-800">
          <CardHeader>
            <CardTitle className="text-white">Sell Assets</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div className="p-4 rounded-lg bg-gray-900/70">
                <label className="text-sm text-gray-400 mb-2 block">Asset</label>
                <Button variant="outline" className="w-full border-gray-700 text-white justify-between bg-transparent">
                  Select Asset <ChevronDown className="h-4 w-4" />
                </Button>
              </div>
              <div className="p-4 rounded-lg bg-gray-900/70">
                <label className="text-sm text-gray-400 mb-2 block">Amount</label>
                <input
                  type="text"
                  placeholder="0.00"
                  className="w-full bg-transparent text-white outline-none text-lg"
                />
              </div>
              <Button className="w-full bg-red-500 hover:bg-red-600 text-white">Sell Asset</Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
