/**
 * About WAGA DAO - Minimal Essential Information
 * Focused on key facts and contact information
 */

"use client"

import Link from "next/link"
import { Card, CardContent } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import {
  Coffee,
  MapPin,
  Users,
  Target,
  ArrowLeft,
  Globe,
  Mail,
  MessageCircle
} from "lucide-react"

export default function About() {
  const keyFacts = [
    {
      icon: Target,
      title: "Mission",
      description: "Regenerating African coffee economies through blockchain-powered grants and tokenization"
    },
    {
      icon: MapPin,
      title: "Locations",
      description: "Active Ethiopia, Cameroon, and Uganda with a projected 50+ cooperative partnerships"
    },
    {
      icon: Users,
      title: "Projected Impact",
      description: "Supporting 10,000+ farmers with grants and milestone tracking"
    },
    {
      icon: Coffee,
      title: "Technology",
      description: "Smart contracts supporting a gold backed treasury on Base, Eth Mainnet, & Arbitrum with IPFS and Relational DB storage"
    }
  ]

  const contacts = [
    {
      icon: Mail,
      label: "Email",
      value: "team@wagatoken.io",
      href: "mailto:team@wagatoken.io"
    },
    {
      icon: Globe,
      label: "Website",
      value: "wagadao.io",
      href: "https://wagadao.io"
    },
    {
      icon: MessageCircle,
      label: "Telegram",
      value: "@wagadao",
      href: "https://t.me/wagadao"
    }
  ]

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-green-900 to-emerald-900">
      {/* Navigation */}
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
                  <div className="absolute inset-0 bg-gradient-to-br from-amber-400 to-green-500 rounded-2xl blur-md opacity-50"></div>
                </div>
                <span className="text-2xl font-bold text-white">WAGA DAO</span>
              </Link>
            </div>

            {/* Centered Navigation */}
            <div className="hidden lg:flex items-center space-x-8">
              <Link href="/" className="text-white/80 hover:text-white transition-colors text-sm font-medium relative group">
                Home
                <div className="absolute bottom-0 left-0 w-0 h-0.5 bg-gradient-to-r from-amber-400 to-green-500 group-hover:w-full transition-all duration-300"></div>
              </Link>
              <Link href="/how-it-works" className="text-white/80 hover:text-white transition-colors text-sm font-medium relative group">
                How It Works
                <div className="absolute bottom-0 left-0 w-0 h-0.5 bg-gradient-to-r from-amber-400 to-green-500 group-hover:w-full transition-all duration-300"></div>
              </Link>
              <Link href="/grants" className="text-white/80 hover:text-white transition-colors text-sm font-medium relative group">
                Dashboard
                <div className="absolute bottom-0 left-0 w-0 h-0.5 bg-gradient-to-r from-amber-400 to-green-500 group-hover:w-full transition-all duration-300"></div>
              </Link>
              <Link href="/treasury" className="text-white/80 hover:text-white transition-colors text-sm font-medium relative group">
                Treasury
                <div className="absolute bottom-0 left-0 w-0 h-0.5 bg-gradient-to-r from-amber-400 to-green-500 group-hover:w-full transition-all duration-300"></div>
              </Link>
              <span className="text-white font-medium text-sm relative">
                About
                <div className="absolute bottom-0 left-0 w-full h-0.5 bg-gradient-to-r from-amber-400 to-green-500"></div>
              </span>
            </div>

            {/* Back Button - Right Side */}
            <div className="absolute right-0">
              <Link href="/">
                <Button variant="outline" className="border-white/20 text-gray-900 hover:bg-white/10 hover:text-gray-800">
                  <ArrowLeft className="mr-2 h-4 w-4" />
                  Back
                </Button>
              </Link>
            </div>
          </div>
        </div>
      </nav>

      {/* About Content */}
      <section className="pt-24 pb-20 px-6">
        <div className="container mx-auto max-w-4xl">
          <div className="text-center mb-16">
            <Badge className="mb-4 bg-green-500/10 text-green-400 border-green-500/20">
              Decentralized Autonomous Organization
            </Badge>
            <h1 className="text-5xl font-bold text-white mb-6">
              About WAGA DAO
            </h1>
            <p className="text-xl text-white/70 max-w-2xl mx-auto">
              Regenerating African coffee economies through blockchain technology, sustainable farming practices, and community-driven development.
            </p>
          </div>

          {/* Key Facts */}
          <div className="grid md:grid-cols-2 gap-6 mb-16">
            {keyFacts.map((fact, index) => {
              const IconComponent = fact.icon
              return (
                <Card
                  key={index}
                  className="bg-black/20 backdrop-blur-xl border-white/10 hover:border-white/30 transition-all duration-500"
                >
                  <CardContent className="p-6">
                    <div className="flex items-start space-x-4">
                      <div className="w-12 h-12 bg-gradient-to-br from-green-500 to-emerald-600 rounded-2xl flex items-center justify-center flex-shrink-0">
                        <IconComponent className="h-6 w-6 text-white" />
                      </div>
                      <div>
                        <h3 className="text-xl font-bold text-white mb-2">{fact.title}</h3>
                        <p className="text-white/70">{fact.description}</p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              )
            })}
          </div>

          {/* Contact Information */}
          <Card className="bg-black/20 backdrop-blur-xl border-white/10 mb-16">
            <CardContent className="p-8">
              <h2 className="text-3xl font-bold text-white mb-8 text-center">Get in Touch</h2>
              <div className="grid md:grid-cols-3 gap-6">
                {contacts.map((contact, index) => {
                  const IconComponent = contact.icon
                  return (
                    <a
                      key={index}
                      href={contact.href}
                      className="flex items-center space-x-3 p-4 bg-white/5 rounded-lg hover:bg-white/10 transition-colors group"
                    >
                      <IconComponent className="h-5 w-5 text-green-400 group-hover:scale-110 transition-transform" />
                      <div>
                        <div className="text-white/60 text-sm">{contact.label}</div>
                        <div className="text-white font-medium">{contact.value}</div>
                      </div>
                    </a>
                  )
                })}
              </div>
            </CardContent>
          </Card>

          {/* Legal */}
          <div className="text-center">
            <p className="text-white/70 text-sm">
              © 2025 WAGA DAO • Decentralized Autonomous Organization
            </p>
            <p className="text-white/60 text-xs mt-2">
              Regenerating African Coffee Economies
            </p>
          </div>
        </div>
      </section>
    </div>
  )
}
