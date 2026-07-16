-- Replace the prototype ward list with the hospital's canonical locations.
-- `name` stays intentionally short because it is displayed in scanner choices
-- and dashboard location cards. `description` carries the clinical context.

alter table public.wards
  add column if not exists description text,
  add column if not exists display_order integer;

update public.wards
set
  name = 'Ward 1',
  description = 'Acute medical / short-stay ward',
  display_order = 10
where name = 'Ward A';

update public.wards
set
  name = 'ICU / ITU',
  description = 'Intensive Care / Therapy Unit',
  display_order = 100
where name = 'ICU';

update public.wards
set
  name = 'AMAU',
  description = 'Acute Medical Assessment Unit',
  display_order = 80
where name = 'Emergency';

-- Preserve the prototype Radiology row and its references by repurposing it.
update public.wards
set
  name = 'Ward 3',
  description = 'General Medicine',
  display_order = 20
where name = 'Radiology';

insert into public.wards (name, description, display_order)
values
  ('Ward 1', 'Acute medical / short-stay ward', 10),
  ('Ward 3', 'General Medicine', 20),
  ('Ward 4', 'General Medicine', 30),
  ('Ward 5', 'General Medicine', 40),
  ('Ward 6', 'Trauma & Orthopaedics', 50),
  ('Ward 7', 'General Surgery', 60),
  ('Ward 9', 'Geriatric & General Medicine / Therapy Unit', 70),
  ('AMAU', 'Acute Medical Assessment Unit', 80),
  ('CCU', 'Coronary Care Unit', 90),
  ('ICU / ITU', 'Intensive Care / Therapy Unit', 100)
on conflict (name) do update
set
  description = excluded.description,
  display_order = excluded.display_order;

alter table public.wards
  alter column display_order set not null;

create unique index if not exists wards_display_order_idx
  on public.wards (display_order);

comment on column public.wards.name is
  'Concise operational label shown in scanner and dashboard interfaces.';
comment on column public.wards.description is
  'Full clinical name or specialty for contextual display.';
comment on column public.wards.display_order is
  'Stable clinical ordering for ward selectors.';
