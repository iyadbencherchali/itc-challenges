-- 1. search_listings (From the README precisely)
CREATE OR REPLACE FUNCTION search_listings(
  query      text,
  p_sector   int,
  p_wilaya   int,
  p_qty      numeric DEFAULT 0
)
RETURNS TABLE (id uuid, product_name text, price_per_unit numeric,
  quantity numeric, unit text, supplier_name text,
  supplier_phone text, wilaya_name text,
  delivery_available boolean, avg_market_price numeric,
  lowest_price numeric, match_score real)
AS $$
  WITH market_stats AS (
    SELECT AVG(price_per_unit) AS avg_price,
           MIN(price_per_unit) AS min_price
    FROM stock_listings
    WHERE status = 'active' AND sector_id = p_sector
      AND product_name ILIKE '%' || query || '%'
  )
  SELECT sl.id, sl.product_name, sl.price_per_unit,
    sl.quantity, sl.unit, u.business_name AS supplier_name,
    u.phone AS supplier_phone, w.name_fr AS wilaya_name,
    sl.delivery_available, ms.avg_price, ms.min_price,
    -- Ranking: text match x3 + same wilaya +2 + qty match +1
    (similarity(sl.product_name, query) * 3
     + CASE WHEN sl.wilaya_id = p_wilaya THEN 2 ELSE 0 END
     + CASE WHEN sl.quantity >= p_qty THEN 1 ELSE 0 END
    ) AS match_score
  FROM stock_listings sl
  JOIN users u ON sl.supplier_id = u.id
  JOIN wilayas w ON sl.wilaya_id = w.id
  CROSS JOIN market_stats ms
  WHERE sl.status = 'active' AND sl.sector_id = p_sector
    AND sl.product_name ILIKE '%' || query || '%'
    AND sl.expires_at > now()
  ORDER BY match_score DESC LIMIT 5;
$$ LANGUAGE sql;

-- 2. count_active_by_category_wilaya
CREATE OR REPLACE FUNCTION count_active_by_category_wilaya()
RETURNS TABLE (wilaya_id int, sector_id int, category_id int, category_name text, active_count bigint)
AS $$
  SELECT 
    sl.wilaya_id, 
    sl.sector_id, 
    sl.category_id, 
    pc.name_fr as category_name,
    COUNT(DISTINCT sl.supplier_id) as active_count
  FROM stock_listings sl
  JOIN product_categories pc ON sl.category_id = pc.id
  WHERE sl.status = 'active' AND sl.expires_at > now()
  GROUP BY sl.wilaya_id, sl.sector_id, sl.category_id, pc.name_fr;
$$ LANGUAGE sql;

-- 3. get_demand_pulse
CREATE OR REPLACE FUNCTION get_demand_pulse(p_days int DEFAULT 7)
RETURNS TABLE (wilaya_id int, sector_id int, query_count bigint, wilaya_name text, sector_name text) 
AS $$
  SELECT 
    dp.wilaya_id, 
    dp.sector_id, 
    SUM(dp.query_count) as query_count,
    w.name_fr as wilaya_name,
    s.name_fr as sector_name
  FROM demand_pulse dp
  JOIN wilayas w ON dp.wilaya_id = w.id
  JOIN sectors s ON dp.sector_id = s.id
  WHERE dp.date >= CURRENT_DATE - p_days
  GROUP BY dp.wilaya_id, dp.sector_id, w.name_fr, s.name_fr
  ORDER BY query_count DESC;
$$ LANGUAGE sql;
