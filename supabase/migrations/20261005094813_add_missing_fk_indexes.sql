-- HYA-248 follow-up: cover the 5 foreign keys the performance linter
-- flags as unindexed. All IF NOT EXISTS so re-running converges, and so a
-- parallel migration adding any of these first does not conflict.
create index if not exists audit_log_actor_id_idx
  on public.audit_log (actor_id);
create index if not exists contact_logs_listing_id_idx
  on public.contact_logs (listing_id);
create index if not exists listings_district_city_idx
  on public.listings (district, city);
create index if not exists listings_city_slug_idx
  on public.listings (city_slug);
create index if not exists listings_reviewed_by_idx
  on public.listings (reviewed_by);

do $$
declare
  v_missing text[];
begin
  select array_agg(x.idx) into v_missing
  from (values
    ('audit_log_actor_id_idx'),
    ('contact_logs_listing_id_idx'),
    ('listings_district_city_idx'),
    ('listings_city_slug_idx'),
    ('listings_reviewed_by_idx')
  ) as x(idx)
  where not exists (
    select 1 from pg_indexes
    where schemaname = 'public' and indexname = x.idx
  );
  if v_missing is not null then
    raise exception 'MISSING INDEXES: %', v_missing
      using errcode = 'integrity_constraint_violation';
  end if;
  raise notice 'fk index cover ok: 5/5 present';
end;
$$;
