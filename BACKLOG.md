# Pace — backlog

One list for all open work. When an item ships, move it to **Done** with the PR that closed it.

**Priority:** **P0** highest, do first · **P1** high · **P2** core feature is wrong or missing · **P3** polish.

_Last reviewed 2026-09-29._

## Order of work

| # | ID | Pri | Area | Item | Status | Size |
|---|----|-----|------|------|--------|------|
| 1 | PACE-7 | **P0** | Design | Align the whole app, all UX and UI, with Apple's design principles | Open | XL |
| 2 | PACE-10 | P1 | Brand | Simpler, Nordic-style logo | Open, alongside PACE-7 | S |
| 3 | PACE-1 | P1 | Deploy | Testers in a private window land on a Vercel login page | Open: settings change + README note | S |
| 4 | PACE-2 | P1 | Auth | Invited testers can't sign in | Fix ready in PR #9, needs merge + SQL run | S |
| 5 | PACE-8 | P2 | Stats | Progress against a benchmark per hobby | **Needs your decision** on targets | L |

PACE-6 (Water palette) and PACE-9 ("Time only" legend) are now steps inside PACE-7.

**Why this order**
- **PACE-7 is the top priority.** Every screen and interaction gets redone to Apple's standards, starting with the colour palette, since every screen uses it.
- **PACE-10 goes with it:** the new logo should use the same palette and style, so both land together.
- **PACE-1 and PACE-2 are settings and merge jobs, not app code.** They take minutes and can happen any time, in parallel.
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
