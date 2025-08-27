/**
 * Cooperative Portal - Main Dashboard
 * Aligned with database schema and smart contract integration
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
  Shield,
  MapPin,
  Users,
  Calendar,
  TrendingUp,
  Leaf,
  Award,
  ArrowLeft
} from "lucide-react"

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

// Placeholder components for missing imports
const GrantApplicationForm = ({ onSubmit }: { onSubmit: (data: any) => void }) => (
  <div className="p-4 border rounded-lg">
    <h3 className="font-semibold mb-2">Grant Application Form</h3>
    <p className="text-gray-600">Grant application functionality will be integrated with smart contracts.</p>
    <Button className="mt-4" onClick={() => onSubmit({})}>
      Submit Application
    </Button>
  </div>
)

const MilestoneManager = ({ grantId }: { grantId: number }) => (
  <div className="p-4 border rounded-lg">
    <h3 className="font-semibold mb-2">Milestone Manager</h3>
    <p className="text-gray-600">Milestone tracking aligned with disbursement_schedules table.</p>
  </div>
)

const InventoryTokenizer = ({ cooperativeId }: { cooperativeId: number }) => (
  <div className="p-4 border rounded-lg">
    <h3 className="font-semibold mb-2">Coffee Inventory Tokenizer</h3>
    <p className="text-gray-600">Integration with coffee_batches table and blockchain tokenization.</p>
  </div>
)

export default function CooperativePortal() {
  const [activeTab, setActiveTab] = useState("dashboard")
  const [profile, setProfile] = useState<CooperativeProfile | null>(null)
  const [grants, setGrants] = useState<Grant[]>([])
  const [milestones, setMilestones] = useState<Milestone[]>([])
  const [notifications, setNotifications] = useState<any[]>([])
  const [loading, setLoading] = useState(true)

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
    }
  ]

  const mockMilestones: Milestone[] = [
    {
      milestone_id: 1,
      schedule_id: 1,
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
      type: "milestone_completed",
      title: "Milestone Completed", 
      message: "Equipment Purchase milestone has been validated and funds disbursed.",
      timestamp: new Date("2025-01-22"),
      read: false
    },
    {
      id: 2,
      type: "funds_disbursed",
      title: "Funds Disbursed", 
      message: "$15,000 USDC has been transferred to your cooperative wallet.",
      timestamp: new Date("2025-01-20"),
      read: false
    }
  ]

  useEffect(() => {
    // Simulate API call
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
      <div className="container mx-auto px-4 py-8">
        <div className="mb-8">
          <div className="flex items-center mb-6">
            <Link href="/portal" className="mr-4">
              <Button variant="ghost" size="sm">
                <ArrowLeft className="w-4 h-4 mr-2" />
                Back to Portals
              </Button>
            </Link>
            <div>
              <h1 className="text-4xl font-bold text-gray-900 mb-2">Cooperative Portal</h1>
              <p className="text-gray-600">Manage grants, milestones, and coffee inventory</p>
            </div>
          </div>

          {/* Quick Stats */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
            <Card>
              <CardContent className="p-6">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-gray-600">Total Funding</p>
                    <p className="text-2xl font-bold text-green-600">${totalFunding.toLocaleString()}</p>
                  </div>
                  <DollarSign className="w-8 h-8 text-green-500" />
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="p-6">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-gray-600">Disbursed</p>
                    <p className="text-2xl font-bold text-blue-600">${disbursedFunding.toLocaleString()}</p>
                  </div>
                  <CheckCircle className="w-8 h-8 text-blue-500" />
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="p-6">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-gray-600">Milestones</p>
                    <p className="text-2xl font-bold text-purple-600">{completedMilestones}/{totalMilestones}</p>
                  </div>
                  <FileText className="w-8 h-8 text-purple-500" />
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="p-6">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-gray-600">Farmers</p>
                    <p className="text-2xl font-bold text-orange-600">{profile?.farmers_count}</p>
                  </div>
                  <Users className="w-8 h-8 text-orange-500" />
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Profile Summary */}
          {profile && (
            <Card className="mb-8">
              <CardContent className="p-6">
                <div className="flex items-start justify-between">
                  <div className="flex items-center space-x-4">
                    <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center">
                      <Coffee className="w-8 h-8 text-green-600" />
                    </div>
                    <div>
                      <h2 className="text-2xl font-bold text-gray-900">{profile.name}</h2>
                      <div className="flex items-center space-x-4 text-gray-600 mt-2">
                        <span className="flex items-center">
                          <MapPin className="w-4 h-4 mr-1" />
                          {profile.location}
                        </span>
                        <span className="flex items-center">
                          <Users className="w-4 h-4 mr-1" />
                          {profile.farmers_count} farmers
                        </span>
                        <span className="flex items-center">
                          <Calendar className="w-4 h-4 mr-1" />
                          Est. {profile.established_year}
                        </span>
                      </div>
                    </div>
                  </div>
                  <Badge
                    variant={profile.is_verified ? "default" : "secondary"}
                    className={profile.is_verified ? "bg-green-100 text-green-800" : ""}
                  >
                    <Shield className="w-4 h-4 mr-1" />
                    {profile.is_verified ? "Verified" : "Pending"}
                  </Badge>
                </div>
              </CardContent>
            </Card>
          )}
        </div>

        <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-6">
          <TabsList className="grid w-full grid-cols-5">
            <TabsTrigger value="dashboard">Dashboard</TabsTrigger>
            <TabsTrigger value="grants">Grants</TabsTrigger>
            <TabsTrigger value="milestones">Milestones</TabsTrigger>
            <TabsTrigger value="inventory">Inventory</TabsTrigger>
            <TabsTrigger value="profile">Profile</TabsTrigger>
          </TabsList>

          <TabsContent value="dashboard" className="space-y-6">
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
              {/* Active Grants */}
              <Card className="lg:col-span-2">
                <CardHeader>
                  <CardTitle>Active Grants</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    {grants.map((grant) => {
                      // Calculate progress based on milestones for this grant
                      const grantMilestones = milestones.filter(m => m.schedule_id === grant.grant_id)
                      const completedForGrant = grantMilestones.filter(m => m.is_completed).length
                      const progress = grantMilestones.length > 0 ? (completedForGrant / grantMilestones.length) * 100 : 0
                      
                      return (
                        <div key={grant.grant_id} className="space-y-2">
                          <div className="flex justify-between items-center">
                            <span className="font-medium">Grant #{grant.grant_id}</span>
                            <Badge variant={grant.status === "ACTIVE" ? "default" : "secondary"}>
                              {grant.status}
                            </Badge>
                          </div>
                          <Progress value={progress} className="w-full" />
                          <div className="flex justify-between text-sm text-gray-600">
                            <span>Total: ${grant.grant_amount_usd.toLocaleString()}</span>
                            <span>Progress: {Math.round(progress)}%</span>
                          </div>
                        </div>
                      )
                    })}
                  </div>
                </CardContent>
              </Card>

              {/* Recent Notifications */}
              <Card>
                <CardHeader>
                  <CardTitle>Notifications</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    {notifications.slice(0, 3).map((notification) => (
                      <div key={notification.id} className="p-3 border rounded-lg">
                        <h4 className="font-medium text-sm">{notification.title}</h4>
                        <p className="text-xs text-gray-600 mt-1">{notification.message}</p>
                        <p className="text-xs text-gray-400 mt-2">
                          {notification.timestamp.toLocaleDateString()}
                        </p>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            </div>
          </TabsContent>

          <TabsContent value="grants" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>Grant Management</CardTitle>
              </CardHeader>
              <CardContent>
                <GrantApplicationForm onSubmit={(data) => console.log("Grant application:", data)} />
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="milestones" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>Milestone Tracking</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {milestones.map((milestone) => (
                    <div key={milestone.milestone_id} className="border rounded-lg p-4">
                      <div className="flex justify-between items-start mb-2">
                        <h3 className="font-medium">{milestone.description}</h3>
                        <Badge variant={milestone.is_completed ? "default" : "secondary"}>
                          {milestone.is_completed ? "Completed" : "Pending"}
                        </Badge>
                      </div>
                      <p className="text-sm text-gray-600 mb-2">
                        Share: {(milestone.percentage_share / 100).toFixed(2)}%
                      </p>
                      {milestone.is_completed && (
                        <div className="text-sm text-green-600">
                          Disbursed: ${milestone.disbursed_amount.toLocaleString()}
                          {milestone.completed_timestamp && (
                            <span className="ml-2">
                              on {milestone.completed_timestamp.toLocaleDateString()}
                            </span>
                          )}
                        </div>
                      )}
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="inventory" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>Coffee Inventory & Tokenization</CardTitle>
              </CardHeader>
              <CardContent>
                <InventoryTokenizer cooperativeId={profile?.cooperative_id || 0} />
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="profile" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>Cooperative Profile</CardTitle>
              </CardHeader>
              <CardContent>
                {profile && (
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                      <h3 className="font-semibold mb-3">Basic Information</h3>
                      <div className="space-y-2 text-sm">
                        <div className="flex justify-between">
                          <span className="text-gray-600">Name:</span>
                          <span>{profile.name}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-gray-600">Location:</span>
                          <span>{profile.location}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-gray-600">Country:</span>
                          <span>{profile.country}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-gray-600">Established:</span>
                          <span>{profile.established_year}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-gray-600">Farmers:</span>
                          <span>{profile.farmers_count}</span>
                        </div>
                      </div>
                    </div>
                    <div>
                      <h3 className="font-semibold mb-3">Certifications</h3>
                      <div className="flex flex-wrap gap-2">
                        {profile.certifications.map((cert, index) => (
                          <Badge key={index} variant="outline">
                            <Award className="w-3 h-3 mr-1" />
                            {cert}
                          </Badge>
                        ))}
                      </div>
                    </div>
                  </div>
                )}
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  )
}
