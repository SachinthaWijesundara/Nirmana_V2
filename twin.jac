enum PaymentStatus { PAID, HELD, RELEASED }

node House {
    has name: str;
    has total_budget: float = 0.0;
    has start_date: str = "";
}

node Element {
    has name: str;
    has kind: str = "";
    has planned_cost: float = 0.0;
    has actual_cost: float = 0.0;
    has percent_complete: float = 0.0;
    has planned_start: str = "";
    has planned_end: str = "";
    has materials: list[str] = [];
    has photos: list[str] = [];
    has actual_start: str = "";
    has actual_end: str = "";
    has material_shares: dict[str, float] = {};
}

node Payment {
    has amount: float;
    has status: PaymentStatus = PaymentStatus.PAID;
    has note: str = "";
    has date: str = "";
}

node Update {
    has raw_text: str;
    has summary: str = "";
}

node Activity {
    has actor: str;
    has kind: str;
    has text: str;
}

node DelayNotice {
    has date: str;
    has element_name: str;
    has cause_chain: list[str];
    has days_behind: int;
    has evidence: str;
}

edge Has {}
edge depends_on {}
edge paid_by {}
edge reported_in {}

def seed_house() -> House {
    houses = [root -->][?:House];
    if houses { return houses[0]; }

    house = root ++> House(name="Nimal's house (Kurunegala)", total_budget=8000000.0, start_date="2026-03-02");
    site = house +>:Has():+> Element(name="Site prep", kind="site", planned_cost=150000.0, planned_start="2026-03-02", planned_end="2026-03-16", percent_complete=100.0, actual_start="2026-03-02", actual_end="2026-03-18", actual_cost=150000.0, material_shares={"cement": 0.0});
    foundation = house +>:Has():+> Element(name="Foundation", kind="structure", planned_cost=1100000.0, planned_start="2026-03-16", planned_end="2026-04-20", percent_complete=100.0, actual_start="2026-03-18", actual_end="2026-04-28", actual_cost=1180000.0, material_shares={"cement": 0.35});
    columns = house +>:Has():+> Element(name="Columns", kind="structure", planned_cost=550000.0, planned_start="2026-04-20", planned_end="2026-05-18", percent_complete=100.0, actual_start="2026-04-28", actual_end="2026-06-01", actual_cost=550000.0, material_shares={"cement": 0.30});
    walls = house +>:Has():+> Element(name="Walls", kind="structure", planned_cost=800000.0, planned_start="2026-05-18", planned_end="2026-06-29", percent_complete=100.0, actual_start="2026-06-01", actual_end="2026-07-20", actual_cost=800000.0, material_shares={"cement": 0.25});
    slab = house +>:Has():+> Element(name="Slab", kind="structure", planned_cost=1600000.0, planned_start="2026-06-29", planned_end="2026-08-03", percent_complete=0.0, actual_start="2026-07-21", material_shares={"cement": 0.35});
    roof = house +>:Has():+> Element(name="Roof", kind="structure", planned_cost=1200000.0, planned_start="2026-08-03", planned_end="2026-09-14", percent_complete=0.0, material_shares={"cement": 0.05});
    plumbing = house +>:Has():+> Element(name="Plumbing", kind="services", planned_cost=450000.0, planned_start="2026-06-29", planned_end="2026-08-10", percent_complete=0.0, material_shares={"cement": 0.05});
    electrical = house +>:Has():+> Element(name="Electrical", kind="services", planned_cost=500000.0, planned_start="2026-06-29", planned_end="2026-08-10", percent_complete=0.0);
    plastering = house +>:Has():+> Element(name="Plastering", kind="finishes", planned_cost=650000.0, planned_start="2026-09-14", planned_end="2026-10-19", percent_complete=0.0, material_shares={"cement": 0.40});
    tiling = house +>:Has():+> Element(name="Tiling", kind="finishes", planned_cost=1000000.0, planned_start="2026-10-19", planned_end="2026-11-30", percent_complete=0.0, material_shares={"cement": 0.20});

    foundation +>:depends_on():+> site;
    columns +>:depends_on():+> foundation;
    walls +>:depends_on():+> columns;
    slab +>:depends_on():+> walls;
    roof +>:depends_on():+> slab;
    plumbing +>:depends_on():+> walls;
    electrical +>:depends_on():+> walls;
    plastering +>:depends_on():+> slab;
    plastering +>:depends_on():+> plumbing;
    plastering +>:depends_on():+> electrical;
    tiling +>:depends_on():+> roof;
    tiling +>:depends_on():+> plastering;

    payment1 = house +>:Has():+> Payment(amount=600000.0, date="2026-03-10");
    payment1 +>:paid_by():+> site;
    payment2 = house +>:Has():+> Payment(amount=1000000.0, date="2026-04-25");
    payment2 +>:paid_by():+> foundation;
    payment3 = house +>:Has():+> Payment(amount=900000.0, date="2026-06-05");
    payment3 +>:paid_by():+> columns;
    payment4 = house +>:Has():+> Payment(amount=900000.0, date="2026-07-15");
    payment4 +>:paid_by():+> walls;
    payment5 = house +>:Has():+> Payment(amount=800000.0, date="2026-08-20", note="advance for slab");
    payment5 +>:paid_by():+> slab;
    return house;
}

