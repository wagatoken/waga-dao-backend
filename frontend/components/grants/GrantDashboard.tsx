/**
 * Grant Dashboard Component - Centralized Reporting Hub
 * System-wide analytics and metrics for all key project parameters
 */

"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Progress } from "@/components/ui/progress"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import {
  Coffee,
  DollarSign,
  Clock,
  CheckCircle,
  AlertCircle,
  Upload,
  FileText,
  Calendar,
  MapPin,
  Coins,
  Users,
  TrendingUp,
  Globe,
  Leaf,
  Award,
  BarChart3,
  PieChart,
  Activity,
  Target
} from "lucide-react"

interface SystemMetrics {
  treasury: {
    totalValue: number
    goldBacked: number
    available: number
    allocated: number
  }
  grants: {
    totalIssued: number
    totalValue: number
    active: number
    completed: number
    pendingApplications: number
    averageAmount: number
  }
  cooperatives: {
    total: number
    verified: number
    pending: number
    totalMembers: number
    totalHectares: number
    averageMembers: number
  }
  impact: {
    carbonSequestered: number
    biodiversityIndex: number
    soilHealthImprovement: number
    womenParticipation: number
    youthEngagement: number
  }
  production: {
    totalCoffeeTokenized: number
    greenBeansTokens: number
    roastedBeansTokens: number
    averageQualityScore: number
    premiumMarketAccess: number
  }
  network: {
    totalTransactions: number
    activeWallets: number
    averageGasUsed: number
    networkUptime: number
  }
}

interface GrantDashboardProps {
  userRole?: "admin" | "dao" | "public"
}

