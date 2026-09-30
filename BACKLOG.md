# Pace — backlog

Open feedback and ideas, newest first. Move an item to a PR when work starts.

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
   - Swipe the calendar sideways to change month (the arrows still work; Next is dimmed on the current month).
   - A day's sessions open in a bottom sheet like the Timer's: grabber, Done, drag down, tap outside or Esc to close. Rows show the thumbnail, name, length and time, the note, and tags as grey capsules; Expand / Read note in blue, Delete in red with a second tap to confirm.
   - The full-screen photo viewer uses the same type, a blue Done and Download, and closes with a downward swipe as well as Esc.
   - Day tiles are real buttons with VoiceOver labels ("20 September, 1h 15m in 2 sessions, with photos"); every control is at least 44 pt.
4. [ ] **Stats:** grouped cards, iOS type scale.
5. [ ] **Settings and sign-in:** iOS Settings-style inset lists.
6. [ ] **App-wide behaviour:** iOS tab bar with icons, 44 pt targets, motion (respecting reduced motion) and accessibility pass.

### 4. Stats: report progress against a benchmark per hobby

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
