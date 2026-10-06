-- HYA-263 part 2: the report RPCs.
--
-- =============================================================================
-- v1_report_listing is SECURITY INVOKER, and that is a deliberate departure
-- from every other v1_* function in this schema.
-- =============================================================================
--
-- The other v1_admin_* and v1_create_* functions are SECURITY DEFINER because
-- they perform an action RLS forbids the caller from performing directly: an
-- admin updating listings.status, a user creating a listing under an insert
-- policy.
--
-- Reporting needs neither. A buyer inserting their own report row is exactly
-- what listing_reports_insert_own already permits. A SECURITY DEFINER function
-- runs as its owner, and the owner bypasses RLS -- so the function would skip
-- the very policy written to stop a seller reporting their own listing and stop
-- reports against listings the reporter cannot see. The rules would exist only
-- for a direct PostgREST write that nothing performs.
--
-- So the policy is the primary defence here and the function is a friendly
-- wrapper around it. That is the reverse of the admin functions, where the
-- function's own explicit check is the primary defence and the policy is the
-- backstop.

create or replace function public.v1_report_listing(
  p_listing_id uuid,
  p_reason text,
  p_details text default null
)
returns json
language plpgsql
security invoker
set search_path to ''
as $function$
declare
  v_uid uuid := (select private.current_uid());
  v_reason public.report_reason;
  v_details text;
  v_seller uuid;
  v_status public.listing_status;
  v_report_id uuid;
begin
  if v_uid is null then
    raise exception 'AUTH_REQUIRED: sign in to report a listing'
      using errcode = '42501';
  end if;

  if p_listing_id is null then
    raise exception 'VALIDATION_ERROR: listing id is required'
      using errcode = '22023';
  end if;

  -- Cast inside a block so an unknown reason becomes 22023 with a readable
  -- message, rather than 22P02 "invalid input value for enum" which tells the
  -- user nothing and which the Dart mapper has no case for.
  begin
    v_reason := p_reason::public.report_reason;
  exception when invalid_text_representation or null_value_not_allowed then
    raise exception
      'VALIDATION_ERROR: unknown report reason "%". Expected one of: %',
      coalesce(p_reason, 'null'),
      (select string_agg(e.enumlabel::text, ', ' order by e.enumsortorder)
         from pg_enum e
         join pg_type t on t.oid = e.enumtypid
         join pg_namespace n on n.oid = t.typnamespace
        where n.nspname = 'public'
          and t.typname = 'report_reason')
      using errcode = '22023';
  end;

  v_details := nullif(btrim(coalesce(p_details, '')), '');

  if length(v_details) > 2000 then
    raise exception
      'VALIDATION_ERROR: details must be 2000 characters or fewer, got %',
      length(v_details)
      using errcode = '22023';
  end if;

  -- 'other' with nothing to say is not actionable. The CHECK constraint
  -- enforces this too; checking here turns a 23514 into a message a user can
  -- act on.
  if v_reason = 'other' and v_details is null then
    raise exception
      'VALIDATION_ERROR: choose a specific reason, or describe the problem'
      using errcode = '22023';
  end if;

  select l.seller_id, l.status
    into v_seller, v_status
    from public.listings l
   where l.id = p_listing_id;

  if not found then
    raise exception 'NOT_FOUND: no listing with that id'
      using errcode = 'P0002';
  end if;

  if v_seller = v_uid then
    raise exception 'VALIDATION_ERROR: you cannot report your own listing'
      using errcode = '22023';
  end if;

  if v_status <> 'live' then
    raise exception
      'VALIDATION_ERROR: only a published listing can be reported (this one is %)',
      v_status
      using errcode = '22023';
  end if;

  -- The insert goes through listing_reports_insert_own, which re-checks every
  -- rule above. This function is the readable error surface; the policy is what
  -- actually holds.
  begin
    insert into public.listing_reports (listing_id, reporter_id, reason, details)
    values (p_listing_id, v_uid, v_reason, v_details)
    returning id into v_report_id;
  exception when unique_violation then
    raise exception
      'VALIDATION_ERROR: you have already reported this listing'
      using errcode = '22023';
  end;

  return json_build_object(
    'report_id', v_report_id,
    'listing_id', p_listing_id,
    'reason', v_reason::text,
    'details', v_details,
    'status', 'open',
    'created_at', now()
  );
