/**
 * WAGA DAO - Home Page
 * Streamlined UI functionality and direct portal access
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
  Target,
  Menu,
  Eye,
  Lock,
  Zap,
  X
} from "lucide-react"

interface SystemMetrics {
  totalGrants: { target: number; actual: number }
  disbursedAmount: { target: number; actual: number }
  activeFarmers: { target: number; actual: number }
  treasuryValue: { target: number; actual: number }
}

export default function Home() {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false)
  const [metrics, setMetrics] = useState<SystemMetrics>({
    totalGrants: { target: 100, actual: 0 },
    disbursedAmount: { target: 20000000, actual: 0 },
    activeFarmers: { target: 10000, actual: 0 },
    treasuryValue: { target: 30000000, actual: 0 }
  })

  const navigationItems = [
    { name: "Home", href: "/" },
    { name: "How It Works", href: "/how-it-works" },
    { name: "Dashboard", href: "/grants" },
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

  // Simulate real-time updates
  useEffect(() => {
    const interval = setInterval(() => {
      setMetrics(prev => ({
        ...prev,
        activeFarmers: { 
          ...prev.activeFarmers, 
          actual: Math.max(0, prev.activeFarmers.actual + Math.floor(Math.random() * 3) - 1)
        }
      }))
    }, 5000)

    return () => clearInterval(interval)
  }, [])

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-green-900 to-emerald-900">
      {/* Modern Web3 Navigation */}
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
                  <div className="absolute inset-0 bg-gradient-to-br from-amber-400 to-green-500 rounded-2xl blur-md opacity-50 group-hover:opacity-75 transition-opacity"></div>
                </div>
                <span className="text-2xl font-bold text-white">WAGA DAO</span>
              </Link>
            </div>

            {/* Centered Navigation */}
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

            {/* Mobile Menu Button - Right Side */}
            <div className="absolute right-0">
              <button
                onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
                className="lg:hidden text-white hover:text-amber-300 transition-colors"
              >
                {isMobileMenuOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
              </button>
            </div>
          </div>
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
                Coffee Finance
              </span>
            </h1>
            
            <p className="text-xl text-white/70 mb-8 max-w-2xl mx-auto">
              Coffee-backed grants for regenerative value addition with zero-knowledge privacy protection
            </p>

            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link href="/portal/cooperative">
                <Button size="lg" className="bg-gradient-to-r from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700 text-white px-8 py-4 text-lg">
                  <Coffee className="mr-2 h-5 w-5" />
                  How it Works
                </Button>
              </Link>
              <Link href="/how-it-works">
                <Button size="lg" className="bg-black/20 backdrop-blur-xl border border-white/20 text-white hover:bg-white/10 hover:border-white/40 transition-all duration-300 px-8 py-4 text-lg">
                  <BarChart3 className="mr-2 h-5 w-5" />
                  Learn More
                </Button>
              </Link>
            </div>
          </div>

          {/* Coffee-Backed Regenerative Features with Privacy */}
          <div className="mb-16">
            <h2 className="text-3xl font-bold text-white text-center mb-8">
              Coffee-Backed Regenerative Finance
            </h2>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <Card className="bg-black/20 backdrop-blur-xl border-white/10 hover:border-green-500/30 transition-all duration-300">
                <CardContent className="p-6 text-center">
                  <Coffee className="w-12 h-12 text-green-400 mx-auto mb-4" />
                  <h3 className="text-lg font-bold text-white mb-2">Coffee-Backed Grants</h3>
                  <p className="text-white/70 text-sm">
                    Grants secured by real coffee inventory, supporting value addition across the coffee supply chain
                  </p>
                </CardContent>
              </Card>

              <Card className="bg-black/20 backdrop-blur-xl border-white/10 hover:border-amber-500/30 transition-all duration-300">
                <CardContent className="p-6 text-center">
                  <Zap className="w-12 h-12 text-amber-400 mx-auto mb-4" />
                  <h3 className="text-lg font-bold text-white mb-2">Value Addition Focus</h3>
                  <p className="text-white/70 text-sm">
                    Finance processing equipment, quality improvements, and sustainable farming practices
                  </p>
                </CardContent>
              </Card>

              <Card className="bg-black/20 backdrop-blur-xl border-white/10 hover:border-purple-500/30 transition-all duration-300">
                <CardContent className="p-6 text-center">
                  <Shield className="w-12 h-12 text-purple-400 mx-auto mb-4" />
                  <h3 className="text-lg font-bold text-white mb-2">Privacy Protected</h3>
                  <p className="text-white/70 text-sm">
                    Zero-knowledge proofs protect sensitive business data while maintaining transparency
                  </p>
                </CardContent>
              </Card>
            </div>
          </div>

          {/* Real-time System Metrics */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-6 mb-16">
            <Card className="bg-black/20 backdrop-blur-xl border-white/10 hover:border-green-500/30 transition-all duration-300">
              <CardContent className="p-4 text-center">
                <Target className="w-8 h-8 text-green-400 mx-auto mb-2" />
                <div className="text-lg font-bold text-white mb-1">
                  {metrics.totalGrants.actual}/{metrics.totalGrants.target}
                </div>
                <div className="text-xs text-green-400 mb-1">Actual vs Target</div>
                <div className="text-xs text-white/60">Active Grants</div>
              </CardContent>
            </Card>

            <Card className="bg-black/20 backdrop-blur-xl border-white/10 hover:border-blue-500/30 transition-all duration-300">
              <CardContent className="p-4 text-center">
                <DollarSign className="w-8 h-8 text-blue-400 mx-auto mb-2" />
                <div className="text-lg font-bold text-white mb-1">
                  ${(metrics.disbursedAmount.actual / 1000000).toFixed(0)}M/${(metrics.disbursedAmount.target / 1000000).toFixed(0)}M
                </div>
                <div className="text-xs text-blue-400 mb-1">Actual vs Target</div>
                <div className="text-xs text-white/60">Disbursed</div>
              </CardContent>
            </Card>

            <Card className="bg-black/20 backdrop-blur-xl border-white/10 hover:border-amber-500/30 transition-all duration-300">
              <CardContent className="p-4 text-center">
                <Users className="w-8 h-8 text-amber-400 mx-auto mb-2" />
                <div className="text-lg font-bold text-white mb-1">
                  {metrics.activeFarmers.actual.toLocaleString()}/{metrics.activeFarmers.target.toLocaleString()}
                </div>
                <div className="text-xs text-amber-400 mb-1">Actual vs Target</div>
                <div className="text-xs text-white/60">Farmers</div>
              </CardContent>
            </Card>

            <Card className="bg-black/20 backdrop-blur-xl border-white/10 hover:border-purple-500/30 transition-all duration-300">
              <CardContent className="p-4 text-center">
                <Coins className="w-8 h-8 text-purple-400 mx-auto mb-2" />
                <div className="text-lg font-bold text-white mb-1">
                  ${(metrics.treasuryValue.actual / 1000000).toFixed(0)}M/${(metrics.treasuryValue.target / 1000000).toFixed(0)}M
                </div>
                <div className="text-xs text-purple-400 mb-1">Actual vs Target</div>
                <div className="text-xs text-white/60">Treasury</div>
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
                  className="group bg-black/20 backdrop-blur-xl border-white/10 hover:border-white/30 transition-all duration-500 hover:scale-105 hover:-translate-y-2 flex flex-col h-full"
                >
                  <CardHeader className="text-center pb-4 flex-grow">
                    <div className="relative mx-auto mb-4">
                      <div className={`w-16 h-16 bg-gradient-to-br ${portal.color} rounded-3xl flex items-center justify-center group-hover:scale-110 transition-transform duration-300`}>
                        <IconComponent className="h-8 w-8 text-white" />
                      </div>
                      <div className={`absolute inset-0 bg-gradient-to-br ${portal.color} rounded-3xl blur-lg opacity-50 group-hover:opacity-75 transition-opacity`}></div>
                    </div>
                    <CardTitle className="text-2xl text-white group-hover:text-transparent group-hover:bg-clip-text group-hover:bg-gradient-to-r group-hover:from-white group-hover:to-green-400 transition-all duration-300">
                      {portal.title}
                    </CardTitle>
                    <p className="text-white/60 min-h-[3rem] flex items-center justify-center">{portal.description}</p>
                  </CardHeader>

                  <CardContent className="space-y-4 mt-auto">
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

      {/* Footer */}
      <footer className="bg-black/30 backdrop-blur-xl border-t border-white/10 py-12">
        <div className="container mx-auto px-6 max-w-7xl">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8 mb-8">
            {/* Brand */}
            <div className="space-y-4">
              <div className="flex items-center space-x-3">
                <div className="w-10 h-10 bg-gradient-to-br from-amber-400 to-green-500 rounded-2xl flex items-center justify-center">
                  <Coffee className="h-6 w-6 text-white" />
                </div>
                <div>
                  <div className="text-white font-bold">WAGA DAO</div>
                  <div className="text-white/60 text-sm">Regenerative Coffee Finance</div>
                </div>
              </div>
              <p className="text-white/70 text-sm">
                Coffee-backed grants for regenerative value addition with zero-knowledge privacy protection.
              </p>
            </div>

            {/* Platform */}
            <div className="space-y-4">
              <h4 className="text-white font-semibold">Platform</h4>
              <div className="space-y-2">
                <a href="/portal/cooperative" className="block text-white/70 hover:text-white transition-colors text-sm">
                  Cooperative Portal
                </a>
                <a href="/portal/admin" className="block text-white/70 hover:text-white transition-colors text-sm">
                  Admin Dashboard
                </a>
                <a href="/treasury" className="block text-white/70 hover:text-white transition-colors text-sm">
                  Treasury
                </a>
                <a href="/grants" className="block text-white/70 hover:text-white transition-colors text-sm">
                  Grants
                </a>
              </div>
            </div>

            {/* Resources */}
            <div className="space-y-4">
              <h4 className="text-white font-semibold">Resources</h4>
              <div className="space-y-2">
                <a href="/how-it-works" className="block text-white/70 hover:text-white transition-colors text-sm">
                  How it Works
                </a>
                <a href="/get-started" className="block text-white/70 hover:text-white transition-colors text-sm">
                  Get Started
                </a>
                <a href="/about" className="block text-white/70 hover:text-white transition-colors text-sm">
                  About
                </a>
              </div>
            </div>

            {/* Connect */}
            <div className="space-y-4">
              <h4 className="text-white font-semibold">Connect</h4>
              <div className="space-y-2">
                <a href="mailto:team@wagatoken.io" className="block text-white/70 hover:text-white transition-colors text-sm">
                  Contact Us
                </a>
                <a href="#" className="block text-white/70 hover:text-white transition-colors text-sm">
                  Twitter
                </a>
                <a href="#" className="block text-white/70 hover:text-white transition-colors text-sm">
                  Discord
                </a>
                <a href="#" className="block text-white/70 hover:text-white transition-colors text-sm">
                  GitHub
                </a>
              </div>
            </div>
          </div>

          {/* Bottom Bar */}
          <div className="border-t border-white/10 pt-8 flex flex-col md:flex-row justify-between items-center space-y-4 md:space-y-0">
            <div className="text-white/60 text-sm">
              © 2025 WAGA DAO • Swiss Non-profit Association • Regenerative Coffee Finance
            </div>
            <div className="flex items-center space-x-6">
              <a href="#" className="text-white/60 hover:text-white text-sm transition-colors">
                Privacy Policy
              </a>
              <a href="#" className="text-white/60 hover:text-white text-sm transition-colors">
                Terms of Service
              </a>
              <div className="flex items-center space-x-2">
                <div className="w-2 h-2 bg-green-400 rounded-full animate-pulse"></div>
                <span className="text-green-400 text-sm">All Systems Operational</span>
              </div>
            </div>
          </div>
        </div>
      </footer>
    </div>
  )
}
