# Pace — backlog

Open work first, in the order it will be done; finished tickets are under **Done** at the end, newest first. Move an item to a PR when work starts.

## Up next

1. **PACE-22** · Tiny calendar pictures, load only what is on screen. Second half of the loading fix (PACE-19, done).
2. **PACE-23** · Upload name can clash with a file about to be erased. Small fix; a bug that loses a photo on other devices, so before the polish.
3. **PACE-18** · Timer becomes a sticky + button, three tabs. High priority; before the tab bar work it reshapes.
4. **PACE-20** · Settings and sign-in as inset lists. Small, finishes the redesign.
5. **PACE-21** · Tab bar icons, motion and accessibility pass. Small; sets the style PACE-8 uses.
6. **PACE-8** · Milestones tab. Biggest; settle its five decisions before building.

## PACE-22 · Diary: tiny calendar pictures, load only what is on screen

**Type:** Improvement · **Tag:** improvement · **Priority:** High · **Status:** Open (not started; PACE-19, its first half, is done)

**From:** the PACE-19 review (4 Oct 2026). Second half of the loading fix.

**Problem:** each calendar square is about 50 px, but it shows the ~780px diary copy, roughly 15 times more data than it needs (about 120 KB instead of about 8 KB). Scrolling back a year in Media mode holds hundreds of these large pictures in memory. On an iPhone that can make scrolling stutter or make Safari reload the page. The diary also loads pictures for all six months it has rendered at once, not just the ones near the screen.

**Want:**

- **A tiny picture for calendar squares:** about 160 px, about 8 KB, named after its diary copy (`3.jpg` → `3.cell.jpg`, `3.video.jpg` → `3.video.cell.jpg`).
  - **New photos and videos:** made when the media is added and uploaded with the diary copy, so every device gets it.
  - **Existing photos:** each phone makes it from the diary copy the first time it downloads that copy, and keeps it on the copies shelf (PACE-19). Not uploaded, to keep this change small. Decide later whether one device should upload them for the others.
  - **Fallback:** if there is no tiny picture (e.g. media added by an older version of the app), the calendar uses the diary copy, as today.
- **What uses which:** calendar squares use the tiny picture; the day sheet and Recently deleted keep the diary copy; the viewer keeps the full-size file.
- **Load only what is near the screen:** months are loaded as they scroll close to view, not all at once.

**Also update:**

- **Deletes:** removing one photo or video in an edit (`mediaFiles`) must also remove its tiny picture. Erasing a whole session already removes its whole folder, so that needs no change.
- **storage-report.sql:** count tiny pictures as their own kind ("calendar picture") and link them to their slot. Today they would be counted as diary photos and reported as "not in its session".
- **README:** nothing to run in Supabase; no new table or column.

**Cost:** about 8 MB of bucket space per 1,000 photos, out of the free plan's 1 GB. Fewer and smaller downloads also use less of the free plan's monthly download allowance.

**Test on iPhone:** scrolling back a year in Media mode, memory and smoothness compared with before; a session with photos added by an older version of the app; removing a photo in an edit, then checking with storage-report.sql that its tiny picture is gone.

## PACE-23 · Sync: a new upload can reuse a file name that is about to be erased

**Type:** Bug · **Tag:** bug · **Priority:** Medium · **Status:** Open (found while testing PACE-19; not fixed there)

**Problem:** a new photo or video takes the first file name in its session that no slot and no Recently deleted item uses (`uploadMedia`). An item erased for good (**Delete now**, or after 30 days) leaves Recently deleted at once, but its files are only removed from the bucket at the next sync, *after* that sync's uploads. So when, before a sync, a photo is erased for good and a new one is added at the same position in the same session (e.g. both offline), the new photo uploads under the erased one's name and the queued delete then removes it. The session points at a file that is gone: other devices cannot show it.

**Fix:** treat names waiting in the delete queue (`purgeQueue`) as taken when choosing a name for a new upload. One line in `uploadMedia`; add a test for the offline case.

## PACE-18 · Timer becomes a sticky + button: three tabs

**Type:** Improvement · **Tag:** improvement · **Priority:** High · **Status:** Open (not started)

**Problem:** the Timer takes a whole tab (Timer, Diary, Stats, You), even though starting or logging a session is one quick action you may want from anywhere.

**Want:** a sticky **+** button on every screen replaces the Timer tab. The tab bar has three tabs: **Diary**, **Stats** and **You**. Stats later becomes the Milestones and companionship tab (PACE-8).

**Scope (to refine):**

- **+ button:** floats in the same place on every tab, above the tab bar and clear of the Diary's **↓ Today** button (PACE-14). It is at least 44 pt, with a VoiceOver label ("Start or log a session").
- **Tapping +** opens a bottom sheet in the PACE-7 style: hobby picker, **Clock in**, **Countdown** (goal chips 25 / 45 / 60 m) and **Log a past session**. Grabber, drag down, tap outside or Esc to close.
- **While a session runs:** the + turns into a live pill showing the hobby and running time (e.g. "🎾 12:34"), still on every tab. Tapping it reopens the timer sheet with pause, resume and stop. Closing the sheet never stops the session.
- **Logged today** moves out of the Timer: into the + sheet, or onto today in the Diary. Decide which. Editing a session from there (PACE-11) keeps working.
- **Launch tab:** the app opens on the Diary instead of the Timer.
- **Session complete** and the undo toast (PACE-12) still appear after Stop, on whichever tab you are on.

