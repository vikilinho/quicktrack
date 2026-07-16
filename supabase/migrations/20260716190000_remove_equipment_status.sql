-- Location is the single source of truth; equipment no longer has a status.
drop function public.get_equipment_for_scan(text);
drop function private.get_equipment_for_scan(text);

alter table public.equipments drop column status;

create function private.get_equipment_for_scan(p_asset_number text)
returns table (
  id uuid,
  asset_number text,
  name text,
  category text,
  current_ward_id uuid,
  current_ward_name text
)
language sql
stable
security definer
set search_path = ''
as $$
  select
    equipment.id,
    equipment.asset_number,
    equipment.name,
    equipment.category,
    equipment.current_ward_id,
    ward.name
  from public.equipments as equipment
  left join public.wards as ward on ward.id = equipment.current_ward_id
  where equipment.asset_number = upper(trim(p_asset_number))
    and equipment.is_active = true
    and coalesce((select auth.jwt() ->> 'role'), '') in ('anon', 'authenticated')
  limit 1;
$$;

revoke all on function private.get_equipment_for_scan(text) from public;
grant execute on function private.get_equipment_for_scan(text) to anon, authenticated;

create function public.get_equipment_for_scan(p_asset_number text)
returns table (
  id uuid,
  asset_number text,
  name text,
  category text,
  current_ward_id uuid,
  current_ward_name text
)
language sql
stable
security invoker
set search_path = ''
as $$
  select * from private.get_equipment_for_scan(p_asset_number);
$$;

revoke all on function public.get_equipment_for_scan(text) from public;
grant execute on function public.get_equipment_for_scan(text) to anon, authenticated;
