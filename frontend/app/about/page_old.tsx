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
  Target,
  Eye,
  Heart,
  Users,
  TrendingUp,
  Shield,
  Coins,
  Zap,
  ArrowLeft,
  Menu,
  X,
} from "lucide-react"
import Link from "next/link"

export default function AboutPage() {
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
            🌍 About WAGA DAO
          </Badge>

          <h1 className="text-5xl md:text-6xl font-bold mb-8 bg-gradient-to-r from-amber-700 via-green-700 to-emerald-800 bg-clip-text text-transparent leading-tight">
            Regenerating African Agriculture Through Blockchain
          </h1>

          <p className="text-xl text-gray-700 mb-12 max-w-3xl mx-auto leading-relaxed">
            WAGA DAO is a Swiss non-profit association leveraging blockchain, AI, and tokenized gold to transform coffee
            economies in Africa.
          </p>
        </div>
      </section>

      {/* Mission & Vision */}
      <section className="py-20 px-6 bg-gradient-to-br from-white/60 via-green-50/60 to-emerald-100/80 relative">
        <div className="absolute inset-0 bg-gradient-to-r from-green-800/5 to-emerald-900/5"></div>
        <div className="container mx-auto max-w-6xl relative">
          <div className="grid md:grid-cols-2 gap-12">
            <Card className="bg-white/80 backdrop-blur-sm border-amber-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:rotate-1 group">
              <CardContent className="p-8">
                <div className="w-16 h-16 bg-gradient-to-br from-amber-400 to-amber-600 rounded-2xl flex items-center justify-center mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Target className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-3xl font-bold text-amber-700 mb-6">Our Mission</h3>
                <p className="text-gray-700 text-lg leading-relaxed">
                  Deploy smart capital and transparent supply chain systems to build high-trust, high-value trade
                  networks led by African producers.
                </p>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-green-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:-rotate-1 group">
              <CardContent className="p-8">
                <div className="w-16 h-16 bg-gradient-to-br from-green-400 to-green-600 rounded-2xl flex items-center justify-center mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Eye className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-3xl font-bold text-green-700 mb-6">Our Vision</h3>
                <p className="text-gray-700 text-lg leading-relaxed">
                  Regenerate African coffee economies through cooperative ownership, traceability, and digitally native
                  trade.
                </p>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* The Problem */}
      <section className="py-20 px-6">
        <div className="container mx-auto max-w-6xl">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4 bg-gradient-to-r from-amber-700 to-green-700 bg-clip-text text-transparent">
              Challenges We Address
            </h2>
            <p className="text-xl text-gray-600">Critical issues facing African coffee producers</p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            <Card className="bg-white/80 backdrop-blur-sm border-red-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 group">
              <CardContent className="p-6 text-center">
                <div className="w-12 h-12 bg-gradient-to-br from-red-400 to-red-600 rounded-xl flex items-center justify-center mx-auto mb-4 transition-all duration-300 group-hover:scale-110">
                  <Users className="h-6 w-6 text-white" />
                </div>
                <h4 className="text-lg font-bold text-red-700 mb-3">Conflict & Displacement</h4>
                <p className="text-gray-600 text-sm">
                  Armed conflict, youth disillusionment, and institutional fragility
                </p>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-orange-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 group">
              <CardContent className="p-6 text-center">
                <div className="w-12 h-12 bg-gradient-to-br from-orange-400 to-orange-600 rounded-xl flex items-center justify-center mx-auto mb-4 transition-all duration-300 group-hover:scale-110">
                  <TrendingUp className="h-6 w-6 text-white" />
                </div>
                <h4 className="text-lg font-bold text-orange-700 mb-3">Value Chain Inefficiency</h4>
                <p className="text-gray-600 text-sm">Less than 10% of retail value captured locally</p>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-blue-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 group">
              <CardContent className="p-6 text-center">
                <div className="w-12 h-12 bg-gradient-to-br from-blue-400 to-blue-600 rounded-xl flex items-center justify-center mx-auto mb-4 transition-all duration-300 group-hover:scale-110">
                  <Shield className="h-6 w-6 text-white" />
                </div>
                <h4 className="text-lg font-bold text-blue-700 mb-3">Traceability Issues</h4>
                <p className="text-gray-600 text-sm">Paper-based systems lack verifiability and tech adoption</p>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-purple-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 group">
              <CardContent className="p-6 text-center">
                <div className="w-12 h-12 bg-gradient-to-br from-purple-400 to-purple-600 rounded-xl flex items-center justify-center mx-auto mb-4 transition-all duration-300 group-hover:scale-110">
                  <Coins className="h-6 w-6 text-white" />
                </div>
                <h4 className="text-lg font-bold text-purple-700 mb-3">Capital Access</h4>
                <p className="text-gray-600 text-sm">No collateral, no liquidity, no investor trust</p>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Our Solution */}
      <section className="py-20 px-6 bg-gradient-to-br from-white/60 via-green-50/60 to-emerald-100/80 relative">
        <div className="absolute inset-0 bg-gradient-to-r from-green-800/5 to-emerald-900/5"></div>
        <div className="container mx-auto max-w-6xl relative">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4 bg-gradient-to-r from-amber-700 to-green-700 bg-clip-text text-transparent">
              WAGA DAO Solution
            </h2>
            <p className="text-xl text-gray-600">Comprehensive approach to regenerative agriculture</p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            <Card className="bg-white/80 backdrop-blur-sm border-amber-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:rotate-1 group">
              <CardContent className="p-8 text-center">
                <div className="w-16 h-16 bg-gradient-to-br from-amber-400 to-amber-600 rounded-2xl flex items-center justify-center mx-auto mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Coins className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-amber-700 mb-4">Gold-Backed Treasury</h3>
                <p className="text-gray-600">
                  Deploys collateral-backed capital to build long-term regenerative value using PAXG/XAUT
                </p>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-green-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:-rotate-1 group">
              <CardContent className="p-8 text-center">
                <div className="w-16 h-16 bg-gradient-to-br from-green-400 to-green-600 rounded-2xl flex items-center justify-center mx-auto mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Zap className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-green-700 mb-4">AI + Blockchain</h3>
                <p className="text-gray-600">
                  Confidential, verifiable, AI-indexed certification and traceability with zk-SNARKs
                </p>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-emerald-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:rotate-1 group">
              <CardContent className="p-8 text-center">
                <div className="w-16 h-16 bg-gradient-to-br from-emerald-400 to-emerald-600 rounded-2xl flex items-center justify-center mx-auto mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Heart className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-emerald-700 mb-4">Sustainable Regeneration</h3>
                <p className="text-gray-600">
                  Grants → milestone validation → inventory tokens → sales → cooperative growth → community impact → regional
                  scaling
                </p>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* SDG Alignment */}
      <section className="py-20 px-6">
        <div className="container mx-auto max-w-6xl">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4 bg-gradient-to-r from-amber-700 to-green-700 bg-clip-text text-transparent">
              UN SDG Alignment
            </h2>
            <p className="text-xl text-gray-600">Contributing to global sustainable development goals</p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-5 gap-6">
            <Card className="bg-gradient-to-br from-red-50 to-red-100 border-red-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:scale-105 group">
              <CardContent className="p-6 text-center">
                <div className="text-3xl font-bold text-red-600 mb-2">SDG 1</div>
                <h4 className="text-sm font-bold text-red-700 mb-2">No Poverty</h4>
                <p className="text-xs text-gray-600">Local job creation in fragile zones</p>
              </CardContent>
            </Card>

            <Card className="bg-gradient-to-br from-orange-50 to-orange-100 border-orange-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:scale-105 group">
              <CardContent className="p-6 text-center">
                <div className="text-3xl font-bold text-orange-600 mb-2">SDG 8</div>
                <h4 className="text-sm font-bold text-orange-700 mb-2">Decent Work</h4>
                <p className="text-xs text-gray-600">Formalized cooperative labor</p>
              </CardContent>
            </Card>

            <Card className="bg-gradient-to-br from-yellow-50 to-yellow-100 border-yellow-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:scale-105 group">
              <CardContent className="p-6 text-center">
                <div className="text-3xl font-bold text-yellow-600 mb-2">SDG 12</div>
                <h4 className="text-sm font-bold text-yellow-700 mb-2">Responsible Consumption</h4>
                <p className="text-xs text-gray-600">QR-tracked sustainable sourcing</p>
              </CardContent>
            </Card>

            <Card className="bg-gradient-to-br from-green-50 to-green-100 border-green-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:scale-105 group">
              <CardContent className="p-6 text-center">
                <div className="text-3xl font-bold text-green-600 mb-2">SDG 13</div>
                <h4 className="text-sm font-bold text-green-700 mb-2">Climate Action</h4>
                <p className="text-xs text-gray-600">Agroforestry and carbon scoring</p>
              </CardContent>
            </Card>

            <Card className="bg-gradient-to-br from-blue-50 to-blue-100 border-blue-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:scale-105 group">
              <CardContent className="p-6 text-center">
                <div className="text-3xl font-bold text-blue-600 mb-2">SDG 16</div>
                <h4 className="text-sm font-bold text-blue-700 mb-2">Peace & Institutions</h4>
                <p className="text-xs text-gray-600">Post-war stability through dignity</p>
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
              Join Our Mission
            </h2>
            <p className="text-xl text-gray-700 mb-8">
              Be part of regenerating African coffee economies through blockchain innovation
            </p>

            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link href="/get-involved">
                <Button
                  size="lg"
                  className="bg-gradient-to-r from-amber-500 to-green-600 hover:from-amber-600 hover:to-green-700 text-white shadow-xl px-12 py-4 text-lg transform transition-all duration-300 hover:scale-110 hover:shadow-2xl"
                >
                  <Heart className="mr-2 h-5 w-5" />
                  Get Involved
                </Button>
              </Link>
              <Link href="/how-it-works">
                <Button
                  size="lg"
                  variant="outline"
                  className="border-2 border-green-300 text-green-700 hover:bg-green-50 px-12 py-4 text-lg bg-white/50 transform transition-all duration-300 hover:scale-105"
                >
                  Learn More
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