**Notes:**

- Clock in and Countdown already run independently, one live session at a time (PACE-5, done), which is the simpler fit for a single pill.
- Ties in with PACE-21 (iOS tab bar with icons, was PACE-7 step 6): the three-tab bar can be built in that style.
- **Companionship** is a new idea for the Stats/Milestones tab, not yet in PACE-8. It needs its own scope.
- No data model or sync change expected: the live session (`store.live`) and logging stay as they are.

## PACE-20 · Settings and sign-in: iOS Settings-style inset lists

**Type:** Improvement · **Tag:** improvement · **Priority:** Medium · **Status:** Open (not started)

**From:** PACE-7 step 5.

**Problem:** the You/Settings screen and the sign-in screens have not had the PACE-7 redesign yet. They still use the older layout, so they look different from the Timer and Diary.

**Want:** the same look as the iPhone Settings app. Grouped, rounded inset lists with hairline separators, rows with a label on the left and the value or control on the right, and sentence-case section captions above each group. Sign-in (email, then code) uses the same cards and pill buttons as the rest of the app.

**Scope:** You → hobbies, archive, Default Diary Mode, theme, Recently deleted, Your data, sync status, sign out; and the sign-in and code screens. 44 pt targets and VoiceOver labels throughout. No behaviour change.

## PACE-21 · App-wide behaviour: tab bar icons, motion, accessibility pass

**Type:** Improvement · **Tag:** improvement · **Priority:** Medium · **Status:** Open (not started)

**From:** PACE-7 step 6.

**Problem:** the bottom tab bar is text with a small mark, no icons, unlike iOS tab bars. Motion and accessibility have been handled screen by screen but never checked across the whole app.

**Scope:**

- **Tab bar:** an icon above each label (Timer, Diary, Stats/Milestones, You), filled when selected. If PACE-8 lands first, use the Milestones icon.
- **Motion:** consistent sheet and screen transitions, all off under Reduce Motion.
- **Accessibility pass:** contrast in Light and Dark, larger text (Dynamic Type) without clipping, VoiceOver order and labels on every screen, and 44 pt targets everywhere.

## PACE-8 · Milestones tab: replace Stats with AI-assisted milestones

**Type:** New feature · **Tag:** feature · **Priority:** High · **Status:** Open (not started; blocked on the decisions below)

**Problem:** Stats shows totals and comparisons (this week vs last, weekly trend, split by hobby, time of day), but not *progress towards something*. It cannot answer "how far am I from my goal?" or celebrate reaching one.

**Want:** replace the **Stats** tab with a **Milestones** tab. You set milestones per hobby, the app reports progress towards them, Wrapped-style recaps celebrate each month and year, and an AI assistant helps you choose milestones and explains your progress.

**Scope:**

- **Milestones per hobby**
  - Lifetime hour milestones, e.g. 100 h, 1,000 h, the 10,000-hour mark.
  - Optional shorter targets: weekly hours (e.g. 3 h/week) or sessions per week (see *Targets: options* below).
  - Each shows hours done, % complete, and a projected date at your current pace.
- **Achievements**
  - Awarded automatically as you pass thresholds (e.g. first 10 h, 100 h, 1,000 h, 10,000 h), with streaks such as weeks in a row a weekly target was met.
  - A clear moment when one is reached (sheet or banner, subtle motion, respects Reduce Motion), plus a list of what you have earned so far.
- **Progress reporting**
  - Per hobby: this week / month / all time, trend vs your own usual (last 4 weeks), progress bar against the milestone.
  - A short summary across all hobbies at the top.
- **AI integration**
  - Suggest realistic milestones from your history ("you average 2.5 h/week on Tennis; 100 h would take about 9 months").
  - Write weekly or monthly progress reports in plain language, and point out patterns (best time of day, slipping hobbies).
  - Ask questions about your practice ("how much piano did I do in August?").
- **Wrapped-style recaps** (was PACE-17)
  - **Problem:** Stats reads like a dashboard: accurate but flat. Nothing makes looking back feel rewarding or worth sharing.
  - **Story format** like Spotify Wrapped: full-screen cards, one big, bold insight per card. Tap or swipe to go forward or back, progress dashes at the top, close with drag down or Esc.
  - **Headline cards:** total time, top hobby and its share, longest session, best streak, busiest day and month, favourite time of day ("You're a morning player"), most-used tags, first session of the period, photos and videos captured. Milestones and achievements reached in the period get their own cards.
  - **Periods:** a monthly recap, and a year in review that unlocks at the end of the year. Optionally a recap for any month or year in the Diary's history.
  - **Look:** big type and bold colour per card, from the hobby's colour (PACE-13) and the Water palette (PACE-7). Subtle motion, off under Reduce Motion.
  - **Share:** save or share a card as an image.
  - **AI is optional:** the AI progress reports can write a card's caption, but every recap works without AI.
  - Uses the visible-sessions view (no trashed sessions, PACE-12). No data model or sync change needed for the recaps themselves.
