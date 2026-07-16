-- Hospital equipment tracking schema and sample data.

create extension if not exists pgcrypto;

create table public.wards (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  created_at timestamptz not null default now()
);

create table public.equipments (
  id uuid primary key default gen_random_uuid(),
  asset_number text not null unique,
  name text not null,
  category text not null,
  owner_ward_id uuid references public.wards (id) on delete set null,
  current_ward_id uuid references public.wards (id) on delete set null,
  status text not null default 'Available'
    check (status in ('Available', 'In Use', 'Maintenance', 'Missing')),
  updated_at timestamptz not null default now()
);

create table public.scan_history (
  id uuid primary key default gen_random_uuid(),
  equipment_id uuid not null
    references public.equipments (id) on delete cascade,
  scanned_from_ward_id uuid
    references public.wards (id) on delete set null,
  scanned_to_ward_id uuid
    references public.wards (id) on delete set null,
  scanned_at timestamptz not null default now()
);

create index equipments_owner_ward_id_idx
  on public.equipments (owner_ward_id);
create index equipments_current_ward_id_idx
  on public.equipments (current_ward_id);
create index scan_history_equipment_id_scanned_at_idx
  on public.scan_history (equipment_id, scanned_at desc);
create index scan_history_scanned_from_ward_id_idx
  on public.scan_history (scanned_from_ward_id);
create index scan_history_scanned_to_ward_id_idx
  on public.scan_history (scanned_to_ward_id);

alter table public.wards enable row level security;
alter table public.equipments enable row level security;
alter table public.scan_history enable row level security;

create policy "Public can select wards"
  on public.wards for select
  to public
  using (true);

create policy "Public can insert wards"
  on public.wards for insert
  to public
  with check (true);

create policy "Public can update wards"
  on public.wards for update
  to public
  using (true)
  with check (true);

create policy "Public can select equipments"
  on public.equipments for select
  to public
  using (true);

create policy "Public can insert equipments"
  on public.equipments for insert
  to public
  with check (true);

create policy "Public can update equipments"
  on public.equipments for update
  to public
  using (true)
  with check (true);

create policy "Public can select scan history"
  on public.scan_history for select
  to public
  using (true);

create policy "Public can insert scan history"
  on public.scan_history for insert
  to public
  with check (true);

create policy "Public cannot update scan history"
  on public.scan_history for update
  to public
  using (false)
  with check (false);

-- There is also intentionally no DELETE policy on scan_history. Together with
-- the deny-all UPDATE policy above, this keeps the ledger append-only for app
-- clients while still exposing explicit SELECT, INSERT, and UPDATE policies.

insert into public.wards (name)
values
  ('Ward A'),
  ('ICU'),
  ('Emergency'),
  ('Radiology');

insert into public.equipments (
  asset_number,
  name,
  category,
  owner_ward_id,
  current_ward_id,
  status
)
values
  (
    'EQ-BLADDER-001',
    'Bladder Scanner A',
    'Scanner',
    (select id from public.wards where name = 'Ward A'),
    (select id from public.wards where name = 'Ward A'),
    'Available'
  ),
  (
    'EQ-INFUSION-001',
    'Infusion Pump 1',
    'Pump',
    (select id from public.wards where name = 'ICU'),
    (select id from public.wards where name = 'ICU'),
    'In Use'
  ),
  (
    'EQ-VENT-001',
    'Ventilator 1',
    'Ventilator',
    (select id from public.wards where name = 'ICU'),
    (select id from public.wards where name = 'Emergency'),
    'In Use'
  ),
  (
    'EQ-ECG-001',
    'ECG Monitor 1',
    'Monitor',
    (select id from public.wards where name = 'Emergency'),
    (select id from public.wards where name = 'Emergency'),
    'Maintenance'
  ),
  (
    'EQ-ULTRASOUND-001',
    'Portable Ultrasound 1',
    'Scanner',
    (select id from public.wards where name = 'Radiology'),
    (select id from public.wards where name = 'Radiology'),
    'Available'
  );
