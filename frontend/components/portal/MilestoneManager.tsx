/**
 * Milestone Manager Component
 * Manages milestone submission, evidence upload, and progress tracking
 */

"use client"

import { useState } from "react"
import Link from "next/link"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import { Textarea } from "@/components/ui/textarea"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import {
  Clock,
  CheckCircle,
  Upload,
  FileText,
  Calendar,
  DollarSign,
  AlertTriangle,
  Eye,
  Download,
  Target,
  Coins,
  ImageIcon,
  VideoIcon,
  File,
  Home,
  ArrowLeft
} from "lucide-react"

interface Grant {
  id: string
  amount: number
  status: "active" | "completed" | "pending" | "rejected"
  milestones: Milestone[]
  disbursedAmount: number
  nextDisbursement: number
  createdAt: Date
}

interface Milestone {
  id: string
  title: string
  description: string
  percentage: number
  status: "completed" | "pending" | "in_review" | "rejected"
  dueDate: Date
  evidenceUrl?: string
  validatedAt?: Date
  feedback?: string
  submittedAt?: Date
}

interface MilestoneManagerProps {
  grants: Grant[]
}

interface EvidenceFile {
  file: File
  type: "image" | "video" | "document"
  description: string
}

export default function MilestoneManager({ grants }: MilestoneManagerProps) {
  const [selectedMilestone, setSelectedMilestone] = useState<Milestone | null>(null)
  const [evidenceFiles, setEvidenceFiles] = useState<EvidenceFile[]>([])
  const [evidenceDescription, setEvidenceDescription] = useState("")
  const [isSubmitting, setIsSubmitting] = useState(false)

  const allMilestones = grants.flatMap(grant => 
    grant.milestones.map(milestone => ({ ...milestone, grantId: grant.id, grantAmount: grant.amount }))
  )

  const pendingMilestones = allMilestones.filter(m => m.status === "pending")
  const inReviewMilestones = allMilestones.filter(m => m.status === "in_review")  
  const completedMilestones = allMilestones.filter(m => m.status === "completed")
  const rejectedMilestones = allMilestones.filter(m => m.status === "rejected")

  const handleFileUpload = (files: FileList | null) => {
    if (!files) return

    const newFiles: EvidenceFile[] = Array.from(files).map(file => {
      let type: "image" | "video" | "document" = "document"
      if (file.type.startsWith("image/")) type = "image"
      else if (file.type.startsWith("video/")) type = "video"

      return {
        file,
        type,
        description: ""
      }
    })

    setEvidenceFiles(prev => [...prev, ...newFiles])
  }

  const removeFile = (index: number) => {
    setEvidenceFiles(prev => prev.filter((_, i) => i !== index))
  }

  const updateFileDescription = (index: number, description: string) => {
    setEvidenceFiles(prev => prev.map((file, i) => 
      i === index ? { ...file, description } : file
    ))
  }

  const submitEvidence = async (milestone: Milestone) => {
    setIsSubmitting(true)
    
    try {
      // Simulate IPFS upload and smart contract interaction
      await new Promise(resolve => setTimeout(resolve, 2000))
      
      // Here would be actual implementation:
      // 1. Upload files to IPFS
      // 2. Call smart contract submitMilestoneEvidence function
      // 3. Update milestone status
      
      console.log("Submitting evidence for milestone:", milestone.id)
      console.log("Files:", evidenceFiles)
      console.log("Description:", evidenceDescription)
      
      // Reset form
      setEvidenceFiles([])
      setEvidenceDescription("")
      setSelectedMilestone(null)
      
    } catch (error) {
      console.error("Error submitting evidence:", error)
    } finally {
      setIsSubmitting(false)
    }
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case "completed":
        return <CheckCircle className="h-5 w-5 text-green-500" />
      case "in_review":
        return <Clock className="h-5 w-5 text-yellow-500" />
      case "rejected":
        return <AlertTriangle className="h-5 w-5 text-red-500" />
      default:
        return <Target className="h-5 w-5 text-gray-400" />
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case "completed":
        return "bg-green-100 text-green-800"
      case "in_review":
        return "bg-yellow-100 text-yellow-800"
      case "rejected":
        return "bg-red-100 text-red-800"
      default:
        return "bg-gray-100 text-gray-800"
    }
  }

  const getFileIcon = (type: string) => {
    switch (type) {
      case "image":
        return <ImageIcon className="h-4 w-4" />
      case "video":
        return <VideoIcon className="h-4 w-4" />
      default:
        return <File className="h-4 w-4" />
    }
  }

  return (
    <div className="space-y-6">
      {/* Breadcrumb Navigation */}
      <nav className="flex items-center space-x-2 text-sm text-gray-600">
        <Link href="/" className="hover:text-green-600 flex items-center">
          <Home className="h-4 w-4 mr-1" />
          Home
        </Link>
        <span>/</span>
        <Link href="/portal/cooperative" className="hover:text-green-600">
          Cooperative Portal
        </Link>
        <span>/</span>
        <span className="text-gray-900 font-medium">Milestone Management</span>
      </nav>

      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Milestone Management</h1>
          <p className="text-gray-600 mt-2">
            Track progress and submit evidence for grant milestones
          </p>
        </div>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card className="bg-blue-50 border-blue-200">
          <CardContent className="p-4">
            <div className="flex items-center">
              <Target className="h-6 w-6 text-blue-500" />
              <div className="ml-3">
                <p className="text-sm font-medium text-blue-600">Pending</p>
                <p className="text-xl font-bold text-blue-800">{pendingMilestones.length}</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="bg-yellow-50 border-yellow-200">
          <CardContent className="p-4">
            <div className="flex items-center">
              <Clock className="h-6 w-6 text-yellow-500" />
              <div className="ml-3">
                <p className="text-sm font-medium text-yellow-600">In Review</p>
                <p className="text-xl font-bold text-yellow-800">{inReviewMilestones.length}</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="bg-green-50 border-green-200">
          <CardContent className="p-4">
            <div className="flex items-center">
              <CheckCircle className="h-6 w-6 text-green-500" />
              <div className="ml-3">
                <p className="text-sm font-medium text-green-600">Completed</p>
                <p className="text-xl font-bold text-green-800">{completedMilestones.length}</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="bg-red-50 border-red-200">
          <CardContent className="p-4">
            <div className="flex items-center">
              <AlertTriangle className="h-6 w-6 text-red-500" />
              <div className="ml-3">
                <p className="text-sm font-medium text-red-600">Needs Action</p>
                <p className="text-xl font-bold text-red-800">{rejectedMilestones.length}</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      <Tabs defaultValue="pending" className="space-y-4">
        <TabsList className="grid w-full grid-cols-4">
          <TabsTrigger value="pending">Pending ({pendingMilestones.length})</TabsTrigger>
          <TabsTrigger value="in_review">In Review ({inReviewMilestones.length})</TabsTrigger>
          <TabsTrigger value="completed">Completed ({completedMilestones.length})</TabsTrigger>
          <TabsTrigger value="rejected">Needs Action ({rejectedMilestones.length})</TabsTrigger>
        </TabsList>

        {/* Pending Milestones */}
        <TabsContent value="pending" className="space-y-4">
          {pendingMilestones.length === 0 ? (
            <Card>
              <CardContent className="text-center py-8">
                <Target className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                <h3 className="text-lg font-medium text-gray-900 mb-2">No Pending Milestones</h3>
                <p className="text-gray-600">All current milestones have been submitted or completed.</p>
              </CardContent>
            </Card>
          ) : (
            pendingMilestones.map((milestone: any) => (
              <Card key={milestone.id} className="border-l-4 border-l-blue-500">
                <CardHeader className="pb-3">
                  <div className="flex items-center justify-between">
                    <CardTitle className="text-lg">{milestone.title}</CardTitle>
                    <div className="flex items-center space-x-2">
                      <Badge variant="secondary">{milestone.percentage}%</Badge>
                      <Badge className={getStatusColor(milestone.status)}>
                        {milestone.status.replace("_", " ")}
                      </Badge>
                    </div>
                  </div>
                </CardHeader>
                <CardContent className="space-y-4">
                  <p className="text-gray-600">{milestone.description}</p>
                  
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
                    <div className="flex items-center text-gray-600">
                      <Calendar className="h-4 w-4 mr-2" />
                      Due: {milestone.dueDate.toLocaleDateString()}
                    </div>
                    <div className="flex items-center text-gray-600">
                      <DollarSign className="h-4 w-4 mr-2" />
                      Value: ${((milestone.grantAmount * milestone.percentage) / 100).toLocaleString()}
                    </div>
                    <div className="flex items-center text-gray-600">
                      <Coins className="h-4 w-4 mr-2" />
                      Grant: #{milestone.grantId}
                    </div>
                  </div>

                  <Button
                    onClick={() => setSelectedMilestone(milestone)}
                    className="w-full bg-blue-600 hover:bg-blue-700"
                  >
                    <Upload className="mr-2 h-4 w-4" />
                    Submit Evidence
                  </Button>
                </CardContent>
              </Card>
            ))
          )}
        </TabsContent>

        {/* In Review Milestones */}
        <TabsContent value="in_review" className="space-y-4">
          {inReviewMilestones.map((milestone: any) => (
            <Card key={milestone.id} className="border-l-4 border-l-yellow-500">
              <CardHeader className="pb-3">
                <div className="flex items-center justify-between">
                  <CardTitle className="text-lg">{milestone.title}</CardTitle>
                  <div className="flex items-center space-x-2">
                    <Badge variant="secondary">{milestone.percentage}%</Badge>
                    <Badge className={getStatusColor(milestone.status)}>
                      {getStatusIcon(milestone.status)}
                      <span className="ml-1">In Review</span>
                    </Badge>
                  </div>
                </div>
              </CardHeader>
              <CardContent className="space-y-4">
                <p className="text-gray-600">{milestone.description}</p>
                
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
                  <div className="flex items-center text-gray-600">
                    <Upload className="h-4 w-4 mr-2" />
                    Submitted: {milestone.submittedAt?.toLocaleDateString()}
                  </div>
                  <div className="flex items-center text-gray-600">
                    <DollarSign className="h-4 w-4 mr-2" />
                    Value: ${((milestone.grantAmount * milestone.percentage) / 100).toLocaleString()}
                  </div>
                  <div className="flex items-center text-gray-600">
                    <Coins className="h-4 w-4 mr-2" />
                    Grant: #{milestone.grantId}
                  </div>
                </div>

                <Alert>
                  <Clock className="h-4 w-4" />
                  <AlertDescription>
                    Evidence submitted and under review. You will be notified once validation is complete.
                  </AlertDescription>
                </Alert>

                {milestone.evidenceUrl && (
                  <Button variant="outline" size="sm">
                    <Eye className="mr-2 h-4 w-4" />
                    View Submitted Evidence
                  </Button>
                )}
              </CardContent>
            </Card>
          ))}
        </TabsContent>

        {/* Completed Milestones */}
        <TabsContent value="completed" className="space-y-4">
          {completedMilestones.map((milestone: any) => (
            <Card key={milestone.id} className="border-l-4 border-l-green-500">
              <CardHeader className="pb-3">
                <div className="flex items-center justify-between">
                  <CardTitle className="text-lg">{milestone.title}</CardTitle>
                  <div className="flex items-center space-x-2">
                    <Badge variant="secondary">{milestone.percentage}%</Badge>
                    <Badge className={getStatusColor(milestone.status)}>
                      {getStatusIcon(milestone.status)}
                      <span className="ml-1">Completed</span>
                    </Badge>
                  </div>
                </div>
              </CardHeader>
              <CardContent className="space-y-4">
                <p className="text-gray-600">{milestone.description}</p>
                
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
                  <div className="flex items-center text-green-600">
                    <CheckCircle className="h-4 w-4 mr-2" />
                    Validated: {milestone.validatedAt?.toLocaleDateString()}
                  </div>
                  <div className="flex items-center text-gray-600">
                    <DollarSign className="h-4 w-4 mr-2" />
                    Disbursed: ${((milestone.grantAmount * milestone.percentage) / 100).toLocaleString()}
                  </div>
                  <div className="flex items-center text-gray-600">
                    <Coins className="h-4 w-4 mr-2" />
                    Grant: #{milestone.grantId}
                  </div>
                </div>

                <div className="flex space-x-2">
                  <Button variant="outline" size="sm">
                    <Eye className="mr-2 h-4 w-4" />
                    View Evidence
                  </Button>
                  <Button variant="outline" size="sm">
                    <Download className="mr-2 h-4 w-4" />
                    Download Certificate
                  </Button>
                </div>
              </CardContent>
            </Card>
          ))}
        </TabsContent>

        {/* Rejected Milestones */}
        <TabsContent value="rejected" className="space-y-4">
          {rejectedMilestones.map((milestone: any) => (
            <Card key={milestone.id} className="border-l-4 border-l-red-500">
              <CardHeader className="pb-3">
                <div className="flex items-center justify-between">
                  <CardTitle className="text-lg">{milestone.title}</CardTitle>
                  <div className="flex items-center space-x-2">
                    <Badge variant="secondary">{milestone.percentage}%</Badge>
                    <Badge className={getStatusColor(milestone.status)}>
                      {getStatusIcon(milestone.status)}
                      <span className="ml-1">Needs Action</span>
                    </Badge>
                  </div>
                </div>
              </CardHeader>
              <CardContent className="space-y-4">
                <p className="text-gray-600">{milestone.description}</p>
                
                {milestone.feedback && (
                  <Alert className="border-red-200 bg-red-50">
                    <AlertTriangle className="h-4 w-4" />
                    <AlertDescription>
                      <strong>Validation Feedback:</strong> {milestone.feedback}
                    </AlertDescription>
                  </Alert>
                )}

                <Button
                  onClick={() => setSelectedMilestone(milestone)}
                  className="w-full bg-red-600 hover:bg-red-700"
                >
                  <Upload className="mr-2 h-4 w-4" />
                  Resubmit Evidence
                </Button>
              </CardContent>
            </Card>
          ))}
        </TabsContent>
      </Tabs>

      {/* Evidence Submission Modal */}
      {selectedMilestone && (
        <Card className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
          <div className="max-w-2xl w-full m-4 max-h-[90vh] overflow-y-auto">
            <Card>
              <CardHeader>
                <CardTitle>Submit Evidence - {selectedMilestone.title}</CardTitle>
                <p className="text-sm text-gray-600">{selectedMilestone.description}</p>
              </CardHeader>
              <CardContent className="space-y-6">
                {/* File Upload */}
                <div className="space-y-4">
                  <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center">
                    <Upload className="h-8 w-8 mx-auto text-gray-400 mb-2" />
                    <h3 className="font-medium mb-2">Upload Evidence Files</h3>
                    <p className="text-sm text-gray-600 mb-4">
                      Upload photos, videos, or documents as proof of milestone completion
                    </p>
                    <input
                      type="file"
                      multiple
                      accept="image/*,video/*,.pdf,.doc,.docx"
                      onChange={(e) => handleFileUpload(e.target.files)}
                      className="hidden"
                      id="evidence-upload"
                    />
                    <label htmlFor="evidence-upload" className="cursor-pointer">
                      <Button variant="outline" size="sm" type="button">
                        Select Files
                      </Button>
                    </label>
                  </div>

                  {/* File List */}
                  {evidenceFiles.length > 0 && (
                    <div className="space-y-2">
                      <h4 className="font-medium">Uploaded Files:</h4>
                      {evidenceFiles.map((evidenceFile, index) => (
                        <div key={index} className="flex items-center justify-between p-3 border rounded-lg">
                          <div className="flex items-center space-x-3">
                            {getFileIcon(evidenceFile.type)}
                            <div>
                              <p className="text-sm font-medium">{evidenceFile.file.name}</p>
                              <p className="text-xs text-gray-500">
                                {evidenceFile.type} • {(evidenceFile.file.size / 1024 / 1024).toFixed(2)} MB
                              </p>
                            </div>
                          </div>
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => removeFile(index)}
                          >
                            Remove
                          </Button>
                        </div>
                      ))}
                    </div>
                  )}
                </div>

                {/* Evidence Description */}
                <div className="space-y-2">
                  <label className="text-sm font-medium">Evidence Description</label>
                  <Textarea
                    placeholder="Describe the evidence you're submitting and how it demonstrates milestone completion..."
                    value={evidenceDescription}
                    onChange={(e) => setEvidenceDescription(e.target.value)}
                    className="min-h-24"
                  />
                </div>

                {/* Actions */}
                <div className="flex justify-end space-x-4">
                  <Button
                    variant="outline"
                    onClick={() => {
                      setSelectedMilestone(null)
                      setEvidenceFiles([])
                      setEvidenceDescription("")
                    }}
                  >
                    Cancel
                  </Button>
                  <Button
                    onClick={() => submitEvidence(selectedMilestone)}
                    disabled={evidenceFiles.length === 0 || !evidenceDescription.trim() || isSubmitting}
                    className="bg-green-600 hover:bg-green-700"
                  >
                    {isSubmitting ? (
                      <>
                        <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                        Submitting...
                      </>
                    ) : (
                      <>
                        <Upload className="mr-2 h-4 w-4" />
                        Submit Evidence
                      </>
                    )}
                  </Button>
                </div>
              </CardContent>
            </Card>
          </div>
        </Card>
      )}
    </div>
  )
}
