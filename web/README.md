# Nirmana web UI

The Nirmana screens from the Figma roadmap canvas, built as a Jac client app (compiles to React). The data source is a [pluggable backend](backend/README.md).

## Run it

```bash
pip install -r ../requirements.txt jac-client
cd web
jac install
jac start --dev main.jac        # http://localhost:8000, uses the mock backend
```

Sign in as Client, Contractor or Architect (the role decides what you can approve). Use `?backend=rest&api=...` or `?backend=jac&api=...` to switch data source.

## Layout

| Path | Contents |
|---|---|
| `main.jac`, `App.cl.jac` | Entry, shared state (context), routes, overlays |
| `screens/` | One file per screen (`ProjectTabsA/B` hold the 11 project tabs) |
| `components/` | Design-system atoms, shell (sidebar, top bar, project header), charts, states |
| `overlays/` | Confirm, ledger drawer, certify modal, daily-log drawer, Ask Nirmana |
| `backend/` | The pluggable data layer and the mock seed data |
| `styles/global.css` | Design tokens (colours, Manrope) and utility classes |

`jac start --dev` does not recompile on save. After an edit run `jac build main.jac`, then restart the dev server.
