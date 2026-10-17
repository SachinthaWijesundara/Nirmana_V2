# Pluggable backend

The UI never talks to a server directly. Every screen goes through two functions in `backend/index.cl.jac`:

```
query(resource, params)    -> data        # reads
command(action, payload)   -> result      # writes
```

Which adapter answers is chosen at runtime, so the same UI runs against fake data, a REST API or the Jac server.

| Adapter | Select with | What it does |
|---|---|---|
| `mock` (default) | nothing, or `?backend=mock` | In-memory seed data (`seed_core.cl.jac`, `seed_project.cl.jac`). Kept in `sessionStorage`, so a demo survives reloads. Close the tab to reset. |
| `rest` | `?backend=rest&api=https://host` | `GET {api}/api/{resource}?{params}` and `POST {api}/api/commands/{action}` with a JSON body. |
| `jac` | `?backend=jac&api=http://localhost:8000` | Calls `jac start` endpoints (`POST {api}/function/<name>`). Maps what the Jac server already implements and falls back to `mock` for the rest. Today it maps `dashboard` from `get_house_view` (the D1 twin dashboard in `ui/api.jac`). |

The choice and the API URL are remembered in `localStorage` (`nirmana.backend`, `nirmana.api`).

## Adding your own backend

1. Create `backend/<name>.cl.jac` with `<name>_query(base, resource, params)` and `<name>_command(base, action, payload)`.
2. Add one branch for it in `query()` and `command()` in `backend/index.cl.jac`.
3. Return the shapes below. The seed files are the reference: copy a resource from there and fill it with real data.

## Resources (`query`)

| Resource | Params | Returns |
|---|---|---|
| `roles` | none | `[{role, title, text, icon, tone}]` for the sign-in screen |
| `session` | `role` | `{user: {name, initials, role, email, tone}, badges: {approvals, messages}}` |
| `dashboard` | none | `{subtitle, stats[], layers[][], paid_ahead, months[], alerts[], messages[], waiting[]}` |
| `projects` | none | `[{id, name, place, status, status_tone, cover, pct, stage, paid, contract, team[], score, score_label, next, group}]` |
| `project` | `id` | `{project, tabs: [{id, label}]}` (header of every project page) |
| `project.<tab>` | `id` | the tab payload: `overview`, `schedule`, `progress`, `plans`, `materials`, `budget`, `changes`, `payments`, `ledger`, `activity`, `tour` |
| `approvals` | none | `{subtitle, items[], done[], details{id: ...}}` |
| `threads` / `thread` | `id` | thread list, and `{messages[], note, pinned[]}` for one thread |
| `market` | none | districts, products, price series and this month's prices |
| `estimator` | none | defaults and the bill of quantities |
| `calc_rates`, `ask_prompts` | none | rates for the calculators, suggested questions for Ask Nirmana |

## Commands (`command`)

`decide_approval {id, decision}`, `decide_change {id, decision}`, `certify_milestone {id, note}`, `pay_milestone {id}`, `post_daily_log {...}`,
`ack_log {id}`, `set_progress {name, pct}`, `ledger_query {id}`, `ledger_verify {id}`, `send_message {thread, text, ...}`, `mark_read {thread}`,
`approve_plan`, `ask {question}`, `estimate {area, contingency, finish}`, `create_project`.
Each returns `{ok, message}` (`ask` and `estimate` return their result). Throw or return a non-2xx status to show the error toast.

## Roles

`lib/roles.cl.jac` mirrors who may do what (client approves and pays, architect certifies and verifies, contractor posts logs and raises changes).
The UI disables an action the current role cannot take and says why. **The server must enforce the same rules.**
