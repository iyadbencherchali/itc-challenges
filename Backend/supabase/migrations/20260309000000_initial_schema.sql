-- Enums
CREATE TYPE user_role AS ENUM ('supplier', 'buyer', 'both');
CREATE TYPE user_language AS ENUM ('fr', 'ar', 'en');
CREATE TYPE listing_status AS ENUM ('active', 'paused', 'expired', 'sold_out');
CREATE TYPE demand_status AS ENUM ('active', 'fulfilled', 'cancelled');
CREATE TYPE shortage_status AS ENUM ('active', 'resolved');

-- wilayas
CREATE TABLE wilayas (
    id SERIAL PRIMARY KEY,
    name_fr TEXT NOT NULL,
    name_ar TEXT NOT NULL,
    code TEXT NOT NULL
);

-- sectors
CREATE TABLE sectors (
    id SERIAL PRIMARY KEY,
    name_fr TEXT NOT NULL,
    name_ar TEXT NOT NULL,
    name_en TEXT NOT NULL,
    icon TEXT
);

-- product_categories
CREATE TABLE product_categories (
    id SERIAL PRIMARY KEY,
    sector_id INT REFERENCES sectors(id) ON DELETE CASCADE,
    name_fr TEXT NOT NULL,
    name_ar TEXT NOT NULL
);

-- users 
CREATE TABLE users (
    id UUID PRIMARY KEY, -- Primary key matches Supabase Auth user ID
    full_name TEXT,
    phone TEXT UNIQUE NOT NULL,
    role user_role DEFAULT 'buyer',
    wilaya_id INT REFERENCES wilayas(id),
    sector_ids INT[],
    language user_language DEFAULT 'fr',
    business_name TEXT,
    verified BOOLEAN DEFAULT false,
    expo_push_token TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- stock_listings
CREATE TABLE stock_listings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    supplier_id UUID REFERENCES users(id) ON DELETE CASCADE,
    sector_id INT REFERENCES sectors(id),
    category_id INT REFERENCES product_categories(id),
    product_name TEXT NOT NULL,
    quantity NUMERIC NOT NULL,
    unit TEXT NOT NULL,
    price_per_unit NUMERIC NOT NULL,
    wilaya_id INT REFERENCES wilayas(id),
    delivery_available BOOLEAN DEFAULT false,
    delivery_wilayas INT[],
    images TEXT[],
    status listing_status DEFAULT 'active',
    expires_at TIMESTAMPTZ DEFAULT (now() + interval '24 hours'),
    views_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- demand_requests
CREATE TABLE demand_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    buyer_id UUID REFERENCES users(id) ON DELETE CASCADE,
    product_query TEXT NOT NULL,
    sector_id INT REFERENCES sectors(id),
    wilaya_id INT REFERENCES wilayas(id),
    status demand_status DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- shortage_alerts
CREATE TABLE shortage_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wilaya_id INT REFERENCES wilayas(id),
    sector_id INT REFERENCES sectors(id),
    category_id INT REFERENCES product_categories(id),
    active_supplier_count INT NOT NULL,
    status shortage_status DEFAULT 'active',
    triggered_at TIMESTAMPTZ DEFAULT now()
);

-- Unique constraint for shortage alerts UPSERT
ALTER TABLE shortage_alerts ADD CONSTRAINT unique_shortage_alert UNIQUE (wilaya_id, category_id);

-- demand_pulse
CREATE TABLE demand_pulse (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wilaya_id INT REFERENCES wilayas(id),
    sector_id INT REFERENCES sectors(id),
    query_count INT DEFAULT 0,
    date DATE DEFAULT CURRENT_DATE
);

ALTER TABLE demand_pulse ADD CONSTRAINT unique_demand_pulse UNIQUE (wilaya_id, sector_id, date);

-- saved_searches
CREATE TABLE saved_searches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    buyer_id UUID REFERENCES users(id) ON DELETE CASCADE,
    sector_id INT REFERENCES sectors(id),
    keyword TEXT NOT NULL,
    wilaya_id INT REFERENCES wilayas(id),
    created_at TIMESTAMPTZ DEFAULT now()
);

-- contacts
CREATE TABLE contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    buyer_id UUID REFERENCES users(id) ON DELETE CASCADE,
    supplier_id UUID REFERENCES users(id) ON DELETE CASCADE,
    listing_id UUID REFERENCES stock_listings(id) ON DELETE CASCADE,
    contacted_at TIMESTAMPTZ DEFAULT now()
);

-- reviews
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reviewer_id UUID REFERENCES users(id) ON DELETE CASCADE,
    supplier_id UUID REFERENCES users(id) ON DELETE CASCADE,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- pg_trgm extension for similarity search
CREATE EXTENSION IF NOT EXISTS pg_trgm;
