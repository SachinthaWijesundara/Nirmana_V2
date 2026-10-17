"""The twin graph: every node type the backend stores, plus small pure helpers.

Nothing in this file holds project data. Projects, people, prices and plans are
created through the API (see api/) and live in the persisted graph."""
import from datetime { date, datetime, timedelta }

enum PaymentStatus: str { PAID = "paid", HELD = "held", RELEASED = "released" }

glob ROLES: list[str] = ["client", "contractor", "architect"];

# ---------------------------------------------------------------- accounts

"""One per signed-in user, hung off that user's own root and indexed in the Registry."""
node Profile {
    has root_id: str;
    has email: str;
    has name: str;
    has default_role: str = "client";
    has phone: str = "";
    has created_at: str = "";
}

"""The shared index on root.shared: projects, profiles and the market catalog hang off it."""
node Registry {
    has name: str = "nirmana";
}

"""A person on a project. Role is per project, so one user can be client on one and architect on another."""
node Member {
    has email: str;
    has role: str;
    has name: str = "";
    has root_id: str = "";
    has status: str = "invited";
    has invited_by: str = "";
    has joined_at: str = "";
}

# ---------------------------------------------------------------- the project (House)

node House {
    has name: str;
    has total_budget: float = 0.0;  # contract sum; revised sum adds approved changes
    has start_date: str = "";
    has location: str = "";
    has district: str = "";
    has building_type: str = "";
    has floor_area_sqft: float = 0.0;
    has handover_date: str = "";
    has status: str = "active";
    has advance_limit_pct: float = 10.0;  # Payment Guard: advance allowed on top of verified work, % of budget
    has retention_pct: float = 5.0;  # kept back from each milestone until after handover
    has rate_tolerance_pct: float = 5.0;  # ledger rates more than this above fair price are flagged
    has created_at: str = "";
    has created_by: str = "";
}

"""A phase of work and a bill-of-quantities line: planned_cost is its budget."""
node Element {
    has name: str;
    has kind: str = "";
    has planned_cost: float = 0.0;
    has actual_cost: float = 0.0;
    has percent_complete: float = 0.0;  # what the contractor reported
    has verified_pct: float = 0.0;  # what the architect verified from proof
    has planned_start: str = "";
    has planned_end: str = "";
    has materials: list[str] = [];
    has photos: list[str] = [];
    has actual_start: str = "";
    has actual_end: str = "";
    has material_shares: dict[str, float] = {};
    has floor: str = "";
    has qty: float = 0.0;
    has unit: str = "";
    has certified_at: str = "";
    has certified_by: str = "";
}

node Payment {
    has amount: float;
    has status: PaymentStatus = PaymentStatus.PAID;
    has note: str = "";
    has date: str = "";
    has milestone_code: str = "";
    has recorded_by: str = "";
}

"""A payment stage: upcoming -> invoiced (or held) -> certified -> paid."""
node Milestone {
    has code: str;
    has name: str;
    has amount: float;
    has due_date: str = "";
    has status: str = "upcoming";
    has element_names: list[str] = [];
    has invoiced_at: str = "";
    has invoice_note: str = "";
    has held_reason: str = "";
    has certified_at: str = "";
    has certified_by: str = "";
    has certify_note: str = "";
    has retention: float = 0.0;
    has paid_at: str = "";
    has paid_amount: float = 0.0;
}

node Update {
    has raw_text: str;
    has summary: str = "";
    has at: str = "";
    has author: str = "";
}

"""The audit trail. Written once, never edited."""
node Activity {
    has actor: str;
    has kind: str;
    has text: str;
    has role: str = "";
    has category: str = "";
    has at: str = "";
}

node DelayNotice {
    has date: str;
    has element_name: str;
    has cause_chain: list[str];
    has days_behind: int;
    has evidence: str;
    has cause: str = "";
    has from_date: str = "";
    has to_date: str = "";
}

node LedgerEntry {
    has date: str;
    has description: str;
    has category: str = "material";  # material, labour, equipment, other
    has material_key: str = "";
    has supplier: str = "";
    has qty: float = 0.0;
    has unit: str = "";
    has rate: float = 0.0;
    has amount: float = 0.0;
    has receipt_url: str = "";
    has element_name: str = "";
    has status: str = "pending_review";  # pending_review, queried, verified
    has audit: str = "";  # ok, review, overpriced, missing_receipt
    has audit_note: str = "";
    has market_rate: float = 0.0;
    has fair_rate: float = 0.0;
    has query_note: str = "";
    has reply_note: str = "";
    has created_by: str = "";
    has created_at: str = "";
}

