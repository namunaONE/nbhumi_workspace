-- HYA-261 (3/3): citizenship-doc-reuse signal on v1_admin_fraud_signals.
--
-- Replaces the function from part 2/3 (CREATE OR REPLACE in a NEW file --
-- Rule 1: the applied migration is never edited) to add the fifth signal:
--
-- * `citizenship_reuse` (warning) -- another profile holds a VERIFIED Tier-2
--   citizenship document with the same `storage_path` as this seller's
--   verified citizenship document. Same file behind two accounts is the
--   strongest identity signal in this set: one citizenship, two sellers.
--
-- ## Why same-file, not same-number
--
-- `kyc_documents` (HYA-264, applied) carries no number column -- only the
-- document file. Number reuse as literally specified is unbuildable without a
-- new PII column owned by the KYC workstream; same verified file is the
-- implementable equivalent and arguably stronger (numbers can be mistyped,
-- identical files cannot). Pending rows are excluded (unreviewed claims) and
-- rejected rows are excluded (purged after 30 days anyway).
--
-- ## Rule compliance
--
-- * Rule 1: new file; replaces the function, edits no applied file.
-- * Rule 3: no new table. One additive partial index on HYA-264's table for
--   the join (flagged to the KYC owner in Linear); no policy changes.
-- * Rules 4/8: read-only, no status transitions, no audit rows.
-- * Rule 36: bilingual message pair like every other signal.
--
-- ## Replay safety
--
-- `create or replace` + re-issued grants; index and comments idempotent.

create index if not exists kyc_documents_verified_citizenship_path_idx
  on public.kyc_documents (storage_path)
  where doc_type = 'citizenship' and status = 'verified';

create or replace function public.v1_admin_fraud_signals(p_listing_id uuid)
returns jsonb
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_uid uuid := (select private.current_uid());
  v_listing public.listings%rowtype;
  v_seller_phone text;
  v_signals jsonb := '[]'::jsonb;
  v_price_per_sqm numeric;
  v_other_photos jsonb;
  v_other_kitta jsonb;
  v_other_accounts jsonb;
  v_other_cit jsonb;
  -- Tunables: unit-price plausibility band (NPR per sqm) and the bedroom
  -- density no honest floor plan survives. Generous on purpose: flagging a
  -- cheap rural plot as fraud would teach admins to ignore the signal.
  c_price_low constant numeric := 100;
  c_price_high constant numeric := 2000000;
  c_bedrooms_many constant smallint := 8;
  c_bedrooms_area constant numeric := 100;
