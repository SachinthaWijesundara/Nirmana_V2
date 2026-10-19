"""Project endpoints: everything the frontend needs to enter and read project data,
plus the P1/P2 agents exposed per project with role checks.

All endpoints are authenticated (plain def). Call them as POST /function/<name> with a
Bearer token and a JSON body of the parameters."""
import from twin {
    House, Element, Payment, PaymentStatus, Member, Activity, Update, DelayNotice, Photo, Has,
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
import from agents.photo { PhotoCheck, check_photo, vision_available, proven_percent }
import from agents.qa { ask }
import from jaclang.byllm.lib { Image }

"""Numbers can reach the 0.34 server as text (form fields, or a left-out argument's default)."""
def num(value: any, fallback: float = 0.0) -> float {
    if value is None or str(value).strip() == "" { return fallback; }
    return float(value);
}

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
    floor_area_sqft = num(floor_area_sqft);
    contract_sum = num(contract_sum);
    advance_limit_pct = num(advance_limit_pct, 10.0);
    retention_pct = num(retention_pct, 5.0);
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
    floor_area_sqft = num(floor_area_sqft, -1.0);
    contract_sum = num(contract_sum, -1.0);
    advance_limit_pct = num(advance_limit_pct, -1.0);
    retention_pct = num(retention_pct, -1.0);
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
    kind: str = "", floor: str = "", prerequisites: list[str] | None = None, qty: float = 0.0, unit: str = "",
    material_shares: dict[str, float] | None = None
) -> dict[str, any] {
    planned_cost = num(planned_cost);
    qty = num(qty);
    # Empty list/dict defaults reach the server as strings on Jac 0.34, so default to None.
    deps: list[str] = prerequisites if isinstance(prerequisites, list) else [];
    shares: dict[str, float] = material_shares if isinstance(material_shares, dict) else {};
    ctx = access(project_id, ["client", "architect"]);
    require(name.strip() != "", "An element name is required.");
    require(find_element(ctx.house, name) is None, f"{name} already exists on this project.");
    require(planned_cost >= 0.0, "planned_cost cannot be negative.");
    require(planned_start <= planned_end, "planned_start must be on or before planned_end.");
    dep_nodes: list[Element] = [];
    for dep_name in deps {
        dep = find_element(ctx.house, dep_name);
        require(dep is not None, f"Unknown element {dep_name} in prerequisites.");
        dep_nodes.append(dep as Element);
    }
    el = Element(name=name.strip(), kind=kind, floor=floor, planned_cost=planned_cost, planned_start=planned_start, planned_end=planned_end, qty=qty, unit=unit, material_shares=shares);
    ctx.house +>:Has():+> el;
    grant(el, level=WritePerm);
    for dep_node in dep_nodes {
        el +>:depends_on():+> dep_node;
    }
    log(ctx, "element_added", f"{ctx.me.name} added {el.name} to the plan.", "project");
    return element_row(el, today_iso());
}

