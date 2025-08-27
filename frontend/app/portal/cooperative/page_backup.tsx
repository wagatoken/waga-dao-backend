/**
 * Cooperative Portal - Main Dashboard
 * Full-featured portal for coffee cooperatives to manage grants, milestones, and inventory
 */

"use client"

import { useState, useEffect } from "react"
import Link from "next/link"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import { Alert, AlertDescription } from "@/components/ui/alert"
import {
  Coffee,
  DollarSign,
  FileText,
  Clock,
  CheckCircle,
  Upload,
  Users,
  MapPin,
  Coins,
  Calendar,
  Award,
  TrendingUp,
  AlertTriangle,
  Plus,
  Eye,
  Download,
  Settings,
  Bell,
  Shield,
  Target,
  ArrowLeft
} from "lucide-react"
import GrantDashboard from "@/components/grants/GrantDashboard"
// import GrantApplicationForm from "@/components/portal/GrantApplicationForm"
// import MilestoneManager from "@/components/portal/MilestoneManager"
// import InventoryTokenizer from "@/components/portal/InventoryTokenizer"

// Temporary placeholders until imports are resolved
const GrantApplicationForm = ({ cooperativeProfile }: any) => (
  <Card>
    <CardHeader>
      <CardTitle>Grant Application Form</CardTitle>
    </CardHeader>
    <CardContent>
      <p className="text-gray-600">Grant application form will be available here.</p>
    </CardContent>
  </Card>
)

const MilestoneManager = ({ grants }: any) => (
  <Card>
    <CardHeader>
      <CardTitle>Milestone Manager</CardTitle>
    </CardHeader>
    <CardContent>
      <p className="text-gray-600">Milestone management interface will be available here.</p>
    </CardContent>
  </Card>
)

const InventoryTokenizer = ({ cooperativeId }: any) => (
  <Card>
    <CardHeader>
      <CardTitle>Inventory Tokenizer</CardTitle>
    </CardHeader>
    <CardContent>
      <p className="text-gray-600">Coffee inventory tokenization interface will be available here.</p>
    </CardContent>
  </Card>
)

// Types aligned with database schema from schema.sql
interface CooperativeProfile {
  cooperative_id: number                 // PRIMARY KEY from cooperatives table
  name: string                          // VARCHAR(255) NOT NULL
  location: string                      // VARCHAR(255) NOT NULL  
  country: string                       // VARCHAR(100) NOT NULL
  region?: string                       // VARCHAR(100)
  contact_person?: string               // VARCHAR(255)
  email?: string                        // VARCHAR(255)
  phone?: string                        // VARCHAR(50)
  legal_status?: string                 // VARCHAR(100)
  established_year?: number             // INTEGER
  registration_number?: string          // VARCHAR(100)
  payment_address?: string              // VARCHAR(42) - Ethereum address
  farmers_count: number                 // INTEGER DEFAULT 0
  total_farm_area_hectares: number      // DECIMAL(10,2)
  primary_crops: string                 // TEXT DEFAULT 'Coffee'
  certifications: string[]              // TEXT[] - Array of certifications
  is_verified: boolean                  // BOOLEAN DEFAULT FALSE
  verification_date?: Date              // TIMESTAMP
  verified_by?: string                  // VARCHAR(255)
  created_at: Date                      // TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  updated_at: Date                      // TIMESTAMP DEFAULT CURRENT_TIMESTAMP
}

interface Grant {
  grant_id: number                      // PRIMARY KEY from cooperative_grants
  cooperative_id: number               // REFERENCES cooperatives(cooperative_id)
  grant_amount_usd: number              // DECIMAL(12,2) NOT NULL
  grant_date: Date                      // DATE NOT NULL
  grant_purpose?: string                // TEXT
  uses_phased_disbursement: boolean     // BOOLEAN DEFAULT false
  revenue_sharing_percentage: number    // DECIMAL(5,2) DEFAULT 10.00
  repayment_cap_multiplier: number      // DECIMAL(4,2) DEFAULT 2.0
  status: "ACTIVE" | "COMPLETED" | "DEFAULTED"  // VARCHAR(50) DEFAULT 'ACTIVE'
  total_revenue_shared: number          // DECIMAL(12,2) DEFAULT 0
  remaining_obligation: number          // COMPUTED COLUMN
  grant_transaction_hash?: string       // VARCHAR(66)
  blockchain_network: string            // VARCHAR(50) DEFAULT 'arbitrum'
  created_at: Date                      // TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  updated_at: Date                      // TIMESTAMP DEFAULT CURRENT_TIMESTAMP
}