- **Keep from Stats:** the useful parts (split by hobby, time of day), moved into Milestones or a per-hobby detail view, so nothing is lost.
- **Design:** built in the PACE-7 iOS style from the start (grouped cards, system font, 44 pt targets, VoiceOver summaries for every chart).

**Decisions needed before building:**

1. **AI provider and where it runs.** An AI API key must never ship in `index.html`. Calls need a small server-side function (e.g. a Supabase Edge Function) that holds the key and checks the signed-in user.
2. **Privacy.** Sending diary data (hobbies, times, notes) to an AI provider is a change from "your data stays in your own Supabase". It should be opt-in, say exactly what is sent, and work fully without AI (milestones and achievements must not depend on it). Notes and photos stay out unless you choose otherwise.
3. **Data model.** New synced data for milestones and earned achievements (a `milestones` table with RLS, or inside `prefs`), following the existing rules: last write wins, tombstones, and defaults never overwrite the cloud.
4. **CSP.** `vercel.json` `connect-src` only allows the Supabase project today; the AI call should go through Supabase so it stays that way.
5. **Offline.** Milestones and achievements work offline; AI features show as unavailable without a connection.

**Replaces:** PACE-7 step 4 (Stats redesign, paused), PACE-17 (Wrapped-style reporting, merged in above) and the Stats benchmark request from the 27 Sep 2026 feedback round, below.

**Original ask (feedback round, 27 Sep 2026):** the main job of Stats is to show progress, e.g. "how many hours have I put into this hobby, against a benchmark?"

**Targets: options.** How to set a target for each hobby:

| Option | How it works | Good for | Downside |
|---|---|---|---|
| **A. Weekly time budget** | Set e.g. 3 h/week per hobby. Stats shows this week's hours vs. budget and a streak of weeks met. | Steady habits (guitar, reading) | You have to pick a number up front |
| **B. Milestone total** | Set a long-term total, e.g. 100 h or 1,000 h. Stats shows lifetime hours, % done and a projected finish date at your current pace. | Skills you want to build over months or years | Slow to move, little day-to-day feedback |
| **C. Session frequency** | Set e.g. 4 sessions/week, regardless of length. | Hobbies where showing up matters more than duration | Ignores how much time you actually put in |
| **D. Automatic baseline (no target)** | The app benchmarks each hobby against your own last 4 weeks' average. Stats shows "this week vs. your usual" (up/down %). | Starting out, when you don't know your target yet | Measures consistency, not ambition |

**Targets: recommendation.** ship **D** as the default so every hobby gets a benchmark with zero setup. Then add an optional per-hobby target where you pick **A (weekly hours)** or **B (milestone total)**, suggested from your baseline (e.g. "you average 2.5 h/week — set 3 h?"). Stats would show, per hobby:
- hours this week / month / all time,
- progress bar against the target (or baseline if none is set),
- trend vs. last period, and for milestones a projected finish date.

# Done

## PACE-19 · Diary: media takes a long while to load

