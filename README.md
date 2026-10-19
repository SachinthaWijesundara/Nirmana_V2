<p align="center">
  <img src="assets/banner.svg" alt="Nirmana: know what your money has actually built" width="100%">
</p>

<p align="center">
  <a href="https://github.com/SachinthaWijesundara/Nirmana_V2/actions/workflows/ci.yml"><img src="https://github.com/SachinthaWijesundara/Nirmana_V2/actions/workflows/ci.yml/badge.svg" alt="CI status"></a>
  <img src="https://img.shields.io/badge/built%20with-Jac-1d5c63" alt="Built with Jac">
  <img src="https://img.shields.io/badge/status-hackathon%20prototype-f4b942" alt="Hackathon prototype">
</p>

**Nirmana** (working name *GedaraTwin*) helps people who are building a home in Sri Lanka while living abroad. It keeps a living model of the house, reads the builder's everyday messages, and protects both sides: the owner from paying for work that isn't there, and the builder from unfair blame for delays.

It is a website where the **client** (the home owner), the **contractor** (the builder) and the **architect** each have their own account and work on the same project, every action written to a record nobody can edit.

---

## The problem

Imagine Nimal, working in Qatar, building a house in Kurunegala. His builder says the slab is done and asks for another Rs. 800,000. Nimal can't visit. He has WhatsApp messages and a feeling something is off.

- **Owners abroad** can't tell if the money they've sent matches the work on site.
- **Builders** get blamed for delays caused by rain, late materials or an earlier stage, with nothing on record to show it.

## What Nirmana does

| Helper | What it does for you |
|---|---|
| **Intake** | Reads the builder's message as they'd naturally write it, in **English, Sinhala, Tamil or Singlish**, such as *"slab eka iwarai, cement 40k gaththa"*. It works out which part of the house it's about and records progress, materials and money spent. |
| **Payment Guard** | Compares **money paid** with **work actually verified**. If a payment request runs ahead of the proven work, it holds the payment. When proof arrives, it releases the part that's now covered. |
| **Photo proof** | The builder (or architect) sends a photo of the finished work. AI looks at it and decides whether it really shows that part of the house and how complete it is. A clear match counts as proof, and Payment Guard releases the money it covers. A wrong or unfinished photo is turned down, with the reason. |
| **Delay Detector** | Spots parts of the build that are behind schedule and traces the delay back to its real cause (for example, Walls are late because the Slab was late). It writes a dated notice with the evidence, a fair record for the builder. |
| **Forecaster** | Works out when the house will really be finished at the current pace, which stages hold everything else up, and what it will cost to complete. |
| **What if?** | Answers questions like *"what if cement goes up 15%?"* or *"what if the roof is delayed three weeks?"* without changing the real record. |
| **Ask the house** | Answers plain questions such as *"How much have we spent on cement?"* or *"Why is a payment held?"* from the project's actual records, in **English, Sinhala or Tamil**. |

### A worked example

> Nimal has paid **Rs. 4.20M**. The work verified as built is worth **Rs. 2.60M**.
> The builder asks for **Rs. 800k** more.
> Payment Guard: **hold.** Paid is already ahead of verified work.
> The builder sends a photo of the finished slab. The AI confirms it shows a completed slab, so the slab counts as verified. Part of the request is now covered, so that part is released and the rest stays held.

Money decisions are made by clear, fixed rules, never by the AI's opinion. The AI is only used to understand messages, check photos and put answers into words; the numbers always come from the project's records.

## Who is it for?

- **Home owners abroad** who want to know where their money went.
- **Builders and site supervisors** who want a clear, timestamped record of progress and of what caused a delay.
- **Architects** who verify the work and sign off progress.

## The website

Everyone signs up with their email, a password and their role. What you can do on a project depends on your role there; the website only shows the actions your role allows, and the server checks the role again.

| Role | What they do on a project |
|---|---|
| **Client** | Creates the project, invites the contractor and architect by email, sets the budget and plan, records payments already made, asks questions, follows progress and money. |
| **Contractor** | Sends site updates in their own words, reports progress, asks for payments, sends photo proof. |
| **Architect** | Helps plan the build, verifies progress from proof (which releases held money), can send photo proof too. |

Each project page has these tabs:

| Tab | What you see or do |
|---|---|
| **Overview** | Paid, verified built, held and budget at a glance; every part of the house with its reported and verified progress, cost and status; all payments. |
| **Plan** | Add parts of the house with cost, dates and what must finish first; record past payments. |
| **Actions** | Site updates, progress reports and payment requests (contractor); verification (architect); the Delay Detector and its notices. |
| **Photo** | Send a photo as proof and see what the AI found. |
| **Forecast** | Finish date, days late, critical path, cost to complete, and the "what if" calculator. |
| **Ask** | Ask about the house and choose the answer language. |
| **Team** | Who is on the project and in which role; invite new people. |
| **Activity** | The full record of who did what, in which role and when. It cannot be edited. |

