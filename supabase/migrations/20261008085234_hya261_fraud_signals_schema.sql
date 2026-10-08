-- HYA-261 (1/2): fraud-signal foundations -- kitta, phone normalization,
-- photo path/hash columns.
--
-- ## Design decisions
--
-- * Four of five signals land here; citizenship-number reuse is DEFERRED to
--   HYA-264 (M3). A competing PII column owned by this migration would collide
--   with the KYC agent's in-flight `kyc_documents` work and split the source
--   of truth for citizenship data. The signals RPC (part 2) reports that
--   signal as not-applicable until HYA-264 lands.
-- * `listings.kitta_number` is free text, nullable. Parcel numbering varies by
--   district and old records predate the column, so no CHECK constraint: a
--   wrong-but-present value is a review judgment, not a schema violation.
--   Missing (null/blank) is itself the signal.
-- * `profiles.phone_normalized` is derived state, not input. Raw `phone` stays
--   untouched; a trigger maintains the normalized form on every write and a
--   one-off backfill covers existing rows. Same-phone-across-accounts becomes
--   an equality check instead of a fuzzy match.
-- * `listing_photos.storage_path` + `photo_hash` are nullable by design. Old
--   rows carry only a full public URL (regexing paths out of URL strings is
--   fragile -- see HYA-261 audit comment), so there is deliberately NO backfill:
--   new uploads write the path, and duplicate detection covers non-null paths
--   plus exact-URL fallback in the RPC. `photo_hash` is reserved for a
--   perceptual hash populated by the future upload pipeline; equality on it is
--   exact-match only, never similarity.
-- * Price/area needs no column: `price_npr / area_sqm` is computable where
--   `area_sqm` is not null. Thresholds live in the RPC (part 2), tunable
--   without a schema change.
--
-- ## Rule compliance
--
-- * Rule 1: new file; nothing applied is edited.
-- * Rule 3: no new table, so no new policies. New columns inherit their
--   tables' RLS: `phone_normalized` inherits `profiles_select_own_or_admin`
--   (self or admin only -- no new PII exposure); `kitta_number` rides the
--   listing's own row visibility like every other seller-provided field.
-- * Rule 4: no status transitions. Rule 8: no mutations, so no audit rows.
--
-- ## Replay safety
--
-- Every statement is IF NOT EXISTS / guarded, matching the HYA-262 style, so
-- re-apply is a no-op.

-- ---------------------------------------------------------------------------
-- listings.kitta_number (missing-kitta + duplicate-kitta signals)
-- ---------------------------------------------------------------------------

alter table public.listings
  add column if not exists kitta_number text;

comment on column public.listings.kitta_number is
  'HYA-261: land parcel (kitta) number as the seller wrote it. Null/blank '
  'means "not provided" and is itself a review signal; duplicates across '
  'listings are a fraud signal. Free text: numbering varies by district.';

-- Duplicate-kitta grouping. Partial: most rows will be null until sellers
-- start providing it, so index only the exception.
create index if not exists listings_kitta_number_idx
  on public.listings (kitta_number)
  where kitta_number is not null;

-- ---------------------------------------------------------------------------
-- profiles.phone_normalized (same-phone-across-accounts signal)
-- ---------------------------------------------------------------------------

alter table public.profiles
  add column if not exists phone_normalized text;

comment on column public.profiles.phone_normalized is
  'HYA-261: digits-only normalized form of phone, maintained by trigger. '
  'Same RLS as the rest of the row (own-or-admin). Groups accounts that '
  'wrote the same number differently (+977, dashes, spaces).';

-- Normalizes Nepali mobile input to a comparable digit string:
-- strips non-digits, then a leading country/trunk prefix (977, 00977, 0).
-- Permissive by design: returns the digits (or null when empty) and leaves
-- validity judgments to Validators.isValidNepaliPhone client-side.
create or replace function public.normalize_np_phone(p_raw text)
returns text
language sql
immutable
set search_path = public, pg_temp
as $$
  select case
    when p_raw is null then null
    else nullif(
      case
        when _d like '00977%' then substring(_d from 6)
        when _d like '977%' and length(_d) > 10 then substring(_d from 4)
        when _d like '0%' and length(_d) = 11 then substring(_d from 2)
        else _d
      end,
      ''
    )
  end
  from (select regexp_replace(p_raw, '\D', '', 'g') as _d) s
$$;

comment on function public.normalize_np_phone(text) is
  'HYA-261: canonical digit form of a phone number for cross-account '
  'comparison. Immutable so it can back indexes and generated reads.';

-- Keeps the normalized column in sync on every write of phone.
create or replace function public.profiles_normalize_phone_trg()
returns trigger
language plpgsql
set search_path = public, pg_temp
as $$
begin
  new.phone_normalized := public.normalize_np_phone(new.phone);
  return new;
end;
$$;

drop trigger if exists profiles_phone_normalized_trg on public.profiles;

create trigger profiles_phone_normalized_trg
  before insert or update of phone on public.profiles
  for each row
  execute function public.profiles_normalize_phone_trg();

-- One-off backfill for rows predating the trigger.
update public.profiles
  set phone_normalized = public.normalize_np_phone(phone)
  where phone is not null
    and phone_normalized is null;

-- Same-phone grouping. Partial: nulls (no phone given) carry no signal.
create index if not exists profiles_phone_normalized_idx
  on public.profiles (phone_normalized)
  where phone_normalized is not null;

-- ---------------------------------------------------------------------------
-- listing_photos.storage_path + photo_hash (same-photo signal)
-- ---------------------------------------------------------------------------

alter table public.listing_photos
  add column if not exists storage_path text,
  add column if not exists photo_hash text;

comment on column public.listing_photos.storage_path is
  'HYA-261: storage object path (not the public URL) for exact duplicate '
  'detection across listings. Null on pre-HYA-261 rows by design -- paths '
  'are written by new uploads, never regexed out of URL strings.';

comment on column public.listing_photos.photo_hash is
  'HYA-261: reserved for a perceptual hash set by the upload pipeline. '
  'Exact-equality grouping only; never similarity-matched in SQL.';

-- Same-photo grouping on either key. Partial: nulls are "unknown", not a
-- group worth indexing.
create index if not exists listing_photos_storage_path_idx
  on public.listing_photos (storage_path)
  where storage_path is not null;

create index if not exists listing_photos_photo_hash_idx
  on public.listing_photos (photo_hash)
  where photo_hash is not null;
