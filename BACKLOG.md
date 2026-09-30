# Pace — backlog

One list for all open work. When an item ships, move it to **Done** with the PR that closed it.

**Priority:** **P0** highest, do first · **P1** high · **P2** core feature is wrong or missing · **P3** polish.

_Last reviewed 2026-09-30._

## Order of work

| # | ID | Pri | Area | Item | Status | Size |
|---|----|-----|------|------|--------|------|
| 1 | PACE-7 | **P0** | Design | Align the whole app, all UX and UI, with Apple's design principles | Open | XL |
| 2 | PACE-10 | P1 | Brand | Simpler, Nordic-style logo | Open, alongside PACE-7 | S |
| 3 | PACE-1 | P1 | Deploy | Testers in a private window land on a Vercel login page | Open: settings change + README note | S |
| 4 | PACE-2 | P1 | Auth | Invited testers can't sign in | Fix ready in PR #9, needs merge + SQL run | S |
| 5 | PACE-12 | P2 | Timer | "Log a past session": pick From → To times instead of a length + hour slider | Open | M |
| 6 | PACE-11 | P2 | Timer | Edit a logged session (hobby, caption, photos, time) | Open, after PACE-12 | M |
| 7 | PACE-8 | P2 | Stats | Progress against a benchmark per hobby | **Needs your decision** on targets | L |

PACE-6 (Water palette) and PACE-9 ("Time only" legend) are now steps inside PACE-7.

**Why this order**
- **PACE-7 is the top priority.** Every screen and interaction gets redone to Apple's standards, starting with the colour palette, since every screen uses it.
- **PACE-10 goes with it:** the new logo should use the same palette and style, so both land together.
- **PACE-1 and PACE-2 are settings and merge jobs, not app code.** They take minutes and can happen any time, in parallel.
- **PACE-12 before PACE-11:** the edit screen reuses the past-session form, so the From → To picker gets built once and used in both. Build both as Apple-style sheets (PACE-7).
- **PACE-8 comes after the redesign,** so the new Stats screen is built once, in the new style. It still needs your target decision.

---

## P0 — highest priority

### PACE-7 · Align the app with Apple's design principles, for all UX and UI

**Today:** it feels boxy, with lines and borders too thick and bold (2 px outlines, heavy fonts, lots of uppercase). Layout and interactions don't feel native on iPhone.

**Want:** every screen, control and interaction follows Apple's Human Interface Guidelines: clarity, deference (content first, the interface stays quiet) and depth.

**UI (how it looks)**
- Hairline separators (0.5–1 px) or none. Group content with spacing and soft fills, not outlines.
- Rounded, grouped sections like iOS Settings, without boxes inside boxes.
- `-apple-system` / SF Pro with Apple's type scale: regular weight for body text, semibold for titles only, few uppercase labels. Support larger text sizes (Dynamic Type).
- Filled pill for the main button, tinted pill for secondary buttons. A native-style segmented control for Clock in / Countdown.
- Generous whitespace, SF Symbols-style line icons, full dark mode.

**UX (how it behaves)**
- Tab bar at the bottom with clear icons and labels. Large titles that shrink as you scroll.
- Tap targets of at least 44 pt, with main actions within thumb reach.
- Sheets and swipe gestures for secondary tasks (log a past session, edit, delete with swipe-to-delete), with confirmation only for destructive actions.
- Subtle, meaningful motion (respect Reduce Motion), clear feedback on every tap, helpful empty states, and plain-language errors.
- Accessibility: VoiceOver labels, enough contrast, no meaning shown by colour alone.

**Work:** start with a short style guide (tokens for colour, type, spacing, corner radius), then go screen by screen so each PR stays reviewable:

#### Step 1 · PACE-6 · Colour palette: Water element (mệnh Thủy, Giản Hạ Thủy)

