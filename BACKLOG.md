# Pace — backlog

Open feedback and ideas, newest first. Move an item to a PR when work starts.

## Feedback round — 2026-09-27

### 1. Timer: Clock in and Countdown must run independently

**Problem:** starting *Clock in* also starts the *Countdown goal*. The two modes share one live session (`store.live`), so the countdown moves whenever the clock-in timer does.

**Want:** each mode works on its own. Starting one must not start, pause or reset the other.

**Notes:**
- Decide whether both can run at the same time (two live sessions) or only one at a time, with switching tabs leaving the other untouched. One at a time is simpler and matches "log one session".
- The goal chips (25 / 45 / 60 m) and the `% of goal` bar should show only in Countdown mode.

### 2. UI: follow Apple design principles

**Problem:** the current UI feels too boxy. Borders and lines are too thick and too bold.

**Want:** a lighter look in line with Apple's Human Interface Guidelines:
- Thin separators (hairline, 0.5–1 px) or no borders at all; group content with spacing and soft background fills instead of outlines.
- Grouped, rounded "inset list" sections as in iOS Settings, with larger corner radii and fewer boxes inside boxes.
- A clear type scale: SF Pro / `-apple-system`, regular weight for body text, semibold only for titles, fewer uppercase labels.
- Pill buttons with a filled primary and tinted secondary, instead of 2 px outlined chips.
- Plenty of whitespace, a 44 pt minimum tap target, native-feeling segmented control for Clock in / Countdown.
- Subtle motion and haptics-style feedback; respect dark mode and Dynamic Type.

### 3. Colours: feng shui palette for Water element (mệnh Thủy — Giản Hạ Thủy)

**Want:** re-theme the app in colours that suit the Water element (Giản Hạ Thủy, "water in the stream").

- **Main colours (Thủy, bản mệnh):** black, navy, deep blue, ocean blue.
- **Supporting colours (Kim sinh Thủy, Metal feeds Water):** white, silver, light grey.
- **Use sparingly:** green (Thủy sinh Mộc, Water feeds Wood; fine as a small accent).
- **Avoid:** yellow, brown, beige, earth tones (Thổ khắc Thủy, Earth blocks Water). Keep red, orange and pink to a minimum.

Suggested direction: white or light-silver background, navy text, a deep-to-ocean blue accent for the timer and progress, silver-grey hairlines. In dark mode, near-black background with blue accent. This fits well with item 2.

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
