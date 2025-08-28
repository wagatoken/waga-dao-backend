import { useState, useEffect, useCallback } from 'react'
import { useAccount, useChainId, useWalletClient } from 'wagmi'
import { ZKProof, ProofMetadata, ProofSubmissionData, ProofVerificationResult, SystemStats } from '../lib/services/ZKProofService'
import { ZKProofDatabase } from '../lib/services/DatabaseService'

export interface UseZKProofsReturn {
  // State
  proofs: ZKProof[]
  databaseProofs: ZKProofDatabase[]
  loading: boolean
  error: string | null
  
  // Smart Contract Operations
  submitProof: (data: ProofSubmissionData) => Promise<string>
  verifyProof: (proofHash: string) => Promise<ProofVerificationResult>
  batchVerifyProofs: (proofHashes: string[]) => Promise<ProofVerificationResult[]>
  
  // Database Operations
  refreshProofs: () => Promise<void>
  getProofDetails: (proofHash: string) => Promise<ZKProof | null>
  searchProofs: (query: string) => Promise<ZKProofDatabase[]>
  
  // Statistics and Analytics
  stats: SystemStats | null
  refreshStats: () => Promise<void>
  
  // Circuit Management
  isCircuitSupported: (circuitHash: string, proofType: 'RISC_ZERO' | 'CIRCOM') => Promise<boolean>
  
  // Utility
  clearError: () => void
}