end;
$function$;

-- =============================================================================
-- Admin reads: mirrors v1_admin_get_queue's shape, cursor and coalesce rules
-- exactly, so the two admin queues behave identically.
-- =============================================================================

create or replace function public.v1_admin_get_reports(
  p_status text default null,
  p_cursor timestamptz default null,
  p_cursor_id uuid default null,
  p_page_size integer default null
)
returns json
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_status public.report_status;
  v_limit integer;
  v_rows json;
  v_next timestamptz;
  v_next_id uuid;
  v_counts json;
begin
  if (select private.current_uid()) is null then
    raise exception 'AUTH_REQUIRED: sign in to review reports'
      using errcode = '42501';
  end if;

  if not (select private.is_admin()) then
    raise exception 'FORBIDDEN: admin only' using errcode = '42501';
  end if;

  -- coalesce is load-bearing, same reason as the listing queue: PostgREST sends
  -- every declared parameter explicitly and a SQL default only applies to an
  -- omitted argument. Without it p_status = NULL would reach the filter and
  -- match nothing, and the admin would conclude there are no reports.
  v_status := coalesce(p_status, 'open')::public.report_status;

  v_limit := least(greatest(coalesce(p_page_size, 50), 1), 100);

  select json_object_agg(status, n) into v_counts
  from (
    select r.status::text as status, count(*) as n
    from public.listing_reports r
    group by r.status
  ) counted;

  -- Cursor is (created_at, id) of the last row in page order, taken from an
  -- ordered array rather than max()/max() taken independently. Independent
  -- maxima yield a pair that never existed as a row and silently skip reports
  -- whenever two share a created_at -- the bug the listing queue had.
  --
  -- Oldest first. An open report is a piece of work waiting for a person, and
  -- the oldest is the one a buyer has been waiting longest on. Newest-first
  -- would let a steady trickle of fresh reports starve the backlog indefinitely.
  with page as materialized (
    select json_build_object(
      'id', r.id,
      'listing_id', r.listing_id,
      'reason', r.reason::text,
      'details', r.details,
      'status', r.status::text,
      'created_at', r.created_at,
      'resolved_at', r.resolved_at,
      -- Only when it helps: an admin deciding what to open next needs to know
      -- the listing's title and price without a second round trip.
      'listing', json_build_object(
        'id', l.id,
        'title', l.title,
        'price_npr', l.price_npr,
        'status', l.status::text,
        'district', l.district,
        'city', l.city,
        'seller_id', l.seller_id
      ),
      -- The reporter is named deliberately. An admin needs to see that one
      -- buyer filed four reports this week, which is the abuse the unique index
      -- limits but does not prevent. profiles_select_own_or_admin already admits
      -- admins to this row.
      'reporter', json_build_object(
        'id', rep.id,
        'full_name', rep.full_name,
        'role', rep.role::text,
        'is_verified', rep.is_verified
      )
    ) as entry,
    r.created_at,
    r.id
    from public.listing_reports r
    join public.listings l on l.id = r.listing_id
    join public.profiles rep on rep.id = r.reporter_id
    where r.status = v_status
      and (
        p_cursor is null
        or (r.created_at, r.id) > (p_cursor, p_cursor_id)
      )
    order by r.created_at, r.id
    limit v_limit
  )
  select
    json_agg(page.entry),
    (array_agg(page.created_at order by page.created_at, page.id))[count(*)::int],
    (array_agg(page.id       order by page.created_at, page.id))[count(*)::int]
  into v_rows, v_next, v_next_id
  from page;

  return json_build_object(
    'entries', coalesce(v_rows, '[]'::json),
    'counts', coalesce(v_counts, '{}'::json),
    'next_cursor', case
      when v_rows is null then null
      else json_build_object('created_at', v_next, 'id', v_next_id)
    end
  );
end;
$function$;

