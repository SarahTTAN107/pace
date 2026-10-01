-- Pace — what is using the space? Read-only: this query changes nothing.
-- Supabase → SQL Editor → New query → paste → Run. One table comes back.
--
-- Free plan limits: 1 GB of file storage (photos and videos in pace-photos)
-- and 500 MB of database (the rows). Usage → "Storage size" is the first,
-- "Database size" the second.
--
-- section "1 files by kind": each photo is two files (diary copy + full size),
--   each video two (video + still).
-- section "2 files by status": does anything still point at the file?
--   "erased session": the session was deleted for good, its files were not. The
--     app now removes these itself (weekly, on sync), see README → Storage.
--   "no session row": the folder's session never reached Supabase, or is mid-upload.
--   "not in its session": the session lives on, but no longer lists this file
--     (removed in an edit before Recently deleted existed).
--   Anything in Recently deleted still counts as in use.
-- section "3 database": the rows, per table.

with o as (
  select name, created_at, coalesce((metadata->>'size')::bigint, 0) as bytes,
    split_part(name, '/', 1) as uid, split_part(name, '/', 2) as sid,
    regexp_replace(regexp_replace(name, '\.full\.jpg$', '.jpg'), '\.video$', '.video.jpg') as slot,
    case when name ~ '\.video$'     then 'video'
         when name ~ '\.video\.jpg$' then 'video still'
         when name ~ '\.full\.jpg$'  then 'full-size photo'
         when name ~ '\.jpg$'        then 'diary photo'
         else 'other' end as kind
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
), report as (
  select '1 files by kind' as section, kind as what, count(*) as files, sum(bytes) as bytes from o group by kind
  union all
  select '1 files by kind', 'all files', count(*), coalesce(sum(bytes), 0) from o
  union all
  select '2 files by status', status, count(*), sum(bytes) from tagged group by status
  union all
  select '3 database', 'whole database', null, pg_database_size(current_database())
  union all
  select '3 database', 'public.' || relname, null, pg_total_relation_size(relid)
  from pg_catalog.pg_statio_user_tables where schemaname = 'public'
)
select section, what, files, pg_size_pretty(bytes) as size
from report order by section, bytes desc;
