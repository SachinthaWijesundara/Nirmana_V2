# Nirmana: P2 plan (AI agents)

Project: digital twin of a house under construction (Jac graph + walkers). Brief: AI Hackathon 2026, 17 Oct, submit by 5:15 PM (hard deadline 5:30).
P2 owns: `agents/intake.jac`, `agents/payment.jac`, `agents/delay.jac`, Singlish prompts, photo check. P2 touches no other files.

## Rules we must not break
- At least 80% of the code is Jac. Everything, including the glue, is Jac. No Python agents.
- Judges score "depth of agentic behaviour": walkers must act (hold a payment, request proof, write a notice), not just summarise.
- Commit after every working piece. Feature freeze 4:00 PM.

## Contract with P1 (agree in writing 9:00-9:30, before any code)
P2 codes against these names, so they must be fixed first. Proposed schema:

| Thing | Fields |
|---|---|
| `node House` | name, total_budget, start_date |
| `node Element` | name, kind, planned_cost, actual_cost, percent_complete, planned_start, planned_end, actual_end, materials, photos |
| `node Payment` | amount, date, note, status (`paid`/`held`/`released`) |
| `node Update` | raw_text, date, structured fields |
| `node DelayNotice` | date, cause_chain, evidence |
| edges | `depends_on` (Element to Element), `paid_by` (Payment to Element), `reported_in` (Update to Element) |

Open question for P1: the exact field names and whether a payment schedule (e.g. foundation 15%, walls 25%) lives on `Element` or a separate node. Payment Guard needs it.

## Build order (one walker per step, `jac check` then `jac run` after each)
1. **9:00-9:30** Setup. Install Jac and byLLM, confirm the LLM key works, write `jac-reference.md` and `CLAUDE.md`, and agree the schema with P1.
2. **9:30-11:00 Intake** (must, about 1 h)
   - `obj ParsedUpdate` (element name, percent complete, materials, cost, delay flag, language) filled by `def parse_update(msg: str, element_names: list[str]) -> ParsedUpdate by llm();`
   - Add `sem` descriptions with Singlish/Sinhala/Tamil examples ("slab eka iwarai, cement 40k gaththa" gives slab 100%, cement Rs. 40k).
   - A walker finds the matching `Element`, updates it, and links an `Update` through `reported_in`.
   - Develop against a mock graph, since P1's real one isn't ready. Tests use `MockLLM`, so they need no key.
3. **11:00 checkpoint:** graph works end to end. Everyone helps until it does.
4. **11:00-2:00 Payment Guard** (must, the demo star, 1-1.5 h)
   - Walk all Elements. Total money paid against verified built value (`percent_complete x planned_cost`).
   - If a requested payment exceeds verified value by a threshold, set the `Payment` to `held` and write an alert. Target demo line: "Paid Rs. 4.2M, verified built Rs. 2.6M. Request held."
   - The agent must act: ask for photo proof, and release part of the payment once proof arrives.
   - The money logic is deterministic Jac. The LLM only judges proof and writes the message.
5. **Connect to P3's dashboard** as `walker:pub` endpoints (alerts, held payments, money paid vs. built).
6. **2:00 checkpoint:** core demo runs. Commit it as the safe version.
7. **2:00-4:00 stretch, in this order**
   1. Delay Detector (should): spot slipping dates, walk `depends_on` backwards to the cause (rain, slab, roof), write a dated `DelayNotice` with evidence. This is the builder-protection angle.
   2. Photo proof check: byLLM image input. Check the docs first to see if it works.
   3. Help P1 with Scenario if they're behind. Client Q&A and voice notes come last.
8. **4:00** Feature freeze. Check the Jac percentage. **4:00-5:15** help P3 with the video and write-up, and have the description name the Jac features we used. **5:15** Submit.

## Jac features to name in the write-up and video
Walkers that traverse the graph, `by llm()` parsing the message, `sem`, typed edges, `walker:pub` endpoints served with `jac serve`, graph persistence.

## Risks
- Claude writes Python or old Jac syntax. Mitigation: the `jaseci` skill, `jac guide`, and `jac check` after every change.
- Schema drift between P1 and P2. Mitigation: fix it in writing in the first 30 minutes.
- LLM latency or key problems during the demo. Mitigation: cache one good parse result for the demo path and keep `MockLLM` for tests.
- byLLM can't take images. Mitigation: photo check stays a stretch goal and the demo is text only.

## Permissions and setup needed
| Need | Why | Who |
|---|---|---|
| OK to run `pip install jaclang` plus the byLLM plugin (via the skill's `ensure_jac.sh`) | Nothing is compiled without it | me, with your yes |
| LLM API key (Anthropic or OpenAI) as an env var, never pasted in chat | byLLM calls | you |
| Network access to jaclang.org docs | Reference file | me (WebFetch) |
| A permanent folder for nirmana, plus `git init` | The scratch folder is deleted with the session, and the repo must be checked at submission | you pick the folder |
| GitHub repo, starring github.com/jaseci-labs/jac, and a Jac Hammer account | Submission | you / P3 |
| Confirm at check-in that AI coding tools are allowed | The brief doesn't ban them but says to confirm | you |
