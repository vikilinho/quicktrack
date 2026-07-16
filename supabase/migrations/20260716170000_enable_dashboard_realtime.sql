-- Publish dashboard source tables to Supabase Realtime. The membership checks
-- make this safe when a table was already enabled through the Supabase UI.

do $$
begin
  if exists (
    select 1 from pg_publication where pubname = 'supabase_realtime'
  ) and not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'equipments'
  ) then
    alter publication supabase_realtime add table public.equipments;
  end if;

  if exists (
    select 1 from pg_publication where pubname = 'supabase_realtime'
  ) and not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'wards'
  ) then
    alter publication supabase_realtime add table public.wards;
  end if;
end
$$;
