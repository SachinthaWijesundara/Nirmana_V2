"""Dashboard API for the D1 twin screen. Two public endpoints: get_house_view (read) and
send_builder_message (write, runs the Intake walker). Everything the UI shows comes from
the twin graph, except the values marked FAKE below (see docs/DECISIONS.md)."""
import time;
import from mock.twin { House, Element, Payment, PaymentStatus, Activity, DelayNotice, Has, depends_on }
import from agents.intake { Intake }
import from agents.payment { totals }

# FAKE: no Forecaster walker exists yet (P1 owns it). Fixed demo values until it lands.
glob FORECAST_FINISH: str = "Mar 2027",
     FORECAST_OVER_BUDGET: float = 600000.0;

# FAKE: ParsedUpdate has no confidence score, and the twin has no Area nodes yet.
glob INTAKE_CONFIDENCE: float = 0.92,
     ELEMENT_AREA: dict[str, str] = {"Roof": "Roof", "Painting": "Finishes", "Tiling": "Finishes", "Plastering": "Finishes"};

glob MAX_MESSAGE_CHARS: int = 1000;

# Row of each element in the house cross-section, top (0) to bottom (6).
glob ELEMENT_ROW: dict[str, int] = {
    "Painting": 0, "Tiling": 0, "Plastering": 0, "Roof": 1, "Plumbing": 2, "Electrical": 2,
    "Walls": 3, "Slab": 4, "Columns": 5, "Foundation": 6
};

"""When each Activity was first seen (epoch seconds, keyed by jid). Kept in the graph so it survives
restarts; the twin's Activity node has no timestamp of its own."""
node FeedClock {
    has seen: dict[str, float] = {};
}

def get_clock() -> FeedClock {
    found = [root -->[?:FeedClock]];
    return found[0] if len(found) > 0 else (root ++> FeedClock())[0];
}

obj ElementView {
    has name: str,
        kind: str,
        percent_complete: float,
        status: str,
        row: int;
}

obj AlertView {
    has agent: str,
        kind: str,
        text: str,
        when: str,
        tone: str;
}

obj MoneyView {
    has budget: float,
        paid: float,
        verified: float,
        paid_ahead: float,
        held_count: int,
        held_amount: float;
}

obj ForecastView {
    has finish: str,
        over_budget: float;
}

obj HouseView {
    has house_name: str,
        location: str,
        homeowner: str,
        homeowner_city: str,
        builder: str,
        elements: list[ElementView],
        money: MoneyView,
        forecast: ForecastView,
        alerts: list[AlertView];
}

obj IntakeResult {
    has ok: bool,
        reason: str = "",
        element: str = "",
        before_percent: float = 0.0,
        after_percent: float = 0.0,
        material: str = "",
        cost_spent: float = 0.0,
        language: str = "",
        attached_to: list[str] = [],
        meaning: str = "",
        confidence: float = 0.0;
}

"""Seed the Perera house the first time the dashboard opens. Numbers match the hackathon demo."""
def seed_demo_house() -> House {
    house = (root ++> House(name="Perera House", total_budget=8000000.0))[0];
    specs: list[tuple[str, str, float, float]] = [
        ("Foundation", "structure", 900000.0, 100.0), ("Columns", "structure", 700000.0, 100.0),
        ("Slab", "structure", 960000.0, 60.0), ("Walls", "structure", 800000.0, 4.0),
        ("Plumbing", "services", 500000.0, 0.0), ("Electrical", "services", 500000.0, 0.0),
        ("Roof", "structure", 1200000.0, 0.0), ("Plastering", "finishes", 600000.0, 0.0),
        ("Tiling", "finishes", 600000.0, 0.0), ("Painting", "finishes", 400000.0, 0.0)
    ];
    by_name: dict[str, Element] = {};
    for (name, kind, cost, pct) in specs {
        by_name[name] = (house +>:Has():+> Element(name=name, kind=kind, planned_cost=cost, percent_complete=pct))[0];
    }
    for (a, b) in [("Columns", "Foundation"), ("Slab", "Columns"), ("Walls", "Slab"), ("Roof", "Walls"), ("Plastering", "Walls")] {
        by_name[a] +>:depends_on():+> by_name[b];
    }
    for amount in [1500000.0, 1200000.0, 1500000.0] {
        house +>:Has():+> Payment(amount=amount, status=PaymentStatus.PAID, note="Stage payment");
    }
    house +>:Has():+> Payment(amount=800000.0, status=PaymentStatus.HELD, note="Walls stage request");
    now = time.time();
    seeded: list[tuple[str, str, str, float]] = [
        ("delay_detector", "delay_notice", "Wrote delay notice DN-03 (rain, 3 days)", 6 * 86400.0),
        ("forecaster", "forecast", "Finish date holds at 15 Mar 2027", 120.0),
        ("payment_guard", "payment_hold", "Held Rs. 800,000 request. Asked builder for wall photos", 120.0)
    ];
    seen: dict[str, float] = {};
    for (actor, kind, text, age) in seeded {
        act = (house +>:Has():+> Activity(actor=actor, kind=kind, text=text))[0];
        seen[jid(act)] = now - age;
    }
    get_clock().seen = seen;
    return house;
}

