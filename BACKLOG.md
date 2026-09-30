# Pace — backlog

Open feedback and ideas, newest first. Move an item to a PR when work starts.

## PACE-9 · Edit a logged session from Diary and Timer

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
- Removed photos/videos stay in the bucket, as they do when a whole session is deleted.

## PACE-8 · Milestones tab: replace Stats with AI-assisted milestones

**Type:** New feature · **Priority:** High · **Status:** Open (not started)

**Problem:** Stats shows totals and comparisons (this week vs last, weekly trend, split by hobby, time of day), but not *progress towards something*. It cannot answer "how far am I from my goal?" or celebrate reaching one.

**Want:** replace the **Stats** tab with a **Milestones** tab. You set milestones per hobby, the app reports progress towards them, and an AI assistant helps you choose milestones and explains your progress.

**Scope:**

- **Milestones per hobby**
  - Lifetime hour milestones, e.g. 100 h, 1,000 h, the 10,000-hour mark.
  - Optional shorter targets: weekly hours (e.g. 3 h/week) or sessions per week (see the options table in item 4 below).
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
- **Keep from Stats:** the useful parts (split by hobby, time of day), moved into Milestones or a per-hobby detail view, so nothing is lost.
- **Design:** built in the PACE-7 iOS style from the start (grouped cards, system font, 44 pt targets, VoiceOver summaries for every chart).

**Decisions needed before building:**

1. **AI provider and where it runs.** An AI API key must never ship in `index.html`. Calls need a small server-side function (e.g. a Supabase Edge Function) that holds the key and checks the signed-in user.
2. **Privacy.** Sending diary data (hobbies, times, notes) to an AI provider is a change from "your data stays in your own Supabase". It should be opt-in, say exactly what is sent, and work fully without AI (milestones and achievements must not depend on it). Notes and photos stay out unless you choose otherwise.
3. **Data model.** New synced data for milestones and earned achievements (a `milestones` table with RLS, or inside `prefs`), following the existing rules: last write wins, tombstones, and defaults never overwrite the cloud.
4. **CSP.** `vercel.json` `connect-src` only allows the Supabase project today; the AI call should go through Supabase so it stays that way.
5. **Offline.** Milestones and achievements work offline; AI features show as unavailable without a connection.

**Replaces:** PACE-7 step 4 (Stats redesign, paused) and item 4 below (Stats benchmark), whose options table is the starting point for targets.

## Feedback round — 2026-09-27

### 1. Timer: Clock in and Countdown must run independently

**Problem:** starting *Clock in* also starts the *Countdown goal*. The two modes share one live session (`store.live`), so the countdown moves whenever the clock-in timer does.

**Want:** each mode works on its own. Starting one must not start, pause or reset the other.

**Notes:**
- Decide whether both can run at the same time (two live sessions) or only one at a time, with switching tabs leaving the other untouched. One at a time is simpler and matches "log one session".
- The goal chips (25 / 45 / 60 m) and the `% of goal` bar should show only in Countdown mode.

### PACE-7. Apple design for the whole app (look and behaviour)

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
   - "Log a past session" and "Session complete" are bottom sheets with a grabber. Drag the header down, tap outside or press Esc to close. For a past session that keeps the draft (Cancel throws it away); for a finished session it leaves the session paused, so *Resume session* or *Stop and log* picks it up again.
   - Every control is at least 44 pt; press feedback shrinks buttons slightly (off under Reduce Motion). Steppers, swatches, media tiles and toggles have VoiceOver labels and pressed states; the clock is a timer region and the goal bar a progress bar.
   - The header and tab bar are unchanged until step 6.
3. [x] **Diary:** large month title with grey round arrows; segmented control for Intensity / Blend / Media; the calendar sits in a white card with rounded day tiles and no outlines, today marked by a blue ring; sentence-case legend; "This month" total in its own card.
   - Media view: days with time but no photo are a soft blue (was grey, which read as a failed day), in the calendar and the *Time only* legend swatch.
   - Swipe the calendar sideways to change month (the arrows still work; Next is dimmed on the current month).
   - A day's sessions open in a bottom sheet like the Timer's: grabber, Done, drag down, tap outside or Esc to close. Rows show the thumbnail, name, length and time, the note, and tags as grey capsules; Expand / Read note in blue, Delete in red with a second tap to confirm.
   - The full-screen photo viewer uses the same type, a blue Done and Download, and closes with a downward swipe as well as Esc.
   - Day tiles are real buttons with VoiceOver labels ("20 September, 1h 15m in 2 sessions, with photos"); every control is at least 44 pt.
4. [ ] ~~**Stats:** grouped cards, iOS type scale.~~ **Paused:** the Stats tab is being replaced by the Milestones tab (PACE-8), which will be built in this style from the start.
5. [ ] **Settings and sign-in:** iOS Settings-style inset lists.
6. [ ] **App-wide behaviour:** iOS tab bar with icons, 44 pt targets, motion (respecting reduced motion) and accessibility pass.

### 4. Stats: report progress against a benchmark per hobby

**Status:** folded into PACE-8 (Milestones tab). Kept here as input for choosing targets.

**Want:** the main job of Stats is to show progress, e.g. "how many hours have I put into this hobby, against a benchmark?"

**Open question:** how to set a target for each hobby. Options to think about:

| Option | How it works | Good for | Downside |
|---|---|---|---|
| **A. Weekly time budget** | Set e.g. 3 h/week per hobby. Stats shows this week's hours vs. budget and a streak of weeks met. | Steady habits (guitar, reading) | You have to pick a number up front |
| **B. Milestone total** | Set a long-term total, e.g. 100 h or 1,000 h. Stats shows lifetime hours, % done and a projected finish date at your current pace. | Skills you want to build over months or years | Slow to move, little day-to-day feedback |
| **C. Session frequency** | Set e.g. 4 sessions/week, regardless of length. | Hobbies where showing up matters more than duration | Ignores how much time you actually put in |
| **D. Automatic baseline (no target)** | The app benchmarks each hobby against your own last 4 weeks' average. Stats shows "this week vs. your usual" (up/down %). | Starting out, when you don't know your target yet | Measures consistency, not ambition |

**Recommendation:** ship **D** as the default so every hobby gets a benchmark with zero setup. Then add an optional per-hobby target where you pick **A (weekly hours)** or **B (milestone total)**, suggested from your baseline (e.g. "you average 2.5 h/week — set 3 h?"). Stats would show, per hobby:
- hours this week / month / all time,
- progress bar against the target (or baseline if none is set),
- trend vs. last period, and for milestones a projected finish date.
