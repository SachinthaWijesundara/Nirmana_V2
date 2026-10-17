"""Project endpoints: everything the frontend needs to enter and read project data,
plus the P1/P2 agents exposed per project with role checks.

All endpoints are authenticated (plain def). Call them as POST /function/<name> with a
Bearer token and a JSON body of the parameters."""
import from twin {
    House, Element, Payment, PaymentStatus, Member, Activity, Update, DelayNotice, Has,
    depends_on, paid_by, ROLES, now_iso, today_iso, find_element, elements, money_summary,
    element_row, revised_budget
}
import from api.access {
    Ctx, access, registry, me, my_projects, log, team, members, initials
}
import from agents.intake { Intake }
import from agents.payment { PaymentGuard, ReleaseOnProof }
import from agents.delay { DelayDetector }
import from agents.forecast { forecast }
import from agents.scenario { scenario }

def require(ok: bool, message: str) -> None {
    if not ok { raise ValueError(message); }
}

def project_summary(ctx: Ctx) -> dict[str, any] {
    house = ctx.house;
    money = money_summary(house);
    budget = revised_budget(house);
    verified_value: float = money["verified"];
    built_pct: float = 0.0;
    if budget > 0.0 { built_pct = int(1000.0 * verified_value / budget) / 10.0; }
    stage = "";
    for el in elements(house) {
        if el.percent_complete > 0.0 and el.percent_complete < 100.0 { stage = el.name; break; }
    }
    return {
        "id": jid(house), "name": house.name, "location": house.location, "district": house.district,
        "building_type": house.building_type, "floor_area_sqft": house.floor_area_sqft,
        "status": house.status, "stage": stage, "my_role": ctx.member.role,
        "contract_sum": house.total_budget, "revised_sum": budget, "paid": money["paid"],
        "verified_built": money["verified"], "built_pct": built_pct, "team": team(house)
    };
}

# ---------------------------------------------------------------- projects and people

"""Create a project. The caller joins it in my_role (the client usually creates it)."""
def create_project(
    name: str, location: str = "", district: str = "", building_type: str = "",
    floor_area_sqft: float = 0.0, contract_sum: float = 0.0, start_date: str = "",
    handover_date: str = "", my_role: str = "client", advance_limit_pct: float = 10.0,
    retention_pct: float = 5.0
) -> dict[str, any] {
    p = me();
    require(name.strip() != "", "A project name is required.");
    require(my_role in ROLES, f"my_role must be one of {ROLES}.");
    require(contract_sum >= 0.0, "contract_sum cannot be negative.");
    house = House(
        name=name.strip(), total_budget=contract_sum, start_date=start_date if start_date != "" else today_iso(),
        location=location, district=district, building_type=building_type, floor_area_sqft=floor_area_sqft,
        handover_date=handover_date, advance_limit_pct=advance_limit_pct, retention_pct=retention_pct,
        created_at=now_iso(), created_by=p.root_id
    );
    registry() +>:Has():+> house;
    grant(house, level=WritePerm);
    m = Member(email=p.email, role=my_role, name=p.name, root_id=p.root_id, status="active", invited_by=p.root_id, joined_at=now_iso());
    house +>:Has():+> m;
    grant(m, level=WritePerm);
    ctx = Ctx(house=house, me=p, member=m);
    log(ctx, "project_created", f"{p.name} created the project {house.name}.", "project");
    return project_summary(ctx);
}

"""Invite someone by email as client, contractor or architect. They see the project after they sign in."""
def invite_member(project_id: str, email: str, role: str, name: str = "") -> dict[str, any] {
    ctx = access(project_id, ["client", "architect"]);
    clean = email.strip().lower();
    require("@" in clean, "A valid email is required.");
    require(role in ROLES, f"role must be one of {ROLES}.");
    for m in members(ctx.house) {
        require(not (m.email == clean and m.status != "removed"), f"{clean} is already on this project.");
    }
    m = Member(email=clean, role=role, name=name, status="invited", invited_by=ctx.me.root_id);
    ctx.house +>:Has():+> m;
    grant(m, level=WritePerm);
    log(ctx, "member_invited", f"{ctx.me.name} invited {name if name != '' else clean} as {role}.", "project");
    return {"email": clean, "role": role, "status": "invited", "initials": initials(name if name != "" else clean)};
}

"""Projects the caller is on."""
def list_projects() -> list[dict[str, any]] {
    return [project_summary(ctx) for ctx in my_projects()];
}

