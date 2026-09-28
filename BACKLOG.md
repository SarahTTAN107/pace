# Pace — backlog

One list for all open work. When an item ships, move it to **Done** with the PR that closed it.

**Priority:** **P1** blocks you or a tester · **P2** core feature is wrong or missing · **P3** polish.

_Last reviewed 2026-09-28._

## Order of work

| # | ID | Pri | Area | Item | Status | Size |
|---|----|-----|------|------|--------|------|
| 1 | PACE-1 | P1 | Deploy | Testers in a private window land on a Vercel login page | Open: settings change + README note | S |
| 2 | PACE-2 | P1 | Auth | Invited testers can't sign in | Fix ready in PR #9, needs merge + SQL run | S |
| 3 | PACE-5 | P2 | Timer | Clock in and Countdown share one clock | Open | M |
| 4 | PACE-6 | P3 | Design | Water-element colour palette | Open | M |
| 5 | PACE-9 | P3 | Diary | "Time only" legend is a dull grey | Open, ship with PACE-6 | S |
| 6 | PACE-7 | P3 | Design | Lighter, Apple-style UI | Open, after PACE-6 | L |
| 7 | PACE-8 | P2 | Stats | Progress against a benchmark per hobby | **Needs your decision** on targets | L |

**Why this order**
- **1–2 first:** they stop friends from getting into the app at all. Both are quick.
- **3 next:** a real bug in the main screen, small and self-contained.
- **4–6 together:** one visual refresh. Colours come first because they are design tokens every screen uses. The legend fix is a few lines once the palette exists.
- **7 last, though it matters most:** Stats needs a new screen. Building it after the refresh means it's built once, in the new style. If you'd rather have Stats sooner, it can move to #4. Either way, pick a target model (below) so it isn't blocked.

---

## P1 — unblock testers

### PACE-1 · Private-window visitors see a Vercel login page

A friend opening the app in a private window gets Vercel's "Log in" page. This comes from Vercel's **Deployment Protection**, not Pace's code. It protects preview and per-deployment URLs (`pace-git-<branch>-….vercel.app`, `pace-<hash>-….vercel.app`). Your normal browser is signed in to Vercel, so you never see it.

**Fix**
1. Share the **production** URL (Vercel → Project → Domains), not a link copied from a deployment.
2. Make sure the build you want tested is promoted to Production.
3. Only if testers need preview builds: Settings → Deployment Protection → turn Vercel Authentication off (safe, since RLS protects the data), or send a Shareable Link.
4. Add any new URL to Supabase → Authentication → URL Configuration.
5. README "Install on your iPhone": add a line saying to share the production domain.

**Done when:** the shared link opens Pace's sign-in screen in a fresh private window on iPhone Safari.

### PACE-2 · Invited testers can't sign in

"Send invitation" in Supabase creates an unconfirmed user, so the sign-in code fails with *"There is no Pace account for that address."*

**Fix:** [PR #9](https://github.com/SarahTTAN107/pace/pull/9) adds a trigger that confirms invited accounts, plus a one-time SQL fix for testers already stuck. **To do:** merge it, then run the upgrade SQL from the README in Supabase.
**Workaround until then:** Authentication → Users → Add user → Create new user, with *Auto Confirm User* ticked.
**Nice to have:** change the error to "Pace is invite-only — ask the owner to add your email."

---

## P2 — core features

### PACE-5 · Timer: Clock in and Countdown must work separately

**Today:** there is a single running clock. The *Clock in / Countdown goal* switch only changes how that clock is shown (counting up vs. counting down from the goal), and you can flip it mid-session. So starting one looks like starting both, and switching modes jumps the display.

**Want:** two independent modes. Starting, pausing or resetting one never touches the other.

**Approach:**
- Save the mode on the live session when it starts. While a session runs, lock the switch or show only that session's mode.
- Show the goal chips (25 / 45 / 60 m) and the "% of goal" bar only in Countdown.
- Optional: when a countdown reaches zero, give a soft alert and offer "keep going" (continues as overtime) or "wrap up".

**Decision:** one session at a time (recommended; a session is one block of practice) or both at once? The backlog assumes one at a time.

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

## P3 — visual refresh (PACE-6 → PACE-9 → PACE-7)

### PACE-6 · Colour palette: Water element (mệnh Thủy, Giản Hạ Thủy)

| Role | Colours | Why |
|---|---|---|
| Main | navy, deep blue, ocean blue, black | Thủy, your own element |
| Supporting | white, silver, light grey | Kim sinh Thủy: Metal feeds Water |
| Small accents only | green | Thủy sinh Mộc: Water feeds Wood |
| Avoid | yellow, brown, beige, earth tones; little red/orange/pink | Thổ khắc Thủy: Earth blocks Water |

**Direction:** light-silver or white background, navy text, a deep-to-ocean blue accent for the timer, progress and heatmap, silver hairlines. In dark mode: near-black background with a brighter blue accent.
**Work:** move colours into shared tokens (they're currently inline per screen), define light and dark sets, and check text contrast.

### PACE-9 · Diary: redesign the "Time only" legend (Media heatmap)

**Today:** the Media heatmap legend shows "Has a photo" as an empty outlined square and "Time only" as a 10% grey fill. The grey looks dull, and the two squares are hard to tell apart.

**Want:**
- "Time only": a soft light blue from PACE-6.
- "Has a photo": clearly stronger, either deep blue or a small camera mark.
- Legend squares that match the heatmap cells exactly, readable in light and dark mode.
- Optional: clearer labels, e.g. "With media" / "Time logged".

### PACE-7 · UI: Apple design principles

**Today:** it feels boxy, with lines and borders too thick and bold (2 px outlines, heavy fonts, lots of uppercase).

**Want (Apple's Human Interface Guidelines):**
- Hairline separators (0.5–1 px) or none. Group content with spacing and soft fills, not outlines.
- Rounded, grouped sections like iOS Settings, without boxes inside boxes.
- `-apple-system` / SF Pro: regular weight for body text, semibold for titles only, few uppercase labels.
- Filled pill for the main button, tinted pill for secondary buttons. A native-style segmented control for Clock in / Countdown.
- Generous whitespace, tap targets of at least 44 pt, subtle motion. Support dark mode and larger text.

**Work:** go screen by screen (Timer → Diary → Stats → Settings) so each PR stays reviewable.

---

## Done

| ID | Item | PR |
|----|------|----|
| PACE-3 | Removed the stale `pace-vercel 2/` copy of the app | #10 |
| PACE-4 | README deploy steps no longer point at a missing folder | #10 |
| — | Backlog started | #11 |
| — | "Log a past session": note field, photos & videos, centred layout | #4, #6, #7 |
| — | Diary heatmap "Photos" option renamed to "Media" | #5 |
| — | Startup race that skipped sign-in and sync | #3 |
| — | Photo sync and expired-JWT recovery; video support | #1, #2 |