The website has a dark, minimal look and works on phones as well as laptops. Each person only sees the projects they belong to. Nothing in the app is pre-filled: projects, plans, payments and progress are all entered through the website (or the API) and stored in the project's database.

## How to use it

A first project, step by step:

1. **Sign up.** Open the website, choose **Sign up**, and enter your email, a password, your name and your usual role. You land on **Your projects**.
2. **Create a project (client).** Click **+ New project** and fill in the name, location, contract sum, start and handover dates, and your role on it. The **advance limit** (default 10%) is how far payments may run ahead of verified work before Payment Guard holds money. **Retention** (default 5%) is kept back until handover.
3. **Invite your team (client).** Open the project, go to **Team** and invite the contractor and the architect by email. Each of them must sign up **with that same email**. The project then appears in their list, with their role on it.
4. **Plan the build (client or architect).** In **Plan**, add each part of the house with its cost and dates, and list what must finish first (for example, *Walls* after *Slab*). Record any payments already made.
5. **Report from site (contractor).** In **Actions**, send updates in your own words (*"slab eka 60% wage karala, cement 45k gaththa"*), report progress, and request payments. In **Photo**, send photos of finished work.
6. **Verify (architect).** In **Actions**, verify how much of each part is really done. Verified work releases any money Payment Guard was holding.
7. **Follow along (everyone).** **Overview** shows money and progress, **Forecast** shows the finish date and lets you try "what if", **Ask** answers questions about the house, and **Activity** shows who did what.

If an action isn't allowed, or something is missing (for example, an element name that doesn't exist), the page shows the reason and nothing is changed.

## Current status

This is a hackathon prototype (AI Hackathon 2026, Jaseci). It runs on **Jac 0.34.23**. The accounts, the website and all seven helpers above work and are tested, including with a real AI model, and a full end-to-end run passes on a real Jac 0.34 server: a client, a contractor and an architect each used every feature through the website and the API (228 checks), with and without an AI model. Not built yet: live material prices, payment milestones with architect sign-off, receipts and the ledger, change orders, plan drawings, messages, and the estimator from the full design. See [`BACKEND.md`](BACKEND.md) for the technical details, and [`plan.md`](plan.md) and [`PLAN-P2.md`](PLAN-P2.md) for the original plans.

## Try it

You'll need **Jac 0.34.23** (Linux, macOS, or WSL on Windows), which brings its own Python, AI library and web client.

```bash
# 1. Get the code
git clone https://github.com/SachinthaWijesundara/Nirmana_V2.git
cd Nirmana_V2

# 2. Install Jac 0.34.23 (Linux or macOS; on Windows use WSL)
curl -fsSL https://raw.githubusercontent.com/jaseci-labs/jaseci/main/scripts/install.sh | bash
jac install

# 3. Start the website (the first start installs and builds it, which takes a minute)
jac start main.jac
```

Open **http://localhost:8000** and sign up. To fill it with the demo project, run this in a second terminal while the website is running:

```bash
jac run scripts/seed_demo.jac
```

### Demo accounts

After loading the demo data you can log in as:

| Role | Email | Password | Projects |
|---|---|---|---|
| Client | nimali.perera@nirmana.demo | Client@2026 | Perera House |
| Contractor | ruwan.silva@nirmana.demo | Contractor@2026 | Perera House, Jayasuriya Annex |
| Architect | anushka.fernando@nirmana.demo | Architect@2026 | Perera House |
| Client | kamal.jayasuriya@nirmana.demo | Client2@2026 | Jayasuriya Annex |

These are made-up accounts for testing only.

### Turning on the AI

The AI parts (reading messages, checking photos, answering questions) run on **Groq**. Get a key from Groq and set it as an environment variable before starting the website:

```bash
export GROQ_API_KEY=your-key-here     # Windows PowerShell: $env:GROQ_API_KEY = "your-key-here"
jac start main.jac
```

