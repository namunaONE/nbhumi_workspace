-- HYA-261 (2/2): v1_admin_fraud_signals -- read-only duplicate/fraud signals
-- for one listing (Rule 4: no status transitions; Rule 8: reads write no
-- audit rows).
--
-- ## What it reports (4 of 5 HYA-261 signals)
--
-- * `duplicate_photo` (warning) -- another listing shares a photo with this
--   one: same `storage_path`, same `photo_hash`, or byte-identical `url`.
--   Pre-HYA-261 rows have null path/hash by design, so the URL fallback keeps
--   them covered.
-- * `duplicate_kitta` (warning) -- another listing carries the same
--   `kitta_number`. Same parcel listed twice is either a duplicate or two
--   sellers claiming one plot; both want human eyes.
-- * `same_phone_accounts` (warning) -- other profiles share the seller's
--   `phone_normalized`. One phone, many accounts is the classic broker-spam
--   shape. Listed as account ids: this RPC is admin-gated, so ids are safe.
-- * `price_area` (info always, warning when implausible) -- computed
--   `price_per_sqm` plus a verdict. Warns on absurd unit prices or bedroom
--   density no floor plan survives (the spec's "1 aana + 12 bedrooms").
--   Thresholds are constants below, tunable without a schema change.
-- * `missing_kitta` (info) -- `kitta_number` null/blank. Every pre-HYA-261 row
--   fires this, so it is info, not warning: absence of data, not evidence.
-- * Citizenship-number reuse is OMITTED (deferred to HYA-264/M3). No
--   citizenship column exists and the KYC agent owns that PII surface; a
--   competing column here would split the source of truth.
--
-- ## Response shape
--
-- `{"listing_id": uuid, "signals": [{code, severity, message_en, message_ne,
-- detail}]}`. Severity is `info` (context) or `warning` (look closer) only:
-- nothing here concludes fraud, so there is no `critical`. An empty `signals`
-- array is a successful answer (nothing suspicious), not an error.
--
-- ## Rule compliance
--
-- * Rule 1: new file; nothing applied is edited.
-- * Rule 3: no new table; no policy changes.
-- * Rule 6: `p_listing_id` null is refused with 22023 before any read.
-- * Rule 36: every signal carries an English + Nepali message pair.
-- * Rule 38: mapped codes only (`AUTH_REQUIRED`/`FORBIDDEN` 42501,
--   `VALIDATION_ERROR` 22023, `NOT_FOUND` P0002). No Postgres text leaks.
--
-- ## Replay safety
--
-- `create or replace` + revoke/grant re-issued, matching the HYA-262 style.

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

-- ---------------------------------------------------------------------------
-- Grants (HYA-248: revoke from public first; is_admin() enforced in the body)
-- ---------------------------------------------------------------------------

revoke execute on function public.v1_admin_fraud_signals (uuid) from public;

grant execute on function public.v1_admin_fraud_signals (uuid) to authenticated;

comment on function public.v1_admin_fraud_signals(uuid) is
  'HYA-261: read-only fraud signals for one listing (duplicate photo/kitta, '
  'shared phone accounts, price/area plausibility, missing kitta). Admin-only '
  'via private.is_admin(); returns info/warning signals, never a verdict. '
  'Citizenship reuse deferred to HYA-264.';