**Type:** Bug · **Tag:** bug · **Priority:** High · **Status:** Done ([#33](https://github.com/SarahTTAN107/pace/pull/33), merged 4 Oct 2026). Numbered PACE-17 while in progress; renumbered when `main` used 17 and 18.

**Problem:** in the Diary, photo and video thumbnails take a long time to appear, especially in Media mode. The phone keeps only recent diary copies of uploaded photos and downloads the rest from Supabase when they are needed. That download was slow for four reasons:

1. **One request per day.** Switching to Media asked for every day of the 6 visible months separately (about 180 calls). Each day with photos made its own signing request to Supabase.
2. **One photo at a time.** Within a day, each file was signed, downloaded and converted before the next one started.
3. **The whole store was saved after every day.** Each finished day copied the entire phone store, photos included, and wrote it to phone storage. That meant several MB written over and over, and the app stuttered while it ran.
4. **Nothing loaded on its own, and nothing was remembered.**
   - With Media as the saved Default Diary Mode (PACE-9), nothing downloaded at launch until something was tapped.
   - Thumbnails the app drops to save phone space (past 3 MB, or when Safari's ~5 MB is full) were downloaded again from scratch.
   - Tapping a day while its month was loading downloaded the same files twice.

**Root cause:** each photo's ~780px diary copy (base64 text, about 100–150 KB) lived inside the one localStorage store with every session, which Safari caps at ~5 MB: only a few dozen photos. The app kept dropping copies to stay under it (`evictPhotos`), so every launch downloaded them again, and every save rewrote all the photos still kept.

**Resolution (shipped in #33):**

1. **Quick fix, then replaced.** The first commit batched the loader (one signing request per 100 files, six downloads at a time, one save per batch, no double downloads). It was kept as the download step and replaced as the loader by the lasting fix below.
2. **Pictures moved to IndexedDB** (`pace-media` database, version 1 → 2), on two shelves:
   - **Waiting shelf** (`blobs`): videos, full-size photos and diary pictures not uploaded yet. Never cleared on its own: only a confirmed upload, a delete, sign-out or a different account signing in empties it.
   - **Copies shelf** (`thumbs`, `thumbInfo`): diary pictures of uploaded media, by bucket path. Capped at 150 MB, least recently viewed cleared first.
   - localStorage keeps only text and a short name per picture (`pic-…` key or bucket path): about 1 KB in the test instead of several MB.
3. **One loader for every screen.** Each screen that shows a picture asks for it (`pic()`): the Media diary, the Timer's sessions, a day, the viewer, the edit sheet, Recently deleted, the running session. `loadPics()` reads them from IndexedDB in one go and downloads only what is missing, keeping it on the copies shelf. Media days show a placeholder until their picture loads.
4. **Safety rules from the review, all built:**
   - **Save order:** a picture is saved before the store points to it.
   - **One-time move:** each picture is written, read back and checked before localStorage lets go of it, 20 at a time, resumable, and sync waits for it.
   - **Tidy-up:** after each sync and at launch. Erasing, Undo and discarding media drop their pictures.
   - **Accounts:** a different account signing in empties both shelves and memory. Before this, only sign-out and *Clear everything* did.
   - **Backups:** *Download a copy* reads the pictures back into the file, and merging an old-format backup moves its pictures into IndexedDB.
5. **No change** to Supabase, the schema, `vercel.json` or what syncs. Other devices are unaffected.

**Decisions made while building:**

- **Fallback without IndexedDB:** photos not uploaded yet stay in localStorage as before, but downloaded copies are kept **in memory only**, not written back into localStorage, so it cannot fill up and set off "Phone storage full". The plan had said "today's behaviour" for both.
- **Every screen loads its own pictures**, not only the diary's visible months as planned. As a result, Intensity and Blend no longer download pictures they do not show.
- **Blocked upgrade:** an older copy of the app holding the database open in another tab makes the new one give up after 3 seconds and fall back, rather than hang sync. The next launch finishes the move.
- **Merge with `main`:** the app code combined cleanly with the Timer button changes (#35, #36); tests re-run on the result. Backlog tickets renumbered as above.

**Tested (4 Oct 2026):** the real page in headless Chromium, under the site's Content-Security-Policy, with a fake Supabase (sign-in, database, storage). 50 checks pass, including:

- **One-time move** from an old-version phone (v1 database, pictures in localStorage): nothing left in localStorage, uploaded pictures keep only their path, unsent ones get their key, the database upgrades to version 2.
- **Uploads:** a photo not yet uploaded reaches the bucket with its exact bytes, under a new name when a removed photo still holds the old one. A video uploads with its still, and leaves the waiting shelf afterwards.
- **No repeat downloads:** only the picture missing from the phone is downloaded, and a relaunch downloads nothing.
- **Clean-up:** the uploaded copy leaves the waiting shelf at the next launch; a photo not yet uploaded stays.
- **Edits:** a removed photo shows in Recently deleted, and Undo brings it back with every copy kept. Erasing a session removes its copies.
- **Account change:** a different account signing in empties both shelves and memory.
- **Backups:** the file holds the pictures, with the original bytes; merging an old-format backup moves its pictures into the cupboard.
- **Cap:** over the cap, only the least recently viewed copy is cleared.
- **Fallbacks:** with no IndexedDB, photos stay in localStorage, still upload and still show. With the upgrade blocked by an old tab, nothing is lost and the next launch finishes the move.

**Security and privacy:**

- Photos stay in the private `pace-photos` bucket, protected by row-level security and links that expire after 10 minutes. No new service, no new permission, no change to `vercel.json`.
- On the phone, copies are kept the same way as today (readable only by this site), and are emptied at sign-out, on an account change and by *Clear everything*.

**Options considered and rejected:**

| Option | Why not |
|---|---|
| Make the bucket public | Fast, but anyone with a link could see the photos |
| Long-lasting signed links (days, not 10 minutes) | The browser could reuse them, but a leaked link would work for days |
| Supabase image resizing | Only on paid plans |
| Store photos in the database | Fills the 500 MB database and slows every sync |

**Rejected options:** a public bucket (anyone with a link could see the photos), long-lasting signed links (a leaked link would work for days), Supabase image resizing (paid plans only), photos in the database (fills the 500 MB database, slows every sync).

**Known limits:**

- If Safari clears website data (private browsing, or Safari tabs unused for 7 days; the Home Screen app is not affected), IndexedDB empties. Uploaded pictures download again; photos not yet uploaded are lost, as they were in localStorage before. The risk ends at the next sync.
- The calendar still shows the 780px copy in each ~50 px square: **PACE-22**.

**Follow-ups:**

- **PACE-22:** tiny calendar pictures, and loading only months near the screen.
- **PACE-23:** an older bug found while testing. A new upload can take the name of a file about to be erased.

**Still to check on iPhone after release** (merged before these were run):

- [ ] Open once with existing photos: all still there (the one-time move).
- [ ] Reopen in Media mode: photos appear almost at once, with nothing downloaded.
- [ ] Add a photo offline, then go online: it uploads.
- [ ] Delete, restore, then erase a session.
- [ ] *Download a copy* opens and includes the photos.

## PACE-17 · Stats: Spotify Wrapped-style reporting

**Type:** Improvement · **Tag:** improvement · **Priority:** High · **Status:** Merged into PACE-8 (see *Wrapped-style recaps* there)

## PACE-16 · Storage: see what fills it, clear files of erased sessions

**Type:** Improvement · **Tag:** improvement · **Priority:** Medium · **Status:** Done ([#27](https://github.com/SarahTTAN107/pace/pull/27))

**Problem:** no way to see what uses the free plan's storage, and some of it is files nothing points at: deletes made before Recently deleted (PACE-12) blanked the row and left the photos and videos in the bucket. First report (1 Oct 2026): 10 MB of files out of 1 GB, 1.7 MB of it from erased sessions; database 11 MB out of 500 MB.

**Shipped:**

- **storage-report.sql**, read-only: space by kind (diary photo, full-size photo, video still, video), files nothing points at (erased session, no session row, not in its session), database size per table.
- **Weekly sweep on sync:** removes the files of sessions whose row is a tombstone in Supabase. Never touches a session in the diary, in Recently deleted, or still on that phone. 100 sessions per sync until the backlog is gone.
- **Removed the "% used" bar** from You → Your data. It measured phone space (the ~5 MB Safari allows), not Supabase, and read "31% used" right under the Supabase text, which looked like the cloud filling up. Supabase's own emails and Usage page cover the real limits; phone space already clears itself.
- No schema change, no change to how photos and videos are stored.

**Open:** none needed at today's size. If storage nears the limit, the options are a lower video size limit (50 MB now) or smaller full-size photos (2400px at JPEG quality 0.85 now, about 1 MB each); both lower quality.

## PACE-15 · Diary: pick one hobby in each mode

**Type:** New feature · **Tag:** feature · **Priority:** High · **Status:** Done ([#25](https://github.com/SarahTTAN107/pace/pull/25))

**Problem:** the Diary calendar always shows all hobbies together. In Intensity, Blend and Media you cannot see how a single hobby has progressed over time, e.g. "how often did I play Tennis this summer?".

**Want:** in each Diary mode (Intensity, Blend, Media), a way to pick one hobby, so the calendar shows only that hobby's sessions and you can follow its progress month by month.

**Scope:**

- **Hobby picker** above or next to the Intensity / Blend / Media control: *All hobbies* (default) plus each hobby with its emoji and colour (PACE-13). Archived hobbies are listed too, after the active ones, so their history can still be viewed.
- **Tap again to deselect:** tapping the hobby that is already picked deselects it and goes back to *All hobbies*. With no hobby picked, the Diary always shows *All hobbies*.
- **Intensity:** day shading counts only the chosen hobby's time. Consider using the hobby's colour for the scale instead of the default blue.
- **Blend:** with one hobby picked, each day shows just that hobby's colour (in effect a single-hobby intensity); the legend shows only that hobby.
- **Media:** only days where the chosen hobby has a photo or video count as *Photo or video*; days with only that hobby's time are *Time only*.
- **Month totals**, the day sheet and VoiceOver day labels follow the filter ("20 September, Tennis, 45m in 1 session"). The day sheet could offer *Show all hobbies* to see the full day.
- **Stays picked** while moving between months and switching modes; resets to *All hobbies* on app launch (or remember it per device; decide).
- Built in the PACE-7 iOS style: 44 pt targets, VoiceOver label on the picker ("Showing Tennis").

**Notes:**

- Filter on the existing visible-sessions view (which already hides trashed sessions, PACE-12), so no data model or sync change is needed.
- Overlaps with PACE-8 (per-hobby progress in Milestones); this is the calendar view of the same question.

**Shipped:**

- **Hobby chips** in the Diary's pinned header, between the Intensity / Blend / Media switch and the weekday letters, scrolling sideways: *All hobbies*, then the active hobbies, then archived hobbies that have sessions. A picked chip fills with the hobby's colour (*All hobbies* in blue).
- **Tap the picked hobby again** to go back to *All hobbies*. A hobby deleted while picked also falls back to *All hobbies*.
- **Intensity** shades days in the picked hobby's colour, legend included. **Blend** shows only that hobby's colour, and each month's legend lists only that hobby. **Media** counts only that hobby's photos and videos.
- **Every month in the scroll (PACE-14)** follows the filter: days without the hobby look empty and can't be tapped, and each month's total ("7h 45m on 10 days") counts only that hobby, so scrolling up shows how it grew. VoiceOver day labels name the hobby ("20 September, Tennis, 45m").
- **Day sheet** lists only the picked hobby's sessions, with the hobby in the subtitle. When the day has other sessions it shows "1 other session that day · **Show all hobbies**", which shows the whole day.
- **Stays picked** while scrolling and changing mode. It is not saved, so each launch opens on *All hobbies* (decision on the open point above).
- No data model, sync or README change. Mockup: https://claude.ai/artifact/6zUMGHAvPZ4NdGwTc9MFAY

## PACE-14 · Diary: scroll up through history, jump back to today

**Type:** Improvement · **Tag:** improvement · **Priority:** Medium · **Status:** Done

**Problem:** the Diary showed one month at a time. Looking back meant tapping ‹ or swiping sideways once per month, so revisiting history was slow and easy to skip.

**Shipped:**

- **One scroll.** The Diary is a vertical list of months, oldest at the top and this month at the bottom. It opens on this month; scrolling up reads back through earlier months. The month arrows and the sideways swipe are gone (replacing PACE-7 item 3's arrows and swipe).
- **Loads as you go.** Six months render at first; six more load before the top is reached, without the view jumping. It stops at the first month with a session (never fewer than three months) and says "Your diary starts in …".
- **Each month** has its own total ("12h 30m on 8 days"), and in Blend its own hobby legend. The Intensity and Media legends show once, under this month.
- **Pinned header.** The Intensity / Blend / Media switch and the weekday letters stay at the top while months scroll under them.
- **Back to today.** A floating **↓ Today** button appears once this month scrolls out of view and scrolls back to it. Tapping the Diary tab while already in it does the same.
- Switching tabs now starts other tabs at the top, so the long diary scroll does not carry over.

## PACE-13 · Emojis for hobbies, not just colour dots

**Type:** Improvement · **Tag:** improvement · **Priority:** Low · **Status:** Done

**Want:** give a hobby a cute emoji instead of only a colour dot.

**Scope:**

- **Pick one** from a row of 32 preset emojis, or type any emoji from the keyboard. Available when adding a hobby (Timer and You) and under *You → Edit*. The dot button goes back to the plain colour dot.
- **Where it shows:** the emoji sits on a soft circle of the hobby's colour in *Your hobbies*, *Archived*, *Logged today*, *Split by hobby* and the Blend legend, and in front of the name in the hobby pickers, the day sheet, the viewer title and the wrap-up.
- **Colour stays.** Calendar cells, stats bars and tiles still use the colour, so every hobby keeps one.
- **Sync:** new `hobbies.emoji` column (see README *Upgrading*).

## PACE-12 · Recently deleted: recover sessions, photos and videos for 30 days

**Type:** Improvement · **Tag:** improvement · **Priority:** Medium · **Status:** Done

**Problem:** nothing deleted can be recovered from the app.

- **Deleting a session** saves a marker that blanks the row: hobby, length and note are wiped. Only its photos and videos stay in the bucket, and nothing in the app points to them any more.
- **Removing a photo or video in an edit** (PACE-11) drops it from the session. The file stays in the bucket, but can only be found by hand in the Supabase dashboard (Storage → `pace-photos` → user id → session id).
- **No database backups** on Supabase's free plan (daily backups start on Pro), and *Download a copy* holds only the diary text and the small thumbnails still on that phone: no videos or full-size photos.

So a user who deletes the wrong thing, or saves a wrong edit, cannot get it back. Leftover files also use storage space (videos up to 50 MB; the free plan has 1 GB) and linger after a user expects them to be gone.

**Want:** a **Recently deleted** area, like iPhone Photos.

**Scope:**

- **Soft delete.** Deleting a session, or removing a photo or video in an edit, moves it to *Settings → Recently deleted* instead of erasing it. The session keeps its hobby, length, time, rating, tags, note and file paths.
- **Recently deleted list.** Each item shows what it was (hobby, day, length, thumbnail), when it was deleted and the days left, with **Restore** and **Delete now**, plus **Delete all**. Restoring puts a session back on its day, or a photo/video back on its session (or on its own, if the session is gone too).
- **Purge after 30 days.** After 30 days, or on *Delete now*, the item and its files are deleted for good: the row becomes a tombstone as today, and the bucket files are removed. That brings the privacy and storage benefits without accidental loss.
- **Undo toast.** After *Delete* or after saving an edit, the toast offers **Undo** for a few seconds, to catch most mistakes straight away.
- **Clear all data** stays immediate and permanent (it already deletes the files), and says so.
- Built in the PACE-7 iOS style: inset list, 44 pt targets, VoiceOver labels ("Tennis, 29 Sep, 45 minutes, deleted 3 days ago, 27 days left").

**Decisions and notes:**

1. **Data model.** Add a `deleted_at timestamptz` (null = live) to `sessions` instead of blanking the row, and keep removed media per session (e.g. a `trashed_media` list of `{ path, removed_at }`), or a small `trash` table. Needs an idempotent migration in `supabase-schema.sql` and a README upgrade note, like the hobby archive column.
2. **Sync.** A trashed session must not appear in the Diary, Stats or totals on any device, and restore must win over an older trash (last write wins by `updated_at`, as today). The existing `deleted` tombstone stays for the final purge, so older copies of the app still treat purged rows as gone.
3. **Who purges.** The app can purge on sync when it finds items older than 30 days. That only happens when a device opens; a scheduled Supabase job (pg_cron, or an Edge Function on a schedule) would purge even if nobody opens the app. Decide whether that is needed.
4. **Storage deletes.** `supabase-schema.sql` already lets each user delete files in their own folder ("own photos delete"), so no policy change is needed. A file whose delete fails is retried on the next sync, not forgotten.
5. **Offline.** Trashing and restoring work offline and sync later; *Delete now* removes the files once online.
6. **Older app copies.** A device still on an older version would show trashed sessions as live until updated. Acceptable for a personal app, but note it in the README.

**Shipped:**

- **Delete** in the Diary moves a session to Recently deleted in one tap (no second tap to confirm), with **Undo** in the toast for 6 seconds. Saving an edit also offers **Undo**, which puts the session back exactly as it was, on its old day.
- **Settings → Recently deleted** shows a count; its sheet lists sessions and photos/videos, newest first, with the day, length, "Deleted 3 days ago · 27 days left", **Restore**, **Delete now** (tap twice) and **Delete all** (tap twice).
- Photos/videos are listed only for sessions that are not themselves deleted; a deleted session keeps its removed media and erases it with the session. A restored photo goes back at the end of its session.
- **Data:** `sessions.trashed_at` and `sessions.trashed_media` (migration in `supabase-schema.sql`, README upgrade note). On the phone, trashed sessions stay in `store.sessions` with `trashedAt`, and one filtered view hides them from the Diary, Stats and Timer.
- **Purge** runs when the app opens and before each sync; bucket deletes wait in a queue on the phone and are retried until they succeed. A photo removed before it was ever uploaded stays on that phone only.
- **Who purges (decision 3):** the app only, when a device opens. No scheduled Supabase job; items can outlive 30 days if no device opens the app, which is fine for a personal diary.

## PACE-11 · Edit a logged session from Diary and Timer

**Type:** Improvement · **Tag:** improvement · **Priority:** Medium · **Status:** Done

**Problem:** once a session is logged it can only be deleted, not changed. If you pick the wrong hobby, make a typo in the note, or want to change the rating, the only fix is to delete the session and log it again as a past session.

**Want:** an **Edit** button on a logged session, in two places:

- **Diary:** in a session's expanded view (the day's bottom sheet, after tapping *Expand*), next to Delete.
- **Timer:** tapping a session in the **Logged today** list opens it, with an Edit button.

**Scope:**

- Edit opens the same bottom sheet as "Log a past session", filled in with the session's values: hobby, date, start time, length, rating (1–5), note, tags, and photos/videos (add or remove).
- **Save** updates the session in place (same id, not a delete plus a new one); **Cancel**, drag down, tap outside or Esc discards the changes.
- Totals update right away everywhere the session counts: Logged today, the Diary calendar and day sheet, the month total, and Stats / Milestones.
- Follows the PACE-7 iOS style: grabber, 44 pt targets, VoiceOver labels ("Edit Guitar session, 45 minutes, 14:00").

**Notes:**

- **Sync:** an edit bumps the session's updated time so last write wins across devices; editing must not bring back a session deleted on another device (respect tombstones). Works offline and syncs later like a new session.
- **Validation:** same rules as logging a past session (length above zero, not in the future). Changing the date moves the session to that day in the Diary.
- **Live session:** a session still running in the Timer is not editable here; only logged sessions are.

**Shipped:**

- **Timer:** each row under *Logged today* is a button (name, length, start time, *Edit*) that opens the editor.
- **Diary:** *Edit* sits between *Expand / Read note* and *Delete* in the day sheet, and next to *Done* in the expanded photo/note view.
- **Edit session sheet:** hobby (active hobbies, plus the session's own if archived), day, start hour, hours/minutes steppers, rating 1–5 (tap the selected number again to clear), tags, note, and photos/videos (tap to remove, + to add). Save, or Cancel / drag down / tap outside / Esc to throw the draft away.
- **Sync:** sessions are matched by id on any day, so a move is not a duplicate; a session deleted on another device is remembered as a tombstone and stays deleted; photo bytes and paths are matched by picture or path, not by position; a new upload never reuses a file name a kept photo already has.
- Removed photos/videos go to Recently deleted (PACE-12).

## PACE-10 · Dark mode: status bar stays white

**Type:** Improvement · **Status:** Done ([#20](https://github.com/SarahTTAN107/pace/pull/20))

**Problem:** with the app theme set to Dark, the iPhone status-bar strip at the top stayed light, because its colour came from a fixed `theme-color` of `#f0f3f8`.

**Done:** the `theme-color` and page background now follow the theme (`#0a0e17` in Dark, `#f0f3f8` in Light). They update as soon as the theme is switched or synced, and are set from the saved theme before the app renders, so a dark launch shows no white strip.

## PACE-9 · Settings: rename "Default heatmap" to "Default Diary Mode"

**Type:** Improvement · **Status:** Done ([#19](https://github.com/SarahTTAN107/pace/pull/19))

**Problem:** the Settings row that picks how the diary colours each day (Intensity / Blend / Media) was labelled *Default heatmap*, which does not match the Diary's own mode names.

**Done:** the label now reads *Default Diary Mode*. The caption and options are unchanged.

## PACE-7 · Apple design for the whole app (look and behaviour)

**Type:** Improvement · **Tag:** improvement · **Status:** Done for steps 1–3 ([#13](https://github.com/SarahTTAN107/pace/pull/13) and later). Step 4 replaced by PACE-8; steps 5 and 6 moved to PACE-20 and PACE-21.

**Problem:** the UI feels boxy. Borders and lines are too thick and bold, and the orange-and-grey palette clashes with the Water-element colours below.

**Scope:** the whole app, both how it looks and how it behaves, following Apple's Human Interface Guidelines.

- **Look:** hairline separators (0.5–1 px) or none; iOS-style grouped, rounded inset sections with fewer boxes inside boxes; SF Pro / `-apple-system` with the iOS text sizes (regular body, semibold titles, fewer uppercase labels); pill buttons, filled primary and tinted secondary.
- **Behaviour:** iOS-style tab bar at the bottom (with icons); sheets (pop-up panels) and swipe gestures; tap targets of at least 44 pt; native-feeling segmented control for Clock in / Countdown; subtle motion and haptics-style feedback; accessibility (contrast, Dynamic Type, VoiceOver labels, reduced motion); dark mode.

**Colours: feng shui palette for the Water element (mệnh Thủy — Giản Hạ Thủy, "water in the stream").** Replaces the orange and grey everywhere.

- **Main (Thủy, bản mệnh):** black, navy, deep blue, ocean blue.
- **Supporting (Kim sinh Thủy, Metal feeds Water):** white, silver, light grey.
- **Sparingly (Thủy sinh Mộc, Water feeds Wood):** green, as a small accent.
- **Avoid (Thổ khắc Thủy, Earth blocks Water):** yellow, brown, beige, earth tones. Red, orange and pink kept to a minimum.

**Plan, one step at a time:**

1. [x] **Colours.** Light: silver background `#f0f3f8`, navy text `#0b1d36`, ocean-blue accent `#0a5fd1`. Dark: near-black navy `#0a0e17`, silver text `#f0f3f8`, blue accent `#3a86f0`. The intensity heatmap is blue; hobby colour choices list blues, navy and silver first and warm colours last (values unchanged, so saved hobbies keep their colour; new hobbies default to blue). Red appears only on destructive actions (Delete, Clear all data, Sign out confirm). The amber "changes waiting" sync dot stays as a status colour. Home Screen icons, manifest and loading screen follow.
   - [x] **"Time only" legend fix** (Diary → Media): the photo swatch was an empty box, identical to a day with nothing logged. The legend now reads *Photo or video* (filled swatch), *Time only* and *Nothing logged*.
2. [x] **Timer:** Apple system font and iOS text sizes, sentence-case labels; white grouped cards with hairline separators; segmented control for Clock in / Countdown and for the 1–5 rating; filled, tinted and grey pill buttons; thin goal progress bar.
   - "Log a past session" and "Session complete" are bottom sheets with a grabber. Drag the header down, tap outside or press Esc to close. For a past session that keeps the draft (Cancel throws it away); for a finished session it leaves the session paused, so *Resume* or *Stop and log* picks it up again.
   - Every control is at least 44 pt; press feedback shrinks buttons slightly (off under Reduce Motion). Steppers, swatches, media tiles and toggles have VoiceOver labels and pressed states; the clock is a timer region and the goal bar a progress bar.
   - The header and tab bar are unchanged until step 6.
3. [x] **Diary:** large month title with grey round arrows; segmented control for Intensity / Blend / Media; the calendar sits in a white card with rounded day tiles and no outlines, today marked by a blue ring; sentence-case legend; "This month" total in its own card.
   - Media view: days with time but no photo are a soft blue (was grey, which read as a failed day), in the calendar and the *Time only* legend swatch.
   - Swipe the calendar sideways to change month (the arrows still work; Next is dimmed on the current month).
   - A day's sessions open in a bottom sheet like the Timer's: grabber, Done, drag down, tap outside or Esc to close. Rows show the thumbnail, name, length and time, the note, and tags as grey capsules; Expand / Read note in blue, Delete in red with a second tap to confirm.
   - The full-screen photo viewer uses the same type, a blue Done and Download, and closes with a downward swipe as well as Esc.
   - Day tiles are real buttons with VoiceOver labels ("20 September, 1h 15m in 2 sessions, with photos"); every control is at least 44 pt.
4. [ ] ~~**Stats:** grouped cards, iOS type scale.~~ **Paused:** the Stats tab is being replaced by the Milestones tab (PACE-8), which will be built in this style from the start.
5. [ ] ~~**Settings and sign-in:** iOS Settings-style inset lists.~~ **Moved** to PACE-20.
6. [ ] ~~**App-wide behaviour:** iOS tab bar with icons, 44 pt targets, motion (respecting reduced motion) and accessibility pass.~~ **Moved** to PACE-21.

## PACE-5 · Timer: Clock in and Countdown run independently

**Type:** Bug · **Status:** Done ([#12](https://github.com/SarahTTAN107/pace/pull/12))

**Problem:** starting *Clock in* also started the *Countdown goal*, because the two modes shared one live session. (Listed as item 1 of the 27 Sep 2026 feedback round.)

**Done:** one live session at a time (the simpler of the two options considered). It belongs to the mode that started it, and the other tab stays idle instead of mirroring it, so starting one mode never starts, pauses or resets the other. The goal chips and the *% of goal* bar show only in Countdown.
