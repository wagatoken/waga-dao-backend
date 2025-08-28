/**
 * WAGA DAO Admin Portal
 * Comprehensive administrative interface for grant management, milestone validation, and system oversight
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
import ZKProofManager from "@/components/zk-proofs/ZKProofManager"
import {
  Shield,
  ArrowLeft,
  CheckCircle,
  Clock,
  Users,
  AlertTriangle,
  DollarSign,
  FileText,
  Target,
  TrendingUp,
  Calendar,
  Search,
  Filter,
  Download,
  Eye,
  Edit,
  X,
  Check,
  Menu
} from "lucide-react"

// Types based on smart contract and database schema
interface Grant {
  grantId: number
  cooperativeId: number
  cooperativeName: string
  grantAmount: number
  status: 'ACTIVE' | 'COMPLETED' | 'DEFAULTED'
  usePhasedDisbursement: boolean
  totalMilestones: number
  completedMilestones: number
  disbursedAmount: number
  remainingBalance: number
  createdAt: string
  blockchainTxHash?: string
}

interface Milestone {
  milestoneId: number
  grantId: number
  milestoneIndex: number
  description: string
  percentageShare: number
  isCompleted: boolean
  evidenceUri?: string
  completedTimestamp?: string
  validatorAddress?: string
  disbursedAmount: number
}

interface Evidence {
  evidenceId: number
  milestoneId: number
  evidenceType: string
  evidenceUri: string
  description: string
  submittedBy: string
  submittedAt: string
  validationStatus: 'pending' | 'approved' | 'rejected'
  validatedBy?: string
  validatedAt?: string
  validationNotes?: string
}

interface Cooperative {
  cooperativeId: number
  name: string
  location: string
  country: string
  contactPerson: string
  email: string
  paymentAddress: string
  farmersCount: number
  isVerified: boolean
  verificationDate?: string
}

export default function AdminPortal() {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false)
  const [searchTerm, setSearchTerm] = useState("")
  const [selectedTab, setSelectedTab] = useState("overview")
  
  // Mock data - In production, this would come from API calls
  const [grants, setGrants] = useState<Grant[]>([
    {
      grantId: 1,
      cooperativeId: 1,
      cooperativeName: "Finca El Paraíso Cooperative",
      grantAmount: 50000,
      status: 'ACTIVE',
      usePhasedDisbursement: true,
      totalMilestones: 4,
      completedMilestones: 2,
      disbursedAmount: 25000,
      remainingBalance: 25000,
      createdAt: "2024-01-15",
      blockchainTxHash: "0x1234...5678"
    },
    {
      grantId: 2,
      cooperativeId: 2,
      cooperativeName: "Alta Vista Coffee Collective",
      grantAmount: 75000,
      status: 'ACTIVE',
      usePhasedDisbursement: true,
      totalMilestones: 5,
      completedMilestones: 1,
      disbursedAmount: 15000,
      remainingBalance: 60000,
      createdAt: "2024-02-01",
      blockchainTxHash: "0xabcd...efgh"
    }
  ])

  const [pendingEvidence, setPendingEvidence] = useState<Evidence[]>([
    {
      evidenceId: 1,
      milestoneId: 3,
      evidenceType: "document",
      evidenceUri: "ipfs://QmXyz123...",
      description: "Land preparation completion certificate",
      submittedBy: "0x742d35Cc...",
      submittedAt: "2024-08-25T10:30:00Z",
      validationStatus: "pending"
    },
    {
      evidenceId: 2,
      milestoneId: 4,
      evidenceType: "image",
      evidenceUri: "ipfs://QmAbc456...",
      description: "Irrigation system installation photos",
      submittedBy: "0x742d35Cc...",
      submittedAt: "2024-08-26T14:15:00Z",
      validationStatus: "pending"
    }
  ])

  const [cooperatives, setCooperatives] = useState<Cooperative[]>([
    {
      cooperativeId: 1,
      name: "Finca El Paraíso Cooperative",
      location: "Huehuetenango, Guatemala",
      country: "Guatemala",
      contactPerson: "Maria Rodriguez",
      email: "maria@fincaparaiso.gt",
      paymentAddress: "0x742d35Cc6d7...",
      farmersCount: 45,
      isVerified: true,
      verificationDate: "2024-01-10"
    },
    {
      cooperativeId: 2,
      name: "Alta Vista Coffee Collective",
      location: "Antigua, Guatemala",
      country: "Guatemala",
      contactPerson: "Carlos Mendez",
      email: "carlos@altavista.gt",
      paymentAddress: "0x892e46Dd8e9...",
      farmersCount: 32,
      isVerified: false
    }
  ])

  const navigationItems = [
    { name: "Home", href: "/" },
    { name: "How It Works", href: "/how-it-works" },
    { name: "Dashboard", href: "/grants" },
    { name: "Treasury", href: "/treasury" },
    { name: "About", href: "/about" }
  ]

  const handleEvidenceValidation = (evidenceId: number, status: 'approved' | 'rejected', notes: string) => {
    setPendingEvidence(prev => prev.map(evidence => 
      evidence.evidenceId === evidenceId 
        ? { 
            ...evidence, 
            validationStatus: status,
            validatedAt: new Date().toISOString(),
            validationNotes: notes,
            validatedBy: "0xadmin123..." // Admin address
          }
        : evidence
    ))
  }

  const handleMilestoneDisbursement = (grantId: number, milestoneId: number, amount: number) => {
    // In production, this would call smart contract function
    setGrants(prev => prev.map(grant => 
      grant.grantId === grantId 
        ? { 
            ...grant, 
            disbursedAmount: grant.disbursedAmount + amount,
            remainingBalance: grant.remainingBalance - amount,
            completedMilestones: grant.completedMilestones + 1
          }
        : grant
    ))
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50">
      {/* Navigation */}
      <nav className="fixed top-0 w-full z-50 bg-white/90 backdrop-blur-xl border-b border-slate-200 shadow-sm">
        <div className="container mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            {/* Logo */}
            <Link href="/" className="flex items-center space-x-3 group">
              <div className="relative">
                <div className="w-10 h-10 bg-gradient-to-br from-slate-600 to-blue-600 rounded-2xl flex items-center justify-center transition-all duration-300 group-hover:scale-110">
                  <Shield className="h-6 w-6 text-white" />
                </div>
                <div className="absolute inset-0 bg-gradient-to-br from-slate-600 to-blue-600 rounded-2xl blur-md opacity-50"></div>
              </div>
              <div>
                <span className="text-2xl font-bold text-gray-900">WAGA DAO</span>
                <div className="text-xs text-gray-500">Admin Portal</div>
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
                  <div className="absolute bottom-0 left-0 w-0 h-0.5 bg-gradient-to-r from-slate-500 to-blue-600 group-hover:w-full transition-all duration-300"></div>
                </Link>
              ))}
              <Badge className="bg-red-500/10 text-red-700 border-red-200">
                <Shield className="mr-2 h-4 w-4" />
                Admin Access
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
                <Button variant="outline" size="sm" className="border-slate-200 text-gray-700 hover:bg-slate-50">
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
      <div className="bg-gradient-to-r from-slate-800 to-blue-900 text-white pt-24 pb-16">
        <div className="container mx-auto px-6">
          <div className="text-center">
            <Badge className="mb-4 bg-blue-500/20 text-blue-100 border-blue-300/30">
              <Shield className="mr-2 h-4 w-4" />
              Administrator Dashboard
            </Badge>
            <h1 className="text-4xl md:text-6xl font-bold mb-6">
              Admin Portal
            </h1>
            <p className="text-xl md:text-2xl text-blue-100 max-w-3xl mx-auto mb-8">
              Grant management, milestone validation, and cooperative oversight
            </p>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="container mx-auto px-6 py-12">
        <Tabs value={selectedTab} onValueChange={setSelectedTab} className="space-y-8">
          <TabsList className="grid w-full grid-cols-6 lg:w-auto lg:grid-cols-6">
            <TabsTrigger value="overview">Overview</TabsTrigger>
            <TabsTrigger value="grants">Grants</TabsTrigger>
            <TabsTrigger value="validation">Validation</TabsTrigger>
            <TabsTrigger value="zk-proofs">ZK Proofs</TabsTrigger>
            <TabsTrigger value="cooperatives">Cooperatives</TabsTrigger>
            <TabsTrigger value="system">System</TabsTrigger>
          </TabsList>

          {/* Overview Tab */}
          <TabsContent value="overview" className="space-y-8">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              <Card className="bg-white/80 backdrop-blur-xl border-slate-200">
                <CardContent className="p-6 text-center">
                  <Target className="w-12 h-12 text-green-600 mx-auto mb-4" />
                  <div className="text-3xl font-bold text-gray-900">{grants.length}</div>
                  <div className="text-sm text-gray-600">Active Grants</div>
                </CardContent>
              </Card>

              <Card className="bg-white/80 backdrop-blur-xl border-slate-200">
                <CardContent className="p-6 text-center">
                  <Clock className="w-12 h-12 text-orange-600 mx-auto mb-4" />
                  <div className="text-3xl font-bold text-gray-900">{pendingEvidence.length}</div>
                  <div className="text-sm text-gray-600">Pending Validations</div>
                </CardContent>
              </Card>

              <Card className="bg-white/80 backdrop-blur-xl border-slate-200">
                <CardContent className="p-6 text-center">
                  <Users className="w-12 h-12 text-blue-600 mx-auto mb-4" />
                  <div className="text-3xl font-bold text-gray-900">{cooperatives.length}</div>
                  <div className="text-sm text-gray-600">Registered Cooperatives</div>
                </CardContent>
              </Card>

              <Card className="bg-white/80 backdrop-blur-xl border-slate-200">
                <CardContent className="p-6 text-center">
                  <DollarSign className="w-12 h-12 text-purple-600 mx-auto mb-4" />
                  <div className="text-3xl font-bold text-gray-900">
                    ${grants.reduce((sum, grant) => sum + grant.disbursedAmount, 0).toLocaleString()}
                  </div>
                  <div className="text-sm text-gray-600">Total Disbursed</div>
                </CardContent>
              </Card>
            </div>

            {/* Recent Activity */}
            <Card className="bg-white/80 backdrop-blur-xl border-slate-200">
              <CardHeader>
                <CardTitle>Recent Activity</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="flex items-center space-x-4 p-4 bg-green-50 rounded-lg">
                    <CheckCircle className="w-6 h-6 text-green-600" />
                    <div>
                      <div className="font-medium">Milestone Completed</div>
                      <div className="text-sm text-gray-600">Finca El Paraíso - Irrigation Installation</div>
                    </div>
                    <div className="text-sm text-gray-500 ml-auto">2 hours ago</div>
                  </div>
                  
                  <div className="flex items-center space-x-4 p-4 bg-orange-50 rounded-lg">
                    <Clock className="w-6 h-6 text-orange-600" />
                    <div>
                      <div className="font-medium">Evidence Submitted</div>
                      <div className="text-sm text-gray-600">Alta Vista - Land preparation documentation</div>
                    </div>
                    <div className="text-sm text-gray-500 ml-auto">5 hours ago</div>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Grants Management Tab */}
          <TabsContent value="grants" className="space-y-6">
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
              <h2 className="text-2xl font-bold text-gray-900">Grant Management</h2>
              <div className="flex space-x-2">
                <Input
                  placeholder="Search grants..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="w-64"
                />
                <Button variant="outline" size="sm">
                  <Filter className="w-4 h-4 mr-2" />
                  Filter
                </Button>
                <Button variant="outline" size="sm">
                  <Download className="w-4 h-4 mr-2" />
                  Export
                </Button>
              </div>
            </div>

            <Card className="bg-white/80 backdrop-blur-xl border-slate-200">
              <CardContent className="p-0">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Grant ID</TableHead>
                      <TableHead>Cooperative</TableHead>
                      <TableHead>Amount</TableHead>
                      <TableHead>Progress</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead>Actions</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {grants.map((grant) => (
                      <TableRow key={grant.grantId}>
                        <TableCell className="font-medium">#{grant.grantId}</TableCell>
                        <TableCell>{grant.cooperativeName}</TableCell>
                        <TableCell>${grant.grantAmount.toLocaleString()}</TableCell>
                        <TableCell>
                          <div className="space-y-1">
                            <div className="text-sm">{grant.completedMilestones}/{grant.totalMilestones} milestones</div>
                            <div className="w-24 bg-gray-200 rounded-full h-2">
                              <div 
                                className="bg-blue-600 h-2 rounded-full" 
                                style={{ width: `${(grant.completedMilestones / grant.totalMilestones) * 100}%` }}
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
                              <Edit className="w-4 h-4" />
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

          {/* Evidence Validation Tab */}
          <TabsContent value="validation" className="space-y-6">
            <div className="flex justify-between items-center">
              <h2 className="text-2xl font-bold text-gray-900">Evidence Validation</h2>
              <Badge className="bg-orange-100 text-orange-800">
                {pendingEvidence.filter(e => e.validationStatus === 'pending').length} Pending
              </Badge>
            </div>

            <div className="grid gap-6">
              {pendingEvidence.map((evidence) => (
                <Card key={evidence.evidenceId} className="bg-white/80 backdrop-blur-xl border-slate-200">
                  <CardHeader>
                    <div className="flex justify-between items-start">
                      <div>
                        <CardTitle>Evidence #{evidence.evidenceId}</CardTitle>
                        <p className="text-gray-600 mt-1">{evidence.description}</p>
                      </div>
                      <Badge variant={evidence.validationStatus === 'pending' ? 'secondary' : 'default'}>
                        {evidence.validationStatus}
                      </Badge>
                    </div>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-2 gap-4 text-sm">
                      <div>
                        <strong>Type:</strong> {evidence.evidenceType}
                      </div>
                      <div>
                        <strong>Submitted:</strong> {new Date(evidence.submittedAt).toLocaleDateString()}
                      </div>
                      <div>
                        <strong>Submitted by:</strong> {evidence.submittedBy.slice(0, 10)}...
                      </div>
                      <div>
                        <strong>URI:</strong> <a href={evidence.evidenceUri} className="text-blue-600 hover:underline">View Evidence</a>
                      </div>
                    </div>

                    {evidence.validationStatus === 'pending' && (
                      <div className="border-t pt-4 space-y-4">
                        <Textarea placeholder="Validation notes..." className="h-20" />
                        <div className="flex space-x-2">
                          <Button 
                            onClick={() => handleEvidenceValidation(evidence.evidenceId, 'approved', '')}
                            className="bg-green-600 hover:bg-green-700"
                          >
                            <Check className="w-4 h-4 mr-2" />
                            Approve
                          </Button>
                          <Button 
                            variant="outline"
                            onClick={() => handleEvidenceValidation(evidence.evidenceId, 'rejected', '')}
                            className="border-red-200 text-red-600 hover:bg-red-50"
                          >
                            <X className="w-4 h-4 mr-2" />
                            Reject
                          </Button>
                        </div>
                      </div>
                    )}

                    {evidence.validationStatus !== 'pending' && evidence.validationNotes && (
                      <div className="border-t pt-4">
                        <strong>Validation Notes:</strong>
                        <p className="text-gray-600 mt-1">{evidence.validationNotes}</p>
                      </div>
                    )}
                  </CardContent>
                </Card>
              ))}
            </div>
          </TabsContent>

          {/* ZK Proofs Tab */}
          <TabsContent value="zk-proofs" className="space-y-6">
            <ZKProofManager />
          </TabsContent>

          {/* Cooperatives Tab */}
          <TabsContent value="cooperatives" className="space-y-6">
            <div className="flex justify-between items-center">
              <h2 className="text-2xl font-bold text-gray-900">Cooperative Management</h2>
              <Button>Add Cooperative</Button>
            </div>

            <Card className="bg-white/80 backdrop-blur-xl border-slate-200">
              <CardContent className="p-0">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Name</TableHead>
                      <TableHead>Location</TableHead>
                      <TableHead>Farmers</TableHead>
                      <TableHead>Contact</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead>Actions</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {cooperatives.map((coop) => (
                      <TableRow key={coop.cooperativeId}>
                        <TableCell className="font-medium">{coop.name}</TableCell>
                        <TableCell>{coop.location}</TableCell>
                        <TableCell>{coop.farmersCount}</TableCell>
                        <TableCell>{coop.email}</TableCell>
                        <TableCell>
                          <Badge variant={coop.isVerified ? 'default' : 'secondary'}>
                            {coop.isVerified ? 'Verified' : 'Pending'}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <div className="flex space-x-2">
                            <Button variant="outline" size="sm">
                              <Eye className="w-4 h-4" />
                            </Button>
                            {!coop.isVerified && (
                              <Button size="sm" className="bg-green-600 hover:bg-green-700">
                                Verify
                              </Button>
                            )}
                          </div>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </CardContent>
            </Card>
          </TabsContent>

          {/* System Status Tab */}
          <TabsContent value="system" className="space-y-6">
            <h2 className="text-2xl font-bold text-gray-900">System Status</h2>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <Card className="bg-white/80 backdrop-blur-xl border-slate-200">
                <CardHeader>
                  <CardTitle>Blockchain Status</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="flex justify-between items-center">
                    <span>Network</span>
                    <Badge className="bg-green-100 text-green-800">Arbitrum One</Badge>
                  </div>
                  <div className="flex justify-between items-center">
                    <span>Block Height</span>
                    <span className="font-mono">245,123,456</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span>Gas Price</span>
                    <span>0.1 gwei</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span>Contract Status</span>
                    <Badge className="bg-green-100 text-green-800">Active</Badge>
                  </div>
                </CardContent>
              </Card>

              <Card className="bg-white/80 backdrop-blur-xl border-slate-200">
                <CardHeader>
                  <CardTitle>Database Status</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="flex justify-between items-center">
                    <span>Connection</span>
                    <Badge className="bg-green-100 text-green-800">Healthy</Badge>
                  </div>
                  <div className="flex justify-between items-center">
                    <span>Last Sync</span>
                    <span>2 minutes ago</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span>Records</span>
                    <span>1,247 entries</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span>Storage</span>
                    <span>2.3 GB / 100 GB</span>
                  </div>
                </CardContent>
              </Card>
            </div>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  )
}
