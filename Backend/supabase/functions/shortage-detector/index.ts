import { createClient } from 'jsr:@supabase/supabase-js@2'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

const supabase = createClient(supabaseUrl, supabaseKey);

Deno.serve(async (req) => {
  try {
    const { data, error } = await supabase.rpc('count_active_by_category_wilaya');

    if (error || !data) {
      console.error(error);
      return new Response(JSON.stringify({ error: error?.message }), { status: 500, headers: { "Content-Type": "application/json" } });
    }

    const notifications = [];

    for (const row of data) {
      if (row.active_count < 3) {
        // Upsert alert
        await supabase.from('shortage_alerts').upsert({
          wilaya_id: row.wilaya_id,
          sector_id: row.sector_id,
          category_id: row.category_id,
          active_supplier_count: row.active_count,
          status: 'active',
          triggered_at: new Date().toISOString()
        }, { onConflict: 'wilaya_id,category_id' });

        notifications.push(notifyBuyers(row.wilaya_id, row.sector_id, row.category_name));
      } else {
        // Resolve alert if stock >= 3
        await supabase.from('shortage_alerts')
          .update({ status: 'resolved' })
          .eq('wilaya_id', row.wilaya_id)
          .eq('category_id', row.category_id)
          .eq('status', 'active');
      }
    }

    await Promise.all(notifications);

    return new Response(JSON.stringify({ success: true, count: data.length }), { status: 200, headers: { "Content-Type": "application/json" } });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), { status: 500, headers: { "Content-Type": "application/json" } });
  }
});

async function notifyBuyers(wilayaId: number, sectorId: number, categoryName: string) {
  const { data: buyers } = await supabase
    .from('users')
    .select('expo_push_token')
    .eq('wilaya_id', wilayaId)
    .contains('sector_ids', [sectorId])
    .not('expo_push_token', 'is', null);

  if (!buyers || buyers.length === 0) return;

  const messages = buyers.map((b: any) => ({
    to: b.expo_push_token,
    title: `Pénuries: ${categoryName}`,
    body: 'Stock critique dans votre wilaya. Réagissez maintenant.',
    data: { screen: 'alerts' }
  }));

  try {
    await fetch('https://exp.host/--/api/v2/push/send', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(messages)
    });
  } catch (error) {
    console.error("Push notification failed", error);
  }
}