export default function GrantDashboard({ userRole = "public" }: GrantDashboardProps) {
  const [metrics, setMetrics] = useState<SystemMetrics | null>(null)
  const [loading, setLoading] = useState(true)
  const [selectedTimeframe, setSelectedTimeframe] = useState<"24h" | "7d" | "30d" | "1y">("30d")

  // Mock data for demonstration - REPLACE WITH ACTUAL DATABASE QUERIES:
  // - Query grant_disbursement_status view for grant metrics
  // - Query batch_full_info view for coffee production data  
  // - Query milestone_progress view for milestone tracking
  // - Query evidence_validation_summary view for validation status
  // - Query commodity_prices table for market data
  // - Query cooperatives table for cooperative metrics
  // API calls should go to: env.API_BASE_URL endpoints
  useEffect(() => {
    const mockMetrics: SystemMetrics = {
      treasury: {
        totalValue: 30000000, // $30M target
        goldBacked: 28500000, // 95% gold backing
        available: 22000000, // Available for grants
        allocated: 6500000   // Already allocated
      },
      grants: {
        totalIssued: 156,
        totalValue: 6500000,
        active: 89,
        completed: 45,
        pendingApplications: 22,
        averageAmount: 41667
      },
      cooperatives: {
        total: 247,
        verified: 198,
        pending: 49,
        totalMembers: 12450,
        totalHectares: 8900,
        averageMembers: 50
      },
      impact: {
        carbonSequestered: 15600, // tons CO2
        biodiversityIndex: 78.5,  // % improvement
        soilHealthImprovement: 65.2, // % improvement
        womenParticipation: 67.8, // % of participants
        youthEngagement: 34.5     // % under 35
      },
      production: {
        totalCoffeeTokenized: 450000, // kg
        greenBeansTokens: 1250000,   // ERC-1155 tokens
        roastedBeansTokens: 425000,  // ERC-1155 tokens
        averageQualityScore: 8.4,    // out of 10
        premiumMarketAccess: 82.3    // % accessing premium markets
      },
      network: {
        totalTransactions: 28450,
        activeWallets: 2890,
        averageGasUsed: 125000,
        networkUptime: 99.8
      }
    }

    setTimeout(() => {
      setMetrics(mockMetrics)
      setLoading(false)
    }, 1000)
  }, [selectedTimeframe])

  if (loading) {
    return (
      <div className="flex items-center justify-center p-8">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-green-500"></div>
      </div>
    )
  }

  if (!metrics) return null

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-white">System Dashboard</h1>
          <p className="text-white/70 mt-2">
            Centralized reporting hub for all WAGA DAO key performance indicators
          </p>
        </div>
        
        <div className="flex items-center space-x-4">
          <select 
            value={selectedTimeframe}
            onChange={(e) => setSelectedTimeframe(e.target.value as any)}
            className="border border-gray-300 rounded-lg px-3 py-2 text-sm"
          >
            <option value="24h">Last 24 Hours</option>
            <option value="7d">Last 7 Days</option>
            <option value="30d">Last 30 Days</option>
            <option value="1y">Last Year</option>
          </select>
          
          {userRole === "admin" && (
            <Button className="bg-blue-600 hover:bg-blue-700">
              <BarChart3 className="mr-2 h-4 w-4" />
              Export Report
            </Button>
          )}
        </div>
      </div>

      {/* Key Performance Indicators */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Treasury Value</CardTitle>
            <DollarSign className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">${(metrics.treasury.totalValue / 1000000).toFixed(1)}M</div>
            <p className="text-xs text-muted-foreground">
              {((metrics.treasury.goldBacked / metrics.treasury.totalValue) * 100).toFixed(1)}% gold-backed
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Active Grants</CardTitle>
            <Coffee className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{metrics.grants.active}</div>
            <p className="text-xs text-muted-foreground">
              ${(metrics.grants.totalValue / 1000000).toFixed(1)}M total value
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Cooperatives</CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{metrics.cooperatives.verified}</div>
            <p className="text-xs text-muted-foreground">
              {metrics.cooperatives.totalMembers.toLocaleString()} total members
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Carbon Impact</CardTitle>
            <Leaf className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{(metrics.impact.carbonSequestered / 1000).toFixed(1)}k</div>
            <p className="text-xs text-muted-foreground">
              tons CO₂ sequestered
            </p>
          </CardContent>
        </Card>
      </div>
      {/* Detailed Analytics Tabs */}
      <Tabs defaultValue="treasury" className="space-y-4">
        <TabsList className="grid w-full grid-cols-6">
          <TabsTrigger value="treasury">Treasury</TabsTrigger>
          <TabsTrigger value="grants">Grants</TabsTrigger>
          <TabsTrigger value="cooperatives">Cooperatives</TabsTrigger>
          <TabsTrigger value="impact">Impact</TabsTrigger>
          <TabsTrigger value="production">Production</TabsTrigger>
          <TabsTrigger value="network">Network</TabsTrigger>
        </TabsList>

        <TabsContent value="treasury" className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center">
                  <Coins className="mr-2 h-5 w-5" />
                  Treasury Allocation
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span>Available for Grants</span>
                    <span>${(metrics.treasury.available / 1000000).toFixed(1)}M</span>
                  </div>
                  <Progress 
                    value={(metrics.treasury.available / metrics.treasury.totalValue) * 100} 
                    className="h-2"
                  />
                </div>
                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span>Currently Allocated</span>
                    <span>${(metrics.treasury.allocated / 1000000).toFixed(1)}M</span>
                  </div>
                  <Progress 
                    value={(metrics.treasury.allocated / metrics.treasury.totalValue) * 100} 
                    className="h-2"
                  />
                </div>
                <div className="pt-2 border-t">
                  <div className="flex justify-between font-semibold">
                    <span>Gold Backing Ratio</span>
                    <span>{((metrics.treasury.goldBacked / metrics.treasury.totalValue) * 100).toFixed(1)}%</span>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="flex items-center">
                  <TrendingUp className="mr-2 h-5 w-5" />
                  Treasury Performance
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="flex items-center justify-between">
                    <span className="text-sm">30-Day Growth</span>
                    <Badge className="bg-green-100 text-green-800">+2.3%</Badge>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-sm">APY Target</span>
                    <span className="font-semibold">8.5%</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-sm">Risk Rating</span>
                    <Badge className="bg-blue-100 text-blue-800">Conservative</Badge>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="grants" className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <Card>
              <CardHeader>
                <CardTitle className="text-lg text-white">Grant Pipeline</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="flex justify-between">
                  <span className="text-sm text-white/60">Pending Applications</span>
                  <span className="font-semibold">{metrics.grants.pendingApplications}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-white/60">Active Grants</span>
                  <span className="font-semibold">{metrics.grants.active}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-white/60">Completed</span>
                  <span className="font-semibold">{metrics.grants.completed}</span>
                </div>
                <div className="flex justify-between pt-2 border-t">
                  <span className="text-sm text-white/60">Success Rate</span>
                  <span className="font-semibold">
                    {((metrics.grants.completed / metrics.grants.totalIssued) * 100).toFixed(1)}%
                  </span>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-lg text-white">Financial Overview</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="flex justify-between">
                  <span className="text-sm text-white/60">Total Disbursed</span>
                  <span className="font-semibold">${(metrics.grants.totalValue / 1000000).toFixed(1)}M</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-white/60">Average Grant Size</span>
                  <span className="font-semibold">${metrics.grants.averageAmount.toLocaleString()}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-white/60">Default Rate</span>
                  <span className="font-semibold text-green-600">0.8%</span>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-lg text-white">Performance Metrics</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="flex justify-between">
                  <span className="text-sm text-white/60">Avg. Approval Time</span>
                  <span className="font-semibold">12 days</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-white/60">Milestone Completion</span>
                  <span className="font-semibold">94.2%</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-white/60">On-Time Delivery</span>
                  <span className="font-semibold">87.5%</span>
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="cooperatives" className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center">
                  <Users className="mr-2 h-5 w-5" />
                  Cooperative Network
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div className="text-center">
                    <div className="text-2xl font-bold text-green-600">{metrics.cooperatives.verified}</div>
                    <div className="text-sm text-white/60">Verified</div>
                  </div>
                  <div className="text-center">
                    <div className="text-2xl font-bold text-amber-600">{metrics.cooperatives.pending}</div>
                    <div className="text-sm text-white/60">Pending</div>
                  </div>
                </div>
                <div className="pt-4 space-y-2">
                  <div className="flex justify-between">
                    <span className="text-sm">Total Members</span>
                    <span className="font-semibold">{metrics.cooperatives.totalMembers.toLocaleString()}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-sm">Total Hectares</span>
                    <span className="font-semibold">{metrics.cooperatives.totalHectares.toLocaleString()}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-sm">Avg. Members per Coop</span>
                    <span className="font-semibold">{metrics.cooperatives.averageMembers}</span>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="flex items-center">
                  <Globe className="mr-2 h-5 w-5" />
                  Geographic Distribution
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  <div className="flex justify-between items-center">
                    <span className="text-sm">Cameroon</span>
                    <div className="flex items-center space-x-2">
                      <Progress value={45} className="w-20 h-2" />
                      <span className="text-sm font-semibold">45%</span>
                    </div>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm">Kenya</span>
                    <div className="flex items-center space-x-2">
                      <Progress value={32} className="w-20 h-2" />
                      <span className="text-sm font-semibold">32%</span>
                    </div>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm">Ethiopia</span>
                    <div className="flex items-center space-x-2">
                      <Progress value={23} className="w-20 h-2" />
                      <span className="text-sm font-semibold">23%</span>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="impact" className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center text-green-600">
                  <Leaf className="mr-2 h-5 w-5" />
                  Environmental
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="text-center">
                  <div className="text-xl font-bold">{(metrics.impact.carbonSequestered / 1000).toFixed(1)}k</div>
                  <div className="text-sm text-white/60">tons CO₂ sequestered</div>
                </div>
                <div className="text-center">
                  <div className="text-xl font-bold">{metrics.impact.biodiversityIndex}%</div>
                  <div className="text-sm text-white/60">biodiversity improvement</div>
                </div>
                <div className="text-center">
                  <div className="text-xl font-bold">{metrics.impact.soilHealthImprovement}%</div>
                  <div className="text-sm text-white/60">soil health improvement</div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="flex items-center text-purple-600">
                  <Users className="mr-2 h-5 w-5" />
                  Social
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="text-center">
                  <div className="text-xl font-bold">{metrics.impact.womenParticipation}%</div>
                  <div className="text-sm text-white/60">women participation</div>
                </div>
                <div className="text-center">
                  <div className="text-xl font-bold">{metrics.impact.youthEngagement}%</div>
                  <div className="text-sm text-white/60">youth engagement</div>
                </div>
                <div className="text-center">
                  <div className="text-xl font-bold">$2.4k</div>
                  <div className="text-sm text-white/60">avg. income increase</div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="flex items-center text-amber-600">
                  <Award className="mr-2 h-5 w-5" />
                  Quality
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="text-center">
                  <div className="text-xl font-bold">{metrics.production.averageQualityScore}/10</div>
                  <div className="text-sm text-white/60">average quality score</div>
                </div>
                <div className="text-center">
                  <div className="text-xl font-bold">{metrics.production.premiumMarketAccess}%</div>
                  <div className="text-sm text-white/60">premium market access</div>
                </div>
                <div className="text-center">
                  <div className="text-xl font-bold">15</div>
                  <div className="text-sm text-white/60">certifications earned</div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="flex items-center text-blue-600">
                  <Target className="mr-2 h-5 w-5" />
                  SDG Progress
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span>No Poverty</span>
                    <span>78%</span>
                  </div>
                  <Progress value={78} className="h-1" />
                </div>
                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span>Climate Action</span>
                    <span>85%</span>
                  </div>
                  <Progress value={85} className="h-1" />
                </div>
                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span>Life on Land</span>
                    <span>72%</span>
                  </div>
                  <Progress value={72} className="h-1" />
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="production" className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center">
                  <Coffee className="mr-2 h-5 w-5" />
                  Coffee Production
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div className="text-center">
                    <div className="text-2xl font-bold text-green-600">
                      {(metrics.production.totalCoffeeTokenized / 1000).toFixed(0)}k
                    </div>
                    <div className="text-sm text-white/60">kg tokenized</div>
                  </div>
                  <div className="text-center">
                    <div className="text-2xl font-bold text-amber-600">
                      {metrics.production.averageQualityScore}
                    </div>
                    <div className="text-sm text-white/60">avg. quality</div>
                  </div>
                </div>
                <div className="space-y-2">
                  <div className="flex justify-between">
                    <span className="text-sm">Green Beans Tokens</span>
                    <span className="font-semibold">{(metrics.production.greenBeansTokens / 1000).toFixed(0)}k</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-sm">Roasted Beans Tokens</span>
                    <span className="font-semibold">{(metrics.production.roastedBeansTokens / 1000).toFixed(0)}k</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-sm">Premium Market Access</span>
                    <span className="font-semibold">{metrics.production.premiumMarketAccess}%</span>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="flex items-center">
                  <BarChart3 className="mr-2 h-5 w-5" />
                  Market Performance
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-3">
                  <div className="flex justify-between">
                    <span className="text-sm">Average Price Premium</span>
                    <span className="font-semibold text-green-600">+23%</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-sm">Direct Trade Volume</span>
                    <span className="font-semibold">67%</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-sm">Export Revenue</span>
                    <span className="font-semibold">$2.1M</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-sm">Fair Trade Certified</span>
                    <span className="font-semibold">89%</span>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="network" className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <Card>
              <CardHeader>
                <CardTitle className="text-lg text-white">Network Activity</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="text-center">
                  <div className="text-xl font-bold">{(metrics.network.totalTransactions / 1000).toFixed(1)}k</div>
                  <div className="text-sm text-white/60">total transactions</div>
                </div>
                <div className="text-center">
                  <div className="text-xl font-bold">{(metrics.network.activeWallets / 1000).toFixed(1)}k</div>
                  <div className="text-sm text-white/60">active wallets</div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-lg text-white">Performance</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="text-center">
                  <div className="text-xl font-bold">{metrics.network.networkUptime}%</div>
                  <div className="text-sm text-white/60">uptime</div>
                </div>
                <div className="text-center">
                  <div className="text-xl font-bold">{(metrics.network.averageGasUsed / 1000).toFixed(0)}k</div>
                  <div className="text-sm text-white/60">avg. gas used</div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-lg text-white">Security</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="text-center">
                  <div className="text-xl font-bold text-green-600">0</div>
                  <div className="text-sm text-white/60">security incidents</div>
                </div>
                <div className="text-center">
                  <div className="text-xl font-bold">$0</div>
                  <div className="text-sm text-white/60">funds at risk</div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-lg text-white">Governance</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="text-center">
                  <div className="text-xl font-bold">12</div>
                  <div className="text-sm text-white/60">active proposals</div>
                </div>
                <div className="text-center">
                  <div className="text-xl font-bold">67%</div>
                  <div className="text-sm text-white/60">voter participation</div>
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>
      </Tabs>
    </div>
  )
}
