"use client"

import { useState } from "react"
import { Card, CardContent } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import {
  Coffee,
  Globe,
  Linkedin,
  MessageCircle,
  Twitter,
  Star,
  Award,
  Leaf,
  Mountain,
  Thermometer,
  Droplets,
  Eye,
  Shield,
  QrCode,
  Heart,
  ArrowLeft,
  Menu,
  X,
} from "lucide-react"
import Link from "next/link"

export default function CoffeePage() {
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
            ☕ Premium Coffee
          </Badge>

          <h1 className="text-5xl md:text-6xl font-bold mb-8 bg-gradient-to-r from-amber-700 via-green-700 to-emerald-800 bg-clip-text text-transparent leading-tight">
            Traceable Premium Coffee
          </h1>

          <p className="text-xl text-gray-700 mb-12 max-w-3xl mx-auto leading-relaxed">
            Discover our planned transparent coffee supply chain launching September 2025. Every future cup will tell a
            story of regenerative agriculture, fair trade, and blockchain verification.
          </p>
        </div>
      </section>

      {/* Coffee Origins */}
      <section className="py-20 px-6 bg-gradient-to-br from-white/60 via-green-50/60 to-emerald-100/80 relative">
        <div className="absolute inset-0 bg-gradient-to-r from-green-800/5 to-emerald-900/5"></div>
        <div className="container mx-auto max-w-6xl relative">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4 bg-gradient-to-r from-amber-700 to-green-700 bg-clip-text text-transparent">
              Our Coffee Origins
            </h2>
            <p className="text-xl text-gray-600">Premium arabica from Africa's finest growing regions</p>
          </div>

          <div className="grid md:grid-cols-2 gap-12">
            <Card className="bg-gradient-to-br from-amber-50 to-orange-50 border-amber-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:rotate-1 group overflow-hidden">
              <div className="absolute inset-0 bg-gradient-to-br from-amber-400/10 to-orange-400/10 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
              <CardContent className="p-8 relative z-10">
                <div className="flex items-center mb-6">
                  <Mountain className="h-8 w-8 text-amber-600 mr-4 transition-transform duration-300 group-hover:scale-125" />
                  <div>
                    <h3 className="text-3xl font-bold text-amber-700">Bamendakwe Highlands</h3>
                    <p className="text-amber-600">Cameroon • 1,400-1,800m elevation</p>
                  </div>
                </div>

                <div className="space-y-4 mb-6">
                  <div className="bg-amber-100/50 rounded-lg p-4">
                    <h4 className="font-semibold text-amber-800 mb-2">Flavor Profile</h4>
                    <p className="text-amber-700 text-sm">
                      Bright acidity with notes of citrus, chocolate, and floral undertones. Medium body with a clean,
                      lingering finish.
                    </p>
                  </div>
                  <div className="bg-amber-100/50 rounded-lg p-4">
                    <h4 className="font-semibold text-amber-800 mb-2">Processing</h4>
                    <p className="text-amber-700 text-sm">
                      Washed process with 48-hour fermentation. Sun-dried on raised beds for optimal flavor development.
                    </p>
                  </div>
                  <div className="bg-amber-100/50 rounded-lg p-4">
                    <h4 className="font-semibold text-amber-800 mb-2">Sustainability</h4>
                    <p className="text-amber-700 text-sm">
                      Agroforestry systems with shade trees. Organic practices with zero chemical inputs.
                    </p>
                  </div>
                </div>

                <div className="flex items-center justify-between">
                  <div className="flex items-center space-x-1">
                    {[1, 2, 3, 4, 5].map((star) => (
                      <Star key={star} className="h-4 w-4 fill-amber-400 text-amber-400" />
                    ))}
                    <span className="text-sm text-amber-600 ml-2">SCA Score: 86+</span>
                  </div>
                  <Badge className="bg-amber-100 text-amber-800">First Harvest 2026</Badge>
                </div>
              </CardContent>
            </Card>

            <Card className="bg-gradient-to-br from-green-50 to-emerald-50 border-green-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:-rotate-1 group overflow-hidden">
              <div className="absolute inset-0 bg-gradient-to-br from-green-400/10 to-emerald-400/10 opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
              <CardContent className="p-8 relative z-10">
                <div className="flex items-center mb-6">
                  <Mountain className="h-8 w-8 text-green-600 mr-4 transition-transform duration-300 group-hover:scale-125" />
                  <div>
                    <h3 className="text-3xl font-bold text-green-700">Ethiopian Highlands</h3>
                    <p className="text-green-600">Ethiopia • 1,800-2,200m elevation</p>
                  </div>
                </div>

                <div className="space-y-4 mb-6">
                  <div className="bg-green-100/50 rounded-lg p-4">
                    <h4 className="font-semibold text-green-800 mb-2">Flavor Profile</h4>
                    <p className="text-green-700 text-sm">
                      Complex wine-like acidity with berry, stone fruit, and tea-like qualities. Full body with
                      exceptional clarity.
                    </p>
                  </div>
                  <div className="bg-green-100/50 rounded-lg p-4">
                    <h4 className="font-semibold text-green-800 mb-2">Processing</h4>
                    <p className="text-green-700 text-sm">
                      Natural and washed processing. Traditional methods passed down through generations of farmers.
                    </p>
                  </div>
                  <div className="bg-green-100/50 rounded-lg p-4">
                    <h4 className="font-semibold text-green-800 mb-2">Sustainability</h4>
                    <p className="text-green-700 text-sm">
                      Heirloom varieties in forest gardens. Certified organic and bird-friendly practices.
                    </p>
                  </div>
                </div>

                <div className="flex items-center justify-between">
                  <div className="flex items-center space-x-1">
                    {[1, 2, 3, 4, 5].map((star) => (
                      <Star key={star} className="h-4 w-4 fill-green-400 text-green-400" />
                    ))}
                    <span className="text-sm text-green-600 ml-2">SCA Score: 88+</span>
                  </div>
                  <Badge className="bg-green-100 text-green-800">First Harvest Q2 2026</Badge>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Traceability Features */}
      <section className="py-20 px-6">
        <div className="container mx-auto max-w-6xl">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4 bg-gradient-to-r from-amber-700 to-green-700 bg-clip-text text-transparent">
              Planned Complete Traceability
            </h2>
            <p className="text-xl text-gray-600">Planned blockchain-verified journey from farm to cup</p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            <Card className="bg-white/80 backdrop-blur-sm border-amber-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:rotate-1 group">
              <CardContent className="p-6 text-center">
                <div className="w-12 h-12 bg-gradient-to-br from-amber-400 to-amber-600 rounded-xl flex items-center justify-center mx-auto mb-4 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Leaf className="h-6 w-6 text-white" />
                </div>
                <h4 className="text-lg font-bold text-amber-700 mb-3">Farm Origin</h4>
                <p className="text-gray-600 text-sm">
                  GPS coordinates, farmer details, and cultivation methods to be recorded on blockchain
                </p>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-green-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:-rotate-1 group">
              <CardContent className="p-6 text-center">
                <div className="w-12 h-12 bg-gradient-to-br from-green-400 to-green-600 rounded-xl flex items-center justify-center mx-auto mb-4 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Thermometer className="h-6 w-6 text-white" />
                </div>
                <h4 className="text-lg font-bold text-green-700 mb-3">Processing</h4>
                <p className="text-gray-600 text-sm">
                  Fermentation time, drying conditions, and quality scores to be verified by AI
                </p>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-emerald-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:rotate-1 group">
              <CardContent className="p-6 text-center">
                <div className="w-12 h-12 bg-gradient-to-br from-emerald-400 to-emerald-600 rounded-xl flex items-center justify-center mx-auto mb-4 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Shield className="h-6 w-6 text-white" />
                </div>
                <h4 className="text-lg font-bold text-emerald-700 mb-3">Quality Control</h4>
                <p className="text-gray-600 text-sm">
                  Planned computer vision analysis and cupping scores to be immutably stored
                </p>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-blue-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:-rotate-1 group">
              <CardContent className="p-6 text-center">
                <div className="w-12 h-12 bg-gradient-to-br from-blue-400 to-blue-600 rounded-xl flex items-center justify-center mx-auto mb-4 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <QrCode className="h-6 w-6 text-white" />
                </div>
                <h4 className="text-lg font-bold text-blue-700 mb-3">Consumer Access</h4>
                <p className="text-gray-600 text-sm">
                  Planned QR code on every bag to reveal complete journey and impact metrics
                </p>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Quality Standards */}
      <section className="py-20 px-6 bg-gradient-to-br from-white/60 via-green-50/60 to-emerald-100/80 relative">
        <div className="absolute inset-0 bg-gradient-to-r from-green-800/5 to-emerald-900/5"></div>
        <div className="container mx-auto max-w-6xl relative">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4 bg-gradient-to-r from-amber-700 to-green-700 bg-clip-text text-transparent">
              Target Quality Standards
            </h2>
            <p className="text-xl text-gray-600">Targeting international coffee quality benchmarks</p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            <Card className="bg-white/80 backdrop-blur-sm border-amber-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:rotate-1 group">
              <CardContent className="p-8 text-center">
                <div className="w-16 h-16 bg-gradient-to-br from-amber-400 to-amber-600 rounded-2xl flex items-center justify-center mx-auto mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Award className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-amber-700 mb-4">Target SCA Certification</h3>
                <p className="text-gray-600 mb-4">
                  All batches targeted to score 80+ on the Specialty Coffee Association scale, with many expected to
                  achieve 85+ specialty grade
                </p>
                <div className="text-sm text-amber-600 font-semibold">Target: Minimum 80 SCA Points</div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-green-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:-rotate-1 group">
              <CardContent className="p-8 text-center">
                <div className="w-16 h-16 bg-gradient-to-br from-green-400 to-green-600 rounded-2xl flex items-center justify-center mx-auto mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Leaf className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-green-700 mb-4">Organic Certified</h3>
                <p className="text-gray-600 mb-4">
                  Planned zero synthetic pesticides or fertilizers. Targeting organic certification by international
                  standards with regenerative practices
                </p>
                <div className="text-sm text-green-600 font-semibold">Target: USDA & EU Organic</div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-emerald-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:rotate-1 group">
              <CardContent className="p-8 text-center">
                <div className="w-16 h-16 bg-gradient-to-br from-emerald-400 to-emerald-600 rounded-2xl flex items-center justify-center mx-auto mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Heart className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-emerald-700 mb-4">Fair Trade Plus</h3>
                <p className="text-gray-600 mb-4">
                  Farmers projected to receive 70%+ of retail value through planned direct trade relationships and
                  cooperative ownership
                </p>
                <div className="text-sm text-emerald-600 font-semibold">Planned Direct Trade Premium</div>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Coffee Varieties */}
      <section className="py-20 px-6">
        <div className="container mx-auto max-w-6xl">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4 bg-gradient-to-r from-amber-700 to-green-700 bg-clip-text text-transparent">
              Selected Coffee Varieties
            </h2>
            <p className="text-xl text-gray-600">Planned heirloom and improved varieties for exceptional flavor</p>
          </div>

          <div className="grid md:grid-cols-2 gap-8">
            <Card className="bg-white/80 backdrop-blur-sm border-amber-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:scale-105 group">
              <CardContent className="p-8">
                <h3 className="text-2xl font-bold text-amber-700 mb-4">Cameroon Varieties</h3>
                <div className="space-y-4">
                  <div className="bg-amber-100/50 rounded-lg p-4">
                    <h4 className="font-semibold text-amber-800 mb-2">Blue Mountain</h4>
                    <p className="text-amber-700 text-sm">
                      Jamaican variety selected for Cameroon highlands. Exceptional balance and complexity.
                    </p>
                  </div>
                  <div className="bg-amber-100/50 rounded-lg p-4">
                    <h4 className="font-semibold text-amber-800 mb-2">Bourbon Rouge</h4>
                    <p className="text-amber-700 text-sm">
                      Selected traditional French colonial variety. Sweet, wine-like acidity with chocolate undertones.
                    </p>
                  </div>
                  <div className="bg-amber-100/50 rounded-lg p-4">
                    <h4 className="font-semibold text-amber-800 mb-2">Catimor</h4>
                    <p className="text-amber-700 text-sm">
                      Selected disease-resistant hybrid for excellent yield potential. Clean cup with bright citrus
                      notes.
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-green-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:scale-105 group">
              <CardContent className="p-8">
                <h3 className="text-2xl font-bold text-green-700 mb-4">Ethiopian Heirlooms</h3>
                <div className="space-y-4">
                  <div className="bg-green-100/50 rounded-lg p-4">
                    <h4 className="font-semibold text-green-800 mb-2">Yirgacheffe Heirloom</h4>
                    <p className="text-green-700 text-sm">
                      Selected ancient varieties known for floral, tea-like qualities. Bright acidity and exceptional
                      clarity.
                    </p>
                  </div>
                  <div className="bg-green-100/50 rounded-lg p-4">
                    <h4 className="font-semibold text-green-800 mb-2">Sidamo Landraces</h4>
                    <p className="text-green-700 text-sm">
                      Selected wild forest varieties known for wine-like complexity. Berry and stone fruit
                      characteristics.
                    </p>
                  </div>
                  <div className="bg-green-100/50 rounded-lg p-4">
                    <h4 className="font-semibold text-green-800 mb-2">Harrar Longberry</h4>
                    <p className="text-green-700 text-sm">
                      Selected traditional dry-processed variety. Full body with blueberry and chocolate notes.
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Environmental Impact */}
      <section className="py-20 px-6 bg-gradient-to-br from-white/60 via-green-50/60 to-emerald-100/80 relative">
        <div className="absolute inset-0 bg-gradient-to-r from-green-800/5 to-emerald-900/5"></div>
        <div className="container mx-auto max-w-6xl relative">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4 bg-gradient-to-r from-amber-700 to-green-700 bg-clip-text text-transparent">
              Projected Environmental Impact
            </h2>
            <p className="text-xl text-gray-600">Planned regenerative agriculture for climate resilience</p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            <Card className="bg-white/80 backdrop-blur-sm border-green-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:scale-105 group">
              <CardContent className="p-6 text-center">
                <div className="w-12 h-12 bg-gradient-to-br from-green-400 to-green-600 rounded-xl flex items-center justify-center mx-auto mb-4 transition-all duration-300 group-hover:scale-110">
                  <Leaf className="h-6 w-6 text-white" />
                </div>
                <div className="text-2xl font-bold text-green-600 mb-2">Target: -2.5 kg</div>
                <div className="text-sm text-gray-600 mb-2">CO₂ per kg coffee</div>
                <div className="text-xs text-gray-500">Projected carbon negative production</div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-blue-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:scale-105 group">
              <CardContent className="p-6 text-center">
                <div className="w-12 h-12 bg-gradient-to-br from-blue-400 to-blue-600 rounded-xl flex items-center justify-center mx-auto mb-4 transition-all duration-300 group-hover:scale-110">
                  <Droplets className="h-6 w-6 text-white" />
                </div>
                <div className="text-2xl font-bold text-blue-600 mb-2">Target: 50%</div>
                <div className="text-sm text-gray-600 mb-2">Water reduction</div>
                <div className="text-xs text-gray-500">vs projected conventional processing</div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-emerald-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:scale-105 group">
              <CardContent className="p-6 text-center">
                <div className="w-12 h-12 bg-gradient-to-br from-emerald-400 to-emerald-600 rounded-xl flex items-center justify-center mx-auto mb-4 transition-all duration-300 group-hover:scale-110">
                  <Mountain className="h-6 w-6 text-white" />
                </div>
                <div className="text-2xl font-bold text-emerald-600 mb-2">Target: 85%</div>
                <div className="text-sm text-gray-600 mb-2">Biodiversity increase</div>
                <div className="text-xs text-gray-500">in planned agroforestry systems</div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-amber-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:scale-105 group">
              <CardContent className="p-6 text-center">
                <div className="w-12 h-12 bg-gradient-to-br from-amber-400 to-amber-600 rounded-xl flex items-center justify-center mx-auto mb-4 transition-all duration-300 group-hover:scale-110">
                  <Award className="h-6 w-6 text-white" />
                </div>
                <div className="text-2xl font-bold text-amber-600 mb-2">Target: 100%</div>
                <div className="text-sm text-gray-600 mb-2">Soil health improvement</div>
                <div className="text-xs text-gray-500">projected over 3 years</div>
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
              Reserve Premium Coffee
            </h2>
            <p className="text-xl text-gray-700 mb-8">
              Be among the first to experience blockchain-verified, regenerative coffee when we launch
            </p>

            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link href="/get-involved">
                <Button
                  size="lg"
                  className="bg-gradient-to-r from-amber-500 to-green-600 hover:from-amber-600 hover:to-green-700 text-white shadow-xl px-12 py-4 text-lg transform transition-all duration-300 hover:scale-110 hover:shadow-2xl"
                >
                  <Coffee className="mr-2 h-5 w-5" />
                  Reserve Coffee
                </Button>
              </Link>
              <Link href="/locations">
                <Button
                  size="lg"
                  variant="outline"
                  className="border-2 border-green-300 text-green-700 hover:bg-green-50 px-12 py-4 text-lg bg-white/50 transform transition-all duration-300 hover:scale-105"
                >
                  <Eye className="mr-2 h-5 w-5" />
                  Visit Origins
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
