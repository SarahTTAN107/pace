# Pace — deploy to Vercel, sync with Supabase

Static site, no build step. Data lives on the phone first and syncs to your own Supabase project.

## 0. Right now, nothing is syncing

Checked against your project on 17 Sep 2026 — it answers, but two things are still off:

- **Anonymous sign-ins are disabled** → `Anonymous sign-ins are disabled`
- **The tables do not exist yet** → `Could not find the table 'public.sessions'`

Until both are fixed the app works perfectly but keeps everything on the phone, and Settings says **Not backed up**. Do step 1.

## 1. Supabase setup (once)

1. SQL Editor → New query → paste **supabase-schema.sql** → Run. It creates three tables, turns on row-level security, and creates the private `pace-photos` bucket with owner-only policies.
2. Authentication → Sign In / Providers → turn on **Anonymous sign-ins**. The app has no login screen: on first launch it signs itself in anonymously and reuses that identity forever, which is what gives RLS a `user_id` to lock your rows to.
3. Authentication → URL Configuration → add your Vercel URL to Site URL.

The project URL and **anon** key are already baked into `index.html`. That is correct and safe for a browser app: the anon key only lets a caller do what RLS allows, and RLS restricts every row to `auth.uid() = user_id`. Never put the `service_role` key in this file.

## 2. Deploy

**Dashboard:** vercel.com → Add New → Project → drag this folder in.

**CLI:**
```
npm i -g vercel
cd pace-vercel
vercel --prod
```

## 3. Install on your iPhone

1. Open the Vercel URL in **Safari** (only Safari can install to the Home Screen).
2. Share → **Add to Home Screen**.
3. That's it — no account, no login. The app signs itself in silently on first launch.

## Is it actually secure?

What protects the data, in order of how much it matters:

1. **Row-level security.** Every table has policies allowing only `auth.uid() = user_id`, for select, insert, update and delete. `user_id` also defaults to `auth.uid()`, so the client cannot write a row belonging to anyone else. This is the real lock.
2. **The anon key is not a secret and does not need to be.** It identifies the project and nothing more; with RLS on it grants access to zero rows until someone holds a valid session. Never replace it with `service_role`, which bypasses RLS entirely.
3. **Private storage bucket.** `pace-photos` is not public. Photos are only ever read through signed URLs that expire in 10 minutes, and the storage policies confine each identity to its own `<user_id>/` folder.
4. **Transport.** Vercel and Supabase are HTTPS only, and `vercel.json` sends HSTS, `frame-ancestors 'none'`, `X-Frame-Options: DENY`, `nosniff`, `no-referrer` and a Content-Security-Policy whose `connect-src` allows your Supabase project and nothing else — so even a successful script injection has nowhere to send your data.
5. **At rest.** Supabase encrypts disks and backups; on the phone the log sits in Safari's storage for that one origin, behind your device passcode and iOS encryption.

### Verify it yourself

- Log a session on the phone, then open Supabase → Table Editor → `sessions`. The row should be there within a couple of seconds.
- Storage → `pace-photos` → a folder named with your user id, one subfolder per session.
- Open the bucket's file URL in a private window with no signed token: it must 400/403.
- In Settings, the sync row should read **Everything is in Supabase**. Amber means changes are waiting; red means it is not reaching the project at all.

## How sync behaves

- **Local first.** Every action writes to the phone immediately. The app is fully usable with no signal.
- **Syncs on open, a second or two after every save or delete, and when the connection returns**, plus a **Sync now** button in Settings. The sync row counts anything still waiting, so nothing is stranded silently.
- **Last write wins per row**, compared on `updated_at`. Deletions travel as tombstones, so removing a session on one device removes it on the others.
- **The first launch pushes whatever is already on the phone** up to the cloud.
- **Photos** are compressed to about 780px, uploaded to the private bucket at `<user_id>/<session_id>/<n>.jpg`, and fetched back through 10-minute signed URLs when you open a day. A photo that fails to upload stays on the phone and retries on the next sync.

## Files

- `index.html` — the whole app, one self-contained file.
- `supabase-schema.sql` — tables, RLS policies, storage bucket and its policies.
- `sw.js` — service worker; caches the app shell so it opens offline.
- `manifest.webmanifest`, `icon-*.png` — Home Screen name and icons. Swap the artwork, keep the filenames.
- `vercel.json` — stops Vercel caching `index.html` and `sw.js`, so updates reach your phone.

## Rotating the anon key

If you ever need to rotate it (Supabase dashboard → Project Settings → API → JWT Settings → rotate):

1. Rotating invalidates existing sessions — every device signs in again.
2. Edit the `anonKey` value in the `window.PACE_SUPABASE` block near the top of `index.html` (or ask me to rebuild it) and redeploy.
3. Because the service worker caches aggressively, bump `CACHE` in `sw.js` (`pace-v1` → `pace-v2`) in the same deploy so phones fetch the new file instead of the cached old one.

A rotated key does not expose old data: the key never granted more than RLS allows.

## One identity per install

With no login there is no password to re-enter — and no way to prove you are you on a second device. Practical consequences:

- The anonymous identity lives in this phone's local storage. **Delete the Home Screen app or clear Safari data and that identity is gone**; the app signs in as a new anonymous user and the old rows become unreachable, though they stay in your Supabase tables.
- A second device gets its own identity and its own log. Cross-device sync would need a real login — say the word and I'll put it back.
- Before switching domains or wiping the phone: **Export backup** in Settings, then **Restore from backup** on the other side.

If you ever want the rows recovered after a wipe, they are still in the `sessions` table under the old `user_id` — reachable from the Supabase dashboard, not from the app.

## Your data, plainly

Vercel serves files and never sees your log. Supabase holds your rows under your account, readable only by you. The phone keeps a full local copy, so **Export backup** in Settings is still worth using before switching domains or clearing Safari data.