"""Change project details. Only the client."""
def update_project(
    project_id: str, name: str = "", location: str = "", district: str = "", building_type: str = "",
    floor_area_sqft: float = -1.0, contract_sum: float = -1.0, handover_date: str = "", status: str = "",
    advance_limit_pct: float = -1.0, retention_pct: float = -1.0
) -> dict[str, any] {
    ctx = access(project_id, ["client"]);
    h = ctx.house;
    if name != "" { h.name = name; }
    if location != "" { h.location = location; }
    if district != "" { h.district = district; }
    if building_type != "" { h.building_type = building_type; }
    if floor_area_sqft >= 0.0 { h.floor_area_sqft = floor_area_sqft; }
    if contract_sum >= 0.0 { h.total_budget = contract_sum; }
    if handover_date != "" { h.handover_date = handover_date; }
    if status != "" { h.status = status; }
    if advance_limit_pct >= 0.0 { h.advance_limit_pct = advance_limit_pct; }
    if retention_pct >= 0.0 { h.retention_pct = retention_pct; }
    log(ctx, "project_updated", f"{ctx.me.name} updated the project details.", "project");
    return project_summary(ctx);
}

# ---------------------------------------------------------------- the plan

"""Add a phase / bill-of-quantities line. prerequisites lists phases that must finish first."""
def add_element(
    project_id: str, name: str, planned_cost: float, planned_start: str, planned_end: str,
    kind: str = "", floor: str = "", prerequisites: list[str] = [], qty: float = 0.0, unit: str = "",
    material_shares: dict[str, float] = {}
) -> dict[str, any] {
    ctx = access(project_id, ["client", "architect"]);
    require(name.strip() != "", "An element name is required.");
    require(find_element(ctx.house, name) is None, f"{name} already exists on this project.");
    require(planned_cost >= 0.0, "planned_cost cannot be negative.");
    require(planned_start <= planned_end, "planned_start must be on or before planned_end.");
    el = Element(name=name.strip(), kind=kind, floor=floor, planned_cost=planned_cost, planned_start=planned_start, planned_end=planned_end, qty=qty, unit=unit, material_shares=material_shares);
    ctx.house +>:Has():+> el;
    grant(el, level=WritePerm);
    for dep_name in prerequisites {
        dep = find_element(ctx.house, dep_name);
        require(dep is not None, f"Unknown element {dep_name} in prerequisites.");
        el +>:depends_on():+> (dep as Element);
    }
    log(ctx, "element_added", f"{ctx.me.name} added {el.name} to the plan.", "project");
    return element_row(el, today_iso());
}

"""Change an element's plan. Leave a field empty (or -1) to keep it."""
def update_element(
    project_id: str, element_name: str, planned_cost: float = -1.0, planned_start: str = "",
    planned_end: str = "", kind: str = "", floor: str = ""
) -> dict[str, any] {
    ctx = access(project_id, ["client", "architect"]);
    found = find_element(ctx.house, element_name);
    require(found is not None, f"Unknown element {element_name}.");
    el = found as Element;
    if planned_cost >= 0.0 { el.planned_cost = planned_cost; }
    if planned_start != "" { el.planned_start = planned_start; }
    if planned_end != "" { el.planned_end = planned_end; }
    if kind != "" { el.kind = kind; }
    if floor != "" { el.floor = floor; }
    log(ctx, "element_updated", f"{ctx.me.name} updated the plan for {el.name}.", "project");
    return element_row(el, today_iso());
}

"""Record a payment the client has already made (e.g. before the project was on Nirmana)."""
def record_payment(project_id: str, amount: float, date: str = "", note: str = "", element_name: str = "") -> dict[str, any] {
    ctx = access(project_id, ["client"]);
    require(amount > 0.0, "amount must be positive.");
    pay = Payment(amount=amount, status=PaymentStatus.PAID, note=note, date=date if date != "" else today_iso(), recorded_by=ctx.me.name);
    ctx.house +>:Has():+> pay;
    grant(pay, level=WritePerm);
    if element_name != "" {
        el = find_element(ctx.house, element_name);
        require(el is not None, f"Unknown element {element_name}.");
        pay +>:paid_by():+> (el as Element);
    }
    log(ctx, "payment_recorded", f"{ctx.me.name} recorded a payment of Rs. {amount:,.0f}.", "money");
    return {"amount": pay.amount, "status": pay.status.value, "date": pay.date, "note": pay.note};
}

"""The whole twin for one project: details, team, plan, money, payments and activity."""
def get_project(project_id: str) -> dict[str, any] {
    ctx = access(project_id);
    h = ctx.house;
    today = today_iso();
    payments = [{"amount": p.amount, "status": p.status.value, "date": p.date, "note": p.note, "recorded_by": p.recorded_by} for p in [h ->:Has:->][?:Payment]];
    activity = [{"actor": a.actor, "role": a.role, "kind": a.kind, "text": a.text, "category": a.category, "at": a.at} for a in [h ->:Has:->][?:Activity]];
    notices = [{"date": n.date, "element": n.element_name, "days_behind": n.days_behind, "cause_chain": n.cause_chain, "evidence": n.evidence} for n in [h ->:Has:->][?:DelayNotice]];
    summary = project_summary(ctx);
    summary["start_date"] = h.start_date;
    summary["handover_date"] = h.handover_date;
    summary["advance_limit_pct"] = h.advance_limit_pct;
    summary["retention_pct"] = h.retention_pct;
    summary["elements"] = [element_row(el, today) for el in elements(h)];
    summary["money"] = money_summary(h);
    summary["payments"] = payments;
    summary["activity"] = activity;
    summary["delay_notices"] = notices;
    return summary;
}

