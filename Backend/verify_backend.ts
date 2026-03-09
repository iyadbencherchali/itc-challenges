import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Replace these with your actual Supabase URL and Anon Key when running against the live DB.
const SUPABASE_URL = process.env.SUPABASE_URL || 'https://your-project-ref.supabase.co'
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY || 'your-anon-key'

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

async function verifyBackend() {
    console.log('🚀 Verifying DispatchDZ Backend...\n')

    // 1. Check Tables and Database Schema
    console.log('🔍 1. Checking Core Tables (Wilayas, Sectors, Categories)...')
    const { data: wilayas, error: wilayasError } = await supabase.from('wilayas').select('*').limit(1)
    if (wilayasError) console.error('❌ Wilayas Table Error:', wilayasError.message)
    else console.log('✅ Wilayas Table OK (Found', wilayas?.length, 'records)')

    const { data: sectors, error: sectorsError } = await supabase.from('sectors').select('*').limit(1)
    if (sectorsError) console.error('❌ Sectors Table Error:', sectorsError.message)
    else console.log('✅ Sectors Table OK (Found', sectors?.length, 'records)')

    // 2. Check RPC Functions
    console.log('\n🔍 2. Checking Custom Search Functions...')
    const { data: searchResults, error: searchError } = await supabase.rpc('search_listings', {
        query: 'test',
        p_sector: 1,
        p_wilaya: 16,
        p_qty: 0
    })
    if (searchError) console.error('❌ search_listings RPC Error:', searchError.message)
    else console.log('✅ search_listings RPC OK (Executed successfully)')

    const { data: countData, error: countError } = await supabase.rpc('count_active_by_category_wilaya')
    if (countError) console.error('❌ count_active_by_category_wilaya RPC Error:', countError.message)
    else console.log('✅ count_active_by_category_wilaya RPC OK')

    // 3. Edge Functions
    console.log('\n🔍 3. Checking Edge Functions...')
    const { data: edgeData, error: edgeError } = await supabase.functions.invoke('shortage-detector')
    if (edgeError) console.error('❌ shortage-detector Edge Function Error:', edgeError.message)
    else console.log('✅ shortage-detector Edge Function OK (Returned:', edgeData, ')')

    console.log('\n🎉 Verification Complete!')
}

verifyBackend().catch(console.error);
