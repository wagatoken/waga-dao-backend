/**
 * WAGA DAO Governance Portal
 * Comprehensive DAO governance interface for proposals, voting, and treasury management
 * Based on WAGAGovernor smart contract and VERT token governance system
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
  Users,
  ArrowLeft,
  Vote,
  Coins,
  FileText,
  TrendingUp,
  Clock,
  CheckCircle,
  XCircle,
  Eye,
  Plus,
  Calendar,
  Target,
  DollarSign,
  AlertCircle,
  Menu,
  ThumbsUp,
  ThumbsDown,
  Minus
} from "lucide-react"

// Types based on WAGAGovernor smart contract
interface Proposal {
  proposalId: string
  title: string
  description: string
  proposer: string
  startBlock: number
  endBlock: number
  forVotes: number
  againstVotes: number
  abstainVotes: number
  status: 'Active' | 'Succeeded' | 'Defeated' | 'Queued' | 'Executed' | 'Canceled'
  quorumReached: boolean
  createdAt: string
  executionTime?: string
  category: 'Treasury' | 'Protocol' | 'Grants' | 'Governance'
}

interface VoterStats {
  totalVERT: number
  votingPower: number
  proposalsVoted: number
  delegatedTo?: string
  delegates: string[]
}

interface TreasuryInfo {
  totalValue: number
  usdcBalance: number
  vertTokens: number
  coffeeTokens: number
  monthlyBurn: number
  projectedRunway: number
}

interface GovernanceStats {
  totalProposals: number
  activeProposals: number
  avgParticipation: number
  quorumThreshold: number
  proposalThreshold: number
  votingDelay: number
  votingPeriod: number
}

export default function DAOPortal() {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false)
  const [searchTerm, setSearchTerm] = useState("")
  const [selectedTab, setSelectedTab] = useState("overview")
  const [selectedFilter, setSelectedFilter] = useState("all")
  
  // Mock data - In production, this would come from blockchain and API calls
  const [proposals, setProposals] = useState<Proposal[]>([
    {
      proposalId: "1",
      title: "Increase Grant Allocation for Sustainable Coffee Farming",
      description: "Proposal to allocate additional 500,000 USDC from treasury for expanding sustainable coffee farming grants to underserved cooperatives in Central America.",
      proposer: "0x742d35Cc6d7...",
      startBlock: 245000000,
      endBlock: 245050400, // 7 days later
      forVotes: 850000,
      againstVotes: 120000,
      abstainVotes: 30000,
      status: 'Active',
      quorumReached: true,
      createdAt: "2024-08-20T10:00:00Z",
      category: 'Treasury'
    },
    {
      proposalId: "2", 
      title: "Implement New Milestone Validation Framework",
      description: "Proposal to update the milestone validation process with enhanced evidence requirements and automated verification for improved grant accountability.",
      proposer: "0x892e46Dd8e9...",
      startBlock: 244950000,
      endBlock: 245000400,
      forVotes: 1200000,
      againstVotes: 80000,
      abstainVotes: 20000,
      status: 'Succeeded',
      quorumReached: true,
      createdAt: "2024-08-15T14:30:00Z",
      executionTime: "2024-08-23T10:00:00Z",
      category: 'Protocol'
    },
    {
      proposalId: "3",
      title: "Partnership with Fair Trade Certification Body",
      description: "Establish formal partnership with Fair Trade USA to streamline certification process for WAGA-supported cooperatives.",
      proposer: "0x123abc456d...",
      startBlock: 244900000,
      endBlock: 244950400,
      forVotes: 450000,
      againstVotes: 650000,
      abstainVotes: 100000,
      status: 'Defeated',
      quorumReached: true,
      createdAt: "2024-08-10T09:15:00Z",
      category: 'Grants'
    }
  ])

  const [voterStats] = useState<VoterStats>({
    totalVERT: 250000,
    votingPower: 250000, // 1:1 if not delegated
    proposalsVoted: 15,
    delegatedTo: undefined,
    delegates: []
  })

  const [treasuryInfo] = useState<TreasuryInfo>({
    totalValue: 8500000,
    usdcBalance: 6800000,
    vertTokens: 1200000,
    coffeeTokens: 500000,
    monthlyBurn: 180000,
    projectedRunway: 47 // months
  })

  const [governanceStats] = useState<GovernanceStats>({
    totalProposals: 25,
    activeProposals: 3,
    avgParticipation: 78.5,
    quorumThreshold: 4, // 4% of total supply
    proposalThreshold: 100000, // 100K VERT tokens
    votingDelay: 1, // 1 day
    votingPeriod: 7 // 7 days
  })

  const navigationItems = [
    { name: "Home", href: "/" },
    { name: "How It Works", href: "/how-it-works" },
    { name: "Dashboard", href: "/grants" },
    { name: "Treasury", href: "/treasury" },
    { name: "About", href: "/about" }
  ]

  const handleVote = (proposalId: string, support: 'for' | 'against' | 'abstain') => {
    // In production, this would call the governor smart contract
    setProposals(prev => prev.map(proposal => {
      if (proposal.proposalId === proposalId) {
        const votes = voterStats.votingPower
        return {
          ...proposal,
          forVotes: support === 'for' ? proposal.forVotes + votes : proposal.forVotes,
          againstVotes: support === 'against' ? proposal.againstVotes + votes : proposal.againstVotes,
          abstainVotes: support === 'abstain' ? proposal.abstainVotes + votes : proposal.abstainVotes
        }
      }
      return proposal
    }))
  }

  const getProposalStatusColor = (status: string) => {
    switch (status) {
      case 'Active': return 'bg-blue-100 text-blue-800'
      case 'Succeeded': return 'bg-green-100 text-green-800'
      case 'Defeated': return 'bg-red-100 text-red-800'
      case 'Queued': return 'bg-yellow-100 text-yellow-800'
      case 'Executed': return 'bg-purple-100 text-purple-800'
      case 'Canceled': return 'bg-gray-100 text-gray-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const getTimeRemaining = (endBlock: number) => {
    // Simplified calculation - 12 second blocks
    const currentBlock = 245010000 // Mock current block
    const blocksRemaining = Math.max(0, endBlock - currentBlock)
    const hoursRemaining = (blocksRemaining * 12) / 3600
    
    if (hoursRemaining < 24) {
      return `${Math.floor(hoursRemaining)}h remaining`
    } else {
      return `${Math.floor(hoursRemaining / 24)}d remaining`
    }
  }

  const filteredProposals = proposals.filter(proposal => {
    const matchesSearch = proposal.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         proposal.description.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesFilter = selectedFilter === 'all' || 
                         proposal.status.toLowerCase() === selectedFilter ||
                         proposal.category.toLowerCase() === selectedFilter
    return matchesSearch && matchesFilter
  })

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 to-violet-50">
      {/* Navigation */}
      <nav className="fixed top-0 w-full z-50 bg-white/90 backdrop-blur-xl border-b border-purple-200 shadow-sm">
        <div className="container mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            {/* Logo */}
            <Link href="/" className="flex items-center space-x-3 group">
              <div className="relative">
                <div className="w-10 h-10 bg-gradient-to-br from-purple-600 to-violet-600 rounded-2xl flex items-center justify-center transition-all duration-300 group-hover:scale-110">
                  <Users className="h-6 w-6 text-white" />
                </div>
                <div className="absolute inset-0 bg-gradient-to-br from-purple-600 to-violet-600 rounded-2xl blur-md opacity-50"></div>
              </div>
              <div>
                <span className="text-2xl font-bold text-gray-900">WAGA DAO</span>
                <div className="text-xs text-gray-500">Governance Portal</div>
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
                  <div className="absolute bottom-0 left-0 w-0 h-0.5 bg-gradient-to-r from-purple-500 to-violet-600 group-hover:w-full transition-all duration-300"></div>
                </Link>
              ))}
              <Badge className="bg-purple-500/10 text-purple-700 border-purple-200">
                <Vote className="mr-2 h-4 w-4" />
                DAO Member
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
                <Button variant="outline" size="sm" className="border-purple-200 text-gray-700 hover:bg-purple-50">
                  <ArrowLeft className="h-4 w-4 mr-2" />
                  Back to Portal
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
                  Back to Portal
                </Button>
              </Link>
            </div>
          </div>
        </div>
      )}

      {/* Header */}
      <div className="bg-gradient-to-r from-purple-800 to-violet-900 text-white pt-24 pb-16">
        <div className="container mx-auto px-6">
          <div className="text-center">
            <Badge className="mb-4 bg-purple-500/20 text-purple-100 border-purple-300/30">
              <Vote className="mr-2 h-4 w-4" />
              Decentralized Governance
            </Badge>
            <h1 className="text-4xl md:text-6xl font-bold mb-6">
              DAO Portal
            </h1>
            <p className="text-xl md:text-2xl text-purple-100 max-w-3xl mx-auto mb-8">
              Community governance, proposals, and treasury management for regenerative coffee
            </p>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="container mx-auto px-6 py-12">
        <Tabs value={selectedTab} onValueChange={setSelectedTab} className="space-y-8">
          <TabsList className="grid w-full grid-cols-5 lg:w-auto lg:grid-cols-5">
            <TabsTrigger value="overview">Overview</TabsTrigger>
            <TabsTrigger value="proposals">Proposals</TabsTrigger>
            <TabsTrigger value="voting">Voting</TabsTrigger>
            <TabsTrigger value="treasury">Treasury</TabsTrigger>
            <TabsTrigger value="delegation">Delegation</TabsTrigger>
          </TabsList>

          {/* Overview Tab */}
          <TabsContent value="overview" className="space-y-8">
            {/* Governance Stats */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              <Card className="bg-white/80 backdrop-blur-xl border-purple-200">
                <CardContent className="p-6 text-center">
                  <FileText className="w-12 h-12 text-purple-600 mx-auto mb-4" />
                  <div className="text-3xl font-bold text-gray-900">{governanceStats.totalProposals}</div>
                  <div className="text-sm text-gray-600">Total Proposals</div>
                </CardContent>
              </Card>

              <Card className="bg-white/80 backdrop-blur-xl border-purple-200">
                <CardContent className="p-6 text-center">
                  <Clock className="w-12 h-12 text-blue-600 mx-auto mb-4" />
                  <div className="text-3xl font-bold text-gray-900">{governanceStats.activeProposals}</div>
                  <div className="text-sm text-gray-600">Active Proposals</div>
                </CardContent>
              </Card>

              <Card className="bg-white/80 backdrop-blur-xl border-purple-200">
                <CardContent className="p-6 text-center">
                  <TrendingUp className="w-12 h-12 text-green-600 mx-auto mb-4" />
                  <div className="text-3xl font-bold text-gray-900">{governanceStats.avgParticipation}%</div>
                  <div className="text-sm text-gray-600">Avg Participation</div>
                </CardContent>
              </Card>

              <Card className="bg-white/80 backdrop-blur-xl border-purple-200">
                <CardContent className="p-6 text-center">
                  <Target className="w-12 h-12 text-orange-600 mx-auto mb-4" />
                  <div className="text-3xl font-bold text-gray-900">{governanceStats.quorumThreshold}%</div>
                  <div className="text-sm text-gray-600">Quorum Threshold</div>
                </CardContent>
              </Card>
            </div>

            {/* Your Voting Power */}
            <Card className="bg-white/80 backdrop-blur-xl border-purple-200">
              <CardHeader>
                <CardTitle>Your Voting Power</CardTitle>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                  <div className="text-center">
                    <div className="text-2xl font-bold text-purple-600">{voterStats.totalVERT.toLocaleString()}</div>
                    <div className="text-sm text-gray-600">VERT Tokens</div>
                  </div>
                  <div className="text-center">
                    <div className="text-2xl font-bold text-blue-600">{voterStats.votingPower.toLocaleString()}</div>
                    <div className="text-sm text-gray-600">Voting Power</div>
                  </div>
                  <div className="text-center">
                    <div className="text-2xl font-bold text-green-600">{voterStats.proposalsVoted}</div>
                    <div className="text-sm text-gray-600">Proposals Voted</div>
                  </div>
                </div>
                <div className="bg-purple-50 rounded-lg p-4">
                  <p className="text-sm text-gray-700">
                    <strong>Delegation Status:</strong> {voterStats.delegatedTo ? `Delegated to ${voterStats.delegatedTo}` : 'Self-voting'}
                  </p>
                </div>
              </CardContent>
            </Card>

            {/* Recent Activity */}
            <Card className="bg-white/80 backdrop-blur-xl border-purple-200">
              <CardHeader>
                <CardTitle>Recent Governance Activity</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="flex items-center space-x-4 p-4 bg-green-50 rounded-lg">
                    <CheckCircle className="w-6 h-6 text-green-600" />
                    <div>
                      <div className="font-medium">Proposal Executed</div>
                      <div className="text-sm text-gray-600">Milestone Validation Framework - Successfully implemented</div>
                    </div>
                    <div className="text-sm text-gray-500 ml-auto">2 days ago</div>
                  </div>
                  
                  <div className="flex items-center space-x-4 p-4 bg-blue-50 rounded-lg">
                    <Vote className="w-6 h-6 text-blue-600" />
                    <div>
                      <div className="font-medium">New Proposal</div>
                      <div className="text-sm text-gray-600">Increase Grant Allocation - Voting now active</div>
                    </div>
                    <div className="text-sm text-gray-500 ml-auto">1 week ago</div>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Proposals Tab */}
          <TabsContent value="proposals" className="space-y-6">
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
              <h2 className="text-2xl font-bold text-gray-900">All Proposals</h2>
              <div className="flex space-x-2">
                <Input
                  placeholder="Search proposals..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="w-64"
                />
                <select 
                  value={selectedFilter}
                  onChange={(e) => setSelectedFilter(e.target.value)}
                  className="px-3 py-2 border border-gray-300 rounded-md"
                >
                  <option value="all">All Status</option>
                  <option value="active">Active</option>
                  <option value="succeeded">Succeeded</option>
                  <option value="defeated">Defeated</option>
                  <option value="treasury">Treasury</option>
                  <option value="protocol">Protocol</option>
                  <option value="grants">Grants</option>
                </select>
                <Button>
                  <Plus className="w-4 h-4 mr-2" />
                  New Proposal
                </Button>
              </div>
            </div>

            <div className="space-y-6">
              {filteredProposals.map((proposal) => (
                <Card key={proposal.proposalId} className="bg-white/80 backdrop-blur-xl border-purple-200">
                  <CardHeader>
                    <div className="flex justify-between items-start">
                      <div className="space-y-2">
                        <div className="flex items-center space-x-3">
                          <h3 className="text-xl font-bold text-gray-900">{proposal.title}</h3>
                          <Badge className={getProposalStatusColor(proposal.status)}>
                            {proposal.status}
                          </Badge>
                          <Badge variant="outline">
                            {proposal.category}
                          </Badge>
                        </div>
                        <p className="text-gray-600">{proposal.description}</p>
                        <div className="flex items-center space-x-4 text-sm text-gray-500">
                          <span>Proposed by {proposal.proposer.slice(0, 10)}...</span>
                          <span>•</span>
                          <span>{new Date(proposal.createdAt).toLocaleDateString()}</span>
                          {proposal.status === 'Active' && (
                            <>
                              <span>•</span>
                              <span className="text-orange-600">{getTimeRemaining(proposal.endBlock)}</span>
                            </>
                          )}
                        </div>
                      </div>
                    </div>
                  </CardHeader>
                  
                  <CardContent className="space-y-4">
                    {/* Voting Progress */}
                    <div className="space-y-3">
                      <div className="flex justify-between items-center">
                        <span className="text-sm font-medium text-green-600">For: {proposal.forVotes.toLocaleString()} VERT</span>
                        <span className="text-sm text-gray-600">
                          {((proposal.forVotes / (proposal.forVotes + proposal.againstVotes + proposal.abstainVotes)) * 100).toFixed(1)}%
                        </span>
                      </div>
                      <Progress 
                        value={(proposal.forVotes / (proposal.forVotes + proposal.againstVotes + proposal.abstainVotes)) * 100} 
                        className="h-2"
                      />
                      
                      <div className="flex justify-between items-center">
                        <span className="text-sm font-medium text-red-600">Against: {proposal.againstVotes.toLocaleString()} VERT</span>
                        <span className="text-sm text-gray-600">
                          {((proposal.againstVotes / (proposal.forVotes + proposal.againstVotes + proposal.abstainVotes)) * 100).toFixed(1)}%
                        </span>
                      </div>
                      <Progress 
                        value={(proposal.againstVotes / (proposal.forVotes + proposal.againstVotes + proposal.abstainVotes)) * 100} 
                        className="h-2"
                      />
                      
                      <div className="flex justify-between items-center">
                        <span className="text-sm font-medium text-gray-600">Abstain: {proposal.abstainVotes.toLocaleString()} VERT</span>
                        <span className="text-sm text-gray-600">
                          {((proposal.abstainVotes / (proposal.forVotes + proposal.againstVotes + proposal.abstainVotes)) * 100).toFixed(1)}%
                        </span>
                      </div>
                    </div>

                    {/* Action Buttons */}
                    <div className="flex justify-between items-center pt-4 border-t">
                      <div className="flex items-center space-x-2">
                        {proposal.quorumReached && (
                          <Badge className="bg-green-100 text-green-800">
                            <CheckCircle className="w-3 h-3 mr-1" />
                            Quorum Reached
                          </Badge>
                        )}
                        {!proposal.quorumReached && proposal.status === 'Active' && (
                          <Badge className="bg-orange-100 text-orange-800">
                            <AlertCircle className="w-3 h-3 mr-1" />
                            Needs Quorum
                          </Badge>
                        )}
                      </div>
                      
                      <div className="flex space-x-2">
                        <Button variant="outline" size="sm">
                          <Eye className="w-4 h-4 mr-2" />
                          Details
                        </Button>
                        {proposal.status === 'Active' && (
                          <>
                            <Button 
                              size="sm"
                              onClick={() => handleVote(proposal.proposalId, 'for')}
                              className="bg-green-600 hover:bg-green-700"
                            >
                              <ThumbsUp className="w-4 h-4 mr-2" />
                              For
                            </Button>
                            <Button 
                              variant="outline"
                              size="sm"
                              onClick={() => handleVote(proposal.proposalId, 'against')}
                              className="border-red-200 text-red-600 hover:bg-red-50"
                            >
                              <ThumbsDown className="w-4 h-4 mr-2" />
                              Against
                            </Button>
                            <Button 
                              variant="outline"
                              size="sm"
                              onClick={() => handleVote(proposal.proposalId, 'abstain')}
                            >
                              <Minus className="w-4 h-4 mr-2" />
                              Abstain
                            </Button>
                          </>
                        )}
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          </TabsContent>

          {/* Voting Tab */}
          <TabsContent value="voting" className="space-y-6">
            <h2 className="text-2xl font-bold text-gray-900">Voting Power & History</h2>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              <Card className="bg-white/80 backdrop-blur-xl border-purple-200">
                <CardHeader>
                  <CardTitle>Your Voting Power</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="text-center">
                    <div className="text-4xl font-bold text-purple-600 mb-2">{voterStats.votingPower.toLocaleString()}</div>
                    <div className="text-gray-600">Total Voting Power</div>
                  </div>
                  <div className="space-y-2">
                    <div className="flex justify-between">
                      <span>VERT Balance:</span>
                      <span className="font-medium">{voterStats.totalVERT.toLocaleString()}</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Delegated Power:</span>
                      <span className="font-medium">0</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Proposals Voted:</span>
                      <span className="font-medium">{voterStats.proposalsVoted}</span>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card className="bg-white/80 backdrop-blur-xl border-purple-200">
                <CardHeader>
                  <CardTitle>Governance Parameters</CardTitle>
                </CardHeader>
                <CardContent className="space-y-3">
                  <div className="flex justify-between">
                    <span>Proposal Threshold:</span>
                    <span className="font-medium">{governanceStats.proposalThreshold.toLocaleString()} VERT</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Quorum Threshold:</span>
                    <span className="font-medium">{governanceStats.quorumThreshold}%</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Voting Delay:</span>
                    <span className="font-medium">{governanceStats.votingDelay} day</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Voting Period:</span>
                    <span className="font-medium">{governanceStats.votingPeriod} days</span>
                  </div>
                </CardContent>
              </Card>
            </div>
          </TabsContent>

          {/* Treasury Tab */}
          <TabsContent value="treasury" className="space-y-6">
            <h2 className="text-2xl font-bold text-gray-900">DAO Treasury</h2>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              <Card className="bg-white/80 backdrop-blur-xl border-purple-200">
                <CardContent className="p-6 text-center">
                  <DollarSign className="w-12 h-12 text-green-600 mx-auto mb-4" />
                  <div className="text-3xl font-bold text-gray-900">${treasuryInfo.totalValue.toLocaleString()}</div>
                  <div className="text-sm text-gray-600">Total Value</div>
                </CardContent>
              </Card>

              <Card className="bg-white/80 backdrop-blur-xl border-purple-200">
                <CardContent className="p-6 text-center">
                  <Coins className="w-12 h-12 text-blue-600 mx-auto mb-4" />
                  <div className="text-3xl font-bold text-gray-900">${treasuryInfo.usdcBalance.toLocaleString()}</div>
                  <div className="text-sm text-gray-600">USDC Balance</div>
                </CardContent>
              </Card>

              <Card className="bg-white/80 backdrop-blur-xl border-purple-200">
                <CardContent className="p-6 text-center">
                  <TrendingUp className="w-12 h-12 text-purple-600 mx-auto mb-4" />
                  <div className="text-3xl font-bold text-gray-900">{treasuryInfo.vertTokens.toLocaleString()}</div>
                  <div className="text-sm text-gray-600">VERT Tokens</div>
                </CardContent>
              </Card>

              <Card className="bg-white/80 backdrop-blur-xl border-purple-200">
                <CardContent className="p-6 text-center">
                  <Calendar className="w-12 h-12 text-orange-600 mx-auto mb-4" />
                  <div className="text-3xl font-bold text-gray-900">{treasuryInfo.projectedRunway}</div>
                  <div className="text-sm text-gray-600">Months Runway</div>
                </CardContent>
              </Card>
            </div>

            <Card className="bg-white/80 backdrop-blur-xl border-purple-200">
              <CardHeader>
                <CardTitle>Treasury Breakdown</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="flex justify-between items-center p-4 bg-green-50 rounded-lg">
                    <div>
                      <div className="font-medium">USDC (Stablecoin)</div>
                      <div className="text-sm text-gray-600">Primary operational currency</div>
                    </div>
                    <div className="text-right">
                      <div className="font-bold">${treasuryInfo.usdcBalance.toLocaleString()}</div>
                      <div className="text-sm text-gray-600">
                        {((treasuryInfo.usdcBalance / treasuryInfo.totalValue) * 100).toFixed(1)}%
                      </div>
                    </div>
                  </div>

                  <div className="flex justify-between items-center p-4 bg-purple-50 rounded-lg">
                    <div>
                      <div className="font-medium">VERT Tokens</div>
                      <div className="text-sm text-gray-600">Governance tokens for voting</div>
                    </div>
                    <div className="text-right">
                      <div className="font-bold">{treasuryInfo.vertTokens.toLocaleString()}</div>
                      <div className="text-sm text-gray-600">
                        {((treasuryInfo.vertTokens / treasuryInfo.totalValue) * 100).toFixed(1)}%
                      </div>
                    </div>
                  </div>

                  <div className="flex justify-between items-center p-4 bg-amber-50 rounded-lg">
                    <div>
                      <div className="font-medium">Coffee Tokens</div>
                      <div className="text-sm text-gray-600">Tokenized coffee inventory</div>
                    </div>
                    <div className="text-right">
                      <div className="font-bold">{treasuryInfo.coffeeTokens.toLocaleString()}</div>
                      <div className="text-sm text-gray-600">
                        {((treasuryInfo.coffeeTokens / treasuryInfo.totalValue) * 100).toFixed(1)}%
                      </div>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Delegation Tab */}
          <TabsContent value="delegation" className="space-y-6">
            <h2 className="text-2xl font-bold text-gray-900">Vote Delegation</h2>

            <Card className="bg-white/80 backdrop-blur-xl border-purple-200">
              <CardHeader>
                <CardTitle>Delegation Status</CardTitle>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="bg-blue-50 rounded-lg p-6">
                  <h3 className="font-medium mb-2">Current Status</h3>
                  <p className="text-gray-600 mb-4">
                    {voterStats.delegatedTo 
                      ? `You have delegated your voting power to ${voterStats.delegatedTo}`
                      : 'You are currently voting with your own tokens'
                    }
                  </p>
                  <div className="flex space-x-3">
                    <Button variant="outline">
                      Delegate Votes
                    </Button>
                    {voterStats.delegatedTo && (
                      <Button variant="outline">
                        Revoke Delegation
                      </Button>
                    )}
                  </div>
                </div>

                <div>
                  <h3 className="font-medium mb-4">Delegate to Address</h3>
                  <div className="space-y-4">
                    <Input 
                      placeholder="Enter Ethereum address (0x...)" 
                      className="w-full"
                    />
                    <Button>Delegate Voting Power</Button>
                  </div>
                </div>

                {voterStats.delegates.length > 0 && (
                  <div>
                    <h3 className="font-medium mb-4">Your Delegates</h3>
                    <div className="space-y-2">
                      {voterStats.delegates.map((delegate, index) => (
                        <div key={index} className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
                          <span className="font-mono text-sm">{delegate}</span>
                          <Button variant="outline" size="sm">
                            Revoke
                          </Button>
                        </div>
                      ))}
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