"""The audit trail for a project, newest first. category filters (money, progress, project)."""
def get_activity(project_id: str, category: str = "") -> list[dict[str, any]] {
    ctx = access(project_id);
    rows = [{"actor": a.actor, "role": a.role, "kind": a.kind, "text": a.text, "category": a.category, "at": a.at} for a in [ctx.house ->:Has:->][?:Activity] if category == "" or a.category == category];
    rows.reverse();  # activities are stored in the order they happened
    return rows;
}

# ---------------------------------------------------------------- agents (P1 and P2), per project

"""Contractor sends a site message (text, Singlish/Sinhala/English). Intake updates the right element."""
def send_builder_message(project_id: str, message: str) -> dict[str, any] {
    ctx = access(project_id, ["contractor"]);
    require(message.strip() != "", "message is empty.");
    res = ctx.house spawn Intake(message=message);
    result: dict[str, any] = {"ok": False, "reason": "no result"};
    if len(res.reports) > 0 { result = res.reports[0] as dict[str, any]; }
    log(ctx, "builder_message", f"{ctx.me.name}: \"{message}\"", "progress");
    return result;
}

"""Contractor reports progress on an element directly (0-100). Progress never goes backwards.
on_date is when this progress was reached (defaults to today); started_on is when the work
began, if it is the first report. They set the element's actual start and finish dates."""
def report_progress(project_id: str, element_name: str, percent: float, on_date: str = "", started_on: str = "", actual_cost: float = 0.0) -> dict[str, any] {
    ctx = access(project_id, ["contractor"]);
    require(percent >= 0.0 and percent <= 100.0, "percent must be between 0 and 100.");
    found = find_element(ctx.house, element_name);
    require(found is not None, f"Unknown element {element_name}.");
    el = found as Element;
    day = on_date if on_date != "" else today_iso();
    require(actual_cost >= 0.0, "actual_cost cannot be negative.");
    if percent > el.percent_complete { el.percent_complete = percent; }
    el.actual_cost += actual_cost;
    require(started_on == "" or started_on <= day, "started_on must be on or before on_date.");
    if el.actual_start == "" and el.percent_complete > 0.0 { el.actual_start = started_on if started_on != "" else day; }
    if el.percent_complete >= 100.0 and el.actual_end == "" { el.actual_end = day; }
    log(ctx, "progress_reported", f"{ctx.me.name} reported {el.name} at {el.percent_complete}%.", "progress");
    return element_row(el, today_iso());
}

"""Contractor asks for money. Payment Guard releases what verified work covers and holds the rest."""
def request_payment(project_id: str, amount: float, note: str = "") -> dict[str, any] {
    ctx = access(project_id, ["contractor"]);
    require(amount > 0.0, "amount must be positive.");
    res = ctx.house spawn PaymentGuard(request_amount=amount, note=note, requested_by=ctx.me.name);
    log(ctx, "payment_requested", f"{ctx.me.name} requested Rs. {amount:,.0f}: {note}", "money");
    return res.reports[0] as dict[str, any];
}

"""Architect verifies an element from proof (photos, inspection). Held money the proof covers is released."""
def verify_progress(project_id: str, element_name: str, verified_percent: float, note: str = "") -> dict[str, any] {
    ctx = access(project_id, ["architect"]);
    res = ctx.house spawn ReleaseOnProof(element_name=element_name, verified_percent=verified_percent);
    result = res.reports[0] as dict[str, any];
    if result["ok"] {
        log(ctx, "progress_verified", f"{ctx.me.name} verified {element_name} at {verified_percent}%. {note}".strip(), "progress");
    }
    return result;
}

"""Find late elements, trace the cause through depends_on and write dated delay notices."""
def run_delay_check(project_id: str, today: str = "") -> list[dict[str, any]] {
    ctx = access(project_id);
    res = ctx.house spawn DelayDetector(today=today if today != "" else today_iso());
    if len(res.reports) == 0 { return []; }
    return res.reports[0] as list[dict[str, any]];
}

"""Finish date, slip, critical path and cost to complete at the current pace."""
def get_forecast(project_id: str, today: str = "") -> dict[str, any] {
    ctx = access(project_id);
    require(len(elements(ctx.house)) > 0, "Add elements to the plan before forecasting.");
    res = ctx.house spawn forecast(today=today);
    return res.reports[0] as dict[str, any];
}

"""What-if: cement price change (%) and/or a delay. The real twin is not changed."""
def run_scenario(project_id: str, cement_pct: float = 0.0, delay_days: int = 0, delay_element: str = "", today: str = "") -> dict[str, any] {
    ctx = access(project_id);
    require(len(elements(ctx.house)) > 0, "Add elements to the plan before running a scenario.");
    res = ctx.house spawn scenario(cement_pct=cement_pct, delay_days=delay_days, delay_element=delay_element, today=today);
    return res.reports[0] as dict[str, any];
}
