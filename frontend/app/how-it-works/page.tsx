/**
 * How It Works - Grant Types & Coffee-Backed Principles
 * Intelligent blend of Home (green/emerald) and Treasury (amber/gold) themes
 */

"use client"

import { useState } from "react"
import Link from "next/link"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import {
  Coffee,
  Coins,
  DollarSign,
  Shield,
  Users,
  Target,
  ArrowLeft,
  Zap,
  CheckCircle,
  Leaf,
  Award,
  BarChart3,
  Globe,
  Gem
} from "lucide-react"

export default function HowItWorks() {
  const [activeTab, setActiveTab] = useState("grants")

  const grantTypes = [
    {
      id: "brownfield",
      title: "Brown Field Project Grants",
      icon: Coffee,
      color: "from-emerald-500 to-green-600",
      amount: "$5K - $100K",
      description: "Value addition and vertical integration grants for established cooperatives",
      features: [
        "Processing equipment and infrastructure upgrades",
        "Quality improvement and certification support",
        "Vertical integration into roasting and packaging",
        "Market access and branding development",
        "Revenue sharing tied to value-added coffee sales",
        "10-15% revenue share until 2x grant amount reached"
      ],
      targets: { projects: "100", coops: "50", avgSize: "$70K" }
    },
    {
      id: "production-finance",
      title: "Production Pre-Financing",
      icon: Leaf,
      color: "from-amber-500 to-yellow-600",
      amount: "$1K - $50K",
      description: "Pre-financing against future coffee production with seasonal flexibility",
      features: [
        "Seasonal working capital for planting and cultivation",
        "Funding against projected harvest yields",
        "Flexible draw-down schedule aligned with farming cycles",
        "Coffee batch tokenization upon harvest completion",
        "Revenue sharing based on actual production and sales",
        "Renewable annually based on performance history"
      ],
      targets: { farmers: "2,000", cycles: "8/year", avgSize: "$24K" }
    },
    {
      id: "greenfield",
      title: "Greenfield Project Grants",
      icon: Target,
      color: "from-green-500 to-emerald-600",
      amount: "$10K - $200K",
      description: "Multi-stage funding for new coffee cultivation projects with phased disbursement",
      features: [
        "Milestone-based phased disbursement system",
        "Land preparation and planting support (Stage 1)",
        "Growing season monitoring and care (Stage 2)", 
        "Harvest and processing equipment funding (Stage 3)",
        "Smart contract automated milestone validation",
        "Multi-signature validation by certified field officers",
        "Satellite imagery and IoT sensor monitoring"
      ],
      targets: { projects: "30", hectares: "1,000", avgGrant: "$130K" }
    }
  ]

  const principles = [
    {
      id: "tokenization",
      title: "Coffee Batch Tokenization",
      icon: Coffee,
      gradient: "from-amber-600 via-green-600 to-emerald-700",
      description: "Every coffee batch becomes an NFT upon harvest, enabling transparent financing",
      details: [
        "IPFS metadata storage with quality scores and certifications",
        "Unique NFT representation linking grants to physical inventory",
        "Future production tokenization for pre-financing contracts",
        "Real-time traceability from farm to cup",
        "Transparent quality assessment and pricing mechanisms"
      ]
    },
    {
      id: "pre-financing",
      title: "Production Pre-Financing",
      icon: Leaf,
      gradient: "from-green-500 via-emerald-600 to-amber-600",
      description: "Seasonal financing against future coffee production with flexible terms",
      details: [
        "Working capital provided during planting and growing seasons",
        "Funding tied to projected harvest yields and historical performance",
        "Flexible repayment aligned with coffee selling seasons",
        "Automatic tokenization and revenue sharing upon harvest",
        "Risk assessment based on climate data and farming practices"
      ]
    },
    {
      id: "phased-disbursement",
      title: "Phased Disbursement System",
      icon: Target,
      gradient: "from-blue-500 via-indigo-600 to-purple-700",
      description: "Milestone-based funding with automatic smart contract validation for greenfield projects",
      details: [
        "Multi-signature validation by certified field officers",
        "Satellite imagery for crop monitoring and verification",
        "IoT sensors for real-time environmental data collection",
        "Automated disbursement upon milestone completion",
        "Customizable milestone percentages and validation criteria"
      ]
    },
    {
      id: "revenue-sharing",
      title: "Revenue Sharing Mechanism", 
      icon: DollarSign,
      gradient: "from-purple-500 via-violet-600 to-pink-700",
      description: "Transparent revenue sharing until grant obligations are met through coffee sales",
      details: [
        "10-15% revenue share on all coffee batch sales",
        "Automatic calculation and distribution via smart contracts",
        "Grant completion when 2x grant amount is reached",
        "Fair pricing guarantees protecting farmer minimum prices",
        "Real-time tracking of revenue sharing progress"
      ]
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
              <span className="text-white font-medium text-sm relative">
                How It Works
                <div className="absolute bottom-0 left-0 w-full h-0.5 bg-gradient-to-r from-amber-400 to-green-500"></div>
              </span>
              <Link href="/grants" className="text-white/80 hover:text-white transition-colors text-sm font-medium relative group">
                Dashboard
                <div className="absolute bottom-0 left-0 w-0 h-0.5 bg-gradient-to-r from-amber-400 to-green-500 group-hover:w-full transition-all duration-300"></div>
              </Link>
              <Link href="/treasury" className="text-white/80 hover:text-white transition-colors text-sm font-medium relative group">
                Treasury
                <div className="absolute bottom-0 left-0 w-0 h-0.5 bg-gradient-to-r from-amber-400 to-green-500 group-hover:w-full transition-all duration-300"></div>
              </Link>
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

      {/* Hero Section */}
      <section className="pt-24 pb-12 px-6">
        <div className="container mx-auto max-w-7xl">
          <div className="text-center mb-16">
            <Badge className="mb-4 bg-gradient-to-r from-amber-500/10 to-green-500/10 text-amber-200 border-amber-500/20">
              <Globe className="w-4 h-4 mr-2" />
              Revolutionary Coffee Finance
            </Badge>
            <h1 className="text-5xl md:text-7xl font-bold text-white mb-6 leading-tight">
              <span className="bg-gradient-to-r from-amber-400 via-yellow-300 to-green-400 bg-clip-text text-transparent">
                How It
              </span>
              <br />
              <span className="bg-gradient-to-r from-green-400 via-emerald-300 to-amber-400 bg-clip-text text-transparent">
                Works
              </span>
            </h1>
            <p className="text-xl text-white/70 max-w-3xl mx-auto">
              Blockchain-powered grant mechanisms, coffee tokenization, and gold-backed treasury systems revolutionizing African agriculture
            </p>
          </div>

          {/* Tab Navigation */}
          <div className="flex justify-center mb-12">
            <div className="flex bg-black/20 backdrop-blur-xl border border-white/10 rounded-2xl p-2">
              <button
                onClick={() => setActiveTab("grants")}
                className={`px-6 py-3 rounded-xl font-medium transition-all duration-300 ${
                  activeTab === "grants"
                    ? "bg-gradient-to-r from-amber-500 to-green-600 text-white"
                    : "text-white/70 hover:text-white"
                }`}
              >
                Grant Types
              </button>
              <button
                onClick={() => setActiveTab("principles")}
                className={`px-6 py-3 rounded-xl font-medium transition-all duration-300 ${
                  activeTab === "principles"
                    ? "bg-gradient-to-r from-green-500 to-amber-600 text-white"
                    : "text-white/70 hover:text-white"
                }`}
              >
                Core Principles
              </button>
            </div>
          </div>
        </div>
      </section>

      {/* Grant Types Section */}
      {activeTab === "grants" && (
        <section className="px-6 pb-20">
          <div className="container mx-auto max-w-7xl">
            <div className="grid lg:grid-cols-3 gap-8">
              {grantTypes.map((grant, index) => {
                const IconComponent = grant.icon
                return (
                  <Card
                    key={grant.id}
                    className="bg-black/20 backdrop-blur-xl border-white/10 hover:border-white/30 transition-all duration-500 hover:scale-105 flex flex-col h-full"
                  >
                    <CardHeader className="text-center pb-6">
                      <div className="relative mx-auto mb-4">
                        <div className={`w-16 h-16 bg-gradient-to-br ${grant.color} rounded-3xl flex items-center justify-center`}>
                          <IconComponent className="h-8 w-8 text-white" />
                        </div>
                        <div className={`absolute inset-0 bg-gradient-to-br ${grant.color} rounded-3xl blur-lg opacity-50`}></div>
                      </div>
                      <Badge className="mb-2 bg-amber-500/20 text-amber-200 border-amber-400/30">
                        {grant.amount}
                      </Badge>
                      <CardTitle className="text-2xl text-white mb-2">{grant.title}</CardTitle>
                      <p className="text-white/60 min-h-[3rem] flex items-center justify-center">{grant.description}</p>
                    </CardHeader>

                    <CardContent className="space-y-6 flex-grow flex flex-col">
                      <div className="space-y-3 flex-grow">
                        {grant.features.map((feature, idx) => (
                          <div key={idx} className="flex items-start space-x-3">
                            <CheckCircle className="h-5 w-5 text-green-400 mt-0.5 flex-shrink-0" />
                            <span className="text-white/80 text-sm">{feature}</span>
                          </div>
                        ))}
                      </div>

                      <div className="grid grid-cols-3 gap-4 pt-4 border-t border-white/10 mt-auto">
                        <div className="text-center">
                          <div className="text-xs text-white/50 mb-1">2030 TARGETS</div>
                        </div>
                        <div></div>
                        <div></div>
                        {Object.entries(grant.targets).map(([key, value]) => (
                          <div key={key} className="text-center">
                            <div className="text-lg font-bold text-white">{value}</div>
                            <div className="text-xs text-white/50 capitalize">{key}</div>
                          </div>
                        ))}
                      </div>
                    </CardContent>
                  </Card>
                )
              })}
            </div>
          </div>
        </section>
      )}

      {/* Core Principles Section */}
      {activeTab === "principles" && (
        <section className="px-6 pb-20">
          <div className="container mx-auto max-w-7xl">
            <div className="grid lg:grid-cols-2 gap-8">
              {principles.map((principle, index) => {
                const IconComponent = principle.icon
                return (
                  <Card
                    key={principle.id}
                    className="bg-black/20 backdrop-blur-xl border-white/10 hover:border-white/30 transition-all duration-500 group"
                  >
                    <CardHeader className="pb-6">
                      <div className="flex items-center space-x-4">
                        <div className="relative">
                          <div className={`w-14 h-14 bg-gradient-to-br ${principle.gradient} rounded-2xl flex items-center justify-center group-hover:scale-110 transition-transform duration-300`}>
                            <IconComponent className="h-7 w-7 text-white" />
                          </div>
                          <div className={`absolute inset-0 bg-gradient-to-br ${principle.gradient} rounded-2xl blur-md opacity-50 group-hover:opacity-75 transition-opacity`}></div>
                        </div>
                        <div>
                          <CardTitle className="text-2xl text-white mb-2">{principle.title}</CardTitle>
                          <p className="text-white/60">{principle.description}</p>
                        </div>
                      </div>
                    </CardHeader>

                    <CardContent className="space-y-4">
                      {principle.details.map((detail, idx) => (
                        <div key={idx} className="flex items-start space-x-3">
                          <div className={`w-2 h-2 bg-gradient-to-br ${principle.gradient} rounded-full mt-2.5 flex-shrink-0`}></div>
                          <span className="text-white/80">{detail}</span>
                        </div>
                      ))}
                    </CardContent>
                  </Card>
                )
              })}
            </div>
          </div>
        </section>
      )}

      {/* Call to Action */}
      <section className="px-6 pb-20">
        <div className="container mx-auto max-w-4xl">
          <Card className="bg-black/40 backdrop-blur-xl border-amber-500/30">
            <CardContent className="p-12 text-center">
              <h2 className="text-4xl font-bold text-white mb-6">
                Ready to Transform Coffee Finance?
              </h2>
              <p className="text-xl text-white mb-8 max-w-2xl mx-auto">
                Join thousands of farmers, cooperatives, and investors building the future of sustainable agriculture
              </p>
              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <Link href="/portal/cooperative">
                  <Button size="lg" className="bg-gradient-to-r from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700 text-white px-8 py-4 text-lg">
                    <Coffee className="mr-2 h-5 w-5" />
                    Apply for Grant
                  </Button>
                </Link>
                <Link href="/treasury">
                  <Button size="lg" className="bg-gradient-to-r from-amber-500 to-yellow-600 hover:from-amber-600 hover:to-yellow-700 text-white px-8 py-4 text-lg">
                    <Coins className="mr-2 h-5 w-5" />
                    View Treasury
                  </Button>
                </Link>
              </div>
            </CardContent>
          </Card>
        </div>
      </section>
    </div>
  )
}