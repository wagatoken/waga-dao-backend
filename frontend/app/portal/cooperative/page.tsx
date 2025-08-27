/**
 * WAGA DAO Cooperative Portal
 * Comprehensive cooperative interface for grant management, milestone tracking, and coffee inventory
 * Based on CooperativeGrantManagerV2 smart contract and phased disbursement database schema
 */

"use client"

import { useState, useEffect } from "react"
import Link from "next/link"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Progress } from "@/components/ui/progress"
import {
  Coffee,
  ArrowLeft,
  DollarSign,
  FileText,
  Clock,
  CheckCircle,
  Upload,
  MapPin,
  Users,
  Calendar,
  TrendingUp,
  Leaf,
  Award,
  Target,
  AlertCircle,
  Menu,
  Eye,
  Download,
  Plus
} from "lucide-react"

// Types aligned with database schema from schema.sql
interface CooperativeProfile {
  cooperative_id: number
  name: string
  location: string
  country: string
  region?: string
  contact_person?: string
  email?: string
  phone?: string
  legal_status?: string
  established_year?: number
  registration_number?: string
  payment_address?: string
  farmers_count: number
  total_farm_area_hectares: number
  primary_crops: string
  certifications: string[]
  is_verified: boolean
  verification_date?: Date
  verified_by?: string
  created_at: Date
  updated_at: Date
}

interface Grant {
  grant_id: number
  cooperative_id: number
  grant_amount_usd: number
  grant_date: Date
  grant_purpose?: string
  uses_phased_disbursement: boolean
  revenue_sharing_percentage: number
  repayment_cap_multiplier: number
  status: "ACTIVE" | "COMPLETED" | "DEFAULTED"
  total_revenue_shared: number
  remaining_obligation: number
  grant_transaction_hash?: string
  blockchain_network: string
  created_at: Date
  updated_at: Date
}

interface Milestone {
  milestone_id: number
  schedule_id: number
  milestone_index: number
  description: string
  percentage_share: number
  is_completed: boolean
  evidence_uri?: string
  completed_timestamp?: Date
  validator_address?: string
  disbursed_amount: number
  blockchain_tx_hash?: string
  created_at: Date
  updated_at: Date
}

