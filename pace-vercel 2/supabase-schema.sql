-- Pace — schema and row-level security.
-- Run this once in your Supabase project: SQL Editor → New query → paste → Run.
--
-- Then turn ON Authentication → Sign In / Providers → Anonymous sign-ins.
-- The app has no login screen; it signs in anonymously on first launch, and that
-- identity is what every policy below locks rows to.

create table if not exists public.hobbies (
  user_id    uuid        not null references auth.users on delete cascade,
  id         text        not null,
  name       text        not null default '',
  color      text        not null default '',
  deleted    boolean     not null default false,
  updated_at timestamptz not null default now(),
  primary key (user_id, id)
);

create table if not exists public.sessions (
  user_id     uuid        not null references auth.users on delete cascade,
  id          text        not null,
  day_key     text        not null,          -- "2026-8-17" (year-monthIndex-day, as the app stores it)
  hobby       text        not null default '',
  minutes     integer     not null default 0,
  hour        integer     not null default 0,
  rating      integer     not null default 0,
  note        text        not null default '',
  tags        text[]      not null default '{}',
  photo_paths text[]      not null default '{}',
  deleted     boolean     not null default false,
  updated_at  timestamptz not null default now(),
  primary key (user_id, id)
);

create index if not exists sessions_user_day_idx on public.sessions (user_id, day_key);

create table if not exists public.prefs (
  user_id    uuid        primary key references auth.users on delete cascade,
  data       jsonb       not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- The app writes with the anon key, so RLS is what actually protects the data.
alter table public.hobbies  enable row level security;
alter table public.sessions enable row level security;
alter table public.prefs    enable row level security;

-- user_id defaults to the caller, so the client cannot write rows for anyone else.
alter table public.hobbies  alter column user_id set default auth.uid();
alter table public.sessions alter column user_id set default auth.uid();
alter table public.prefs    alter column user_id set default auth.uid();

do $$
declare t text;
begin
  foreach t in array array['hobbies','sessions','prefs'] loop
    execute format('drop policy if exists "own rows select" on public.%I', t);
    execute format('drop policy if exists "own rows insert" on public.%I', t);
    execute format('drop policy if exists "own rows update" on public.%I', t);
    execute format('drop policy if exists "own rows delete" on public.%I', t);
    execute format('create policy "own rows select" on public.%I for select using (auth.uid() = user_id)', t);
    execute format('create policy "own rows insert" on public.%I for insert with check (auth.uid() = user_id)', t);
    execute format('create policy "own rows update" on public.%I for update using (auth.uid() = user_id) with check (auth.uid() = user_id)', t);
    execute format('create policy "own rows delete" on public.%I for delete using (auth.uid() = user_id)', t);
  end loop;
end $$;

-- ── Photo storage ─────────────────────────────────────────────────────────
-- Create a PRIVATE bucket named pace-photos (Storage → New bucket, Public = off),
-- then run the rest. Photos are stored at <user_id>/<session_id>/<n>.jpg and are
-- only ever read through short-lived signed URLs the app requests.

insert into storage.buckets (id, name, public)
values ('pace-photos', 'pace-photos', false)
on conflict (id) do nothing;

drop policy if exists "own photos read"   on storage.objects;
drop policy if exists "own photos write"  on storage.objects;
drop policy if exists "own photos update" on storage.objects;
drop policy if exists "own photos delete" on storage.objects;

create policy "own photos read" on storage.objects for select
  using (bucket_id = 'pace-photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "own photos write" on storage.objects for insert
  with check (bucket_id = 'pace-photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "own photos update" on storage.objects for update
  using (bucket_id = 'pace-photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "own photos delete" on storage.objects for delete
  using (bucket_id = 'pace-photos' and (storage.foldername(name))[1] = auth.uid()::text);
