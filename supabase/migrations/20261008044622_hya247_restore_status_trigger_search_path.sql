-- HYA-247 follow-up: restore search_path on enforce_listing_status_transition.
--
-- The HYA-262 suspension migration redefined this trigger function without
-- SET search_path, regressing the HYA-247 hardening (live advisor
-- function_search_path_mutable x1). Re-pin it; purely additive, no behavior
-- change to the transition logic itself.

alter function public.enforce_listing_status_transition()
  set search_path = public;

do $$
begin
  if exists (
    select 1
    from pg_proc p
    where p.proname = 'enforce_listing_status_transition'
      and p.pronamespace = 'public'::regnamespace
      and p.proconfig is null
  ) then
    raise exception 'SEARCH_PATH STILL MUTABLE on enforce_listing_status_transition'
      using errcode = 'integrity_constraint_violation';
  end if;
  raise notice 'search_path pinned on enforce_listing_status_transition';
end;
$$;
