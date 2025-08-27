/**
 * WAGA DAO - Modern Web3 Dashboard
 * Streamlined UI focused on functionality and direct portal access
 */

"use client"

import { useState, useEffect } from "react"
import Link from "next/link"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import {
  Coffee,
  Users,
  Shield,
  Coins,
  TrendingUp,
  DollarSign,
  Globe,
  ArrowRight,
  Activity,
  BarChart3,
  Leaf,
  Target,
  Menu,
  X
} from "lucide-react"

interface SystemMetrics {
  totalGrants: number
  disbursedAmount: number
  activeFarmers: number
  treasuryValue: number
  carbonOffset: number
  milestonesCompleted: number
}

export default function Dashboard() {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false)
  const [metrics, setMetrics] = useState<SystemMetrics>({
    totalGrants: 25,
    disbursedAmount: 2850000,
    activeFarmers: 1250,
    treasuryValue: 30000000,
    carbonOffset: 15800,
    milestonesCompleted: 89
  })

  // Simulate real-time updates
  useEffect(() => {
    const interval = setInterval(() => {
      setMetrics(prev => ({
        ...prev,
        disbursedAmount: prev.disbursedAmount + Math.random() * 1000,
        milestonesCompleted: prev.milestonesCompleted + (Math.random() > 0.95 ? 1 : 0)
      }))
    }, 3000)

    return () => clearInterval(interval)
  }, [])

  const navigationItems = [
    { name: "Dashboard", href: "/" },
    { name: "Grants", href: "/grants" },
    { name: "Treasury", href: "/treasury" },
    { name: "About", href: "/about" }
  ]

  const portalCards = [
    {
      id: "cooperative",
      title: "Cooperative Portal",
      description: "Apply for grants, track milestones, tokenize inventory",
      icon: Coffee,
      color: "from-green-500 to-emerald-600",
      href: "/portal/cooperative",
      metrics: { farmers: "1,250", grants: "25", funding: "$2.8M" }
    },
    {
      id: "admin",
      title: "Admin Portal",
      description: "Validate milestones, manage grants, system oversight",
      icon: Shield,
      color: "from-blue-500 to-indigo-600",
      href: "/portal/admin",
      metrics: { pending: "12", validated: "89", active: "25" }
    },
    {
      id: "dao",
      title: "DAO Portal",
      description: "Governance, proposals, treasury management",
      icon: Users,
      color: "from-purple-500 to-violet-600",
      href: "/portal/dao",
      metrics: { proposals: "7", members: "2,840", treasury: "$30M" }
    }
  ]

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-green-900 to-emerald-900">
      {/* Modern Web3 Navigation */}
      <nav className="fixed top-0 w-full z-50 bg-black/20 backdrop-blur-xl border-b border-white/10">
        <div className="container mx-auto px-6 py-4 flex items-center justify-between">
          <Link href="/" className="flex items-center space-x-3 group">
            <div className="relative">
              <div className="w-10 h-10 bg-gradient-to-br from-amber-400 to-green-500 rounded-2xl flex items-center justify-center transition-all duration-300 group-hover:scale-110">
                <Coffee className="h-6 w-6 text-white" />
              </div>
              <div className="absolute inset-0 bg-gradient-to-br from-amber-400 to-green-500 rounded-2xl blur-md opacity-50 group-hover:opacity-75 transition-opacity"></div>
            </div>
            <span className="text-2xl font-bold text-white">WAGA DAO</span>
          </Link>

          {/* Desktop Navigation */}
          <div className="hidden lg:flex items-center space-x-8">
            {navigationItems.map((item) => (
              <Link
                key={item.name}
                href={item.href}
                className="text-white/80 hover:text-white transition-colors duration-300 text-sm font-medium relative group"
              >
                {item.name}
                <div className="absolute bottom-0 left-0 w-0 h-0.5 bg-gradient-to-r from-amber-400 to-green-500 group-hover:w-full transition-all duration-300"></div>
              </Link>
            ))}
          </div>

          {/* Mobile Menu Button */}
          <button
            onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
            className="lg:hidden text-white hover:text-amber-300 transition-colors"
          >
            {isMobileMenuOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
          </button>
        </div>

        {/* Mobile Navigation */}
        {isMobileMenuOpen && (
          <div className="lg:hidden bg-black/40 backdrop-blur-xl border-t border-white/10">
            <div className="container mx-auto px-6 py-4 space-y-4">
              {navigationItems.map((item) => (
                <Link
                  key={item.name}
                  href={item.href}
                  className="block text-white/80 hover:text-white transition-colors duration-300 text-sm font-medium py-2"
                  onClick={() => setIsMobileMenuOpen(false)}
                >
                  {item.name}
                </Link>
              ))}
            </div>
          </div>
        )}
      </nav>

      {/* Hero Section with Real-time Metrics */}
      <section className="pt-24 pb-12 px-6">
        <div className="container mx-auto max-w-7xl">
          {/* Main CTA */}
          <div className="text-center mb-16">
            <div className="inline-flex items-center space-x-2 bg-green-500/10 backdrop-blur-sm border border-green-500/20 rounded-full px-4 py-2 mb-6">
              <Activity className="w-4 h-4 text-green-400" />
              <span className="text-green-400 text-sm font-medium">Live System</span>
              <div className="w-2 h-2 bg-green-400 rounded-full animate-pulse"></div>
            </div>
            
            <h1 className="text-5xl md:text-7xl font-bold text-white mb-6 leading-tight">
              Regenerative
              <br />
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-amber-400 via-green-400 to-emerald-400">
                Coffee Economy
              </span>
            </h1>
            
            <p className="text-xl text-white/70 mb-8 max-w-2xl mx-auto">
              Blockchain-powered grants, milestone tracking, and coffee tokenization across Africa
            </p>

            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link href="/portal/cooperative">
                <Button size="lg" className="bg-gradient-to-r from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700 text-white px-8 py-4 text-lg">
                  <Coffee className="mr-2 h-5 w-5" />
                  Launch Portal
                </Button>
              </Link>
              <Link href="/grants">
                <Button size="lg" variant="outline" className="border-white/20 text-white hover:bg-white/10 px-8 py-4 text-lg">
                  <BarChart3 className="mr-2 h-5 w-5" />
                  View Grants
                </Button>
              </Link>
            </div>
          </div>

          {/* Real-time System Metrics */}
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-6 mb-16">
            <Card className="bg-black/20 backdrop-blur-xl border-white/10 hover:border-green-500/30 transition-all duration-300">
              <CardContent className="p-4 text-center">
                <Target className="w-8 h-8 text-green-400 mx-auto mb-2" />
                <div className="text-2xl font-bold text-white">{metrics.totalGrants}</div>
                <div className="text-xs text-white/60">Active Grants</div>
              </CardContent>
            </Card>

            <Card className="bg-black/20 backdrop-blur-xl border-white/10 hover:border-blue-500/30 transition-all duration-300">
              <CardContent className="p-4 text-center">
                <DollarSign className="w-8 h-8 text-blue-400 mx-auto mb-2" />
                <div className="text-2xl font-bold text-white">${(metrics.disbursedAmount / 1000000).toFixed(1)}M</div>
                <div className="text-xs text-white/60">Disbursed</div>
              </CardContent>
            </Card>

            <Card className="bg-black/20 backdrop-blur-xl border-white/10 hover:border-amber-500/30 transition-all duration-300">
              <CardContent className="p-4 text-center">
                <Users className="w-8 h-8 text-amber-400 mx-auto mb-2" />
                <div className="text-2xl font-bold text-white">{metrics.activeFarmers.toLocaleString()}</div>
                <div className="text-xs text-white/60">Farmers</div>
              </CardContent>
            </Card>

            <Card className="bg-black/20 backdrop-blur-xl border-white/10 hover:border-purple-500/30 transition-all duration-300">
              <CardContent className="p-4 text-center">
                <Coins className="w-8 h-8 text-purple-400 mx-auto mb-2" />
                <div className="text-2xl font-bold text-white">${(metrics.treasuryValue / 1000000).toFixed(0)}M</div>
                <div className="text-xs text-white/60">Treasury</div>
              </CardContent>
            </Card>

            <Card className="bg-black/20 backdrop-blur-xl border-white/10 hover:border-emerald-500/30 transition-all duration-300">
              <CardContent className="p-4 text-center">
                <Leaf className="w-8 h-8 text-emerald-400 mx-auto mb-2" />
                <div className="text-2xl font-bold text-white">{metrics.carbonOffset.toLocaleString()}</div>
                <div className="text-xs text-white/60">CO₂ Tons</div>
              </CardContent>
            </Card>

            <Card className="bg-black/20 backdrop-blur-xl border-white/10 hover:border-green-500/30 transition-all duration-300">
              <CardContent className="p-4 text-center">
                <TrendingUp className="w-8 h-8 text-green-400 mx-auto mb-2" />
                <div className="text-2xl font-bold text-white">{metrics.milestonesCompleted}</div>
                <div className="text-xs text-white/60">Milestones</div>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Direct Portal Access - No Dropdown Needed */}
      <section className="px-6 pb-20">
        <div className="container mx-auto max-w-7xl">
          <div className="text-center mb-12">
            <h2 className="text-4xl font-bold text-white mb-4">Access Portals</h2>
            <p className="text-white/70 text-lg">Direct access to your workspace</p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            {portalCards.map((portal) => {
              const IconComponent = portal.icon
              return (
                <Card
                  key={portal.id}
                  className="group bg-black/20 backdrop-blur-xl border-white/10 hover:border-white/30 transition-all duration-500 hover:scale-105 hover:-translate-y-2"
                >
                  <CardHeader className="text-center pb-4">
                    <div className="relative mx-auto mb-4">
                      <div className={`w-16 h-16 bg-gradient-to-br ${portal.color} rounded-3xl flex items-center justify-center group-hover:scale-110 transition-transform duration-300`}>
                        <IconComponent className="h-8 w-8 text-white" />
                      </div>
                      <div className={`absolute inset-0 bg-gradient-to-br ${portal.color} rounded-3xl blur-lg opacity-50 group-hover:opacity-75 transition-opacity`}></div>
                    </div>
                    <CardTitle className="text-2xl text-white group-hover:text-transparent group-hover:bg-clip-text group-hover:bg-gradient-to-r group-hover:from-white group-hover:to-green-400 transition-all duration-300">
                      {portal.title}
                    </CardTitle>
                    <p className="text-white/60">{portal.description}</p>
                  </CardHeader>

                  <CardContent className="space-y-4">
                    {/* Portal Metrics */}
                    <div className="grid grid-cols-3 gap-4 text-center">
                      {Object.entries(portal.metrics).map(([key, value]) => (
                        <div key={key}>
                          <div className="text-lg font-bold text-white">{value}</div>
                          <div className="text-xs text-white/50 capitalize">{key}</div>
                        </div>
                      ))}
                    </div>

                    <Link href={portal.href} className="block">
                      <Button className={`w-full bg-gradient-to-r ${portal.color} hover:opacity-90 transition-all duration-300 group-hover:scale-105`}>
                        Access Portal
                        <ArrowRight className="ml-2 h-4 w-4" />
                      </Button>
                    </Link>
                  </CardContent>
                </Card>
              )
            })}
          </div>
        </div>
      </section>

      {/* Quick Stats Footer */}
      <section className="px-6 pb-8">
        <div className="container mx-auto max-w-7xl">
          <Card className="bg-black/20 backdrop-blur-xl border-white/10">
            <CardContent className="p-6">
              <div className="flex flex-col md:flex-row items-center justify-between">
                <div className="flex items-center space-x-3 mb-4 md:mb-0">
                  <div className="w-10 h-10 bg-gradient-to-br from-amber-400 to-green-500 rounded-2xl flex items-center justify-center">
                    <Coffee className="h-6 w-6 text-white" />
                  </div>
                  <div>
                    <div className="text-white font-bold">WAGA DAO</div>
                    <div className="text-white/60 text-sm">Regenerating African Coffee</div>
                  </div>
                </div>
                
                <div className="flex items-center space-x-6 text-center">
                  <div>
                    <div className="text-white font-bold">50+</div>
                    <div className="text-white/60 text-xs">Cooperatives</div>
                  </div>
                  <div>
                    <div className="text-white font-bold">3</div>
                    <div className="text-white/60 text-xs">Countries</div>
                  </div>
                  <div>
                    <div className="text-white font-bold">98%</div>
                    <div className="text-white/60 text-xs">Success Rate</div>
                  </div>
                </div>

                <div className="flex items-center space-x-2">
                  <div className="w-2 h-2 bg-green-400 rounded-full animate-pulse"></div>
                  <span className="text-green-400 text-sm">System Online</span>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </section>
    </div>
  )
}
