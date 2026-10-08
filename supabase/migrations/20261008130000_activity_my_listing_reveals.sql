-- HYA-297 — v1_my_listing_reveals: seller-side interest stats.
--
-- The Activity page shows sellers how much interest their listings get.
-- `contact_logs` SELECT is buyer-own + admin only (see
-- 20261004070057_add_contact_logs_and_contact_seller.sql), so a seller cannot
-- read reveals of their own listings through RLS. This SECURITY DEFINER RPC
-- is the only path, following the repo's RPC-for-others'-rows pattern.
--
-- Privacy boundary (deliberate): rows carry per-listing aggregates
-- (reveal_count, last_revealed_at) and NO buyer identity. The seller learns
-- that interest exists without learning who viewed — buyer names/phones stay
-- undisclosed. Disclosing buyer identities is a follow-up requiring a Privacy
-- Act 2075 purpose-limitation review, not part of this function.

create or replace function public.v1_my_listing_reveals()
returns table (
  listing_id uuid,
  title text,
  reveal_count bigint,
  last_revealed_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select
    l.id,
    l.title,
    count(cl.id),
    max(cl.revealed_at)
  from public.listings l
  left join public.contact_logs cl on cl.listing_id = l.id
  where l.seller_id = (select private.current_uid())
  group by l.id, l.title
  having count(cl.id) > 0
  order by max(cl.revealed_at) desc;
$$;

-- Rule 2 pattern (see v1_contact_seller): anon must not execute. The revoke
-- covers the OR REPLACE re-creation; the grant admits signed-in callers, and
-- the function body confines every row to the caller's own listings.
revoke execute on function public.v1_my_listing_reveals() from public;
grant execute on function public.v1_my_listing_reveals() to authenticated;

comment on function public.v1_my_listing_reveals() is
  'Per-listing contact-reveal aggregates for the caller''s own listings. '
  'Counts and latest timestamp only — no buyer identity (privacy boundary).';
