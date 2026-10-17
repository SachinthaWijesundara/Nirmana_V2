import from twin { House, Element, Activity, Has, depends_on, elements, seed_house }
import from datetime { date, timedelta }

obj WhatIf {
    has material_price: dict[str, float] = {};
    has delay_days: int = 0;
    has delay_element: str = "";
}

def day_number(iso: str, origin: str) -> int {
    return (date.fromisoformat(iso) - date.fromisoformat(origin)).days;
}

def iso_day(day_num: int, origin: str) -> str {
    return (date.fromisoformat(origin) + timedelta(days=day_num)).isoformat();
}

def compute_forecast(house: House, today: str, what_if: WhatIf) -> dict {
    items = elements(house);
    pace_total: float = 0.0;
    pace_count: int = 0;
    overrun_total: float = 0.0;
    overrun_count: int = 0;
    for el in items {
        if el.actual_end != "" {
            planned_days = day_number(el.planned_end, el.planned_start);
            actual_days = day_number(el.actual_end, el.actual_start);
            if planned_days > 0 {
                pace_total += actual_days / planned_days;
                pace_count += 1;
            }
            if el.planned_cost > 0.0 {
                overrun_total += el.actual_cost / el.planned_cost;
                overrun_count += 1;
            }
        }
    }
    pace: float = pace_total / pace_count if pace_count > 0 else 1.0;
    overrun: float = overrun_total / overrun_count if overrun_count > 0 else 1.0;
    today_day = day_number(today, house.start_date);
    est_end: dict[str, int] = {};
    remaining: dict[str, float] = {};
    planned_finish_day: int = -999999;
    for el in items {
        planned_days = day_number(el.planned_end, el.planned_start);
        planned_end_day = day_number(el.planned_end, house.start_date);
        if planned_end_day > planned_finish_day { planned_finish_day = planned_end_day; }
        if el.actual_end != "" {
            est_end[el.name] = day_number(el.actual_end, house.start_date);
            remaining[el.name] = 0.0;
        } else {
            rem = planned_days * (1.0 - el.percent_complete / 100.0) * pace;
            if el.actual_start == "" { rem = planned_days * pace; }
            if what_if.delay_element == "" or what_if.delay_element.lower() == el.name.lower() {
                rem += what_if.delay_days;
            }
            remaining[el.name] = rem;
            est_end[el.name] = today_day + int(rem);
        }
    }

    for iteration in range(0, len(items) + 1) {
        changed = False;
        for el in items {
            if el.actual_end == "" {
                start_day = today_day;
                for prereq in [el ->:depends_on:->][?:Element] {
                    if est_end[prereq.name] > start_day { start_day = est_end[prereq.name]; }
                }
                new_end = start_day + int(remaining[el.name]);
                if new_end != est_end[el.name] { est_end[el.name] = new_end; changed = True; }
            }
        }
        if not changed { break; }
    }

    finish_day: int = -999999;
    final_el: Element | None = None;
    for el in items {
        if est_end[el.name] > finish_day {
            finish_day = est_end[el.name];
            final_el = el;
        }
    }
    critical_path: list[str] = [];
    if items {
        current: Element = items[0];
        for el in items {
            if est_end[el.name] == finish_day { current = el; }
        }
        active: bool = True;
        while active {
            critical_path.insert(0, current.name);
            prerequisites = [current ->:depends_on:->][?:Element];
            if prerequisites {
                latest = prerequisites[0];
                for prerequisite in prerequisites {
                    if est_end[prerequisite.name] > est_end[latest.name] { latest = prerequisite; }
                }
                current = latest;
            } else { active = False; }
        }
    }

    spent: float = 0.0;
    cost_to_complete: float = 0.0;
    for el in items {
        spent += el.actual_cost;
        rem_cost = el.planned_cost * (1.0 - el.percent_complete / 100.0) * overrun;
        for (material, pct) in what_if.material_price.items() {
            if material in el.material_shares {
                rem_cost += rem_cost * el.material_shares[material] * pct;
            }
        }
        cost_to_complete += rem_cost;
    }
    projected_total = spent + cost_to_complete;
    over_budget = projected_total - house.total_budget;
    slip_days = finish_day - planned_finish_day;
    return {"finish_date": iso_day(finish_day, house.start_date), "planned_finish_date": iso_day(planned_finish_day, house.start_date), "slip_days": slip_days, "pace": round(pace, 2), "cost_to_complete": round(cost_to_complete, 2), "projected_total": round(projected_total, 2), "over_budget": round(over_budget, 2), "critical_path": critical_path};
}

walker:pub forecast {
    has today: str = "2026-09-18";

    can run with Root entry {
        houses = [root -->][?:House];
        house = houses[0] if houses else seed_house();
        result = compute_forecast(house, self.today, WhatIf());
        report result;
        if result["slip_days"] > 14 or result["over_budget"] > 0.0 {
            note = Activity(actor="forecaster", kind="forecast", text=f"At this pace: done {result['finish_date']}, Rs. {result['over_budget']} over budget");
            house +>:Has():+> note;
        }
    }
}

test "forecast finishes late and identifies critical path" {
    house = seed_house();
    result = compute_forecast(house, "2026-09-18", WhatIf());
    assert result["finish_date"] > "2026-11-30";
    assert result["slip_days"] > 0;
    assert "Slab" in result["critical_path"];
    assert "Roof" in result["critical_path"];
    assert "Tiling" in result["critical_path"];
}

test "material prices increase projected total" {
    house = seed_house();
    baseline = compute_forecast(house, "2026-09-18", WhatIf());
    increased = compute_forecast(house, "2026-09-18", WhatIf(material_price={"cement": 0.15}));
    assert increased["projected_total"] > baseline["projected_total"];
}

test "delay scenario pushes out finish" {
    house = seed_house();
    baseline = compute_forecast(house, "2026-09-18", WhatIf());
    delayed = compute_forecast(house, "2026-09-18", WhatIf(delay_days=21, delay_element="Slab"));
    assert delayed["finish_date"] > baseline["finish_date"];
}
