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
