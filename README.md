# 🎹 Pianus Studio — Orbital 2026

*By **Nguyen Khanh Duong** & **Dao Quang Linh***

A virtual piano you play with your computer keyboard — simulator, guided lessons,
scoring mode, pitch-recognition drills, recordings and a community forum.

* 🌐 **Live site:** [pianus-studio-orbital26.vercel.app](https://pianus-studio-orbital26.vercel.app/)
* 🎬 **Demo video:** [https://youtu.be/OEWCI49M6Nc](https://www.youtube.com/watch?v=Nk4Y8JQCDDc)

---

## Table of contents

1. [Tech stack](#tech-stack)
2. [Prerequisites](#prerequisites)
3. [Project structure](#project-structure)
4. [Quick start](#quick-start)
5. [Backend setup](#backend-setup-fastapi--port-8000)
6. [Frontend setup](#frontend-setup-vite--react--port-5173)
7. [Environment variables](#environment-variables)
8. [Supabase setup](#supabase-setup)
9. [Running tests](#running-tests)
10. [Troubleshooting](#troubleshooting)
11. [API reference](#api-reference)
12. [Deployment](#deployment)

---

## Tech stack

| Layer | Technology |
| :-- | :-- |
| Frontend | Vite 8, React 19, React Router 7, Tone.js |
| Backend | FastAPI, Uvicorn, Pydantic |
| Database & Auth | Supabase (PostgreSQL, Auth, Storage) |
| Testing | Vitest, React Testing Library, jsdom |
| Hosting | Vercel (frontend), Render (backend) |

---

## Prerequisites

| Tool | Version | Check with |
| :-- | :-- | :-- |
| **Node.js** | 20.19+ or 22.12+ (CI uses 24) | `node --version` |
| **npm** | 10+ | `npm --version` |
| **Python** | **3.10 or newer** | `python --version` |
| **Git** | any recent | `git --version` |

> **Python 3.10 is a hard minimum.** `backend/schemas.py` uses the `str | None`
> union syntax, which is a syntax error on 3.9 and below.

You will also need a **Supabase project** — see [Supabase setup](#supabase-setup).

---

## Project structure

```
PianusStudio-Orbital26/
├── .github/workflows/
│   └── vitest.yml               # CI: runs the frontend test suite on push/PR
│
├── backend/                     # FastAPI service → http://localhost:8000
│   ├── main.py                  # All 22 API routes + CORS config
│   ├── database.py              # Supabase client (reads .env)
│   ├── schemas.py               # Pydantic request/response models
│   ├── requirements.txt
│   ├── render.yaml              # Render deployment config
│   ├── setup.sh                 # Reference commands (Windows paths — see note below)
│   └── .env                     # ← you create this (git-ignored)
│
└── frontend/                    # Vite + React app → http://localhost:5173
    ├── index.html               # Vite entry HTML
    ├── vite.config.js           # Vite + Vitest config
    ├── eslint.config.js
    ├── vercel.json              # SPA rewrite for client-side routing
    ├── package.json
    ├── public/                  # Static assets: backgrounds, piece art, piano decorations
    ├── src/
    │   ├── main.jsx             # React entry point
    │   ├── App.jsx              # Route table
    │   ├── index.css            # Global styles
    │   ├── App.css              # (unused Vite starter styles)
    │   ├── assets/
    │   ├── webpages/            # Route-level pages (HomePage, Scoring, Community, …)
    │   ├── components/          # Shared components, Supabase client, API helper
    │   │   └── Pieces/          # P1–P12: one module per piano piece
    │   ├── classes/             # Note, Piece, Piece_simplified, Record, AudioRecord
    │   │   └── __tests__/       # Vitest suites
    │   ├── hooks/               # usePiano, useKeyboard, useRequireAuth
    │   ├── styles/              # Per-page CSS
    │   └── test/setup.js        # Vitest setup
    └── .env                     # ← you create this (git-ignored)
```

**You need two terminals running at once** — one for the backend, one for the
frontend.

---

## Quick start

Already have your `.env` files and dependencies installed? Then it's just:

```bash
# Terminal 1 — backend
cd backend
source .venv/bin/activate        # Windows: .venv\Scripts\activate
uvicorn main:app --reload        # → http://localhost:8000

# Terminal 2 — frontend
cd frontend
npm run dev                      # → http://localhost:5173
```

First time through? Follow the two sections below.

---

## Backend setup (FastAPI → port 8000)

### 1. Create a virtual environment

From the **`backend/`** folder:

```bash
cd backend
python -m venv .venv
```

> If `python` isn't found, try `python3` (common on macOS/Linux).

### 2. Activate it

The activation path differs by platform — this is the single most common
stumbling block:

| Platform | Command |
| :-- | :-- |
| **macOS / Linux** | `source .venv/bin/activate` |
| **Windows — PowerShell** | `.venv\Scripts\Activate.ps1` |
| **Windows — CMD** | `.venv\Scripts\activate.bat` |
| **Windows — Git Bash** | `source .venv/Scripts/activate` |

You'll know it worked when your prompt is prefixed with `(.venv)`.

> **Note:** the existing `backend/setup.sh` hard-codes `.venv/Scripts/activate`,
> which is the **Windows** path. On macOS or Linux use `.venv/bin/activate`.

> **PowerShell blocking the script?** Run once, in that terminal:
> `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Create `backend/.env`

See [Environment variables](#environment-variables). **The server will not start
without it.**

### 5. Run the server

```bash
uvicorn main:app --reload
```

`--reload` restarts the server automatically whenever you edit a `.py` file.
Leave this terminal running.

You should see:

```
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
INFO:     Application startup complete.
```

**Verify it works:** open <http://localhost:8000/docs> for the interactive
Swagger UI. All 22 endpoints should be listed.

Want a different port? `uvicorn main:app --reload --port 8001` — but then you
must also update `VITE_API_URL` in the frontend **and** add the new origin to the
`origins` list in `main.py`.

### Leaving the venv

```bash
deactivate
```

---

## Frontend setup (Vite + React → port 5173)

### 1. Install dependencies

From the **`frontend/`** folder:

```bash
cd frontend
npm install
```

> Use plain `npm install`, not the individual `npm install tone react-router-dom …`
> lines in `frontend/setup.sh`. Everything is already declared in
> `package.json`, and installing packages one at a time can pull versions that
> don't match `package-lock.json`.
>
> For a clean, reproducible install that matches the lockfile exactly, use
> `npm ci`.

### 2. Create `frontend/.env`

See [Environment variables](#environment-variables).

### 3. Run the dev server

```bash
npm run dev
```

You should see:

```
  VITE v8.0.16  ready in 576 ms
  ➜  Local:   http://localhost:5173/
```

Open <http://localhost:5173>.

> **Port 5173 matters.** The backend's CORS policy in `main.py` only allows
> `http://localhost:5173`. If Vite falls back to 5174 because 5173 is occupied,
> every API call fails with a CORS error. Free the port, or run
> `npm run dev -- --port 5173 --strictPort` so Vite fails loudly instead of
> quietly switching.

### Other frontend commands

| Command | What it does |
| :-- | :-- |
| `npm run dev` | Dev server with hot reload |
| `npm run build` | Production build into `dist/` |
| `npm run preview` | Serve the built `dist/` locally |
| `npm run lint` | ESLint |
| `npm run test` | Vitest in watch mode |
| `npm run test:run` | Vitest once (what CI runs) |
| `npm run coverage` | Vitest with a coverage report |

---

## Environment variables

Both files are already listed in `.gitignore` — **never commit them.**

### `backend/.env`

Create a file at **`backend/.env`**:

```dotenv
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_SERVICE_KEY=your-service-role-key
```

| Variable | Where to find it |
| :-- | :-- |
| `SUPABASE_URL` | Supabase dashboard → **Project Settings → API → Project URL** |
| `SUPABASE_SERVICE_KEY` | Same page → **Project API keys → `service_role`** |

> ⚠️ **The `service_role` key bypasses all Row Level Security.** It must only
> ever live in the backend. Never put it in the frontend, never commit it, never
> paste it into a screenshot. If it leaks, rotate it immediately from the
> Supabase dashboard.

### `frontend/.env`

Create a file at **`frontend/.env`**:

```dotenv
VITE_SUPABASE_URL=https://your-project-ref.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-public-key
VITE_API_URL=http://localhost:8000
```

| Variable | Notes |
| :-- | :-- |
| `VITE_SUPABASE_URL` | Same URL as the backend's `SUPABASE_URL` |
| `VITE_SUPABASE_ANON_KEY` | The **`anon` / `public`** key — *not* `service_role` |
| `VITE_API_URL` | Your local backend. **No trailing slash** |

Two rules that catch people out:

1. **The `VITE_` prefix is mandatory.** Vite only exposes variables beginning
   with `VITE_` to browser code. A frontend variable named `SUPABASE_URL` will
   silently be `undefined`.
2. **Restart the dev server after editing `.env`.** Vite reads env files at
   startup only; hot reload will not pick up the change.

`VITE_API_URL` has no trailing slash because `API.jsx` builds request URLs by
string concatenation:

```js
fetch(`${import.meta.env.VITE_API_URL}${path}`)   // path already starts with "/"
```

A trailing slash would give you `http://localhost:8000//user`.

---

## Supabase setup

If you're joining the project and have been handed credentials for the existing
Supabase project, paste them into the two `.env` files and skip this section.
To stand up your own instance, you'll need the following.

### Tables

| Table | Purpose |
| :-- | :-- |
| `users_data` | Profile: `id`, `username`, `role`, `avatar_url`, `bio`, `binding_option`, `first_record`, `second_record`, `third_record`, `created_at` |
| `scoring_data` | Per-piece scores: `user_id`, `user_name`, `piece_number`, `current_score`, `top_score`, `changed_at` |
| `records` | Saved keyboard performances |
| `forum_posts` | Community posts: `title`, `description`, `record1`, `record2`, `title_record1`, `created_at` |
| `forum_comments` | Comments, keyed to a post |

`users_data.id` is a foreign key to Supabase's built-in `auth.users.id`.

### Storage

Create a **public** bucket named **`avatars`**. `POST /user/avatar` uploads to
`{user_id}/avatar.{ext}` and accepts `.jpg`, `.jpeg` and `.png` only.

### Auth

Enable **Email** sign-in under **Authentication → Providers**. For local
development, add `http://localhost:5173` under
**Authentication → URL Configuration → Redirect URLs**, or the password-reset
flow will redirect to production instead of your machine.

---

## Running tests

```bash
cd frontend
npm run test:run       # single run — what CI does
npm run test           # watch mode
npm run coverage       # with coverage
```

Current suite: **32 tests across 4 files**, covering the `Note`, `Piece`,
`Record` and `AudioRecord` classes. CI runs on every push and PR to `main` via
`.github/workflows/vitest.yml`.

The backend has `pytest` installed but no test files yet.

---

## Troubleshooting

### `SupabaseException: supabase_url is required`

The backend crashes the moment you start it. `backend/.env` is missing, is in the
wrong folder, or has a typo in a variable name.

Check the file is at `backend/.env` (**not** the repo root) and that both keys
are spelled exactly `SUPABASE_URL` and `SUPABASE_SERVICE_KEY`. Run `uvicorn` from
*inside* `backend/` — `load_dotenv()` looks in the current working directory.

### `ModuleNotFoundError: No module named 'fastapi'`

The venv isn't active, or dependencies aren't installed. Look for `(.venv)` in
your prompt; if it's missing, re-activate. Then `pip install -r requirements.txt`.

### CORS error in the browser console

Something like *"has been blocked by CORS policy"*. The frontend isn't on port
5173. Check what Vite actually printed — if it says 5174, port 5173 was already
taken. Free it, or add your real origin to `origins` in `main.py`.

### Frontend loads but every API call fails

Confirm the backend terminal is still running, and that `VITE_API_URL` is
`http://localhost:8000` with **no trailing slash**. Check the backend is alive at
<http://localhost:8000/docs>.

### `supabaseUrl is required` in the browser console

`frontend/.env` is missing, or its variables lack the `VITE_` prefix. Restart
`npm run dev` after fixing — Vite only reads `.env` at startup.

### `401 Unauthorized` from the API

Expected when signed out; protected routes need a Supabase session token. Sign in
through the UI. If it persists while logged in, your frontend and backend are
probably pointed at *different* Supabase projects — the project URL in both
`.env` files must match.

### Port already in use

```bash
# macOS / Linux
lsof -ti:8000 | xargs kill -9
lsof -ti:5173 | xargs kill -9
```

```powershell
# Windows (PowerShell)
netstat -ano | findstr :8000
taskkill /PID <pid> /F
```

### `npm install` fails or behaves oddly

```bash
cd frontend
rm -rf node_modules package-lock.json
npm install
```

### Note: the stray `packpage.json`

There's a misspelled `packpage.json` in the repo root. Nothing uses it — the real
manifest is `frontend/package.json`. Don't run `npm install` from the repo root.

---

## API reference

Base URL in development: `http://localhost:8000`
Interactive docs: <http://localhost:8000/docs>

Routes marked 🔒 require an `Authorization: Bearer <supabase-access-token>`
header, which `apiFetch()` in `src/components/API.jsx` attaches automatically.
The rest are public reads.

**Profile**

| | Method | Route | Purpose |
| :-- | :-- | :-- | :-- |
| 🔒 | `GET` | `/user` | Current user's profile |
| 🔒 | `PUT` | `/user` | Update username / bio / avatar URL |
| 🔒 | `POST` | `/user/avatar` | Upload avatar image (jpg/jpeg/png) |
| 🔒 | `GET` | `/user/binding-option` | Current keyboard binding preset |
| 🔒 | `PUT` | `/user/binding-option` | Change keyboard binding preset |
| | `GET` | `/profile/{username}` | Public profile by username |
| | `GET` | `/profile-by-id/{user_id}` | Public profile by user id |

**Scores & leaderboard**

| | Method | Route | Purpose |
| :-- | :-- | :-- | :-- |
| 🔒 | `GET` | `/user/scores` | All of the user's piece scores |
| 🔒 | `GET` | `/user/score/{pieceNumber}` | Score for one piece |
| 🔒 | `PUT` | `/user/score/{pieceNumber}` | Submit a score for a piece |
| | `GET` | `/leaderboard/{pieceNumber}` | Top 20 for a piece |

**Recordings**

| | Method | Route | Purpose |
| :-- | :-- | :-- | :-- |
| 🔒 | `POST` | `/record` | Save a recording |
| 🔒 | `GET` | `/records` | List the user's recordings |
| 🔒 | `GET` | `/record/{position}` | Fetch recording in slot 1–3 |
| 🔒 | `DELETE` | `/record/{position}` | Delete a recording slot |
| | `GET` | `/record-by-id/{record_id}` | Fetch a recording by id |

**Pitch-recognition exercises**

| | Method | Route | Purpose |
| :-- | :-- | :-- | :-- |
| 🔒 | `GET` | `/exercise` | Exercise scores |
| 🔒 | `PUT` | `/exercise/{id}` | Submit an exercise score |

**Community forum**

| | Method | Route | Purpose |
| :-- | :-- | :-- | :-- |
| 🔒 | `POST` | `/post` | Create a forum post |
| 🔒 | `POST` | `/post/comment` | Add a comment |
| | `GET` | `/posts` | List forum posts |
| | `GET` | `/comments/{post_id}` | Comments on a post |

---

## Deployment

| Part | Platform | Config |
| :-- | :-- | :-- |
| Frontend | Vercel | `frontend/vercel.json` — SPA rewrite so client-side routes resolve |
| Backend | Render | `backend/render.yaml` — `uvicorn main:app --host 0.0.0.0 --port $PORT` |

Set the same environment variables in each platform's dashboard. In production,
`VITE_API_URL` points at the deployed Render URL, and that frontend origin must
be present in the `origins` list in `main.py`.
