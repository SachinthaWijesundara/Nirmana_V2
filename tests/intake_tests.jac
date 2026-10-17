import from twin { House, Element, Has, Update, Activity, depends_on }
import from agents.intake { ParsedUpdate, apply_update, commit_update, parse_update, Intake }

def seed_mock_house() -> House {
    house = (root ++> House(name="Nimal's house", total_budget=10000000.0))[0];
    slab = (house +>:Has():+> Element(name="Slab", kind="structure", planned_cost=3000000.0))[0];
    walls = (house +>:Has():+> Element(name="Walls", kind="structure", planned_cost=2500000.0))[0];
    foundation = (house +>:Has():+> Element(name="Foundation", kind="structure", planned_cost=1500000.0, percent_complete=100.0, verified_pct=100.0))[0];
    slab +>:depends_on():+> foundation;
    walls +>:depends_on():+> slab;
    return house;
}

test "apply_update raises progress and cost, never lowers progress" {
    el = Element(name="Slab", planned_cost=3000000.0, percent_complete=60.0);
    ok = apply_update(el, ParsedUpdate(element_name="Slab", percent_complete=40.0, material="cement", cost_spent=1000.0, delay_reason="", language="english"));
    assert ok;
    assert el.percent_complete == 60.0;
    assert el.actual_cost == 1000.0;
    assert el.materials == ["cement"];
}

test "apply_update rejects out of range percent" {
    el = Element(name="Slab");
    assert not apply_update(el, ParsedUpdate(element_name="Slab", percent_complete=140.0, material="", cost_spent=0.0, delay_reason="", language="english"));
}

test "parse_update returns a typed ParsedUpdate (mock LLM)" {
    p = parse_update("slab eka iwarai, cement 40k gaththa", ["Slab", "Walls"]);
    assert p.element_name == "Slab";
    assert p.cost_spent == 40000.0;
}

test "commit_update writes progress, an Update node and an Activity" {
    house = seed_mock_house();
    parsed = ParsedUpdate(element_name="slab", percent_complete=100.0, material="cement", cost_spent=40000.0, delay_reason="", language="singlish");
    r = commit_update(house, "slab eka iwarai, cement 40k gaththa", parsed);
    assert r["ok"];
    assert r["element"] == "Slab";
    slab = [e for e in [house ->:Has:->[?:Element]] if e.name == "Slab"][0];
    assert slab.percent_complete == 100.0;
    assert slab.actual_cost == 40000.0;
    assert len([house ->:Has:->[?:Update]]) == 1;
    assert len([house ->:Has:->[?:Activity]]) == 1;
}

test "commit_update reports no match for an unknown element" {
    house = seed_mock_house();
    parsed = ParsedUpdate(element_name="Roof", percent_complete=10.0, material="", cost_spent=0.0, delay_reason="", language="english");
    assert not commit_update(house, "roof started", parsed)["ok"];
}

test "Intake walker end to end (mock LLM): message to updated Slab" {
    house = seed_mock_house();
    res = house spawn Intake(message="slab eka iwarai, cement 40k gaththa");
    assert res.reports[0]["ok"];
    assert res.reports[0]["percent_complete"] == 100.0;
}
