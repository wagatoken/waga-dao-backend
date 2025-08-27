/**
 * Inventory Tokenizer Component
 * Manages coffee inventory tokenization for cooperatives
 */

"use client"

import { useState, useEffect } from "react"
import Link from "next/link"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import { Textarea } from "@/components/ui/textarea"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import {
  Coffee,
  Package,
  Coins,
  Calendar,
  MapPin,
  Thermometer,
  Award,
  TrendingUp,
  Plus,
  Eye,
  Download,
  Upload,
  CheckCircle,
  Clock,
  AlertTriangle,
  Leaf,
  Scale,
  Truck,
  Home,
  ArrowLeft
} from "lucide-react"

interface InventoryTokenizerProps {
  cooperativeId: string
}

interface CoffeeBatch {
  id: string
  tokenId: number
  type: "GREEN_BEANS" | "ROASTED_BEANS"
  quantity: number
  qualityGrade: string
  harvestDate: Date
  processMethod: string
  moistureContent: number
  cupScore: number
  certifications: string[]
  location: string
  status: "active" | "sold" | "processing"
  marketValue: number
  tokenizedAmount: number
  createdAt: Date
}

interface TokenizationRequest {
  batchId: string
  quantity: number
  qualityEvidence: File[]
  certificationDocs: File[]
  description: string
}