export default function CooperativePortal() {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false)
  const [searchTerm, setSearchTerm] = useState("")
  const [selectedTab, setSelectedTab] = useState("overview")
  const [loading, setLoading] = useState(false)

  // Mock data - In production, this would come from API calls
  const [profile] = useState<CooperativeProfile>({
    cooperative_id: 1,
    name: "Finca El Paraíso Cooperative",
    location: "Huehuetenango, Guatemala", 
    country: "Guatemala",
    region: "Western Highlands",
    contact_person: "Maria Rodriguez",
    email: "maria@fincaparaiso.gt",
    phone: "+502-1234-5678",
    legal_status: "Registered Cooperative",
    established_year: 2018,
    registration_number: "COOP-GT-2018-045",
    payment_address: "0x742d35Cc6d7...",
    farmers_count: 45,
    total_farm_area_hectares: 120.5,
    primary_crops: "Arabica Coffee",
    certifications: ["Fair Trade", "Organic", "Bird Friendly"],
    is_verified: true,
    verification_date: new Date("2024-01-10"),
    verified_by: "WAGA Verification Team",
    created_at: new Date("2024-01-01"),
    updated_at: new Date("2024-08-27")
  })

  const [grants] = useState<Grant[]>([
    {
      grant_id: 1,
      cooperative_id: 1,
      grant_amount_usd: 50000,
      grant_date: new Date("2024-01-15"),
      grant_purpose: "Sustainable farming equipment and irrigation system",
      uses_phased_disbursement: true,
      revenue_sharing_percentage: 10.0,
      repayment_cap_multiplier: 2.0,
      status: "ACTIVE",
      total_revenue_shared: 5000,
      remaining_obligation: 95000,
      grant_transaction_hash: "0x1234567890abcdef...",
      blockchain_network: "arbitrum",
      created_at: new Date("2024-01-15"),
      updated_at: new Date("2024-08-27")
    }
  ])

  const [milestones] = useState<Milestone[]>([
    {
      milestone_id: 1,
      schedule_id: 1,
      milestone_index: 0,
      description: "Land preparation and soil testing",
      percentage_share: 2500, // 25% in basis points
      is_completed: true,
      evidence_uri: "ipfs://QmXyz123...",
      completed_timestamp: new Date("2024-02-15"),
      validator_address: "0xvalidator123...",
      disbursed_amount: 12500,
      blockchain_tx_hash: "0xabcdef123...",
      created_at: new Date("2024-01-15"),
      updated_at: new Date("2024-02-15")
    },
    {
      milestone_id: 2,
      schedule_id: 1,
      milestone_index: 1,
      description: "Purchase and install irrigation equipment",
      percentage_share: 3000, // 30% in basis points
      is_completed: true,
      evidence_uri: "ipfs://QmAbc456...",
      completed_timestamp: new Date("2024-04-20"),
      validator_address: "0xvalidator123...",
      disbursed_amount: 15000,
      blockchain_tx_hash: "0x789abc456...",
      created_at: new Date("2024-01-15"),
      updated_at: new Date("2024-04-20")
    },
    {
      milestone_id: 3,
      schedule_id: 1,
      milestone_index: 2,
      description: "Plant shade trees and implement agroforestry",
      percentage_share: 2000, // 20% in basis points
      is_completed: false,
      evidence_uri: undefined,
      completed_timestamp: undefined,
      validator_address: undefined,
      disbursed_amount: 0,
      blockchain_tx_hash: undefined,
      created_at: new Date("2024-01-15"),
      updated_at: new Date("2024-01-15")
    },
    {
      milestone_id: 4,
      schedule_id: 1,
      milestone_index: 3,
      description: "Harvest and quality assessment",
      percentage_share: 2500, // 25% in basis points
      is_completed: false,
      evidence_uri: undefined,
      completed_timestamp: undefined,
      validator_address: undefined,
      disbursed_amount: 0,
      blockchain_tx_hash: undefined,
      created_at: new Date("2024-01-15"),
      updated_at: new Date("2024-01-15")
    }
  ])

  const navigationItems = [
    { name: "Home", href: "/" },
    { name: "How It Works", href: "/how-it-works" },
    { name: "Dashboard", href: "/grants" },
    { name: "Treasury", href: "/treasury" },
    { name: "About", href: "/about" }
  ]

  // Calculate metrics
  const totalFunding = grants.reduce((sum, grant) => sum + grant.grant_amount_usd, 0)
  const disbursedFunding = milestones
    .filter(m => m.is_completed)
    .reduce((sum, m) => sum + m.disbursed_amount, 0)
  const completedMilestones = milestones.filter(m => m.is_completed).length
  const totalMilestones = milestones.length

  const handleEvidenceSubmission = (milestoneId: number, evidenceData: any) => {
    // In production, this would upload to IPFS and call smart contract
    console.log(`Submitting evidence for milestone ${milestoneId}:`, evidenceData)
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 to-emerald-50">
      {/* Navigation */}
      <nav className="fixed top-0 w-full z-50 bg-white/90 backdrop-blur-xl border-b border-green-200 shadow-sm">
        <div className="container mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            {/* Logo */}
            <Link href="/" className="flex items-center space-x-3 group">
              <div className="relative">
                <div className="w-10 h-10 bg-gradient-to-br from-green-600 to-emerald-600 rounded-2xl flex items-center justify-center transition-all duration-300 group-hover:scale-110">
                  <Coffee className="h-6 w-6 text-white" />
                </div>
                <div className="absolute inset-0 bg-gradient-to-br from-green-600 to-emerald-600 rounded-2xl blur-md opacity-50"></div>
              </div>
              <div>
                <span className="text-2xl font-bold text-gray-900">WAGA DAO</span>
                <div className="text-xs text-gray-500">Cooperative Portal</div>
              </div>
            </Link>

            {/* Desktop Navigation */}
            <div className="hidden lg:flex items-center space-x-8">
              {navigationItems.map((item) => (
                <Link
                  key={item.name}
                  href={item.href}
                  className="text-gray-600 hover:text-gray-900 transition-colors text-sm font-medium relative group"
                >
                  {item.name}
                  <div className="absolute bottom-0 left-0 w-0 h-0.5 bg-gradient-to-r from-green-500 to-emerald-600 group-hover:w-full transition-all duration-300"></div>
                </Link>
              ))}
              <Badge className="bg-green-500/10 text-green-700 border-green-200">
                <Coffee className="mr-2 h-4 w-4" />
                Cooperative Access
              </Badge>
            </div>

            {/* Mobile Menu Button */}
            <div className="lg:hidden">
              <Button
                variant="outline"
                size="sm"
                onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
              >
                <Menu className="h-4 w-4" />
              </Button>
            </div>

            {/* Back Button */}
            <div className="hidden lg:block">
              <Link href="/">
                <Button variant="outline" size="sm" className="border-green-200 text-gray-700 hover:bg-green-50">
                  <ArrowLeft className="h-4 w-4 mr-2" />
                  Back to Home
                </Button>
              </Link>
            </div>
          </div>
        </div>
      </nav>

      {/* Mobile Navigation */}
      {isMobileMenuOpen && (
        <div className="fixed inset-0 z-40 lg:hidden">
          <div className="fixed inset-0 bg-black/50" onClick={() => setIsMobileMenuOpen(false)}></div>
          <div className="fixed top-0 right-0 h-full w-64 bg-white shadow-xl pt-20 px-6">
            <div className="space-y-4">
              {navigationItems.map((item) => (
                <Link
                  key={item.name}
                  href={item.href}
                  className="block text-gray-600 hover:text-gray-900 transition-colors py-2"
                  onClick={() => setIsMobileMenuOpen(false)}
                >
                  {item.name}
                </Link>
              ))}
              <Link href="/" className="block pt-4">
                <Button variant="outline" size="sm" className="w-full">
                  <ArrowLeft className="h-4 w-4 mr-2" />
                  Back to Home
                </Button>
              </Link>
            </div>
          </div>
        </div>
      )}

      {/* Header */}
      <div className="bg-gradient-to-r from-green-800 to-emerald-900 text-white pt-24 pb-16">
        <div className="container mx-auto px-6">
          <div className="text-center">
            <Badge className="mb-4 bg-green-500/20 text-green-100 border-green-300/30">
              <Coffee className="mr-2 h-4 w-4" />
              Cooperative Dashboard
            </Badge>
            <h1 className="text-4xl md:text-6xl font-bold mb-6">
              {profile.name}
            </h1>
            <p className="text-xl md:text-2xl text-green-100 max-w-3xl mx-auto mb-8">
              Grant management, milestone tracking, and sustainable coffee production
            </p>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="container mx-auto px-6 py-12">
        <Tabs value={selectedTab} onValueChange={setSelectedTab} className="space-y-8">
          <TabsList className="grid w-full grid-cols-5 lg:w-auto lg:grid-cols-5">
            <TabsTrigger value="overview">Overview</TabsTrigger>
            <TabsTrigger value="grants">Grants</TabsTrigger>
            <TabsTrigger value="milestones">Milestones</TabsTrigger>
            <TabsTrigger value="profile">Profile</TabsTrigger>
            <TabsTrigger value="application">Apply</TabsTrigger>
          </TabsList>

          {/* Overview Tab */}
          <TabsContent value="overview" className="space-y-8">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              <Card className="bg-white/80 backdrop-blur-xl border-green-200">
                <CardContent className="p-6 text-center">
                  <DollarSign className="w-12 h-12 text-green-600 mx-auto mb-4" />
                  <div className="text-3xl font-bold text-gray-900">${totalFunding.toLocaleString()}</div>
                  <div className="text-sm text-gray-600">Total Funding</div>
                </CardContent>
              </Card>

              <Card className="bg-white/80 backdrop-blur-xl border-green-200">
                <CardContent className="p-6 text-center">
                  <CheckCircle className="w-12 h-12 text-blue-600 mx-auto mb-4" />
                  <div className="text-3xl font-bold text-gray-900">${disbursedFunding.toLocaleString()}</div>
                  <div className="text-sm text-gray-600">Disbursed</div>
                </CardContent>
              </Card>

              <Card className="bg-white/80 backdrop-blur-xl border-green-200">
                <CardContent className="p-6 text-center">
                  <Target className="w-12 h-12 text-purple-600 mx-auto mb-4" />
                  <div className="text-3xl font-bold text-gray-900">{completedMilestones}/{totalMilestones}</div>
                  <div className="text-sm text-gray-600">Milestones</div>
                </CardContent>
              </Card>

              <Card className="bg-white/80 backdrop-blur-xl border-green-200">
                <CardContent className="p-6 text-center">
                  <Users className="w-12 h-12 text-orange-600 mx-auto mb-4" />
                  <div className="text-3xl font-bold text-gray-900">{profile.farmers_count}</div>
                  <div className="text-sm text-gray-600">Farmers</div>
                </CardContent>
              </Card>
            </div>

            {/* Current Grant Progress */}
            <Card className="bg-white/80 backdrop-blur-xl border-green-200">
              <CardHeader>
                <CardTitle>Current Grant Progress</CardTitle>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="flex justify-between items-center">
                  <span className="text-lg font-medium">Grant #{grants[0]?.grant_id}</span>
                  <Badge className="bg-green-100 text-green-800">Active</Badge>
                </div>
                
                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span>Progress: {completedMilestones} of {totalMilestones} milestones</span>
                    <span>{Math.round((completedMilestones / totalMilestones) * 100)}%</span>
                  </div>
                  <Progress value={(completedMilestones / totalMilestones) * 100} className="h-3" />
                </div>

                <div className="grid grid-cols-2 gap-4 text-sm">
                  <div>
                    <strong>Grant Amount:</strong> ${grants[0]?.grant_amount_usd.toLocaleString()}
                  </div>
                  <div>
                    <strong>Disbursed:</strong> ${disbursedFunding.toLocaleString()}
                  </div>
                  <div>
                    <strong>Purpose:</strong> {grants[0]?.grant_purpose}
                  </div>
                  <div>
                    <strong>Revenue Share:</strong> {grants[0]?.revenue_sharing_percentage}%
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Recent Activity */}
            <Card className="bg-white/80 backdrop-blur-xl border-green-200">
              <CardHeader>
                <CardTitle>Recent Activity</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="flex items-center space-x-4 p-4 bg-green-50 rounded-lg">
                    <CheckCircle className="w-6 h-6 text-green-600" />
                    <div>
                      <div className="font-medium">Milestone Completed</div>
                      <div className="text-sm text-gray-600">Irrigation equipment installation verified</div>
                    </div>
                    <div className="text-sm text-gray-500 ml-auto">2 months ago</div>
                  </div>
                  
                  <div className="flex items-center space-x-4 p-4 bg-blue-50 rounded-lg">
                    <DollarSign className="w-6 h-6 text-blue-600" />
                    <div>
                      <div className="font-medium">Funds Disbursed</div>
                      <div className="text-sm text-gray-600">$15,000 released for milestone completion</div>
                    </div>
                    <div className="text-sm text-gray-500 ml-auto">2 months ago</div>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Grants Tab */}
          <TabsContent value="grants" className="space-y-6">
            <div className="flex justify-between items-center">
              <h2 className="text-2xl font-bold text-gray-900">Your Grants</h2>
              <Button>
                <Plus className="w-4 h-4 mr-2" />
                Apply for Grant
              </Button>
            </div>

            <Card className="bg-white/80 backdrop-blur-xl border-green-200">
              <CardContent className="p-0">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Grant ID</TableHead>
                      <TableHead>Amount</TableHead>
                      <TableHead>Purpose</TableHead>
                      <TableHead>Progress</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead>Actions</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {grants.map((grant) => (
                      <TableRow key={grant.grant_id}>
                        <TableCell className="font-medium">#{grant.grant_id}</TableCell>
                        <TableCell>${grant.grant_amount_usd.toLocaleString()}</TableCell>
                        <TableCell>{grant.grant_purpose}</TableCell>
                        <TableCell>
                          <div className="space-y-1">
                            <div className="text-sm">{completedMilestones}/{totalMilestones} milestones</div>
                            <div className="w-24 bg-gray-200 rounded-full h-2">
                              <div 
                                className="bg-green-600 h-2 rounded-full" 
                                style={{ width: `${(completedMilestones / totalMilestones) * 100}%` }}
                              ></div>
                            </div>
                          </div>
                        </TableCell>
                        <TableCell>
                          <Badge variant={grant.status === 'ACTIVE' ? 'default' : 'secondary'}>
                            {grant.status}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <div className="flex space-x-2">
                            <Button variant="outline" size="sm">
                              <Eye className="w-4 h-4" />
                            </Button>
                            <Button variant="outline" size="sm">
                              <Download className="w-4 h-4" />
                            </Button>
                          </div>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Milestones Tab */}
          <TabsContent value="milestones" className="space-y-6">
            <h2 className="text-2xl font-bold text-gray-900">Milestone Progress</h2>

            <div className="space-y-6">
              {milestones.map((milestone) => (
                <Card key={milestone.milestone_id} className="bg-white/80 backdrop-blur-xl border-green-200">
                  <CardHeader>
                    <div className="flex justify-between items-start">
                      <div>
                        <CardTitle>Milestone {milestone.milestone_index + 1}</CardTitle>
                        <p className="text-gray-600 mt-1">{milestone.description}</p>
                      </div>
                      <Badge variant={milestone.is_completed ? 'default' : 'secondary'}>
                        {milestone.is_completed ? 'Completed' : 'Pending'}
                      </Badge>
                    </div>
                  </CardHeader>
                  
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-2 gap-4 text-sm">
                      <div>
                        <strong>Share:</strong> {milestone.percentage_share / 100}%
                      </div>
                      <div>
                        <strong>Amount:</strong> ${milestone.disbursed_amount.toLocaleString()}
                      </div>
                      {milestone.completed_timestamp && (
                        <div>
                          <strong>Completed:</strong> {milestone.completed_timestamp.toLocaleDateString()}
                        </div>
                      )}
                      {milestone.blockchain_tx_hash && (
                        <div>
                          <strong>Tx Hash:</strong> {milestone.blockchain_tx_hash.slice(0, 20)}...
                        </div>
                      )}
                    </div>

                    {!milestone.is_completed && (
                      <div className="border-t pt-4 space-y-4">
                        <h4 className="font-medium">Submit Evidence</h4>
                        <Textarea placeholder="Evidence description..." className="h-20" />
                        <Input type="file" accept="image/*,application/pdf" />
                        <Button 
                          onClick={() => handleEvidenceSubmission(milestone.milestone_id, {})}
                          className="bg-green-600 hover:bg-green-700"
                        >
                          <Upload className="w-4 h-4 mr-2" />
                          Submit Evidence
                        </Button>
                      </div>
                    )}

                    {milestone.is_completed && milestone.evidence_uri && (
                      <div className="border-t pt-4">
                        <strong>Evidence:</strong>
                        <a href={milestone.evidence_uri} className="text-green-600 hover:underline ml-2">
                          View Submitted Evidence
                        </a>
                      </div>
                    )}
                  </CardContent>
                </Card>
              ))}
            </div>
          </TabsContent>

          {/* Profile Tab */}
          <TabsContent value="profile" className="space-y-6">
            <h2 className="text-2xl font-bold text-gray-900">Cooperative Profile</h2>

            <Card className="bg-white/80 backdrop-blur-xl border-green-200">
              <CardHeader>
                <CardTitle>Basic Information</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <strong>Name:</strong> {profile.name}
                  </div>
                  <div>
                    <strong>Location:</strong> {profile.location}
                  </div>
                  <div>
                    <strong>Country:</strong> {profile.country}
                  </div>
                  <div>
                    <strong>Region:</strong> {profile.region}
                  </div>
                  <div>
                    <strong>Contact Person:</strong> {profile.contact_person}
                  </div>
                  <div>
                    <strong>Email:</strong> {profile.email}
                  </div>
                  <div>
                    <strong>Farmers:</strong> {profile.farmers_count}
                  </div>
                  <div>
                    <strong>Farm Area:</strong> {profile.total_farm_area_hectares} hectares
                  </div>
                  <div>
                    <strong>Primary Crops:</strong> {profile.primary_crops}
                  </div>
                  <div>
                    <strong>Established:</strong> {profile.established_year}
                  </div>
                </div>

                {profile.certifications.length > 0 && (
                  <div>
                    <strong>Certifications:</strong>
                    <div className="flex flex-wrap gap-2 mt-2">
                      {profile.certifications.map((cert, index) => (
                        <Badge key={index} variant="outline" className="bg-green-50">
                          <Award className="w-3 h-3 mr-1" />
                          {cert}
                        </Badge>
                      ))}
                    </div>
                  </div>
                )}

                <div className="flex items-center space-x-2 pt-4">
                  {profile.is_verified ? (
                    <Badge className="bg-green-100 text-green-800">
                      <CheckCircle className="w-3 h-3 mr-1" />
                      Verified
                    </Badge>
                  ) : (
                    <Badge className="bg-orange-100 text-orange-800">
                      <Clock className="w-3 h-3 mr-1" />
                      Pending Verification
                    </Badge>
                  )}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Application Tab */}
          <TabsContent value="application" className="space-y-6">
            <h2 className="text-2xl font-bold text-gray-900">Apply for New Grant</h2>

            <Card className="bg-white/80 backdrop-blur-xl border-green-200">
              <CardHeader>
                <CardTitle>Grant Application</CardTitle>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Grant Purpose
                    </label>
                    <Textarea 
                      placeholder="Describe how you plan to use the grant funds..."
                      className="h-32"
                    />
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Requested Amount (USD)
                      </label>
                      <Input type="number" placeholder="50000" />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Project Duration (months)
                      </label>
                      <Input type="number" placeholder="12" />
                    </div>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Supporting Documents
                    </label>
                    <Input type="file" multiple accept=".pdf,.doc,.docx,.jpg,.png" />
                  </div>

                  <Button className="w-full bg-green-600 hover:bg-green-700">
                    <FileText className="w-4 h-4 mr-2" />
                    Submit Application
                  </Button>
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  )
}
