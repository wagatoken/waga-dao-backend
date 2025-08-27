/**
 * Grant Application Form Component
 * Complete form for cooperatives to apply for coffee development grants
 */

"use client"

import { useState } from "react"
import Link from "next/link"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Checkbox } from "@/components/ui/checkbox"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import { Alert, AlertDescription } from "@/components/ui/alert"
import {
  Coffee,
  DollarSign,
  Calendar,
  MapPin,
  Users,
  Upload,
  FileText,
  CheckCircle,
  AlertTriangle,
  Target,
  Clock,
  Coins,
  ArrowLeft,
  Home
} from "lucide-react"

interface CooperativeProfile {
  id: string
  name: string
  location: string
  members: number
  established: string
  certifications: string[]
  totalLandHectares: number
  annualProduction: number
  verificationStatus: "verified" | "pending" | "unverified"
}

interface GrantApplicationFormProps {
  cooperativeProfile: CooperativeProfile | null
}

interface ApplicationData {
  projectTitle: string
  projectDescription: string
  requestedAmount: string
  projectDuration: string
  category: string
  landArea: string
  expectedProduction: string
  membersImpacted: string
  sustainabilityPractices: string[]
  milestones: Milestone[]
  businessPlan: File | null
  environmentalImpact: File | null
  certifications: File | null
}

interface Milestone {
  title: string
  description: string
  percentage: number
  timeline: string
  deliverables: string
}

