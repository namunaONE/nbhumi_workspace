-- HYA-263 part 2 fix: v1_admin_resolve_report had a single status variable doing
-- two jobs.
--
-- `v_status := p_resolution::report_status` parsed the requested resolution into
-- v_status, and then `select r.status ... into v_status` overwrote it with the
-- row's *current* status ('open'). The guard `if v_status <> 'open'` therefore read
-- the row's status and always passed, and the UPDATE wrote
-- `status = v_status` -- that is, 'open' -- while also setting resolved_at and
-- resolved_by.
--
-- Caught by reports_resolution_consistent, which refused the row:
--
--   ERROR: 23514: violates check constraint "reports_resolution_consistent"
--
-- That constraint is the reason this was a failed migration rather than a
-- silently corrupted report: without it the report would have been left 'open'
-- with a resolution timestamp and a resolver, and an admin re-resolving it later
-- would have hit the same no-op forever.
--
-- Rule 1: this is a new file rather than an edit to the applied migration.

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

  -- Two distinct variables, which is the whole fix. v_resolution is what the
  -- caller asked for; v_current is what the row says today. Collapsing them into
  -- one is what made the UPDATE a no-op that still stamped a resolution.
  v_resolution public.report_status;
  v_current public.report_status;
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

  if p_resolution is null
     or p_resolution not in ('actioned', 'dismissed') then
    raise exception
      'VALIDATION_ERROR: resolution must be ''actioned'' or ''dismissed'', got "%"',
      coalesce(p_resolution, 'null')
      using errcode = '22023';
  end if;

  v_resolution := p_resolution::public.report_status;

  -- FOR UPDATE takes a row lock, so two admins resolving the same report
  -- serialise here: the second sees the first's committed status and is refused
  -- by the guard below rather than overwriting it.
  select r.status, r.listing_id
    into v_current, v_listing
    from public.listing_reports r
   where r.id = p_report_id
   for update;

  if not found then
    raise exception 'NOT_FOUND: no report with that id'
      using errcode = 'P0002';
  end if;

  if v_current <> 'open' then
    raise exception
      'VALIDATION_ERROR: this report is already % and cannot be resolved again',
      v_current
      using errcode = '22023';
  end if;

  update public.listing_reports
     set status = v_resolution,
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
    'status', v_resolution::text,
    'resolved_at', now(),
    'resolved_by', v_uid
  );
end;
$function$;

comment on function public.v1_admin_resolve_report(uuid, text) is
  'Resolves an open report and writes the audit_log row in the same transaction '
  '(Rule 8). Only ''actioned'' or ''dismissed''; an already-resolved report is '
  'refused with 22023 rather than silently re-resolved. Corrected in a follow-up '
  'migration: a single status variable was doing two jobs, so the UPDATE wrote '
  'the row''s existing status instead of the requested one.';