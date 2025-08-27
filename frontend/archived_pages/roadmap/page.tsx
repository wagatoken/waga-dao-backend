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
  Calendar,
  Target,
  Users,
  TrendingUp,
  Zap,
  CheckCircle,
  Clock,
  ArrowRight,
  ArrowLeft,
  Menu,
  X,
} from "lucide-react"
import Link from "next/link"

export default function RoadmapPage() {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false)
  const roadmapPhases = [
    {
      year: "2025",
      quarter: "Q3 (Sep)",
      title: "Foundation & Launch",
      status: "active",
      color: "amber",
      items: [
        "DAO treasury formation with initial PAXG/XAUT",
        "Smart contract deployment and auditing",
        "Swiss non-profit registration and compliance",
        "Community building and early supporter onboarding",
        "Initial website and documentation launch",
      ],
    },
    {
      year: "2025-2026",
      quarter: "Q4-Q2",
      title: "Planning & Partnership",
      status: "upcoming",
      color: "green",
      items: [
        "Cooperative identification and engagement in Ethiopia/Cameroon",
        "Site visits and community needs assessment",
        "MOU negotiations and legal framework establishment",
        "Mobile app design and initial development",
        "AI verification system research and planning",
      ],
    },
    {
      year: "2026",
      quarter: "Q3",
      title: "Infrastructure Development",
      status: "upcoming",
      color: "emerald",
      items: [
        "First USDC grants deployed to cooperatives",
        "Processing facility construction begins",
        "Blockchain traceability pilot program launch",
        "Farmer training program implementation",
        "Quality certification system development",
      ],
    },
    {
      year: "2026",
      quarter: "Q4",
      title: "Production Integration",
      status: "upcoming",
      color: "blue",
      items: [
        "First inventory tokens minted",
        "Mobile app public release and farmer onboarding",
        "AI verification system beta testing",
        "Direct trade partnerships established",
        "Community governance activation",
      ],
    },
    {
      year: "2027",
      quarter: "Q1-Q2",
      title: "Market Entry",
      status: "future",
      color: "purple",
      items: [
        "First certified coffee batches to market",
        "Premium pricing tier implementation",
        "International buyer onboarding",
        "Revenue sharing mechanism launch",
        "Second location expansion planning",
      ],
    },
    {
      year: "2028-2030",
      quarter: "Long Term",
      title: "Scale & Continental Impact",
      status: "future",
      color: "indigo",
      items: [
        "1,000+ farmers actively participating",
        "500+ tons of certified coffee produced annually",
        "Expansion to Ghana, Kenya, and additional countries",
        "Advanced AI features and carbon credit integration",
        "$100M+ cumulative economic impact across Africa",
      ],
    },
  ]

  const getStatusIcon = (status: string) => {
    switch (status) {
      case "active":
        return <Clock className="h-5 w-5" />
      case "upcoming":
        return <ArrowRight className="h-5 w-5" />
      case "future":
        return <Target className="h-5 w-5" />
      default:
        return <CheckCircle className="h-5 w-5" />
    }
  }

  const getColorClasses = (color: string) => {
    const colors = {
      amber: {
        bg: "from-amber-400 to-amber-600",
        border: "border-amber-200",
        text: "text-amber-700",
        badge: "bg-amber-100 text-amber-800",
      },
      green: {
        bg: "from-green-400 to-green-600",
        border: "border-green-200",
        text: "text-green-700",
        badge: "bg-green-100 text-green-800",
      },
      emerald: {
        bg: "from-emerald-400 to-emerald-600",
        border: "border-emerald-200",
        text: "text-emerald-700",
        badge: "bg-emerald-100 text-emerald-800",
      },
      blue: {
        bg: "from-blue-400 to-blue-600",
        border: "border-blue-200",
        text: "text-blue-700",
        badge: "bg-blue-100 text-blue-800",
      },
      purple: {
        bg: "from-purple-400 to-purple-600",
        border: "border-purple-200",
        text: "text-purple-700",
        badge: "bg-purple-100 text-purple-800",
      },
      indigo: {
        bg: "from-indigo-400 to-indigo-600",
        border: "border-indigo-200",
        text: "text-indigo-700",
        badge: "bg-indigo-100 text-indigo-800",
      },
    }
    return colors[color as keyof typeof colors] || colors.amber
  }

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
            🗓️ Development Roadmap
          </Badge>

          <h1 className="text-5xl md:text-6xl font-bold mb-8 bg-gradient-to-r from-amber-700 via-green-700 to-emerald-800 bg-clip-text text-transparent leading-tight">
            Journey to 2030
          </h1>

          <p className="text-xl text-gray-700 mb-12 max-w-3xl mx-auto leading-relaxed">
            Our strategic roadmap from pilot programs to continental impact, transforming African coffee economies
            through blockchain innovation.
          </p>
        </div>
      </section>

      {/* Roadmap Timeline */}
      <section className="py-20 px-6 bg-gradient-to-br from-white/60 via-green-50/60 to-emerald-100/80 relative">
        <div className="absolute inset-0 bg-gradient-to-r from-green-800/5 to-emerald-900/5"></div>
        <div className="container mx-auto max-w-6xl relative">
          <div className="space-y-8">
            {roadmapPhases.map((phase, index) => {
              const colorClasses = getColorClasses(phase.color)
              return (
                <Card
                  key={index}
                  className={`bg-white/80 backdrop-blur-sm ${colorClasses.border} shadow-xl hover:shadow-2xl transition-all duration-500 hover:-translate-y-2 group`}
                >
                  <CardContent className="p-8">
                    <div className="flex items-start space-x-6">
                      <div
                        className={`w-16 h-16 bg-gradient-to-br ${colorClasses.bg} rounded-2xl flex items-center justify-center flex-shrink-0 transition-all duration-300 group-hover:scale-110 group-hover:rotate-12`}
                      >
                        {getStatusIcon(phase.status)}
                      </div>
                      <div className="flex-1">
                        <div className="flex items-center mb-4 flex-wrap gap-4">
                          <span className={`${colorClasses.badge} text-sm font-bold px-3 py-1 rounded-full`}>
                            {phase.year} {phase.quarter}
                          </span>
                          <h3 className={`text-2xl font-bold ${colorClasses.text}`}>{phase.title}</h3>
                          <Badge variant={phase.status === "active" ? "default" : "outline"} className="ml-auto">
                            {phase.status === "active" && "In Progress"}
                            {phase.status === "upcoming" && "Upcoming"}
                            {phase.status === "future" && "Future"}
                          </Badge>
                        </div>
                        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-3">
                          {phase.items.map((item, itemIndex) => (
                            <div key={itemIndex} className="flex items-start space-x-2 text-gray-700 text-sm">
                              <CheckCircle className={`h-4 w-4 ${colorClasses.text} mt-0.5 flex-shrink-0`} />
                              <span>{item}</span>
                            </div>
                          ))}
                        </div>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              )
            })}
          </div>
        </div>
      </section>

      {/* Key Milestones */}
      <section className="py-20 px-6">
        <div className="container mx-auto max-w-6xl">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4 bg-gradient-to-r from-amber-700 to-green-700 bg-clip-text text-transparent">
              Key Milestones
            </h2>
            <p className="text-xl text-gray-600">Critical achievements on our journey</p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            <Card className="bg-white/80 backdrop-blur-sm border-amber-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:scale-105 group">
              <CardContent className="p-6 text-center">
                <div className="w-12 h-12 bg-gradient-to-br from-amber-400 to-amber-600 rounded-xl flex items-center justify-center mx-auto mb-4 transition-all duration-300 group-hover:scale-110">
                  <Users className="h-6 w-6 text-white" />
                </div>
                <div className="text-2xl font-bold text-amber-600 mb-2">Sep 2025</div>
                <div className="text-sm text-gray-600 mb-2">Launch</div>
                <div className="text-xs text-gray-500">Foundation & DAO establishment</div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-green-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:scale-105 group">
              <CardContent className="p-6 text-center">
                <div className="w-12 h-12 bg-gradient-to-br from-green-400 to-green-600 rounded-xl flex items-center justify-center mx-auto mb-4 transition-all duration-300 group-hover:scale-110">
                  <Users className="h-6 w-6 text-white" />
                </div>
                <div className="text-2xl font-bold text-green-600 mb-2">Q3 2026</div>
                <div className="text-sm text-gray-600 mb-2">First Grants</div>
                <div className="text-xs text-gray-500">USDC deployment to cooperatives</div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-emerald-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:scale-105 group">
              <CardContent className="p-6 text-center">
                <div className="w-12 h-12 bg-gradient-to-br from-emerald-400 to-emerald-600 rounded-xl flex items-center justify-center mx-auto mb-4 transition-all duration-300 group-hover:scale-110">
                  <Coffee className="h-6 w-6 text-white" />
                </div>
                <div className="text-2xl font-bold text-emerald-600 mb-2">Q1 2027</div>
                <div className="text-sm text-gray-600 mb-2">First Harvest</div>
                <div className="text-xs text-gray-500">Certified coffee to market</div>
              </CardContent>
            </Card>

            <Card className="bg-white/80 backdrop-blur-sm border-blue-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:scale-105 group">
              <CardContent className="p-6 text-center">
                <div className="w-12 h-12 bg-gradient-to-br from-blue-400 to-blue-600 rounded-xl flex items-center justify-center mx-auto mb-4 transition-all duration-300 group-hover:scale-110">
                  <TrendingUp className="h-6 w-6 text-white" />
                </div>
                <div className="text-2xl font-bold text-blue-600 mb-2">2028+</div>
                <div className="text-sm text-gray-600 mb-2">Scale Up</div>
                <div className="text-xs text-gray-500">1,000+ farmers participating</div>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Next Steps */}
      <section className="py-20 px-6 bg-gradient-to-br from-white/60 via-green-50/60 to-emerald-100/80 relative">
        <div className="absolute inset-0 bg-gradient-to-r from-green-800/5 to-emerald-900/5"></div>
        <div className="container mx-auto max-w-6xl relative">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4 bg-gradient-to-r from-amber-700 to-green-700 bg-clip-text text-transparent">
              Next Steps
            </h2>
            <p className="text-xl text-gray-600">Key actions to launch WAGA DAO in September 2025</p>
          </div>

          <Card className="bg-white/80 backdrop-blur-sm border-green-200 shadow-xl hover:shadow-2xl transition-all duration-500 hover:scale-105">
            <CardContent className="p-8">
              <div className="grid md:grid-cols-2 gap-8">
                <div>
                  <h3 className="text-2xl font-bold text-green-700 mb-6">Pre-Launch Priorities</h3>
                  <div className="space-y-4">
                    <div className="flex items-start space-x-3">
                      <Clock className="h-5 w-5 text-amber-600 mt-0.5" />
                      <div>
                        <div className="font-medium text-gray-800">Smart Contract Development</div>
                        <div className="text-sm text-gray-600">Design and audit treasury, governance, and inventory token contracts</div>
                      </div>
                    </div>
                    <div className="flex items-start space-x-3">
                      <Clock className="h-5 w-5 text-blue-600 mt-0.5" />
                      <div>
                        <div className="font-medium text-gray-800">Community Building</div>
                        <div className="text-sm text-gray-600">Establish early supporter community and governance framework</div>
                      </div>
                    </div>
                    <div className="flex items-start space-x-3">
                      <Clock className="h-5 w-5 text-green-600 mt-0.5" />
                      <div>
                        <div className="font-medium text-gray-800">Gold Treasury Setup</div>
                        <div className="text-sm text-gray-600">Secure initial PAXG/XAUT contributions for treasury foundation</div>
                      </div>
                    </div>
                    <div className="flex items-start space-x-3">
                      <Clock className="h-5 w-5 text-purple-600 mt-0.5" />
                      <div>
                        <div className="font-medium text-gray-800">Legal Framework</div>
                        <div className="text-sm text-gray-600">Finalize Swiss non-profit structure and compliance requirements</div>
                      </div>
                    </div>
                  </div>
                </div>

                <div>
                  <h3 className="text-2xl font-bold text-amber-700 mb-6">Cooperative Engagement</h3>
                  <div className="space-y-4">
                    <div className="flex items-start space-x-3">
                      <Clock className="h-5 w-5 text-emerald-600 mt-0.5" />
                      <div>
                        <div className="font-medium text-gray-800">Ethiopia Partnership</div>
                        <div className="text-sm text-gray-600">Identify and engage highland cooperatives for pilot program</div>
                      </div>
                    </div>
                    <div className="flex items-start space-x-3">
                      <Clock className="h-5 w-5 text-orange-600 mt-0.5" />
                      <div>
                        <div className="font-medium text-gray-800">Cameroon Outreach</div>
                        <div className="text-sm text-gray-600">Connect with Bamendakwe region farming communities</div>
                      </div>
                    </div>
                    <div className="flex items-start space-x-3">
                      <Clock className="h-5 w-5 text-indigo-600 mt-0.5" />
                      <div>
                        <div className="font-medium text-gray-800">Infrastructure Planning</div>
                        <div className="text-sm text-gray-600">Design processing facilities and quality verification systems</div>
                      </div>
                    </div>
                    <div className="flex items-start space-x-3">
                      <Clock className="h-5 w-5 text-red-600 mt-0.5" />
                      <div>
                        <div className="font-medium text-gray-800">Mobile App Design</div>
                        <div className="text-sm text-gray-600">Create farmer-friendly interface for blockchain interactions</div>
                      </div>
                    </div>
                  </div>
                </div>
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
              Be Part of the Journey
            </h2>
            <p className="text-xl text-gray-700 mb-8">
              Join us as we transform African coffee economies through blockchain innovation
            </p>

            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link href="/get-involved">
                <Button
                  size="lg"
                  className="bg-gradient-to-r from-amber-500 to-green-600 hover:from-amber-600 hover:to-green-700 text-white shadow-xl px-12 py-4 text-lg transform transition-all duration-300 hover:scale-110 hover:shadow-2xl"
                >
                  <Calendar className="mr-2 h-5 w-5" />
                  Join the Mission
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
