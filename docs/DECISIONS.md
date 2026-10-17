# Decisions

## 2026-10-17 · D1 twin dashboard (branch `feat/d1-twin-dashboard`)

Built from Figma `II1pN9wQVTuvs4tyRgzdZk`, page "Hackathon demo", frame `25:2`. No UI code existed on `main`, so `ui/` was written from scratch on a branch cut from `main`.

### Layout

| Path | What |
|---|---|
| `main.jac` | Entry. Imports the two endpoints and mounts `ui/App.cl.jac`. |
| `ui/api.jac` | Server: `get_house_view`, `send_builder_message`, the view objects, and the demo seed. |
| `ui/App.cl.jac` | Stateful shell: fetch, loading/error states, send handler. |
| `ui/components/*.cl.jac` | Stateless sections. `fmt.cl.jac` holds `rs()`, which formats all money. |
| `ui/styles.css` | Figma colour tokens as CSS custom properties, the Manrope type scale, and layout. |

### API shapes (`ui/api.jac`)

Both endpoints are `def:pub` (no logins, per the brief) and read/write the shared global root.

**`get_house_view() -> HouseView`**

```
HouseView    { house_name, location, homeowner, homeowner_city, builder: str,
               elements: list[ElementView], money: MoneyView, forecast: ForecastView, alerts: list[AlertView] }
ElementView  { name, kind: str, percent_complete: float, status: str ("done"|"progress"|"late"|"idle"), row: int (0 = top) }
MoneyView    { budget, paid, verified, paid_ahead, held_amount: float, held_count: int }
ForecastView { finish: str, over_budget: float }
AlertView    { agent, kind, text, when, tone: str }   # agent feed, newest first, one per Activity node
```

`paid` and `verified` come from `agents/payment.jac::totals`. `paid_ahead = max(0, paid - verified)`. An element is `late` when a `DelayNotice` names it.

**`send_builder_message(message: str) -> IntakeResult`**: spawns the `Intake` walker and describes what changed.

```
IntakeResult { ok: bool, reason, element: str, before_percent, after_percent: float, material: str,
               cost_spent: float, language: str, attached_to: list[str], meaning: str, confidence: float }
```

Every field after `ok` has a default, so new fields can be added without breaking callers. Keep the existing names stable.

### Fake data (replace when the real source exists)

| Value | Where | Why |
|---|---|---|
| `IntakeResult.confidence` = 0.92 | `INTAKE_CONFIDENCE` | `ParsedUpdate` has no confidence score. |
| `attached_to` middle level ("Ground floor", "Roof", "Finishes") | `ELEMENT_AREA` | The twin has no `Area` nodes yet (P1's schema adds them). |
| Forecast "Mar 2027", Rs. 600,000 over budget | `FORECAST_FINISH`, `FORECAST_OVER_BUDGET` | No Forecaster walker yet (P1). |
| Homeowner, city, builder, location | `get_house_view` | The twin has no `Client`/`Builder` nodes yet. |
| Seeded Payment Guard, Forecaster and Delay Detector feed items | `seed_demo_house` | So the feed shows every agent before the demo starts. |

`meaning` is not fake: it is a template filled from the parsed fields (no LLM).

### Demo seed

On first call, `get_house_view` seeds "Perera House": budget Rs. 8.0M, paid Rs. 4.2M, one Rs. 800,000 request held, and Slab at 60% (verified built Rs. 2,208,000). Sending the prefilled message `slab eka iwarai, cement bag 40k gaththa` moves Slab to 100%. Verified built becomes Rs. 2,592,000 (shown as Rs. 2.6M), and the gap is Rs. 1,608,000. That matches the Figma frame.

To reset the demo, stop the server and delete `.jac/data/main.db*`.

### Changes outside `ui/`

- **`mock/twin.jac`: `PaymentStatus` is now `enum PaymentStatus: str { PAID = "paid", ... }`.** A plain enum is persisted as its int value and read back as a bare int. After any server restart, `status == PaymentStatus.HELD` was always false. Held money then counted as paid (the dashboard showed Rs. 5.0M paid, 0 held), and `agents/payment.jac::totals` was wrong too. A str enum compares equal to its stored value. All P2 tests still pass. The values also match P1's schema contract (`"paid"`, `"held"`, `"released"`).
- **`FeedClock` node (in `ui/api.jac`)** stores when each `Activity` was first seen, because `Activity` has no timestamp. When P1's `Alert.day` lands, use that instead.
- `jac.toml` is now the fullstack config (entry `main.jac`, `base_route_app = "app"`).

### Known issues

- Run the dev server with `GEDARA_LLM=mock` unless a model and API key are configured. Otherwise Intake calls the real model.
- In `jac start --dev`, a hot reload after editing `.jac` files can leave `Intake` unable to find the House: "Intake did not report a result". Restart the server after server-side edits.
- Client Jac has no working `str.join`, and `str.capitalize` is wrong (it swaps case). Use `join_parts()` and `cap()` from `fmt.cl.jac`. Backticks inside an f-string break the compiled JS.
- The Figma search bar and bell are not built because nothing backs them. The other nav items open a placeholder.
