-- Pace — what is using the space? Read-only: these queries change nothing.
-- Supabase → SQL Editor → New query → paste → Run. Each result is one table.
--
-- Free plan limits: 1 GB of file storage (photos and videos in pace-photos)
-- and 500 MB of database (the rows). Usage → "Storage size" is the first,
-- "Database size" the second.

-- ── 1. Files by kind ─────────────────────────────────────────────────────────
-- Each photo is two files (diary copy + full size), each video two (video + still).
with o as (
  select coalesce((metadata->>'size')::bigint, 0) as bytes,
    case when name ~ '\.video$'     then '4 video'
         when name ~ '\.video\.jpg$' then '3 video still'
         when name ~ '\.full\.jpg$'  then '2 full-size photo'
         when name ~ '\.jpg$'        then '1 diary photo'
         else '5 other' end as kind
  from storage.objects where bucket_id = 'pace-photos'
)
select kind, count(*) as files, pg_size_pretty(sum(bytes)) as size,
       pg_size_pretty((sum(bytes) / nullif(count(*), 0))::bigint) as average
from o group by kind
union all
select '9 total', count(*), pg_size_pretty(sum(bytes)), null from o
order by kind;

-- ── 2. Files nothing points at any more ──────────────────────────────────────
-- "erased session": the session was deleted for good, its files were not. The app
--   now removes these itself (weekly, on sync), see README → Storage.
-- "no session row": the folder's session never reached Supabase, or is mid-upload.
-- "not in its session": the session lives on, but no longer lists this file
--   (removed in an edit before Recently deleted existed).
-- Anything in Recently deleted still counts as in use.
with o as (
  select name, created_at, coalesce((metadata->>'size')::bigint, 0) as bytes,
    split_part(name, '/', 1) as uid, split_part(name, '/', 2) as sid,
    regexp_replace(regexp_replace(name, '\.full\.jpg$', '.jpg'), '\.video$', '.video.jpg') as slot
  from storage.objects where bucket_id = 'pace-photos'
), tagged as (
  select o.*, case
      when s.id is null then 'no session row'
      when s.deleted then 'erased session'
      when o.slot = any (s.photo_paths)
        or exists (select 1 from jsonb_array_elements(s.trashed_media) t where t->>'path' = o.slot)
        then 'in use'
      else 'not in its session' end as status
  from o left join public.sessions s on s.user_id::text = o.uid and s.id = o.sid
)
select status, count(*) as files, pg_size_pretty(sum(bytes)) as size,
       min(created_at)::date as oldest
from tagged group by status order by sum(bytes) desc;

-- ── 3. Database ──────────────────────────────────────────────────────────────
select 'whole database' as what, pg_size_pretty(pg_database_size(current_database())) as size
union all
select 'public.' || relname, pg_size_pretty(pg_total_relation_size(relid))
from pg_catalog.pg_statio_user_tables where schemaname = 'public';
