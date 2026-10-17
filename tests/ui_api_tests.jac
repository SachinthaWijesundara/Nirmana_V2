import from ui.api { get_house_view, send_builder_message }

test "dashboard view seeds the demo house with the demo money numbers" {
    # The test root persists between runs; start from an empty graph so the seed runs again.
    for n in [root -->] {
        del n;
    }
    v = get_house_view();
    assert v.house_name == "Perera House";
    assert v.money.paid == 4200000.0;
    assert v.money.held_count == 1;
    assert v.money.held_amount == 800000.0;
    assert len(v.elements) == 10;
    assert len(v.alerts) == 3;
}

test "builder message moves Slab to 100% and verified built to Rs. 2,592,000" {
    r = send_builder_message("slab eka iwarai, cement bag 40k gaththa");
    assert r.ok;
    assert r.element == "Slab";
    assert r.before_percent == 60.0;
    assert r.after_percent == 100.0;
    assert r.cost_spent == 40000.0;
    v = get_house_view();
    assert v.money.verified == 2592000.0;
    assert v.money.paid_ahead == 1608000.0;
    assert v.alerts[0].agent == "Intake";
}

test "empty or oversized builder messages are rejected before Intake runs" {
    assert not send_builder_message("   ").ok;
    assert not send_builder_message("x" * 1001).ok;
}
