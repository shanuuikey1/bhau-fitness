# BHAU FITNESS — Freelancer Deployment Brief

**For:** the developer being hired
**From:** Gaurav (project owner)
**Job type:** One-time deployment of an existing, already-built application to live hosting
**Important:** This is a deploy-and-configure job, **not** a build job. The application is finished. Do not quote me for "development," "rebuilding," or "rewriting." If you think a rewrite is needed, tell me *why* before doing anything, and wait for my approval.

---

## 1. What the project is

A finished full-stack app with three parts that all exist in the zip I'll give you:

| Part | Technology | Where it lives in the repo |
|---|---|---|
| Frontend | Flutter (web build) | `frontend/bhau_fitness_flutter/` |
| Backend API | ASP.NET Core 10 | `backend/BhauFitnessApi/` |
| Database | PostgreSQL (production) | schema in `backend/BhauFitnessApi/Migrations/` |

There is already a `render.yaml` and a `.netlify` folder in the project. Use them as the starting point.

---

## 2. The exact job (scope)

Deploy all three parts so the app is live on the public internet for **one gym**, and hand me back working URLs. Specifically:

1. **Database:** Set up a PostgreSQL database on **Supabase** (free tier). Give me the project, and configure the backend to use it.
2. **Backend:** Deploy `backend/BhauFitnessApi` to **Render** as a paid web service (the instance that does **not** sleep). Set all configuration via Render **environment variables** — see Section 4.
3. **Run the database migrations** against the Supabase database so all tables are created.
4. **Frontend:** Run `flutter build web`, deploy the output to **Netlify** (or Vercel), and point it at the live backend URL.
5. **Verify** the whole thing works end-to-end using the acceptance tests in Section 6, on a call with me watching.

That's the entire job. Nothing more is in scope unless I approve it in writing.

---

## 3. Security — non-negotiable, do these or the job is not accepted

1. **A real Google Gemini API key is currently sitting in plaintext** in `backend/BhauFitnessApi/appsettings.json`. I am rotating (deleting and regenerating) that key myself before I send you the project. **Never** put the new key back into `appsettings.json` or any committed file. It goes **only** into Render environment variables.
2. The same rule applies to the **JWT secret**, the **database connection string**, and any **Razorpay keys**. All secrets live in environment variables, never in code.
3. Before you finish, confirm to me that `appsettings.json` in the deployed version contains **no real secrets** — only placeholders.

If you are not comfortable following these rules, do not take this job.

---

## 4. Environment variables you must set on Render

(These are the names the app already expects. I'll provide the actual values.)

- `ConnectionStrings__DefaultConnection` → the Supabase PostgreSQL connection string
- `Jwt__Key` → a long random secret (you generate it, send it to me to store)
- `Jwt__Issuer` → `BhauFitnessApi`
- `Jwt__Audience` → `BhauFitnessFlutterApp`
- `Gemini__ApiKey` → the rotated key I provide
- `Razorpay__KeyId` and `Razorpay__KeySecret` → leave as `placeholder` for now (real payments are a later, separate job — do **not** wire live payments in this job)

---

## 5. What is explicitly OUT of scope (do not bill me for these)

- Building real Razorpay live payments (separate future job; needs the gym's KYC).
- Adding new features, screens, or "improvements."
- Multi-gym onboarding / multi-tenant signup flows.
- Redesigning the UI.
- Buying a custom domain (I'll handle that separately if I want one).

If any of these come up, stop and ask me first. Surprise work is not paid for.

---

## 6. Acceptance tests — how I will confirm the job is done

I am not a coder, so I verify by **using the app**, not by reading code. The job is complete only when **all** of these pass, on a screen-share call with me:

1. **Frontend loads:** You give me a public URL. I open it on my phone and on a laptop. The BHAU FITNESS landing page appears, styled correctly, no error screen.
2. **Login works:** Using the seeded demo accounts —
   - Admin: `admin@bhau.com` / `AdminPassword123`
   - Member: `member@bhau.com` / `MemberPassword123`
   — both log in successfully from the live URL (not from your laptop).
3. **Backend is awake:** Open `<backend-url>/api/health` in a browser. It returns a healthy status, **and** when I reopen the app 5 minutes later it loads instantly (proving the instance does **not** sleep).
4. **Database is real and persistent:** I create a test booking or log as the member, you restart the backend on Render, I log back in, and **the data is still there**.
5. **AI Coach responds:** As the member, I open the AI Coach and generate a workout plan. It returns a plan (either from Gemini or the fallback — either is fine, it must not crash).
6. **Admin sees data:** The admin login shows the member roster and analytics screens with data, not blank/error states.
7. **Secrets are clean:** You show me, on screen, that the live config has no real API keys in any committed file.

If any test fails, the job is not finished and final payment is not due.

---

## 7. Deliverables you hand me at the end

1. **Live frontend URL** (Netlify/Vercel).
2. **Live backend URL** (Render).
3. **Supabase project** access (added to my email, or credentials handed over).
4. **Render account/service** under my email, or access handed to me — I must own the hosting, not you.
5. A **short plain-language note** (half a page, no jargon) listing: where each piece is hosted, what the monthly cost is, and the exact steps to do this again for a second gym. This note is part of the deliverable — it's how I learn to do gym #2 myself.

**Ownership matters:** every account (Render, Supabase, Netlify) must be in **my** name/email. I should never be locked out of my own app because the developer holds the logins.

---

## 8. Payment terms (suggested — adjust to your agreement)

- This is a small, well-defined job. Expect a fixed price, not hourly.
- **Do not pay 100% upfront.** A common split: a small deposit, the rest only after all Section 6 acceptance tests pass on the verification call.
- The handover note (Section 7.5) and account ownership (Section 7) are conditions of final payment, not optional extras.

---

## 9. Red flags — tell Gaurav if the developer does any of these

- Asks to put the API key back in `appsettings.json` "to make it work."
- Says the whole thing needs to be "rebuilt" before giving a specific technical reason.
- Wants to keep the hosting accounts in their own name.
- Quotes for "development" when this is a deploy job.
- Can't make the backend stop sleeping (test #3) and calls it done anyway.