| Setting | What it does |
|---|---|
| `GROQ_API_KEY` | Turns on the AI. Reading messages and answering questions use `openai/gpt-oss-120b`; checking photos uses `qwen/qwen3.8-27b` (both on Groq). |
| `GEDARA_MODEL` | Optional: a different text model (any [LiteLLM](https://docs.litellm.ai/docs/providers) model name, with that provider's key set). |
| `GEDARA_VISION_MODEL` | Optional: a different model for checking photos. It must accept images. |
| `GEDARA_LLM=mock` | Uses a built-in practice AI with fixed answers (for tests; no key needed). |

On JacHammer, add `GROQ_API_KEY` under **Settings → Environment** instead. **Never paste a key into a file or commit it**; the project's checks will reject it. Without a key, Nirmana still works: messages and questions are handled by simpler built-in rules, and photos are kept for the architect to review by hand.

### Running it on JacHammer

Open the project in JacHammer, add `GROQ_API_KEY` under **Settings → Environment**, and start the preview. A new preview starts with an empty database: sign up there, or load the demo accounts by pointing the demo script at the preview's address:

```bash
NIRMANA_URL=https://your-preview-address jac run scripts/seed_demo.jac
```

- To deploy, go to **Ship → Preview** and click **Start preview**. You get a public link that works for **7 days**; start the preview again to get a fresh one. Redeploying keeps the data already entered.
- **Production** (a permanent address with your own subdomain) needs a JacHammer Builder or Pro plan; deploy it from **Ship → Production**.
- Without JacHammer, any Linux server with Jac 0.34.23 works: run `jac start main.jac -p 8000` behind a web server, and set `GROQ_API_KEY` in its environment.

### Using the API

Everything the website does is also an API: sign in with `POST /user/register` and `POST /user/login`, then call `POST /function/<name>` with the token. For example:

```bash
curl -X POST http://localhost:8000/function/list_projects   -H "Authorization: Bearer <token>" -H "Content-Type: application/json" -d '{}'
```

A refused call replies `{"error": "..."}`. [`BACKEND.md`](BACKEND.md) lists every endpoint, who may call it, and what it does.

### If something goes wrong

| Problem | What to do |
|---|---|
| The page stays blank on the first start | The website is still being built; wait a minute and refresh. |
| `jac start` says the port is in use | Start it on another port: `jac start main.jac -p 8001`. |
| You see **Finish your profile** | Fill it in once; it links your account to your name and role. |
| An invited person can't see the project | They must sign up with exactly the email they were invited with. |
| Answers say "Answered from the graph" (not by AI), or photos wait for review | No AI key is set; add `GROQ_API_KEY` and restart. |
| You want to start again with an empty database | Stop the website and delete the `.jac/data` folder. |

### Things to know about Jac 0.34

- The website's client keeps the answers of server calls for a minute. Nirmana clears that store before every page load and every action, so what you see is always current.
- Numbers typed into forms reach the server as text, and a value the caller leaves out arrives as text too. The server turns them back into numbers before using them.
- The web client needs the `@tanstack/react-form` package, which is listed in `jac.toml`.
- When a request fails, Jac 0.34 throws away everything that request touched, and that can include saved records. So Nirmana's endpoints never fail outright: they check everything before saving anything, and report a refused action as a normal reply with an error message, which the website shows.

### Running the checks

```bash
export GEDARA_LLM=mock              # Windows PowerShell: $env:GEDARA_LLM = "mock"
jac test tests/api_tests.jac
jac test tests/intake_tests.jac
jac test tests/payment_tests.jac
jac test tests/delay_tests.jac
jac test tests/forecast_tests.jac
```

`GEDARA_LLM=mock` uses a built-in practice AI, so no account or key is needed. If everything is working you'll see `Passed successfully.` after each one. To type-check a file, run `jac check <file>`, for example `jac check main.jac`.

## How the pieces fit

```
Client / Contractor / Architect ──► Website ──► sign-in and role check
                                                   │
Builder's message ──► Intake ──────────────► House model ◄── Payment Guard ──► hold / release
Site photo ─────────► Photo proof ─ verified ─────┤                ▲
                                                   ├── Delay Detector ──► dated delay notice
                                                   ├── Forecaster / What if ──► finish date, cost
                                                   └── Ask the house ──► answer from the records
```

| Folder / file | Contents |
|---|---|
| `ui/` | The website, written in Jac: sign-in and projects (`App.cl.jac`), the project page (`ProjectView.cl.jac`) and its styles |
| `api/` | The public API the website calls (`endpoints.jac`), accounts and role checks (`access.jac`), and the project logic (`projects.jac`) |
| `agents/` | The helpers: `intake.jac`, `payment.jac`, `photo.jac`, `delay.jac`, `forecast.jac`, `scenario.jac`, `qa.jac` |
| `twin.jac` | The house model: projects, people, parts of the house, payments, updates and the activity record |
| `main.jac` | Starts the website and the API together |
| `seed/`, `scripts/` | The demo data and the script that loads it through the website's own API |
| `tests/` | Tests for each helper and for the API |
| `.github/` | Automatic checks that run on every change |

## Quality checks

Every change is automatically checked for:

1. **No leaked keys**: no AI keys committed to the repo.
2. **Jac share**: at least 80% of the code is written in Jac (a hackathon rule). The whole project, website included, is about 98% Jac.
3. **Code correctness**: every file is type-checked and every test must pass.

## Built with

[Jac / Jaseci](https://docs.jaseci.org), including its graph-based programming model, built-in AI functions (byLLM), built-in accounts and Jac's web client for the website, with AI models on Groq for reading messages, checking photos and answering questions.

## Team

Built for the AI Hackathon 2026 (Jaseci, Moratuwa) by the Nirmana team.
