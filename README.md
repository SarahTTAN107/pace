# Pace — deploy to Vercel, sync with Supabase

Static site, no build step. Data lives on the phone first and syncs to your own Supabase project.

## 1. Supabase setup (once)

1. **SQL Editor** → New query → paste **supabase-schema.sql** → Run. It creates the tables, row-level security, and the private `pace-photos` bucket.
2. **Authentication → Sign In / Providers:**
   - **Email**: on.
   - **Anonymous sign-ins**: **off**. Pace signs in with email only.
   - **Allow new users to sign up**: **off** (invite-only). Matches `allowSignup: false` in `index.html`.
3. **Authentication → Users → Add user → Create new user**: enter the email, set any password (it is never used), tick **Auto Confirm User**. Do this for yourself if your address isn't listed yet, and for each friend you invite.
4. **Authentication → Emails → SMTP Settings**: custom SMTP (e.g. Gmail with an app password, no spaces). Required on free projects to edit templates.
5. **Email Templates**: put `{{ .Token }}` in **Magic Link** (sign-in) and **Change Email Address**:
   ```html
   <p>Your Pace code is <strong>{{ .Token }}</strong>. It expires in an hour.</p>
   ```
6. **Authentication → URL Configuration**: add your Vercel URL as Site URL.

The project URL and **anon** key in `index.html` are safe to ship: RLS restricts every row to `auth.uid() = user_id`. Never put the `service_role` key in this file.

To open sign-up to anyone with the link, set `allowSignup: true` in the `window.PACE_SUPABASE` block of `index.html` **and** turn **Allow new users to sign up** back on.

### Upgrading an existing project

**Change the hobby in Log a past session (PACE-27):** no SQL needed. The past-session sheet gets the same hobby picker as the Timer. It starts on the Timer's hobby, and picking another one there does not change the Timer. Nothing synced changes.

**Diary days open as stories (PACE-26):** no SQL needed. Tapping a day plays its sessions full screen, with name pills across the top; the day's list is under •••. Nothing synced changes, so a device still running an older copy of the app keeps opening the list until it updates.

**Diary opens with Show memories (PACE-25):** no SQL needed. The Diary's Intensity / Blend / Media control becomes one Show memories switch (on: the media diary; off: Intensity). It is on every time the app opens and is not saved, so the old Default Diary Mode setting is no longer used. A device still running an older copy of the app keeps its three modes until it updates.

**Diary pictures kept in IndexedDB (PACE-19):** no SQL needed. On the first launch of this version, each phone moves the diary pictures it holds out of localStorage into IndexedDB, checking each one before letting go of the old copy. If that cannot finish (no IndexedDB, or an older copy of the app still open in another tab), the pictures stay where they were and the next launch carries on. Nothing synced changes, so other devices are unaffected.

**Photo/video viewer and video support:** no SQL needed. Deploy `vercel.json` together with `index.html`: its Content-Security-Policy gains `media-src`, and without it videos will not play. If you set a file size limit or allowed MIME types on the `pace-photos` bucket, allow `video/*` and at least 50 MB.

**Recently deleted:** run this once **before** deploying the `index.html` that adds Recently deleted (re-running the whole `supabase-schema.sql` also works):

```sql
alter table public.sessions add column if not exists trashed_at timestamptz;
alter table public.sessions add column if not exists trashed_media jsonb not null default '[]'::jsonb;
notify pgrst, 'reload schema';
```

Until the columns exist, sync stops with *"Supabase needs the Recently deleted columns"*; nothing on the phone is lost. A device still running an older copy of the app shows sessions in Recently deleted as normal sessions until it updates.

**Hobby emojis:** run this once **before** deploying the `index.html` that adds hobby emojis (re-running the whole `supabase-schema.sql` also works):

```sql
alter table public.hobbies add column if not exists emoji text not null default '';
notify pgrst, 'reload schema';
```

Until the column exists, sync stops with *"Supabase needs the hobby emoji column"*; nothing on the phone is lost. A device still running an older copy of the app keeps showing colour dots until it updates; its hobby edits leave the emoji in place.

Run this once **before** deploying a new `index.html` that adds the hobby archive (re-running the whole `supabase-schema.sql` also works — it is idempotent):

```sql
alter table public.hobbies add column if not exists archived boolean not null default false;
notify pgrst, 'reload schema';
```

The `notify` line makes the API pick up the new column immediately. Without it you can see *"Could not find the 'archived' column of 'hobbies' in the schema cache"* even after the column exists.

If the new app goes live first, sync stops with an error on the settings row until the column exists; nothing on the phone is lost.

## 2. Deploy

**Dashboard:** vercel.com → Add New → Project → drag the repository folder in (or import the GitHub repo).

**CLI:**
```
npm i -g vercel
vercel --prod   # run from the repository root
```

## 3. Install on your iPhone

1. Open the Vercel URL in **Safari** (only Safari can install to the Home Screen).
2. Share → **Add to Home Screen**.
3. Open it from the Home Screen, enter your email, type the code. Safari and the Home Screen app keep separate storage, so sign in from the Home Screen icon.

