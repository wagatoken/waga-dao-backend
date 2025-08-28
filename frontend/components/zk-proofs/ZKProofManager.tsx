/**
 * WAGA DAO ZK Proof Manager Component
 * Comprehensive ZK proof management interface with smart contract integration
 */

'use client'

import { useState, useEffect } from 'react'
import { useZKProofs, useProofSubmission } from '@/hooks/useZKProofs'
import { 
  Card, 
  CardContent, 
  CardDescription, 
  CardHeader, 
  CardTitle 
} from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { Progress } from '@/components/ui/progress'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Label } from '@/components/ui/label'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { 
  Shield, 
  Upload, 
  CheckCircle, 
  XCircle, 
  Clock, 
  Search, 
  RefreshCw, 
  BarChart3, 
  FileText, 
  Zap,
  AlertTriangle,
  Info
} from 'lucide-react'
import { ProofSubmissionData, ProofMetadata } from '@/lib/services/ZKProofService'

export default function ZKProofManager() {
  const [activeTab, setActiveTab] = useState('overview')
  const [searchQuery, setSearchQuery] = useState('')
  const [selectedProofType, setSelectedProofType] = useState<'RISC_ZERO' | 'CIRCOM' | 'all'>('all')
  const [selectedStatus, setSelectedStatus] = useState<string>('all')

  // Custom hooks
  const { 
    proofs, 
    databaseProofs, 
    loading, 
    error, 
    stats, 
    submitProof, 
    verifyProof, 
    refreshProofs, 
    searchProofs, 
    clearError 
  } = useZKProofs()

  const { 
    submitting, 
    error: submissionError, 
    success: submissionSuccess, 
    submit, 
    clearMessages 
  } = useProofSubmission()

  // Form state for proof submission
  const [proofForm, setProofForm] = useState<ProofSubmissionData>({
    proofType: 'RISC_ZERO',
    proofData: '',
    publicInputs: '',
    publicInputsHash: '',
    metadata: {
      proof_name: '',
      description: '',
      version: '1.0.0',
      circuit_hash: '',
      max_gas_limit: 500000
    }
  })

  // Filter proofs based on search and filters
  const filteredProofs = databaseProofs.filter(proof => {
    const matchesSearch = searchQuery === '' || 
      proof.proof_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      proof.description.toLowerCase().includes(searchQuery.toLowerCase()) ||
      proof.circuit_hash.toLowerCase().includes(searchQuery.toLowerCase())
    
    const matchesType = selectedProofType === 'all' || proof.proof_type === selectedProofType
    const matchesStatus = selectedStatus === 'all' || proof.verification_status === selectedStatus
    
    return matchesSearch && matchesType && matchesStatus
  })

  // Handle form input changes
  const handleFormChange = (field: string, value: string | number) => {
    if (field.startsWith('metadata.')) {
      const metadataField = field.replace('metadata.', '') as keyof ProofMetadata
      setProofForm((prev: ProofSubmissionData) => ({
        ...prev,
        metadata: {
          ...prev.metadata,
          [metadataField]: value
        }
      }))
    } else {
      setProofForm((prev: ProofSubmissionData) => ({
        ...prev,
        [field]: value
      }))
    }
  }

  // Handle proof submission
  const handleSubmitProof = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    
    try {
      await submit(proofForm)
      
      // Reset form
      setProofForm({
        proofType: 'RISC_ZERO',
        proofData: '',
        publicInputs: '',
        publicInputsHash: '',
        metadata: {
          proof_name: '',
          description: '',
          version: '1.0.0',
          circuit_hash: '',
          max_gas_limit: 500000
        }
      })
      
      // Refresh data
      await refreshProofs()
    } catch (error) {
      // Error is handled by the hook
      console.error('Proof submission failed:', error)
    }
  }

  // Handle proof verification
  const handleVerifyProof = async (proofHash: string) => {
    try {
      await verifyProof(proofHash)
      await refreshProofs()
    } catch (error) {
      console.error('Proof verification failed:', error)
    }
  }

  // Handle search
  const handleSearch = async () => {
    if (searchQuery.trim()) {
      await searchProofs(searchQuery)
    }
  }

  // Clear all messages
  const handleClearMessages = () => {
    clearError()
    clearMessages()
  }

  // Format verification status
  const formatStatus = (status: string) => {
    const statusConfig = {
      'PENDING': { label: 'Pending', className: 'bg-yellow-100 text-yellow-800 border-yellow-200', icon: Clock },
      'VERIFIED': { label: 'Verified', className: 'bg-green-100 text-green-800 border-green-200', icon: CheckCircle },
      'REJECTED': { label: 'Rejected', className: 'bg-red-100 text-red-800 border-red-200', icon: XCircle },
      'EXPIRED': { label: 'Expired', className: 'bg-gray-100 text-gray-800 border-gray-200', icon: AlertTriangle }
    }
    
    const config = statusConfig[status as keyof typeof statusConfig] || statusConfig['PENDING']
    const Icon = config.icon
    
    return (
      <span className={`inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold ${config.className}`}>
        <Icon className="w-3 h-3 mr-1" />
        {config.label}
      </span>
    )
  }

  // Format proof type
  const formatProofType = (type: string) => {
    const typeConfig = {
      'RISC_ZERO': { label: 'RISC Zero', className: 'bg-blue-100 text-blue-800 border-blue-200', icon: Zap },
      'CIRCOM': { label: 'Circom', className: 'bg-purple-100 text-purple-800 border-purple-200', icon: FileText }
    }
    
    const config = typeConfig[type as keyof typeof typeConfig] || typeConfig['RISC_ZERO']
    const Icon = config.icon
    
    return (
      <span className={`inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold ${config.className}`}>
        <Icon className="w-3 h-3 mr-1" />
        {config.label}
      </span>
    )
  }

  // Truncate hash for display
  const truncateHash = (hash: string) => {
    if (hash.length <= 10) return hash
    return `${hash.slice(0, 6)}...${hash.slice(-4)}`
  }

  // Format date
  const formatDate = (date: Date | string) => {
    return new Date(date).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">ZK Proof Manager</h1>
          <p className="text-muted-foreground">
            Manage and verify zero-knowledge proofs for the WAGA DAO ecosystem
          </p>
        </div>
        <Button onClick={() => refreshProofs()} disabled={loading}>
          <RefreshCw className={`w-4 h-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
          Refresh
        </Button>
      </div>

      {/* Error and Success Messages */}
      {(error || submissionError || submissionSuccess) && (
        <div className="space-y-2">
          {error && (
            <Alert variant="destructive">
              <AlertTriangle className="h-4 w-4" />
              <AlertDescription>{error}</AlertDescription>
            </Alert>
          )}
          {submissionError && (
            <Alert variant="destructive">
              <AlertTriangle className="h-4 w-4" />
              <AlertDescription>{submissionError}</AlertDescription>
            </Alert>
          )}
          {submissionSuccess && (
            <Alert>
              <CheckCircle className="h-4 w-4" />
              <AlertDescription>{submissionSuccess}</AlertDescription>
            </Alert>
          )}
          <Button variant="outline" size="sm" onClick={handleClearMessages}>
            Clear Messages
          </Button>
        </div>
      )}

      {/* Main Tabs */}
      <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-4">
        <TabsList className="grid w-full grid-cols-5">
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="proofs">All Proofs</TabsTrigger>
          <TabsTrigger value="submit">Submit Proof</TabsTrigger>
          <TabsTrigger value="verify">Verify Proof</TabsTrigger>
          <TabsTrigger value="analytics">Analytics</TabsTrigger>
        </TabsList>

        {/* Overview Tab */}
        <TabsContent value="overview" className="space-y-4">
          {/* Statistics Cards */}
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Total Proofs</CardTitle>
                <Shield className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{stats?.totalProofs || 0}</div>
                <p className="text-xs text-muted-foreground">
                  Across all networks
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Verified</CardTitle>
                <CheckCircle className="h-4 w-4 text-green-600" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{stats?.verifiedProofs || 0}</div>
                <p className="text-xs text-muted-foreground">
                  Successfully verified
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Pending</CardTitle>
                <Clock className="h-4 w-4 text-yellow-600" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{stats?.pendingProofs || 0}</div>
                <p className="text-xs text-muted-foreground">
                  Awaiting verification
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Success Rate</CardTitle>
                <BarChart3 className="h-4 w-4 text-blue-600" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{stats?.successRate?.toFixed(1) || 0}%</div>
                <p className="text-xs text-muted-foreground">
                  Verification success
                </p>
              </CardContent>
            </Card>
          </div>

          {/* Recent Activity */}
          <Card>
            <CardHeader>
              <CardTitle>Recent Activity</CardTitle>
              <CardDescription>
                Latest ZK proof submissions and verifications
              </CardDescription>
            </CardHeader>
            <CardContent>
              {filteredProofs.length > 0 ? (
                <div className="space-y-3">
                  {filteredProofs.slice(0, 5).map((proof) => (
                    <div key={proof.proof_hash} className="flex items-center justify-between p-3 border rounded-lg">
                      <div className="flex items-center space-x-3">
                        {formatProofType(proof.proof_type)}
                        <div>
                          <p className="font-medium">{proof.proof_name}</p>
                          <p className="text-sm text-muted-foreground">
                            {truncateHash(proof.proof_hash)}
                          </p>
                        </div>
                      </div>
                      <div className="flex items-center space-x-3">
                        {formatStatus(proof.verification_status)}
                        <span className="text-sm text-muted-foreground">
                          {formatDate(proof.submitted_at)}
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="text-center py-8 text-muted-foreground">
                  <Shield className="h-12 w-12 mx-auto mb-4 opacity-50" />
                  <p>No proofs found</p>
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        {/* All Proofs Tab */}
        <TabsContent value="proofs" className="space-y-4">
          {/* Filters and Search */}
          <Card>
            <CardHeader>
              <CardTitle>Proofs</CardTitle>
              <CardDescription>
                Browse and manage all ZK proofs in the system
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="flex flex-col sm:flex-row gap-4 mb-4">
                <div className="flex-1">
                  <Input
                    placeholder="Search proofs..."
                    value={searchQuery}
                    onChange={(e: React.ChangeEvent<HTMLInputElement>) => setSearchQuery(e.target.value)}
                    onKeyPress={(e: React.KeyboardEvent<HTMLInputElement>) => e.key === 'Enter' && handleSearch()}
                  />
                </div>
                <Select value={selectedProofType} onValueChange={(value: any) => setSelectedProofType(value)}>
                  <SelectTrigger className="w-[180px]">
                    <SelectValue placeholder="Proof Type" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">All Types</SelectItem>
                    <SelectItem value="RISC_ZERO">RISC Zero</SelectItem>
                    <SelectItem value="CIRCOM">Circom</SelectItem>
                  </SelectContent>
                </Select>
                <Select value={selectedStatus} onValueChange={setSelectedStatus}>
                  <SelectTrigger className="w-[180px]">
                    <SelectValue placeholder="Status" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">All Status</SelectItem>
                    <SelectItem value="PENDING">Pending</SelectItem>
                    <SelectItem value="VERIFIED">Verified</SelectItem>
                    <SelectItem value="REJECTED">Rejected</SelectItem>
                    <SelectItem value="EXPIRED">Expired</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              {/* Proofs Table */}
              <div className="rounded-md border">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Proof</TableHead>
                      <TableHead>Type</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead>Submitter</TableHead>
                      <TableHead>Submitted</TableHead>
                      <TableHead>Actions</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {filteredProofs.map((proof) => (
                      <TableRow key={proof.proof_hash}>
                        <TableCell>
                          <div>
                            <p className="font-medium">{proof.proof_name}</p>
                            <p className="text-sm text-muted-foreground font-mono">
                              {truncateHash(proof.proof_hash)}
                            </p>
                          </div>
                        </TableCell>
                        <TableCell>{formatProofType(proof.proof_type)}</TableCell>
                        <TableCell>{formatStatus(proof.verification_status)}</TableCell>
                        <TableCell className="font-mono">
                          {truncateHash(proof.submitter_address)}
                        </TableCell>
                        <TableCell>{formatDate(proof.submitted_at)}</TableCell>
                        <TableCell>
                          <div className="flex space-x-2">
                            {proof.verification_status === 'PENDING' && (
                              <Button
                                size="sm"
                                onClick={() => handleVerifyProof(proof.proof_hash)}
                                disabled={loading}
                              >
                                <CheckCircle className="w-4 h-4 mr-1" />
                                Verify
                              </Button>
                            )}
                            <Button variant="outline" size="sm">
                              <FileText className="w-4 h-4 mr-1" />
                              Details
                            </Button>
                          </div>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </div>

              {filteredProofs.length === 0 && (
                <div className="text-center py-8 text-muted-foreground">
                  <Shield className="h-12 w-12 mx-auto mb-4 opacity-50" />
                  <p>No proofs found matching your criteria</p>
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        {/* Submit Proof Tab */}
        <TabsContent value="submit" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Submit New ZK Proof</CardTitle>
              <CardDescription>
                Submit a new zero-knowledge proof for verification
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleSubmitProof} className="space-y-6">
                {/* Basic Information */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="proofType">Proof Type</Label>
                    <Select 
                      value={proofForm.proofType} 
                      onValueChange={(value: 'RISC_ZERO' | 'CIRCOM') => handleFormChange('proofType', value)}
                    >
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="RISC_ZERO">RISC Zero</SelectItem>
                        <SelectItem value="CIRCOM">Circom</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="proofName">Proof Name</Label>
                    <Input
                      id="proofName"
                      placeholder="e.g., Coffee Quality Assessment"
                      value={proofForm.metadata.proof_name}
                      onChange={(e: React.ChangeEvent<HTMLInputElement>) => handleFormChange('metadata.proof_name', e.target.value)}
                      required
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="description">Description</Label>
                  <Textarea
                    id="description"
                    placeholder="Describe what this proof demonstrates..."
                    value={proofForm.metadata.description}
                    onChange={(e: React.ChangeEvent<HTMLTextAreaElement>) => handleFormChange('metadata.description', e.target.value)}
                    required
                  />
                </div>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="version">Version</Label>
                    <Input
                      id="version"
                      placeholder="1.0.0"
                      value={proofForm.metadata.version}
                      onChange={(e: React.ChangeEvent<HTMLInputElement>) => handleFormChange('metadata.version', e.target.value)}
                      required
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="circuitHash">Circuit Hash</Label>
                    <Input
                      id="circuitHash"
                      placeholder="0x..."
                      value={proofForm.metadata.circuit_hash}
                      onChange={(e: React.ChangeEvent<HTMLInputElement>) => handleFormChange('metadata.circuit_hash', e.target.value)}
                      required
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="maxGasLimit">Max Gas Limit</Label>
                    <Input
                      id="maxGasLimit"
                      type="number"
                      placeholder="500000"
                      value={proofForm.metadata.max_gas_limit}
                      onChange={(e: React.ChangeEvent<HTMLInputElement>) => handleFormChange('metadata.max_gas_limit', parseInt(e.target.value))}
                      required
                    />
                  </div>
                </div>

                {/* Proof Data */}
                <div className="space-y-2">
                  <Label htmlFor="proofData">Proof Data (Hex)</Label>
                  <Textarea
                    id="proofData"
                    placeholder="0x..."
                    value={proofForm.proofData}
                    onChange={(e: React.ChangeEvent<HTMLTextAreaElement>) => handleFormChange('proofData', e.target.value)}
                    required
                    className="font-mono"
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="publicInputs">Public Inputs (Hex)</Label>
                  <Textarea
                    id="publicInputs"
                    placeholder="0x..."
                    value={proofForm.publicInputs}
                    onChange={(e: React.ChangeEvent<HTMLTextAreaElement>) => handleFormChange('publicInputs', e.target.value)}
                    required
                    className="font-mono"
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="publicInputsHash">Public Inputs Hash</Label>
                  <Input
                    id="publicInputsHash"
                    placeholder="0x..."
                    value={proofForm.publicInputsHash}
                    onChange={(e: React.ChangeEvent<HTMLInputElement>) => handleFormChange('publicInputsHash', e.target.value)}
                    required
                    className="font-mono"
                  />
                </div>

                <Button type="submit" disabled={submitting} className="w-full">
                  {submitting ? (
                    <>
                      <RefreshCw className="w-4 h-4 mr-2 animate-spin" />
                      Submitting...
                    </>
                  ) : (
                    <>
                      <Upload className="w-4 h-4 mr-2" />
                      Submit Proof
                    </>
                  )}
                </Button>
              </form>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Verify Proof Tab */}
        <TabsContent value="verify" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Verify ZK Proof</CardTitle>
              <CardDescription>
                Verify existing proofs or check verification status
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="verifyProofHash">Proof Hash</Label>
                    <Input
                      id="verifyProofHash"
                      placeholder="Enter proof hash to verify..."
                      className="font-mono"
                    />
                  </div>
                  <div className="flex items-end">
                    <Button className="w-full">
                      <CheckCircle className="w-4 h-4 mr-2" />
                      Verify Proof
                    </Button>
                  </div>
                </div>

                <div className="text-center text-muted-foreground">
                  <Info className="h-8 w-8 mx-auto mb-2 opacity-50" />
                  <p>Enter a proof hash above to verify its validity</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Analytics Tab */}
        <TabsContent value="analytics" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>ZK Proof Analytics</CardTitle>
              <CardDescription>
                Detailed insights and performance metrics
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-6">
                {/* Performance Metrics */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="text-center p-4 border rounded-lg">
                    <div className="text-2xl font-bold text-green-600">
                      {stats?.successRate?.toFixed(1) || 0}%
                    </div>
                    <div className="text-sm text-muted-foreground">Success Rate</div>
                  </div>
                  <div className="text-center p-4 border rounded-lg">
                    <div className="text-2xl font-bold text-blue-600">
                      {stats?.averageGasUsed?.toLocaleString() || 0}
                    </div>
                    <div className="text-sm text-muted-foreground">Avg Gas Used</div>
                  </div>
                  <div className="text-center p-4 border rounded-lg">
                    <div className="text-2xl font-bold text-purple-600">
                      {stats?.totalProofs || 0}
                    </div>
                    <div className="text-sm text-muted-foreground">Total Proofs</div>
                  </div>
                </div>

                {/* Proof Type Distribution */}
                <div>
                  <h3 className="text-lg font-semibold mb-4">Proof Type Distribution</h3>
                  <div className="space-y-2">
                    <div className="flex items-center justify-between">
                      <span>RISC Zero</span>
                      <div className="flex items-center space-x-2">
                        <Progress 
                          value={stats ? (stats.verifiedProofs / Math.max(stats.totalProofs, 1)) * 100 : 0} 
                          className="w-20" 
                        />
                        <span className="text-sm text-muted-foreground">
                          {databaseProofs.filter(p => p.proof_type === 'RISC_ZERO').length}
                        </span>
                      </div>
                    </div>
                    <div className="flex items-center justify-between">
                      <span>Circom</span>
                      <div className="flex items-center space-x-2">
                        <Progress 
                          value={stats ? (stats.verifiedProofs / Math.max(stats.totalProofs, 1)) * 100 : 0} 
                          className="w-20" 
                        />
                        <span className="text-sm text-muted-foreground">
                          {databaseProofs.filter(p => p.proof_type === 'CIRCOM').length}
                        </span>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Recent Activity Chart Placeholder */}
                <div>
                  <h3 className="text-lg font-semibold mb-4">Recent Activity</h3>
                  <div className="h-32 bg-muted rounded-lg flex items-center justify-center">
                    <p className="text-muted-foreground">Activity chart coming soon</p>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  )
}
