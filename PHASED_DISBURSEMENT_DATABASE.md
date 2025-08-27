# Phased Disbursement System - Database Integration Requirements

## Overview
The phased disbursement system for greenfield projects requires database integration for storing and retrieving milestone evidence, validation records, and audit trails.

## Database Schema Requirements

### 1. **Milestone Evidence Table**
```sql
CREATE TABLE milestone_evidence (
    id BIGSERIAL PRIMARY KEY,
    grant_id BIGINT NOT NULL,
    milestone_index INTEGER NOT NULL,
    evidence_uri TEXT NOT NULL,
    evidence_type VARCHAR(50) NOT NULL, -- 'photo', 'document', 'video', 'report'
    file_hash VARCHAR(66), -- IPFS hash for content verification
    uploaded_by VARCHAR(42) NOT NULL, -- Ethereum address
    uploaded_at TIMESTAMP DEFAULT NOW(),
    description TEXT,
    metadata JSONB, -- Additional structured data
    UNIQUE(grant_id, milestone_index)
);
```

### 2. **Milestone Validations Table**
```sql
CREATE TABLE milestone_validations (
    id BIGSERIAL PRIMARY KEY,
    grant_id BIGINT NOT NULL,
    milestone_index INTEGER NOT NULL,
    validator_address VARCHAR(42) NOT NULL,
    validation_result BOOLEAN NOT NULL,
    validation_notes TEXT,
    validated_at TIMESTAMP DEFAULT NOW(),
    tx_hash VARCHAR(66), -- Transaction hash of on-chain validation
    block_number BIGINT
);
```

### 3. **Disbursement Audit Table**
```sql
CREATE TABLE disbursement_audit (
    id BIGSERIAL PRIMARY KEY,
    grant_id BIGINT NOT NULL,
    milestone_index INTEGER NOT NULL,
    amount_disbursed DECIMAL(20,6) NOT NULL,
    recipient_address VARCHAR(42) NOT NULL,
    disbursed_at TIMESTAMP DEFAULT NOW(),
    tx_hash VARCHAR(66) NOT NULL,
    block_number BIGINT NOT NULL,
    status VARCHAR(20) DEFAULT 'completed' -- 'pending', 'completed', 'failed'
);
```

### 4. **Grant Timeline Table**
```sql
CREATE TABLE grant_timeline (
    id BIGSERIAL PRIMARY KEY,
    grant_id BIGINT NOT NULL,
    event_type VARCHAR(50) NOT NULL, -- 'created', 'schedule_created', 'milestone_submitted', 'milestone_validated', 'disbursed'
    event_data JSONB,
    event_timestamp TIMESTAMP DEFAULT NOW(),
    tx_hash VARCHAR(66),
    block_number BIGINT
);
```

## Smart Contract Integration Points

### 1. **Evidence Submission Flow**
```solidity
// Current: Auto-approve workflow
function submitMilestoneEvidence(uint256 grantId, uint256 milestoneIndex, string memory evidenceUri) external {
    // Store evidence URI on-chain
    // Trigger database webhook to fetch and validate evidence
    // For now: auto-approve, but structure for external validation
}
```

### 2. **Database Webhook Integration**
```typescript
// Webhook endpoint: POST /api/milestone-evidence
interface MilestoneEvidenceWebhook {
    grantId: number;
    milestoneIndex: number;
    evidenceUri: string;
    cooperativeAddress: string;
    timestamp: number;
    blockNumber: number;
    txHash: string;
}
```

### 3. **Validation Workflow**
```typescript
// Validation service endpoint: POST /api/validate-milestone
interface ValidationRequest {
    grantId: number;
    milestoneIndex: number;
    evidenceId: number;
    validatorAddress: string;
    approved: boolean;
    notes?: string;
}
```

## API Endpoints for Database Integration

### 1. **Evidence Management**
```typescript
// Store evidence metadata
POST /api/evidence
{
    "grantId": 1,
    "milestoneIndex": 0,
    "evidenceUri": "ipfs://QmHash...",
    "evidenceType": "photo",
    "description": "Land preparation photos",
    "metadata": {
        "gpsCoordinates": "lat,lng",
        "timestamp": "2025-08-27T10:00:00Z",
        "photographer": "field_agent_001"
    }
}

// Retrieve evidence for milestone
GET /api/evidence/{grantId}/{milestoneIndex}
```

