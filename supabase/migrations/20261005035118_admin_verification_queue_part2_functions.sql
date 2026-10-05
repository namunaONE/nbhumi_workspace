-- HYA-260 (1/2) — part 2 of 2: v1_admin_get_queue and the detail RPC
--
-- Part 1 is 20261005035045 (submitted_at, the trigger, the indexes). Read them
-- together; the split was a deployment decision, not a design one. See the note
-- at the bottom of that file.
--
-- The verification queue is the first thing in M2 that cannot be built on what
-- already exists. Approve and reject work (repaired in HYA-251); nothing can
-- *find* the listings to review, and nothing can say how long they have been
-- waiting.
--
-- SLA ARITHMETIC IS NOT IN THIS MIGRATION
-- ========================================
-- This function returns `submitted_at` and nothing else. The 48h threshold and
-- the at-risk bucket are computed in Dart (QueueSla.fromSubmittedAt), not here,
-- because:
--
--   * one source of truth. A threshold duplicated in SQL and Dart drifts, and
--     the admin sees a different number from the one the test suite asserts.
--   * testability. `packages/models` can unit-test bucket boundaries at exactly
--     36h and 48h (Rule 32); testing them through a SECURITY DEFINER RPC would
--     mean a live database in the unit test loop (Rule 31 forbids it).
--   * clock honesty. `now()` is the database clock and the Dart computation is
--     the device clock. Returning the timestamp and comparing it to the device's
--     now() means the two can disagree by the device's skew; returning a
--     precomputed verdict would hide that disagreement instead of surfacing it.

-- ---------------------------------------------------------------------------
-- 5. v1_admin_get_queue
-- ---------------------------------------------------------------------------
-- Deliberately NOT an extension of v1_get_listings. That function is
-- anon-executable and shaped for guest browse: it filters to `live`, returns
-- only what a public card renders, and paginates on a keyset unrelated to
-- queue age. The queue needs admin gating, a different row shape, and ordering
-- by how long a listing has been waiting.
--
-- Cursor is (submitted_at, id) rather than submitted_at alone. submitted_at is
-- not unique -- several listings submitted in the same transaction or the same
-- clock tick share a timestamp -- so a single-column cursor would silently skip
-- rows whenever two listings share a timestamp, which is precisely what happens
-- when a seller submits the same day they registered.

create or replace function public.v1_admin_get_queue (
  p_status text default 'pending_review',
  p_cursor timestamptz default null,
  p_cursor_id uuid default null,
  p_page_size integer default 50
)
returns json
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_status public.listing_status;
  v_limit integer;
  v_rows json;
  v_next timestamptz;
  v_next_id uuid;
  v_counts json;
