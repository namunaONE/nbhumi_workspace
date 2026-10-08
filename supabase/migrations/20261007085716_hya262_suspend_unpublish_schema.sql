-- HYA-262 (1/3): suspension columns, unpublished status, enforcement backstops.
--
-- ## Design decisions (user-approved)
--
-- * Suspension is orthogonal state, not a role. `user_role` stays
--   buyer/agent/admin; `profiles` gains suspended_at / suspended_reason /
--   suspended_by. A suspended seller keeps their role (and therefore their
--   history) but cannot write listings.
-- * Unpublish is a distinct `listing_status` value, not a reused `rejected`.
--   `rejected` means "submitted and failed review"; telling a seller their
--   live listing was "rejected" would be a lie the audit trail then enshrines.
--   The `rejection_reason` *column* is reused to carry the unpublish reason
--   shown to the seller -- it is a free-text reason field, and duplicating it
--   would leave two reason columns to disagree.
-- * Suspending a seller does NOT auto-unpublish their live listings. Hiding
--   someone's inventory is a separate, per-listing, audited decision; bundling
--   it into suspend would make one tap do two things. The admin unpublishes
--   explicitly via v1_admin_unpublish_listing (part 3 of this migration).
-- * Enforcement lives in BOTH the write RPCs and the RLS policies. The RPCs
--   are what the app calls, but the seller write path is SECURITY INVOKER, so
--   a suspended seller with a REST client could bypass an RPC-only check via
--   direct insert/update. The policy is the backstop that cannot be routed
--   around; the RPC is the readable 42501.
-- * No JWT claim, no Auth hook: `private.is_suspended()` mirrors
--   `private.is_admin()` -- server-owned state, effective immediately, no
--   stale-token window (HYA-280).
--
-- ## Rule compliance
--
-- * Rule 1: new files; nothing applied is edited.
-- * Rule 3: no new table; the altered policies ship in this same file.
-- * Rule 4: live<->unpublished transitions only via the new admin RPCs (plus
--   the GUC bypass the trigger already grants admin RPCs). Sellers gain one
--   new legal path, unpublished->pending_review, so a fixed listing can be
--   resubmitted exactly like a rejected one.
--
-- ## Note on ALTER TYPE ... ADD VALUE
--
-- Applied idempotently (IF NOT EXISTS) so replay is safe. Postgres runs the
-- statement outside the migration transaction; reaching it twice is a no-op.

alter type public.listing_status add value if not exists 'unpublished';

-- ---------------------------------------------------------------------------
-- Suspension columns (profiles)
-- ---------------------------------------------------------------------------

alter table public.profiles
  add column if not exists suspended_at timestamptz,
  add column if not exists suspended_reason text,
  add column if not exists suspended_by uuid references public.profiles (id);

-- Suspended sellers, for the admin user lookup. Partial: the overwhelming
-- majority of rows will never be suspended, so index only the exception.
create index if not exists profiles_suspended_idx
  on public.profiles (suspended_at)
  where suspended_at is not null;

-- Suspension state must be internally consistent: a reason and an actor travel
-- together, and clearing one clears all three. Without this, "suspended with
-- no reason" and "unsuspended but still stamped" are both representable.
do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'profiles_suspension_consistent'
  ) then
    alter table public.profiles
      add constraint profiles_suspension_consistent
      check (
        (suspended_at is null and suspended_reason is null and suspended_by is null)
        or
        (suspended_at is not null and suspended_reason is not null and suspended_by is not null)
      );
  end if;
end $$;

comment on column public.profiles.suspended_at is
  'HYA-262: when an admin suspended this account. Null means not suspended. '
  'Orthogonal to role: a suspended agent keeps their history but cannot write.';

-- ---------------------------------------------------------------------------
-- private.is_suspended(): mirrors private.is_admin()
-- ---------------------------------------------------------------------------

create or replace function private.is_suspended()
returns boolean
language sql
stable
security definer
set search_path to ''
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = (select private.current_uid()) and p.suspended_at is not null
  );
$$;

-- Executable where RLS needs it (policies evaluate for anon too on listings
-- reads), but the schema is not exposed via PostgREST so this is not a public
-- endpoint -- the same arrangement HYA-248 documents for private.is_admin().
revoke execute on function private.is_suspended() from public;
grant execute on function private.is_suspended() to anon, authenticated;

comment on function private.is_suspended() is
  'HYA-262: true when the calling user''s profile carries suspended_at. '
  'Server-owned state, effective immediately on write -- no token-refresh '
  'window, unlike a JWT claim.';

-- ---------------------------------------------------------------------------
-- Policy backstops: a suspended seller cannot write, even via direct REST
-- ---------------------------------------------------------------------------

drop policy if exists "listings_insert_own" on public.listings;
create policy "listings_insert_own" on public.listings
  for insert to authenticated
  with check (
    seller_id = (select private.current_uid())
    and not (select private.is_suspended())
  );

drop policy if exists "listings_update_own" on public.listings;
create policy "listings_update_own" on public.listings
  for update to authenticated
  using (
    seller_id = (select private.current_uid())
    and not (select private.is_suspended())
  )
  with check (
    seller_id = (select private.current_uid())
    and not (select private.is_suspended())
  );

-- ---------------------------------------------------------------------------
-- Status machine: sellers may resubmit an unpublished listing after fixing it
-- ---------------------------------------------------------------------------

create or replace function public.enforce_listing_status_transition()
returns trigger
language plpgsql
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

  -- Seller-permitted transitions only. unpublished->pending_review mirrors
  -- rejected->pending_review: the seller fixed whatever the admin pulled the
  -- listing for and asks for another look.
  if (old.status = 'draft' and new.status = 'pending_review')
     or (old.status = 'pending_review' and new.status = 'draft')
     or (old.status = 'rejected' and new.status = 'pending_review')
     or (old.status = 'unpublished' and new.status = 'pending_review') then
    return new;
  end if;

  raise exception 'Invalid listing status transition: % -> %', old.status, new.status
    using errcode = 'check_violation';
end;
$$;
