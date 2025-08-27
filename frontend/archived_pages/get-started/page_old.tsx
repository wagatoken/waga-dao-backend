/**
 * Get Started Page - Consolidated entry point for all user types
 * Replaces multiple scattered CTAs with clear pathways
 */

"use client"

import { useState, useEffect, useRef } from "react"
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
  TrendingUp,
  Award,
  Leaf,
  Heart,
  Target,
  FileText,
  Calendar,
  Home,
  Menu,
  X,
  ChevronDown,
  ArrowLeft
} from "lucide-react"

interface UserPath {
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

  const userPaths: UserPath[] = [
    {
      id: "cooperative",
      title: "Coffee Cooperative",
      description: "Apply for grants, manage milestones, and tokenize your coffee inventory",
      icon: Coffee,
      color: "from-green-400 to-green-600",
      features: [
        "Apply for development grants up to $50,000",
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
        "Contribute PAXG/XAUT to treasury",
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
              <div 
                key={item.name} 
                className="relative" 
                ref={item.dropdown ? dropdownRef : undefined}
                onMouseEnter={() => item.dropdown && handleMouseEnter(item.name)}
                onMouseLeave={() => item.dropdown && handleMouseLeave()}
              >
                {item.dropdown ? (
                  <div className="relative">
                    <button
                      className="flex items-center text-white hover:text-amber-300 transition-colors duration-300 text-sm font-medium"
                      onClick={() => handleDropdownToggle(item.name)}
                      aria-expanded={dropdownOpen === item.name}
                      aria-haspopup="true"
                    >
                      <span>{item.name}</span>
                      <ChevronDown className={`ml-1 h-4 w-4 transition-transform duration-200 ${
                        dropdownOpen === item.name ? 'rotate-180' : ''
                      }`} />
                    </button>
                    
                    {dropdownOpen === item.name && (
                      <div 
                        className="absolute top-full left-0 mt-2 w-48 bg-white rounded-lg shadow-xl border border-gray-200 py-2 z-50 animate-in fade-in-0 zoom-in-95 duration-200"
                        onMouseEnter={() => {
                          if (hoverTimeout) {
                            clearTimeout(hoverTimeout)
                            setHoverTimeout(null)
                          }
                        }}
                        onMouseLeave={handleMouseLeave}
                      >
                        {item.dropdown.map((dropdownItem) => (
                          <Link
                            key={dropdownItem.name}
                            href={dropdownItem.href}
                            className="block px-4 py-2 text-sm text-gray-700 hover:bg-green-50 hover:text-green-600 transition-colors duration-150"
                            onClick={handleDropdownClose}
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
                      item.name === "Get Started" ? "bg-amber-500 px-4 py-2 rounded-lg" : ""
                    }`}
                  >
                    {item.name}
                  </Link>
                )}
              </div>
            ))}
          </div>

          <div className="flex items-center space-x-4">
            {/* Back Button */}
            <Link href="/">
              <Button
                variant="outline"
                className="bg-transparent border-amber-400/30 text-white hover:bg-amber-500/20 hover:text-amber-300 transition-all duration-300"
              >
                <ArrowLeft className="mr-2 h-4 w-4" />
                Home
              </Button>
            </Link>

            {/* Mobile Menu Button */}
            <Button
              variant="ghost"
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
                      <button
                        className="flex items-center justify-between w-full text-white font-medium py-2 text-sm border-b border-emerald-700/50"
                        onClick={() => handleDropdownToggle(item.name)}
                        aria-expanded={dropdownOpen === item.name}
                        aria-haspopup="true"
                      >
                        <span>{item.name}</span>
                        <ChevronDown className={`h-4 w-4 transition-transform duration-200 ${
                          dropdownOpen === item.name ? 'rotate-180' : ''
                        }`} />
                      </button>
                      {dropdownOpen === item.name && (
                        <div className="mt-2 space-y-1 animate-in fade-in-0 duration-200">
                          {item.dropdown.map((dropdownItem) => (
                            <Link
                              key={dropdownItem.name}
                              href={dropdownItem.href}
                              className="block text-white/80 hover:text-amber-300 transition-colors duration-300 py-2 pl-4 text-sm"
                              onClick={() => {
                                handleDropdownClose()
                                setIsMobileMenuOpen(false)
                              }}
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
      <section className="pt-32 pb-16 px-6">
        <div className="container mx-auto text-center max-w-4xl">
          <Badge className="mb-6 bg-gradient-to-r from-green-100 to-emerald-100 text-green-800 border border-green-300/50 px-4 py-2 text-sm shadow-lg">
            <Target className="inline w-4 h-4 mr-2" />
            Choose Your Path
          </Badge>

          <h1 className="text-5xl md:text-6xl font-bold mb-8 bg-gradient-to-r from-green-700 via-emerald-600 to-amber-600 bg-clip-text text-transparent leading-tight">
            Get Started with WAGA DAO
          </h1>

          <p className="text-xl text-gray-700 mb-12 max-w-3xl mx-auto leading-relaxed">
            Join the regenerative coffee revolution. Whether you're a cooperative seeking funding, 
            an administrator validating impact, or a contributor supporting the mission - start here.
          </p>
        </div>
      </section>

      {/* User Paths */}
      <section className="pb-20 px-6">
        <div className="container mx-auto max-w-7xl">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
            {userPaths.map((path) => {
              const IconComponent = path.icon
              return (
                <Card key={path.id} className="group hover:shadow-2xl transition-all duration-500 hover:-translate-y-2 border-0 overflow-hidden">
                  <CardHeader className={`bg-gradient-to-r ${path.color} text-white p-8`}>
                    <div className="flex items-center space-x-4">
                      <div className="w-16 h-16 bg-white/20 rounded-2xl flex items-center justify-center group-hover:scale-110 transition-transform duration-300">
                        <IconComponent className="h-8 w-8 text-white" />
                      </div>
                      <div>
                        <CardTitle className="text-2xl font-bold">{path.title}</CardTitle>
                        <p className="text-white/90 mt-2">{path.description}</p>
                      </div>
                    </div>
                  </CardHeader>
                  
                  <CardContent className="p-8">
                    <div className="space-y-4 mb-8">
                      {path.features.map((feature, index) => (
                        <div key={index} className="flex items-center space-x-3">
                          <CheckCircle className="h-5 w-5 text-green-500 flex-shrink-0" />
                          <span className="text-gray-700">{feature}</span>
                        </div>
                      ))}
                    </div>

                    <Link href={path.href}>
                      <Button className={`w-full bg-gradient-to-r ${path.color} hover:opacity-90 text-white shadow-lg group-hover:shadow-xl transition-all duration-300`}>
                        {path.cta}
                        <ArrowRight className="ml-2 h-4 w-4 group-hover:translate-x-1 transition-transform" />
                      </Button>
                    </Link>
                  </CardContent>
                </Card>
              )
            })}
          </div>
        </div>
      </section>

      {/* Quick Stats */}
      <section className="py-16 px-6 bg-white">
        <div className="container mx-auto max-w-6xl">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-gray-900 mb-4">Impact So Far</h2>
            <p className="text-xl text-gray-600">Building the future of regenerative coffee finance</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            <div className="text-center">
              <div className="w-16 h-16 bg-gradient-to-br from-green-400 to-green-600 rounded-2xl flex items-center justify-center mx-auto mb-4">
                <Coffee className="h-8 w-8 text-white" />
              </div>
              <div className="text-3xl font-bold text-gray-900 mb-2">247</div>
              <div className="text-gray-600">Cooperative Members</div>
            </div>

            <div className="text-center">
              <div className="w-16 h-16 bg-gradient-to-br from-blue-400 to-blue-600 rounded-2xl flex items-center justify-center mx-auto mb-4">
                <Coins className="h-8 w-8 text-white" />
              </div>
              <div className="text-3xl font-bold text-gray-900 mb-2">$30M</div>
              <div className="text-gray-600">Gold Treasury Target</div>
            </div>

            <div className="text-center">
              <div className="w-16 h-16 bg-gradient-to-br from-purple-400 to-purple-600 rounded-2xl flex items-center justify-center mx-auto mb-4">
                <Globe className="h-8 w-8 text-white" />
              </div>
              <div className="text-3xl font-bold text-gray-900 mb-2">3</div>
              <div className="text-gray-600">African Regions</div>
            </div>

            <div className="text-center">
              <div className="w-16 h-16 bg-gradient-to-br from-amber-400 to-amber-600 rounded-2xl flex items-center justify-center mx-auto mb-4">
                <TrendingUp className="h-8 w-8 text-white" />
              </div>
              <div className="text-3xl font-bold text-gray-900 mb-2">2025</div>
              <div className="text-gray-600">Launch Year</div>
            </div>
          </div>
        </div>
      </section>

      {/* Call to Action */}
      <section className="py-20 px-6 bg-gradient-to-r from-green-600 to-emerald-700">
        <div className="container mx-auto text-center max-w-4xl">
          <h2 className="text-4xl font-bold text-white mb-6">Ready to Make an Impact?</h2>
          <p className="text-xl text-green-100 mb-8">
            Join the regenerative coffee revolution and help build sustainable futures for African coffee cooperatives.
          </p>
          
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link href="/portal/cooperative">
              <Button size="lg" className="bg-white text-green-600 hover:bg-green-50 shadow-xl">
                <Coffee className="mr-2 h-5 w-5" />
                I'm a Cooperative
              </Button>
            </Link>
            <Link href="/tokenomics">
              <Button size="lg" variant="outline" className="border-white text-white hover:bg-white hover:text-green-600 shadow-xl">
                <Coins className="mr-2 h-5 w-5" />
                I Want to Invest
              </Button>
            </Link>
          </div>
        </div>
      </section>
    </div>
  )
}