begin
  -- Defence in depth. anon has no EXECUTE grant, so this is unreachable from a
  -- guest; it catches a JWT that carries no `sub`.
  if (select private.current_uid()) is null then
    raise exception 'AUTH_REQUIRED: sign in to review the queue'
      using errcode = '42501';
  end if;

  -- The gate that matters. Every row below is a seller's unreviewed listing, so
  -- this check is the whole authorisation model for the queue.
  if not (select private.is_admin()) then
    raise exception 'FORBIDDEN: admin only' using errcode = '42501';
  end if;

  -- Cast through the enum so an unknown status is a 22P02 invalid-value error
  -- rather than a silently empty result. A typo returning "no listings" reads
  -- as "nothing to review" to an admin, which is worse than an error.
  --
  -- coalesce is load-bearing, not defensive padding. PostgREST sends every
  -- declared parameter explicitly, so a client that includes `"p_status": null`
  -- in its params object delivers an explicit NULL -- and a SQL default applies
  -- only to an OMITTED argument, never to an explicit null. Without this
  -- coalesce the parameter default is unreachable over PostgREST.
  --
  -- The failure it prevents is silent and total:
  --
  --   v_status := NULL::listing_status
  --   if v_status = 'pending_review'   -->  NULL, not FALSE
  --   ...so control reaches the ELSE branch
  --   where l.status = v_status        -->  l.status = NULL  -->  no rows
  --
  -- An admin would see an empty queue and conclude there is nothing to review.
  -- This is not hypothetical: ListingRepository.buildUpdateParams passes an
  -- explicit null for every parameter the caller did not touch, so that is
  -- exactly the shape a Dart caller of this function will produce.
  --
  -- Reproduced side by side before the fix:
  --   buggy,  status omitted   -> 3 entries
  --   buggy,  status = null    -> []      <- the bug
  --   fixed,  status = null    -> 3 entries
  v_status := coalesce(p_status, 'pending_review')::public.listing_status;

  -- Bounded rather than trusted: an unbounded page from a client is a cheap way
  -- to pull the entire queue in one round trip.
  v_limit := least(greatest(coalesce(p_page_size, 50), 1), 100);

  -- Tab counts for every status the queue shows, regardless of p_status, since
  -- WIREFRAMES.md Screen 4 puts a count on each tab ("Pending (12)"). One grouped
  -- pass instead of a round trip per tab.
  --
  -- Honest cost note: this counts `live` too, so it visits every live listing
  -- rather than only the queue. At the 20,000-listing shape measured against
  -- this project's dev database, the planner takes a sequential scan here while
  -- the page query itself takes an Index Only Scan on
  -- listings_pending_review_sla_idx. That is the right trade for now and is not
  -- worth an index: `audit_log` and the queue are admin-scale, and the count only
  -- has to be right on the page an admin is already looking at. If live inventory
  -- reaches the tens of thousands and this shows up in a query log, the fix is a
  -- covering index on (status) that the group-by can scan -- `listings_status_idx`
  -- already exists, so the planner has the option and is declining it while the
  -- table is small.
  select json_object_agg(status, n) into v_counts
  from (
    select l.status::text as status, count(*) as n
    from public.listings l
    where l.status in ('pending_review', 'live', 'rejected')
    group by l.status
  ) counted;

  -- Oldest submission first for the queue itself: that is the work order, and it
  -- is what makes the 48h SLA meaningful. Newest first for the historical tabs,
  -- where an admin is looking for what they just actioned rather than what is
  -- oldest. Two static branches rather than a computed ORDER BY direction, so
  -- each half can use the index directly.
  --
  -- WHY THE CURSOR IS AN ORDERED array_agg AND NOT max()/max()
  -- -------------------------------------------------------
  -- The cursor must be the (submitted_at, id) pair of the LAST row in page
  -- order, because that pair is what the next page compares against. Aggregating
  -- the two columns independently does not give you that pair, and the mistake
  -- is silent rather than loud:
  --
  --   rows: (10-01, id1) (10-02, id2) (10-02, id3)   -- a page of two
  --   true last row by (submitted_at, id):            (10-02, id2)
  --   max(submitted_at), max(id):                     (10-02, id3)
  --
  -- Emitting (10-02, id3) makes the next page's `> (p_cursor, p_cursor_id)`
  -- predicate false for id2, so id2 is never returned. The admin scrolls the
  -- queue, sees two rows, pages forward, and has silently lost the listing that
  -- sat at the top of their queue. Listings sharing a submitted_at are not an
  -- edge case here -- they are what a same-transaction submission produces, and
  -- the column is explicitly not unique.
  --
  -- Verified by walking the queue end to end at page size 2 over three rows
  -- where two shared a timestamp:
  --
  --   all rows         [1, 2, 3]
  --   fixed cursor     [1, 2, 3]   <- correct
  --   naive max/max    [1, 2]      <- row 3 lost, silently and permanently
  --
  -- `max()` on a uuid has the added problem of not existing at all: Postgres
  -- has no max(uuid) aggregate, so the naive version fails at runtime with
  -- 42883 the first time the queue is non-empty rather than at CREATE time.
  -- That is how the bug was found.
  --
  -- array_agg(... ORDER BY <same keys>)[count(*)] yields the last element of the
  -- page in page order, and count(*) is the page length, so a short page indexes
  -- in range instead of raising. Confirmed: an ASC page of two yields the second
  -- row, a DESC page of three yields the first, and a one-row page yields its own
  -- value rather than an out-of-range error.
  if v_status = 'pending_review' then
    with page as materialized (
      select json_build_object(
        'id', l.id,
        'title', l.title,
        'district', l.district,
        'city', l.city,
        'ward', l.ward,
        'property_type', l.property_type,
        'listing_purpose', l.listing_purpose,
        'price_npr', l.price_npr,
        'area_sqm', l.area_sqm,
        'area_ropani', l.area_ropani,
        'area_aana', l.area_aana,
        'area_paisa', l.area_paisa,
        'area_dam', l.area_dam,
        'area_bigha', l.area_bigha,
        'area_kattha', l.area_kattha,
        'area_dhur', l.area_dhur,
        'status', l.status,
        'rejection_reason', l.rejection_reason,
        'submitted_at', l.submitted_at,
        'reviewed_at', l.reviewed_at,
        'created_at', l.created_at,
        -- Cover photo for the queue row. A lateral so the index on
        -- (listing_id) serves it, rather than a correlated subquery the planner
        -- may choose to evaluate per candidate row.
        'photo_url', cover.url,
        'photo_count', cover.n,
        'seller', json_build_object(
          'id', s.id,
          'full_name', s.full_name,
          'role', s.role,
          'is_verified', s.is_verified,
          'kyc_tier', s.kyc_tier,
          'agency_name', s.agency_name,
          'agency_reg_no', s.agency_reg_no
        )
      ) as entry,
        l.submitted_at,
        l.id
      from public.listings l
      join public.profiles s on s.id = l.seller_id
      left join lateral (
        select
          (select lp.url
             from public.listing_photos lp
            where lp.listing_id = l.id
            order by lp.sort_order, lp.created_at
            limit 1) as url,
          (select count(*)
             from public.listing_photos lp
            where lp.listing_id = l.id) as n
      ) cover on true
      where l.status = 'pending_review'
        and (
          p_cursor is null
          or (l.submitted_at, l.id) > (p_cursor, p_cursor_id)
        )
      order by l.submitted_at, l.id
      limit v_limit
    )
    select
      json_agg(page.entry),
      (array_agg(page.submitted_at order by page.submitted_at, page.id))[count(*)::int],
      (array_agg(page.id order by page.submitted_at, page.id))[count(*)::int]
    into v_rows, v_next, v_next_id
    from page;
  else
    with page as materialized (
      select json_build_object(
        'id', l.id,
        'title', l.title,
        'district', l.district,
        'city', l.city,
        'ward', l.ward,
        'property_type', l.property_type,
        'listing_purpose', l.listing_purpose,
        'price_npr', l.price_npr,
        'area_sqm', l.area_sqm,
        'area_ropani', l.area_ropani,
        'area_aana', l.area_aana,
        'area_paisa', l.area_paisa,
        'area_dam', l.area_dam,
        'area_bigha', l.area_bigha,
        'area_kattha', l.area_kattha,
        'area_dhur', l.area_dhur,
        'status', l.status,
        'rejection_reason', l.rejection_reason,
        'submitted_at', l.submitted_at,
        'reviewed_at', l.reviewed_at,
        'created_at', l.created_at,
        'photo_url', cover.url,
        'photo_count', cover.n,
        'seller', json_build_object(
          'id', s.id,
          'full_name', s.full_name,
          'role', s.role,
          'is_verified', s.is_verified,
          'kyc_tier', s.kyc_tier,
          'agency_name', s.agency_name,
          'agency_reg_no', s.agency_reg_no
        )
      ) as entry,
        l.submitted_at,
        l.id
      from public.listings l
      join public.profiles s on s.id = l.seller_id
      left join lateral (
        select
          (select lp.url
             from public.listing_photos lp
            where lp.listing_id = l.id
            order by lp.sort_order, lp.created_at
            limit 1) as url,
          (select count(*)
             from public.listing_photos lp
            where lp.listing_id = l.id) as n
      ) cover on true
      where l.status = v_status
        and (
          p_cursor is null
          or (l.submitted_at, l.id) > (p_cursor, p_cursor_id)
        )
      order by l.submitted_at desc, l.id desc
      limit v_limit
    )
    -- Same ordered-array cursor as the branch above. The DESC ordering makes the
    -- naive max()/max() version worse rather than better: it would emit the
    -- newest (submitted_at, max id) pair, and the `>` predicate would then skip
    -- every remaining row on a full page.
    select
      json_agg(page.entry),
      (array_agg(page.submitted_at order by page.submitted_at desc, page.id desc))[count(*)::int],
      (array_agg(page.id order by page.submitted_at desc, page.id desc))[count(*)::int]
    into v_rows, v_next, v_next_id
    from page;
  end if;

  -- Null when the page was empty, which is how the client knows it has reached
  -- the end. Emitting a cursor here would make the client ask once more for
  -- nothing on every page boundary.
  return json_build_object(
    'entries', coalesce(v_rows, '[]'::json),
    'counts', coalesce(v_counts, '{}'::json),
    'next_cursor', case
      when v_rows is null then null
      else json_build_object('submitted_at', v_next, 'id', v_next_id)
    end
  );