node ChangeOrder {
    has code: str;
    has title: str;
    has reason_type: str = "client_request";  # client_request, site_condition, design_change
    has description: str = "";
    has cost_impact: float = 0.0;
    has time_impact_days: int = 0;
    has status: str = "pending";  # pending, approved, rejected
    has quote_url: str = "";
    has material_key: str = "";
    has quoted_rate: float = 0.0;
    has rate_note: str = "";
    has raised_by: str = "";
    has raised_at: str = "";
    has decided_by: str = "";
    has decided_at: str = "";
    has decision_note: str = "";
}

node DailyLog {
    has date: str;
    has weather: str = "";
    has workers: int = 0;
    has text: str = "";
    has elements: list[str] = [];
    has photos: list[str] = [];
    has include_in_digest: bool = True;
    has status: str = "awaiting_architect";  # awaiting_architect, acknowledged
    has posted_by: str = "";
    has acknowledged_by: str = "";
    has created_at: str = "";
}

node PlanSheet {
    has code: str;
    has title: str;
    has revision: str = "A";
    has status: str = "awaiting_client";  # awaiting_client, approved, revision_asked
    has file_url: str = "";
    has uploaded_by: str = "";
    has uploaded_at: str = "";
    has decided_by: str = "";
}

node PlanComment {
    has author: str;
    has role: str;
    has text: str;
    has tag: str = "question";  # question, design_change, cost_impact
    has x: float = 0.0;
    has y: float = 0.0;
    has at: str = "";
}

node ScheduleEvent {
    has title: str;
    has date: str;
    has owner_role: str = "";
    has kind: str = "event";  # inspection, delivery, milestone, event
    has done: bool = False;
}

"""History of progress so earned value can be charted month by month."""
node ProgressEvent {
    has element_name: str;
    has kind: str;  # reported, verified
    has pct: float;
    has at: str;
    has author: str = "";
}

node Message {
    has thread: str;  # "project" for everyone, or "dm:<root_id>:<root_id>"
    has sender_name: str;
    has sender_role: str;
    has sender_root: str;
    has text: str;
    has at: str;
}

node PhotoSpot {
    has name: str;
}

node Photo {
    has url: str;
    has date: str;
    has caption: str = "";
    has author: str = "";
}

"""Materials the project needs (from the estimator or calculators) and how much was used."""
node MaterialNeed {
    has material_key: str;
    has qty_needed: float = 0.0;
    has qty_used: float = 0.0;
    has unit: str = "";
    has source: str = "";
}

# ---------------------------------------------------------------- market catalog (shared, under Registry)

"""A material the market tracks. match_* decide which shop listings count as this material;
listing_factor converts a listing's price to this material's unit (e.g. per bar -> per kg)."""
node Material {
    has key: str;
    has name: str;
    has unit: str;
    has category: str = "material";
    has match_all: list[str] = [];
    has match_any: list[str] = [];
    has exclude: list[str] = [];
    has listing_factor: float = 1.0;
}

node District {
    has name: str;
    has cost_factor: float = 1.0;
}

node PriceSource {
    has name: str;
    has url: str;
    has active: bool = True;
    has last_fetched_at: str = "";
    has last_status: str = "";
}

node PriceObservation {
    has material_key: str;
    has price: float;
    has unit: str;
    has source_name: str;
    has observed_at: str;
    has url: str = "";
    has raw_name: str = "";
    has method: str = "live";  # live, manual
}

"""Estimator quantities per square foot of floor area, per finish level."""
node CostNorm {
    has item: str;
    has finish_level: str = "mid";
    has qty_per_sqft: float = 0.0;
    has unit: str = "";
    has material_key: str = "";
    has rate_per_unit: float = 0.0;  # used when no market material applies (e.g. lump-sum items)
    has category: str = "material";
}

edge Has {}
edge depends_on {}
edge paid_by {}
edge reported_in {}

# ---------------------------------------------------------------- pure helpers

def now_iso() -> str {
    return datetime.now().isoformat(timespec="seconds");
}

def today_iso() -> str {
    return date.today().isoformat();
}

def find_element(house: House, name: str) -> Element | None {
    target = name.lower();
    for el in [house ->:Has:->][?:Element] {
        if el.name.lower() == target { return el; }
    }
    return None;
}

