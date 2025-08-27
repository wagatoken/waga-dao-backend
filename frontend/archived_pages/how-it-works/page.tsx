"use client"

import { Card, CardContent } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import {
  Coffee,
  Globe,
  Linkedin,
  MessageCircle,
  Twitter,
  ArrowRight,
  Coins,
  Users,
  Zap,
  Shield,
  TrendingUp,
  RefreshCw,
  Database,
  Eye,
  ArrowLeft,
  Menu,
  X,
  ChevronDown,
} from "lucide-react"
import Link from "next/link"
import { useState } from "react"

interface NavigationItem {
  name: string
  href: string
  dropdown?: { name: string; href: string }[]
}

export default function HowItWorksPage() {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false)
  const [dropdownOpen, setDropdownOpen] = useState<string | null>(null)

  const navigationItems: NavigationItem[] = [
    { name: "About", href: "/about" },
    { name: "How It Works", href: "/how-it-works" },
    { name: "Portals", href: "#", dropdown: [
        { name: "Cooperative Portal", href: "/portal/cooperative" },
        { name: "Admin Portal", href: "/portal/admin" },
        { name: "DAO Portal", href: "/portal/dao" }
      ]
    },
    { name: "Tokenomics", href: "/tokenomics" },
    { name: "Get Started", href: "/get-started" }
  ]

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
            {navigationItems.map((item) => (
              <div key={item.name} className="relative">
                {item.dropdown ? (
                  <div
                    className="flex items-center cursor-pointer text-white hover:text-amber-300 transition-colors duration-300 text-sm font-medium"
                    onMouseEnter={() => setDropdownOpen(item.name)}
                    onMouseLeave={() => setDropdownOpen(null)}
                  >
                    <span>{item.name}</span>
                    <ChevronDown className="ml-1 h-4 w-4" />
                    
                    {/* Dropdown Menu */}
                    {dropdownOpen === item.name && (
                      <div className="absolute top-full left-0 mt-2 w-48 bg-white rounded-lg shadow-xl border border-gray-200 py-2 z-50">
                        {item.dropdown.map((dropdownItem) => (
                          <Link
                            key={dropdownItem.name}
                            href={dropdownItem.href}
                            className="block px-4 py-2 text-sm text-gray-700 hover:bg-green-50 hover:text-green-600 transition-colors"
                          >
                            {dropdownItem.name}
                          </Link>
                        ))}
                      </div>
                    )}
                  </div>
                ) : (
                  <Link
                    href={item.href}
                    className={`text-white hover:text-amber-300 transition-colors duration-300 text-sm font-medium ${
                      item.name === "How It Works" ? "text-amber-300" : ""
                    }`}
                  >
                    {item.name}
                  </Link>
                )}
              </div>
            ))}
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
              {navigationItems.map((item) => (
                <div key={item.name}>
                  {item.dropdown ? (
                    <div>
                      <div className="text-white font-medium py-2 text-sm border-b border-emerald-700/50">
                        {item.name}
                      </div>
                      {item.dropdown.map((dropdownItem) => (
                        <Link
                          key={dropdownItem.name}
                          href={dropdownItem.href}
                          className="block text-white/80 hover:text-amber-300 transition-colors duration-300 py-2 pl-4 text-sm"
                          onClick={() => setIsMobileMenuOpen(false)}
                        >
                          {dropdownItem.name}
                        </Link>
                      ))}
                    </div>
                  ) : (
                    <Link
                      href={item.href}
                      className="block text-white hover:text-amber-300 transition-colors duration-300 py-2 text-sm font-medium"
                      onClick={() => setIsMobileMenuOpen(false)}
                    >
                      {item.name}
                    </Link>
                  )}
                </div>
              ))}
            </div>
          </div>
        )}
      </nav>

      {/* Hero Section */}
      <section className="pt-32 pb-20 px-6 relative">
        <div className="container mx-auto text-center max-w-4xl">
          <Badge className="mb-6 bg-gradient-to-r from-green-100 to-emerald-100 text-green-800 border border-green-300/50 px-4 py-2 text-sm shadow-lg">
            ⚙️ How It Works
          </Badge>

          <h1 className="text-5xl md:text-6xl font-bold mb-8 bg-gradient-to-r from-amber-700 via-green-700 to-emerald-800 bg-clip-text text-transparent leading-tight">
            System Architecture & Workflow
          </h1>

          <p className="text-xl text-gray-700 mb-12 max-w-3xl mx-auto leading-relaxed">
            Discover how WAGA DAO transforms coffee economies through innovative blockchain technology and sustainable
            funding models.
          </p>
        </div>
      </section>

      {/* System Workflow */}
      <section className="py-20 px-6 bg-gradient-to-br from-white/60 via-green-50/60 to-emerald-100/80 relative">
        <div className="absolute inset-0 bg-gradient-to-r from-green-800/5 to-emerald-900/5"></div>
        <div className="container mx-auto max-w-6xl relative">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4 bg-gradient-to-r from-amber-700 to-green-700 bg-clip-text text-transparent">
              5-Step Process
            </h2>
            <p className="text-xl text-gray-600">From treasury formation to sustainable reflow</p>
          </div>

          <div className="space-y-8">
            {/* Step 1 */}
            <Card className="bg-white/80 backdrop-blur-sm border-amber-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-2 group">
              <CardContent className="p-8">
                <div className="flex items-start space-x-6">
                  <div className="w-16 h-16 bg-gradient-to-br from-amber-400 to-amber-600 rounded-2xl flex items-center justify-center flex-shrink-0 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                    <Coins className="h-8 w-8 text-white" />
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center mb-4">
                      <span className="bg-amber-100 text-amber-800 text-sm font-bold px-3 py-1 rounded-full mr-4">
                        Step 1
                      </span>
                      <h3 className="text-2xl font-bold text-amber-700">DAO Treasury Formation</h3>
                    </div>
                    <p className="text-gray-700 text-lg mb-4">
                      DAO collects PAXG/XAUT from donors and partners. Gold is held in multisig-controlled vault as
                      collateral.
                    </p>
                    <div className="flex items-center text-amber-600">
                      <Shield className="h-4 w-4 mr-2" />
                      <span className="text-sm">Secure multisig treasury management</span>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Arrow */}
            <div className="flex justify-center">
              <ArrowRight className="h-8 w-8 text-green-600 animate-pulse" />
            </div>

            {/* Step 2 */}
            <Card className="bg-white/80 backdrop-blur-sm border-green-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-2 group">
              <CardContent className="p-8">
                <div className="flex items-start space-x-6">
                  <div className="w-16 h-16 bg-gradient-to-br from-green-400 to-green-600 rounded-2xl flex items-center justify-center flex-shrink-0 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                    <Zap className="h-8 w-8 text-white" />
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center mb-4">
                      <span className="bg-green-100 text-green-800 text-sm font-bold px-3 py-1 rounded-full mr-4">
                        Step 2
                      </span>
                      <h3 className="text-2xl font-bold text-green-700">Liquidity Unlock</h3>
                    </div>
                    <p className="text-gray-700 text-lg mb-4">
                      DAO borrows USDC from DeFi protocols against gold reserves. USDC is deployed to cooperatives via
                      programmable disbursement.
                    </p>
                    <div className="flex items-center text-green-600">
                      <TrendingUp className="h-4 w-4 mr-2" />
                      <span className="text-sm">DeFi-powered capital deployment</span>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Arrow */}
            <div className="flex justify-center">
              <ArrowRight className="h-8 w-8 text-green-600 animate-pulse" />
            </div>

            {/* Step 3 */}
            <Card className="bg-white/80 backdrop-blur-sm border-emerald-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-2 group">
              <CardContent className="p-8">
                <div className="flex items-start space-x-6">
                  <div className="w-16 h-16 bg-gradient-to-br from-emerald-400 to-emerald-600 rounded-2xl flex items-center justify-center flex-shrink-0 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                    <Users className="h-8 w-8 text-white" />
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center mb-4">
                      <span className="bg-emerald-100 text-emerald-800 text-sm font-bold px-3 py-1 rounded-full mr-4">
                        Step 3
                      </span>
                      <h3 className="text-2xl font-bold text-emerald-700">Cooperative Integration</h3>
                    </div>
                    <p className="text-gray-700 text-lg mb-4">
                      Cameroon: New farm development and infrastructure buildout. Ethiopia: Upgrade drying stations,
                      integrate traceability, and sign MOUs.
                    </p>
                    <div className="flex items-center text-emerald-600">
                      <Coffee className="h-4 w-4 mr-2" />
                      <span className="text-sm">Direct farmer empowerment</span>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Arrow */}
            <div className="flex justify-center">
              <ArrowRight className="h-8 w-8 text-green-600 animate-pulse" />
            </div>

            {/* Step 4 */}
            <Card className="bg-white/80 backdrop-blur-sm border-blue-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-2 group">
              <CardContent className="p-8">
                <div className="flex items-start space-x-6">
                  <div className="w-16 h-16 bg-gradient-to-br from-blue-400 to-blue-600 rounded-2xl flex items-center justify-center flex-shrink-0 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                    <Database className="h-8 w-8 text-white" />
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center mb-4">
                      <span className="bg-blue-100 text-blue-800 text-sm font-bold px-3 py-1 rounded-full mr-4">
                        Step 4
                      </span>
                      <h3 className="text-2xl font-bold text-blue-700">Tokenized Inventory Management</h3>
                    </div>
                    <p className="text-gray-700 text-lg mb-4">
                      DAO mints Inventory Tokens (ERC-1155) representing finished product coffee batches. Used for
                      logistics, warehouse management, and vendor distribution contracts.
                    </p>
                    <div className="flex items-center text-blue-600">
                      <Eye className="h-4 w-4 mr-2" />
                      <span className="text-sm">Transparent supply chain tracking</span>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Arrow */}
            <div className="flex justify-center">
              <ArrowRight className="h-8 w-8 text-green-600 animate-pulse" />
            </div>

            {/* Step 5 */}
            <Card className="bg-white/80 backdrop-blur-sm border-purple-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-2 group">
              <CardContent className="p-8">
                <div className="flex items-start space-x-6">
                  <div className="w-16 h-16 bg-gradient-to-br from-purple-400 to-purple-600 rounded-2xl flex items-center justify-center flex-shrink-0 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                    <RefreshCw className="h-8 w-8 text-white" />
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center mb-4">
                      <span className="bg-purple-100 text-purple-800 text-sm font-bold px-3 py-1 rounded-full mr-4">
                        Step 5
                      </span>
                      <h3 className="text-2xl font-bold text-purple-700">Grant Impact & Growth</h3>
                    </div>
                    <p className="text-gray-700 text-lg mb-4">
                      DAO sells inventory tokens representing finished coffee to reinvest in cooperative development. Successful cooperatives 
                      contribute to the gold treasury, enabling expansion to new regions and scaling regenerative practices.
                    </p>
                    <div className="flex items-center text-purple-600">
                      <RefreshCw className="h-4 w-4 mr-2" />
                      <span className="text-sm">Sustainable regenerative growth cycle</span>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Treasury Flow Diagram */}
      <section className="py-20 px-6">
        <div className="container mx-auto max-w-6xl">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4 bg-gradient-to-r from-amber-700 to-green-700 bg-clip-text text-transparent">
              Treasury Flow
            </h2>
            <p className="text-xl text-gray-600">Visual representation of fund movement</p>
          </div>

          <Card className="bg-white/80 backdrop-blur-sm border-green-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:scale-105">
            <CardContent className="p-12">
              <div className="grid md:grid-cols-3 gap-8 items-center">
                <div className="text-center">
                  <div className="w-20 h-20 bg-gradient-to-br from-amber-400 to-amber-600 rounded-full flex items-center justify-center mx-auto mb-4 transition-all duration-300 hover:scale-110">
                    <Coins className="h-10 w-10 text-white" />
                  </div>
                  <h3 className="text-lg font-bold text-amber-700 mb-2">Gold Treasury</h3>
                  <p className="text-sm text-gray-600">PAXG/XAUT collateral from donors</p>
                </div>

                <div className="text-center">
                  <div className="w-20 h-20 bg-gradient-to-br from-green-400 to-green-600 rounded-full flex items-center justify-center mx-auto mb-4 transition-all duration-300 hover:scale-110">
                    <Users className="h-10 w-10 text-white" />
                  </div>
                  <h3 className="text-lg font-bold text-green-700 mb-2">Cooperatives</h3>
                  <p className="text-sm text-gray-600">USDC grants for infrastructure</p>
                </div>

                <div className="text-center">
                  <div className="w-20 h-20 bg-gradient-to-br from-emerald-400 to-emerald-600 rounded-full flex items-center justify-center mx-auto mb-4 transition-all duration-300 hover:scale-110">
                    <RefreshCw className="h-10 w-10 text-white" />
                  </div>
                  <h3 className="text-lg font-bold text-emerald-700 mb-2">Reflow</h3>
                  <p className="text-sm text-gray-600">Surplus returns to treasury</p>
                </div>
              </div>

              <div className="mt-8 text-center">
                <p className="text-gray-700 text-lg">
                  <span className="font-semibold text-amber-700">Gold Treasury</span> →
                  <span className="font-semibold text-green-700 mx-2">USDC Grants</span> →
                  <span className="font-semibold text-emerald-700">Regenerative Impact</span>
                </p>
              </div>
            </CardContent>
          </Card>
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
              Ready to Learn More?
            </h2>
            <p className="text-xl text-gray-700 mb-8">Explore our tokenomics and technology stack</p>

            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link href="/tokenomics">
                <Button
                  size="lg"
                  className="bg-gradient-to-r from-amber-500 to-green-600 hover:from-amber-600 hover:to-green-700 text-white shadow-xl px-12 py-4 text-lg transform transition-all duration-300 hover:scale-110 hover:shadow-2xl"
                >
                  <Coins className="mr-2 h-5 w-5" />
                  View Tokenomics
                </Button>
              </Link>
              <Link href="/technology">
                <Button
                  size="lg"
                  variant="outline"
                  className="border-2 border-green-300 text-green-700 hover:bg-green-50 px-12 py-4 text-lg bg-white/50 transform transition-all duration-300 hover:scale-105"
                >
                  <Zap className="mr-2 h-5 w-5" />
                  Technology Stack
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