export default function GrantApplicationForm({ cooperativeProfile }: GrantApplicationFormProps) {
  const [currentStep, setCurrentStep] = useState(1)
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [applicationData, setApplicationData] = useState<ApplicationData>({
    projectTitle: "",
    projectDescription: "",
    requestedAmount: "",
    projectDuration: "",
    category: "",
    landArea: "",
    expectedProduction: "",
    membersImpacted: "",
    sustainabilityPractices: [],
    milestones: [
      { title: "", description: "", percentage: 25, timeline: "", deliverables: "" },
      { title: "", description: "", percentage: 25, timeline: "", deliverables: "" },
      { title: "", description: "", percentage: 25, timeline: "", deliverables: "" },
      { title: "", description: "", percentage: 25, timeline: "", deliverables: "" }
    ],
    businessPlan: null,
    environmentalImpact: null,
    certifications: null
  })

  const sustainabilityOptions = [
    "Organic Farming Practices",
    "Water Conservation Systems", 
    "Soil Preservation Techniques",
    "Renewable Energy Usage",
    "Waste Reduction Programs",
    "Biodiversity Protection",
    "Carbon Sequestration",
    "Fair Trade Compliance"
  ]

  const totalSteps = 4
  const progressPercentage = (currentStep / totalSteps) * 100

  const handleInputChange = (field: string, value: any) => {
    setApplicationData(prev => ({ ...prev, [field]: value }))
  }

  const handleMilestoneChange = (index: number, field: string, value: any) => {
    setApplicationData(prev => ({
      ...prev,
      milestones: prev.milestones.map((milestone, i) => 
        i === index ? { ...milestone, [field]: value } : milestone
      )
    }))
  }

  const handleSustainabilityToggle = (practice: string) => {
    setApplicationData(prev => ({
      ...prev,
      sustainabilityPractices: prev.sustainabilityPractices.includes(practice)
        ? prev.sustainabilityPractices.filter(p => p !== practice)
        : [...prev.sustainabilityPractices, practice]
    }))
  }

  const handleFileUpload = (field: string, file: File) => {
    setApplicationData(prev => ({ ...prev, [field]: file }))
  }

  const handleSubmit = async () => {
    setIsSubmitting(true)
    // Simulate submission delay
    await new Promise(resolve => setTimeout(resolve, 2000))
    
    // Here would be the actual smart contract call
    console.log("Submitting application:", applicationData)
    
    setIsSubmitting(false)
    // Show success message or redirect
  }

  const validateStep = (step: number): boolean => {
    switch (step) {
      case 1:
        return !!(applicationData.projectTitle && applicationData.projectDescription && 
                 applicationData.requestedAmount && applicationData.category)
      case 2:
        return !!(applicationData.landArea && applicationData.expectedProduction && 
                 applicationData.membersImpacted && applicationData.sustainabilityPractices.length > 0)
      case 3:
        return applicationData.milestones.every(m => m.title && m.description && m.timeline)
      case 4:
        return !!(applicationData.businessPlan && applicationData.environmentalImpact)
      default:
        return false
    }
  }

  if (!cooperativeProfile) {
    return (
      <Alert>
        <AlertTriangle className="h-4 w-4" />
        <AlertDescription>
          Please complete your cooperative profile before applying for grants.
        </AlertDescription>
      </Alert>
    )
  }

  if (cooperativeProfile.verificationStatus !== "verified") {
    return (
      <Alert>
        <AlertTriangle className="h-4 w-4" />
        <AlertDescription>
          Your cooperative must be verified before applying for grants. Verification status: {cooperativeProfile.verificationStatus}
        </AlertDescription>
      </Alert>
    )
  }

  return (
    <div className="max-w-4xl mx-auto space-y-6">
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
        <span className="text-gray-900 font-medium">Grant Application</span>
      </nav>

      {/* Header */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center text-2xl">
            <Coffee className="h-6 w-6 mr-3 text-green-600" />
            Grant Application
          </CardTitle>
          <div className="flex items-center justify-between">
            <p className="text-gray-600">Apply for coffee development funding</p>
            <Badge className="bg-green-100 text-green-800">
              Step {currentStep} of {totalSteps}
            </Badge>
          </div>
        </CardHeader>
        <CardContent>
          <Progress value={progressPercentage} className="h-2" />
        </CardContent>
      </Card>

      {/* Step 1: Project Details */}
      {currentStep === 1 && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center">
              <FileText className="h-5 w-5 mr-2" />
              Project Details
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-2">
                <Label htmlFor="projectTitle">Project Title *</Label>
                <Input
                  id="projectTitle"
                  placeholder="e.g., Coffee Processing Facility Expansion"
                  value={applicationData.projectTitle}
                  onChange={(e) => handleInputChange("projectTitle", e.target.value)}
                />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="requestedAmount">Requested Amount (USDC) *</Label>
                <Input
                  id="requestedAmount"
                  type="number"
                  placeholder="50000"
                  value={applicationData.requestedAmount}
                  onChange={(e) => handleInputChange("requestedAmount", e.target.value)}
                />
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-2">
                <Label htmlFor="category">Project Category *</Label>
                <Select value={applicationData.category} onValueChange={(value: string) => handleInputChange("category", value)}>
                  <SelectTrigger>
                    <SelectValue placeholder="Select category" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="infrastructure">Infrastructure Development</SelectItem>
                    <SelectItem value="equipment">Equipment & Machinery</SelectItem>
                    <SelectItem value="training">Training & Capacity Building</SelectItem>
                    <SelectItem value="certification">Certification & Quality</SelectItem>
                    <SelectItem value="sustainability">Sustainability Initiatives</SelectItem>
                    <SelectItem value="expansion">Farm Expansion</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label htmlFor="projectDuration">Project Duration (months)</Label>
                <Input
                  id="projectDuration"
                  type="number"
                  placeholder="24"
                  value={applicationData.projectDuration}
                  onChange={(e) => handleInputChange("projectDuration", e.target.value)}
                />
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="projectDescription">Project Description *</Label>
              <Textarea
                id="projectDescription"
                placeholder="Describe your project, its objectives, and expected impact..."
                className="min-h-32"
                value={applicationData.projectDescription}
                onChange={(e) => handleInputChange("projectDescription", e.target.value)}
              />
            </div>
          </CardContent>
        </Card>
      )}

      {/* Step 2: Impact & Sustainability */}
      {currentStep === 2 && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center">
              <Target className="h-5 w-5 mr-2" />
              Impact & Sustainability
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div className="space-y-2">
                <Label htmlFor="landArea">Land Area (hectares) *</Label>
                <Input
                  id="landArea"
                  type="number"
                  placeholder="25"
                  value={applicationData.landArea}
                  onChange={(e) => handleInputChange("landArea", e.target.value)}
                />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="expectedProduction">Expected Production (kg/year) *</Label>
                <Input
                  id="expectedProduction"
                  type="number"
                  placeholder="5000"
                  value={applicationData.expectedProduction}
                  onChange={(e) => handleInputChange("expectedProduction", e.target.value)}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="membersImpacted">Members Impacted *</Label>
                <Input
                  id="membersImpacted"
                  type="number"
                  placeholder="50"
                  value={applicationData.membersImpacted}
                  onChange={(e) => handleInputChange("membersImpacted", e.target.value)}
                />
              </div>
            </div>

            <div className="space-y-4">
              <Label>Sustainability Practices *</Label>
              <p className="text-sm text-gray-600">Select all practices your project will implement:</p>
              <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                {sustainabilityOptions.map((practice) => (
                  <div key={practice} className="flex items-center space-x-2">
                    <Checkbox
                      id={practice}
                      checked={applicationData.sustainabilityPractices.includes(practice)}
                      onCheckedChange={() => handleSustainabilityToggle(practice)}
                    />
                    <Label htmlFor={practice} className="text-sm">{practice}</Label>
                  </div>
                ))}
              </div>
            </div>

            {applicationData.sustainabilityPractices.length > 0 && (
              <div className="space-y-2">
                <Label>Selected Practices:</Label>
                <div className="flex flex-wrap gap-2">
                  {applicationData.sustainabilityPractices.map((practice) => (
                    <Badge key={practice} variant="secondary" className="bg-green-100 text-green-800">
                      {practice}
                    </Badge>
                  ))}
                </div>
              </div>
            )}
          </CardContent>
        </Card>
      )}

      {/* Step 3: Milestone Planning */}
      {currentStep === 3 && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center">
              <Clock className="h-5 w-5 mr-2" />
              Milestone Planning
            </CardTitle>
            <p className="text-sm text-gray-600">Define 4 milestones for phased grant disbursement</p>
          </CardHeader>
          <CardContent className="space-y-6">
            {applicationData.milestones.map((milestone, index) => (
              <Card key={index} className="border-l-4 border-l-green-500">
                <CardHeader className="pb-3">
                  <CardTitle className="text-lg">
                    Milestone {index + 1} ({milestone.percentage}%)
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor={`milestone-title-${index}`}>Milestone Title *</Label>
                      <Input
                        id={`milestone-title-${index}`}
                        placeholder="e.g., Infrastructure Setup"
                        value={milestone.title}
                        onChange={(e) => handleMilestoneChange(index, "title", e.target.value)}
                      />
                    </div>
                    
                    <div className="space-y-2">
                      <Label htmlFor={`milestone-timeline-${index}`}>Timeline *</Label>
                      <Input
                        id={`milestone-timeline-${index}`}
                        placeholder="e.g., Months 1-6"
                        value={milestone.timeline}
                        onChange={(e) => handleMilestoneChange(index, "timeline", e.target.value)}
                      />
                    </div>
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor={`milestone-description-${index}`}>Description *</Label>
                    <Textarea
                      id={`milestone-description-${index}`}
                      placeholder="Describe what will be accomplished in this milestone..."
                      value={milestone.description}
                      onChange={(e) => handleMilestoneChange(index, "description", e.target.value)}
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor={`milestone-deliverables-${index}`}>Deliverables</Label>
                    <Textarea
                      id={`milestone-deliverables-${index}`}
                      placeholder="List specific deliverables and evidence that will be provided..."
                      value={milestone.deliverables}
                      onChange={(e) => handleMilestoneChange(index, "deliverables", e.target.value)}
                    />
                  </div>
                </CardContent>
              </Card>
            ))}
          </CardContent>
        </Card>
      )}

      {/* Step 4: Documentation */}
      {currentStep === 4 && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center">
              <Upload className="h-5 w-5 mr-2" />
              Required Documentation
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <Card className="border-dashed border-2 border-gray-300">
                <CardContent className="p-6 text-center">
                  <Upload className="h-8 w-8 mx-auto text-gray-400 mb-2" />
                  <h3 className="font-medium mb-2">Business Plan *</h3>
                  <p className="text-sm text-gray-600 mb-4">
                    Detailed business plan (PDF, max 10MB)
                  </p>
                  <Button variant="outline" size="sm">
                    {applicationData.businessPlan ? "Change File" : "Upload File"}
                  </Button>
                  {applicationData.businessPlan && (
                    <p className="text-sm text-green-600 mt-2">
                      ✓ {applicationData.businessPlan.name}
                    </p>
                  )}
                </CardContent>
              </Card>

              <Card className="border-dashed border-2 border-gray-300">
                <CardContent className="p-6 text-center">
                  <Upload className="h-8 w-8 mx-auto text-gray-400 mb-2" />
                  <h3 className="font-medium mb-2">Environmental Impact *</h3>
                  <p className="text-sm text-gray-600 mb-4">
                    Environmental assessment (PDF, max 10MB)
                  </p>
                  <Button variant="outline" size="sm">
                    {applicationData.environmentalImpact ? "Change File" : "Upload File"}
                  </Button>
                  {applicationData.environmentalImpact && (
                    <p className="text-sm text-green-600 mt-2">
                      ✓ {applicationData.environmentalImpact.name}
                    </p>
                  )}
                </CardContent>
              </Card>
            </div>

            <Card className="border-dashed border-2 border-gray-300">
              <CardContent className="p-6 text-center">
                <Upload className="h-8 w-8 mx-auto text-gray-400 mb-2" />
                <h3 className="font-medium mb-2">Certifications</h3>
                <p className="text-sm text-gray-600 mb-4">
                  Current certifications and compliance documents (PDF, max 5MB)
                </p>
                <Button variant="outline" size="sm">
                  {applicationData.certifications ? "Change File" : "Upload File"}
                </Button>
                {applicationData.certifications && (
                  <p className="text-sm text-green-600 mt-2">
                    ✓ {applicationData.certifications.name}
                  </p>
                )}
              </CardContent>
            </Card>

            <Alert>
              <CheckCircle className="h-4 w-4" />
              <AlertDescription>
                All documents will be stored securely on IPFS and linked to your grant application on-chain.
              </AlertDescription>
            </Alert>
          </CardContent>
        </Card>
      )}

      {/* Navigation */}
      <div className="flex justify-between">
        <Button
          variant="outline"
          onClick={() => setCurrentStep(Math.max(1, currentStep - 1))}
          disabled={currentStep === 1}
        >
          Previous
        </Button>

        <div className="flex space-x-4">
          {currentStep < totalSteps ? (
            <Button
              onClick={() => setCurrentStep(currentStep + 1)}
              disabled={!validateStep(currentStep)}
              className="bg-green-600 hover:bg-green-700"
            >
              Next
            </Button>
          ) : (
            <Button
              onClick={handleSubmit}
              disabled={!validateStep(currentStep) || isSubmitting}
              className="bg-green-600 hover:bg-green-700"
            >
              {isSubmitting ? (
                <>
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                  Submitting...
                </>
              ) : (
                <>
                  <Coins className="mr-2 h-4 w-4" />
                  Submit Application
                </>
              )}
            </Button>
          )}
        </div>
      </div>
    </div>
  )
}
