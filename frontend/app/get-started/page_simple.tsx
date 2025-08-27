/**
 * Get Started Page - Consolidated entry point for all user types
 * With working dropdown navigation
 */

"use client"

import { useState } from "react"
import Link from "next/link"
import SimpleDropdown from "@/components/SimpleDropdown"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Alert, AlertDescription } from "@/components/ui/alert"
import {
  Coffee,
  Users,
  Shield,
  Coins,
  ArrowRight,
  CheckCircle,
  Globe,
  Calendar,
  DollarSign,
  Menu,
  X,
  Leaf,
  TrendingUp
} from "lucide-react"

interface PortalOption {
  id: string
  title: string
  description: string
  icon: any
  color: string
  features: string[]
  cta: string
  href: string
}

export default function GetStarted() {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false)

  const portalOptions: PortalOption[] = [
    {
      id: "cooperative",
      title: "Coffee Cooperative",
      description: "Apply for grants, track milestones, and tokenize your coffee inventory",
      icon: Coffee,
      color: "from-green-400 to-green-600",
      features: [
        "Apply for development grants",
        "Milestone-based funding disbursement",
        "Tokenize coffee inventory on blockchain",
        "Track progress with smart contracts",
        "Access to premium coffee markets"
      ],
      cta: "Access Cooperative Portal",
      href: "/portal/cooperative"
    },
    {
      id: "admin",
      title: "System Administrator",
      description: "Validate milestones, manage grants, and oversee system operations",
      icon: Shield,
      color: "from-blue-400 to-blue-600",
      features: [
        "Review and validate grant applications",
        "Approve milestone evidence submissions",
        "Monitor grant disbursement schedules",
        "Manage cooperative verification status",
        "System analytics and reporting"
      ],
      cta: "Access Admin Portal",
      href: "/portal/admin"
    },
    {
      id: "dao",
      title: "DAO Governance",
      description: "Participate in governance, vote on proposals, and manage treasury",
      icon: Users,
      color: "from-purple-400 to-purple-600",
      features: [
        "Vote on governance proposals",
        "Manage $30M gold treasury",
        "Set grant allocation strategies",
        "Review cooperative applications",
        "Participate in DAO decisions"
      ],
      cta: "Access DAO Portal",
      href: "/portal/dao"
    },
    {
      id: "investor",
      title: "Investor / Contributor",
      description: "Contribute to the gold treasury and earn VERT governance tokens",
      icon: Coins,
      color: "from-amber-400 to-amber-600",
      features: [
        "Contribute PAXG, ETH, or USDC to treasury",
        "Earn VERT governance tokens",
        "Participate in treasury growth",
        "Support regenerative coffee farming",
        "Access to exclusive coffee products"
      ],
      cta: "Contribute to Treasury",
      href: "/tokenomics"
    }
  ]

  const navigationItems = [
    { name: "About", href: "/about" },
    { name: "How It Works", href: "/how-it-works" },
    { name: "Tokenomics", href: "/tokenomics" },
    { name: "Get Started", href: "/get-started" }
  ]

  const portalItems = [
    { name: "Cooperative Portal", href: "/portal/cooperative" },
    { name: "Admin Portal", href: "/portal/admin" },
    { name: "DAO Portal", href: "/portal/dao" }
  ]

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-emerald-50 to-amber-50">
      {/* Navigation */}
      <nav className="fixed top-0 w-full z-50 bg-gradient-to-r from-green-800 to-emerald-900 backdrop-blur-md border-b border-emerald-700/50">
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
              <Link
                key={item.name}
                href={item.href}
                className={`text-white hover:text-amber-300 transition-colors duration-300 text-sm font-medium ${
                  item.name === "Get Started" ? "bg-amber-500 px-4 py-2 rounded-lg" : ""
                }`}
              >
                {item.name}
              </Link>
            ))}
            <SimpleDropdown 
              label="Portals" 
              items={portalItems}
            />
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
          <div className="lg:hidden bg-green-900/95 backdrop-blur-md border-t border-emerald-700/50">
            <div className="container mx-auto px-6 py-4 space-y-4">
              {navigationItems.map((item) => (
                <Link
                  key={item.name}
                  href={item.href}
                  className="block text-white hover:text-amber-300 transition-colors duration-300 text-sm font-medium py-2"
                  onClick={() => setIsMobileMenuOpen(false)}
                >
                  {item.name}
                </Link>
              ))}
              <div className="border-t border-emerald-700/50 pt-4">
                <p className="text-emerald-300 text-sm font-medium mb-2">Portals</p>
                {portalItems.map((item) => (
                  <Link
                    key={item.name}
                    href={item.href}
                    className="block text-white hover:text-amber-300 transition-colors duration-300 text-sm py-2 pl-4"
                    onClick={() => setIsMobileMenuOpen(false)}
                  >
                    {item.name}
                  </Link>
                ))}
              </div>
            </div>
          </div>
        )}
      </nav>

      {/* Main Content */}
      <div className="pt-20">
        {/* Hero Section */}
        <section className="container mx-auto px-6 py-16 text-center">
          <div className="max-w-4xl mx-auto">
            <h1 className="text-5xl md:text-6xl font-bold text-gray-900 mb-6 leading-tight">
              Choose Your <span className="text-transparent bg-clip-text bg-gradient-to-r from-green-600 to-emerald-600">Portal</span>
            </h1>
            <p className="text-xl text-gray-600 mb-8 leading-relaxed">
              Access the WAGA DAO ecosystem through your dedicated portal. Each role has specialized tools for participating in regenerative coffee farming.
            </p>
            
            <Alert className="mb-8 bg-green-50 border-green-200">
              <Globe className="h-4 w-4" />
              <AlertDescription className="text-green-800">
                <strong>Global Impact:</strong> Supporting 50+ cooperatives across Rwanda, Colombia, and Ethiopia. Join the movement for sustainable coffee farming.
              </AlertDescription>
            </Alert>
          </div>
        </section>

        {/* Portal Options Grid */}
        <section className="container mx-auto px-6 pb-16">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            {portalOptions.map((portal) => {
              const IconComponent = portal.icon
              return (
                <Card key={portal.id} className="group hover:shadow-xl transition-all duration-300 transform hover:-translate-y-2 border-2 hover:border-green-300">
                  <CardHeader className="pb-4">
                    <div className="flex items-center space-x-4 mb-4">
                      <div className={`w-16 h-16 rounded-xl bg-gradient-to-br ${portal.color} flex items-center justify-center group-hover:scale-110 transition-transform duration-300`}>
                        <IconComponent className="h-8 w-8 text-white" />
                      </div>
                      <div>
                        <CardTitle className="text-2xl text-gray-900 group-hover:text-green-600 transition-colors">
                          {portal.title}
                        </CardTitle>
                        <p className="text-gray-600 mt-1">{portal.description}</p>
                      </div>
                    </div>
                  </CardHeader>
                  
                  <CardContent className="space-y-6">
                    <div className="space-y-3">
                      {portal.features.map((feature, index) => (
                        <div key={index} className="flex items-start space-x-3">
                          <CheckCircle className="h-5 w-5 text-green-500 mt-0.5 flex-shrink-0" />
                          <span className="text-gray-700 text-sm">{feature}</span>
                        </div>
                      ))}
                    </div>
                    
                    <Link href={portal.href} className="block">
                      <Button className={`w-full bg-gradient-to-r ${portal.color} hover:opacity-90 transition-opacity group-hover:scale-105 duration-300`}>
                        {portal.cta}
                        <ArrowRight className="ml-2 h-4 w-4" />
                      </Button>
                    </Link>
                  </CardContent>
                </Card>
              )
            })}
          </div>
        </section>

        {/* Stats Section */}
        <section className="bg-white/80 backdrop-blur-sm py-16">
          <div className="container mx-auto px-6">
            <div className="text-center mb-12">
              <h2 className="text-3xl font-bold text-gray-900 mb-4">Impact Metrics</h2>
              <p className="text-gray-600">Real-time data from our growing ecosystem</p>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
              <div className="text-center">
                <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                  <Coffee className="h-8 w-8 text-green-600" />
                </div>
                <h3 className="text-3xl font-bold text-gray-900">50+</h3>
                <p className="text-gray-600">Coffee Cooperatives</p>
              </div>
              
              <div className="text-center">
                <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
                  <DollarSign className="h-8 w-8 text-blue-600" />
                </div>
                <h3 className="text-3xl font-bold text-gray-900">$2.5M+</h3>
                <p className="text-gray-600">Grants Disbursed</p>
              </div>
              
              <div className="text-center">
                <div className="w-16 h-16 bg-purple-100 rounded-full flex items-center justify-center mx-auto mb-4">
                  <Users className="h-8 w-8 text-purple-600" />
                </div>
                <h3 className="text-3xl font-bold text-gray-900">10,000+</h3>
                <p className="text-gray-600">Farmers Supported</p>
              </div>
              
              <div className="text-center">
                <div className="w-16 h-16 bg-amber-100 rounded-full flex items-center justify-center mx-auto mb-4">
                  <Leaf className="h-8 w-8 text-amber-600" />
                </div>
                <h3 className="text-3xl font-bold text-gray-900">85%</h3>
                <p className="text-gray-600">Regenerative Practices</p>
              </div>
            </div>
          </div>
        </section>

        {/* CTA Section */}
        <section className="container mx-auto px-6 py-16 text-center">
          <div className="max-w-3xl mx-auto">
            <h2 className="text-4xl font-bold text-gray-900 mb-6">
              Ready to Make an Impact?
            </h2>
            <p className="text-xl text-gray-600 mb-8">
              Join thousands of farmers, investors, and coffee lovers creating a sustainable future for coffee farming.
            </p>
            
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link href="/portal/cooperative">
                <Button size="lg" className="bg-gradient-to-r from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700">
                  <Coffee className="mr-2 h-5 w-5" />
                  Join as Cooperative
                </Button>
              </Link>
              <Link href="/tokenomics">
                <Button size="lg" variant="outline" className="border-green-300 text-green-700 hover:bg-green-50">
                  <Coins className="mr-2 h-5 w-5" />
                  Contribute to Treasury
                </Button>
              </Link>
            </div>
          </div>
        </section>
      </div>
    </div>
  )
}