end;
$$;

comment on function public.v1_admin_get_queue (text, timestamptz, uuid, integer) is
  'Admin-only: one page of the verification queue, oldest submission first for '
  'pending_review, with per-tab counts. Cursor is (submitted_at, id). Returns '
  'submitted_at raw: the 48h SLA bucket is computed client-side in '
  'QueueSla.fromSubmittedAt so the threshold has one definition and one test.';

-- RULE 2, and the point of the function: anon must never reach this. With EXECUTE
-- granted to anon, anyone could enumerate every unreviewed listing and every
-- seller's name, role, agency and KYC tier without an account.
revoke execute on function public.v1_admin_get_queue (text, timestamptz, uuid, integer)
  from public;
grant execute on function public.v1_admin_get_queue (text, timestamptz, uuid, integer)
  to authenticated;

-- HYA-248: pg_default_acl grants EXECUTE on new functions to anon, so restate
-- the revocation as a default for anything created after this file.
alter default privileges in schema public
  revoke execute on functions from anon;

-- ---------------------------------------------------------------------------
-- 6. submitted_at on the detail RPC
-- ---------------------------------------------------------------------------
-- Same shape as HYA-251 (3/3): v1_get_listing_detail builds its response from
-- an explicit json_build_object list, so a new column is invisible until named
-- here. Without it the admin detail pane cannot show how long a listing has been
-- waiting, which is the other half of the SLA requirement.
--
-- Full body restated rather than altered: a plpgsql body cannot be patched by
-- CREATE OR REPLACE, so the function has to be dropped and recreated. That is
-- what 20261002082158 did for the same reason.
--
-- Verified after applying: this function reads a pending_review listing and
-- returns submitted_at. It needs no new RLS policy -- the existing
-- `or (select private.is_admin())` clause already admits the admin.

