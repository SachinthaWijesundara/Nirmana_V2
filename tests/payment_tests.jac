import from mock.twin { House, Element, Payment, PaymentStatus, Has, Activity }
import from agents.payment { assess, verified_value, totals, PaymentGuard, ReleaseOnProof }
import from agents.intake { Intake }

def demo_house() -> House {
    # Foundation 1.5M verified 100% = 1.5M; Walls 2.5M verified 44% = 1.1M; Slab reported 80% but not verified. Verified = 2.6M. Paid = 4.2M.
    house = (root ++> House(name="Nimal house", total_budget=10000000.0))[0];
    house +>:Has():+> Element(name="Foundation", planned_cost=1500000.0, percent_complete=100.0, verified_pct=100.0);
    house +>:Has():+> Element(name="Walls", planned_cost=2500000.0, percent_complete=44.0, verified_pct=44.0);
    house +>:Has():+> Element(name="Slab", planned_cost=3000000.0, percent_complete=80.0, verified_pct=0.0);
    house +>:Has():+> Payment(amount=4200000.0, status=PaymentStatus.PAID);
    return house;
}

test "verified_value is planned cost times percent" {
    assert verified_value(2500000.0, 44.0) == 1100000.0;
    assert verified_value(100.0, 0.0) == 0.0;
}

test "assess approves a request inside verified value" {
    # allowed total = 2.6M * 1.1 = 2.86M; paid 1M; headroom 1.86M >= 500k
    d = assess(1000000.0, 2600000.0, 500000.0);
    assert d.verdict == "approve";
    assert d.release_now == 500000.0;
}

test "assess holds when paid is already ahead of work" {
    d = assess(4200000.0, 2600000.0, 800000.0);
    assert d.verdict == "hold";
    assert d.hold == 800000.0;
    assert d.release_now == 0.0;
}

test "assess releases part when headroom is smaller than the request" {
    # headroom = 2.86M - 2.5M = 360k, request 800k -> release 360k, hold 440k
    d = assess(2500000.0, 2600000.0, 800000.0);
    assert d.verdict == "partial";
    assert abs(d.release_now - 360000.0) < 0.01;
    assert abs(d.hold - 440000.0) < 0.01;
}

test "totals sums paid and verified" {
    h = demo_house();
    t = totals(h);
    assert t["paid"] == 4200000.0;
    assert t["verified"] == 2600000.0;
}

test "PaymentGuard holds the 800k request and logs an Activity" {
    h = demo_house();
    res = h spawn PaymentGuard(request_amount=800000.0, note="slab advance");
    assert res.reports[0]["verdict"] == "hold";
    held = [p for p in [h ->:Has:->[?:Payment]] if p.status == PaymentStatus.HELD];
    assert len(held) == 1;
    assert held[0].amount == 800000.0;
    assert len([h ->:Has:->[?:Activity]]) == 1;
    assert totals(h)["paid"] == 4200000.0;
}

test "ReleaseOnProof releases the held payment once proof raises verified value" {
    h = demo_house();
    _ = h spawn PaymentGuard(request_amount=800000.0, note="slab advance");
    # Walls 80% -> verified 1.5M + 2.0M = 3.5M; allowed 3.85M; paid 4.2M -> still no headroom.
    r1 = h spawn ReleaseOnProof(element_name="Walls", verified_percent=80.0);
    assert r1.reports[0]["released"] == 0.0;
    # Slab 50% -> +1.5M, verified 5.0M; allowed 5.5M; headroom 1.3M >= 800k -> full release.
    r2 = h spawn ReleaseOnProof(element_name="Slab", verified_percent=50.0);
    assert r2.reports[0]["released"] == 800000.0;
    held = [p for p in [h ->:Has:->[?:Payment]] if p.status == PaymentStatus.HELD];
    assert len(held) == 0;
    assert totals(h)["paid"] == 5000000.0;
}

test "ReleaseOnProof rejects an unknown element" {
    h = demo_house();
    r = h spawn ReleaseOnProof(element_name="Roof", verified_percent=10.0);
    assert not r.reports[0]["ok"];
}

test "builder-reported progress does not count as verified" {
    h = demo_house();
    slab = [e for e in [h ->:Has:->[?:Element]] if e.name == "Slab"][0];
    slab.percent_complete = 100.0;
    assert totals(h)["verified"] == 2600000.0;
}

test "demo order: Intake marks the slab done, Payment Guard still holds the 800k (mock LLM)" {
    h = demo_house();
    r0 = h spawn Intake(message="slab eka iwarai, cement bag 40k gaththa");
    assert r0.reports[0]["ok"];
    slab = [e for e in [h ->:Has:->[?:Element]] if e.name == "Slab"][0];
    assert slab.percent_complete == 100.0;
    assert slab.verified_pct == 0.0;
    r1 = h spawn PaymentGuard(request_amount=800000.0, note="slab advance");
    assert r1.reports[0]["verdict"] == "hold";
    assert r1.reports[0]["verified"] == 2600000.0;
    # The slab photo is the proof: verified 5.6M, allowed 6.16M, paid 4.2M -> the full 800k is released.
    r2 = h spawn ReleaseOnProof(element_name="Slab", verified_percent=100.0);
    assert r2.reports[0]["released"] == 800000.0;
    assert slab.verified_pct == 100.0;
}

test "ReleaseOnProof never lowers verified progress" {
    h = demo_house();
    _ = h spawn ReleaseOnProof(element_name="Foundation", verified_percent=50.0);
    f = [e for e in [h ->:Has:->[?:Element]] if e.name == "Foundation"][0];
    assert f.verified_pct == 100.0;
}
