"""P1 tests: Forecaster and Scenario on a test house built here (test data only)."""
import from twin { House, Element, Payment, Has, depends_on }
import from agents.forecast { WhatIf, compute_forecast, forecast }
import from agents.scenario { scenario }

def add_el(house: House, name: str, cost: float, start: str, end: str, pct: float, a_start: str, a_end: str, actual: float, cement: float) -> Element {
    el = Element(name=name, planned_cost=cost, planned_start=start, planned_end=end, percent_complete=pct, verified_pct=pct, actual_start=a_start, actual_end=a_end, actual_cost=actual, material_shares={"cement": cement});
    house +>:Has():+> el;
    return el;
}

def test_house() -> House {
    house = House(name="Test house", total_budget=8000000.0, start_date="2026-03-02");
    root ++> house;
    site = add_el(house, "Site prep", 150000.0, "2026-03-02", "2026-03-16", 100.0, "2026-03-02", "2026-03-18", 150000.0, 0.0);
    foundation = add_el(house, "Foundation", 1100000.0, "2026-03-16", "2026-04-20", 100.0, "2026-03-18", "2026-04-28", 1180000.0, 0.35);
    walls = add_el(house, "Walls", 800000.0, "2026-04-20", "2026-06-29", 100.0, "2026-04-28", "2026-07-20", 800000.0, 0.25);
    slab = add_el(house, "Slab", 1600000.0, "2026-06-29", "2026-08-03", 0.0, "2026-07-21", "", 0.0, 0.35);
    roof = add_el(house, "Roof", 1200000.0, "2026-08-03", "2026-09-14", 0.0, "", "", 0.0, 0.05);
    tiling = add_el(house, "Tiling", 1000000.0, "2026-10-19", "2026-11-30", 0.0, "", "", 0.0, 0.20);
    foundation +>:depends_on():+> site;
    walls +>:depends_on():+> foundation;
    slab +>:depends_on():+> walls;
    roof +>:depends_on():+> slab;
    tiling +>:depends_on():+> roof;
    house +>:Has():+> Payment(amount=4200000.0);
    return house;
}

test "forecast finishes late and identifies critical path" {
    house = test_house();
    result = compute_forecast(house, "2026-09-18", WhatIf());
    assert str(result["finish_date"]) > "2026-11-30";
    assert int(result["slip_days"]) > 0;
    path = result["critical_path"] as list[str];
    assert "Slab" in path;
    assert "Roof" in path;
    assert "Tiling" in path;
}

test "material prices increase projected total" {
    house = test_house();
    baseline = compute_forecast(house, "2026-09-18", WhatIf());
    increased = compute_forecast(house, "2026-09-18", WhatIf(material_price={"cement": 0.15}));
    assert (increased["projected_total"] as float) > (baseline["projected_total"] as float);
}

test "delay scenario pushes out finish" {
    house = test_house();
    baseline = compute_forecast(house, "2026-09-18", WhatIf());
    delayed = compute_forecast(house, "2026-09-18", WhatIf(delay_days=21, delay_element="Slab"));
    assert str(delayed["finish_date"]) > str(baseline["finish_date"]);
}

test "forecast walker runs on a project" {
    house = test_house();
    res = house spawn forecast(today="2026-09-18");
    assert int(res.reports[0]["slip_days"]) > 0;
}

test "scenario walker never mutates the twin" {
    house = test_house();
    slab = [el for el in [house ->:Has:->][?:Element] if el.name == "Slab"][0];
    payments_before = len([house ->:Has:->][?:Payment]);
    res = house spawn scenario(cement_pct=15.0, delay_days=21, delay_element="Slab", today="2026-09-18");
    answer = res.reports[0];
    assert (answer["diff"]["extra_cost"] as float) > 0.0;
    assert (answer["diff"]["extra_days"] as int) > 0;
    assert slab.percent_complete == 0.0;
    assert len([house ->:Has:->][?:Payment]) == payments_before;
}