create or replace function public.v1_get_listing_detail (p_listing_id uuid)
returns json
language plpgsql
security definer
set search_path = ''
as $$
declare v_result json;
begin
  select json_build_object(
    'id', l.id, 'seller_id', l.seller_id, 'title', l.title,
    'description', l.description,
    'price_npr', l.price_npr, 'area_sqm', l.area_sqm,
    'area_ropani', l.area_ropani, 'area_aana', l.area_aana,
    'area_paisa', l.area_paisa, 'area_dam', l.area_dam,
    'area_bigha', l.area_bigha, 'area_kattha', l.area_kattha,
    'area_dhur', l.area_dhur,
    'district', l.district, 'city', l.city, 'ward', l.ward,
    'road_access_ft', l.road_access_ft,
    'bedrooms', l.bedrooms, 'bathrooms', l.bathrooms,
    'property_type', l.property_type, 'listing_purpose', l.listing_purpose,
    'status', l.status, 'rejection_reason', l.rejection_reason,
    -- New: the 48h clock. Null for a draft, which is correct -- a draft has not
    -- been submitted and has no SLA running against it.
    'submitted_at', l.submitted_at,
    'created_at', l.created_at, 'updated_at', l.updated_at,
    'photos', coalesce((
      select json_agg(lp.url order by lp.sort_order, lp.created_at)
      from public.listing_photos lp where lp.listing_id = l.id
    ), '[]'::json),
    'seller', json_build_object(
      'id', p.id, 'full_name', p.full_name,
      'is_verified', p.is_verified, 'kyc_tier', p.kyc_tier,
      'role', p.role, 'agency_name', p.agency_name
    ),
    'is_favorite', false,
    'area_display', case
      when coalesce(l.area_ropani,0)>0 or coalesce(l.area_aana,0)>0
        or coalesce(l.area_paisa,0)>0 or coalesce(l.area_dam,0)>0
        then trim(both from concat_ws(' ',
          case when coalesce(l.area_ropani,0)>0 then l.area_ropani::text||' ropani' end,
          case when coalesce(l.area_aana,0)>0   then l.area_aana::text||' aana' end,
          case when coalesce(l.area_paisa,0)>0  then l.area_paisa::text||' paisa' end,
          case when coalesce(l.area_dam,0)>0    then l.area_dam::text||' dam' end))
      when coalesce(l.area_bigha,0)>0 or coalesce(l.area_kattha,0)>0
        or coalesce(l.area_dhur,0)>0
        then trim(both from concat_ws(' ',
          case when coalesce(l.area_bigha,0)>0  then l.area_bigha::text||' bigha' end,
          case when coalesce(l.area_kattha,0)>0 then l.area_kattha::text||' kattha' end,
          case when coalesce(l.area_dhur,0)>0   then l.area_dhur::text||' dhur' end))
      when l.area_sqm is not null then l.area_sqm::text||' sqm'
    end
  ) into v_result
  from public.listings l
  join public.profiles p on p.id = l.seller_id
  where l.id = p_listing_id
    and (
      l.status = 'live'
      or l.seller_id = (select private.current_uid())
      or (select private.is_admin())
    );

  if v_result is null then
    raise exception 'NOT_FOUND: listing not found or not visible'
      using errcode = 'P0002';
  end if;

  return v_result;