export default function InventoryTokenizer({ cooperativeId }: InventoryTokenizerProps) {
  const [batches, setBatches] = useState<CoffeeBatch[]>([])
  const [selectedBatch, setSelectedBatch] = useState<CoffeeBatch | null>(null)
  const [activeTab, setActiveTab] = useState("overview")
  const [isTokenizing, setIsTokenizing] = useState(false)
  const [newBatchData, setNewBatchData] = useState({
    quantity: "",
    qualityGrade: "",
    harvestDate: "",
    processMethod: "",
    moistureContent: "",
    cupScore: "",
    certifications: [] as string[],
    location: "",
    description: ""
  })

  // Mock data initialization
  useEffect(() => {
    const mockBatches: CoffeeBatch[] = [
      {
        id: "batch_001",
        tokenId: 1001,
        type: "GREEN_BEANS",
        quantity: 2500,
        qualityGrade: "Specialty",
        harvestDate: new Date("2025-03-15"),
        processMethod: "Washed",
        moistureContent: 11.5,
        cupScore: 84.5,
        certifications: ["Organic", "Fair Trade"],
        location: "Plot A, Bamenda Region",
        status: "active",
        marketValue: 7500,
        tokenizedAmount: 2500,
        createdAt: new Date("2025-03-20")
      },
      {
        id: "batch_002", 
        tokenId: 1002,
        type: "ROASTED_BEANS",
        quantity: 1200,
        qualityGrade: "Premium",
        harvestDate: new Date("2025-02-28"),
        processMethod: "Natural",
        moistureContent: 10.8,
        cupScore: 86.2,
        certifications: ["Organic", "Rainforest Alliance"],
        location: "Plot B, Bamenda Region",
        status: "processing",
        marketValue: 4800,
        tokenizedAmount: 1200,
        createdAt: new Date("2025-03-05")
      }
    ]

    setBatches(mockBatches)
  }, [cooperativeId])

  const totalInventoryValue = batches.reduce((sum, batch) => sum + batch.marketValue, 0)
  const totalQuantity = batches.reduce((sum, batch) => sum + batch.quantity, 0)
  const averageQuality = batches.reduce((sum, batch) => sum + batch.cupScore, 0) / batches.length || 0

  const handleCreateBatch = async () => {
    setIsTokenizing(true)
    
    try {
      // Simulate blockchain transaction
      await new Promise(resolve => setTimeout(resolve, 2000))
      
      const newBatch: CoffeeBatch = {
        id: `batch_${Date.now()}`,
        tokenId: Math.floor(Math.random() * 10000) + 1000,
        type: "GREEN_BEANS",
        quantity: parseInt(newBatchData.quantity),
        qualityGrade: newBatchData.qualityGrade,
        harvestDate: new Date(newBatchData.harvestDate),
        processMethod: newBatchData.processMethod,
        moistureContent: parseFloat(newBatchData.moistureContent),
        cupScore: parseFloat(newBatchData.cupScore),
        certifications: newBatchData.certifications,
        location: newBatchData.location,
        status: "active",
        marketValue: parseInt(newBatchData.quantity) * 3, // $3 per kg estimate
        tokenizedAmount: parseInt(newBatchData.quantity),
        createdAt: new Date()
      }

      setBatches(prev => [...prev, newBatch])
      
      // Reset form
      setNewBatchData({
        quantity: "",
        qualityGrade: "",
        harvestDate: "",
        processMethod: "",
        moistureContent: "",
        cupScore: "",
        certifications: [],
        location: "",
        description: ""
      })
      
      setActiveTab("overview")
      
    } catch (error) {
      console.error("Error creating batch:", error)
    } finally {
      setIsTokenizing(false)
    }
  }

  const convertToRoasted = async (batch: CoffeeBatch) => {
    try {
      // Simulate conversion process
      await new Promise(resolve => setTimeout(resolve, 1500))
      
      // Here would be actual smart contract call to convert tokens
      console.log("Converting batch to roasted beans:", batch.id)
      
      setBatches(prev => prev.map(b => 
        b.id === batch.id 
          ? { ...b, type: "ROASTED_BEANS", quantity: b.quantity * 0.8, marketValue: b.marketValue * 1.5 }
          : b
      ))
      
    } catch (error) {
      console.error("Error converting batch:", error)
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case "active":
        return "bg-green-100 text-green-800"
      case "processing":
        return "bg-yellow-100 text-yellow-800"
      case "sold":
        return "bg-gray-100 text-gray-800"
      default:
        return "bg-gray-100 text-gray-800"
    }
  }

  const getTypeColor = (type: string) => {
    return type === "GREEN_BEANS" 
      ? "bg-green-100 text-green-800" 
      : "bg-amber-100 text-amber-800"
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
        <span className="text-gray-900 font-medium">Inventory Tokenization</span>
      </nav>

      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Coffee Inventory Tokenization</h1>
          <p className="text-gray-600 mt-2">
            Manage and tokenize your coffee inventory on the blockchain
          </p>
        </div>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <Card className="bg-gradient-to-br from-green-400 to-green-600 text-white">
          <CardContent className="p-6">
            <div className="flex items-center">
              <Package className="h-8 w-8 text-green-100" />
              <div className="ml-3">
                <p className="text-green-100 text-sm font-medium">Total Inventory</p>
                <p className="text-2xl font-bold">{totalQuantity.toLocaleString()} kg</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="bg-gradient-to-br from-blue-400 to-blue-600 text-white">
          <CardContent className="p-6">
            <div className="flex items-center">
              <Coins className="h-8 w-8 text-blue-100" />
              <div className="ml-3">
                <p className="text-blue-100 text-sm font-medium">Market Value</p>
                <p className="text-2xl font-bold">${totalInventoryValue.toLocaleString()}</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="bg-gradient-to-br from-purple-400 to-purple-600 text-white">
          <CardContent className="p-6">
            <div className="flex items-center">
              <Award className="h-8 w-8 text-purple-100" />
              <div className="ml-3">
                <p className="text-purple-100 text-sm font-medium">Avg. Quality</p>
                <p className="text-2xl font-bold">{averageQuality.toFixed(1)}</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="bg-gradient-to-br from-amber-400 to-amber-600 text-white">
          <CardContent className="p-6">
            <div className="flex items-center">
              <Coffee className="h-8 w-8 text-amber-100" />
              <div className="ml-3">
                <p className="text-amber-100 text-sm font-medium">Active Batches</p>
                <p className="text-2xl font-bold">{batches.filter(b => b.status === "active").length}</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-6">
        <TabsList className="grid w-full grid-cols-3">
          <TabsTrigger value="overview">Inventory Overview</TabsTrigger>
          <TabsTrigger value="tokenize">Create New Batch</TabsTrigger>
          <TabsTrigger value="analytics">Analytics</TabsTrigger>
        </TabsList>

        {/* Overview Tab */}
        <TabsContent value="overview" className="space-y-6">
          <div className="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-6">
            {batches.map((batch) => (
              <Card key={batch.id} className="hover:shadow-lg transition-shadow">
                <CardHeader className="pb-3">
                  <div className="flex items-center justify-between">
                    <CardTitle className="text-lg">Batch #{batch.tokenId}</CardTitle>
                    <div className="flex space-x-2">
                      <Badge className={getTypeColor(batch.type)}>
                        {batch.type === "GREEN_BEANS" ? "Green" : "Roasted"}
                      </Badge>
                      <Badge className={getStatusColor(batch.status)}>
                        {batch.status}
                      </Badge>
                    </div>
                  </div>
                </CardHeader>
                
                <CardContent className="space-y-4">
                  <div className="grid grid-cols-2 gap-4 text-sm">
                    <div className="flex items-center text-gray-600">
                      <Scale className="h-4 w-4 mr-2" />
                      {batch.quantity} kg
                    </div>
                    <div className="flex items-center text-gray-600">
                      <Award className="h-4 w-4 mr-2" />
                      {batch.cupScore} points
                    </div>
                    <div className="flex items-center text-gray-600">
                      <Thermometer className="h-4 w-4 mr-2" />
                      {batch.moistureContent}% moisture
                    </div>
                    <div className="flex items-center text-gray-600">
                      <Coins className="h-4 w-4 mr-2" />
                      ${batch.marketValue.toLocaleString()}
                    </div>
                  </div>

                  <div className="space-y-2">
                    <div className="flex items-center text-sm text-gray-600">
                      <MapPin className="h-4 w-4 mr-2" />
                      {batch.location}
                    </div>
                    <div className="flex items-center text-sm text-gray-600">
                      <Calendar className="h-4 w-4 mr-2" />
                      Harvested: {batch.harvestDate.toLocaleDateString()}
                    </div>
                  </div>

                  <div className="space-y-2">
                    <p className="text-sm font-medium">Quality Grade: {batch.qualityGrade}</p>
                    <p className="text-sm text-gray-600">Process: {batch.processMethod}</p>
                  </div>

                  {batch.certifications.length > 0 && (
                    <div className="flex flex-wrap gap-1">
                      {batch.certifications.map((cert, index) => (
                        <Badge key={index} variant="outline" className="text-xs">
                          {cert}
                        </Badge>
                      ))}
                    </div>
                  )}

                  <div className="flex space-x-2">
                    <Button variant="outline" size="sm" className="flex-1">
                      <Eye className="h-4 w-4 mr-2" />
                      Details
                    </Button>
                    {batch.type === "GREEN_BEANS" && batch.status === "active" && (
                      <Button 
                        size="sm" 
                        onClick={() => convertToRoasted(batch)}
                        className="bg-amber-600 hover:bg-amber-700"
                      >
                        <Coffee className="h-4 w-4 mr-2" />
                        Roast
                      </Button>
                    )}
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>

          {batches.length === 0 && (
            <Card>
              <CardContent className="text-center py-12">
                <Package className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                <h3 className="text-lg font-medium text-gray-900 mb-2">No Inventory Batches</h3>
                <p className="text-gray-600 mb-6">
                  Create your first coffee batch to start tokenizing your inventory.
                </p>
                <Button onClick={() => setActiveTab("tokenize")} className="bg-green-600 hover:bg-green-700">
                  <Plus className="mr-2 h-4 w-4" />
                  Create Batch
                </Button>
              </CardContent>
            </Card>
          )}
        </TabsContent>

        {/* Tokenize Tab */}
        <TabsContent value="tokenize" className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center">
                <Plus className="h-5 w-5 mr-2" />
                Create New Coffee Batch
              </CardTitle>
              <p className="text-sm text-gray-600">
                Tokenize a new batch of coffee beans on the blockchain
              </p>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-2">
                  <Label htmlFor="quantity">Quantity (kg) *</Label>
                  <Input
                    id="quantity"
                    type="number"
                    placeholder="1000"
                    value={newBatchData.quantity}
                    onChange={(e) => setNewBatchData(prev => ({ ...prev, quantity: e.target.value }))}
                  />
                </div>
                
                <div className="space-y-2">
                  <Label htmlFor="qualityGrade">Quality Grade *</Label>
                  <Select value={newBatchData.qualityGrade} onValueChange={(value: string) => setNewBatchData(prev => ({ ...prev, qualityGrade: value }))}>
                    <SelectTrigger>
                      <SelectValue placeholder="Select grade" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="Specialty">Specialty (80+ points)</SelectItem>
                      <SelectItem value="Premium">Premium (75-79 points)</SelectItem>
                      <SelectItem value="Exchange">Exchange (70-74 points)</SelectItem>
                      <SelectItem value="Standard">Standard (60-69 points)</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-2">
                  <Label htmlFor="harvestDate">Harvest Date *</Label>
                  <Input
                    id="harvestDate"
                    type="date"
                    value={newBatchData.harvestDate}
                    onChange={(e) => setNewBatchData(prev => ({ ...prev, harvestDate: e.target.value }))}
                  />
                </div>
                
                <div className="space-y-2">
                  <Label htmlFor="processMethod">Process Method *</Label>
                  <Select value={newBatchData.processMethod} onValueChange={(value: string) => setNewBatchData(prev => ({ ...prev, processMethod: value }))}>
                    <SelectTrigger>
                      <SelectValue placeholder="Select method" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="Washed">Washed</SelectItem>
                      <SelectItem value="Natural">Natural</SelectItem>
                      <SelectItem value="Honey">Honey</SelectItem>
                      <SelectItem value="Semi-Washed">Semi-Washed</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div className="space-y-2">
                  <Label htmlFor="moistureContent">Moisture Content (%) *</Label>
                  <Input
                    id="moistureContent"
                    type="number"
                    step="0.1"
                    placeholder="11.5"
                    value={newBatchData.moistureContent}
                    onChange={(e) => setNewBatchData(prev => ({ ...prev, moistureContent: e.target.value }))}
                  />
                </div>
                
                <div className="space-y-2">
                  <Label htmlFor="cupScore">Cup Score *</Label>
                  <Input
                    id="cupScore"
                    type="number"
                    step="0.1"
                    placeholder="84.5"
                    value={newBatchData.cupScore}
                    onChange={(e) => setNewBatchData(prev => ({ ...prev, cupScore: e.target.value }))}
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="location">Location *</Label>
                  <Input
                    id="location"
                    placeholder="Plot A, Farm Section"
                    value={newBatchData.location}
                    onChange={(e) => setNewBatchData(prev => ({ ...prev, location: e.target.value }))}
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="description">Batch Description</Label>
                <Textarea
                  id="description"
                  placeholder="Additional details about this coffee batch..."
                  value={newBatchData.description}
                  onChange={(e) => setNewBatchData(prev => ({ ...prev, description: e.target.value }))}
                />
              </div>

              <Alert>
                <CheckCircle className="h-4 w-4" />
                <AlertDescription>
                  Creating this batch will mint ERC-1155 tokens representing your coffee inventory on the blockchain.
                </AlertDescription>
              </Alert>

              <Button
                onClick={handleCreateBatch}
                disabled={!newBatchData.quantity || !newBatchData.qualityGrade || !newBatchData.harvestDate || isTokenizing}
                className="w-full bg-green-600 hover:bg-green-700"
              >
                {isTokenizing ? (
                  <>
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                    Tokenizing Batch...
                  </>
                ) : (
                  <>
                    <Coins className="mr-2 h-4 w-4" />
                    Create & Tokenize Batch
                  </>
                )}
              </Button>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Analytics Tab */}
        <TabsContent value="analytics" className="space-y-6">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <Card>
              <CardHeader>
                <CardTitle>Inventory Distribution</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="flex justify-between items-center">
                    <span className="text-sm">Green Beans</span>
                    <span className="font-medium">
                      {batches.filter(b => b.type === "GREEN_BEANS").reduce((sum, b) => sum + b.quantity, 0)} kg
                    </span>
                  </div>
                  <Progress 
                    value={(batches.filter(b => b.type === "GREEN_BEANS").reduce((sum, b) => sum + b.quantity, 0) / totalQuantity) * 100} 
                    className="h-2"
                  />
                  
                  <div className="flex justify-between items-center">
                    <span className="text-sm">Roasted Beans</span>
                    <span className="font-medium">
                      {batches.filter(b => b.type === "ROASTED_BEANS").reduce((sum, b) => sum + b.quantity, 0)} kg
                    </span>
                  </div>
                  <Progress 
                    value={(batches.filter(b => b.type === "ROASTED_BEANS").reduce((sum, b) => sum + b.quantity, 0) / totalQuantity) * 100} 
                    className="h-2"
                  />
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Quality Distribution</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {["Specialty", "Premium", "Exchange", "Standard"].map((grade) => {
                    const count = batches.filter(b => b.qualityGrade === grade).length
                    const percentage = batches.length > 0 ? (count / batches.length) * 100 : 0
                    return (
                      <div key={grade}>
                        <div className="flex justify-between items-center">
                          <span className="text-sm">{grade}</span>
                          <span className="font-medium">{count} batches</span>
                        </div>
                        <Progress value={percentage} className="h-2" />
                      </div>
                    )
                  })}
                </div>
              </CardContent>
            </Card>
          </div>

          <Card>
            <CardHeader>
              <CardTitle>Monthly Tokenization Trends</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-center py-8 text-gray-500">
                <TrendingUp className="h-12 w-12 mx-auto mb-4" />
                <p>Analytics charts will be available with more data</p>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  )
}
