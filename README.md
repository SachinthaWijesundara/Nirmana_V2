<p align="center">
  <img src="assets/banner.svg" alt="Nirmana: know what your money has actually built" width="100%">
</p>

<p align="center">
  <a href="https://github.com/SachinthaWijesundara/Nirmana_V2/actions/workflows/ci.yml"><img src="https://github.com/SachinthaWijesundara/Nirmana_V2/actions/workflows/ci.yml/badge.svg" alt="CI status"></a>
  <img src="https://img.shields.io/badge/built%20with-Jac-1d5c63" alt="Built with Jac">
  <img src="https://img.shields.io/badge/status-hackathon%20prototype-f4b942" alt="Hackathon prototype">
</p>

**Nirmana** (working name *GedaraTwin*) helps people who are building a home in Sri Lanka while living abroad. It keeps a living model of the house, reads the builder's everyday messages, and protects both sides: the owner from paying for work that isn't there, and the builder from unfair blame for delays.

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
| **Delay Detector** | Spots parts of the build that are behind schedule and traces the delay back to its real cause (for example, Walls are late because the Slab was late). It writes a dated notice with the evidence, a fair record for the builder. |

### A worked example

> Nimal has paid **Rs. 4.20M**. The work verified as built is worth **Rs. 2.60M**.
> The builder asks for **Rs. 800k** more.
> Payment Guard: **hold.** Paid is already ahead of verified work.
> A photo of the slab arrives and its progress is verified. Part of the request is now covered, so that part is released and the rest stays held.

Money decisions are made by clear, fixed rules, never by the AI's opinion. The AI is only used to understand messages.

## Who is it for?

- **Home owners abroad** who want to know where their money went.
- **Builders and site supervisors** who want a clear, timestamped record of progress and of what caused a delay.

## Current status

This is a hackathon prototype (AI Hackathon 2026, Jaseci). The three helpers above work and are tested. They currently run against a **sample house** (*Nimal's house*: Foundation, Slab, Walls). The house model, forecasting, "what if" scenarios and a dashboard to drive them are in place. See [`plan.md`](plan.md) and [`PLAN-P2.md`](PLAN-P2.md) for the roadmap.

## Try it

You'll need **Python 3.12 or newer**.

```bash
# 1. Get the code
git clone https://github.com/SachinthaWijesundara/Nirmana_V2.git
cd Nirmana_V2

# 2. Install Jac, the language Nirmana is written in
pip install -r requirements.txt

# 3. Run the checks with the built-in practice AI (no account or key needed)
export GEDARA_LLM=mock              # Windows PowerShell: $env:GEDARA_LLM = "mock"
jac test tests/intake_tests.jac
jac test tests/payment_tests.jac
jac test tests/delay_tests.jac
```

If everything is working you'll see `Passed successfully.` after each one.

### Open the dashboard

The dashboard is written in Jac too (`jac-client`: `.cl.jac` components that compile to React). The first run builds the UI with **Bun**; `jac start` installs it automatically if it is missing (or install it yourself from https://bun.sh).

```bash
export GEDARA_LLM=mock              # optional: practice AI, no key needed
jac start main.jac                  # first run installs the UI packages and builds them
```

Open http://localhost:8000. A good demo order:

1. **Ask Payment Guard** for Rs. 800,000. It is held, because paid (4.2M) is ahead of verified work (2.6M).
2. **Send to Intake** with *"slab eka iwarai, cement bag 40k gaththa"*. The slab turns to 100% reported, but it is not verified yet.
3. Press **Verify** on the slab. Proof raises verified work, and Payment Guard releases the part it now covers (Rs. 420k) and keeps the rest held.
4. **Run delay check** and a **What if?** scenario, and watch the agent activity feed.

To start again from the sample house, stop the server and delete `.jac/data`.
Use `jac start main.jac` without `--dev`: in hot-reload mode the agent walkers can't find the house node.

| File | What it is |
|---|---|
| `main.jac` | Entry point: serves every agent walker and mounts the UI |
| `dashboard_api.jac` | Read-only `dashboard_view` walker: the twin as typed objects, with the forecast |
| `components/*.cl.jac` | Dashboard sections (money, house model, builder message, payment request, forecast, activity) |
| `components/Dashboard.impl.jac` | What each button does: spawns the agent walkers, then reloads the view |

### Using a real AI model

By default (without `GEDARA_LLM=mock`) Intake uses Claude to read messages. Set your own API key as an environment variable first. **Never paste a key into a file or commit it**; the project's checks will reject it.

To use another provider, set `GEDARA_MODEL` to any LiteLLM model name. For Groq, pick a model that supports structured outputs:

```bash
export GROQ_API_KEY=...                        # Windows PowerShell: $env:GROQ_API_KEY = "..."
export GEDARA_MODEL=groq/openai/gpt-oss-120b   # Windows PowerShell: $env:GEDARA_MODEL = "groq/openai/gpt-oss-120b"
jac start main.jac
```

## How the pieces fit

```
Builder's message ──► Intake ──► House model ◄── Payment Guard ──► hold / release
                                     ▲
                                     └────────── Delay Detector ──► dated delay notice
```

| Folder | Contents |
|---|---|
| `agents/` | The three helpers: `intake.jac`, `payment.jac`, `delay.jac` |
| `mock/` | The sample house used until the full model lands |
| `tests/` | Tests for each helper |
| `.github/` | Automatic checks that run on every change |

## Quality checks

Every change is automatically checked for:

1. **No leaked keys**: no AI keys committed to the repo.
2. **Jac share**: at least 80% of the code is written in Jac (a hackathon rule).
3. **Code correctness**: every file is type-checked and every test must pass.

## Built with

[Jac / Jaseci](https://docs.jaseci.org), including its graph-based programming model and built-in AI functions (byLLM), with Claude by Anthropic for understanding messages.

## Team

Built for the AI Hackathon 2026 (Jaseci, Moratuwa) by the Nirmana team.
