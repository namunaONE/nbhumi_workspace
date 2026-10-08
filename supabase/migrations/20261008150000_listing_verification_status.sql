-- HYA-265 (Tier 3) — public per-listing verification signal.
--
-- WHAT THIS DOES
-- ==============
-- `v1_listing_verification_status(p_listing_id)` answers whether a listing
-- has a *verified* Tier-3 document (lalpurja / tiro_rasid row in
-- kyc_documents with this listing_id). The detail screen renders the
-- "Verified Listing" badge from it. No new table, no RLS change:
-- kyc_documents stays owner-or-admin readable, and this SECURITY DEFINER
-- function is the only public peephole.
--
-- HONESTY BOUNDARY (deliberate)
-- =============================
-- * `{verified: true}` is returned for a listing ONLY when the caller may
--   see the listing at all: live listings for everyone (including guests),
--   any status for the owning seller, everything for admins. Otherwise the
--   answer is `{verified: false}` with no timestamp — a probe for hidden
--   listings learns nothing beyond what browse already shows.
-- * Output is `{verified, reviewed_at}` and nothing else: no doc type, no
--   storage path, no reviewer. The client copy states doc-check only, never
--   legal/title verification (HYA-265 description).
-- * Guests may call it: the badge is a public trust signal on a public
--   page, so EXECUTE goes to anon + authenticated (the HYA-248 default
--   revocation is re-granted explicitly here, not inherited).
--
-- VERIFY AT APPLY TIME (HYA-283 owns the apply queue)
-- ===================================================
--   1. As anon: `select public.v1_listing_verification_status('<live-id>');`
--      → `{verified: false}` (no docs yet).
--   2. Insert a verified kyc_documents row for that listing (admin RPC),
--      call again → `{verified: true, reviewed_at: ...}`.
--   3. As anon against a draft id → `{verified: false}` regardless of docs.

create or replace function public.v1_listing_verification_status(
  p_listing_id uuid
)
returns json
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_uid uuid := (select private.current_uid());
  v_status public.listing_status;
  v_seller_id uuid;
  v_verified boolean := false;
  v_reviewed_at timestamptz;
begin
  select l.status, l.seller_id into v_status, v_seller_id
  from public.listings l
  where l.id = p_listing_id;

  -- Missing, unpublished-not-yours, and never-verified all answer alike:
  -- existence and review state of a hidden listing are not oracle-able.
  if not found then
    return json_build_object('verified', false);
  end if;

  select true, max(d.reviewed_at)
    into v_verified, v_reviewed_at
  from public.kyc_documents d
  where d.listing_id = p_listing_id
    and d.status = 'verified'
  group by d.listing_id;

  if v_verified is distinct from true then
    return json_build_object('verified', false);
  end if;

  if v_status = 'live'
     or v_seller_id = v_uid
     or (select public.is_admin()) then
    return json_build_object(
      'verified', true,
      'reviewed_at', v_reviewed_at
    );
  end if;
  return json_build_object('verified', false);
end;
$$;

comment on function public.v1_listing_verification_status (uuid) is
  'HYA-265: public per-listing Tier-3 signal. {verified, reviewed_at} only '
  'when the caller may see the listing (live, owner, admin); {verified:false} '
  'otherwise. Doc-check signal, never legal verification.';

revoke execute on function public.v1_listing_verification_status (uuid)
  from public;
grant execute on function public.v1_listing_verification_status (uuid)
  to anon, authenticated;
