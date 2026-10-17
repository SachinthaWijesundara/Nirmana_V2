# P1 plan: graph & logic (GedaraTwin)

**You are P1.** You own the twin graph, the `DependsOn` edges, the Forecaster and the Scenario (what-if).
**Your files:** `twin.jac`, `agents/forecast.jac`, `agents/scenario.jac`. Don't edit anyone else's files.
**Everyone codes against your schema**, so getting it agreed at 9:00 is your most important job.

Source: *AI Hackathon 2026 — Team Brief: Construction Digital Twin* (Desktop).

---

## 1. Your day at a glance

| Time | What you do | Done when |
|---|---|---|
| 9:00–9:30 | Share the **schema contract** (section 3) with P2 and P3. Get a written yes. Set up `jac.toml` and `CLAUDE.md` together | Schema is in the repo and everyone has pulled it |
| 9:30–11:00 | Build `twin.jac`: node and edge types, `seed_house()`, `get_twin` walker | `jac run` seeds the house; `get_twin` returns the JSON in section 5 |
| **11:00 checkpoint** | Show the graph end to end. If it fails, the whole team helps | P2 can find an Element by name; P3 can fetch `get_twin` |
| 11:00–2:00 | Build the **Forecaster** (section 6) | It returns a finish date, cost to complete, over/under budget and the critical path |
| **2:00 checkpoint** | Core demo runs: message → twin updates → payment held → forecast | Commit and tag it `safe-v1` |
| 2:00–4:00 | **Scenario / what-if** (section 7), then help P2 with the Delay Detector (it reuses your dependency walk) | "Cement +15%" changes the forecast |
| **4:00 feature freeze** | Stop features. Check the Jac % with P3 and fix bugs only | — |
| 4:00–5:15 | Help with the video: explain the graph and walkers on screen | — |

Rule: if something isn't working within 15 minutes, ask the Jaseci team on-site.

---

## 2. Things to do first (9:00–9:30)

1. Clone the repo, then run `jac --version` and write the version into `CLAUDE.md`.
2. Give P2 and P3 a copy of section 3 (schema) and section 5 (`get_twin` output). This is the contract.
3. Agree on these decisions with the team (the brief recommends these):
   - Name: **GedaraTwin**
   - Lead story: **Payment Guard** (money protection)
   - Demo input: **text only**
   - Who writes the seed data: **you write `seed_house()` in `twin.jac`**. P3's `seed.jac` just calls it. This avoids two people guessing the numbers.
4. Agree that "today" is a **fixed demo day** (`House.today`), not the real clock. That keeps the demo the same every time you record it.

---

## 3. Schema contract (agree this at 9:00)

All dates are **integer day numbers from the project start** (day 0 = `House.start_date`). The UI turns them into real dates. This avoids date maths in Jac.

### Nodes

| Node | Fields |
|---|---|
| `House` | `name: str`, `budget: float`, `start_date: str` ("2026-03-02"), `today: int` (demo day) |
| `Client` | `name: str`, `country: str` |
| `Builder` | `name: str` |
| `Area` | `name: str`, `level: int` |
| `Element` | `name: str`, `kind: str`, `planned_cost: float`, `actual_cost: float`, `pct_complete: float` (0–100, what the builder **reported**), `verified_pct: float` (0–100, **proven** by photo), `materials: dict[str, float]` (share of cost, e.g. `{"cement": 0.3}`), `planned_start: int`, `planned_end: int`, `actual_start: int` (-1 = not started), `actual_end: int` (-1 = not finished) |
| `Payment` | `amount: float`, `day: int`, `status: str` ("paid", "requested", "held", "partial", "released"), `released: float`, `note: str` |
| `Update` | `raw_text: str`, `day: int`, `summary: str`, `cost: float`, `photo_url: str` |
| `Alert` | `kind: str` ("payment_hold", "delay", "forecast"), `message: str`, `day: int`, `severity: str` |

### Edges (direction matters)

| Edge | From → To | Meaning |
|---|---|---|
| `Owns` | Client → House | |
| `Builds` | Builder → House | |
| `HasArea` | House → Area | |
| `HasElement` | Area → Element | |
| `DependsOn` | Element → Element | "A depends on B" = `A +>:DependsOn:+> B` (Roof → Slab) |
| `HasPayment` | House → Payment | |
| `PaidFor` | Payment → Element | the brief's `paid_by` |
| `ReportedIn` | Update → Element | |
| `HasAlert` | House → Alert | |

`Client` and `Builder` are connected to `root` and to the House. Everything else is reached from the House.

**Who writes which fields:**
- P2's Intake changes `pct_complete`, `actual_cost`, `actual_start`/`actual_end`, and adds `Update` nodes.
- P2's Payment Guard changes `verified_pct` and `Payment.status`/`released`, and adds `Alert` nodes.
- You only **read** these in the Forecaster. Scenario never changes the real twin.

