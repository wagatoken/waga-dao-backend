-- WAGA DAO Coffee Tokenization Database Schema
-- Following WAGA_MVP_V2 hybrid blockchain + database pattern
-- Rich metadata stored off-chain, essential data on-chain

-- ============================================================================
-- BATCH MANAGEMENT (Core blockchain-first entities)
-- ============================================================================

-- Main batch table - mirrors minimal on-chain data
CREATE TABLE coffee_batches (
    batch_id BIGINT PRIMARY KEY,           -- Blockchain-generated ID
    production_date TIMESTAMP NOT NULL,
    expiry_date TIMESTAMP NOT NULL,
    quantity_kg DECIMAL(10,2) NOT NULL,
    price_per_kg DECIMAL(10,2) NOT NULL,
    grant_value_usd DECIMAL(12,2) NOT NULL,
    ipfs_hash VARCHAR(255),                -- IPFS metadata reference
    
    -- Blockchain tracking
    blockchain_network VARCHAR(50) NOT NULL DEFAULT 'arbitrum',
    transaction_hash VARCHAR(66),          -- Creation tx hash
    block_number BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Status tracking
    token_type VARCHAR(20) DEFAULT 'GREEN_BEANS', -- GREEN_BEANS | ROASTED_BEANS
    is_verified BOOLEAN DEFAULT FALSE,
    verification_date TIMESTAMP,
    
    CONSTRAINT chk_quantity_positive CHECK (quantity_kg > 0),
    CONSTRAINT chk_price_positive CHECK (price_per_kg > 0),
    CONSTRAINT chk_dates_valid CHECK (expiry_date > production_date)
);

