# DispatchDZ Backend Setup Guide

## Authentication Setup (Phone OTP)
1. Go to your Supabase Project Dashboard.
2. Navigate to **Authentication** -> **Providers**.
3. Enable **Phone** authentication.
4. You will need a provider (like Twilio, MessageBird, or a local Algerian SMS provider API). Configure the Webhook/Credentials there.
5. In your frontend, call `supabase.auth.signInWithOtp({ phone: '+213XXXXXXXXX' })`.

## Realtime Setup
1. Go to **Database** -> **Replication**.
2. Click **0 Tables** under Source.
3. Toggle the `stock_listings` table to enable Realtime explicitly.
4. In your client apps, listen via:
   ```javascript
   supabase.channel('public:stock_listings')
     .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'stock_listings' }, payload => {
       console.log('New listing!', payload)
     }).subscribe()
   ```

## Edge Functions Deployment
1. To deploy the Edge function to your production Supabase instance run:
   ```bash
   npx supabase functions deploy shortage-detector
   ```
2. You will also want to set it up on a cron job (e.g. via `pg_cron` inside Supabase SQL):
   ```sql
   SELECT cron.schedule(
     'shortage-detector-cron',
     '*/30 * * * *',
     $$
       SELECT net.http_post(
           url := 'https://<PROJECT_REF>.supabase.co/functions/v1/shortage-detector',
           headers := '{"Authorization": "Bearer <ANON_KEY>"}'::jsonb
       );
     $$
   );
   ```
