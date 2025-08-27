/**
 * Admin Portal - Placeholder Page
 * For milestone validation and grant management
 */

"use client"

import Link from "next/link"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import {
  Coffee,
  Shield,
  ArrowLeft,
  CheckCircle,
  Clock,
  Users,
  AlertTriangle
} from "lucide-react"

export default function AdminPortal() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      {/* Navigation */}
      <nav className="fixed top-0 w-full z-50 bg-white/90 backdrop-blur-xl border-b border-blue-200 shadow-sm">
        <div className="container mx-auto px-6 py-4">
          <div className="flex items-center justify-center relative">
            {/* Logo - Left Side */}
            <div className="absolute left-0">
              <Link href="/" className="flex items-center space-x-3 group">
                <div className="relative">
                  <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-indigo-600 rounded-2xl flex items-center justify-center transition-all duration-300 group-hover:scale-110">
                    <Shield className="h-6 w-6 text-white" />
                  </div>
                  <div className="absolute inset-0 bg-gradient-to-br from-blue-500 to-indigo-600 rounded-2xl blur-md opacity-50"></div>
                </div>
                <div>
                  <span className="text-2xl font-bold text-gray-900">WAGA DAO</span>
                  <div className="text-xs text-gray-500">Admin Portal</div>
                </div>
              </Link>
            </div>

            {/* Centered Navigation */}
            <div className="hidden lg:flex items-center space-x-8">
              <Link href="/" className="text-gray-600 hover:text-gray-900 transition-colors text-sm font-medium relative group">
                Home
                <div className="absolute bottom-0 left-0 w-0 h-0.5 bg-gradient-to-r from-blue-500 to-indigo-600 group-hover:w-full transition-all duration-300"></div>
              </Link>
              <Link href="/grants" className="text-gray-600 hover:text-gray-900 transition-colors text-sm font-medium relative group">
                Dashboard
                <div className="absolute bottom-0 left-0 w-0 h-0.5 bg-gradient-to-r from-blue-500 to-indigo-600 group-hover:w-full transition-all duration-300"></div>
              </Link>
              <span className="text-gray-900 font-medium text-sm">Admin Portal</span>
            </div>

            {/* Back Button - Right Side */}
            <div className="absolute right-0">
              <Link href="/">
                <Button variant="outline" size="sm" className="border-blue-200 text-gray-700 hover:bg-blue-50">
                  <ArrowLeft className="h-4 w-4 mr-2" />
                  Back
                </Button>
              </Link>
            </div>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <div className="bg-gradient-to-r from-blue-800 to-indigo-900 text-white pt-24 pb-16">
        <div className="container mx-auto px-6">
          <div className="text-center">
            <Badge className="mb-4 bg-blue-500/20 text-blue-100 border-blue-300/30">
              <Shield className="mr-2 h-4 w-4" />
              Administrator Access
            </Badge>
            <h1 className="text-4xl md:text-6xl font-bold mb-6">
              Admin Portal
            </h1>
            <p className="text-xl md:text-2xl text-blue-100 max-w-3xl mx-auto mb-8">
              Milestone validation, grant oversight, and system administration
            </p>
          </div>
        </div>
      </div>

      {/* Coming Soon Content */}
      <section className="py-16 px-6">
        <div className="container mx-auto max-w-4xl text-center">
          <Card className="bg-white/80 backdrop-blur-xl border-blue-200 shadow-xl">
            <CardHeader>
              <div className="w-20 h-20 bg-gradient-to-br from-blue-500 to-indigo-600 rounded-full flex items-center justify-center mx-auto mb-4">
                <Shield className="h-10 w-10 text-white" />
              </div>
              <CardTitle className="text-3xl text-gray-900 mb-4">Coming Soon</CardTitle>
              <p className="text-gray-600 text-lg">
                The Admin Portal is currently under development. This will be the central hub for:
              </p>
            </CardHeader>

            <CardContent className="space-y-8">
              <div className="grid md:grid-cols-2 gap-6">
                <div className="text-center p-6 bg-blue-50 rounded-xl">
                  <CheckCircle className="h-12 w-12 text-blue-600 mx-auto mb-4" />
                  <h3 className="text-xl font-bold text-gray-900 mb-2">Milestone Validation</h3>
                  <p className="text-gray-600">Review and validate cooperative milestone submissions</p>
                </div>

                <div className="text-center p-6 bg-indigo-50 rounded-xl">
                  <Clock className="h-12 w-12 text-indigo-600 mx-auto mb-4" />
                  <h3 className="text-xl font-bold text-gray-900 mb-2">Grant Management</h3>
                  <p className="text-gray-600">Monitor grant progress and disbursement schedules</p>
                </div>

                <div className="text-center p-6 bg-blue-50 rounded-xl">
                  <Users className="h-12 w-12 text-blue-600 mx-auto mb-4" />
                  <h3 className="text-xl font-bold text-gray-900 mb-2">Cooperative Oversight</h3>
                  <p className="text-gray-600">Manage cooperative registrations and verifications</p>
                </div>

                <div className="text-center p-6 bg-indigo-50 rounded-xl">
                  <AlertTriangle className="h-12 w-12 text-indigo-600 mx-auto mb-4" />
                  <h3 className="text-xl font-bold text-gray-900 mb-2">System Monitoring</h3>
                  <p className="text-gray-600">Track system health and blockchain transactions</p>
                </div>
              </div>

              <div className="bg-gray-50 rounded-xl p-6">
                <p className="text-gray-600 mb-4">
                  <strong>Expected Launch:</strong> Q4 2025
                </p>
                <p className="text-gray-600">
                  For immediate administrative needs, please contact the development team at{" "}
                  <a href="mailto:admin@wagatoken.io" className="text-blue-600 hover:underline">
                    admin@wagatoken.io
                  </a>
                </p>
              </div>
            </CardContent>
          </Card>
        </div>
      </section>
    </div>
  )
}