def elements(house: House) -> list[Element] {
    return [house ->:Has:->][?:Element];
}

def approved_changes(house: House) -> float {
    total: float = 0.0;
    for co in [house ->:Has:->][?:ChangeOrder] {
        if co.status == "approved" { total += co.cost_impact; }
    }
    return total;
}

def revised_budget(house: House) -> float {
    return house.total_budget + approved_changes(house);
}

def money_summary(house: House) -> dict[str, float] {
    paid: float = 0.0;
    held: float = 0.0;
    for payment in [house ->:Has:->][?:Payment] {
        if payment.status == PaymentStatus.HELD { held += payment.amount; }
        else { paid += payment.amount; }
    }
    built: float = 0.0;
    verified: float = 0.0;
    for el in elements(house) {
        built += el.planned_cost * el.percent_complete / 100.0;
        verified += el.planned_cost * el.verified_pct / 100.0;
    }
    return {"paid": paid, "held": held, "built": built, "verified": verified, "budget": revised_budget(house)};
}

def downstream(el: Element) -> list[Element] {
    found: list[Element] = [];
    pending: list[Element] = [el];
    seen: set[str] = {jid(el)};
    while pending {
        current = pending.pop(0);
        for child in [current <-:depends_on:<-][?:Element] {
            key = jid(child);
            if key not in seen {
                seen.add(key);
                found.append(child);
                pending.append(child);
            }
        }
    }
    return found;
}

"""Status of a phase for the house view: done, active, delayed or not_started."""
def element_status(el: Element, today: str) -> str {
    if el.percent_complete >= 100.0 { return "done"; }
    if el.planned_end != "" and today > el.planned_end { return "delayed"; }
    if el.percent_complete > 0.0 or el.actual_start != "" { return "active"; }
    return "not_started";
}

def element_row(el: Element, today: str) -> dict[str, any] {
    return {
        "id": jid(el), "name": el.name, "kind": el.kind, "floor": el.floor,
        "planned_cost": el.planned_cost, "actual_cost": el.actual_cost,
        "percent_complete": el.percent_complete, "verified_pct": el.verified_pct,
        "planned_start": el.planned_start, "planned_end": el.planned_end,
        "actual_start": el.actual_start, "actual_end": el.actual_end,
        "qty": el.qty, "unit": el.unit, "materials": el.materials,
        "certified_at": el.certified_at, "certified_by": el.certified_by,
        "status": element_status(el, today),
        "depends_on": [dep.name for dep in [el ->:depends_on:->][?:Element]]
    };
}

test "money summary splits reported and verified work" {
    house = House(name="Test", total_budget=1000.0);
    root ++> house;
    house +>:Has():+> Element(name="A", planned_cost=400.0, percent_complete=100.0, verified_pct=50.0);
    house +>:Has():+> Payment(amount=300.0);
    house +>:Has():+> Payment(amount=100.0, status=PaymentStatus.HELD);
    house +>:Has():+> ChangeOrder(code="CO-001", title="x", cost_impact=50.0, status="approved");
    s = money_summary(house);
    assert s["paid"] == 300.0;
    assert s["held"] == 100.0;
    assert s["built"] == 400.0;
    assert s["verified"] == 200.0;
    assert s["budget"] == 1050.0;
}

test "payment status is a string enum" {
    assert PaymentStatus.HELD == PaymentStatus("held");
    assert PaymentStatus.HELD.value == "held";
}

test "downstream follows depends_on transitively" {
    house = House(name="T2");
    root ++> house;
    a = Element(name="A");
    b = Element(name="B");
    c = Element(name="C");
    house +>:Has():+> a;
    house +>:Has():+> b;
    house +>:Has():+> c;
    b +>:depends_on():+> a;
    c +>:depends_on():+> b;
    names = [e.name for e in downstream(a)];
    assert "B" in names and "C" in names;
}

test "element status" {
    assert element_status(Element(name="x", percent_complete=100.0), "2026-10-17") == "done";
    assert element_status(Element(name="x", planned_end="2026-10-01", percent_complete=40.0), "2026-10-17") == "delayed";
    assert element_status(Element(name="x", planned_end="2026-11-01", percent_complete=40.0), "2026-10-17") == "active";
    assert element_status(Element(name="x", planned_end="2026-11-01"), "2026-10-17") == "not_started";
}
