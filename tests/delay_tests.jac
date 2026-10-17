import from mock.twin { House, Element, DelayNotice, Activity, Has, depends_on }
import from agents.delay { days_behind, cause_chain, DelayDetector }

def delay_house() -> House {
    # Slab: 2026-08-01..2026-09-10 (40 days), 25% done. On 2026-08-21 (20 days in) expected 50% -> 10 days behind.
    # Walls: depends on Slab, starts 2026-08-11, ends 2026-09-20 (40 days), 0% done; 10 days in -> expected 25% -> 10 days behind.
    house = (root ++> House(name="Nimal house"))[0];
    slab = (house +>:Has():+> Element(name="Slab", planned_start="2026-08-01", planned_end="2026-09-10", percent_complete=25.0))[0];
    walls = (house +>:Has():+> Element(name="Walls", planned_start="2026-08-11", planned_end="2026-09-20", percent_complete=0.0))[0];
    walls +>:depends_on():+> slab;
    return house;
}

test "days_behind: 25 percent done when 50 percent expected is 10 days" {
    assert days_behind("2026-08-01", "2026-09-10", 25.0, "2026-08-21") == 10;
}

test "days_behind is 0 when on schedule, not started, or dates missing" {
    assert days_behind("2026-08-01", "2026-09-10", 60.0, "2026-08-21") == 0;
    assert days_behind("2026-08-01", "2026-09-10", 0.0, "2026-07-20") == 0;
    assert days_behind("", "", 0.0, "2026-08-21") == 0;
}

test "cause_chain traces Walls back to Slab" {
    house = delay_house();
    walls = [e for e in [house ->:Has:->[?:Element]] if e.name == "Walls"][0];
    assert cause_chain(walls, "2026-08-21") == ["Walls", "Slab"];
}

test "DelayDetector writes dated notices with the root cause and logs activity" {
    house = delay_house();
    res = house spawn DelayDetector(today="2026-08-21");
    rows = res.reports[0] as list[dict];
    assert len(rows) == 2;
    walls_report = [r for r in rows if r["element"] == "Walls"][0];
    assert walls_report["root_cause"] == "Slab";
    assert len([house ->:Has:->[?:DelayNotice]]) == 2;
    assert len([house ->:Has:->[?:Activity]]) == 2;
}

test "DelayDetector is idempotent for the same day" {
    house = delay_house();
    _ = house spawn DelayDetector(today="2026-08-21");
    res = house spawn DelayDetector(today="2026-08-21");
    rows = res.reports[0] as list[dict];
    assert len(rows) == 0;
    assert len([house ->:Has:->[?:DelayNotice]]) == 2;
}
