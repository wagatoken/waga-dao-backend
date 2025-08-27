/**
 * Treasury Dashboard - Gold Treasury & Tokenomics
 * Streamlined view of financial metrics and token utilities
 */

"use client"

import { useState, useEffect } from "react"
import Link from "next/link"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import {
  Coffee,
  Coins,
  TrendingUp,
  DollarSign,
  Shield,
  Users,
  Target,
  ArrowLeft,
  Zap,
  Lock,
  Vote,
  Gem
} from "lucide-react"

interface TreasuryMetrics {
  totalValue: number
  paxgBalance: number
  usdcBalance: number
  vertCirculating: number
  apy: number
  participants: number
}

export default function Treasury() {
  const [metrics, setMetrics] = useState<TreasuryMetrics>({
    totalValue: 30000000,
    paxgBalance: 18000000,
    usdcBalance: 12000000,
    vertCirculating: 5000000,
    apy: 12.5,
    participants: 2840
  })

  // Simulate real-time treasury updates
  useEffect(() => {
    const interval = setInterval(() => {
      setMetrics(prev => ({
        ...prev,
        totalValue: prev.totalValue + Math.random() * 10000,
        vertCirculating: prev.vertCirculating + Math.random() * 1000
      }))
    }, 5000)

    return () => clearInterval(interval)
  }, [])

  const tokenUtilities = [
    {
      icon: Vote,
      title: "Governance Rights",
      description: "Vote on grant allocations and DAO proposals",
      color: "from-purple-500 to-violet-600"
    },
    {
      icon: Zap,
      title: "Staking Rewards",
      description: "Earn additional VERT through staking mechanisms",
      color: "from-amber-500 to-orange-600"
    },
    {
      icon: Shield,
      title: "Treasury Access",
      description: "Priority access to new treasury opportunities",
      color: "from-blue-500 to-indigo-600"
    },
    {
      icon: Target,
      title: "Grant Validation",
      description: "Participate in milestone validation processes",
      color: "from-green-500 to-emerald-600"
    }
  ]

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-amber-900 to-yellow-900">
      {/* Navigation */}
      <nav className="fixed top-0 w-full z-50 bg-black/20 backdrop-blur-xl border-b border-white/10">
        <div className="container mx-auto px-6 py-4">
          <div className="flex items-center justify-center relative">
            {/* Logo - Left Side */}
            <div className="absolute left-0">
              <Link href="/" className="flex items-center space-x-3 group">
                <div className="relative">
                  <div className="w-10 h-10 bg-gradient-to-br from-amber-400 to-green-500 rounded-2xl flex items-center justify-center transition-all duration-300 group-hover:scale-110">
                    <Coffee className="h-6 w-6 text-white" />
                  </div>
                  <div className="absolute inset-0 bg-gradient-to-br from-amber-400 to-green-500 rounded-2xl blur-md opacity-50"></div>
                </div>
                <span className="text-2xl font-bold text-white">WAGA DAO</span>
              </Link>
            </div>

            {/* Centered Navigation */}
            <div className="hidden lg:flex items-center space-x-8">
              <Link href="/" className="text-white/80 hover:text-white transition-colors text-sm font-medium relative group">
                Home
                <div className="absolute bottom-0 left-0 w-0 h-0.5 bg-gradient-to-r from-amber-400 to-green-500 group-hover:w-full transition-all duration-300"></div>
              </Link>
              <Link href="/how-it-works" className="text-white/80 hover:text-white transition-colors text-sm font-medium relative group">
                How It Works
                <div className="absolute bottom-0 left-0 w-0 h-0.5 bg-gradient-to-r from-amber-400 to-green-500 group-hover:w-full transition-all duration-300"></div>
              </Link>
              <Link href="/grants" className="text-white/80 hover:text-white transition-colors text-sm font-medium relative group">
                Dashboard
                <div className="absolute bottom-0 left-0 w-0 h-0.5 bg-gradient-to-r from-amber-400 to-green-500 group-hover:w-full transition-all duration-300"></div>
              </Link>
              <span className="text-white font-medium text-sm relative">
                Treasury
                <div className="absolute bottom-0 left-0 w-full h-0.5 bg-gradient-to-r from-amber-400 to-green-500"></div>
              </span>
              <Link href="/about" className="text-white/80 hover:text-white transition-colors text-sm font-medium relative group">
                About
                <div className="absolute bottom-0 left-0 w-0 h-0.5 bg-gradient-to-r from-amber-400 to-green-500 group-hover:w-full transition-all duration-300"></div>
              </Link>
            </div>

            {/* Back Button - Right Side */}
            <div className="absolute right-0">
              <Link href="/">
                <Button variant="outline" className="border-white/20 text-gray-900 hover:bg-white/10 hover:text-gray-800">
                  <ArrowLeft className="mr-2 h-4 w-4" />
                  Back
                </Button>
              </Link>
            </div>
          </div>
        </div>
      </nav>

      {/* Treasury Overview */}
      <section className="pt-24 pb-12 px-6">
        <div className="container mx-auto max-w-7xl">
          <div className="text-center mb-12">
            <Badge className="mb-4 bg-amber-500/10 text-amber-400 border-amber-500/20">
              <Gem className="w-4 h-4 mr-2" />
              Gold-Backed Treasury
            </Badge>
            <h1 className="text-5xl font-bold text-white mb-4">
              Treasury Dashboard
            </h1>
            <p className="text-xl text-white/70 max-w-2xl mx-auto">
              $30M gold treasury backing regenerative coffee development
            </p>
          </div>

          {/* Treasury Metrics */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-16">
            <Card className="bg-black/20 backdrop-blur-xl border-white/10 hover:border-amber-500/30 transition-all duration-300">
              <CardContent className="p-6">
                <div className="flex items-center justify-between mb-4">
                  <DollarSign className="w-8 h-8 text-amber-400" />
                  <Badge className="bg-green-500/10 text-green-400 border-green-500/20">Live</Badge>
                </div>
                <div className="text-3xl font-bold text-white mb-2">
                  ${(metrics.totalValue / 1000000).toFixed(1)}M
                </div>
                <div className="text-white/60">Total Treasury Value</div>
                <div className="text-green-400 text-sm mt-2">+2.4% today</div>
              </CardContent>
            </Card>

            <Card className="bg-black/20 backdrop-blur-xl border-white/10 hover:border-yellow-500/30 transition-all duration-300">
              <CardContent className="p-6">
                <div className="flex items-center justify-between mb-4">
                  <Gem className="w-8 h-8 text-yellow-400" />
                  <span className="text-yellow-400 text-sm">PAXG</span>
                </div>
                <div className="text-3xl font-bold text-white mb-2">
                  ${(metrics.paxgBalance / 1000000).toFixed(1)}M
                </div>
                <div className="text-white/60">Paxos Gold</div>
                <Progress value={60} className="mt-2 h-1 bg-white/10" />
              </CardContent>
            </Card>

            <Card className="bg-black/20 backdrop-blur-xl border-white/10 hover:border-green-500/30 transition-all duration-300">
              <CardContent className="p-6">
                <div className="flex items-center justify-between mb-4">
                  <DollarSign className="w-8 h-8 text-green-400" />
                  <span className="text-green-400 text-sm">USDC</span>
                </div>
                <div className="text-3xl font-bold text-white mb-2">
                  ${(metrics.usdcBalance / 1000000).toFixed(1)}M
                </div>
                <div className="text-white/60">USDC Reserve</div>
                <Progress value={40} className="mt-2 h-1 bg-white/10" />
              </CardContent>
            </Card>

            <Card className="bg-black/20 backdrop-blur-xl border-white/10 hover:border-green-500/30 transition-all duration-300">
              <CardContent className="p-6">
                <div className="flex items-center justify-between mb-4">
                  <TrendingUp className="w-8 h-8 text-green-400" />
                  <Badge className="bg-green-500/10 text-green-400 border-green-500/20">{metrics.apy}% APY</Badge>
                </div>
                <div className="text-3xl font-bold text-white mb-2">
                  {(metrics.vertCirculating / 1000000).toFixed(1)}M
                </div>
                <div className="text-white/60">VERT Circulating</div>
                <div className="text-green-400 text-sm mt-2">+{metrics.participants} holders</div>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Token Utilities */}
      <section className="px-6 pb-12">
        <div className="container mx-auto max-w-7xl">
          <div className="text-center mb-12">
            <h2 className="text-4xl font-bold text-white mb-4">VERT Token Utilities</h2>
            <p className="text-white/70 text-lg">Governance and utility token for the WAGA ecosystem</p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6 mb-16">
            {tokenUtilities.map((utility, index) => {
              const IconComponent = utility.icon
              return (
                <Card
                  key={index}
                  className="group bg-black/20 backdrop-blur-xl border-white/10 hover:border-white/30 transition-all duration-500 hover:scale-105"
                >
                  <CardContent className="p-6 text-center">
                    <div className="relative mx-auto mb-4">
                      <div className={`w-12 h-12 bg-gradient-to-br ${utility.color} rounded-2xl flex items-center justify-center group-hover:scale-110 transition-transform duration-300`}>
                        <IconComponent className="h-6 w-6 text-white" />
                      </div>
                      <div className={`absolute inset-0 bg-gradient-to-br ${utility.color} rounded-2xl blur-lg opacity-50 group-hover:opacity-75 transition-opacity`}></div>
                    </div>
                    <h3 className="text-lg font-bold text-white mb-2">{utility.title}</h3>
                    <p className="text-white/60 text-sm">{utility.description}</p>
                  </CardContent>
                </Card>
              )
            })}
          </div>

          {/* Contribution CTA */}
          <Card className="bg-black/40 backdrop-blur-xl border-amber-500/30">
            <CardContent className="p-8 text-center">
              <div className="flex items-center justify-center mb-6">
                <div className="w-16 h-16 bg-gradient-to-br from-amber-400 to-yellow-500 rounded-3xl flex items-center justify-center">
                  <Coins className="h-8 w-8 text-white" />
                </div>
              </div>
              <h3 className="text-3xl font-bold text-white mb-4">Contribute to Treasury</h3>
              <p className="text-white text-lg mb-8 max-w-2xl mx-auto">
                Support regenerative coffee farming by contributing PAXG, ETH, or USDC to our treasury and earn VERT governance tokens
              </p>
              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <Button size="lg" className="bg-gradient-to-r from-amber-500 to-yellow-600 hover:from-amber-600 hover:to-yellow-700 text-white px-8 py-4">
                  <Coins className="mr-2 h-5 w-5" />
                  Contribute PAXG
                </Button>
                <Button size="lg" className="bg-gradient-to-r from-blue-500 to-indigo-600 hover:from-blue-600 hover:to-indigo-700 text-white px-8 py-4">
                  <Gem className="mr-2 h-5 w-5" />
                  Contribute ETH
                </Button>
                <Button size="lg" className="bg-gradient-to-r from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700 text-white px-8 py-4">
                  <DollarSign className="mr-2 h-5 w-5" />
                  Contribute USDC
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>
      </section>

      {/* Treasury Allocation */}
      <section className="px-6 pb-20">
        <div className="container mx-auto max-w-7xl">
          <div className="grid md:grid-cols-2 gap-8">
            <Card className="bg-black/20 backdrop-blur-xl border-white/10">
              <CardHeader>
                <CardTitle className="text-white flex items-center">
                  <Target className="mr-2 h-5 w-5 text-green-400" />
                  Treasury Allocation
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-3">
                  <div className="flex justify-between items-center">
                    <span className="text-white/70">Grant Funding</span>
                    <span className="text-white font-medium">60%</span>
                  </div>
                  <Progress value={60} className="h-2 bg-white/10" />
                  
                  <div className="flex justify-between items-center">
                    <span className="text-white/70">Operations</span>
                    <span className="text-white font-medium">25%</span>
                  </div>
                  <Progress value={25} className="h-2 bg-white/10" />
                  
                  <div className="flex justify-between items-center">
                    <span className="text-white/70">Reserve</span>
                    <span className="text-white font-medium">15%</span>
                  </div>
                  <Progress value={15} className="h-2 bg-white/10" />
                </div>
              </CardContent>
            </Card>

            <Card className="bg-black/20 backdrop-blur-xl border-white/10">
              <CardHeader>
                <CardTitle className="text-white flex items-center">
                  <Lock className="mr-2 h-5 w-5 text-blue-400" />
                  Security & Governance
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-4">
                  <div className="flex items-center justify-between p-3 bg-white/5 rounded-lg">
                    <span className="text-white/70">Multi-sig Security</span>
                    <Badge className="bg-green-500/10 text-green-400 border-green-500/20">Active</Badge>
                  </div>
                  
                  <div className="flex items-center justify-between p-3 bg-white/5 rounded-lg">
                    <span className="text-white/70">DAO Governance</span>
                    <Badge className="bg-purple-500/10 text-purple-400 border-purple-500/20">Live</Badge>
                  </div>
                  
                  <div className="flex items-center justify-between p-3 bg-white/5 rounded-lg">
                    <span className="text-white/70">Audit Status</span>
                    <Badge className="bg-blue-500/10 text-blue-400 border-blue-500/20">Verified</Badge>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>
    </div>
  )
}