-- =============================================================================
-- Resolution. Writes the audit_log row in the same transaction as the status
-- change (Rule 8), so a report can never be resolved without a trace.
-- =============================================================================

create or replace function public.v1_admin_resolve_report(
  p_report_id uuid,
  p_resolution text
)
returns json
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_uid uuid := (select private.current_uid());
  v_status public.report_status;
  v_listing uuid;
begin
  if v_uid is null then
    raise exception 'AUTH_REQUIRED: sign in to resolve reports'
      using errcode = '42501';
  end if;

  if not (select private.is_admin()) then
    raise exception 'FORBIDDEN: admin only' using errcode = '42501';
  end if;

  if p_report_id is null then
    raise exception 'VALIDATION_ERROR: report id is required'
      using errcode = '22023';
  end if;

  -- 'open' is not a resolution. Refusing it here rather than allowing a no-op
  -- update means a double-click cannot write a second audit row claiming the
  -- report was resolved twice.
  if p_resolution is null
     or p_resolution not in ('actioned', 'dismissed') then
    raise exception
      'VALIDATION_ERROR: resolution must be ''actioned'' or ''dismissed'', got "%"',
      coalesce(p_resolution, 'null')
      using errcode = '22023';
  end if;

  v_status := p_resolution::public.report_status;

  select r.status, r.listing_id
    into v_status, v_listing
    from public.listing_reports r
   where r.id = p_report_id
   for update;

  if not found then
    raise exception 'NOT_FOUND: no report with that id'
      using errcode = 'P0002';
  end if;

  if v_status <> 'open' then
    raise exception
      'VALIDATION_ERROR: this report is already % and cannot be resolved again',
      v_status
      using errcode = '22023';
  end if;

  update public.listing_reports
     set status = v_status,
         resolved_at = now(),
         resolved_by = v_uid
   where id = p_report_id;

  insert into public.audit_log (actor_id, action, entity_type, entity_id, details)
  values (
    v_uid,
    'report_' || p_resolution,
    'report',
    p_report_id,
    json_build_object('to', p_resolution, 'listing_id', v_listing)
  );

  return json_build_object(
    'report_id', p_report_id,
    'listing_id', v_listing,
    'status', v_status::text,
    'resolved_at', now(),
    'resolved_by', v_uid
  );
end;
$function$;

-- -----------------------------------------------------------------------------
-- Grants
--
-- Revoked from anon first: HYA-248 established that a SECURITY DEFINER function
-- reachable by anon is a standing vulnerability, and v1_report_listing being
-- INVOKER does not make the other two safe by association.
-- -----------------------------------------------------------------------------

revoke execute on function public.v1_report_listing (uuid, text, text) from public;
revoke execute on function public.v1_admin_get_reports (text, timestamptz, uuid, integer) from public;
revoke execute on function public.v1_admin_resolve_report (uuid, text) from public;

grant execute on function public.v1_report_listing (uuid, text, text) to authenticated;
grant execute on function public.v1_admin_get_reports (text, timestamptz, uuid, integer) to authenticated;
grant execute on function public.v1_admin_resolve_report (uuid, text) to authenticated;

comment on function public.v1_report_listing(uuid, text, text) is
  'Files a buyer report against a listing (HYA-263). SECURITY INVOKER on purpose: '
  'a DEFINER function runs as its owner and would bypass listing_reports_insert_own, '
  'which is the rule that stops a seller reporting their own listing. Returns 22023 '
  'with a readable message for a bad reason, a duplicate, a self-report or a '
  'non-live listing.';
comment on function public.v1_admin_get_reports(text, timestamptz, uuid, integer) is
  'One page of reports for the admin reports queue, oldest first. Cursor is '
  '(created_at, id) taken from an ordered array, for the same reason the listing '
  'queue does it: independent maxima skip rows that share a created_at.';
comment on function public.v1_admin_resolve_report(uuid, text) is
  'Resolves an open report and writes the audit_log row in the same transaction '
  '(Rule 8). Only ''actioned'' or ''dismissed''; a report that is already resolved '
  'is refused with 22023 rather than silently re-resolved.';