**On a laptop:** open the same URL in any browser, sign in with the same email and code. The whole diary syncs down. **Settings → Sign out** removes it from that computer (unsynced changes are uploaded first; if that fails you're asked to tap again).

## Is it actually secure?

What protects the data, in order of how much it matters:

1. **Row-level security.** Every table has policies allowing only `auth.uid() = user_id`, for select, insert, update and delete. `user_id` also defaults to `auth.uid()`, so the client cannot write a row belonging to anyone else. This is the real lock.
2. **The anon key is not a secret and does not need to be.** It identifies the project and nothing more; with RLS on it grants access to zero rows until someone holds a valid session. Never replace it with `service_role`, which bypasses RLS entirely.
3. **Private storage bucket.** `pace-photos` is not public. Photos and videos are only ever read through signed URLs that expire within an hour, and the storage policies confine each identity to its own `<user_id>/` folder.
4. **Transport.** Vercel and Supabase are HTTPS only, and `vercel.json` sends HSTS, `frame-ancestors 'none'`, `X-Frame-Options: DENY`, `nosniff`, `no-referrer` and a Content-Security-Policy whose `connect-src` allows your Supabase project and nothing else — so even a successful script injection has nowhere to send your data.
5. **At rest.** Supabase encrypts disks and backups; on the phone the log sits in Safari's storage for that one origin, behind your device passcode and iOS encryption.

### Verify it yourself

- Log a session on the phone, then open Supabase → Table Editor → `sessions`. The row should be there within a couple of seconds.
- Storage → `pace-photos` → a folder named with your user id, one subfolder per session.
- Open the bucket's file URL in a private window with no signed token: it must 400/403.
- In Settings, the sync row should read **Everything is in Supabase**. Amber means changes are waiting; red means it is not reaching the project at all.

## How sync behaves

- **Local first.** Every action writes to the phone immediately. The app is fully usable with no signal.
- **Syncs on open, on resume from the background, every 5 minutes while open, 1.5 s after any change** (sessions, hobbies, colours, theme, custom tags), **when the connection returns, and as the app goes to the background** if anything is waiting. A change made mid-sync queues a follow-up sync instead of being skipped. **Sync now** is still in Settings.
- **Pulls are paginated**, so diaries past 1,000 rows (tombstones count) restore completely.
- **Defaults never overwrite the cloud.** A fresh or restored phone adopts your cloud theme, hobby names/colours and custom tags; untouched defaults only upload when the cloud has none.
- **Deleting is recoverable for 30 days.** Deleting a session, or removing a photo or video while editing one, moves it to **Settings → Recently deleted**, which syncs like any edit (a restore on one device wins over an older delete on another). After 30 days, or on **Delete now**, the row becomes a tombstone and its files are removed from the bucket; a file delete that fails is retried on the next sync. **Clear all data** skips Recently deleted and cannot be undone.
- **Custom tags sync** (stored inside `prefs.data.customTags`) and merge as a set across devices.
- **Last write wins per row**, compared on `updated_at` — and enforced by a Postgres trigger, so a stale client cannot overwrite a newer row even if it tries.
- **Archived hobbies** sync as `hobbies.archived = true`. They leave the timer picker but stay in the diary, stats and "Split by hobby" with their name and colour. Restore them from **You → Archived**, or type the same name into Add a hobby. Only an archived hobby can be deleted outright (two taps), and deleting it leaves its past sessions unlabelled.
- **Deletions travel as tombstones** (`deleted: true` rows), never hard deletes. That is what stops another open tab or a second device re-uploading something you just erased. **Clear all data** writes tombstones for every session and hobby, removes the photo objects, and only then resets the phone; if the cloud step fails it deletes nothing and tells you so.
- **The first launch pushes whatever is already on the phone** up to the cloud.
- **Photos** are compressed to about 780px for the diary and uploaded to the private bucket at `<user_id>/<session_id>/<n>.jpg`, plus a full-size copy (up to 2400px) at `<n>.full.jpg`. A phone that does not have a small copy fetches it once, through a signed URL, when a screen first shows it (the Media diary, a day, Recently deleted), then keeps it; the full-size one only when you enlarge or download the photo. A photo that fails to upload stays on the phone and retries on the next sync.
- **Videos** (up to 50 MB each, the Supabase free-plan upload limit) are uploaded to `<n>.video`, with a still frame at `<n>.video.jpg` that the diary and heatmap show. `photo_paths` stores that still frame's path, so no schema change is needed, and an older copy of the app shows the still instead of breaking.
- **Pictures live in the browser's IndexedDB**, not localStorage (Safari gives localStorage ~5 MB, a few dozen photos). localStorage keeps only the diary text and the name of each picture, so it stays small and saves stay fast however many photos there are. IndexedDB has two shelves:
  - **Waiting:** videos, full-size photos and diary pictures not uploaded yet. Nothing here is cleared on its own; it leaves only after a confirmed upload, a delete, signing out or a different account signing in. Once uploaded, videos and full-size photos are deleted from the phone and the bucket is the only copy, so enlarging or downloading them needs a connection.
  - **Copies:** the small diary pictures of uploaded media, each also in the bucket. They stay, so the diary opens without downloading. Past 150 MB, the pictures viewed longest ago are cleared first, and are fetched again if needed.
- **Without IndexedDB** (some private-browsing modes), the app works as before: pictures not uploaded yet are kept in localStorage, and fetched pictures are kept in memory until the app closes.
- **Enlarge and download:** in the Diary, open a day and tap a session, its thumbnail or **Expand**. Photos and videos fill the screen (swipe, the arrows or ← → to move between them, Esc to close), with the full note and tags below. **Download** saves the largest copy available. On a phone it opens the share sheet, so **Save Image / Save Video** puts it in Photos; on a computer it downloads the file.
- **Phone storage never silently fills.** Only the copies shelf can grow, and it is capped (see above). Should localStorage ever hit Safari's limit (only possible without IndexedDB), uploaded pictures kept there go first; pictures not yet uploaded are never dropped.

## Storage: what fills it, and keeping it lean

The free plan has **1 GB of file storage** (photos and videos) and **500 MB of database** (the rows). The rows are tiny, a few kB per hundred sessions, so it is the files that grow: a video can be up to 50 MB, a full-size photo is about 0.5–1.5 MB, the diary copy and video still about 50–100 kB.

**Watching the limits:** the app shows no storage meter. Supabase emails the project owner when usage nears or passes a free-plan limit, and **Usage** in the dashboard shows the live numbers. Phone space looks after itself (see *Phone storage never silently fills* above); if a save ever hits Safari's limit, the app says *Phone storage full*.

**See what is using it:** Supabase → SQL Editor → paste **storage-report.sql** → Run. It only reads, and returns one table with three sections:

1. Space by kind: diary photos, full-size photos, video stills, videos.
2. Files nothing points at any more: from sessions **erased for good**, from **no session row**, or **not in its session** (removed in an edit before Recently deleted existed). Everything in Recently deleted counts as in use.
3. The database size, per table.

**Cleaned up automatically:** once a week, after a sync, the app removes the files of sessions that are already erased for good (their row in `sessions` is `deleted = true`). These are left over from deletes made before Recently deleted existed, or from a purge on a phone that was wiped before it could upload the purge. It never touches a session that is in the diary or in Recently deleted, or one this phone still holds; a large backlog is cleared 100 sessions per sync. No SQL needed.

Do not delete files by running `delete from storage.objects` in SQL: that removes the row but can leave the file in the bucket, still counted. Delete through the app, or in Storage → `pace-photos` in the dashboard.

## Files

- `index.html` — the whole app, one self-contained file.
- `supabase-schema.sql` — tables, RLS policies, storage bucket and its policies.
- `storage-report.sql` — read-only report of what uses the storage and the database.
- `sw.js` — service worker; network-first for the page (updates land on the next open), cache fallback offline, and it never touches Supabase requests.
- `manifest.webmanifest`, `icon-*.png` — Home Screen name and icons. Swap the artwork, keep the filenames.
- `vercel.json` — stops Vercel caching `index.html` and `sw.js`, so updates reach your phone.

## Rotating the anon key

If you ever need to rotate it (Supabase dashboard → Project Settings → API → JWT Settings → rotate):

1. Rotating invalidates existing sessions — every device signs in again.
2. Edit the `anonKey` value in the `window.PACE_SUPABASE` block near the top of `index.html` (or ask me to rebuild it) and redeploy.
3. Because the service worker caches aggressively, bump `CACHE` in `sw.js` (`pace-v1` → `pace-v2`) in the same deploy so phones fetch the new file instead of the cached old one.

A rotated key does not expose old data: the key never granted more than RLS allows.

## Accounts

Your diary belongs to your **email account**, not to a browser. There is no password: every sign-in mails a code.

- **New phone, wiped phone, laptop:** open Pace, enter your email and the code. Everything comes down on the next sync.
- **Logged before signing in?** "Use on this device without signing in" keeps sessions on that device only; signing in later uploads them to your account. If a device still holds a *different* account's leftovers, they are discarded rather than uploaded into yours.
- **Change email:** Settings → Change email, confirmed by a code sent to the new address.
- **Existing phones** that were already signed in keep working — your old anonymous account became a normal email account when you attached the address.

## Your data, plainly

Vercel serves files and never sees your log. Supabase holds your rows under your account, readable only by you — that *is* the backup. With a recovery email attached there is nothing to export: clear Safari, switch domains or change phones, sign in with the code, and the diary comes back.

**Download a copy / Merge a copy** remain in Settings as an optional personal archive. The file includes the diary pictures this phone holds, above all any not uploaded yet; merging a file moves its pictures into IndexedDB. Merging now combines row-by-row (newest wins, deletions respected) instead of replacing the phone's data, so an old file can't roll anything back.

On the Supabase free plan there are no automatic database backups; if you want a second safety net, upgrade to Pro (daily backups) or download a copy occasionally.
