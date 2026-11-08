-- ====================================================================
-- HR RECRUITMENT CONTROL - SUPABASE POSTGRESQL MIGRATION SCRIPT
-- Master Migration Script for Supabase SQL Editor
-- ====================================================================

-- 0. Enable UUID Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. CUSTOMERS TABLE (Công ty khách hàng)
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

-- 2. LOCATIONS / KITCHENS TABLE (Chi nhánh / Bếp ăn)
CREATE TABLE IF NOT EXISTS public.locations (
  id VARCHAR(255) PRIMARY KEY,
  code VARCHAR(50) NOT NULL UNIQUE,
  name TEXT NOT NULL,
  customer_id VARCHAR(255) REFERENCES public.customers(id) ON DELETE CASCADE,
  address TEXT,
  region VARCHAR(100),
  leader_id VARCHAR(255),
  leader_name TEXT,
  phone VARCHAR(50),
  active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. POSITIONS TABLE (Vị trí tuyển dụng)
CREATE TABLE IF NOT EXISTS public.positions (
  id VARCHAR(255) PRIMARY KEY,
  code VARCHAR(50) NOT NULL UNIQUE,
  name TEXT NOT NULL,
  job_group VARCHAR(100) DEFAULT 'Chế biến',
  description TEXT,
  active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. KITCHEN LEADERS TABLE (Leader / Người phụ trách tại bếp)
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

-- 5. PRESET TEMPLATES TABLE (Mẫu Mức lương & Phúc lợi tự động điền)
-- Composite Unique Constraint: customer_id + position_id
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

-- 6. RECRUITMENT REQUESTS TABLE (Yêu cầu tuyển dụng)
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

-- 7. SYSTEM USERS TABLE (Tài khoản & Phân quyền HR / Admin)
CREATE TABLE IF NOT EXISTS public.users (
  id VARCHAR(255) PRIMARY KEY,
  code VARCHAR(50) NOT NULL UNIQUE,
  full_name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  role VARCHAR(20) NOT NULL DEFAULT 'hr', -- 'hr' or 'admin'
  phone VARCHAR(50),
  active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. INDEXES FOR PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_req_cust ON public.recruitment_requests(customer_id);
CREATE INDEX IF NOT EXISTS idx_req_loc ON public.recruitment_requests(location_id);
CREATE INDEX IF NOT EXISTS idx_req_pos ON public.recruitment_requests(position_id);
CREATE INDEX IF NOT EXISTS idx_req_status ON public.recruitment_requests(status);
CREATE INDEX IF NOT EXISTS idx_loc_cust ON public.locations(customer_id);
CREATE INDEX IF NOT EXISTS idx_preset_cust_pos ON public.preset_templates(customer_id, position_id);

-- 9. ROW LEVEL SECURITY (RLS) POLICIES
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.positions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kitchen_leaders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.preset_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recruitment_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Create Policies allowing public/authenticated client operations
CREATE POLICY "Allow Select Customers" ON public.customers FOR SELECT USING (true);
CREATE POLICY "Allow Insert Customers" ON public.customers FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow Update Customers" ON public.customers FOR UPDATE USING (true);
CREATE POLICY "Allow Delete Customers" ON public.customers FOR DELETE USING (true);

CREATE POLICY "Allow Select Locations" ON public.locations FOR SELECT USING (true);
CREATE POLICY "Allow Insert Locations" ON public.locations FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow Update Locations" ON public.locations FOR UPDATE USING (true);
CREATE POLICY "Allow Delete Locations" ON public.locations FOR DELETE USING (true);

CREATE POLICY "Allow Select Positions" ON public.positions FOR SELECT USING (true);
CREATE POLICY "Allow Insert Positions" ON public.positions FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow Update Positions" ON public.positions FOR UPDATE USING (true);
CREATE POLICY "Allow Delete Positions" ON public.positions FOR DELETE USING (true);

CREATE POLICY "Allow Select Leaders" ON public.kitchen_leaders FOR SELECT USING (true);
CREATE POLICY "Allow Insert Leaders" ON public.kitchen_leaders FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow Update Leaders" ON public.kitchen_leaders FOR UPDATE USING (true);
CREATE POLICY "Allow Delete Leaders" ON public.kitchen_leaders FOR DELETE USING (true);

CREATE POLICY "Allow Select Presets" ON public.preset_templates FOR SELECT USING (true);
CREATE POLICY "Allow Insert Presets" ON public.preset_templates FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow Update Presets" ON public.preset_templates FOR UPDATE USING (true);
CREATE POLICY "Allow Delete Presets" ON public.preset_templates FOR DELETE USING (true);

CREATE POLICY "Allow Select Requests" ON public.recruitment_requests FOR SELECT USING (true);
CREATE POLICY "Allow Insert Requests" ON public.recruitment_requests FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow Update Requests" ON public.recruitment_requests FOR UPDATE USING (true);
CREATE POLICY "Allow Delete Requests" ON public.recruitment_requests FOR DELETE USING (true);

CREATE POLICY "Allow Select Users" ON public.users FOR SELECT USING (true);
CREATE POLICY "Allow Insert Users" ON public.users FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow Update Users" ON public.users FOR UPDATE USING (true);
CREATE POLICY "Allow Delete Users" ON public.users FOR DELETE USING (true);

-- 10. SECURE ADMIN PASSWORD HASH VERIFICATION FUNCTION
-- Cryptographic hash comparison function for Admin Login
CREATE OR REPLACE FUNCTION public.verify_admin_password(input_password TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- SHA-256 hash of '242004' is 050a9d46eba417028d3f9b52dfd0b94a4e4e275a972570aff33a22059dc50902
  RETURN encode(digest(input_password, 'sha256'), 'hex') = '050a9d46eba417028d3f9b52dfd0b94a4e4e275a972570aff33a22059dc50902';
END;
$$;