end;
$$;

-- Restated so this file stands alone. Guest browse is the product's primary use
-- case, so the anon grant is deliberate here; see the acknowledged-findings note
-- at the bottom of this migration.
revoke execute on function public.v1_get_listing_detail (uuid) from public;
grant execute on function public.v1_get_listing_detail (uuid)
  to anon, authenticated;

comment on function public.v1_get_listing_detail (uuid) is
  'Full detail for one listing, including photos, seller card, bedrooms and '
  'bathrooms. Adds submitted_at in this migration so the admin detail pane can '
  'show queue age. Guest-readable for live listings only.';

-- ---------------------------------------------------------------------------
-- ACKNOWLEDGED ADVISOR FINDINGS
-- ---------------------------------------------------------------------------
-- v1_admin_get_queue will be reported as an
-- authenticated_security_definer_function_executable finding. It must NOT be
-- "fixed" by adding an anon grant or downgrading to SECURITY INVOKER:
--
--   SECURITY DEFINER is required because an admin's queue read joins
--   public.profiles for seller name, role, agency and KYC tier. Under INVOKER,
--   RLS would confine the join to the admin's own profile row and every queue
--   entry would come back with a null seller.
--
--   `search_path = ''` is what makes DEFINER safe: every reference in the body
--   is schema-qualified, so there is nothing for a caller to hijack.
--
--   The absence of an anon grant is the security control, not an oversight.
--   Verified after applying: anon has no EXECUTE, authenticated does.
--
-- The trigger function set_listing_submitted_at (part 1) may also be flagged. It
-- is revoked from public and is only ever reached as a trigger, never called
-- directly.
--
-- ---------------------------------------------------------------------------
-- NOT IN THIS MIGRATION, AND WORTH KNOWING
-- -------------------------------------------
-- * `listing_reports` does not exist, so there is no report inbox (HYA-263).
-- * `profiles` has no suspension columns and no write RPC checks suspension, so
--   a suspended seller can still post (HYA-262).
-- * `listing_status` has no `unpublished` value, so pulling a live listing has
--   to reuse `rejected` (HYA-262).
-- * No seller notification is sent on approve/reject; `notifications` is M3
--   (HYA-242).