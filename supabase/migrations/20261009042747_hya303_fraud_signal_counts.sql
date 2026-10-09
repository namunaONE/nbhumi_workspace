-- HYA-303: batch fraud-warning counts for queue rows.
--
-- `v1_admin_fraud_signals` answers one listing; the queue page holds fifty.
-- Fifty round trips per page is rude, and re-implementing the checks here
-- would drift from the single-listing answers on the detail pane. So this
-- function loops over the ids and reuses the canonical function per id:
-- one round trip, zero logic drift, and a row flag can never disagree with
-- the pane it opens.
--
-- Ledger note: 20261009042617 holds the first iteration, whose per-row
-- handler caught `raise_exception` (P0001) -- but the wrapped function
-- raises P0002 (`no_data_found`), so unknown ids still failed the page.
-- 20261009042747 (this file) narrows the handler to `no_data_found` and
-- skips null ids. Same function, corrected; both rows stay as history.
--
-- ## Response shape
--
-- `{"<listing-uuid>": <warning-count>, ...}` for every id asked about,
-- including explicit zeros. Unknown ids are skipped, not errors: a listing
-- actioned between the page load and this call simply drops out, and the
-- row keeps no flag rather than failing the whole page.
--
-- ## Rule compliance
--
-- * Rule 1: new file; existing functions untouched.
-- * Rules 4/8: read-only, no status transitions, no audit rows.
-- * Rule 38: same mapped codes as the wrapped function (42501/22023/P0002
--   surface per id through the wrapper's own guards, not per-row).
--
-- ## Replay safety
--
-- `create or replace`; grants re-issued idempotently below.

create or replace function public.v1_admin_fraud_signal_counts(
  p_listing_ids uuid[]
)
returns jsonb
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_uid uuid := (select private.current_uid());
  v_out jsonb := '{}'::jsonb;
  v_id uuid;
  v_res jsonb;
  v_warnings int;
begin
  if v_uid is null then
    raise exception 'AUTH_REQUIRED: sign in to view fraud signals'
      using errcode = '42501';
  end if;

  if not (select private.is_admin()) then
    raise exception 'FORBIDDEN: admin only' using errcode = '42501';
  end if;

  if p_listing_ids is null or cardinality(p_listing_ids) = 0 then
    return '{}'::jsonb;
  end if;

  -- Capped: a page holds tens of rows, and an unbounded array would let a
  -- client turn one call into a full-table scan by another name.
  if cardinality(p_listing_ids) > 100 then
    raise exception 'VALIDATION_ERROR: at most 100 listings per call'
      using errcode = '22023';
  end if;

  foreach v_id in array p_listing_ids loop
    -- Null ids carry nothing to check; skip rather than tripping the
    -- wrapped function's null guard and failing the whole page.
    if v_id is null then
      continue;
    end if;
    begin
      v_res := public.v1_admin_fraud_signals(v_id);
      select count(*) into v_warnings
        from jsonb_array_elements(v_res -> 'signals') s
        where s ->> 'severity' = 'warning';
      v_out := v_out || jsonb_build_object(v_id::text, v_warnings);
    exception when no_data_found then
      -- NOT_FOUND (P0002): the row was actioned or removed between the page
      -- load and this call. Skip it rather than failing the other
      -- ninety-nine. Deliberately narrow: any other per-row failure still
      -- propagates loudly instead of silently dropping a row.
      continue;
    end;
  end loop;

  return v_out;
end;
$function$;

-- Grants (HYA-248: revoke from public first; is_admin() enforced in the body).
revoke execute on function public.v1_admin_fraud_signal_counts (uuid[]) from public;

grant execute on function public.v1_admin_fraud_signal_counts (uuid[]) to authenticated;

comment on function public.v1_admin_fraud_signal_counts(uuid[]) is
  'HYA-303: warning counts for a page of listings, reusing '
  'v1_admin_fraud_signals per id so row flags cannot disagree with the '
  'detail pane. Admin-only, read-only, at most 100 ids per call.';
