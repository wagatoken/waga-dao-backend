/**
 * Navigation Component - Reusable header navigation with dropdown support
 */

"use client"

import { useState } from "react"
import Link from "next/link"
import { Button } from "@/components/ui/button"
import { Coffee, Menu, X, ChevronDown, ArrowLeft } from "lucide-react"

interface NavigationItem {
  name: string
  href: string
  dropdown?: { name: string; href: string }[]
}

interface NavigationProps {
  currentPage?: string
  showBackButton?: boolean
}

export function Navigation({ currentPage, showBackButton = false }: NavigationProps) {
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
                    currentPage === item.name ? "text-amber-300" : ""
                  }`}
                >
                  {item.name}
                </Link>
              )}
            </div>
          ))}
        </div>

        <div className="flex items-center space-x-4">
          {showBackButton && (
            <Link href="/">
              <Button
                variant="outline"
                className="bg-transparent border-amber-400/30 text-white hover:bg-amber-500/20 hover:text-amber-300 transition-all duration-300"
              >
                <ArrowLeft className="mr-2 h-4 w-4" />
                Home
              </Button>
            </Link>
          )}

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
  )
}