def get_house() -> House | None {
    houses = [root -->][?:House];
    if houses { return houses[0]; }
    return None;
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

def money_summary(house: House) -> dict {
    paid: float = 0.0;
    held: float = 0.0;
    for payment in [house ->:Has:->][?:Payment] {
        if payment.status == PaymentStatus.HELD { held += payment.amount; }
        else { paid += payment.amount; }
    }
    built: float = 0.0;
    for el in elements(house) { built += el.planned_cost * el.percent_complete / 100.0; }
    return {"paid": paid, "held": held, "built": built, "budget": house.total_budget};
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

walker:pub get_twin {
    can assemble with Root entry {
        houses = [root -->][?:House];
        house = houses[0] if houses else seed_house();
        element_rows: list[dict] = [];
        for el in elements(house) {
            dependencies = [dep.name for dep in [el ->:depends_on:->][?:Element]];
            element_rows.append({"name": el.name, "kind": el.kind, "planned_cost": el.planned_cost, "actual_cost": el.actual_cost, "percent_complete": el.percent_complete, "planned_start": el.planned_start, "planned_end": el.planned_end, "actual_start": el.actual_start, "actual_end": el.actual_end, "depends_on": dependencies});
        }
        payment_rows: list[dict] = [];
        for payment in [house ->:Has:->][?:Payment] {
            payment_rows.append({"amount": payment.amount, "status": payment.status.name, "date": payment.date, "note": payment.note});
        }
        activity_rows: list[dict] = [];
        for activity in [house ->:Has:->][?:Activity] {
            activity_rows.append({"actor": activity.actor, "kind": activity.kind, "text": activity.text});
        }
        report {"house": {"name": house.name, "total_budget": house.total_budget, "start_date": house.start_date}, "elements": element_rows, "money": money_summary(house), "payments": payment_rows, "activities": activity_rows};
    }
}

test "seed house has ten elements and expected money totals" {
    house = seed_house();
    assert len(elements(house)) == 10;
    summary = money_summary(house);
    assert summary["paid"] == 4200000.0;
    assert summary["built"] == 2600000.0;
}

test "downstream walls includes all later work" {
    house = seed_house();
    walls = find_element(house, "WALLS");
    names = [el.name for el in downstream(walls as Element)];
    assert "Slab" in names;
    assert "Roof" in names;
    assert "Plastering" in names;
    assert "Tiling" in names;
}

test "seeding twice does not duplicate the house" {
    first = seed_house();
    second = seed_house();
    assert jid(first) == jid(second);
    assert len([root -->][?:House]) == 1;
    assert len(elements(second)) == 10;
}
