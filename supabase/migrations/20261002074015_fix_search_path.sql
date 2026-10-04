-- ===========================================================================
-- HYA-247 — Backport of applied migration 004 (search_path hardening)
-- ===========================================================================
--
-- WHY THIS FILE EXISTS
-- --------------------
-- Migration `004_fix_search_path` was applied to the remote project under the
-- version `20261002074015` but was never committed to git. This file recreates
-- it so that `supabase db reset` produces a schema identical to the remote.
--
-- Rule 1 (never edit an applied migration) is respected: this is a NEW file
-- with the SAME version string the remote already recorded, so the migration
-- ledger stays in sync and nothing is re-applied.
--
-- WHAT IT CHANGES
-- ---------------
-- Two trigger functions declared in 001/002 without a `search_path`:
--   * public.set_updated_at()
--   * public.enforce_listing_status_transition()
--
-- Without a pinned `search_path` these resolve table/function names through
-- whatever `search_path` the caller happens to have. An attacker who can
-- create objects in a schema earlier on the path can shadow them. Every other
-- function in the schema already pins `search_path = public`.
--
-- Bodies are reproduced verbatim from the remote definitions; only the
-- `set search_path` clause is added.
-- ===========================================================================

-- ---------------------------------------------------------------------------
-- public.set_updated_at()
-- ---------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin new.updated_at = now(); return new; end;
$$;

-- ---------------------------------------------------------------------------
-- public.enforce_listing_status_transition()
-- ---------------------------------------------------------------------------
create or replace function public.enforce_listing_status_transition()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  -- Admin RPC path: the RPC sets this GUC before transitioning.
  if current_setting('nbhumi.admin_action', true) = 'on' then
    return new;
  end if;

  -- Unchanged status is always fine.
  if old.status = new.status then
    return new;
  end if;

  -- Seller-allowed transitions.
  if (old.status = 'draft' and new.status = 'pending_review')
     or (old.status = 'pending_review' and new.status = 'draft')
     or (old.status = 'rejected' and new.status = 'pending_review') then
    return new;
  end if;

  raise exception 'Invalid listing status transition: % -> %', old.status, new.status
    using errcode = 'check_violation';
end;
$$;

-- ---------------------------------------------------------------------------
-- Defensive: guarantee every non-exposed helper is not callable from the API.
-- HYA-248 generalises this across the whole schema.
-- ---------------------------------------------------------------------------
revoke execute on function public.set_updated_at() from public;
revoke execute on function public.enforce_listing_status_transition() from public;