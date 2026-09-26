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

**Photo/video viewer and video support:** no SQL needed. Deploy `vercel.json` together with `index.html`: its Content-Security-Policy gains `media-src`, and without it videos will not play. If you set a file size limit or allowed MIME types on the `pace-photos` bucket, allow `video/*` and at least 50 MB.

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
- **Custom tags sync** (stored inside `prefs.data.customTags`) and merge as a set across devices.
- **Last write wins per row**, compared on `updated_at` — and enforced by a Postgres trigger, so a stale client cannot overwrite a newer row even if it tries.
- **Archived hobbies** sync as `hobbies.archived = true`. They leave the timer picker but stay in the diary, stats and "Split by hobby" with their name and colour. Restore them from **You → Archived**, or type the same name into Add a hobby. Only an archived hobby can be deleted outright (two taps), and deleting it leaves its past sessions unlabelled.
- **Deletions travel as tombstones** (`deleted: true` rows), never hard deletes. That is what stops another open tab or a second device re-uploading something you just erased. **Clear all data** writes tombstones for every session and hobby, removes the photo objects, and only then resets the phone; if the cloud step fails it deletes nothing and tells you so.
- **The first launch pushes whatever is already on the phone** up to the cloud.
- **Photos** are compressed to about 780px for the diary and uploaded to the private bucket at `<user_id>/<session_id>/<n>.jpg`, plus a full-size copy (up to 2400px) at `<n>.full.jpg`. The small copies come back through signed URLs when you open a day or view the Photos heatmap; the full-size one only when you enlarge or download the photo. A photo that fails to upload stays on the phone and retries on the next sync.
- **Videos** (up to 50 MB each, the Supabase free-plan upload limit) are uploaded to `<n>.video`, with a still frame at `<n>.video.jpg` that the diary and heatmap show. `photo_paths` stores that still frame's path, so no schema change is needed, and an older copy of the app shows the still instead of breaking.
- **Until they upload, videos and full-size photos wait in the browser's IndexedDB**, not localStorage (Safari's ~5 MB would not hold them). Once uploaded, the phone's copy is deleted and the bucket is the only copy. Enlarging or downloading them then needs a connection; the small photo copy still works offline.
- **Enlarge and download:** in the Diary, open a day and tap a session, its thumbnail or **Expand**. Photos and videos fill the screen (swipe, the arrows or ← → to move between them, Esc to close), with the full note and tags below. **Download** saves the largest copy available. On a phone it opens the share sheet, so **Save Image / Save Video** puts it in Photos; on a computer it downloads the file.
- **Phone storage never silently fills.** Safari gives the app ~5 MB. Once a photo is safely in the bucket its local copy is only a cache: past ~3 MB, cached photos older than 30 days are dropped; if a save would still hit the limit, older uploaded photos go first. Photos not yet uploaded are never dropped.

## Files

- `index.html` — the whole app, one self-contained file.
- `supabase-schema.sql` — tables, RLS policies, storage bucket and its policies.
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

**Download a copy / Merge a copy** remain in Settings as an optional personal archive. Merging now combines row-by-row (newest wins, deletions respected) instead of replacing the phone's data, so an old file can't roll anything back.

On the Supabase free plan there are no automatic database backups; if you want a second safety net, upgrade to Pro (daily backups) or download a copy occasionally.
