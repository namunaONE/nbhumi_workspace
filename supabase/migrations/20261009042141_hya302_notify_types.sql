-- HYA-302 (1/2): seller-inbox types for moderation verdicts.
--
-- Extends `private.notify_user` and `notifications_type_check` with the four
-- HYA-262 verdict types. Applied as its own ledger row (the RPC restatements
-- are 2/2): the choke point must accept the types before any caller sends
-- them, and the two halves review independently.
--
-- * `listing_unpublished`, `listing_republished`,
--   `account_suspended`, `account_reinstated`.
-- * Best-effort semantics unchanged: notify failures warn, verdicts stand.
-- * Rule 1: new file. Rule 36: bilingual enforcement unchanged.

create or replace function private.notify_user (
  p_user_id uuid,
  p_type text,
  p_message_en text,
  p_message_ne text
)
returns void
language plpgsql
security definer
set search_path to ''
as $function$
begin
  if p_user_id is null then raise exception 'INVALID_USER: notification needs a recipient' using errcode = '22023'; end if;
  if p_type not in ('listing_approved', 'listing_rejected', 'kyc_verified', 'kyc_rejected', 'new_message', 'listing_unpublished', 'listing_republished', 'account_suspended', 'account_reinstated') then raise exception 'INVALID_TYPE: %', p_type using errcode = '22023'; end if;
  if btrim(coalesce(p_message_en, '')) = '' or btrim(coalesce(p_message_ne, '')) = '' then raise exception 'INVALID_MESSAGE: bilingual content is required' using errcode = '22023'; end if;
  begin
    insert into public.notifications (user_id, type, message_en, message_ne) values (p_user_id, p_type, p_message_en, p_message_ne);
  exception when others then
    raise warning 'notify_user failed for % (%) : %', p_user_id, p_type, sqlerrm;
  end;
end;
$function$;

alter table public.notifications
  drop constraint if exists notifications_type_check;

alter table public.notifications
  add constraint notifications_type_check
  check (type in (
    'listing_approved', 'listing_rejected',
    'kyc_verified', 'kyc_rejected',
    'new_message',
    'listing_unpublished', 'listing_republished',
    'account_suspended', 'account_reinstated'
  ));
