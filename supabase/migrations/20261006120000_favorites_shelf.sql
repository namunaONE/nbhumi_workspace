-- HYA-268 (C1) — favorites shelf: table + RLS
--
-- Buyer bookmarks. One row per (seller, listing); unbookmarking deletes the
-- row. A shelf, not history: both foreign keys CASCADE, so deleting an
-- account or a listing silently drops its bookmarks rather than orphaning
-- them. Nothing here is worth anonymizing (contrast listings/audit/contact
-- logs in HYA-258): a favorite says "I was interested", and that statement
-- belongs to the account being deleted.
--
-- WHAT THIS DOES NOT DO
-- =====================
--   * `is_favorite` in `v1_get_listings` / `v1_get_listing_detail` stays a
--     hardcoded false. Flipping it means restating both RPC bodies, and the
--     browse body is long enough that restating it blind (no live database
--     here to verify against) risks breaking the feed sellers browse by.
--     The client reads favorite state from this table instead (see
--     FavoritesRepository), and the server-side flip is C2, verified against
--     a live database at apply time.
--   * Saved-search alerts (the second half of HYA-268) need a matcher on a
--     schedule. That is C2 with pg_cron/Edge, not this file.
--
-- RULE 3: RLS lives in the same migration as the table.

-- ---------------------------------------------------------------------------
-- 1. Table
-- ---------------------------------------------------------------------------

create table if not exists public.favorites (
  user_id uuid not null references public.profiles (id) on delete cascade,
  listing_id uuid not null references public.listings (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, listing_id)
);

comment on table public.favorites is
  'Buyer bookmarks (HYA-268 C1). Composite PK doubles as the duplicate guard: '
  'a second bookmark is 23505, mapped client-side to already-saved.';

comment on column public.favorites.user_id is
  'Bookmark owner. Cascade: deleting the account drops the shelf with it.';

comment on column public.favorites.listing_id is
  'Bookmarked listing. Cascade: deleting the listing drops its bookmarks. '
  'Sellers never learn who bookmarked what — no reader policy admits them.';

-- Newest-first shelf order is the only read order.
create index if not exists favorites_user_idx
  on public.favorites (user_id, created_at desc);

-- ---------------------------------------------------------------------------
-- 2. RLS (same file as the table — Rule 3)
-- ---------------------------------------------------------------------------
-- Owner-only in all three directions. No UPDATE policy: no column is mutable
-- (created_at is stamp-at-insert), so update is dead surface. No admin
-- policy: bookmarks are private to the account; support has no read path.

alter table public.favorites enable row level security;

drop policy if exists "favorites_select_own" on public.favorites;
create policy "favorites_select_own"
  on public.favorites for select
  to authenticated
  using (user_id = (select private.current_uid()));

drop policy if exists "favorites_insert_own" on public.favorites;
create policy "favorites_insert_own"
  on public.favorites for insert
  to authenticated
  with check (user_id = (select private.current_uid()));

drop policy if exists "favorites_delete_own" on public.favorites;
create policy "favorites_delete_own"
  on public.favorites for delete
  to authenticated
  using (user_id = (select private.current_uid()));

-- HYA-248: restate the anon-execution default so future functions inherit it.
alter default privileges in schema public
  revoke execute on functions from anon;
