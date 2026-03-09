# Provix — Backend Submission Guide 🚀

This repository contains the complete, production-ready backend for **DispatchDZ**, a real-time supply intelligence platform for Algeria's SME economy.

## 🏗️ Architecture Overview

The backend is built on **Supabase**, leveraging its full power for a "Serverless" and "Real-time" architecture:
- **Database**: PostgreSQL with custom SQL functions (RPCs) for complex logic.
- **Authentication**: Phone-based OTP (One-Time Password) system.
- **Intelligence Layer**: Deno-based Edge Functions for automated stock monitoring.
- **Real-time**: Postgres Replication for instant broadcast of stock changes.
- **CI/CD**: GitHub Actions for automated, zero-downtime deployments.

## 📂 Key Components

1.  **Database Migrations** (`backend/supabase/migrations/`):
    - `initial_schema.sql`: Core tables for users, listings, wilayas, and etc.
    - `rls_policies.sql`: Row Level Security policies to protect user data.
    - `rpc_functions.sql`: The search engine logic and aggregation functions.
2.  **Edge Functions** (`backend/supabase/functions/`):
    - `shortage-detector`: A TypeScript function that monitors stock and triggers push notifications when categories drop below 3 suppliers.
3.  **Seed Data** (`backend/supabase/seed.sql`):
    - Includes all 58 Algerian Wilayas and pre-defined business sectors.
4.  **DevOps** (`.github/workflows/deploy.yml`):
    - Fully automated pipeline to sync code to Supabase on every push.

## 🧪 How to Verify the Implementation

### 1. The Database Structure
In the Supabase **Table Editor**, you can see the relational structure between Suppliers (`users`), Listings (`stock_listings`), and Locations (`wilayas`).

### 2. The Search Logic (RPC)
The heart of the app is the `search_listings` function. You can test it in the SQL Editor:
```sql
SELECT * FROM search_listings(
  query := 'Tomate', 
  p_sector := 1,     -- Food
  p_wilaya := 16,    -- Alger
  p_qty := 10        
);
```
This returns results ranked by **Text similarity**, **Location proximity**, and **Quantity availability**.

### 3. Real-Time Capabilities
By toggling **Replication** on the `stock_listings` table, the backend broadcasts every new broadcast to buyers instantly.

### 4. Automated Shortage Monitoring
The `shortage-detector` function uses high-performance Deno and the Expo Push API to fire alerts to buyers' phones when stock is low in their region.

---

**Built by:** Iyad Bencherchali  
**Project ID:** `lxvtjwsfqkbakxgksrmi`
