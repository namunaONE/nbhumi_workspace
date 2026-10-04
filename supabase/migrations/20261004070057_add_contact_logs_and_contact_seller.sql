-- HYA-252 — contact_logs + v1_contact_seller
--
-- Closes G-05. Listing detail renders a seller card with no phone or email,
-- because publishing them on a public endpoint would let anyone scrape the
-- contacts of every seller on the platform. This migration is the only way to
-- obtain them, and it makes the buyer accountable for the reveal:
--
--   * the caller must be signed in, so every reveal is attributable
--   * the reveal is written to contact_logs with an expiry
--   * a per-buyer daily cap stops bulk scraping by simply paging through ids
--
-- Two design decisions worth stating, because both are choices rather than
-- consequences:
--
-- 1. The daily cap counts contact_logs rows, and re-revealing a listing you have
--    already revealed UPDATES that row rather than inserting a second one. So
--    re-reading a contact you already hold is free and does not consume quota,
--    while browsing ten new listings does. Counting inserts instead would let a
--    user lock themselves out by tapping the same button twice.
--
-- 2. expiry is 24 hours, matching the rate-limit window. A revealed contact is
--    cached on the buyer's device for that long. There is no separate "how long
--    is a reveal valid" policy to keep in sync.

-- ---------------------------------------------------------------------------
-- contact_logs
-- ---------------------------------------------------------------------------
-- RULE 3: RLS ships in the same migration as the table.

create table if not exists public.contact_logs (
  id uuid primary key default gen_random_uuid(),
  buyer_id uuid not null references auth.users (id) on delete cascade,
  listing_id uuid not null references public.listings (id) on delete cascade,
  revealed_at timestamptz not null default now(),
  expires_at timestamptz not null,

  -- One reveal row per (buyer, listing). This is what makes the re-reveal
  -- upsert below idempotent instead of accumulating a row per tap.
  constraint contact_logs_buyer_listing_unique unique (buyer_id, listing_id)
);

comment on table public.contact_logs is
  'Audit trail of seller-contact reveals. One row per buyer/listing pair; '
  're-revealing refreshes revealed_at and expires_at. Never exposed to the '
  'client for writes.';

-- The rate-limit query counts this buyer's rows in the last day. Leading with
-- buyer_id lets the index serve it as an index-only scan.
create index if not exists contact_logs_buyer_recent_idx
  on public.contact_logs (buyer_id, revealed_at desc);

alter table public.contact_logs enable row level security;

-- A buyer may read their own reveal history; an admin may read any. There is no
-- INSERT, UPDATE or DELETE policy on purpose: writes happen only inside the
-- SECURITY DEFINER function below, which runs as the table owner. A client
-- INSERT policy would let a buyer forge a reveal log.
create policy "contact_logs_select_own"
  on public.contact_logs
  for select
  to authenticated
  using (buyer_id = (select private.current_uid()));

create policy "contact_logs_select_admin"
  on public.contact_logs
  for select
  to authenticated
  using ((select private.is_admin()));

-- ---------------------------------------------------------------------------
-- v1_contact_seller
-- ---------------------------------------------------------------------------

create or replace function public.v1_contact_seller (p_listing_id uuid)
returns json
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select private.current_uid());
  v_seller_id uuid;
  v_status public.listing_status;
  v_reveals_today integer;
  -- `timestamptz`, not `timestamptz with time zone`: the long form is not a
  -- legal PL/pgSQL variable type.
  v_revealed_at timestamptz;
  v_expires_at timestamptz;
  v_result json;
begin
  -- Defence in depth. anon has no EXECUTE grant, so this is unreachable from a
  -- guest; it catches a JWT that carries no `sub`.
  if v_uid is null then
    raise exception 'AUTH_REQUIRED: sign in to contact a seller'
      using errcode = '42501';
  end if;

  select l.seller_id, l.status into v_seller_id, v_status
  from public.listings l
  where l.id = p_listing_id;

  -- Missing, unpublished and not-yours all answer identically so a client
  -- cannot probe for the existence of a listing it may not see.
  if v_status is distinct from 'live' then
    raise exception 'NOT_FOUND: listing not found or not available'
      using errcode = 'P0002';
  end if;

  -- A seller has their own phone number already. Denying this also stops the
  -- daily cap being burned on self-reveals.
  if v_seller_id = v_uid then
    raise exception 'FORBIDDEN: cannot reveal your own contact'
      using errcode = '42501';
  end if;

  select count(*) into v_reveals_today
  from public.contact_logs cl
  where cl.buyer_id = v_uid
    and cl.revealed_at > now() - interval '1 day';

  -- >= rather than >: the eleventh distinct listing in a rolling day fails.
  -- Re-revealing a listing already counted above does not add a row, so it
  -- cannot push the buyer over the line.
  if v_reveals_today >= 10 then
    raise exception 'RATE_LIMITED: contact reveal limit reached'
      using errcode = 'PN001';
  end if;

  v_expires_at := now() + interval '24 hours';

  insert into public.contact_logs as cl (buyer_id, listing_id, expires_at)
  values (v_uid, p_listing_id, v_expires_at)
  on conflict (buyer_id, listing_id) do update
    set revealed_at = now(),
        expires_at = excluded.expires_at
  returning cl.revealed_at, cl.expires_at
    into v_revealed_at, v_expires_at;

  select json_build_object(
    'listing_id', p_listing_id,
    'seller_id', v_seller_id,
    'seller_name', p.full_name,
    'seller_phone', p.phone,
    'seller_email', p.email,
    'agency_name', p.agency_name,
    'is_verified', p.is_verified,
    'revealed_at', v_revealed_at,
    'expires_at', v_expires_at
  ) into v_result
  from public.profiles p
  where p.id = v_seller_id;

  if v_result is null then
    raise exception 'NOT_FOUND: seller profile missing'
      using errcode = 'P0002';
  end if;

  return v_result;
end;
$$;

-- RULE 2, and the whole point of the exercise: anon must not be able to call
-- this. With EXECUTE granted to anon, anyone could enumerate listing ids and
-- scrape every seller's phone number with no session at all.
revoke execute on function public.v1_contact_seller (uuid) from public;
grant execute on function public.v1_contact_seller (uuid) to authenticated;

comment on function public.v1_contact_seller (uuid) is
  'Reveals a live listing''s seller contact to a signed-in buyer, at most 10 '
  'distinct listings per rolling 24 hours, and records the reveal.';

-- ---------------------------------------------------------------------------
-- Default privileges
-- ---------------------------------------------------------------------------
-- HYA-248 found that pg_default_acl grants EXECUTE on new functions to anon.
-- This migration only covers its own function, so extend that revocation to
-- cover anything created later. Harmless if the earlier fix already applied it.

alter default privileges in schema public
  revoke execute on functions from anon;

-- ---------------------------------------------------------------------------
-- ACKNOWLEDGED ADVISITOR FINDINGS
-- ---------------------------------------------------------------------------
-- v1_contact_seller will appear as a seventh
-- anon/authenticated_security_definer_function_executable finding if the advisor
-- ever checks it. It must NOT be "fixed" by adding an anon grant or by
-- downgrading to SECURITY INVOKER:
--
--   SECURITY DEFINER is required because the buyer must not have SELECT on
--   public.profiles. An invoker function would return nothing at all, since
--   profiles is readable only by its owner and by admins.
--
--   The absence of an anon grant is the security control, not an oversight.
--   Verified by test: as anon the call fails with 42501.