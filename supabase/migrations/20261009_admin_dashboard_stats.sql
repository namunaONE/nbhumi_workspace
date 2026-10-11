-- Migration: Admin Dashboard Statistics RPC (HYA-195)  
-- Provides aggregated metrics for the admin dashboard overview.  
-- All reads are admin-only via SECURITY DEFINER + is_admin() check.  
  
create or replace function public.v1_admin_dashboard_stats()  
returns jsonb  
language plpgsql  
security definer  
set search_path = public  
as   
declare  
  result jsonb;  
begin  
  if not public.is_admin() then  
    raise exception 'Admin access required' using errcode = '42501';  
  end if; 
  result := jsonb_build_object(  
    'queue', jsonb_build_object(  
      'pending_review', (select count(*) from public.listings where status = 'pending_review'),  
      'live', (select count(*) from public.listings where status = 'live'),  
      'rejected', (select count(*) from public.listings where status = 'rejected'),  
      'unpublished', (select count(*) from public.listings where status = 'unpublished'),  
      'sla_breached', (  
        select count(*) from public.listings  
        where status = 'pending_review'  