A draft of these types already passes `jac check` and `jac run` (tested on the installed jaclang). Rebuild it at 9:30, don't paste old code, because code before 9:00 is not allowed.

---

## 4. Seed house (your prep work, already done on paper)

**Nimal's house, Kurunegala.** Client: Nimal (Qatar). Builder: Sunil baas. Budget **Rs. 8,000,000**. Start date 2026-03-02. Demo "today" = **day 200**.

| # | Element | Area | Planned cost (Rs.) | Depends on | Planned days | Reported % | Verified % | Cement share |
|---|---|---|---|---|---|---|---|---|
| 1 | Site prep & setting out | Ground | 150,000 | — | 0–14 | 100 | 100 | 0.00 |
| 2 | Foundation | Ground | 1,100,000 | 1 | 14–49 | 100 | 100 | 0.35 |
| 3 | Columns | Ground | 550,000 | 2 | 49–77 | 100 | 100 | 0.30 |
| 4 | Walls | Ground | 800,000 | 3 | 77–119 | 100 | 100 | 0.25 |
| 5 | Upper slab | Upper | 1,600,000 | 4 | 119–154 | 80 → 100 (demo message) | 0 | 0.35 |
| 6 | Roof | Upper | 1,200,000 | 5 | 154–196 | 0 | 0 | 0.05 |
| 7 | Plumbing | Services | 450,000 | 4 | 119–161 | 30 | 0 | 0.05 |
| 8 | Electrical | Services | 500,000 | 4 | 119–161 | 20 | 0 | 0.00 |
| 9 | Plastering | Finishes | 650,000 | 5, 7, 8 | 196–231 | 0 | 0 | 0.40 |
| 10 | Tiling & finishes | Finishes | 1,000,000 | 6, 9 | 231–273 | 0 | 0 | 0.20 |

Total 8,000,000. Planned finish = **day 273**. The project is already behind (slab planned to end on day 154, still not done on day 200), so the Forecaster will show a real slip.

**Payments already made (total Rs. 4,200,000):** day 10: 600k · day 50: 1,000k · day 90: 900k · day 130: 900k · day 170: 800k (advance "for the slab").

**Why the numbers work for the demo:**
- Verified built = 150k + 1,100k + 550k + 800k = **Rs. 2,600,000**. Paid = **Rs. 4,200,000**. That's the brief's "Paid 4.2M, verified built 2.6M" line.
- The baas sends "slab eka iwarai, cement bag 40k gaththa" → Intake sets the slab to 100% reported (turns green) and adds 40k to its actual cost.
- The baas asks for Rs. 800,000. Payment Guard holds it because verified (2.6M) is far below paid (4.2M).
- A slab photo arrives → the slab's verified % goes to 100 → verified = 4.2M. With a Rs. 300,000 advance allowance (agree on this with P2), Payment Guard releases **300k** and keeps **500k** held. That's "releases part on proof".

Give these numbers to P2 (Payment Guard) and P3 (dashboard and video) at 9:00.

---

## 5. `get_twin` output (contract for P3)

Make `walker:pub get_twin` in `twin.jac` report a single dict shaped like this:

```json
{
  "house": {"name": "...", "budget": 8000000, "start_date": "2026-03-02", "today": 200},
  "elements": [
    {"name": "Upper slab", "area": "Upper", "kind": "structure",
     "planned_cost": 1600000, "actual_cost": 1640000,
     "pct_complete": 100, "verified_pct": 0,
     "planned_start": 119, "planned_end": 154, "actual_start": 120, "actual_end": -1,
     "depends_on": ["Walls"]}
  ],
  "money": {"paid": 4200000, "reported_built": 4435000, "verified_built": 2600000},
  "payments": [{"amount": 800000, "day": 200, "status": "held", "released": 0}],
  "alerts": [{"kind": "payment_hold", "message": "...", "day": 200, "severity": "high"}]
}
```

`reported_built` = sum of `planned_cost × pct_complete / 100`. `verified_built` = the same using `verified_pct`. Put these two in a shared helper (`def money_summary(h: House) -> dict`) so Payment Guard and the dashboard use the same maths.

**Helpers to give P2 in `twin.jac`:** `get_house() -> House`, `find_element(name: str) -> Element | None`, `money_summary(h: House) -> dict`.

---

## 6. Forecaster (`agents/forecast.jac`), 11:00–2:00

Write a `walker:pub forecast` that walks the elements and their `DependsOn` edges and reports something like this (the numbers are only examples):

```json
{"finish_day": 312, "finish_date": "2027-01-08", "planned_finish_day": 273,
 "slip_days": 39, "cost_to_complete": 3550000, "projected_total": 8650000,
 "over_budget": 650000, "critical_path": ["Walls", "Upper slab", "Roof", "Tiling & finishes"]}
```

**Steps (one Claude Code prompt each, run after every step):**

