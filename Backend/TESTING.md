# DispatchDZ Backend: Manual Testing Guide

Follow these steps to verify that every part of the backend is working correctly in your Supabase project.

---

## 1. Database & Seed Verification
**Where:** Supabase Dashboard -> **Table Editor**

- **Wilayas Table:** Check the `wilayas` table. You should see 31+ records (Adrar, Alger, Oran, etc.).
- **Sectors Table:** Check the `sectors` table. You should see 4 records: Agroalimentaire, Construction, Pièces détachées, Gros/Superettes.
- **Product Categories Table:** Check `product_categories`. You should see items like "Fruits & Légumes", "Ciment", etc.

---

## 2. Authentication Testing (Phone OTP)
**Where:** Supabase Dashboard -> **Authentication** -> **Users**

1. Click **Add User** -> **Create new user**.
2. Enter a phone number (e.g., `+213555555555`).
3. **Verify:** A new record should appear in the `users` table in the **Table Editor** (via the trigger or manually if you haven't set up a trigger yet, though Supabase Auth users are stored in the `auth.users` schema).
4. **Note:** In the "Settings" tab of Auth, ensure "Phone" is enabled as a provider.

---

## 3. Testing Real-Time Stock Listings
**Where:** Supabase Dashboard -> **Realtime Inspector**

1. Go to the **Realtime Inspector** (under Tools or Database in some versions).
2. Listen to the `stock_listings` table.
3. Open a second tab with the **Table Editor** for `stock_listings`.
4. Insert a new row (choose any `supplier_id` from your users).
5. **Verify:** You should see a "new record" event pop up instantly in the Realtime Inspector.

---

## 4. Testing the Search Engine (RPC)
**Where:** Supabase Dashboard -> **SQL Editor**

Run this SQL snippet to test if the product ranking and matching logic is working:

```sql
SELECT * FROM search_listings(
  query := 'Tomate', -- Change this to a product name you have in stock
  p_sector := 1,     -- 1 = Food sector
  p_wilaya := 16,    -- 16 = Alger
  p_qty := 10        -- Minimum quantity
);
```

**Verify:** It should return the top 5 relevant listings with a `match_score`, `avg_market_price`, and `lowest_price`.

---

## 5. Testing Row Level Security (RLS)
**Where:** Use **Postman** or **cURL**

Try to read data without an API key or with a restricted key:
1. **Request:** `GET https://your-ref.supabase.co/rest/v1/users`
2. **Verify:** It should return your public profile data.
3. **Request:** `PATCH https://your-ref.supabase.co/rest/v1/users?id=eq.<other-user-uuid>`
4. **Verify:** It should return a `403 Forbidden` or success with 0 rows updated, because RLS prevents editing other users' profiles.

---

## 6. Testing the Shortage Detector (Edge Function)
**Where:** Supabase Dashboard -> **Edge Functions** -> `shortage-detector`

You can trigger it manually via cURL to see if it detects shortages:

```bash
curl --request POST 'https://your-ref.supabase.co/functions/v1/shortage-detector' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json'
```

**Verify:** 
1. Check the **Function Logs** in Supabase. It should show it counting listings.
2. If any category in a wilaya has < 3 suppliers, a new row should appear in the `shortage_alerts` table.

---

## 7. Heatmap Data (Demand Pulse)
**Where:** Supabase Dashboard -> **SQL Editor**

Run this to see if searches are being aggregated correctly:

```sql
SELECT * FROM get_demand_pulse(7); -- Last 7 days
```

**Verify:** It should return wilayas and sectors sorted by most searched/demand.