interface DisbursementSchedule {
  schedule_id: number                   // PRIMARY KEY from disbursement_schedules
  grant_id: number                      // REFERENCES cooperative_grants(grant_id)
  total_milestones: number              // INTEGER NOT NULL CHECK (> 0)
  completed_milestones: number          // INTEGER DEFAULT 0
  is_active: boolean                    // BOOLEAN DEFAULT true
  escrowed_amount: number               // DECIMAL(18,6) NOT NULL
  blockchain_tx_hash?: string           // VARCHAR(66)
  created_at: Date                      // TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  updated_at: Date                      // TIMESTAMP DEFAULT CURRENT_TIMESTAMP
}

interface Milestone {
  milestone_id: number                  // PRIMARY KEY from milestones
  schedule_id: number                   // REFERENCES disbursement_schedules(schedule_id)
  milestone_index: number               // INTEGER NOT NULL CHECK (>= 0)
  description: string                   // TEXT NOT NULL
  percentage_share: number              // INTEGER NOT NULL CHECK (0-10000 basis points)
  is_completed: boolean                 // BOOLEAN DEFAULT false
  evidence_uri?: string                 // TEXT
  completed_timestamp?: Date            // TIMESTAMP
  validator_address?: string            // VARCHAR(42)
  disbursed_amount: number              // DECIMAL(18,6) DEFAULT 0
  blockchain_tx_hash?: string           // VARCHAR(66)
  created_at: Date                      // TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  updated_at: Date                      // TIMESTAMP DEFAULT CURRENT_TIMESTAMP
}

interface MilestoneEvidence {
  evidence_id: number                   // PRIMARY KEY from milestone_evidence
  milestone_id: number                  // REFERENCES milestones(milestone_id)
  evidence_type: string                 // VARCHAR(50) NOT NULL - 'document', 'image', 'video', 'report', 'ipfs'
  evidence_uri: string                  // TEXT NOT NULL
  evidence_hash?: string                // VARCHAR(66) - IPFS hash or file hash
  description?: string                  // TEXT
  submitted_by: string                  // VARCHAR(42) NOT NULL - Ethereum address
  submitted_at: Date                    // TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  validation_status: "pending" | "approved" | "rejected"  // VARCHAR(20) DEFAULT 'pending'
  validated_by?: string                 // VARCHAR(42) - Validator address
  validated_at?: Date                   // TIMESTAMP
  validation_notes?: string             // TEXT
  blockchain_tx_hash?: string           // VARCHAR(66)
  created_at: Date                      // TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  updated_at: Date                      // TIMESTAMP DEFAULT CURRENT_TIMESTAMP
}

interface CoffeeBatch {
  batch_id: number                      // BIGINT PRIMARY KEY from coffee_batches
  production_date: Date                 // TIMESTAMP NOT NULL
  expiry_date: Date                     // TIMESTAMP NOT NULL
  quantity_kg: number                   // DECIMAL(10,2) NOT NULL
  price_per_kg: number                  // DECIMAL(10,2) NOT NULL
  grant_value_usd: number               // DECIMAL(12,2) NOT NULL
  ipfs_hash?: string                    // VARCHAR(255) - IPFS metadata reference
  blockchain_network: string            // VARCHAR(50) NOT NULL DEFAULT 'arbitrum'
  transaction_hash?: string             // VARCHAR(66) - Creation tx hash
  block_number?: number                 // BIGINT
  token_type: "GREEN_BEANS" | "ROASTED_BEANS"  // VARCHAR(20) DEFAULT 'GREEN_BEANS'
  is_verified: boolean                  // BOOLEAN DEFAULT FALSE
  verification_date?: Date              // TIMESTAMP
  created_at: Date                      // TIMESTAMP DEFAULT CURRENT_TIMESTAMP
}

