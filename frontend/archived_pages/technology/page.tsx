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
  Zap,
  Shield,
  Database,
  Cpu,
  Eye,
  Lock,
  Smartphone,
  Cloud,
  GitBranch,
  Bot,
  ArrowLeft,
  Menu,
  X,
} from "lucide-react"
import Link from "next/link"

export default function TechnologyPage() {
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
            ⚡ Technology Stack
          </Badge>

          <h1 className="text-5xl md:text-6xl font-bold mb-8 bg-gradient-to-r from-amber-700 via-green-700 to-emerald-800 bg-clip-text text-transparent leading-tight">
            Blockchain & AI Infrastructure
          </h1>

          <p className="text-xl text-gray-700 mb-12 max-w-3xl mx-auto leading-relaxed">
            Cutting-edge technology stack combining blockchain transparency, AI verification, and mobile-first design
            for African coffee producers.
          </p>
        </div>
      </section>

      {/* Tech Stack Overview */}
      <section className="py-20 px-6 bg-gradient-to-br from-white/60 via-green-50/60 to-emerald-100/80 relative">
        <div className="absolute inset-0 bg-gradient-to-r from-green-800/5 to-emerald-900/5"></div>
        <div className="container mx-auto max-w-6xl relative">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4 bg-gradient-to-r from-amber-700 to-green-700 bg-clip-text text-transparent">
              Core Technologies
            </h2>
            <p className="text-xl text-gray-600">Integrated systems for transparency and efficiency</p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            <Card className="bg-white/80 backdrop-blur-sm border-amber-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:rotate-1 group">
              <CardContent className="p-8 text-center">
                <div className="w-16 h-16 bg-gradient-to-br from-amber-400 to-amber-600 rounded-2xl flex items-center justify-center mx-auto mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Database className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-amber-700 mb-4">Ethereum Blockchain</h3>
                <p className="text-gray-600 mb-4">
                  Smart contracts for treasury management, governance, and automated settlements
                </p>
                <div className="text-sm text-amber-600 font-semibold">Layer 1 + L2 Scaling</div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-green-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:-rotate-1 group">
              <CardContent className="p-8 text-center">
                <div className="w-16 h-16 bg-gradient-to-br from-green-400 to-green-600 rounded-2xl flex items-center justify-center mx-auto mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Bot className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-green-700 mb-4">AI Verification</h3>
                <p className="text-gray-600 mb-4">
                  Computer vision and ML models for quality assessment and batch verification
                </p>
                <div className="text-sm text-green-600 font-semibold">TensorFlow + OpenCV</div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-emerald-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:rotate-1 group">
              <CardContent className="p-8 text-center">
                <div className="w-16 h-16 bg-gradient-to-br from-emerald-400 to-emerald-600 rounded-2xl flex items-center justify-center mx-auto mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Lock className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-emerald-700 mb-4">zk-SNARKs</h3>
                <p className="text-gray-600 mb-4">
                  Zero-knowledge proofs for confidential verification and privacy protection
                </p>
                <div className="text-sm text-emerald-600 font-semibold">Circom + SnarkJS</div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-blue-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:-rotate-1 group">
              <CardContent className="p-8 text-center">
                <div className="w-16 h-16 bg-gradient-to-br from-blue-400 to-blue-600 rounded-2xl flex items-center justify-center mx-auto mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Smartphone className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-blue-700 mb-4">Mobile-First</h3>
                <p className="text-gray-600 mb-4">Progressive web app optimized for low-bandwidth African networks</p>
                <div className="text-sm text-blue-600 font-semibold">React Native + PWA</div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-purple-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:rotate-1 group">
              <CardContent className="p-8 text-center">
                <div className="w-16 h-16 bg-gradient-to-br from-purple-400 to-purple-600 rounded-2xl flex items-center justify-center mx-auto mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Cloud className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-purple-700 mb-4">IPFS Storage</h3>
                <p className="text-gray-600 mb-4">
                  Decentralized storage for certificates, images, and batch documentation
                </p>
                <div className="text-sm text-purple-600 font-semibold">Pinata + Filecoin</div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-indigo-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:-rotate-1 group">
              <CardContent className="p-8 text-center">
                <div className="w-16 h-16 bg-gradient-to-br from-indigo-400 to-indigo-600 rounded-2xl flex items-center justify-center mx-auto mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <GitBranch className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-indigo-700 mb-4">API Integration</h3>
                <p className="text-gray-600 mb-4">
                  RESTful APIs connecting cooperatives, buyers, and logistics partners
                </p>
                <div className="text-sm text-indigo-600 font-semibold">Node.js + GraphQL</div>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Blockchain Architecture */}
      <section className="py-20 px-6">
        <div className="container mx-auto max-w-6xl">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4 bg-gradient-to-r from-amber-700 to-green-700 bg-clip-text text-transparent">
              Blockchain Architecture
            </h2>
            <p className="text-xl text-gray-600">Smart contract ecosystem design</p>
          </div>

          <div className="space-y-8">
            <Card className="bg-white/80 backdrop-blur-sm border-amber-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-2 group">
              <CardContent className="p-8">
                <div className="flex items-start space-x-6">
                  <div className="w-16 h-16 bg-gradient-to-br from-amber-400 to-amber-600 rounded-2xl flex items-center justify-center flex-shrink-0 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                    <Shield className="h-8 w-8 text-white" />
                  </div>
                  <div className="flex-1">
                    <h3 className="text-2xl font-bold text-amber-700 mb-4">Treasury Management Contract</h3>
                    <p className="text-gray-700 text-lg mb-4">
                      Multi-signature wallet managing PAXG/XAUT treasury with automated USDC grant disbursement from gold
                      reserves.
                    </p>
                    <div className="grid md:grid-cols-2 gap-4">
                      <div className="bg-amber-100/50 rounded-lg p-4">
                        <h4 className="font-semibold text-amber-800 mb-2">Features</h4>
                        <ul className="text-sm text-amber-700 space-y-1">
                          <li>• Multi-sig governance (3/5 threshold)</li>
                          <li>• Automated grant disbursement system</li>
                          <li>• Real-time treasury monitoring</li>
                          <li>• Emergency pause mechanisms</li>
                        </ul>
                      </div>
                      <div className="bg-amber-100/50 rounded-lg p-4">
                        <h4 className="font-semibold text-amber-800 mb-2">Security</h4>
                        <ul className="text-sm text-amber-700 space-y-1">
                          <li>• Timelock for major changes</li>
                          <li>• Slashing protection</li>
                          <li>• Oracle price feeds</li>
                          <li>• Audit by ConsenSys Diligence</li>
                        </ul>
                      </div>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-green-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-2 group">
              <CardContent className="p-8">
                <div className="flex items-start space-x-6">
                  <div className="w-16 h-16 bg-gradient-to-br from-green-400 to-green-600 rounded-2xl flex items-center justify-center flex-shrink-0 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                    <Coffee className="h-8 w-8 text-white" />
                  </div>
                  <div className="flex-1">
                    <h3 className="text-2xl font-bold text-green-700 mb-4">Inventory Token System (ERC-1155)</h3>
                    <p className="text-gray-700 text-lg mb-4">
                      Semi-fungible tokens representing DAO's claims on coffee batches, issued against USDC grants and
                      sold to reinvest in cooperative development.
                    </p>
                    <div className="grid md:grid-cols-2 gap-4">
                      <div className="bg-green-100/50 rounded-lg p-4">
                        <h4 className="font-semibold text-green-800 mb-2">Token Metadata</h4>
                        <ul className="text-sm text-green-700 space-y-1">
                          <li>• Farm origin coordinates</li>
                          <li>• Harvest date and processing method</li>
                          <li>• Quality scores and certifications</li>
                          <li>• Carbon footprint data</li>
                        </ul>
                      </div>
                      <div className="bg-green-100/50 rounded-lg p-4">
                        <h4 className="font-semibold text-green-800 mb-2">Use Cases</h4>
                        <ul className="text-sm text-green-700 space-y-1">
                          <li>• Grant milestone tracking</li>
                          <li>• Supply chain tracking</li>
                          <li>• Quality verification</li>
                          <li>• Automated reinvestment</li>
                        </ul>
                      </div>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-emerald-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-2 group">
              <CardContent className="p-8">
                <div className="flex items-start space-x-6">
                  <div className="w-16 h-16 bg-gradient-to-br from-emerald-400 to-emerald-600 rounded-2xl flex items-center justify-center flex-shrink-0 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                    <Eye className="h-8 w-8 text-white" />
                  </div>
                  <div className="flex-1">
                    <h3 className="text-2xl font-bold text-emerald-700 mb-4">Governance & Voting Contract</h3>
                    <p className="text-gray-700 text-lg mb-4">
                      Quadratic voting system ensuring fair representation across all stakeholders in the DAO ecosystem.
                    </p>
                    <div className="grid md:grid-cols-2 gap-4">
                      <div className="bg-emerald-100/50 rounded-lg p-4">
                        <h4 className="font-semibold text-emerald-800 mb-2">Voting Mechanics</h4>
                        <ul className="text-sm text-emerald-700 space-y-1">
                          <li>• Quadratic cost scaling</li>
                          <li>• 7-day voting periods</li>
                          <li>• Delegation support</li>
                          <li>• Proposal threshold: 10K WAGA</li>
                        </ul>
                      </div>
                      <div className="bg-emerald-100/50 rounded-lg p-4">
                        <h4 className="font-semibold text-emerald-800 mb-2">Governance Scope</h4>
                        <ul className="text-sm text-emerald-700 space-y-1">
                          <li>• Treasury allocation decisions</li>
                          <li>• Partnership approvals</li>
                          <li>• Protocol parameter updates</li>
                          <li>• Emergency response actions</li>
                        </ul>
                      </div>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* AI & Verification */}
      <section className="py-20 px-6 bg-gradient-to-br from-white/60 via-green-50/60 to-emerald-100/80 relative">
        <div className="absolute inset-0 bg-gradient-to-r from-green-800/5 to-emerald-900/5"></div>
        <div className="container mx-auto max-w-6xl relative">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4 bg-gradient-to-r from-amber-700 to-green-700 bg-clip-text text-transparent">
              AI Verification System
            </h2>
            <p className="text-xl text-gray-600">Computer vision and machine learning for quality assurance</p>
          </div>

          <div className="grid md:grid-cols-2 gap-12">
            <Card className="bg-white/80 backdrop-blur-sm border-blue-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:rotate-1 group">
              <CardContent className="p-8">
                <div className="w-16 h-16 bg-gradient-to-br from-blue-400 to-blue-600 rounded-2xl flex items-center justify-center mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Cpu className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-3xl font-bold text-blue-700 mb-6">Computer Vision Pipeline</h3>
                <div className="space-y-4">
                  <div className="bg-blue-100/50 rounded-lg p-4">
                    <h4 className="font-semibold text-blue-800 mb-2">Image Analysis</h4>
                    <ul className="text-sm text-blue-700 space-y-1">
                      <li>• Bean size and color classification</li>
                      <li>• Defect detection and scoring</li>
                      <li>• Moisture content estimation</li>
                      <li>• Processing method verification</li>
                    </ul>
                  </div>
                  <div className="bg-blue-100/50 rounded-lg p-4">
                    <h4 className="font-semibold text-blue-800 mb-2">Quality Scoring</h4>
                    <ul className="text-sm text-blue-700 space-y-1">
                      <li>• SCA cupping score prediction</li>
                      <li>• Grade classification (AA, AB, etc.)</li>
                      <li>• Consistency metrics</li>
                      <li>• Premium tier identification</li>
                    </ul>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-purple-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:-rotate-1 group">
              <CardContent className="p-8">
                <div className="w-16 h-16 bg-gradient-to-br from-purple-400 to-purple-600 rounded-2xl flex items-center justify-center mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Lock className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-3xl font-bold text-purple-700 mb-6">Zero-Knowledge Proofs</h3>
                <div className="space-y-4">
                  <div className="bg-purple-100/50 rounded-lg p-4">
                    <h4 className="font-semibold text-purple-800 mb-2">Privacy Protection</h4>
                    <ul className="text-sm text-purple-700 space-y-1">
                      <li>• Farm location confidentiality</li>
                      <li>• Pricing information privacy</li>
                      <li>• Competitive advantage protection</li>
                      <li>• Selective disclosure controls</li>
                    </ul>
                  </div>
                  <div className="bg-purple-100/50 rounded-lg p-4">
                    <h4 className="font-semibold text-purple-800 mb-2">Verification Without Exposure</h4>
                    <ul className="text-sm text-purple-700 space-y-1">
                      <li>• Quality standards compliance</li>
                      <li>• Organic certification proof</li>
                      <li>• Fair trade verification</li>
                      <li>• Carbon footprint validation</li>
                    </ul>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Mobile & Accessibility */}
      <section className="py-20 px-6">
        <div className="container mx-auto max-w-6xl">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4 bg-gradient-to-r from-amber-700 to-green-700 bg-clip-text text-transparent">
              Mobile-First Design
            </h2>
            <p className="text-xl text-gray-600">Optimized for African network conditions</p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            <Card className="bg-white/80 backdrop-blur-sm border-green-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:rotate-1 group">
              <CardContent className="p-8 text-center">
                <div className="w-16 h-16 bg-gradient-to-br from-green-400 to-green-600 rounded-2xl flex items-center justify-center mx-auto mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Smartphone className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-green-700 mb-4">Offline-First</h3>
                <p className="text-gray-600 mb-4">
                  Progressive Web App with offline data sync and local storage capabilities
                </p>
                <div className="text-sm text-green-600 font-semibold">Service Workers + IndexedDB</div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-blue-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:-rotate-1 group">
              <CardContent className="p-8 text-center">
                <div className="w-16 h-16 bg-gradient-to-br from-blue-400 to-blue-600 rounded-2xl flex items-center justify-center mx-auto mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Zap className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-blue-700 mb-4">Low Bandwidth</h3>
                <p className="text-gray-600 mb-4">
                  Optimized for 2G/3G networks with image compression and lazy loading
                </p>
                <div className="text-sm text-blue-600 font-semibold">WebP + Progressive Loading</div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-amber-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-4 hover:rotate-1 group">
              <CardContent className="p-8 text-center">
                <div className="w-16 h-16 bg-gradient-to-br from-amber-400 to-amber-600 rounded-2xl flex items-center justify-center mx-auto mb-6 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Globe className="h-8 w-8 text-white" />
                </div>
                <h3 className="text-2xl font-bold text-amber-700 mb-4">Multi-Language</h3>
                <p className="text-gray-600 mb-4">
                  Support for English, French, Amharic, and local dialects with voice interfaces
                </p>
                <div className="text-sm text-amber-600 font-semibold">i18n + Speech Recognition</div>
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
              Open Source Development
            </h2>
            <p className="text-xl text-gray-700 mb-8">
              Join our developer community and contribute to regenerative agriculture technology
            </p>

            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link href="/get-involved">
                <Button
                  size="lg"
                  className="bg-gradient-to-r from-amber-500 to-green-600 hover:from-amber-600 hover:to-green-700 text-white shadow-xl px-12 py-4 text-lg transform transition-all duration-300 hover:scale-110 hover:shadow-2xl"
                >
                  <GitBranch className="mr-2 h-5 w-5" />
                  Contribute Code
                </Button>
              </Link>
              <Link href="/roadmap">
                <Button
                  size="lg"
                  variant="outline"
                  className="border-2 border-green-300 text-green-700 hover:bg-green-50 px-12 py-4 text-lg bg-white/50 transform transition-all duration-300 hover:scale-105"
                >
                  <Cpu className="mr-2 h-5 w-5" />
                  View Roadmap
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
