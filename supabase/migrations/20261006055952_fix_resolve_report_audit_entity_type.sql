-- HYA-263 part 2 fix 2: the audit_log entity_type for a report resolution.
--
-- The first attempt wrote entity_type = 'report', which
-- audit_log_entity_type_check refuses:
--
--   CHECK (entity_type = ANY (ARRAY['listing','user','kyc']))
--
-- Widening that CHECK to admit 'report' would work, but 'listing' is both
-- simpler and more useful, so no schema change is needed:
--
--   * an admin action about a report IS an action about a listing. The report is
--     an attribute of the listing, not a peer entity.
--   * it means report resolutions appear in the listing's existing audit trail
--     automatically. AdminQueueEntry's trail already filters
--     entity_type='listing' by entity_id, so the panel built in HYA-260 starts
--     showing report outcomes with no change to the Dart at all.
--   * finding every report resolution is then a filter on action
--     ('report_actioned', 'report_dismissed') rather than on entity_type.
--
-- entity_id is therefore the LISTING id, and the report id moves into details so
-- nothing is lost.

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

  -- entity_type 'listing', entity_id the LISTING, report_id in details.
  -- See the header for why this is not 'report'.
  insert into public.audit_log (actor_id, action, entity_type, entity_id, details)
  values (
    v_uid,
    'report_' || p_resolution,
    'listing',
    v_listing,
    json_build_object('report_id', p_report_id, 'to', p_resolution)
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