export function useZKProofs(): UseZKProofsReturn {
  const { address, isConnected } = useAccount()
  const chainId = useChainId()
  const { data: walletClient } = useWalletClient()
  
  // State
  const [proofs, setProofs] = useState<ZKProof[]>([])
  const [databaseProofs, setDatabaseProofs] = useState<ZKProofDatabase[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [stats, setStats] = useState<SystemStats | null>(null)

  // Initialize service when wallet connects
  useEffect(() => {
    if (isConnected && walletClient && chainId) {
      initializeService()
    }
  }, [isConnected, walletClient, chainId])

  // Load initial data
  useEffect(() => {
    if (isConnected) {
      loadInitialData()
    }
  }, [isConnected])

  const initializeService = useCallback(async () => {
    try {
      setLoading(true)
      setError(null)
      
      // Initialize ZK proof service
      // await zkProofService.initialize()
      
      // Load initial data
      await loadInitialData()
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to initialize service')
    } finally {
      setLoading(false)
    }
  }, [])

  const loadInitialData = useCallback(async () => {
    try {
      setLoading(true)
      
      // Load proofs from database
      // const dbProofs = await databaseService.listZKProofs({ limit: 50 })
      // setDatabaseProofs(dbProofs)
      
      // Load system stats
      await refreshStats()
      
      // Load proofs from smart contract (for connected wallet)
      if (address) {
        // const contractProofs = await zkProofService.getProofsBySubmitter(address)
        // setProofs(contractProofs)
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load initial data')
    } finally {
      setLoading(false)
    }
  }, [address])

  const submitProof = useCallback(async (data: ProofSubmissionData): Promise<string> => {
    try {
      setLoading(true)
      setError(null)
      
      // Submit proof to smart contract
      // const proofHash = await zkProofService.submitProof(data)
      const proofHash = 'mock-hash' // Temporary mock
      
      // Refresh data
      await refreshProofs()
      await refreshStats()
      
      return proofHash
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to submit proof'
      setError(errorMessage)
      throw new Error(errorMessage)
    } finally {
      setLoading(false)
    }
  }, [])

  const verifyProof = useCallback(async (proofHash: string): Promise<ProofVerificationResult> => {
    try {
      setLoading(true)
      setError(null)
      
      // Verify proof on smart contract
      // const result = await zkProofService.verifyProof(proofHash)
      const result: ProofVerificationResult = { 
        success: true, 
        gasUsed: 100000,
        verificationDuration: 1500 // 1.5 seconds
      } // Temporary mock
      
      // Refresh data
      await refreshProofs()
      await refreshStats()
      
      return result
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to verify proof'
      setError(errorMessage)
      throw new Error(errorMessage)
    } finally {
      setLoading(false)
    }
  }, [])

  const batchVerifyProofs = useCallback(async (proofHashes: string[]): Promise<ProofVerificationResult[]> => {
    try {
      setLoading(true)
      setError(null)
      
      // Batch verify proofs on smart contract
      // const results = await zkProofService.batchVerifyProofs(proofHashes)
      const results: ProofVerificationResult[] = proofHashes.map(() => ({ 
        success: true, 
        gasUsed: 100000,
        verificationDuration: 1500 // 1.5 seconds
      })) // Temporary mock
      
      // Refresh data
      await refreshProofs()
      await refreshStats()
      
      return results
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to batch verify proofs'
      setError(errorMessage)
      throw new Error(errorMessage)
    } finally {
      setLoading(false)
    }
  }, [])

  const refreshProofs = useCallback(async () => {
    try {
      setLoading(true)
      
      // Refresh database proofs
      // const dbProofs = await databaseService.listZKProofs({ limit: 50 })
      // setDatabaseProofs(dbProofs)
      
      // Refresh smart contract proofs for connected wallet
      if (address) {
        // const contractProofs = await zkProofService.getProofsBySubmitter(address)
        // setProofs(contractProofs)
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to refresh proofs')
    } finally {
      setLoading(false)
    }
  }, [address])

  const getProofDetails = useCallback(async (proofHash: string): Promise<ZKProof | null> => {
    try {
      setError(null)
      
      // Get proof details from smart contract
      // const proof = await zkProofService.getProofDetails(proofHash)
      
      return null // Temporary mock
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to get proof details'
      setError(errorMessage)
      return null
    }
  }, [])

  const searchProofs = useCallback(async (query: string): Promise<ZKProofDatabase[]> => {
    try {
      setError(null)
      
      // Search proofs in database
      // const results = await databaseService.searchProofs(query)
      
      return [] // Temporary mock
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to search proofs'
      setError(errorMessage)
      return []
    }
  }, [])

  const refreshStats = useCallback(async () => {
    try {
      // Get stats from smart contract
      // const contractStats = await zkProofService.getSystemStats()
      
      // Get additional stats from database
      // const dbStats = await databaseService.getZKProofStats()
      
      // Combine stats
      const combinedStats: SystemStats = {
        totalProofs: 0,
        verifiedProofs: 0,
        pendingProofs: 0,
        expiredProofs: 0,
        averageGasUsed: 0,
        successRate: 0
      }
      
      setStats(combinedStats)
    } catch (err) {
      console.error('Failed to refresh stats:', err)
      // Don't set error for stats refresh failure
    }
  }, [])

  const isCircuitSupported = useCallback(async (
    circuitHash: string, 
    proofType: 'RISC_ZERO' | 'CIRCOM'
  ): Promise<boolean> => {
    try {
      setError(null)
      
      // return await zkProofService.isCircuitSupported(circuitHash, proofType)
      return true // Temporary mock
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to check circuit support'
      setError(errorMessage)
      return false
    }
  }, [])

  const clearError = useCallback(() => {
    setError(null)
  }, [])

  return {
    // State
    proofs,
    databaseProofs,
    loading,
    error,
    
    // Smart Contract Operations
    submitProof,
    verifyProof,
    batchVerifyProofs,
    
    // Database Operations
    refreshProofs,
    getProofDetails,
    searchProofs,
    
    // Statistics and Analytics
    stats,
    refreshStats,
    
    // Circuit Management
    isCircuitSupported,
    
    // Utility
    clearError,
  }
}

// Hook for managing a single proof
export function useZKProof(proofHash: string) {
  const [proof, setProof] = useState<ZKProof | null>(null)
  const [databaseProof, setDatabaseProof] = useState<ZKProofDatabase | null>(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const { verifyProof } = useZKProofs()

  useEffect(() => {
    if (proofHash) {
      loadProof()
    }
  }, [proofHash])

  const loadProof = async () => {
    try {
      setLoading(true)
      setError(null)
      
      // Load from smart contract
      // const contractProof = await zkProofService.getProofDetails(proofHash)
      // setProof(contractProof)
      
      // Load from database
      // const dbProof = await databaseService.getZKProof(proofHash)
      // setDatabaseProof(dbProof)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load proof')
    } finally {
      setLoading(false)
    }
  }

  const verify = async (): Promise<ProofVerificationResult> => {
    return await verifyProof(proofHash)
  }

  const refresh = () => {
    loadProof()
  }

  return {
    proof,
    databaseProof,
    loading,
    error,
    verify,
    refresh,
  }
}

// Hook for proof submission form
export function useProofSubmission() {
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState<string | null>(null)

  const { submitProof } = useZKProofs()

  const submit = async (data: ProofSubmissionData) => {
    try {
      setSubmitting(true)
      setError(null)
      setSuccess(null)
      
      const proofHash = await submitProof(data)
      
      setSuccess(`Proof submitted successfully! Hash: ${proofHash}`)
      return proofHash
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to submit proof'
      setError(errorMessage)
      throw err
    } finally {
      setSubmitting(false)
    }
  }

  const clearMessages = () => {
    setError(null)
    setSuccess(null)
  }

  return {
    submitting,
    error,
    success,
    submit,
    clearMessages,
  }
}