begin
  if v_uid is null then
    raise exception 'AUTH_REQUIRED: sign in to view fraud signals'
      using errcode = '42501';
  end if;

  if not (select private.is_admin()) then
    raise exception 'FORBIDDEN: admin only' using errcode = '42501';
  end if;

  if p_listing_id is null then
    raise exception 'VALIDATION_ERROR: listing id is required'
      using errcode = '22023';
  end if;

  select l.* into v_listing
    from public.listings l
    where l.id = p_listing_id;

  if not found then
    raise exception 'NOT_FOUND: no listing with that id'
      using errcode = 'P0002';
  end if;

  -- -- duplicate_photo ------------------------------------------------------
  -- Same storage path, same perceptual hash, or byte-identical URL on another
  -- listing's photo. Null keys never match (null = unknown, not a group).
  select coalesce(jsonb_agg(distinct p.listing_id), '[]'::jsonb) into v_other_photos
    from public.listing_photos p
    join public.listing_photos mine
      on (mine.storage_path is not null and p.storage_path = mine.storage_path)
      or (mine.photo_hash is not null and p.photo_hash = mine.photo_hash)
      or (p.url = mine.url)
    where mine.listing_id = p_listing_id
      and p.listing_id <> p_listing_id;

  if jsonb_array_length(v_other_photos) > 0 then
    v_signals := v_signals || jsonb_build_object(
      'code', 'duplicate_photo',
      'severity', 'warning',
      'message_en', 'Same photo appears on another listing.',
      'message_ne', 'उही फोटो अर्को लिस्टिङमा पनि देखिन्छ।',
      'detail', jsonb_build_object('other_listing_ids', v_other_photos)
    );
  end if;

  -- -- duplicate_kitta ------------------------------------------------------
  if v_listing.kitta_number is not null
     and length(btrim(v_listing.kitta_number)) > 0 then
    select coalesce(jsonb_agg(l.id), '[]'::jsonb) into v_other_kitta
      from public.listings l
      where l.kitta_number = v_listing.kitta_number
        and l.id <> p_listing_id;

    if jsonb_array_length(v_other_kitta) > 0 then
      v_signals := v_signals || jsonb_build_object(
        'code', 'duplicate_kitta',
        'severity', 'warning',
        'message_en', 'Same kitta number is listed more than once.',
        'message_ne', 'उही कित्ता नम्बर एकभन्दा बढी पटक सूचीबद्ध छ।',
        'detail', jsonb_build_object(
          'kitta_number', v_listing.kitta_number,
          'other_listing_ids', v_other_kitta
        )
      );
    end if;
  else
    v_signals := v_signals || jsonb_build_object(
      'code', 'missing_kitta',
      'severity', 'info',
      'message_en', 'No kitta number provided.',
      'message_ne', 'कित्ता नम्बर दिइएको छैन।',
      'detail', '{}'::jsonb
    );
  end if;

  -- -- same_phone_accounts --------------------------------------------------
  select p.phone_normalized into v_seller_phone
    from public.profiles p
    where p.id = v_listing.seller_id;

  if v_seller_phone is not null then
    select coalesce(jsonb_agg(p.id), '[]'::jsonb) into v_other_accounts
      from public.profiles p
      where p.phone_normalized = v_seller_phone
        and p.id <> v_listing.seller_id;

    if jsonb_array_length(v_other_accounts) > 0 then
      v_signals := v_signals || jsonb_build_object(
        'code', 'same_phone_accounts',
        'severity', 'warning',
        'message_en', 'Same phone number is used by other accounts.',
        'message_ne', 'उही फोन नम्बर अन्य खाताहरूले प्रयोग गरेका छन्।',
        'detail', jsonb_build_object(
          'other_account_ids', v_other_accounts,
          'account_count', jsonb_array_length(v_other_accounts) + 1
        )
      );
    end if;
  end if;

  -- -- citizenship_reuse ----------------------------------------------------
  -- Same verified citizenship file behind two accounts (HYA-261 5/5, adapted:
  -- kyc_documents carries files, not numbers -- see header). Verified only:
  -- pending rows are unreviewed claims, rejected rows are purged anyway.
  select coalesce(jsonb_agg(distinct d2.profile_id), '[]'::jsonb)
    into v_other_cit
    from public.kyc_documents d1
    join public.kyc_documents d2
      on d2.storage_path = d1.storage_path
    where d1.profile_id = v_listing.seller_id
      and d1.doc_type = 'citizenship'
      and d1.status = 'verified'
      and d2.doc_type = 'citizenship'
      and d2.status = 'verified'
      and d2.profile_id <> v_listing.seller_id;

  if jsonb_array_length(v_other_cit) > 0 then
    v_signals := v_signals || jsonb_build_object(
      'code', 'citizenship_reuse',
      'severity', 'warning',
      'message_en',
        'Same verified citizenship document is used by another account.',
      'message_ne',
        'उही प्रमाणित नागरिकता कागजात अर्को खाताले प्रयोग गरेको छ।',
      'detail', jsonb_build_object('other_account_ids', v_other_cit)
    );
  end if;

  -- -- price_area -----------------------------------------------------------
  if v_listing.area_sqm is not null and v_listing.area_sqm > 0 then
    v_price_per_sqm := v_listing.price_npr / v_listing.area_sqm;

    if v_price_per_sqm < c_price_low
       or v_price_per_sqm > c_price_high
       or (v_listing.bedrooms is not null
           and v_listing.bedrooms >= c_bedrooms_many
           and v_listing.area_sqm < c_bedrooms_area) then
      v_signals := v_signals || jsonb_build_object(
        'code', 'price_area',
        'severity', 'warning',
        'message_en', 'Price or bedroom count looks implausible for the area.',
        'message_ne', 'क्षेत्रफलको तुलनामा मूल्य वा बेडरुम संख्या अस्वाभाविक देखिन्छ।',
        'detail', jsonb_build_object(
          'price_npr', v_listing.price_npr,
          'area_sqm', v_listing.area_sqm,
          'price_per_sqm', v_price_per_sqm,
          'bedrooms', v_listing.bedrooms
        )
      );
    else
      v_signals := v_signals || jsonb_build_object(
        'code', 'price_area',
        'severity', 'info',
        'message_en', 'Price per sqm computed.',
        'message_ne', 'प्रति वर्गमिटर मूल्य गणना गरियो।',
        'detail', jsonb_build_object(
          'price_npr', v_listing.price_npr,
          'area_sqm', v_listing.area_sqm,
          'price_per_sqm', v_price_per_sqm
        )
      );
    end if;
  else
    v_signals := v_signals || jsonb_build_object(
      'code', 'price_area',
      'severity', 'info',
      'message_en', 'No area to judge the price against.',
      'message_ne', 'मूल्याङ्कन गर्ने आधार (क्षेत्रफल) छैन।',
      'detail', jsonb_build_object('price_npr', v_listing.price_npr)
    );
  end if;

  return jsonb_build_object(
    'listing_id', p_listing_id,
    'signals', v_signals
  );
end;
$function$;

-- Grants re-issued with the replacement (HYA-248 pattern).
revoke execute on function public.v1_admin_fraud_signals (uuid) from public;

grant execute on function public.v1_admin_fraud_signals (uuid) to authenticated;

comment on function public.v1_admin_fraud_signals(uuid) is
  'HYA-261: read-only fraud signals for one listing (duplicate photo/kitta, '
  'shared phone accounts, shared verified citizenship doc, price/area '
  'plausibility, missing kitta). Admin-only via private.is_admin(); returns '
  'info/warning signals, never a verdict.';