1. **Pace factor.** For finished elements, `pace = actual days ÷ planned days`. Average them. Default 1.0 if none are finished.
2. **Remaining days per element.**
   - Finished: 0.
   - In progress: `planned_days × (1 − pct/100) × pace`.
   - Not started: `planned_days × pace`.
3. **Forward pass over `DependsOn`** (the critical path method):
   - `est_start = max(today, est_end of every prerequisite)` (use the actual start if it has started)
   - `est_end = est_start + remaining_days`
   - Process elements in dependency order. With 10 elements, just loop until nothing changes. No clever topological sort needed.
4. **Finish day** = the largest `est_end`. **Critical path** = start at the last element and keep stepping to the prerequisite with the largest `est_end`.
5. **Cost.** `overrun = actual_cost ÷ planned_cost` averaged over finished elements (default 1.0). Cost to complete = for each element, `planned_cost × (1 − pct/100) × overrun`. `projected_total = spent so far + cost to complete`. `over_budget = projected_total − budget`.
6. Turn `finish_day` into a date string (`start_date + days`; Python's `datetime` is fine to import from Jac).
7. Add one `Alert` (kind "forecast") if `over_budget > 0` or `slip_days > 14`.

**Why this matters for judging:** this is a walker that follows graph edges to reason about the future. Say exactly that in the video.

**Test:** add a `test "forecast on seed house" {}` block and run `jac test`. Check by hand: the slab is late, so the roof, plastering and tiling all slip.

Write the maths as `def compute_forecast(h: House, what_if: WhatIf) -> dict` so Scenario can call it again with changes (see below).

---

## 7. Scenario / what-if (`agents/scenario.jac`), 2:00–4:00, stretch

Only start this after the 2:00 checkpoint is green.

**Simple, safe approach (recommended):** don't copy the graph. Pass the changes into the same forecast maths.

```
obj WhatIf {
    has material_price: dict[str, float] = {};  # {"cement": 0.15} = +15%
    has delay_days: int = 0;                    # e.g. 21 = 3-week monsoon
    has delay_element: str = "";                # "" = delay whatever is in progress now
}
```

- Price change: for each remaining element, `extra = remaining cost × materials["cement"] × 0.15`.
- Delay: add `delay_days` to the remaining days of the chosen element (or the current ones). The forward pass then spreads it through `DependsOn` by itself. That's the "ripple".
- `walker:pub scenario` takes `cement_pct`, `delay_days` and `delay_element`, and reports the base forecast, the what-if forecast and the difference.

**Upgrade only if there's time:** really copy the Element subgraph under a `ScenarioHouse` node and run the forecast walker on the copy. It matches the brief's "copies the twin and replays it" line and looks better to judges, but it costs about an hour more.

Demo line: "What if cement goes up 15%?" → "+Rs. X, finish date unchanged". "What if it rains for 3 weeks?" → "Finish moves to April, and the roof and tiling slip."

---

## 8. Help P2 with the Delay Detector (if Scenario is done)

The Delay Detector needs to know why something is late, e.g. rain → slab → roof. Give P2 a helper in `twin.jac`:
`def downstream(e: Element) -> list[Element]` (everything that depends on `e`, directly or indirectly, using `<-:DependsOn:<-`).

---

## 9. Working with Claude Code (your session)

- Your session only touches `twin.jac`, `agents/forecast.jac` and `agents/scenario.jac`.
- Start each session with: "Read CLAUDE.md. Use the jaseci skill. Run `jac guide jac-core-cheatsheet` and `jac guide jac-walker-patterns` before writing code."
- One small step per prompt (one node type group, one walker, one forecast step). Run `jac check` and `jac run` after each step.
- If you change node fields: `rm -rf .jac` before running again, or you'll get stale or duplicate nodes.
- `root ++> X()` returns a **list**. Use `[0]`.
- Commit after every working piece: `git add -A && git commit -m "twin: ..."`.

---

## 10. Your checklist

**Before 9:00 (allowed, no code)**
- [ ] Read the brief
- [ ] `jac --version` works and a hello-world walker runs
- [ ] LLM API key tested (P2 needs it most, but you need it to run Intake end to end)
- [ ] Seed house numbers checked (section 4) and ready to share
- [ ] Talk to one person who built a house recently and write down one quotable line

**During the day**
- [ ] 9:30 Schema agreed in writing with P2 and P3
- [ ] 11:00 `twin.jac` seeds the house; `get_twin` works
- [ ] 2:00 Forecaster works; core demo committed as `safe-v1`
- [ ] 4:00 Scenario works, or is cut
- [ ] 4:00 Jac % checked (must be at least 80%)
- [ ] Graph and walkers explained in the video and the write-up

**Final submission (the whole team)**
- [ ] GitHub link (at least 80% Jac) · demo video · written description · star `jaseci-labs/jac` · Jac Hammer deploy · submit by **5:15**
