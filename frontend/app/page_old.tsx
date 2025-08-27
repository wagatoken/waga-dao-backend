"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import {
  Wallet,
  Coffee,
  Coins,
  Globe,
  Leaf,
  TrendingUp,
  Users,
  MapPin,
  Heart,
  ArrowRight,
  Play,
  Linkedin,
  MessageCircle,
  Twitter,
  Sparkles,
  Zap,
  Shield,
  Menu,
  X,
  ChevronDown,
} from "lucide-react"
import Link from "next/link"

interface NavigationItem {
  name: string
  href: string
  dropdown?: { name: string; href: string }[]
}

export default function WagaDAOLanding() {
  const [isWalletConnected, setIsWalletConnected] = useState(false)
  const [walletAddress, setWalletAddress] = useState("")
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false)
  const [dropdownOpen, setDropdownOpen] = useState<string | null>(null)
  const [animatedNumbers, setAnimatedNumbers] = useState({
    impact: 0,
    farmers: 0,
    cooperatives: 0,
    year: 2025,
  })

  const connectWallet = async () => {
    if (typeof window !== "undefined" && (window as any).ethereum) {
      try {
        const accounts = await (window as any).ethereum.request({
          method: "eth_requestAccounts",
        })
        setWalletAddress(accounts[0])
        setIsWalletConnected(true)
      } catch (error) {
        console.error("Failed to connect wallet:", error)
      }
    } else {
      alert("Please install MetaMask or another Web3 wallet")
    }
  }

  const disconnectWallet = () => {
    setIsWalletConnected(false)
    setWalletAddress("")
  }

  // Animate numbers on page load
  useEffect(() => {
    const timer = setTimeout(() => {
      setAnimatedNumbers({
        impact: 195,
        farmers: 4000,
        cooperatives: 40,
        year: 2030,
      })
    }, 500)

    return () => clearTimeout(timer)
  }, [])

  const navigationItems = [
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
                    className="text-white hover:text-amber-300 transition-colors duration-300 text-sm font-medium"
                  >
                    {item.name}
                  </Link>
                )}
              </div>
            ))}
          </div>

          <div className="flex items-center space-x-4">
            <Button
              onClick={isWalletConnected ? disconnectWallet : connectWallet}
              className="bg-gradient-to-r from-amber-500 to-green-600 hover:from-amber-600 hover:to-green-700 text-white shadow-lg border border-amber-400/30 transform transition-all duration-300 hover:scale-105 hover:shadow-xl"
            >
              <Wallet className="mr-2 h-4 w-4" />
              {isWalletConnected ? `${walletAddress.slice(0, 6)}...${walletAddress.slice(-4)}` : "Connect Wallet"}
            </Button>

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
        <div className="container mx-auto text-center max-w-6xl">
          <Badge className="mb-6 bg-gradient-to-r from-green-100 to-emerald-100 text-green-800 border border-green-300/50 px-4 py-2 text-sm shadow-lg animate-bounce">
            <Sparkles className="inline w-4 h-4 mr-2" />🌱 Launching September 2025 • ☕ Premium Coffee • 🔗 Blockchain
            • 🌍 Global Impact • 🤝 Community Driven • 💚 Sustainable Future
          </Badge>

          <h1 className="text-5xl md:text-7xl font-bold mb-8 bg-gradient-to-r from-amber-700 via-green-700 to-emerald-800 bg-clip-text text-transparent leading-tight animate-fade-in">
            Regenerating African Coffee Economies
          </h1>

          <p className="text-xl md:text-2xl text-gray-700 mb-12 max-w-3xl mx-auto leading-relaxed animate-fade-in-delay">
            Empowering African coffee cooperatives through blockchain-backed grants, AI, and gold-backed funding.
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center mb-16">
            <Link href="/grants">
              <Button
                size="lg"
                className="bg-gradient-to-r from-amber-500 to-green-600 hover:from-amber-600 hover:to-green-700 text-white shadow-xl px-8 py-4 text-lg transform transition-all duration-300 hover:scale-105 hover:shadow-2xl animate-pulse-slow"
              >
                <Heart className="mr-2 h-5 w-5" />
                View Grant Dashboard
                <ArrowRight className="ml-2 h-5 w-5 transition-transform duration-300 group-hover:translate-x-1" />
              </Button>
            </Link>
            <Link href="/grants">
              <Button
                size="lg"
                variant="outline"
                className="border-2 border-green-300 text-green-700 hover:bg-green-50 px-8 py-4 text-lg bg-white/50 transform transition-all duration-300 hover:scale-105 hover:shadow-xl"
              >
                <Coffee className="mr-2 h-5 w-5" />
                Coffee Grants
              </Button>
            </Link>
          </div>

          {/* Animated Impact Numbers */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8 max-w-4xl mx-auto">
            <div className="text-center transform transition-all duration-700 hover:scale-110">
              <div className="text-4xl font-bold text-amber-600 mb-2 transition-all duration-1000">
                ${animatedNumbers.impact}M
              </div>
              <div className="text-sm text-gray-600">Projected Impact by 2030</div>
            </div>
            <div className="text-center transform transition-all duration-700 hover:scale-110">
              <div className="text-4xl font-bold text-green-600 mb-2 transition-all duration-1000">
                {animatedNumbers.farmers.toLocaleString()}+
              </div>
              <div className="text-sm text-gray-600">Target Farmers by 2030</div>
            </div>
            <div className="text-center transform transition-all duration-700 hover:scale-110">
              <div className="text-4xl font-bold text-emerald-600 mb-2 transition-all duration-1000">
                {animatedNumbers.cooperatives}+
              </div>
              <div className="text-sm text-gray-600">Target Cooperatives</div>
            </div>
            <div className="text-center transform transition-all duration-700 hover:scale-110">
              <div className="text-4xl font-bold text-amber-600 mb-2 transition-all duration-1000">
                {animatedNumbers.year}
              </div>
              <div className="text-sm text-gray-600">Full Scale Target</div>
            </div>
          </div>
        </div>
      </section>

      {/* Mission Cards */}
      <section className="py-20 px-6 bg-gradient-to-br from-white/60 via-green-50/60 to-emerald-100/80 relative">
        <div className="absolute inset-0 bg-gradient-to-r from-green-800/5 to-emerald-900/5"></div>
        <div className="container mx-auto max-w-6xl relative">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4 bg-gradient-to-r from-amber-700 to-green-700 bg-clip-text text-transparent">
              From Farm to Cup
            </h2>
            <p className="text-xl text-gray-600">Transparent, traceable, transformative</p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            <Card className="bg-white/80 backdrop-blur-sm border-amber-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:rotate-1 group">
              <CardContent className="p-8 text-center">
                <div className="w-16 h-16 bg-gradient-to-br from-amber-400 to-amber-600 rounded-2xl flex items-center justify-center mx-auto mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Coins className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-amber-700 mb-4 group-hover:text-amber-600 transition-colors">
                  Gold-Backed Treasury
                </h3>
                <p className="text-gray-600 group-hover:text-gray-700 transition-colors">
                  PAXG/XAUT collateral enables immediate USDC grants to cooperatives
                </p>
                <div className="absolute top-4 right-4 opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                  <Sparkles className="h-5 w-5 text-amber-500" />
                </div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-green-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:-rotate-1 group">
              <CardContent className="p-8 text-center">
                <div className="w-16 h-16 bg-gradient-to-br from-green-400 to-green-600 rounded-2xl flex items-center justify-center mx-auto mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Coffee className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-green-700 mb-4 group-hover:text-green-600 transition-colors">
                  Traceable Coffee
                </h3>
                <p className="text-gray-600 group-hover:text-gray-700 transition-colors">
                  AI + blockchain verify every batch from farm to your cup
                </p>
                <div className="absolute top-4 right-4 opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                  <Zap className="h-5 w-5 text-green-500" />
                </div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-emerald-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:rotate-1 group">
              <CardContent className="p-8 text-center">
                <div className="w-16 h-16 bg-gradient-to-br from-emerald-400 to-emerald-600 rounded-2xl flex items-center justify-center mx-auto mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Users className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-emerald-700 mb-4 group-hover:text-emerald-600 transition-colors">
                  Community Owned
                </h3>
                <p className="text-gray-600 group-hover:text-gray-700 transition-colors">
                  DAO governance ensures farmers and supporters lead together
                </p>
                <div className="absolute top-4 right-4 opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                  <Shield className="h-5 w-5 text-emerald-500" />
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Locations */}
      <section className="py-20 px-6">
        <div className="container mx-auto max-w-6xl">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4 bg-gradient-to-r from-amber-700 to-green-700 bg-clip-text text-transparent">
              Where We'll Work
            </h2>
          </div>

          <div className="grid md:grid-cols-2 gap-12">
            <Card className="bg-gradient-to-br from-amber-50 to-orange-50 border-amber-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:scale-105 group overflow-hidden">
              <div className="absolute inset-0 bg-gradient-to-br from-amber-400/10 to-orange-400/10 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
              <CardContent className="p-8 relative z-10">
                <div className="flex items-center mb-6">
                  <MapPin className="h-6 w-6 text-amber-600 mr-3 transition-transform duration-300 group-hover:scale-125" />
                  <h3 className="text-2xl font-bold text-amber-700">Bamendakwe, Cameroon</h3>
                </div>
                <p className="text-gray-700 mb-4">Post-conflict zone requiring full infrastructure development</p>
                <div className="flex items-center text-sm text-amber-600">
                  <Leaf className="h-4 w-4 mr-2 transition-transform duration-300 group-hover:rotate-12" />
                  New agroforestry plantations planned
                </div>
              </CardContent>
            </Card>

            <Card className="bg-gradient-to-br from-green-50 to-emerald-50 border-green-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:scale-105 group overflow-hidden">
              <div className="absolute inset-0 bg-gradient-to-br from-green-400/10 to-emerald-400/10 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
              <CardContent className="p-8 relative z-10">
                <div className="flex items-center mb-6">
                  <MapPin className="h-6 w-6 text-green-600 mr-3 transition-transform duration-300 group-hover:scale-125" />
                  <h3 className="text-2xl font-bold text-green-700">Highland Ethiopia</h3>
                </div>
                <p className="text-gray-700 mb-4">Existing cooperatives ready for digital integration</p>
                <div className="flex items-center text-sm text-green-600">
                  <TrendingUp className="h-4 w-4 mr-2 transition-transform duration-300 group-hover:rotate-12" />
                  Immediate production scaling potential
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Donation CTA */}
      <section className="py-20 px-6 bg-gradient-to-r from-green-800 to-emerald-900 relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-amber-900/20 to-green-900/20"></div>
        {/* Animated background elements */}
        <div className="absolute top-10 left-10 w-20 h-20 bg-amber-400/20 rounded-full blur-xl animate-pulse"></div>
        <div className="absolute bottom-10 right-10 w-32 h-32 bg-green-400/20 rounded-full blur-xl animate-pulse delay-1000"></div>

        <div className="container mx-auto max-w-4xl text-center relative z-10">
          <div className="bg-white/95 backdrop-blur-sm rounded-3xl p-12 shadow-2xl border border-emerald-200 transform transition-all duration-500 hover:scale-105">
            <h2 className="text-4xl font-bold mb-6 bg-gradient-to-r from-amber-700 to-green-700 bg-clip-text text-transparent">
              Support Regenerative Agriculture
            </h2>
            <p className="text-xl text-gray-700 mb-8">
              Help us launch sustainable coffee economies in Africa - launching September 2025
            </p>

            <div className="flex flex-col sm:flex-row gap-4 justify-center mb-8">
              <Button
                size="lg"
                className="bg-gradient-to-r from-amber-500 to-green-600 hover:from-amber-600 hover:to-green-700 text-white shadow-xl px-12 py-4 text-lg transform transition-all duration-300 hover:scale-110 hover:shadow-2xl group"
              >
                <Heart className="mr-2 h-5 w-5 group-hover:animate-pulse" />
                Early Supporter Access
              </Button>
              <Button
                size="lg"
                className="bg-gradient-to-r from-green-700 to-emerald-800 hover:from-green-800 hover:to-emerald-900 text-white shadow-xl px-12 py-4 text-lg transform transition-all duration-300 hover:scale-110 hover:shadow-2xl group"
              >
                <Coins className="mr-2 h-5 w-5 group-hover:animate-spin" />
                Join Waitlist
              </Button>
            </div>

            <p className="text-sm text-gray-600">
              WAGA DAO is a Swiss non-profit association dedicated to regenerating African economies
            </p>
          </div>
        </div>
      </section>

      {/* Simple Footer */}
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
              {/* Contact Email */}
              <a
                href="mailto:team@wagatoken.io"
                className="hover:text-amber-300 transition-all duration-300 hover:scale-105 text-center"
              >
                team@wagatoken.io
              </a>

              {/* Website */}
              <a
                href="https://wagadao.io"
                className="hover:text-amber-300 transition-all duration-300 hover:scale-105 flex items-center"
              >
                <Globe className="h-4 w-4 mr-1" />
                wagadao.io
              </a>

              {/* Social Media Links */}
              <div className="flex items-center space-x-4">
                <a
                  href="https://linkedin.com/company/wagadao"
                  className="hover:text-amber-300 transition-all duration-300 p-2 hover:bg-white/10 rounded-lg transform hover:scale-110 hover:rotate-12"
                  aria-label="LinkedIn"
                >
                  <Linkedin className="h-5 w-5" />
                </a>
                <a
                  href="https://t.me/wagadao"
                  className="hover:text-amber-300 transition-all duration-300 p-2 hover:bg-white/10 rounded-lg transform hover:scale-110 hover:rotate-12"
                  aria-label="Telegram"
                >
                  <MessageCircle className="h-5 w-5" />
                </a>
                <a
                  href="https://twitter.com/wagadao"
                  className="hover:text-amber-300 transition-all duration-300 p-2 hover:bg-white/10 rounded-lg transform hover:scale-110 hover:rotate-12"
                  aria-label="Twitter"
                >
                  <Twitter className="h-5 w-5" />
                </a>
                <a
                  href="https://discord.gg/wagadao"
                  className="hover:text-amber-300 transition-all duration-300 p-2 hover:bg-white/10 rounded-lg transform hover:scale-110 hover:rotate-12"
                  aria-label="Discord"
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

      <style jsx>{`
        @keyframes fade-in {
          from {
            opacity: 0;
            transform: translateY(20px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }

        @keyframes fade-in-delay {
          from {
            opacity: 0;
            transform: translateY(20px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }

        @keyframes pulse-slow {
          0%, 100% {
            opacity: 1;
          }
          50% {
            opacity: 0.8;
          }
        }

        .animate-fade-in {
          animation: fade-in 1s ease-out;
        }

        .animate-fade-in-delay {
          animation: fade-in-delay 1s ease-out 0.3s both;
        }

        .animate-pulse-slow {
          animation: pulse-slow 3s ease-in-out infinite;
        }
      `}</style>
    </div>
  )
}
