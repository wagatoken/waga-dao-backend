"use client"

import { useState } from "react"
import { Card, CardContent } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Progress } from "@/components/ui/progress"
import {
  Coffee,
  Globe,
  Linkedin,
  MessageCircle,
  Twitter,
  Users,
  TrendingUp,
  Shield,
  Vote,
  Package,
  Target,
  Zap,
  ArrowLeft,
  Menu,
  X,
} from "lucide-react"
import Link from "next/link"

export default function TokenomicsPage() {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false)

  return (
    <div className="min-h-screen bg-gradient-to-br from-amber-50 via-green-50 to-emerald-100 overflow-x-hidden">
      {/* Floating Background Elements */}
      <div className="fixed inset-0 pointer-events-none">
        <div className="absolute top-20 left-10 w-32 h-32 bg-gradient-to-br from-amber-200/20 to-green-200/20 rounded-full blur-xl animate-pulse"></div>
        <div className="absolute top-40 right-20 w-24 h-24 bg-gradient-to-br from-green-200/20 to-emerald-200/20 rounded-full blur-xl animate-pulse delay-1000"></div>
        <div className="absolute bottom-40 left-20 w-40 h-40 bg-gradient-to-br from-emerald-200/20 to-amber-200/20 rounded-full blur-xl animate-pulse delay-2000"></div>
        <div className="absolute bottom-20 right-10 w-28 h-28 bg-gradient-to-br from-amber-200/20 to-green-200/20 rounded-full blur-xl animate-pulse delay-500"></div>
      </div>

      {/* Navigation */}
      <nav className="fixed top-0 w-full z-50 bg-gradient-to-r from-green-800 to-emerald-900 backdrop-blur-md border-b border-emerald-700/50 transition-all duration-300">
        <div className="container mx-auto px-6 py-4 flex items-center justify-between">
          <Link href="/" className="flex items-center space-x-3 group">
            <div className="w-10 h-10 bg-gradient-to-br from-amber-400 to-green-500 rounded-xl flex items-center justify-center transition-transform duration-300 group-hover:scale-110 group-hover:rotate-12">
              <Coffee className="h-6 w-6 text-white" />
            </div>
            <span className="text-2xl font-bold text-white">WAGA DAO</span>
          </Link>

          {/* Desktop Navigation */}
          <div className="hidden lg:flex items-center space-x-8">
            <Link
              href="/about"
              className="text-white hover:text-amber-300 transition-colors duration-300 text-sm font-medium"
            >
              About
            </Link>
            <Link
              href="/how-it-works"
              className="text-white hover:text-amber-300 transition-colors duration-300 text-sm font-medium"
            >
              How It Works
            </Link>
            <Link
              href="/tokenomics"
              className="text-white hover:text-amber-300 transition-colors duration-300 text-sm font-medium"
            >
              Tokenomics
            </Link>
            <Link
              href="/locations"
              className="text-white hover:text-amber-300 transition-colors duration-300 text-sm font-medium"
            >
              Locations
            </Link>
            <Link
              href="/technology"
              className="text-white hover:text-amber-300 transition-colors duration-300 text-sm font-medium"
            >
              Technology
            </Link>
            <Link
              href="/roadmap"
              className="text-white hover:text-amber-300 transition-colors duration-300 text-sm font-medium"
            >
              Roadmap
            </Link>
            <Link
              href="/coffee"
              className="text-white hover:text-amber-300 transition-colors duration-300 text-sm font-medium"
            >
              Coffee
            </Link>
            <Link
              href="/get-involved"
              className="text-white hover:text-amber-300 transition-colors duration-300 text-sm font-medium"
            >
              Get Involved
            </Link>
          </div>

          <div className="flex items-center space-x-4">
            <Link href="/">
              <Button
                variant="outline"
                className="bg-transparent border-amber-400/30 text-white hover:bg-amber-500/20 hover:text-amber-300 transition-all duration-300"
              >
                <ArrowLeft className="mr-2 h-4 w-4" />
                Go Back
              </Button>
            </Link>

            {/* Mobile Menu Button */}
            <Button
              variant="ghost"
              size="sm"
              className="lg:hidden text-white hover:text-amber-300"
              onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
            >
              {isMobileMenuOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
            </Button>
          </div>
        </div>

        {/* Mobile Navigation */}
        {isMobileMenuOpen && (
          <div className="lg:hidden bg-gradient-to-r from-green-800 to-emerald-900 border-t border-emerald-700/50">
            <div className="container mx-auto px-6 py-4 space-y-2">
              <Link
                href="/about"
                className="block text-white hover:text-amber-300 transition-colors duration-300 py-2 text-sm font-medium"
                onClick={() => setIsMobileMenuOpen(false)}
              >
                About
              </Link>
              <Link
                href="/how-it-works"
                className="block text-white hover:text-amber-300 transition-colors duration-300 py-2 text-sm font-medium"
                onClick={() => setIsMobileMenuOpen(false)}
              >
                How It Works
              </Link>
              <Link
                href="/tokenomics"
                className="block text-white hover:text-amber-300 transition-colors duration-300 py-2 text-sm font-medium"
                onClick={() => setIsMobileMenuOpen(false)}
              >
                Tokenomics
              </Link>
              <Link
                href="/locations"
                className="block text-white hover:text-amber-300 transition-colors duration-300 py-2 text-sm font-medium"
                onClick={() => setIsMobileMenuOpen(false)}
              >
                Locations
              </Link>
              <Link
                href="/technology"
                className="block text-white hover:text-amber-300 transition-colors duration-300 py-2 text-sm font-medium"
                onClick={() => setIsMobileMenuOpen(false)}
              >
                Technology
              </Link>
              <Link
                href="/roadmap"
                className="block text-white hover:text-amber-300 transition-colors duration-300 py-2 text-sm font-medium"
                onClick={() => setIsMobileMenuOpen(false)}
              >
                Roadmap
              </Link>
              <Link
                href="/coffee"
                className="block text-white hover:text-amber-300 transition-colors duration-300 py-2 text-sm font-medium"
                onClick={() => setIsMobileMenuOpen(false)}
              >
                Coffee
              </Link>
              <Link
                href="/get-involved"
                className="block text-white hover:text-amber-300 transition-colors duration-300 py-2 text-sm font-medium"
                onClick={() => setIsMobileMenuOpen(false)}
              >
                Get Involved
              </Link>
            </div>
          </div>
        )}
      </nav>

      {/* Hero Section */}
      <section className="pt-32 pb-20 px-6 relative">
        <div className="container mx-auto text-center max-w-4xl">
          <Badge className="mb-6 bg-gradient-to-r from-green-100 to-emerald-100 text-green-800 border border-green-300/50 px-4 py-2 text-sm shadow-lg">
            💰 Tokenomics
          </Badge>

          <h1 className="text-5xl md:text-6xl font-bold mb-8 bg-gradient-to-r from-amber-700 via-green-700 to-emerald-800 bg-clip-text text-transparent leading-tight">
            Token Economics & Governance
          </h1>

          <p className="text-xl text-gray-700 mb-12 max-w-3xl mx-auto leading-relaxed">
            Acquire VERT governance tokens by contributing PAXG/XAUT or fiat (converted to gold tokens) to build our
            $30M gold treasury. This gold reserve enables sustainable USDC grants to cooperatives through milestone-based disbursement, providing
            stable, long-term funding without token price volatility. Launching September 2025.
          </p>
        </div>
      </section>

      {/* Token Overview */}
      <section className="py-20 px-6 bg-gradient-to-br from-white/60 via-green-50/60 to-emerald-100/80 relative">
        <div className="absolute inset-0 bg-gradient-to-r from-green-800/5 to-emerald-900/5"></div>
        <div className="container mx-auto max-w-6xl relative">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4 bg-gradient-to-r from-amber-700 to-green-700 bg-clip-text text-transparent">
              Dual Token System
            </h2>
            <p className="text-xl text-gray-600">Governance and utility tokens working together</p>
          </div>

          <div className="grid md:grid-cols-2 gap-12">
            <Card className="bg-white/80 backdrop-blur-sm border-amber-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:rotate-1 group">
              <CardContent className="p-8">
                <div className="w-16 h-16 bg-gradient-to-br from-amber-400 to-amber-600 rounded-2xl flex items-center justify-center mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Vote className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-3xl font-bold text-amber-700 mb-6">VERT Governance Token</h3>
                <p className="text-gray-600 mb-4 text-sm italic">
                  Vertical Integration Token - representing integrated agribusiness governance
                </p>
                <ul className="space-y-3 text-gray-700">
                  <li className="flex items-center">
                    <Shield className="h-4 w-4 text-amber-600 mr-3" />
                    DAO voting rights and proposals
                  </li>
                  <li className="flex items-center">
                    <Users className="h-4 w-4 text-amber-600 mr-3" />
                    Community treasury management
                  </li>
                  <li className="flex items-center">
                    <Target className="h-4 w-4 text-amber-600 mr-3" />
                    Strategic partnership decisions
                  </li>
                  <li className="flex items-center">
                    <TrendingUp className="h-4 w-4 text-amber-600 mr-3" />
                    Impact-based influence growth
                  </li>
                </ul>
                <div className="mt-4 p-3 bg-amber-50 rounded-lg">
                  <p className="text-xs text-amber-800">
                    <strong>Non-Speculative:</strong> VERT tokens are not investments. Value reflects verified impact
                    and DAO influence only.
                  </p>
                </div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-green-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:-rotate-1 group">
              <CardContent className="p-8">
                <div className="w-16 h-16 bg-gradient-to-br from-green-400 to-green-600 rounded-2xl flex items-center justify-center mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Package className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-3xl font-bold text-green-700 mb-6">Inventory Tokens (ERC-1155)</h3>
                <p className="text-gray-600 mb-4 text-sm italic">
                  Representing tokenized coffee batches for supply chain management
                </p>
                <ul className="space-y-3 text-gray-700">
                  <li className="flex items-center">
                    <Coffee className="h-4 w-4 text-green-600 mr-3" />
                    Represent finished coffee batch ownership
                  </li>
                  <li className="flex items-center">
                    <Zap className="h-4 w-4 text-green-600 mr-3" />
                    Enable supply chain tracking
                  </li>
                  <li className="flex items-center">
                    <Shield className="h-4 w-4 text-green-600 mr-3" />
                    Facilitate quality verification
                  </li>
                  <li className="flex items-center">
                    <TrendingUp className="h-4 w-4 text-green-600 mr-3" />
                    Support automated settlements
                  </li>
                </ul>
                <div className="mt-4 p-3 bg-green-50 rounded-lg">
                  <p className="text-xs text-green-800">
                    <strong>Utility Only:</strong> Minted only to cover DAO grant values to cooperatives for inventory
                    management.
                  </p>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* VERT Acquisition & Gold Reserve Advantage */}
      <section className="py-20 px-6">
        <div className="container mx-auto max-w-6xl">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4 bg-gradient-to-r from-amber-700 to-green-700 bg-clip-text text-transparent">
              VERT Token Acquisition
            </h2>
            <p className="text-xl text-gray-600">How to join the DAO and why gold reserves matter</p>
          </div>

          <div className="grid md:grid-cols-2 gap-12 items-center">
            <Card className="bg-white/80 backdrop-blur-sm border-amber-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:scale-105">
              <CardContent className="p-8">
                <div className="w-16 h-16 bg-gradient-to-br from-amber-400 to-amber-600 rounded-2xl flex items-center justify-center mb-6 transition-all duration-300 hover:scale-110">
                  <Vote className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-amber-700 mb-4">How to Get VERT Tokens</h3>
                <ul className="space-y-3 text-gray-700">
                  <li className="flex items-center">
                    <Shield className="h-4 w-4 text-amber-600 mr-3" />
                    Contribute PAXG or XAUT directly to DAO treasury
                  </li>
                  <li className="flex items-center">
                    <TrendingUp className="h-4 w-4 text-amber-600 mr-3" />
                    Send fiat (USD/EUR) - automatically converted to PAXG
                  </li>
                  <li className="flex items-center">
                    <Users className="h-4 w-4 text-amber-600 mr-3" />
                    Receive VERT tokens proportional to contribution
                  </li>
                  <li className="flex items-center">
                    <Target className="h-4 w-4 text-amber-600 mr-3" />
                    Gain voting rights in DAO governance
                  </li>
                </ul>
                <div className="mt-4 p-3 bg-amber-50 rounded-lg">
                  <p className="text-xs text-amber-800">
                    <strong>Direct Exchange:</strong> Your gold contribution = VERT tokens + DAO membership
                  </p>
                </div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-green-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:scale-105">
              <CardContent className="p-8">
                <div className="w-16 h-16 bg-gradient-to-br from-green-400 to-green-600 rounded-2xl flex items-center justify-center mb-6 transition-all duration-300 hover:scale-110">
                  <Shield className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-green-700 mb-4">Gold Reserve Advantages</h3>
                <ul className="space-y-3 text-gray-700">
                  <li className="flex items-center">
                    <Shield className="h-4 w-4 text-green-600 mr-3" />
                    <span>
                      <strong>Stable Collateral:</strong> Gold doesn't crash like crypto
                    </span>
                  </li>
                  <li className="flex items-center">
                    <TrendingUp className="h-4 w-4 text-green-600 mr-3" />
                    <span>
                      <strong>Sustainable Grants:</strong> Reusable treasury for multiple grant cycles
                    </span>
                  </li>
                  <li className="flex items-center">
                    <Users className="h-4 w-4 text-green-600 mr-3" />
                    <span>
                      <strong>No Liquidation Risk:</strong> Gold maintains value during market crashes
                    </span>
                  </li>
                  <li className="flex items-center">
                    <Target className="h-4 w-4 text-green-600 mr-3" />
                    <span>
                      <strong>Long-term Focus:</strong> Enables patient capital for agriculture
                    </span>
                  </li>
                </ul>
                <div className="mt-4 p-3 bg-green-50 rounded-lg">
                  <p className="text-xs text-green-800">
                    <strong>vs. Crypto Collateral:</strong> No volatility risk, no forced liquidations, sustainable
                    funding
                  </p>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Fund Allocation */}
      <section className="py-20 px-6">
        <div className="container mx-auto max-w-6xl">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4 bg-gradient-to-r from-amber-700 to-green-700 bg-clip-text text-transparent">
              Gold-Backed USDC Deployment
            </h2>
            <p className="text-xl text-gray-600">
              DAO's $30M gold treasury enables $19.5M USDC grants through milestone-based disbursement - allocated as follows:
            </p>
          </div>

          <div className="grid md:grid-cols-2 gap-12 items-center">
            <div className="space-y-6">
              <Card className="bg-white/80 backdrop-blur-sm border-green-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:scale-105 group">
                <CardContent className="p-6">
                  <div className="flex items-center justify-between mb-3">
                    <span className="font-semibold text-green-700">Cooperative Development</span>
                    <span className="text-2xl font-bold text-green-600">70%</span>
                  </div>
                  <Progress value={70} className="h-3 mb-2" />
                  <p className="text-sm text-gray-600">
                    Direct USDC grants to farmers for infrastructure and operations ($13.65M)
                  </p>
                </CardContent>
              </Card>

              <Card className="bg-white/80 backdrop-blur-sm border-emerald-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:scale-105 group">
                <CardContent className="p-6">
                  <div className="flex items-center justify-between mb-3">
                    <span className="font-semibold text-emerald-700">DAO USDC Treasury</span>
                    <span className="text-2xl font-bold text-emerald-600">20%</span>
                  </div>
                  <Progress value={20} className="h-3 mb-2" />
                  <p className="text-sm text-gray-600">Emergency reserves and future expansion funding ($3.9M)</p>
                </CardContent>
              </Card>

              <Card className="bg-white/80 backdrop-blur-sm border-amber-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:scale-105 group">
                <CardContent className="p-6">
                  <div className="flex items-center justify-between mb-3">
                    <span className="font-semibold text-amber-700">Development & Operations</span>
                    <span className="text-2xl font-bold text-amber-600">10%</span>
                  </div>
                  <Progress value={10} className="h-3 mb-2" />
                  <p className="text-sm text-gray-600">Core team and technology development costs ($1.95M)</p>
                </CardContent>
              </Card>
            </div>

            <Card className="bg-white/80 backdrop-blur-sm border-blue-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:scale-105">
              <CardContent className="p-8 text-center">
                <h3 className="text-2xl font-bold text-blue-700 mb-4">DAO Gold Treasury Model</h3>
                <div className="text-4xl font-bold text-blue-600 mb-4">$19,500,000</div>
                <p className="text-gray-600 mb-6">USDC grants from gold treasury</p>
                <div className="space-y-2 text-sm text-gray-700">
                  <div className="flex justify-between">
                    <span>Contributors provide:</span>
                    <span className="font-semibold">PAXG/XAUT or Fiat</span>
                  </div>
                  <div className="flex justify-between">
                    <span>DAO Gold Treasury:</span>
                    <span className="font-semibold">$30M PAXG/XAUT</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Grant Allocation Ratio:</span>
                    <span className="font-semibold">65%</span>
                  </div>
                  <div className="flex justify-between">
                    <span>USDC Grant Capacity:</span>
                    <span className="font-semibold">$19.5M</span>
                  </div>
                  <div className="flex justify-between">
                    <span>To Cooperatives:</span>
                    <span className="font-semibold">$13.65M (70%)</span>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Gold-Backed Mechanism */}
      <section className="py-20 px-6 bg-gradient-to-br from-white/60 via-green-50/60 to-emerald-100/80 relative">
        <div className="absolute inset-0 bg-gradient-to-r from-green-800/5 to-emerald-900/5"></div>
        <div className="container mx-auto max-w-6xl relative">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4 bg-gradient-to-r from-amber-700 to-green-700 bg-clip-text text-transparent">
              Gold-Backed Grant Distribution
            </h2>
            <p className="text-xl text-gray-600">Milestone-based capital deployment through smart contracts</p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            <Card className="bg-white/80 backdrop-blur-sm border-amber-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:rotate-1 group">
              <CardContent className="p-8 text-center">
                <div className="w-16 h-16 bg-gradient-to-br from-amber-400 to-amber-600 rounded-2xl flex items-center justify-center mx-auto mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Shield className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-amber-700 mb-4">Gold Treasury</h3>
                <p className="text-gray-600 mb-4">
                  $30M in tokenized gold (PAXG/XAUT) held in secure multi-signature wallets as collateral
                </p>
                <div className="text-sm text-amber-600 font-semibold">Immutable Collateral Base</div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-green-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:-rotate-1 group">
              <CardContent className="p-8 text-center">
                <div className="w-16 h-16 bg-gradient-to-br from-green-400 to-green-600 rounded-2xl flex items-center justify-center mx-auto mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <TrendingUp className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-green-700 mb-4">Treasury Conversion</h3>
                <p className="text-gray-600 mb-4">
                  Convert $19.5M from $30M gold treasury to USDC grants through milestone-based disbursement system
                </p>
                <div className="text-sm text-green-600 font-semibold">$19.5M Grant Capacity</div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-emerald-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:rotate-1 group">
              <CardContent className="p-8 text-center">
                <div className="w-16 h-16 bg-gradient-to-br from-emerald-400 to-emerald-600 rounded-2xl flex items-center justify-center mx-auto mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Users className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-emerald-700 mb-4">Cooperative Grants</h3>
                <p className="text-gray-600 mb-4">
                  Deploy USDC to cooperatives through milestone validation in exchange for tokenized claims on finished coffee products
                </p>
                <div className="text-sm text-emerald-600 font-semibold">Direct Impact Funding</div>
              </CardContent>
            </Card>
          </div>

          <div className="mt-12 text-center">
            <Card className="bg-white/80 backdrop-blur-sm border-blue-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:scale-105 max-w-4xl mx-auto">
              <CardContent className="p-8">
                <h3 className="text-2xl font-bold text-blue-700 mb-4">Milestone-Based Grant Model</h3>
                <div className="grid md:grid-cols-3 gap-6 text-left">
                  <div>
                    <h4 className="font-semibold text-blue-800 mb-2">Phase 1: Grant Approval</h4>
                    <ul className="text-sm text-blue-700 space-y-1">
                      <li>• Gold treasury backs USDC grants</li>
                      <li>• USDC deployed through milestones</li>
                      <li>• Infrastructure development begins</li>
                    </ul>
                  </div>
                  <div>
                    <h4 className="font-semibold text-blue-800 mb-2">Phase 2: Production</h4>
                    <ul className="text-sm text-blue-700 space-y-1">
                      <li>• Coffee production and sales</li>
                      <li>• Revenue generation for cooperatives</li>
                      <li>• Quality premiums captured</li>
                    </ul>
                  </div>
                  <div>
                    <h4 className="font-semibold text-blue-800 mb-2">Phase 3: Growth & Scale</h4>
                    <ul className="text-sm text-blue-700 space-y-1">
                      <li>• DAO sells inventory tokens for reinvestment</li>
                      <li>• Cooperatives contribute to gold treasury</li>
                      <li>• Gold treasury grows for regional scaling</li>
                    </ul>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Governance Model */}
      <section className="py-20 px-6 bg-gradient-to-br from-white/60 via-green-50/60 to-emerald-100/80 relative">
        <div className="absolute inset-0 bg-gradient-to-r from-green-800/5 to-emerald-900/5"></div>
        <div className="container mx-auto max-w-6xl relative">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4 bg-gradient-to-r from-amber-700 to-green-700 bg-clip-text text-transparent">
              DAO Governance Model
            </h2>
            <p className="text-xl text-gray-600">Democratic decision-making for Swiss Verein structure</p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            <Card className="bg-white/80 backdrop-blur-sm border-amber-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:rotate-1 group">
              <CardContent className="p-8 text-center">
                <div className="w-16 h-16 bg-gradient-to-br from-amber-400 to-amber-600 rounded-2xl flex items-center justify-center mx-auto mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Users className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-amber-700 mb-4">Proposal Creation</h3>
                <p className="text-gray-600 mb-4">Any VERT holder with 1,000+ tokens can create governance proposals</p>
                <div className="text-sm text-amber-600 font-semibold">Minimum: 1K VERT</div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-green-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:-rotate-1 group">
              <CardContent className="p-8 text-center">
                <div className="w-16 h-16 bg-gradient-to-br from-green-400 to-green-600 rounded-2xl flex items-center justify-center mx-auto mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Vote className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-green-700 mb-4">Voting Process</h3>
                <p className="text-gray-600 mb-4">7-day voting period with one-token-one-vote (capped per wallet)</p>
                <div className="text-sm text-green-600 font-semibold">Simple Majority</div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-emerald-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:rotate-1 group">
              <CardContent className="p-8 text-center">
                <div className="w-16 h-16 bg-gradient-to-br from-emerald-400 to-emerald-600 rounded-2xl flex items-center justify-center mx-auto mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Shield className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-emerald-700 mb-4">Non-Profit Focus</h3>
                <p className="text-gray-600 mb-4">
                  All decisions support regenerative agriculture mission, no profit distribution
                </p>
                <div className="text-sm text-emerald-600 font-semibold">Swiss Verein</div>
              </CardContent>
            </Card>
          </div>

          <div className="mt-12 text-center">
            <Card className="bg-white/80 backdrop-blur-sm border-blue-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:scale-105 max-w-4xl mx-auto">
              <CardContent className="p-8">
                <h3 className="text-2xl font-bold text-blue-700 mb-4">Governance Scope</h3>
                <div className="grid md:grid-cols-2 gap-6 text-left">
                  <div>
                    <h4 className="font-semibold text-blue-800 mb-2">Treasury Decisions</h4>
                    <ul className="text-sm text-blue-700 space-y-1">
                      <li>• PAXG/XAUT allocation strategies</li>
                      <li>• USDC grant deployment to cooperatives</li>
                      <li>• Emergency fund management</li>
                    </ul>
                  </div>
                  <div>
                    <h4 className="font-semibold text-blue-800 mb-2">Strategic Decisions</h4>
                    <ul className="text-sm text-blue-700 space-y-1">
                      <li>• New cooperative partnerships</li>
                      <li>• Technology stack upgrades</li>
                      <li>• Regional expansion planning</li>
                    </ul>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="py-20 px-6 bg-gradient-to-r from-green-800 to-emerald-900 relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-amber-900/20 to-green-900/20"></div>
        <div className="absolute top-10 left-10 w-20 h-20 bg-amber-400/20 rounded-full blur-xl animate-pulse"></div>
        <div className="absolute bottom-10 right-10 w-32 h-32 bg-green-400/20 rounded-full blur-xl animate-pulse delay-1000"></div>

        <div className="container mx-auto max-w-4xl text-center relative z-10">
          <div className="bg-white/95 backdrop-blur-sm rounded-3xl p-12 shadow-2xl border border-emerald-200">
            <h2 className="text-4xl font-bold mb-6 bg-gradient-to-r from-amber-700 to-green-700 bg-clip-text text-transparent">
              Join the DAO Launch
            </h2>
            <p className="text-xl text-gray-700 mb-8">
              Be part of the founding community when WAGA DAO launches in September 2025
            </p>

            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link href="/get-involved">
                <Button
                  size="lg"
                  className="bg-gradient-to-r from-amber-500 to-green-600 hover:from-amber-600 hover:to-green-700 text-white shadow-xl px-12 py-4 text-lg transform transition-all duration-300 hover:scale-110 hover:shadow-2xl"
                >
                  <Vote className="mr-2 h-5 w-5" />
                  Get Early Access
                </Button>
              </Link>
              <Link href="/technology">
                <Button
                  size="lg"
                  variant="outline"
                  className="border-2 border-green-300 text-green-700 hover:bg-green-50 px-12 py-4 text-lg bg-white/50 transform transition-all duration-300 hover:scale-105"
                >
                  <Zap className="mr-2 h-5 w-5" />
                  View Technology
                </Button>
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-12 px-6 bg-gradient-to-r from-green-800 to-emerald-900 text-white">
        <div className="container mx-auto max-w-6xl">
          <div className="flex flex-col md:flex-row items-center justify-between">
            <div className="flex items-center space-x-3 mb-6 md:mb-0 group">
              <div className="w-10 h-10 bg-gradient-to-br from-amber-400 to-green-500 rounded-xl flex items-center justify-center transition-transform duration-300 group-hover:scale-110 group-hover:rotate-12">
                <Coffee className="h-6 w-6 text-white" />
              </div>
              <span className="text-2xl font-bold">WAGA DAO</span>
            </div>

            <div className="flex flex-col md:flex-row items-center space-y-4 md:space-y-0 md:space-x-8">
              <a
                href="mailto:team@wagatoken.io"
                className="hover:text-amber-300 transition-all duration-300 hover:scale-105"
              >
                team@wagatoken.io
              </a>
              <a
                href="https://wagadao.io"
                className="hover:text-amber-300 transition-all duration-300 hover:scale-105 flex items-center"
              >
                <Globe className="h-4 w-4 mr-1" />
                wagadao.io
              </a>
              <div className="flex items-center space-x-4">
                <a
                  href="https://linkedin.com/company/wagadao"
                  className="hover:text-amber-300 transition-all duration-300 p-2 hover:bg-white/10 rounded-lg transform hover:scale-110 hover:rotate-12"
                >
                  <Linkedin className="h-5 w-5" />
                </a>
                <a
                  href="https://t.me/wagadao"
                  className="hover:text-amber-300 transition-all duration-300 p-2 hover:bg-white/10 rounded-lg transform hover:scale-110 hover:rotate-12"
                >
                  <MessageCircle className="h-5 w-5" />
                </a>
                <a
                  href="https://twitter.com/wagadao"
                  className="hover:text-amber-300 transition-all duration-300 p-2 hover:bg-white/10 rounded-lg transform hover:scale-110 hover:rotate-12"
                >
                  <Twitter className="h-5 w-5" />
                </a>
                <a
                  href="https://discord.gg/wagadao"
                  className="hover:text-amber-300 transition-all duration-300 p-2 hover:bg-white/10 rounded-lg transform hover:scale-110 hover:rotate-12"
                >
                  <MessageCircle className="h-5 w-5" />
                </a>
              </div>
            </div>
          </div>

          <div className="border-t border-green-700 mt-8 pt-8 text-center text-green-200">
            <p>© 2025 WAGA DAO • Swiss Non-profit Association • Regenerating African Economies</p>
          </div>
        </div>
      </footer>
    </div>
  )
}
