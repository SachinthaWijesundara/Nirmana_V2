# Nirmana backend

Account-based backend for the construction digital twin. All code is Jac. No project data
is hard-coded: projects, people, plans, payments and progress are entered through the API
and stored in Jac's graph database (`.jac/data/`, created on first run).

## Run it

```bash
pip install -r requirements.txt
jac start main.jac --no_client          # API on http://localhost:8000
jac run scripts/seed_demo.jac           # optional: load the demo accounts and projects
```

`scripts/seed_demo.jac` reads `seed/demo_data.json` and sends every item through the API as
the matching user, so demo data goes in exactly like real data. Set `NIRMANA_URL` to seed a
server that is not on `localhost:8000`. To start from an empty database, stop the server and
delete the `.jac/` folder.

## Accounts and roles

1. `POST /user/register` with `{"identities":[{"type":"username","value":"<email>"}],"credential":{"type":"password","password":"<password>"}}`
2. `POST /user/login` with `{"identity":{"type":"username","value":"<email>"},"credential":{"type":"password","password":"<password>"}}` returns a `token`
3. `POST /function/create_profile` with `{"name","email","role","phone"}` once, using `Authorization: Bearer <token>`

Every endpoint below is `POST /function/<name>` with the Bearer token and a JSON body. A role is
per project: the same person can be the client on one project and the architect on another.
Each user only sees projects they are a member of, and each action checks their role on that
project. A refused call returns `{"error": "..."}`.

| Endpoint | Who | What |
|---|---|---|
| `create_profile`, `get_me` | anyone signed in | profile and my projects |
| `create_project` | anyone signed in | new project; the caller joins as `my_role` |
| `invite_member` | client, architect | add a person by email as client, contractor or architect |
| `list_projects`, `get_project`, `get_activity` | members | read projects, the full twin, the audit trail |
| `update_project`, `record_payment` | client | project details and settings, past payments |
| `add_element`, `update_element` | client, architect | the plan: phases, costs, dates, prerequisites |
| `send_builder_message` | contractor | Intake: site message in Singlish/English updates an element |
| `report_progress`, `request_payment` | contractor | progress on an element; Payment Guard decides a payment request |
| `verify_progress` | architect | verified %; releases held money the proof covers |
| `run_delay_check`, `get_forecast`, `run_scenario` | members | Delay Detector, Forecaster, what-if |

Project settings such as the advance limit (Payment Guard) and retention are stored on each
project when it is created.

## AI (Groq)

Intake is the agent that uses an LLM. It runs on Groq when `GROQ_API_KEY` is set in the
environment; the model defaults to `groq/openai/gpt-oss-120b` and can be changed with
`GEDARA_MODEL`. On JacHammer, add `GROQ_API_KEY` under Settings → Environment. Never put the key
in code or commit it (`.env` is git-ignored). With no key set, Intake uses a rule-based parser;
tests and CI use a mock (`GEDARA_LLM=mock`) and need no key. The other agents (Payment Guard,
Delay Detector, Forecaster, Scenario) are deterministic and never call an LLM.

## Demo logins (after running the seed script)

| Role | Email | Password | Projects |
|---|---|---|---|
| Client | nimali.perera@nirmana.demo | Client@2026 | Perera House |
| Contractor | ruwan.silva@nirmana.demo | Contractor@2026 | Perera House, Jayasuriya Annex |
| Architect | anushka.fernando@nirmana.demo | Architect@2026 | Perera House |
| Client | kamal.jayasuriya@nirmana.demo | Client2@2026 | Jayasuriya Annex |

These are dummy accounts for testing only.
