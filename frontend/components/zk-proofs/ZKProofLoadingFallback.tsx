/**
 * ZK Proof Loading Fallback Component
 * Displays when ZK proof components are loading or encountering errors
 */

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { Shield, AlertTriangle, RefreshCw } from 'lucide-react'
import { Button } from '@/components/ui/button'

interface ZKProofLoadingFallbackProps {
  error?: string | null
  onRetry?: () => void
}

export default function ZKProofLoadingFallback({ error, onRetry }: ZKProofLoadingFallbackProps) {
  if (error) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2 text-red-600">
            <AlertTriangle className="h-5 w-5" />
            ZK Proof System Error
          </CardTitle>
          <CardDescription>
            There was an issue loading the ZK proof management system
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <Alert variant="destructive">
            <AlertTriangle className="h-4 w-4" />
            <AlertDescription>{error}</AlertDescription>
          </Alert>
          
          <div className="text-sm text-muted-foreground">
            <p>This could be due to:</p>
            <ul className="list-disc list-inside mt-2 space-y-1">
              <li>Network connectivity issues</li>
              <li>Wallet connection problems</li>
              <li>Smart contract deployment status</li>
              <li>Browser compatibility</li>
            </ul>
          </div>
          
          {onRetry && (
            <Button onClick={onRetry} variant="outline" className="w-full">
              <RefreshCw className="h-4 w-4 mr-2" />
              Try Again
            </Button>
          )}
        </CardContent>
      </Card>
    )
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Shield className="h-5 w-5" />
          ZK Proof Management
        </CardTitle>
        <CardDescription>
          Loading zero-knowledge proof management system...
        </CardDescription>
      </CardHeader>
      <CardContent>
        <div className="flex flex-col items-center justify-center py-12 space-y-4">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
          <p className="text-sm text-muted-foreground">Initializing ZK proof system</p>
          <div className="text-xs text-muted-foreground max-w-md text-center">
            Please ensure your wallet is connected and you have network access
          </div>
        </div>
      </CardContent>
    </Card>
  )
}