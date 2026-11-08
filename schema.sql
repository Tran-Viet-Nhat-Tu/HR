-- ====================================================================
-- HR RECRUITMENT CONTROL - SUPABASE POSTGRESQL SCHEMA
-- Industrial Catering Recruitment Request & Category Management
-- ====================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. CUSTOMERS (Công ty khách hàng)
CREATE TABLE IF NOT EXISTS public.customers (
  id VARCHAR(255) PRIMARY KEY,
  code VARCHAR(50) NOT NULL UNIQUE,
  name TEXT NOT NULL,
  address TEXT,
  region VARCHAR(100),
  contact_person VARCHAR(100),
  phone VARCHAR(50),
  notes TEXT,
  active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. LOCATIONS / KITCHENS (Chi nhánh / Bếp ăn cơ sở)
CREATE TABLE IF NOT EXISTS public.locations (
  id VARCHAR(255) PRIMARY KEY,
  code VARCHAR(50) NOT NULL UNIQUE,
  name TEXT NOT NULL,
  customer_id VARCHAR(255) REFERENCES public.customers(id) ON DELETE SET NULL,
  address TEXT,
  region VARCHAR(100),
  leader_id VARCHAR(255),
  phone VARCHAR(50),
  active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. POSITIONS (Vị trí tuyển dụng)
CREATE TABLE IF NOT EXISTS public.positions (
  id VARCHAR(255) PRIMARY KEY,
  code VARCHAR(50) NOT NULL UNIQUE,
  name TEXT NOT NULL,
  job_group VARCHAR(100) DEFAULT 'Chế biến',
  description TEXT,
  active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. KITCHEN LEADERS (Leader / Người phụ trách tại bếp)
CREATE TABLE IF NOT EXISTS public.kitchen_leaders (
  id VARCHAR(255) PRIMARY KEY,
  code VARCHAR(50) NOT NULL UNIQUE,
  full_name VARCHAR(100) NOT NULL,
  location_id VARCHAR(255) REFERENCES public.locations(id) ON DELETE SET NULL,
  phone VARCHAR(50),
  email VARCHAR(100),
  notes TEXT,
  active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. PRESET TEMPLATES (Cấu hình tự động điền Lương & Phúc lợi mặc định)
-- Composite key: customer_id + position_id
CREATE TABLE IF NOT EXISTS public.preset_templates (
  id VARCHAR(255) PRIMARY KEY,
  customer_id VARCHAR(255) NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
  position_id VARCHAR(255) NOT NULL REFERENCES public.positions(id) ON DELETE CASCADE,
  salary_vnd NUMERIC(15, 2) DEFAULT 0,
  salary_max_vnd NUMERIC(15, 2),
  salary_type VARCHAR(100) DEFAULT 'Lương tháng',
  allowance_notes TEXT,
  benefits_notes TEXT,
  work_shift VARCHAR(200),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unq_cust_pos UNIQUE (customer_id, position_id)
);

-- 6. RECRUITMENT REQUESTS (Yêu cầu tuyển dụng)
CREATE TABLE IF NOT EXISTS public.recruitment_requests (
  id VARCHAR(255) PRIMARY KEY,
  code VARCHAR(50) NOT NULL UNIQUE,
  customer_id VARCHAR(255) REFERENCES public.customers(id) ON DELETE RESTRICT,
  location_id VARCHAR(255) REFERENCES public.locations(id) ON DELETE RESTRICT,
  position_id VARCHAR(255) REFERENCES public.positions(id) ON DELETE RESTRICT,
  leader_id VARCHAR(255) REFERENCES public.kitchen_leaders(id) ON DELETE SET NULL,
  leader_name TEXT,
  contact_phone VARCHAR(50),
  
  quantity_needed INT NOT NULL DEFAULT 1,
  quantity_recruited INT NOT NULL DEFAULT 0,
  quantity_remaining INT NOT NULL DEFAULT 1,

  reason TEXT,
  intake_date VARCHAR(20),
  target_date VARCHAR(20) NOT NULL,
  priority VARCHAR(20) DEFAULT 'normal',

  salary_vnd NUMERIC(15, 2) DEFAULT 0,
  salary_max_vnd NUMERIC(15, 2),
  salary_type VARCHAR(100) DEFAULT 'Lương tháng',
  allowance_notes TEXT,
  benefits_notes TEXT,
  work_shift VARCHAR(200),

  candidate_requirements TEXT,
  notes TEXT,
  
  status VARCHAR(50) DEFAULT 'new', -- 'new', 'recruiting', 'fully_filled', 'paused', 'cancelled'
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  history JSONB DEFAULT '[]'::jsonb
);

-- Indexes for high-performance queries
CREATE INDEX IF NOT EXISTS idx_req_cust ON public.recruitment_requests(customer_id);
CREATE INDEX IF NOT EXISTS idx_req_loc ON public.recruitment_requests(location_id);
CREATE INDEX IF NOT EXISTS idx_req_pos ON public.recruitment_requests(position_id);
CREATE INDEX IF NOT EXISTS idx_req_status ON public.recruitment_requests(status);

-- Enable RLS (Row Level Security)
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.positions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kitchen_leaders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.preset_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recruitment_requests ENABLE ROW LEVEL SECURITY;

-- Allow authenticated and anon access for HR Web App
CREATE POLICY "Public Read Access" ON public.customers FOR SELECT USING (true);
CREATE POLICY "Public Write Access" ON public.customers FOR ALL USING (true);

CREATE POLICY "Public Read Access" ON public.locations FOR SELECT USING (true);
CREATE POLICY "Public Write Access" ON public.locations FOR ALL USING (true);

CREATE POLICY "Public Read Access" ON public.positions FOR SELECT USING (true);
CREATE POLICY "Public Write Access" ON public.positions FOR ALL USING (true);

CREATE POLICY "Public Read Access" ON public.kitchen_leaders FOR SELECT USING (true);
CREATE POLICY "Public Write Access" ON public.kitchen_leaders FOR ALL USING (true);

CREATE POLICY "Public Read Access" ON public.preset_templates FOR SELECT USING (true);
CREATE POLICY "Public Write Access" ON public.preset_templates FOR ALL USING (true);

CREATE POLICY "Public Read Access" ON public.recruitment_requests FOR SELECT USING (true);
CREATE POLICY "Public Write Access" ON public.recruitment_requests FOR ALL USING (true);