"""Change an element's plan. Leave a field empty (or -1) to keep it."""
def update_element(
    project_id: str, element_name: str, planned_cost: float = -1.0, planned_start: str = "",
    planned_end: str = "", kind: str = "", floor: str = ""
) -> dict[str, any] {
    planned_cost = num(planned_cost, -1.0);
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
    amount = num(amount);
    ctx = access(project_id, ["client"]);
    require(amount > 0.0, "amount must be positive.");
    target: Element | None = None;
    if element_name != "" {
        target = find_element(ctx.house, element_name);
        require(target is not None, f"Unknown element {element_name}.");
    }
    pay = Payment(amount=amount, status=PaymentStatus.PAID, note=note, date=date if date != "" else today_iso(), recorded_by=ctx.me.name);
    ctx.house +>:Has():+> pay;
    grant(pay, level=WritePerm);
    if target is not None {
        pay +>:paid_by():+> (target as Element);
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
    percent = num(percent);
    actual_cost = num(actual_cost);
    ctx = access(project_id, ["contractor"]);
    require(percent >= 0.0 and percent <= 100.0, "percent must be between 0 and 100.");
    found = find_element(ctx.house, element_name);
    require(found is not None, f"Unknown element {element_name}.");
    el = found as Element;
    day = on_date if on_date != "" else today_iso();
    require(actual_cost >= 0.0, "actual_cost cannot be negative.");
    require(started_on == "" or started_on <= day, "started_on must be on or before on_date.");
    if percent > el.percent_complete { el.percent_complete = percent; }
    el.actual_cost += actual_cost;
    if el.actual_start == "" and el.percent_complete > 0.0 { el.actual_start = started_on if started_on != "" else day; }
    if el.percent_complete >= 100.0 and el.actual_end == "" { el.actual_end = day; }
    log(ctx, "progress_reported", f"{ctx.me.name} reported {el.name} at {el.percent_complete}%.", "progress");
    return element_row(el, today_iso());
}

"""Contractor asks for money. Payment Guard releases what verified work covers and holds the rest."""
def request_payment(project_id: str, amount: float, note: str = "") -> dict[str, any] {
    amount = num(amount);
    ctx = access(project_id, ["contractor"]);
    require(amount > 0.0, "amount must be positive.");
    res = ctx.house spawn PaymentGuard(request_amount=amount, note=note, requested_by=ctx.me.name);
    log(ctx, "payment_requested", f"{ctx.me.name} requested Rs. {amount:,.0f}: {note}", "money");
    return res.reports[0] as dict[str, any];
}

"""Architect verifies an element from proof (photos, inspection). Held money the proof covers is released."""
def verify_progress(project_id: str, element_name: str, verified_percent: float, note: str = "") -> dict[str, any] {
    verified_percent = num(verified_percent);
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
    cement_pct = num(cement_pct);
    delay_days = int(num(delay_days));
    ctx = access(project_id);
    require(len(elements(ctx.house)) > 0, "Add elements to the plan before running a scenario.");
    res = ctx.house spawn scenario(cement_pct=cement_pct, delay_days=delay_days, delay_element=delay_element, today=today);
    return res.reports[0] as dict[str, any];
}

# ---------------------------------------------------------------- photo proof and Q&A

glob MAX_PHOTO_CHARS: int = 6000000;  # about 4.5 MB of image as a data URL
glob MIN_PHOTO_CONFIDENCE: float = 0.6;

"""Send a site photo as proof for an element (a data URL or an image URL). A vision model checks
it; a confident match raises the verified progress (up to what was reported) and releases held
money the proof covers. Without a vision model the photo is stored for the architect to review."""
def submit_photo_proof(project_id: str, element_name: str, image: str, note: str = "") -> dict[str, any] {
    ctx = access(project_id, ["contractor", "architect"]);
    found = find_element(ctx.house, element_name);
    require(found is not None, f"Unknown element {element_name}.");
    require(image.startswith("data:image/") or image.startswith("http"), "image must be a data:image/... URL or an http(s) link.");
    require(len(image) <= MAX_PHOTO_CHARS, "The photo is too large (limit about 4.5 MB).");
    el = found as Element;
    photo = Photo(url=image, date=today_iso(), caption=note, author=ctx.me.name);
    el +>:Has():+> photo;
    grant(photo, level=WritePerm);
    el.photos = el.photos + [jid(photo)];
    result: dict[str, any] = {"element": el.name, "photo_id": jid(photo), "checked": False, "released": 0.0, "verified_pct": el.verified_pct};
    if not vision_available() {
        result["message"] = "Photo saved. No vision model is configured, so the architect needs to review it.";
        log(ctx, "photo_proof", f"{ctx.me.name} sent a photo of {el.name} (waiting for review).", "progress");
        return result;
    }
    check: PhotoCheck | None = None;
    try {
        check = check_photo(Image(image), el.name, el.kind, el.percent_complete);
    } except Exception as e {
        result["message"] = "Photo saved, but the AI check failed (" + str(e) + "). The architect can verify it instead.";
        log(ctx, "photo_proof", f"{ctx.me.name} sent a photo of {el.name}; the AI check failed, waiting for review.", "progress");
        return result;
    }
    check = check as PhotoCheck;
    proven = proven_percent(check, el.percent_complete, MIN_PHOTO_CONFIDENCE);
    result["checked"] = True;
    result["shows_element"] = check.shows_element;
    result["estimated_percent"] = check.estimated_percent;
    result["confidence"] = check.confidence;
    result["observations"] = check.observations;
    if proven > el.verified_pct {
        res = ctx.house spawn ReleaseOnProof(element_name=el.name, verified_percent=proven);
        release = res.reports[0] as dict[str, any];
        result["released"] = release["released"];
        result["verified_pct"] = el.verified_pct;
        release_msg = str(release["message"]);
        result["message"] = "Photo accepted as proof: " + el.name + " verified at " + str(proven) + "%. " + release_msg;
    } else {
        result["message"] = "The photo was not accepted as new proof. " + check.observations;
    }
    log(ctx, "photo_proof", f"Photo of {el.name} checked by AI: {check.observations}", "progress");
    return result;
}

"""Ask a question about the project in plain words. language: english, sinhala or tamil."""
def ask_project(project_id: str, question: str, language: str = "english") -> dict[str, any] {
    ctx = access(project_id);
    require(question.strip() != "", "question is empty.");
    require(language in ["english", "sinhala", "tamil"], "language must be english, sinhala or tamil.");
    return ask(ctx.house, question, language);
}
