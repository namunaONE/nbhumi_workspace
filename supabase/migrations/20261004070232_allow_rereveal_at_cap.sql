-- HYA-252 (2/2) — permit re-reveal of an already-revealed contact at the cap
--
-- Corrects the rate-limit check in v1_contact_seller, introduced earlier in the
-- same session and not yet released.
--
-- The original counted the buyer's reveals before deciding, so reaching ten
-- locked the buyer out of everything — including re-reading a contact they had
-- already been given. A verified test:
--
--   re-reveal same listing  ->  refused, PN001 RATE_LIMITED
--
-- That is both bad behaviour and a leak of nothing: re-revealing returns
-- details the buyer already holds, so allowing it cannot assist scraping. What
-- must stay capped is revealing a contact for the first time, which is the only
-- act that hands over new information.
--
-- The check therefore runs only when the upsert actually inserted a new row.
-- `xmax = 0` in the RETURNING clause distinguishes a fresh insert from an
-- update, so an existing pair refreshes its timestamps without being counted.
--
-- The count runs after the insert and compares with `> 10`, not `>= 10`,
-- because the new row is already visible to the query. When the eleventh
-- distinct reveal trips the cap, the RAISE rolls the insert back with the
-- statement, so a refused reveal leaves no row behind.

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
  v_revealed_at timestamptz;
  v_expires_at timestamptz;
  v_inserted boolean;
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

  v_expires_at := now() + interval '24 hours';

  insert into public.contact_logs as cl (buyer_id, listing_id, expires_at)
  values (v_uid, p_listing_id, v_expires_at)
  on conflict (buyer_id, listing_id) do update
    set revealed_at = now(),
        expires_at = excluded.expires_at
  returning cl.revealed_at,
            cl.expires_at,
            (cl.xmax = 0)
    into v_revealed_at, v_expires_at, v_inserted;

  -- Only a first-time reveal is capped. Re-revealing hands back nothing the
  -- buyer does not already hold.
  if v_inserted then
    select count(*) into v_reveals_today
    from public.contact_logs cl
    where cl.buyer_id = v_uid
      and cl.revealed_at > now() - interval '1 day';

    if v_reveals_today > 10 then
      raise exception 'RATE_LIMITED: contact reveal limit reached'
        using errcode = 'PN001';
    end if;
  end if;

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

revoke execute on function public.v1_contact_seller (uuid) from public;
grant execute on function public.v1_contact_seller (uuid) to authenticated;

comment on function public.v1_contact_seller (uuid) is
  'Reveals a live listing''s seller contact to a signed-in buyer, at most 10 '
  'first-time reveals per rolling 24 hours, and records the reveal. '
  'Re-revealing a contact already held is always allowed.';