export default function CooperativePortal() {
  const [activeTab, setActiveTab] = useState("dashboard")
  const [profile, setProfile] = useState<CooperativeProfile | null>(null)
  const [grants, setGrants] = useState<Grant[]>([])
  const [milestones, setMilestones] = useState<Milestone[]>([])
  const [notifications, setNotifications] = useState<any[]>([])
  const [loading, setLoading] = useState(true)

  // Mock data initialization
  useEffect(() => {
  // Mock data aligned with database schema
  const mockProfile: CooperativeProfile = {
    cooperative_id: 1,
    name: "Nyamasheke Coffee Cooperative",
    location: "Nyamasheke District, Western Province",
    country: "Rwanda",
    region: "Western Province",
    contact_person: "Jean Baptiste Uwimana",
    email: "info@nyamasheke-coffee.rw",
    phone: "+250 788 123 456",
    legal_status: "Registered Cooperative",
    established_year: 2018,
    registration_number: "RC/COOP/001/2018",
    payment_address: "0x742d35Cc6634C0532925a3b8D6Ac6D72e66544E", // Example Ethereum address
    farmers_count: 250,
    total_farm_area_hectares: 1250.75,
    primary_crops: "Arabica Coffee",
    certifications: ["Organic", "Fair Trade", "Rainforest Alliance", "UTZ"],
    is_verified: true,
    verification_date: new Date("2023-06-15"),
    verified_by: "WAGA DAO Verification Team",
    created_at: new Date("2023-01-15"),
    updated_at: new Date("2024-01-20")
  }

  const mockGrants: Grant[] = [
    {
      grant_id: 1,
      cooperative_id: 1,
      grant_amount_usd: 25000.00,
      grant_date: new Date("2024-01-15"),
      grant_purpose: "Coffee processing equipment upgrade and farmer training programs",
      uses_phased_disbursement: true,
      revenue_sharing_percentage: 12.00,
      repayment_cap_multiplier: 2.0,
      status: "ACTIVE",
      total_revenue_shared: 1250.00,
      remaining_obligation: 48750.00, // 25000 * 2.0 - 1250
      grant_transaction_hash: "0x123...abc",
      blockchain_network: "arbitrum",
      created_at: new Date("2024-01-15"),
      updated_at: new Date("2024-01-20")
    },
    {
      grant_id: 2,
      cooperative_id: 1,
      grant_amount_usd: 15000.00,
      grant_date: new Date("2023-08-10"),
      grant_purpose: "Soil improvement and sustainable farming practices",
      uses_phased_disbursement: false,
      revenue_sharing_percentage: 10.00,
      repayment_cap_multiplier: 1.8,
      status: "COMPLETED",
      total_revenue_shared: 27000.00, // Fully repaid
      remaining_obligation: 0.00,
      grant_transaction_hash: "0x456...def",
      blockchain_network: "arbitrum",
      created_at: new Date("2023-08-10"),
      updated_at: new Date("2024-01-10")
    }
  ]

  const mockMilestones: Milestone[] = [
    {
      milestone_id: 1,
      schedule_id: 1, // Associated with first grant's disbursement schedule
      milestone_index: 0,
      description: "Initial equipment purchase and farmer training completion",
      percentage_share: 4000, // 40% in basis points
      is_completed: true,
      evidence_uri: "https://ipfs.io/ipfs/QmExample1...",
      completed_timestamp: new Date("2024-02-15"),
      validator_address: "0x789...ghi",
      disbursed_amount: 10000.00, // 40% of 25000
      blockchain_tx_hash: "0xmilestone1...abc",
      created_at: new Date("2024-01-15"),
      updated_at: new Date("2024-02-15")
    },
    {
      milestone_id: 2,
      schedule_id: 1,
      milestone_index: 1,
      description: "Mid-season crop monitoring and quality assessment",
      percentage_share: 3500, // 35% in basis points
      is_completed: true,
      evidence_uri: "https://ipfs.io/ipfs/QmExample2...",
      completed_timestamp: new Date("2024-05-20"),
      validator_address: "0x789...ghi",
      disbursed_amount: 8750.00, // 35% of 25000
      blockchain_tx_hash: "0xmilestone2...def",
      created_at: new Date("2024-01-15"),
      updated_at: new Date("2024-05-20")
    },
    {
      milestone_id: 3,
      schedule_id: 1,
      milestone_index: 2,
      description: "Final harvest documentation and quality certification",
      percentage_share: 2500, // 25% in basis points
      is_completed: false,
      evidence_uri: undefined,
      completed_timestamp: undefined,
      validator_address: undefined,
      disbursed_amount: 0.00,
      blockchain_tx_hash: undefined,
      created_at: new Date("2024-01-15"),
      updated_at: new Date("2024-01-15")
    }
  ]

  const mockNotifications = [
      {
        id: 1,
        type: "milestone_approved",
        title: "Milestone Approved",
        message: "Land Acquisition milestone has been validated. Next disbursement of $12,500 is being processed.",
        timestamp: new Date("2025-08-25"),
        read: false
      },
      {
        id: 2,
        type: "disbursement",
        title: "Funds Disbursed", 
        message: "$15,000 USDC has been transferred to your cooperative wallet.",
        timestamp: new Date("2025-08-20"),
        read: false
      },
      {
        id: 3,
        type: "milestone_due",
        title: "Milestone Due Soon",
        message: "Infrastructure Development milestone is due in 7 days.",
        timestamp: new Date("2025-08-18"),
        read: true
      }
    ]

    setTimeout(() => {
      setProfile(mockProfile)
      setGrants(mockGrants)
      setMilestones(mockMilestones)
      setNotifications(mockNotifications)
      setLoading(false)
    }, 1000)
  }, [])

  // Calculate metrics with database schema-aligned logic
  const totalMilestones = milestones.length
  const completedMilestones = milestones.filter((m: Milestone) => m.is_completed).length
  
  const totalFunding = grants.reduce((sum, grant) => sum + grant.grant_amount_usd, 0)
  const disbursedFunding = milestones
    .filter((m: Milestone) => m.is_completed)
    .reduce((sum: number, m: Milestone) => sum + m.disbursed_amount, 0)

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 to-emerald-100 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-green-500 mx-auto mb-4"></div>
          <p className="text-green-600 font-medium">Loading Cooperative Portal...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 to-emerald-100">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-green-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-4">
            <div className="flex items-center space-x-4">
              <Link href="/" className="flex items-center space-x-3 group">
                <div className="w-12 h-12 bg-gradient-to-br from-green-500 to-emerald-600 rounded-xl flex items-center justify-center transition-transform duration-300 group-hover:scale-110 group-hover:rotate-12">
                  <Coffee className="h-6 w-6 text-white" />
                </div>
                <div>
                  <span className="text-2xl font-bold text-gray-900">WAGA DAO</span>
                  <div className="text-xs text-gray-500">Cooperative Portal</div>
                </div>
              </Link>
              <div className="hidden lg:block h-8 w-px bg-gray-300"></div>
              <div className="hidden lg:block">
                <h1 className="text-xl font-bold text-gray-900">{profile?.name}</h1>
                <div className="flex items-center space-x-2">
                  <MapPin className="h-4 w-4 text-gray-400" />
                  <span className="text-sm text-gray-600">{profile?.location}</span>
                  <Badge 
                    variant={profile?.verificationStatus === "verified" ? "default" : "secondary"}
                    className={profile?.verificationStatus === "verified" ? "bg-green-100 text-green-800" : ""}
                  >
                    <Shield className="h-3 w-3 mr-1" />
                    {profile?.verificationStatus === "verified" ? "Verified" : "Pending"}
                  </Badge>
                </div>
              </div>
            </div>
            
            <div className="flex items-center space-x-2 md:space-x-4">
              <Link href="/">
                <Button variant="outline" size="sm">
                  <ArrowLeft className="h-4 w-4 mr-2" />
                  <span className="hidden sm:inline">Back to Home</span>
                  <span className="sm:hidden">Home</span>
                </Button>
              </Link>
              <Button variant="outline" size="sm">
                <Bell className="h-4 w-4 mr-0 sm:mr-2" />
                <span className="hidden sm:inline">Notifications</span>
                {notifications.filter(n => !n.read).length > 0 && (
                  <Badge className="ml-1 sm:ml-2 h-5 w-5 rounded-full bg-red-500 text-white text-xs p-0 flex items-center justify-center">
                    {notifications.filter(n => !n.read).length}
                  </Badge>
                )}
              </Button>
              <Button variant="outline" size="sm" className="hidden md:flex">
                <Settings className="h-4 w-4 mr-2" />
                <span className="hidden lg:inline">Settings</span>
              </Button>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Mobile Cooperative Info */}
        <div className="lg:hidden mb-6">
          <Card className="bg-gradient-to-r from-green-50 to-emerald-50 border-green-200">
            <CardContent className="p-4">
              <h2 className="text-lg font-bold text-gray-900 mb-2">{profile?.name}</h2>
              <div className="flex items-center space-x-4 text-sm text-gray-600 mb-2">
                <div className="flex items-center">
                  <MapPin className="h-4 w-4 mr-1" />
                  {profile?.location}
                </div>
                <Badge 
                  variant={profile?.verificationStatus === "verified" ? "default" : "secondary"}
                  className={profile?.verificationStatus === "verified" ? "bg-green-100 text-green-800" : ""}
                >
                  <Shield className="h-3 w-3 mr-1" />
                  {profile?.verificationStatus === "verified" ? "Verified" : "Pending"}
                </Badge>
              </div>
              <div className="flex items-center space-x-4 text-sm text-gray-600">
                <span>{profile?.members} members</span>
                <span>•</span>
                <span>Est. {profile?.established}</span>
              </div>
            </CardContent>
          </Card>
        </div>

        <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-6">
          <TabsList className="grid w-full grid-cols-6 lg:w-fit lg:grid-cols-6">
            <TabsTrigger value="dashboard" className="flex items-center space-x-2">
              <TrendingUp className="h-4 w-4" />
              <span className="hidden sm:inline">Dashboard</span>
            </TabsTrigger>
            <TabsTrigger value="grants" className="flex items-center space-x-2">
              <DollarSign className="h-4 w-4" />
              <span className="hidden sm:inline">Grants</span>
            </TabsTrigger>
            <TabsTrigger value="milestones" className="flex items-center space-x-2">
              <Target className="h-4 w-4" />
              <span className="hidden sm:inline">Milestones</span>
            </TabsTrigger>
            <TabsTrigger value="inventory" className="flex items-center space-x-2">
              <Coffee className="h-4 w-4" />
              <span className="hidden sm:inline">Inventory</span>
            </TabsTrigger>
            <TabsTrigger value="apply" className="flex items-center space-x-2">
              <Plus className="h-4 w-4" />
              <span className="hidden sm:inline">Apply</span>
            </TabsTrigger>
            <TabsTrigger value="profile" className="flex items-center space-x-2">
              <Users className="h-4 w-4" />
              <span className="hidden sm:inline">Profile</span>
            </TabsTrigger>
          </TabsList>

          {/* Dashboard Tab */}
          <TabsContent value="dashboard" className="space-y-6">
            {/* Key Metrics */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              <Card className="bg-gradient-to-br from-green-400 to-green-600 text-white">
                <CardContent className="p-6">
                  <div className="flex items-center">
                    <DollarSign className="h-8 w-8 text-green-100" />
                    <div className="ml-3">
                      <p className="text-green-100 text-sm font-medium">Total Funding</p>
                      <p className="text-2xl font-bold">${totalFunding.toLocaleString()}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card className="bg-gradient-to-br from-blue-400 to-blue-600 text-white">
                <CardContent className="p-6">
                  <div className="flex items-center">
                    <Coins className="h-8 w-8 text-blue-100" />
                    <div className="ml-3">
                      <p className="text-blue-100 text-sm font-medium">Disbursed</p>
                      <p className="text-2xl font-bold">${disbursedFunding.toLocaleString()}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card className="bg-gradient-to-br from-purple-400 to-purple-600 text-white">
                <CardContent className="p-6">
                  <div className="flex items-center">
                    <Target className="h-8 w-8 text-purple-100" />
                    <div className="ml-3">
                      <p className="text-purple-100 text-sm font-medium">Milestones</p>
                      <p className="text-2xl font-bold">{completedMilestones}/{totalMilestones}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card className="bg-gradient-to-br from-amber-400 to-amber-600 text-white">
                <CardContent className="p-6">
                  <div className="flex items-center">
                    <Users className="h-8 w-8 text-amber-100" />
                    <div className="ml-3">
                      <p className="text-amber-100 text-sm font-medium">Members</p>
                      <p className="text-2xl font-bold">{profile?.members}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </div>

            {/* Recent Activity & Notifications */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center">
                    <Bell className="h-5 w-5 mr-2" />
                    Recent Notifications
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  {notifications.slice(0, 3).map((notification) => (
                    <div key={notification.id} className={`p-3 rounded-lg border ${notification.read ? 'bg-gray-50' : 'bg-blue-50 border-blue-200'}`}>
                      <div className="flex items-start justify-between">
                        <div>
                          <h4 className="font-medium text-sm">{notification.title}</h4>
                          <p className="text-sm text-gray-600 mt-1">{notification.message}</p>
                        </div>
                        {!notification.read && (
                          <div className="w-2 h-2 bg-blue-500 rounded-full mt-2"></div>
                        )}
                      </div>
                      <p className="text-xs text-gray-400 mt-2">
                        {notification.timestamp.toLocaleDateString()}
                      </p>
                    </div>
                  ))}
                  <Button variant="outline" className="w-full">
                    View All Notifications
                  </Button>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center">
                    <Target className="h-5 w-5 mr-2" />
                    Upcoming Milestones
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  {grants.flatMap(grant => grant.milestones)
                    .filter(milestone => milestone.status === "pending")
                    .slice(0, 3)
                    .map((milestone) => (
                    <div key={milestone.id} className="p-3 rounded-lg border bg-yellow-50 border-yellow-200">
                      <div className="flex items-center justify-between">
                        <div>
                          <h4 className="font-medium text-sm">{milestone.title}</h4>
                          <p className="text-sm text-gray-600 mt-1">{milestone.description}</p>
                        </div>
                        <Badge variant="secondary">
                          {milestone.percentage}%
                        </Badge>
                      </div>
                      <div className="flex items-center mt-2 text-xs text-gray-500">
                        <Calendar className="h-3 w-3 mr-1" />
                        Due: {milestone.dueDate.toLocaleDateString()}
                      </div>
                    </div>
                  ))}
                  <Button variant="outline" className="w-full">
                    View All Milestones
                  </Button>
                </CardContent>
              </Card>
            </div>

            {/* Progress Overview */}
            <Card>
              <CardHeader>
                <CardTitle>Grant Progress Overview</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {grants.map((grant) => {
                    const progress = (grant.milestones.filter(m => m.status === "completed").length / grant.milestones.length) * 100
                    return (
                      <div key={grant.id} className="space-y-2">
                        <div className="flex justify-between items-center">
                          <span className="font-medium">Grant #{grant.id}</span>
                          <span className="text-sm text-gray-600">{Math.round(progress)}% Complete</span>
                        </div>
                        <Progress value={progress} className="h-3" />
                        <div className="flex justify-between text-sm text-gray-600">
                          <span>Disbursed: ${grant.disbursedAmount.toLocaleString()}</span>
                          <span>Next: ${grant.nextDisbursement.toLocaleString()}</span>
                        </div>
                      </div>
                    )
                  })}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Grants Tab */}
          <TabsContent value="grants">
            <GrantDashboard userRole="dao" />
          </TabsContent>

          {/* Milestones Tab */}
          <TabsContent value="milestones">
            <MilestoneManager grants={grants} />
          </TabsContent>

          {/* Inventory Tab */}
          <TabsContent value="inventory">
            <InventoryTokenizer cooperativeId={profile?.id || ""} />
          </TabsContent>

          {/* Apply Tab */}
          <TabsContent value="apply">
            <GrantApplicationForm cooperativeProfile={profile} />
          </TabsContent>

          {/* Profile Tab */}
          <TabsContent value="profile">
            <Card>
              <CardHeader>
                <CardTitle>Cooperative Profile</CardTitle>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <h3 className="font-semibold mb-2">Basic Information</h3>
                    <div className="space-y-2 text-sm">
                      <div className="flex justify-between">
                        <span className="text-gray-600">Name:</span>
                        <span>{profile?.name}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-600">Location:</span>
                        <span>{profile?.location}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-600">Established:</span>
                        <span>{profile?.established}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-600">Members:</span>
                        <span>{profile?.members}</span>
                      </div>
                    </div>
                  </div>
                  
                  <div>
                    <h3 className="font-semibold mb-2">Farm Details</h3>
                    <div className="space-y-2 text-sm">
                      <div className="flex justify-between">
                        <span className="text-gray-600">Total Land:</span>
                        <span>{profile?.totalLandHectares} hectares</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-600">Annual Production:</span>
                        <span>{profile?.annualProduction} kg</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-600">Verification:</span>
                        <Badge variant={profile?.verificationStatus === "verified" ? "default" : "secondary"}>
                          {profile?.verificationStatus}
                        </Badge>
                      </div>
                    </div>
                  </div>
                </div>

                <div>
                  <h3 className="font-semibold mb-2">Certifications</h3>
                  <div className="flex flex-wrap gap-2">
                    {profile?.certifications.map((cert, index) => (
                      <Badge key={index} variant="outline" className="bg-green-50 text-green-700">
                        <Award className="h-3 w-3 mr-1" />
                        {cert}
                      </Badge>
                    ))}
                  </div>
                </div>

                <Button className="w-full bg-green-600 hover:bg-green-700">
                  <Settings className="mr-2 h-4 w-4" />
                  Edit Profile
                </Button>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </main>

      {/* Floating Home Button for Mobile */}
      <div className="fixed bottom-6 right-6 lg:hidden z-40">
        <Link href="/">
          <Button size="lg" className="rounded-full bg-green-600 hover:bg-green-700 shadow-lg">
            <ArrowLeft className="h-5 w-5" />
          </Button>
        </Link>
      </div>
    </div>
  )
}