def get_house() -> House {
    found = [root -->[?:House]];
    return found[0] if len(found) > 0 else seed_demo_house();
}

def element_status(el: Element, late: list[str]) -> str {
    if el.percent_complete >= 100.0 {
        return "done";
    }
    if el.name in late {
        return "late";
    }
    return "progress" if el.percent_complete > 0.0 else "idle";
}

def ago(seconds: float) -> str {
    if seconds < 60.0 {
        return "now";
    }
    if seconds < 3600.0 {
        return f"{int(seconds / 60.0)} min";
    }
    if seconds < 86400.0 {
        return f"{int(seconds / 3600.0)} h";
    }
    return f"{int(seconds / 86400.0)} days";
}

glob AGENT_LABEL: dict[str, str] = {
    "builder": "Intake", "payment_guard": "Payment Guard", "forecaster": "Forecaster", "delay_detector": "Delay Detector"
};
glob AGENT_TONE: dict[str, str] = {
    "builder": "herb", "payment_guard": "danger", "forecaster": "midnight", "delay_detector": "marigold"
};

"""Agent feed, newest first. Activities are appended to the House, so reverse edge order."""
def alert_views(house: House) -> list[AlertView] {
    now = time.time();
    clock = get_clock();
    seen: dict[str, float] = {k: v for (k, v) in clock.seen.items()};
    views: list[AlertView] = [];
    for act in reversed([house ->:Has:->[?:Activity]]) {
        key = jid(act);
        if key not in seen {
            seen[key] = now;
        }
        views.append(AlertView(
            agent=AGENT_LABEL.get(act.actor, act.actor), kind=act.kind, text=act.text,
            when=ago(now - seen[key]), tone=AGENT_TONE.get(act.actor, "midnight")
        ));
    }
    if len(seen) != len(clock.seen) {
        clock.seen = seen;
    }
    return views;
}

def:pub get_house_view() -> HouseView {
    house = get_house();
    late = [n.element_name for n in [house ->:Has:->[?:DelayNotice]]];
    elements = [
        ElementView(name=e.name, kind=e.kind, percent_complete=e.percent_complete, status=element_status(e, late), row=ELEMENT_ROW.get(e.name, 3))
        for e in [house ->:Has:->[?:Element]]
    ];
    t = totals(house);
    held = [p for p in [house ->:Has:->[?:Payment]] if p.status == PaymentStatus.HELD];
    money = MoneyView(
        budget=house.total_budget, paid=t["paid"], verified=t["verified"], paid_ahead=max(0.0, t["paid"] - t["verified"]),
        held_count=len(held), held_amount=sum([p.amount for p in held])
    );
    return HouseView(
        house_name=house.name, location="Kandy", homeowner="Nimal Perera", homeowner_city="Doha, Qatar", builder="Ruwan Silva",
        elements=elements, money=money, forecast=ForecastView(finish=FORECAST_FINISH, over_budget=FORECAST_OVER_BUDGET),
        alerts=alert_views(house)
    );
}

"""Plain-language reading of the update, built from the parsed fields (no LLM)."""
def meaning_of(element: str, after: float, material: str, cost: float) -> str {
    done = f"{element} is finished" if after >= 100.0 else f"{element} is {int(after)}% done";
    if material != "" and cost > 0.0 {
        return f"{done}, bought {material} for {int(cost / 1000.0)}k";
    }
    return done;
}

def:pub send_builder_message(message: str) -> IntakeResult {
    text = message.strip();
    if text == "" {
        return IntakeResult(ok=False, reason="The message is empty.");
    }
    # Public endpoint feeding an LLM: cap the input so one request can't run up the bill.
    if len(text) > MAX_MESSAGE_CHARS {
        return IntakeResult(ok=False, reason=f"The message is too long (max {MAX_MESSAGE_CHARS} characters).");
    }
    house = get_house();
    before = {e.name: e.percent_complete for e in [house ->:Has:->[?:Element]]};
    cost_before = {e.name: e.actual_cost for e in [house ->:Has:->[?:Element]]};
    res = root spawn Intake(message=text);
    if len(res.reports) == 0 {
        return IntakeResult(ok=False, reason="Intake did not report a result.");
    }
    r = res.reports[0] as dict[str, object];
    if not r["ok"] {
        return IntakeResult(ok=False, reason=f"Intake could not use that message ({r['reason']}).");
    }
    name = r["element"] as str;
    el = [e for e in [house ->:Has:->[?:Element]] if e.name == name][0];
    material = el.materials[len(el.materials) - 1] if len(el.materials) > 0 else "";
    cost = el.actual_cost - cost_before.get(name, 0.0);
    after = r["percent_complete"] as float;
    return IntakeResult(
        ok=True, element=name, before_percent=before.get(name, 0.0), after_percent=after,
        material=material, cost_spent=cost, language=r["language"] as str,
        attached_to=["House", ELEMENT_AREA.get(name, "Ground floor"), name],
        meaning=meaning_of(name, after, material, cost), confidence=INTAKE_CONFIDENCE
    );
}
