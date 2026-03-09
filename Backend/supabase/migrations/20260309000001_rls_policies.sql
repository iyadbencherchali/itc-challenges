-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE demand_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE shortage_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE demand_pulse ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_searches ENABLE ROW LEVEL SECURITY;
ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- users policies
CREATE POLICY "Public profiles are viewable by everyone" ON users FOR SELECT USING (true);
CREATE POLICY "Users can insert their own profile" ON users FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update their own profile" ON users FOR UPDATE USING (auth.uid() = id);

-- stock_listings policies 
CREATE POLICY "Listings are viewable by everyone" ON stock_listings FOR SELECT USING (true);
CREATE POLICY "Suppliers can insert their own listings" ON stock_listings FOR INSERT WITH CHECK (auth.uid() = supplier_id);
CREATE POLICY "Suppliers can update their own listings" ON stock_listings FOR UPDATE USING (auth.uid() = supplier_id);
CREATE POLICY "Suppliers can delete their own listings" ON stock_listings FOR DELETE USING (auth.uid() = supplier_id);

-- demand_requests policies
CREATE POLICY "Demand requests viewable by everyone" ON demand_requests FOR SELECT USING (true);
CREATE POLICY "Buyers can insert their own demands" ON demand_requests FOR INSERT WITH CHECK (auth.uid() = buyer_id);
CREATE POLICY "Buyers can update their own demands" ON demand_requests FOR UPDATE USING (auth.uid() = buyer_id);
CREATE POLICY "Buyers can delete their own demands" ON demand_requests FOR DELETE USING (auth.uid() = buyer_id);

-- shortage_alerts policies (Read-only for public, write via Edge Function/Service Role)
CREATE POLICY "Shortage alerts viewable by everyone" ON shortage_alerts FOR SELECT USING (true);

-- demand_pulse policies (Read-only for public, write via RPC/Service Role)
CREATE POLICY "Demand pulse viewable by everyone" ON demand_pulse FOR SELECT USING (true);

-- saved_searches policies
CREATE POLICY "Users can view their own saved searches" ON saved_searches FOR SELECT USING (auth.uid() = buyer_id);
CREATE POLICY "Users can insert their own saved searches" ON saved_searches FOR INSERT WITH CHECK (auth.uid() = buyer_id);
CREATE POLICY "Users can update their own saved searches" ON saved_searches FOR UPDATE USING (auth.uid() = buyer_id);
CREATE POLICY "Users can delete their own saved searches" ON saved_searches FOR DELETE USING (auth.uid() = buyer_id);

-- contacts policies (Buyers can create, suppliers/buyers can read their own)
CREATE POLICY "Users can view contacts involving them" ON contacts FOR SELECT USING (auth.uid() = buyer_id OR auth.uid() = supplier_id);
CREATE POLICY "Buyers can create contacts" ON contacts FOR INSERT WITH CHECK (auth.uid() = buyer_id);

-- reviews policies
CREATE POLICY "Reviews viewable by everyone" ON reviews FOR SELECT USING (true);
CREATE POLICY "Buyers can create reviews" ON reviews FOR INSERT WITH CHECK (auth.uid() = reviewer_id);
CREATE POLICY "Buyers can edit their own reviews" ON reviews FOR UPDATE USING (auth.uid() = reviewer_id);
CREATE POLICY "Buyers can delete their own reviews" ON reviews FOR DELETE USING (auth.uid() = reviewer_id);
