# Pace — Backlog

Open work for the app, newest first within each priority. Move an item to **Done** with the commit or PR that closed it.

Priority: **P1** blocks users · **P2** real problem, has a workaround · **P3** cleanup / nice to have.

| ID | Priority | Area | Title | Status |
|----|----------|------|-------|--------|
| PACE-1 | P1 | Deploy / Vercel | Incognito visitors are sent to a Vercel login page | Open |
| PACE-2 | P2 | Auth / onboarding | Invited testers can't sign in until they are added in Supabase | Open |
| PACE-3 | P3 | Repo hygiene | Remove the stale `pace-vercel 2/` copy of the app | Open |
| PACE-4 | P3 | Docs | README deploy steps say `cd pace-vercel`, but the app is at the repo root | Open |

---

## PACE-1 · Incognito visitors are sent to a Vercel login page

**Priority:** P1 · **Area:** Deploy / Vercel · **Reported by:** a friend testing the app

### Symptom
Opening the app in an incognito/private window shows a Vercel "Log in" or "Sign up" page instead of Pace. A normal browser window may work, which makes it look intermittent.

### Cause
This comes from Vercel's **Deployment Protection** (Vercel Authentication), not from Pace's code. Nothing in `index.html`, `sw.js` or `vercel.json` sends people to vercel.com.

- By default ("Standard Protection"), Vercel puts a Vercel login in front of **preview deployments** and **deployment-specific URLs**. Only people signed in to Vercel as members of the project's team get through.
- The URL shared with the tester was almost certainly one of these protected URLs, for example:
  - `pace-git-<branch>-<team>.vercel.app` (branch preview)
  - `pace-<hash>-<team>.vercel.app` (a single deployment)

  rather than the production domain (`<project>.vercel.app` or a custom domain), which is public.
- It only looks incognito-specific because a normal window is often already signed in to Vercel (it is for the owner), so the check passes silently. Incognito has no Vercel cookie, so Vercel asks you to log in. Anyone without access to the Vercel team would be blocked in any window.

### Fix
1. **Share the production URL.** In Vercel, go to Project → **Domains** (or the Overview "Domains" list) and send testers `https://<project>.vercel.app` or your custom domain, not a URL copied from a specific deployment or the Deployments tab. Most likely this alone is enough.
2. Make sure the change you want tested is **promoted to Production** (merge to the production branch, or Deployments → ⋯ → *Promote to Production*). Otherwise the public URL serves an older build.
3. **Only if testers need preview builds:** either
   - Project → **Settings → Deployment Protection** → set Vercel Authentication to **Disabled**, or to *Only Production Deployments*. Everything behind it becomes public, which is fine for Pace because RLS is what protects the data. Or:
   - Keep protection on and create a **Shareable Link** for that deployment (the share button on the deployment page), which lets a tester through without a Vercel account.
4. After changing the URL, add it to **Supabase → Authentication → URL Configuration** (Site URL / Redirect URLs) if it's new.

### Acceptance
- The shared URL opens Pace (the email sign-in screen) in a fresh incognito window on iPhone Safari and desktop Chrome, with no Vercel page.
- README's "Install on your iPhone" section says to share the production domain, not a deployment URL.

---

## PACE-2 · Invited testers can't sign in until they are added in Supabase

**Priority:** P2 · **Area:** Auth / onboarding

Once PACE-1 is fixed, a tester will reach the sign-in screen. Because `allowSignup: false` (invite-only), entering an address that isn't in Supabase shows *"There is no Pace account for that address."*

**Fix:** before sharing the link, go to Supabase → Authentication → Users → **Add user**, enter their email and tick *Auto Confirm User* (README §1 step 3). Or they can tap *Use on this device without signing in* to try the app locally.

**Possible improvement:** make that message say "Pace is invite-only — ask the owner to add your email", so testers know what to do next.

---

## PACE-3 · Remove the stale `pace-vercel 2/` copy of the app

**Priority:** P3 · **Area:** Repo hygiene

`pace-vercel 2/` is an older copy of the app, left from an upload (its `index.html` is ~350 KB against ~425 KB at the root, and its `vercel.json` and `sw.js` are older). If the project is dragged or deployed from the wrong folder, an outdated build goes live. Delete the folder once you've confirmed nothing depends on it.

---

## PACE-4 · README deploy steps point at a folder that doesn't exist

**Priority:** P3 · **Area:** Docs

README §2 "Deploy → CLI" says `cd pace-vercel`, but the app files are at the repo root. Change it to run `vercel --prod` from the repo root. Also add a note to share the production domain (see PACE-1).

---

## Done

_Nothing yet._
