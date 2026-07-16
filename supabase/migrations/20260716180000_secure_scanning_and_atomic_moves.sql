-- Anonymous mobile clients may discover wards and use the two narrowly scoped
-- RPCs below. Direct equipment and movement-ledger access is dashboard-only.

alter table public.equipments
  add column is_active boolean not null default true;

drop policy if exists "Public can insert wards" on public.wards;
drop policy if exists "Public can update wards" on public.wards;

drop policy if exists "Public can select equipments" on public.equipments;
drop policy if exists "Public can insert equipments" on public.equipments;
drop policy if exists "Public can update equipments" on public.equipments;

drop policy if exists "Public can select scan history" on public.scan_history;
drop policy if exists "Public can insert scan history" on public.scan_history;
drop policy if exists "Public cannot update scan history" on public.scan_history;

create policy "Authenticated users can select equipments"
  on public.equipments for select
  to authenticated
  using (true);

create policy "Authenticated users can select scan history"
  on public.scan_history for select
  to authenticated
  using (true);

revoke insert, update, delete on public.wards from anon, authenticated;
revoke select, insert, update, delete on public.equipments from anon;
revoke insert, update, delete on public.equipments from authenticated;
revoke select, insert, update, delete on public.scan_history from anon;
revoke insert, update, delete on public.scan_history from authenticated;

grant select on public.wards to anon, authenticated;
grant select on public.equipments to authenticated;
grant select on public.scan_history to authenticated;

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;
grant usage on schema private to anon, authenticated;

create or replace function private.get_equipment_for_scan(p_asset_number text)
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

create or replace function private.move_equipment(
  p_equipment_id uuid,
  p_destination_ward_id uuid
)
returns table (
  equipment_id uuid,
  asset_number text,
  previous_ward_id uuid,
  destination_ward_id uuid,
  destination_ward_name text,
  moved_at timestamptz
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  selected_equipment public.equipments%rowtype;
  selected_ward public.wards%rowtype;
  movement_time timestamptz := now();
begin
  if coalesce((select auth.jwt() ->> 'role'), '') not in ('anon', 'authenticated') then
    raise exception using
      errcode = '42501',
      message = 'A valid Supabase API session is required';
  end if;

  select *
  into selected_equipment
  from public.equipments
  where id = p_equipment_id
  for update;

  if not found or not selected_equipment.is_active then
    raise exception using
      errcode = 'P0002',
      message = 'Equipment was not found or is inactive';
  end if;

  select *
  into selected_ward
  from public.wards
  where id = p_destination_ward_id;

  if not found then
    raise exception using
      errcode = '23503',
      message = 'Destination ward was not found';
  end if;

  if selected_equipment.current_ward_id is not distinct from p_destination_ward_id then
    raise exception using
      errcode = 'P0001',
      message = 'Equipment is already at this ward';
  end if;

  update public.equipments
  set current_ward_id = p_destination_ward_id,
      updated_at = movement_time
  where id = p_equipment_id;

  insert into public.scan_history (
    equipment_id,
    scanned_from_ward_id,
    scanned_to_ward_id,
    scanned_at
  ) values (
    p_equipment_id,
    selected_equipment.current_ward_id,
    p_destination_ward_id,
    movement_time
  );

  return query
  select
    selected_equipment.id,
    selected_equipment.asset_number,
    selected_equipment.current_ward_id,
    selected_ward.id,
    selected_ward.name,
    movement_time;
end;
$$;

revoke all on function private.get_equipment_for_scan(text) from public;
revoke all on function private.move_equipment(uuid, uuid) from public;
grant execute on function private.get_equipment_for_scan(text) to anon, authenticated;
grant execute on function private.move_equipment(uuid, uuid) to anon, authenticated;

create or replace function public.get_equipment_for_scan(p_asset_number text)
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

create or replace function public.move_equipment(
  p_equipment_id uuid,
  p_destination_ward_id uuid
)
returns table (
  equipment_id uuid,
  asset_number text,
  previous_ward_id uuid,
  destination_ward_id uuid,
  destination_ward_name text,
  moved_at timestamptz
)
language sql
security invoker
set search_path = ''
as $$
  select * from private.move_equipment(
    p_equipment_id,
    p_destination_ward_id
  );
$$;

revoke all on function public.get_equipment_for_scan(text) from public;
revoke all on function public.move_equipment(uuid, uuid) from public;
grant execute on function public.get_equipment_for_scan(text) to anon, authenticated;
grant execute on function public.move_equipment(uuid, uuid) to anon, authenticated;