| Role | Colours | Why |
|---|---|---|
| Main | navy, deep blue, ocean blue, black | Thủy, your own element |
| Supporting | white, silver, light grey | Kim sinh Thủy: Metal feeds Water |
| Small accents only | green | Thủy sinh Mộc: Water feeds Wood |
| Avoid | yellow, brown, beige, earth tones; little red/orange/pink | Thổ khắc Thủy: Earth blocks Water |

**Direction:** light-silver or white background, navy text, a deep-to-ocean blue accent for the timer, progress and heatmap, silver hairlines. In dark mode: near-black background with a brighter blue accent.
**Work:** move colours into shared tokens (they're currently inline per screen), define light and dark sets, and check text contrast.

#### Step 2 · Screens
Timer → Diary → Stats → Settings and sign-in, one PR each.

#### Step 3 · PACE-9 · Diary: redesign the "Time only" legend (Media heatmap, ships with the Diary PR)

**Today:** the Media heatmap legend shows "Has a photo" as an empty outlined square and "Time only" as a 10% grey fill. The grey looks dull, and the two squares are hard to tell apart.

**Want:**
- "Time only": a soft light blue from PACE-6.
- "Has a photo": clearly stronger, either deep blue or a small camera mark.
- Legend squares that match the heatmap cells exactly, readable in light and dark mode.
- Optional: clearer labels, e.g. "With media" / "Time logged".

**Done when:** every screen follows the style guide in light and dark mode, and nothing uses the old 2 px borders or heavy fonts.

---

## P1 — high

### PACE-10 · Logo: simpler, Nordic design

**Today:** the icon is a bright red square with a heavy white "P". It's loud, and red clashes with the Water palette (PACE-6).

**Want:** a calm, minimal, Scandinavian-style mark:
- One simple geometric shape with plenty of empty space, e.g. a thin ring (a clock or pace loop) with a small dot, or a light lowercase "p".
- Muted colours from the palette, e.g. a navy mark on off-white or silver, or white on deep blue. No gradients or shadows.
- Readable at small sizes: test at Home Screen size and in Settings.

**Work:** make it as SVG, then export `icon-180.png`, `icon-192.png` and `icon-512.png` (keep the mark inside the safe zone, since iOS rounds the corners). Update `theme_color` / `background_color` in `manifest.webmanifest` and the in-app "Pace" splash to match. Show 2–3 options to choose from before finalising.

### Testers

#### PACE-1 · Private-window visitors see a Vercel login page

A friend opening the app in a private window gets Vercel's "Log in" page. This comes from Vercel's **Deployment Protection**, not Pace's code. It protects preview and per-deployment URLs (`pace-git-<branch>-….vercel.app`, `pace-<hash>-….vercel.app`). Your normal browser is signed in to Vercel, so you never see it.

**Fix**
1. Share the **production** URL (Vercel → Project → Domains), not a link copied from a deployment.
2. Make sure the build you want tested is promoted to Production.
3. Only if testers need preview builds: Settings → Deployment Protection → turn Vercel Authentication off (safe, since RLS protects the data), or send a Shareable Link.
4. Add any new URL to Supabase → Authentication → URL Configuration.
5. README "Install on your iPhone": add a line saying to share the production domain.

**Done when:** the shared link opens Pace's sign-in screen in a fresh private window on iPhone Safari.

#### PACE-2 · Invited testers can't sign in

"Send invitation" in Supabase creates an unconfirmed user, so the sign-in code fails with *"There is no Pace account for that address."*

**Fix:** [PR #9](https://github.com/SarahTTAN107/pace/pull/9) adds a trigger that confirms invited accounts, plus a one-time SQL fix for testers already stuck. **To do:** merge it, then run the upgrade SQL from the README in Supabase.
**Workaround until then:** Authentication → Users → Add user → Create new user, with *Auto Confirm User* ticked.
**Nice to have:** change the error to "Pace is invite-only — ask the owner to add your email."

---

## P2 — core features

### PACE-12 · "Log a past session": From → To times

**Today:** you set the length with Hours / Minutes steppers (or 15m–90m chips), then drag a slider for "Started around", which only picks a whole hour (00:00–23:00). You can't say "14:20 to 15:05".

**Want:** two time pickers, **From** and **To** (native iOS time wheels, 5-minute steps), under the date. The length is worked out and shown ("45m"), not entered.

**Details:**
- Default: To = now rounded to 5 minutes, From = To minus 45m (or your last length for that hobby).
- If To is earlier than From, treat it as crossing midnight and show "ends next day", or block it. Suggest: allow it, and log the session on the From date.
- Remove the length steppers/chips and the hour slider. Optional: keep the chips as shortcuts that set From = To minus that length.
- Block zero-length or future sessions, with a plain message.

**Data:** sessions currently store `day_key`, `minutes` and a whole `hour`. Add a `start_min` column (minutes after midnight) in `supabase-schema.sql`, with an upgrade snippet in the README. Keep writing `hour` so older app versions still work. Timed sessions (Clock in / Countdown) should save their real start time too.

### PACE-11 · Timer: edit a logged session

**Today:** the Timer tab's "Logged today" list is read-only (colour, hobby, length). Once a session is saved, you can only delete it in the Diary, not fix a mistake.

**Want:** tap a session to open an **Edit session** sheet where you can change:
- **Hobby:** pick another hobby.
- **Caption:** the note.
- **Photos & videos:** add and remove, same grid as the past-session form.
- **Time logged:** date and From → To (PACE-12), or length for older sessions without a start time.

Plus **Save**, **Cancel**, and **Delete session** at the bottom (with confirmation).

**Details:**
- Reuse the past-session form in edit mode rather than building a second form.
- Show the same Edit action from the Diary's session view, so edits work for any day, not just today.
- Sync: stamp `updated_at` on save so other devices pick up the change. Removed photos should also be deleted from the `pace-photos` bucket and IndexedDB.
- If the session's photos are still uploading, keep them safe while editing.

### PACE-8 · Stats: progress against a benchmark per hobby

**Want:** Stats answers "how many hours have I put into this hobby, and how does that compare to a benchmark?"

**Needs your decision: how to set a target.** Options:

| Option | How it works | Good for | Downside |
|---|---|---|---|
| **A. Weekly hours** | e.g. 3 h/week. Shows this week vs. target and a streak of weeks met. | Steady habits | You pick a number up front |
| **B. Milestone total** | e.g. 100 h. Shows % done and a projected finish date at your pace. | Long-term skills | Slow to move day to day |
| **C. Sessions per week** | e.g. 4 sessions/week, any length. | Showing up matters most | Ignores time spent |
| **D. Automatic baseline** | No setup. Compares each hobby to your own last-4-weeks average. | Not sure of a target yet | Measures consistency, not ambition |

**Recommendation:** make **D** the default, so every hobby has a benchmark on day one. Then add an optional target per hobby, **A** or **B**, with a suggested number ("you average 2.5 h/week — set 3 h?"). You never have to decide up front.

**Per-hobby card:** hours this week / month / all time · a progress bar against the target (or baseline) · trend vs. last period · projected finish date for milestones.

**Data:** the target is a new per-hobby field that needs a Supabase column for sync. Baselines are computed from sessions, so they need nothing new.

---

## Done

| ID | Item | PR |
|----|------|----|
| PACE-5 | Clock in and Countdown goal run independently: a session belongs to the mode it started in | #12 |
| PACE-3 | Removed the stale `pace-vercel 2/` copy of the app | #10 |
| PACE-4 | README deploy steps no longer point at a missing folder | #10 |
| — | Backlog started | #11 |
| — | "Log a past session": note field, photos & videos, centred layout | #4, #6, #7 |
| — | Diary heatmap "Photos" option renamed to "Media" | #5 |
| — | Startup race that skipped sign-in and sync | #3 |
| — | Photo sync and expired-JWT recovery; video support | #1, #2 |