-- Rich batch metadata - extensive off-chain data
CREATE TABLE batch_metadata (
    batch_id BIGINT PRIMARY KEY REFERENCES coffee_batches(batch_id),
    
    -- Production details
    processing_method VARCHAR(100),        -- Washed, Natural, Honey, etc.
    drying_method VARCHAR(100),
    fermentation_time_hours INTEGER,
    moisture_content_percent DECIMAL(4,2),
    
    -- Quality metrics
    quality_score INTEGER CHECK (quality_score BETWEEN 0 AND 100),
    cupping_score DECIMAL(4,2),
    defect_count INTEGER DEFAULT 0,
    screen_size VARCHAR(20),
    
    -- Sustainability & Social Impact
    sustainability_practices TEXT,
    fair_trade_certified BOOLEAN DEFAULT FALSE,
    organic_certified BOOLEAN DEFAULT FALSE,
    rainforest_alliance_certified BOOLEAN DEFAULT FALSE,
    
    -- Traceability
    harvest_season VARCHAR(50),
    altitude_meters INTEGER,
    varietal VARCHAR(100),
    lot_number VARCHAR(50),
    
    -- Additional metadata
    storage_conditions TEXT,
    packaging_type VARCHAR(100),
    notes TEXT,
    
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- COOPERATIVE MANAGEMENT
-- ============================================================================

-- Cooperative registry - rich off-chain data
CREATE TABLE cooperatives (
    cooperative_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    country VARCHAR(100) NOT NULL,
    region VARCHAR(100),
    
    -- Contact information
    contact_person VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    website VARCHAR(255),
    
    -- Legal & organizational
    legal_status VARCHAR(100),
    established_year INTEGER,
    registration_number VARCHAR(100),
    
    -- Blockchain integration
    payment_address VARCHAR(42),           -- Ethereum address
    
    -- Operational details
    farmers_count INTEGER DEFAULT 0,
    total_farm_area_hectares DECIMAL(10,2),
    primary_crops TEXT DEFAULT 'Coffee',
    
    -- Certifications
    certifications TEXT[],                 -- Array of certification names
    
    -- Verification
    is_verified BOOLEAN DEFAULT FALSE,
    verification_date TIMESTAMP,
    verified_by VARCHAR(255),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Link batches to cooperatives
CREATE TABLE batch_cooperatives (
    batch_id BIGINT REFERENCES coffee_batches(batch_id),
    cooperative_id INTEGER REFERENCES cooperatives(cooperative_id),
    is_primary_producer BOOLEAN DEFAULT TRUE,
    contribution_percentage DECIMAL(5,2) DEFAULT 100.00,
    
    PRIMARY KEY (batch_id, cooperative_id)
);

-- ============================================================================
-- ROASTING & VALUE CHAIN PROGRESSION
-- ============================================================================

-- Roasting records - tracks GREEN_BEANS -> ROASTED_BEANS conversion
CREATE TABLE roasting_records (
    roasting_id SERIAL PRIMARY KEY,
    green_batch_id BIGINT REFERENCES coffee_batches(batch_id),
    roasted_batch_id BIGINT REFERENCES coffee_batches(batch_id),
    
    -- Roasting details
    roasting_date TIMESTAMP NOT NULL,
    roaster_name VARCHAR(255),
    roaster_address VARCHAR(42),           -- Ethereum address
    
    -- Conversion metrics
    green_beans_input_kg DECIMAL(10,2) NOT NULL,
    roasted_beans_output_kg DECIMAL(10,2) NOT NULL,
    weight_loss_percentage DECIMAL(5,2) GENERATED ALWAYS AS 
        ((green_beans_input_kg - roasted_beans_output_kg) / green_beans_input_kg * 100) STORED,
    
    -- Roasting profile
    roast_profile VARCHAR(100),            -- Light, Medium, Dark, etc.
    roasting_time_minutes INTEGER,
    max_temperature_celsius INTEGER,
    
    -- Quality post-roasting
    post_roast_quality_score INTEGER CHECK (post_roast_quality_score BETWEEN 0 AND 100),
    aroma_notes TEXT,
    flavor_profile TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- PRICING & MARKET DATA
-- ============================================================================

-- Coffee commodity pricing - Yahoo Finance API integration
CREATE TABLE commodity_prices (
    price_id SERIAL PRIMARY KEY,
    date DATE NOT NULL,
    
    -- Yahoo Finance coffee futures data
    coffee_futures_price_usd DECIMAL(10,4) NOT NULL,  -- $/lb
    currency VARCHAR(3) DEFAULT 'USD',
    
    -- WAGA specific pricing
    waga_base_price_usd DECIMAL(10,4) NOT NULL,       -- Commodity + premium
    premium_percentage DECIMAL(5,2) DEFAULT 10.00,    -- 10% fair trade premium
    
    -- Market context
    market_volatility_index DECIMAL(8,4),
    trading_volume BIGINT,
    
    -- Data source tracking
    data_source VARCHAR(100) DEFAULT 'Yahoo Finance',
    api_response_json JSONB,               -- Store full API response
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(date, currency)
);

-- Price history for individual batches
CREATE TABLE batch_pricing_history (
    pricing_id SERIAL PRIMARY KEY,
    batch_id BIGINT REFERENCES coffee_batches(batch_id),
    
    -- Pricing event
    event_type VARCHAR(50) NOT NULL,       -- CREATION, ROASTING, SALE, MARKET_UPDATE
    event_date TIMESTAMP NOT NULL,
    
    -- Pricing details
    base_commodity_price DECIMAL(10,4),
    premium_amount DECIMAL(10,4),
    total_price_per_kg DECIMAL(10,4) NOT NULL,
    
    -- Context
    quantity_kg DECIMAL(10,2),
    total_value_usd DECIMAL(12,2),
    
    -- Audit trail
    updated_by VARCHAR(255),
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- GRANT MANAGEMENT (Replacing Loan System)
-- ============================================================================

-- Grant records - cooperative financing
CREATE TABLE cooperative_grants (
    grant_id SERIAL PRIMARY KEY,
    cooperative_id INTEGER REFERENCES cooperatives(cooperative_id),
    
    -- Grant details
    grant_amount_usd DECIMAL(12,2) NOT NULL,
    grant_date DATE NOT NULL,
    grant_purpose TEXT,
    
    -- Disbursement type
    uses_phased_disbursement BOOLEAN DEFAULT false,
    
    -- Revenue sharing terms
    revenue_sharing_percentage DECIMAL(5,2) DEFAULT 10.00,  -- 10% of coffee sales
    repayment_cap_multiplier DECIMAL(4,2) DEFAULT 2.0,      -- 2x grant amount max
    
    -- Status tracking
    status VARCHAR(50) DEFAULT 'ACTIVE',   -- ACTIVE, COMPLETED, DEFAULTED
    total_revenue_shared DECIMAL(12,2) DEFAULT 0,
    remaining_obligation DECIMAL(12,2) GENERATED ALWAYS AS 
        (GREATEST(0, grant_amount_usd * repayment_cap_multiplier - total_revenue_shared)) STORED,
    
    -- Blockchain integration
    grant_transaction_hash VARCHAR(66),
    blockchain_network VARCHAR(50) DEFAULT 'arbitrum',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Revenue sharing payments
CREATE TABLE grant_revenue_payments (
    payment_id SERIAL PRIMARY KEY,
    grant_id INTEGER REFERENCES cooperative_grants(grant_id),
    batch_id BIGINT REFERENCES coffee_batches(batch_id),
    
    -- Payment details
    payment_date DATE NOT NULL,
    coffee_sale_amount DECIMAL(12,2) NOT NULL,
    revenue_share_percentage DECIMAL(5,2) NOT NULL,
    payment_amount DECIMAL(12,2) GENERATED ALWAYS AS 
        (coffee_sale_amount * revenue_share_percentage / 100) STORED,
    
    -- Blockchain tracking
    payment_transaction_hash VARCHAR(66),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- IPFS & METADATA MANAGEMENT
-- ============================================================================

-- IPFS content tracking
CREATE TABLE ipfs_metadata (
    ipfs_hash VARCHAR(255) PRIMARY KEY,
    batch_id BIGINT REFERENCES coffee_batches(batch_id),
    
    -- Content details
    content_type VARCHAR(100),             -- metadata, images, certificates
    file_size_bytes BIGINT,
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Metadata content (JSON)
    metadata_json JSONB,
    
    -- Verification
    is_verified BOOLEAN DEFAULT FALSE,
    verification_date TIMESTAMP,
    
    -- Access tracking
    access_count INTEGER DEFAULT 0,
    last_accessed TIMESTAMP
);

-- ============================================================================
-- INDEXING FOR PERFORMANCE
-- ============================================================================

-- Batch lookups
CREATE INDEX idx_coffee_batches_type ON coffee_batches(token_type);
CREATE INDEX idx_coffee_batches_created ON coffee_batches(created_at);
CREATE INDEX idx_coffee_batches_expiry ON coffee_batches(expiry_date);

-- Cooperative lookups
CREATE INDEX idx_cooperatives_country ON cooperatives(country);
CREATE INDEX idx_cooperatives_verified ON cooperatives(is_verified);

-- Pricing lookups
CREATE INDEX idx_commodity_prices_date ON commodity_prices(date);
CREATE INDEX idx_batch_pricing_batch ON batch_pricing_history(batch_id);
CREATE INDEX idx_batch_pricing_event ON batch_pricing_history(event_type, event_date);

-- Grant lookups
CREATE INDEX idx_grants_cooperative ON cooperative_grants(cooperative_id);
CREATE INDEX idx_grants_status ON cooperative_grants(status);
CREATE INDEX idx_grants_phased_disbursement ON cooperative_grants(uses_phased_disbursement) WHERE uses_phased_disbursement = true;

-- IPFS lookups
CREATE INDEX idx_ipfs_batch ON ipfs_metadata(batch_id);
CREATE INDEX idx_ipfs_type ON ipfs_metadata(content_type);

-- ============================================================================
-- VIEWS FOR COMMON QUERIES
-- ============================================================================

-- Complete batch information with cooperative data
CREATE VIEW batch_full_info AS
SELECT 
    cb.batch_id,
    cb.production_date,
    cb.expiry_date,
    cb.quantity_kg,
    cb.price_per_kg,
    cb.grant_value_usd,
    cb.token_type,
    cb.is_verified,
    
    -- Metadata
    bm.quality_score,
    bm.processing_method,
    bm.sustainability_practices,
    
    -- Cooperative info
    c.name as cooperative_name,
    c.location,
    c.country,
    c.farmers_count,
    c.certifications,
    
    -- Latest pricing
    (SELECT total_price_per_kg FROM batch_pricing_history 
     WHERE batch_id = cb.batch_id 
     ORDER BY event_date DESC LIMIT 1) as current_price_per_kg
     
FROM coffee_batches cb
LEFT JOIN batch_metadata bm ON cb.batch_id = bm.batch_id
LEFT JOIN batch_cooperatives bc ON cb.batch_id = bc.batch_id AND bc.is_primary_producer = true
LEFT JOIN cooperatives c ON bc.cooperative_id = c.cooperative_id;

-- Grant performance summary
CREATE VIEW grant_performance AS
SELECT 
    cg.grant_id,
    cg.cooperative_id,
    c.name as cooperative_name,
    cg.grant_amount_usd,
    cg.revenue_sharing_percentage,
    cg.total_revenue_shared,
    cg.remaining_obligation,
    cg.status,
    
    -- Performance metrics
    (cg.total_revenue_shared / cg.grant_amount_usd * 100) as repayment_percentage,
    (SELECT COUNT(*) FROM grant_revenue_payments WHERE grant_id = cg.grant_id) as payment_count,
    (SELECT MAX(payment_date) FROM grant_revenue_payments WHERE grant_id = cg.grant_id) as last_payment_date
    
FROM cooperative_grants cg
JOIN cooperatives c ON cg.cooperative_id = c.cooperative_id;

-- Market pricing trends
CREATE VIEW pricing_trends AS
SELECT 
    date,
    coffee_futures_price_usd,
    waga_base_price_usd,
    premium_percentage,
    (waga_base_price_usd - coffee_futures_price_usd) as premium_amount,
    
    -- Price changes
    LAG(coffee_futures_price_usd, 1) OVER (ORDER BY date) as prev_futures_price,
    (coffee_futures_price_usd - LAG(coffee_futures_price_usd, 1) OVER (ORDER BY date)) / 
        LAG(coffee_futures_price_usd, 1) OVER (ORDER BY date) * 100 as futures_change_percent
        
FROM commodity_prices
ORDER BY date DESC;

-- ============================================================================
-- PHASED DISBURSEMENT SYSTEM
-- ============================================================================

-- Disbursement Schedules Table
CREATE TABLE disbursement_schedules (
    schedule_id SERIAL PRIMARY KEY,
    grant_id INTEGER NOT NULL REFERENCES cooperative_grants(grant_id) ON DELETE CASCADE,
    total_milestones INTEGER NOT NULL CHECK (total_milestones > 0),
    completed_milestones INTEGER DEFAULT 0 CHECK (completed_milestones >= 0),
    is_active BOOLEAN DEFAULT true,
    escrowed_amount DECIMAL(18,6) NOT NULL CHECK (escrowed_amount >= 0),
    blockchain_tx_hash VARCHAR(66),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_completed_milestones_valid CHECK (completed_milestones <= total_milestones),
    CONSTRAINT uq_disbursement_schedules_grant_id UNIQUE (grant_id)
);

-- Milestones Table
CREATE TABLE milestones (
    milestone_id SERIAL PRIMARY KEY,
    schedule_id INTEGER NOT NULL REFERENCES disbursement_schedules(schedule_id) ON DELETE CASCADE,
    milestone_index INTEGER NOT NULL CHECK (milestone_index >= 0),
    description TEXT NOT NULL,
    percentage_share INTEGER NOT NULL CHECK (percentage_share > 0 AND percentage_share <= 10000), -- basis points (0-10000)
    is_completed BOOLEAN DEFAULT false,
    evidence_uri TEXT,
    completed_timestamp TIMESTAMP,
    validator_address VARCHAR(42),
    disbursed_amount DECIMAL(18,6) DEFAULT 0 CHECK (disbursed_amount >= 0),
    blockchain_tx_hash VARCHAR(66),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT uq_milestones_schedule_index UNIQUE (schedule_id, milestone_index)
);

-- Milestone Evidence Table
CREATE TABLE milestone_evidence (
    evidence_id SERIAL PRIMARY KEY,
    milestone_id INTEGER NOT NULL REFERENCES milestones(milestone_id) ON DELETE CASCADE,
    evidence_type VARCHAR(50) NOT NULL, -- 'document', 'image', 'video', 'report', 'ipfs', etc.
    evidence_uri TEXT NOT NULL,
    evidence_hash VARCHAR(66), -- IPFS hash or file hash for integrity
    description TEXT,
    submitted_by VARCHAR(42) NOT NULL, -- Ethereum address
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    validation_status VARCHAR(20) DEFAULT 'pending' CHECK (validation_status IN ('pending', 'approved', 'rejected')),
    validated_by VARCHAR(42), -- Validator address
    validated_at TIMESTAMP,
    validation_notes TEXT,
    blockchain_tx_hash VARCHAR(66),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Disbursement History Table
CREATE TABLE disbursement_history (
    disbursement_id SERIAL PRIMARY KEY,
    grant_id INTEGER NOT NULL REFERENCES cooperative_grants(grant_id) ON DELETE CASCADE,
    milestone_id INTEGER REFERENCES milestones(milestone_id) ON DELETE SET NULL,
    disbursement_type VARCHAR(20) NOT NULL CHECK (disbursement_type IN ('initial', 'milestone', 'final', 'emergency')),
    amount DECIMAL(18,6) NOT NULL CHECK (amount > 0),
    recipient_address VARCHAR(42) NOT NULL,
    disbursed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    blockchain_tx_hash VARCHAR(66) NOT NULL,
    gas_used BIGINT,
    gas_price DECIMAL(18,0),
    block_number BIGINT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Escrow Management Table
CREATE TABLE escrow_balances (
    escrow_id SERIAL PRIMARY KEY,
    grant_id INTEGER NOT NULL REFERENCES cooperative_grants(grant_id) ON DELETE CASCADE,
    total_escrowed DECIMAL(18,6) NOT NULL CHECK (total_escrowed >= 0),
    total_disbursed DECIMAL(18,6) DEFAULT 0 CHECK (total_disbursed >= 0),
    remaining_balance DECIMAL(18,6) GENERATED ALWAYS AS (total_escrowed - total_disbursed) STORED,
    last_transaction_hash VARCHAR(66),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT uq_escrow_balances_grant_id UNIQUE (grant_id),
    CONSTRAINT chk_disbursed_not_exceed_escrowed CHECK (total_disbursed <= total_escrowed)
);

-- ============================================================================
-- PHASED DISBURSEMENT INDEXES
-- ============================================================================

-- Disbursement Schedules Indexes
CREATE INDEX idx_disbursement_schedules_grant_id ON disbursement_schedules(grant_id);
CREATE INDEX idx_disbursement_schedules_active ON disbursement_schedules(is_active) WHERE is_active = true;
CREATE INDEX idx_disbursement_schedules_tx_hash ON disbursement_schedules(blockchain_tx_hash) WHERE blockchain_tx_hash IS NOT NULL;

-- Milestones Indexes
CREATE INDEX idx_milestones_schedule_id ON milestones(schedule_id);
CREATE INDEX idx_milestones_index ON milestones(milestone_index);
CREATE INDEX idx_milestones_completed ON milestones(is_completed);
CREATE INDEX idx_milestones_validator ON milestones(validator_address) WHERE validator_address IS NOT NULL;
CREATE INDEX idx_milestones_tx_hash ON milestones(blockchain_tx_hash) WHERE blockchain_tx_hash IS NOT NULL;

-- Milestone Evidence Indexes
CREATE INDEX idx_milestone_evidence_milestone_id ON milestone_evidence(milestone_id);
CREATE INDEX idx_milestone_evidence_submitted_by ON milestone_evidence(submitted_by);
CREATE INDEX idx_milestone_evidence_validation_status ON milestone_evidence(validation_status);
CREATE INDEX idx_milestone_evidence_validated_by ON milestone_evidence(validated_by) WHERE validated_by IS NOT NULL;
CREATE INDEX idx_milestone_evidence_submitted_at ON milestone_evidence(submitted_at);
CREATE INDEX idx_milestone_evidence_tx_hash ON milestone_evidence(blockchain_tx_hash) WHERE blockchain_tx_hash IS NOT NULL;

-- Disbursement History Indexes
CREATE INDEX idx_disbursement_history_grant_id ON disbursement_history(grant_id);
CREATE INDEX idx_disbursement_history_milestone_id ON disbursement_history(milestone_id) WHERE milestone_id IS NOT NULL;
CREATE INDEX idx_disbursement_history_type ON disbursement_history(disbursement_type);
CREATE INDEX idx_disbursement_history_recipient ON disbursement_history(recipient_address);
CREATE INDEX idx_disbursement_history_disbursed_at ON disbursement_history(disbursed_at);
CREATE INDEX idx_disbursement_history_tx_hash ON disbursement_history(blockchain_tx_hash);
CREATE INDEX idx_disbursement_history_block_number ON disbursement_history(block_number) WHERE block_number IS NOT NULL;

-- Escrow Balances Indexes
CREATE INDEX idx_escrow_balances_grant_id ON escrow_balances(grant_id);
CREATE INDEX idx_escrow_balances_last_updated ON escrow_balances(last_updated);
CREATE INDEX idx_escrow_balances_tx_hash ON escrow_balances(last_transaction_hash) WHERE last_transaction_hash IS NOT NULL;

-- ============================================================================
-- PHASED DISBURSEMENT VIEWS
-- ============================================================================

-- Comprehensive Grant Status with Phased Disbursement
CREATE VIEW grant_disbursement_status AS
SELECT 
    cg.grant_id,
    cg.cooperative_id,
    c.name as cooperative_name,
    cg.grant_amount_usd,
    cg.status as grant_status,
    
    -- Disbursement Schedule Info
    ds.schedule_id,
    ds.total_milestones,
    ds.completed_milestones,
    ds.is_active as schedule_active,
    ds.escrowed_amount,
    
    -- Escrow Balance Info
    eb.total_escrowed,
    eb.total_disbursed,
    eb.remaining_balance,
    
    -- Progress Metrics
    CASE 
        WHEN ds.total_milestones > 0 THEN 
            ROUND((ds.completed_milestones::DECIMAL / ds.total_milestones::DECIMAL * 100), 2)
        ELSE 0 
    END as milestone_completion_percentage,
    
    CASE 
        WHEN eb.total_escrowed > 0 THEN 
            ROUND((eb.total_disbursed / eb.total_escrowed * 100), 2)
        ELSE 0 
    END as disbursement_percentage
    
FROM cooperative_grants cg
JOIN cooperatives c ON cg.cooperative_id = c.cooperative_id
LEFT JOIN disbursement_schedules ds ON cg.grant_id = ds.grant_id
LEFT JOIN escrow_balances eb ON cg.grant_id = eb.grant_id;

-- Milestone Progress View
CREATE VIEW milestone_progress AS
SELECT 
    m.milestone_id,
    m.schedule_id,
    ds.grant_id,
    cg.cooperative_id,
    c.name as cooperative_name,
    m.milestone_index,
    m.description,
    m.percentage_share,
    m.is_completed,
    m.evidence_uri,
    m.completed_timestamp,
    m.validator_address,
    m.disbursed_amount,
    
    -- Evidence Summary
    (SELECT COUNT(*) FROM milestone_evidence WHERE milestone_id = m.milestone_id) as evidence_count,
    (SELECT COUNT(*) FROM milestone_evidence WHERE milestone_id = m.milestone_id AND validation_status = 'approved') as approved_evidence_count,
    (SELECT COUNT(*) FROM milestone_evidence WHERE milestone_id = m.milestone_id AND validation_status = 'pending') as pending_evidence_count,
    
    -- Calculated disbursement amount based on percentage
    ROUND((m.percentage_share::DECIMAL / 10000::DECIMAL) * ds.escrowed_amount, 6) as calculated_disbursement_amount
    
FROM milestones m
JOIN disbursement_schedules ds ON m.schedule_id = ds.schedule_id
JOIN cooperative_grants cg ON ds.grant_id = cg.grant_id
JOIN cooperatives c ON cg.cooperative_id = c.cooperative_id
ORDER BY ds.grant_id, m.milestone_index;

-- Evidence Validation Summary
CREATE VIEW evidence_validation_summary AS
SELECT 
    me.evidence_id,
    me.milestone_id,
    m.milestone_index,
    ds.grant_id,
    c.name as cooperative_name,
    me.evidence_type,
    me.evidence_uri,
    me.description,
    me.submitted_by,
    me.submitted_at,
    me.validation_status,
    me.validated_by,
    me.validated_at,
    me.validation_notes,
    
    -- Time metrics
    EXTRACT(EPOCH FROM (COALESCE(me.validated_at, CURRENT_TIMESTAMP) - me.submitted_at))/3600 as hours_since_submission
    
FROM milestone_evidence me
JOIN milestones m ON me.milestone_id = m.milestone_id
JOIN disbursement_schedules ds ON m.schedule_id = ds.schedule_id
JOIN cooperative_grants cg ON ds.grant_id = cg.grant_id
JOIN cooperatives c ON cg.cooperative_id = c.cooperative_id
ORDER BY me.submitted_at DESC;

-- ============================================================================
-- ZK-PROOF SYSTEM INTEGRATION (UPDATED FOR NEW ARCHITECTURE)
-- ============================================================================
-- 
-- ARCHITECTURAL CHANGES FROM V1 TO V2:
-- 
-- V1 (Previous): Stored only IPFS URIs for proof data and public inputs
-- V2 (Current):  Stores actual proof data and public inputs as BYTEA
-- 
-- BENEFITS OF NEW ARCHITECTURE:
-- 1. Data Integrity: Can verify public inputs hash matches actual data
-- 2. Performance: No need to fetch from IPFS for verification
-- 3. Reliability: Data available even if IPFS is down
-- 4. Security: On-chain verification can use actual data directly
-- 
-- DATA STORAGE STRATEGY:
-- - proof_data: Raw proof bytes (RISC Zero or Circom format)
-- - public_inputs: Actual public inputs bytes
-- - public_inputs_hash: SHA256 hash for integrity verification
-- - metadata_uri: Optional IPFS URI for rich metadata (descriptions, etc.)
--

-- Main ZK Proof Registry (UPDATED: Now stores actual data, not just IPFS URIs)
CREATE TABLE zk_proofs (
    proof_hash VARCHAR(66) PRIMARY KEY,           -- Unique proof identifier (matches smart contract)
    proof_type VARCHAR(20) NOT NULL CHECK (proof_type IN ('RISC_ZERO', 'CIRCOM')),
    
    -- Proof Data (ACTUAL DATA STORAGE, not just IPFS references)
    proof_data BYTEA NOT NULL,                    -- Raw proof data (actual bytes)
    public_inputs BYTEA NOT NULL,                 -- Actual public inputs (actual bytes)
    public_inputs_hash VARCHAR(66) NOT NULL,      -- Hash of public inputs for integrity verification
    
    -- Metadata (still IPFS for rich metadata)
    metadata_uri TEXT,                            -- IPFS URI for additional proof metadata (optional)
    
    -- Proof Metadata
    proof_name VARCHAR(255) NOT NULL,             -- Human-readable proof name
    description TEXT,                             -- Proof description
    version VARCHAR(50) NOT NULL,                 -- Proof version
    circuit_hash VARCHAR(66) NOT NULL,            -- Hash of the circuit/program
    
    -- Submission Details
    submitter_address VARCHAR(42) NOT NULL,       -- Ethereum address of submitter
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Verification Status
    verification_status VARCHAR(20) DEFAULT 'PENDING' CHECK (verification_status IN ('PENDING', 'VERIFIED', 'REJECTED', 'EXPIRED')),
    verified_at TIMESTAMP,
    verified_by VARCHAR(42),                      -- Validator address
    verification_reason TEXT,                     -- Success/failure reason
    gas_used BIGINT,                             -- Gas used for verification
    
    -- Expiry Management
    expiry_timestamp TIMESTAMP NOT NULL,          -- When proof expires
    is_expired BOOLEAN DEFAULT FALSE,
    
    -- Blockchain Integration
    blockchain_tx_hash VARCHAR(66),               -- Transaction hash
    block_number BIGINT,                         -- Block number
    network VARCHAR(50) DEFAULT 'base',           -- Network where proof was submitted
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ZK Proof Metadata (Matches Smart Contract ProofMetadata struct)
CREATE TABLE zk_proof_metadata (
    proof_hash VARCHAR(66) PRIMARY KEY REFERENCES zk_proofs(proof_hash) ON DELETE CASCADE,
    
    -- Proof Metadata (matches smart contract ProofMetadata struct)
    proof_name VARCHAR(255) NOT NULL,             -- Human-readable proof name
    description TEXT,                             -- Proof description
    version VARCHAR(50) NOT NULL,                 -- Proof version
    circuit_hash VARCHAR(66) NOT NULL,            -- Hash of the circuit/program
    max_gas_limit BIGINT NOT NULL,                -- Maximum gas for verification
    
    -- Additional metadata
    metadata_uri TEXT,                            -- IPFS URI for additional rich metadata (optional)
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ZK Proof Types and Use Cases
CREATE TABLE zk_proof_use_cases (
    use_case_id SERIAL PRIMARY KEY,
    proof_hash VARCHAR(66) REFERENCES zk_proofs(proof_hash) ON DELETE CASCADE,
    
    -- Use Case Classification
    use_case_type VARCHAR(50) NOT NULL,           -- 'MILESTONE_VALIDATION', 'COFFEE_QUALITY', 'IDENTITY_VERIFICATION', etc.
    use_case_subtype VARCHAR(100),                -- More specific classification
    
    -- Related Entity References
    grant_id INTEGER REFERENCES cooperative_grants(grant_id) ON DELETE SET NULL,
    milestone_id INTEGER REFERENCES milestones(milestone_id) ON DELETE SET NULL,
    batch_id BIGINT REFERENCES coffee_batches(batch_id) ON DELETE SET NULL,
    cooperative_id INTEGER REFERENCES cooperatives(cooperative_id) ON DELETE SET NULL,
    
    -- Use Case Specific Data
    use_case_data JSONB,                         -- Flexible storage for use case specific information
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- RISC Zero Specific Data
CREATE TABLE risc_zero_proofs (
    proof_hash VARCHAR(66) PRIMARY KEY REFERENCES zk_proofs(proof_hash) ON DELETE CASCADE,
    
    -- RISC Zero Specific Fields
    program_hash VARCHAR(66) NOT NULL,            -- Hash of the RISC Zero program
    image_id VARCHAR(66) NOT NULL,                -- RISC Zero image ID
    journal_hash VARCHAR(66) NOT NULL,            -- Hash of the execution journal
    
    -- Performance Metrics
    proof_generation_time_ms INTEGER,             -- Time to generate proof in milliseconds
    proof_size_bytes BIGINT,                     -- Size of the proof in bytes
    verification_time_ms INTEGER,                 -- Time to verify proof in milliseconds
    
    -- Circuit Information
    circuit_name VARCHAR(255),                    -- Name of the circuit
    circuit_version VARCHAR(50),                  -- Version of the circuit
    circuit_parameters JSONB,                     -- Circuit-specific parameters
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Circom Specific Data
CREATE TABLE circom_proofs (
    proof_hash VARCHAR(66) PRIMARY KEY REFERENCES zk_proofs(proof_hash) ON DELETE CASCADE,
    
    -- Circom Specific Fields
    circuit_name VARCHAR(255) NOT NULL,           -- Name of the Circom circuit
    circuit_version VARCHAR(50) NOT NULL,         -- Version of the circuit
    proving_key_hash VARCHAR(66) NOT NULL,        -- Hash of the proving key
    verification_key_hash VARCHAR(66) NOT NULL,   -- Hash of the verification key
    
    -- Proof Format
    proof_format VARCHAR(20) DEFAULT 'GROTH16',   -- Proof format (GROTH16, PLONK, etc.)
    proof_components JSONB,                       -- Proof components (A, B, C for Groth16)
    
    -- Circuit Constraints
    constraint_count INTEGER,                     -- Number of constraints in circuit
    wire_count INTEGER,                           -- Number of wires in circuit
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Proof Verification History
CREATE TABLE proof_verification_history (
    verification_id SERIAL PRIMARY KEY,
    proof_hash VARCHAR(66) REFERENCES zk_proofs(proof_hash) ON DELETE CASCADE,
    
    -- Verification Details
    verification_attempt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    verifier_address VARCHAR(42) NOT NULL,        -- Address that attempted verification
    verification_method VARCHAR(50) NOT NULL,     -- 'ON_CHAIN', 'OFF_CHAIN', 'BATCH'
    
    -- Results
    success BOOLEAN NOT NULL,
    reason TEXT,                                  -- Success/failure reason
    gas_used BIGINT,                             -- Gas used for verification
    verification_time_ms INTEGER,                 -- Time taken for verification
    
    -- Blockchain Details
    tx_hash VARCHAR(66),                         -- Transaction hash if on-chain
    block_number BIGINT,                         -- Block number if on-chain
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- ZK-PROOF INTEGRATION WITH EXISTING TABLES
-- ============================================================================

-- Enhanced Milestones Table with ZK-Proof Support
ALTER TABLE milestones ADD COLUMN zk_proof_hash VARCHAR(66) REFERENCES zk_proofs(proof_hash);
ALTER TABLE milestones ADD COLUMN zk_proof_type VARCHAR(20) CHECK (zk_proof_type IN ('RISC_ZERO', 'CIRCOM'));
ALTER TABLE milestones ADD COLUMN zk_proof_verified BOOLEAN DEFAULT FALSE;
ALTER TABLE milestones ADD COLUMN zk_proof_verification_timestamp TIMESTAMP;

-- Enhanced Coffee Batches with ZK-Proof Support
ALTER TABLE coffee_batches ADD COLUMN quality_proof_hash VARCHAR(66) REFERENCES zk_proofs(proof_hash);
ALTER TABLE coffee_batches ADD COLUMN quality_proof_type VARCHAR(20) CHECK (quality_proof_type IN ('RISC_ZERO', 'CIRCOM'));
ALTER TABLE coffee_batches ADD COLUMN quality_proof_verified BOOLEAN DEFAULT FALSE;

-- Enhanced Cooperatives with ZK-Proof Support
ALTER TABLE cooperatives ADD COLUMN identity_proof_hash VARCHAR(66) REFERENCES zk_proofs(proof_hash);
ALTER TABLE cooperatives ADD COLUMN identity_proof_type VARCHAR(20) CHECK (identity_proof_type IN ('RISC_ZERO', 'CIRCOM'));
ALTER TABLE cooperatives ADD COLUMN identity_proof_verified BOOLEAN DEFAULT FALSE;

-- ============================================================================
-- ZK-PROOF INDEXES FOR PERFORMANCE
-- ============================================================================

-- Note: These indexes will be created after all tables exist
-- They are moved to the end of the schema for proper execution order

-- ============================================================================
-- ZK-PROOF VIEWS FOR COMMON QUERIES
-- ============================================================================

-- ZK Proof Status Overview (Updated for new architecture)
CREATE VIEW zk_proof_status_overview AS
SELECT 
    zp.proof_hash,
    zp.proof_type,
    zp.verification_status,
    zp.submitter_address,
    zp.submitted_at,
    zp.verified_at,
    zp.verification_reason,
    zp.gas_used,
    
    -- Metadata information (from separate table)
    zpm.proof_name,
    zpm.description,
    zpm.version,
    zpm.circuit_hash,
    zpm.max_gas_limit,
    
    -- Use case information
    zuc.use_case_type,
    zuc.use_case_subtype,
    zuc.grant_id,
    zuc.milestone_id,
    zuc.batch_id,
    zuc.cooperative_id,
    
    -- Expiry information
    zp.expiry_timestamp,
    zp.is_expired,
    CASE 
        WHEN zp.expiry_timestamp < CURRENT_TIMESTAMP THEN 'EXPIRED'
        WHEN zp.expiry_timestamp < CURRENT_TIMESTAMP + INTERVAL '1 day' THEN 'EXPIRING_SOON'
        ELSE 'VALID'
    END as expiry_status
    
FROM zk_proofs zp
LEFT JOIN zk_proof_metadata zpm ON zp.proof_hash = zpm.proof_hash
LEFT JOIN zk_proof_use_cases zuc ON zp.proof_hash = zuc.proof_hash
ORDER BY zp.submitted_at DESC;

-- Milestone ZK-Proof Status
CREATE VIEW milestone_zk_proof_status AS
SELECT 
    m.milestone_id,
    m.schedule_id,
    ds.grant_id,
    cg.cooperative_id,
    c.name as cooperative_name,
    m.milestone_index,
    m.description,
    m.percentage_share,
    m.is_completed,
    
    -- ZK Proof information
    m.zk_proof_hash,
    m.zk_proof_type,
    m.zk_proof_verified,
    m.zk_proof_verification_timestamp,
    
    -- Proof details
    zp.verification_status as proof_status,
    zp.verification_reason as proof_reason,
    zp.gas_used as proof_gas_used,
    zp.expiry_timestamp as proof_expiry
    
FROM milestones m
JOIN disbursement_schedules ds ON m.schedule_id = ds.schedule_id
JOIN cooperative_grants cg ON ds.grant_id = cg.grant_id
JOIN cooperatives c ON cg.cooperative_id = c.cooperative_id
LEFT JOIN zk_proofs zp ON m.zk_proof_hash = zp.proof_hash
ORDER BY ds.grant_id, m.milestone_index;

-- Coffee Quality ZK-Proof Status
CREATE VIEW coffee_quality_zk_proof_status AS
SELECT 
    cb.batch_id,
    cb.production_date,
    cb.quantity_kg,
    cb.price_per_kg,
    cb.token_type,
    
    -- ZK Proof information
    cb.quality_proof_hash,
    cb.quality_proof_type,
    cb.quality_proof_verified,
    
    -- Proof details
    zp.verification_status as proof_status,
    zp.verification_reason as proof_reason,
    zp.submitted_at as proof_submitted,
    zp.verified_at as proof_verified,
    
    -- Use case data
    zuc.use_case_data as quality_metrics
    
FROM coffee_batches cb
LEFT JOIN zk_proofs zp ON cb.quality_proof_hash = zp.proof_hash
LEFT JOIN zk_proof_use_cases zuc ON cb.quality_proof_hash = zuc.proof_hash
WHERE cb.quality_proof_hash IS NOT NULL
ORDER BY cb.production_date DESC;

-- ZK Proof Data Integrity Verification View
CREATE VIEW zk_proof_data_integrity AS
SELECT 
    zp.proof_hash,
    zp.proof_type,
    zp.public_inputs_hash,
    
    -- Data integrity verification
    CASE 
        WHEN zp.public_inputs_hash = encode(sha256(zp.public_inputs), 'hex') THEN 'VALID'
        ELSE 'CORRUPTED'
    END as data_integrity_status,
    
    -- Data size information
    length(zp.proof_data) as proof_data_size_bytes,
    length(zp.public_inputs) as public_inputs_size_bytes,
    
    -- Metadata
    zpm.proof_name,
    zpm.circuit_hash,
    
    -- Verification status
    zp.verification_status,
    zp.verified_at
    
FROM zk_proofs zp
LEFT JOIN zk_proof_metadata zpm ON zp.proof_hash = zpm.proof_hash
ORDER BY zp.submitted_at DESC;

-- ZK Proof Performance Metrics
CREATE VIEW zk_proof_performance_metrics AS
SELECT 
    zp.proof_type,
    COUNT(*) as total_proofs,
    COUNT(CASE WHEN zp.verification_status = 'VERIFIED' THEN 1 END) as verified_proofs,
    COUNT(CASE WHEN zp.verification_status = 'REJECTED' THEN 1 END) as rejected_proofs,
    COUNT(CASE WHEN zp.verification_status = 'EXPIRED' THEN 1 END) as expired_proofs,
    
    -- Average gas usage
    AVG(zp.gas_used) as avg_gas_used,
    MAX(zp.gas_used) as max_gas_used,
    MIN(zp.gas_used) as min_gas_used,
    
    -- Success rate
    ROUND(
        (COUNT(CASE WHEN zp.verification_status = 'VERIFIED' THEN 1 END)::DECIMAL / COUNT(*)::DECIMAL * 100), 2
    ) as success_rate_percent
    
FROM zk_proofs zp
GROUP BY zp.proof_type;

-- ============================================================================
-- ZK-PROOF FUNCTIONS AND TRIGGERS
-- ============================================================================

-- Function to verify ZK proof data integrity
CREATE OR REPLACE FUNCTION verify_zk_proof_integrity(proof_hash_param VARCHAR(66))
RETURNS TABLE(
    proof_hash VARCHAR(66),
    integrity_status VARCHAR(20),
    public_inputs_hash VARCHAR(66),
    calculated_hash VARCHAR(66),
    is_valid BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        zp.proof_hash,
        CASE 
            WHEN zp.public_inputs_hash = encode(sha256(zp.public_inputs), 'hex') THEN 'VALID'
            ELSE 'CORRUPTED'
        END as integrity_status,
        zp.public_inputs_hash,
        encode(sha256(zp.public_inputs), 'hex') as calculated_hash,
        (zp.public_inputs_hash = encode(sha256(zp.public_inputs), 'hex')) as is_valid
    FROM zk_proofs zp
    WHERE zp.proof_hash = proof_hash_param;
END;
$$ LANGUAGE plpgsql;

-- Function to automatically expire proofs
CREATE OR REPLACE FUNCTION expire_zk_proofs()
RETURNS INTEGER AS $$
DECLARE
    expired_count INTEGER := 0;
BEGIN
    UPDATE zk_proofs 
    SET 
        verification_status = 'EXPIRED',
        is_expired = TRUE,
        updated_at = CURRENT_TIMESTAMP
    WHERE 
        expiry_timestamp < CURRENT_TIMESTAMP 
        AND verification_status = 'PENDING'
        AND is_expired = FALSE;
    
    GET DIAGNOSTICS expired_count = ROW_COUNT;
    
    RETURN expired_count;
END;
$$ LANGUAGE plpgsql;

-- Function to update proof verification status
CREATE OR REPLACE FUNCTION update_proof_verification_status()
RETURNS TRIGGER AS $$
BEGIN
    -- Update the main proof status
    UPDATE zk_proofs 
    SET 
        verification_status = NEW.verification_status,
        verified_at = CASE WHEN NEW.verification_status = 'VERIFIED' THEN CURRENT_TIMESTAMP ELSE NULL END,
        verified_by = CASE WHEN NEW.verification_status = 'VERIFIED' THEN NEW.verifier_address ELSE NULL END,
        verification_reason = NEW.verification_reason,
        gas_used = NEW.gas_used,
        updated_at = CURRENT_TIMESTAMP
    WHERE proof_hash = NEW.proof_hash;
    
    -- Update related milestone if this is a milestone proof
    UPDATE milestones 
    SET 
        zk_proof_verified = CASE WHEN NEW.verification_status = 'VERIFIED' THEN TRUE ELSE FALSE END,
        zk_proof_verification_timestamp = CASE WHEN NEW.verification_status = 'VERIFIED' THEN CURRENT_TIMESTAMP ELSE NULL END
    WHERE zk_proof_hash = NEW.proof_hash;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update proof status
CREATE TRIGGER trigger_update_proof_verification_status
    AFTER INSERT ON proof_verification_history
    FOR EACH ROW
    EXECUTE FUNCTION update_proof_verification_status();

-- ============================================================================
-- SAMPLE ZK-PROOF DATA INSERTION
-- ============================================================================

-- Insert sample RISC Zero circuit support
INSERT INTO zk_proofs (
    proof_hash, proof_type, proof_data, public_inputs, public_inputs_hash,
    submitter_address, expiry_timestamp, network
) VALUES (
    '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
    'RISC_ZERO',
    '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef', -- Raw proof data
    '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef', -- Public inputs
    '0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890', -- Public inputs hash
    '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
    CURRENT_TIMESTAMP + INTERVAL '7 days',
    'base'
);

-- Insert corresponding metadata
INSERT INTO zk_proof_metadata (
    proof_hash, proof_name, description, version, circuit_hash, max_gas_limit
) VALUES (
    '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
    'Coffee Quality Algorithm V1',
    'RISC Zero proof for coffee quality scoring algorithm',
    '1.0.0',
    '0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890',
    500000
);

-- Insert sample Circom circuit support
INSERT INTO zk_proofs (
    proof_hash, proof_type, proof_data, public_inputs, public_inputs_hash,
    submitter_address,
    expiry_timestamp, network
) VALUES (
    '0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890',
    'CIRCOM',
    '0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890', -- Raw proof data
    '0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890', -- Public inputs
    '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef', -- Public inputs hash

    '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
    CURRENT_TIMESTAMP + INTERVAL '30 days',
    'base'
);

-- Insert corresponding metadata
INSERT INTO zk_proof_metadata (
    proof_hash, proof_name, description, version, circuit_hash, max_gas_limit
) VALUES (
    '0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890',
    'Milestone Completion V1',
    'Circom proof for milestone completion verification',
    '1.0.0',
    '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
    300000
);

-- Insert sample use cases
INSERT INTO zk_proof_use_cases (
    proof_hash, use_case_type, use_case_subtype, grant_id, milestone_id
) VALUES (
    '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
    'COFFEE_QUALITY',
    'QUALITY_SCORING',
    NULL,
    NULL
);

INSERT INTO zk_proof_use_cases (
    proof_hash, use_case_type, use_case_subtype, grant_id, milestone_id
) VALUES (
    '0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890',
    'MILESTONE_VALIDATION',
    'COMPLETION_VERIFICATION',
    NULL,
    NULL
);

-- ============================================================================
-- ZK-PROOF INDEXES FOR PERFORMANCE (CREATED AFTER ALL TABLES EXIST)
-- ============================================================================

-- ZK Proofs Indexes
CREATE INDEX idx_zk_proofs_type ON zk_proofs(proof_type);
CREATE INDEX idx_zk_proofs_status ON zk_proofs(verification_status);
CREATE INDEX idx_zk_proofs_submitter ON zk_proofs(submitter_address);
CREATE INDEX idx_zk_proofs_circuit ON zk_proofs(circuit_hash);
CREATE INDEX idx_zk_proofs_expiry ON zk_proofs(expiry_timestamp);
CREATE INDEX idx_zk_proofs_network ON zk_proofs(network);

-- Metadata Indexes
CREATE INDEX idx_zk_proof_metadata_circuit ON zk_proof_metadata(circuit_hash);
CREATE INDEX idx_zk_proof_metadata_name ON zk_proof_metadata(proof_name);

-- Use Cases Indexes
CREATE INDEX idx_zk_proof_use_cases_type ON zk_proof_use_cases(use_case_type);
CREATE INDEX idx_zk_proof_use_cases_grant ON zk_proof_use_cases(grant_id);
CREATE INDEX idx_zk_proof_use_cases_milestone ON zk_proof_use_cases(milestone_id);
CREATE INDEX idx_zk_proof_use_cases_batch ON zk_proof_use_cases(batch_id);

-- RISC Zero Indexes
CREATE INDEX idx_risc_zero_proofs_program ON risc_zero_proofs(program_hash);
CREATE INDEX idx_risc_zero_proofs_image ON risc_zero_proofs(image_id);
CREATE INDEX idx_risc_zero_proofs_circuit ON risc_zero_proofs(circuit_name);

-- Circom Indexes
CREATE INDEX idx_circom_proofs_circuit ON circom_proofs(circuit_name);
CREATE INDEX idx_circom_proofs_version ON circom_proofs(circuit_version);
CREATE INDEX idx_circom_proofs_format ON circom_proofs(proof_format);

-- Verification History Indexes
CREATE INDEX idx_proof_verification_history_proof ON proof_verification_history(proof_hash);
CREATE INDEX idx_proof_verification_history_verifier ON proof_verification_history(verifier_address);
CREATE INDEX idx_proof_verification_history_success ON proof_verification_history(success);
CREATE INDEX idx_proof_verification_history_timestamp ON proof_verification_history(verification_attempt);
