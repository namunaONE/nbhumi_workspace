-- HYA-248 (2/4) — Close the RPC surface on functions no client should call
--
-- The admin pair is reachable by `authenticated` because the admin panel needs
-- it, but never by `anon`. Defence in depth is retained: v1_admin_approve_listing
-- and v1_admin_reject_listing still call private.is_admin() internally.
--
-- The two trigger helpers are not an RPC surface (PostgREST refuses to call
-- trigger functions), but revoking removes the ambiguity from an audit.

revoke execute on function public.v1_admin_approve_listing(uuid) from public;
revoke execute on function public.v1_admin_approve_listing(uuid) from anon;
revoke execute on function public.v1_admin_reject_listing(uuid, text) from public;
revoke execute on function public.v1_admin_reject_listing(uuid, text) from anon;

grant execute on function public.v1_admin_approve_listing(uuid) to authenticated;
grant execute on function public.v1_admin_reject_listing(uuid, text) to authenticated;

revoke execute on function public.set_updated_at() from public;
revoke execute on function public.set_updated_at() from anon;
revoke execute on function public.set_updated_at() from authenticated;

revoke execute on function public.enforce_listing_status_transition() from public;
revoke execute on function public.enforce_listing_status_transition() from anon;
revoke execute on function public.enforce_listing_status_transition() from authenticated;

-- HYA-247 parity: these two are the only public helpers that lacked a pinned
-- search_path in migration 002.
alter function public.set_updated_at() set search_path = public;
alter function public.enforce_listing_status_transition() set search_path = public;