### 2. **Validation Tracking**
```typescript
// Record validation decision
POST /api/validations
{
    "grantId": 1,
    "milestoneIndex": 0,
    "approved": true,
    "validatorAddress": "0x...",
    "notes": "Land cleared and prepared according to specifications"
}

// Get validation history
GET /api/validations/{grantId}
```

### 3. **Audit and Reporting**
```typescript
// Get complete grant timeline
GET /api/grants/{grantId}/timeline

// Get disbursement history
GET /api/disbursements/{grantId}

// Generate compliance report
GET /api/compliance-report/{grantId}
```

## Enhanced Smart Contract Functions (Future Implementation)

### 1. **External Validation Integration**
```solidity
// Oracle-based validation for production
contract MilestoneValidator {
    mapping(uint256 => mapping(uint256 => ValidationRequest)) public pendingValidations;
    
    function submitForValidation(uint256 grantId, uint256 milestoneIndex, string memory evidenceUri) external {
        // Store validation request
        // Emit event for off-chain validation service
        // Wait for oracle response
    }
    
    function oracleValidateCallback(uint256 grantId, uint256 milestoneIndex, bool approved, string memory notes) external onlyOracle {
        // Process oracle validation response
        // Trigger automatic disbursement if approved
    }
}
```

### 2. **Multi-Validator Consensus**
```solidity
struct ValidationConsensus {
    address[] validators;
    bool[] votes;
    uint256 threshold; // Minimum votes required
    bool finalized;
}

mapping(uint256 => mapping(uint256 => ValidationConsensus)) public consensusValidations;
```

## IPFS Integration

### 1. **Evidence Storage**
```typescript
// IPFS storage structure
interface IPFSEvidence {
    milestone: {
        grantId: number;
        milestoneIndex: number;
        description: string;
    };
    evidence: {
        type: 'photo' | 'document' | 'video' | 'report';
        files: Array<{
            filename: string;
            hash: string;
            size: number;
            mimeType: string;
        }>;
    };
    metadata: {
        timestamp: string;
        location?: {
            latitude: number;
            longitude: number;
        };
        weather?: object;
        equipment?: string[];
    };
    signatures: {
        cooperative: string; // Digital signature
        fieldAgent?: string;
        witnesses?: string[];
    };
}
```

## Security Considerations

### 1. **Evidence Integrity**
- Store IPFS hashes on-chain for immutability
- Implement content verification through file hashing
- Digital signatures for evidence authenticity

### 2. **Validator Authorization**
- Role-based access control for validators
- Multi-signature validation for large disbursements
- Audit trail for all validation decisions

### 3. **Database Security**
- Encrypted storage for sensitive data
- Access logging and monitoring
- Regular backup and disaster recovery

## Implementation Phases

### Phase 1: Basic Integration (Current)
- ✅ Smart contract infrastructure
- ✅ Auto-approval workflow
- ✅ On-chain event emission

### Phase 2: Database Integration
- 📝 Database schema implementation
- 📝 Webhook integration for event capture
- 📝 Basic API endpoints

### Phase 3: Advanced Validation
- 📝 Multi-validator consensus mechanism
- 📝 Oracle integration for external validation
- 📝 ML-based evidence analysis

### Phase 4: Full Automation
- 📝 AI-powered milestone verification
- 📝 IoT sensor integration
- 📝 Satellite imagery validation

## Monitoring and Analytics

### 1. **Key Metrics**
- Average time from evidence submission to validation
- Validation approval rates by milestone type
- Disbursement velocity and patterns
- Cooperative compliance scores

### 2. **Dashboard Requirements**
- Real-time milestone progress tracking
- Validation queue management
- Disbursement analytics
- Risk assessment indicators

This database integration will provide the foundation for scalable, auditable, and efficient phased disbursement management for greenfield coffee projects.
