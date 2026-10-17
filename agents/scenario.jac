import from twin { House, Element, Payment, Activity, Has, seed_house }
import from agents.forecast { WhatIf, compute_forecast }

walker:pub scenario {
    has cement_pct: float = 0.0;
    has delay_days: int = 0;
    has delay_element: str = "";
    has today: str = "2026-09-18";

    can run with Root entry {
        houses = [root -->][?:House];
        house = houses[0] if houses else seed_house();
        base = compute_forecast(house, self.today, WhatIf());
        prices: dict[str, float] = {};
        if self.cement_pct > 0.0 { prices["cement"] = self.cement_pct / 100.0; }
        what_if = compute_forecast(house, self.today, WhatIf(material_price=prices, delay_days=self.delay_days, delay_element=self.delay_element));
        extra_cost = what_if["projected_total"] - base["projected_total"];
        extra_days = what_if["slip_days"] - base["slip_days"];
        change = f"{base['finish_date']} -> {what_if['finish_date']}";
        impact = "";
        if self.cement_pct > 0.0 { impact = f"cement +{self.cement_pct}%"; }
        if self.delay_days > 0 {
            if impact != "" { impact = impact + " and "; }
            if self.delay_element == "" { impact = impact + f"all work delayed {self.delay_days} days"; }
            else { impact = impact + f"{self.delay_element} is delayed {self.delay_days} days"; }
        }
        if impact == "" { impact = "no changes"; }
        summary = f"What if {impact}: finish moves {change}, Rs. {extra_cost} more.";
        diff = {"extra_cost": extra_cost, "extra_days": extra_days, "finish_date_change": change};
        activity = Activity(actor="scenario", kind="what_if", text=summary);
        house +>:Has():+> activity;
        report {"base": base, "what_if": what_if, "diff": diff, "summary": summary};
    }
}

test "cement scenario increases cost without changing days" {
    seed_house();
    result = root spawn scenario(cement_pct=15.0);
    answer = result.reports[0];
    assert answer["diff"]["extra_cost"] > 0.0;
    assert answer["diff"]["extra_days"] == 0;
}

test "slab delay scenario increases slip" {
    seed_house();
    result = root spawn scenario(delay_days=21, delay_element="Slab");
    answer = result.reports[0];
    assert answer["diff"]["extra_days"] > 0;
}

test "scenario does not mutate elements or payments" {
    house = seed_house();
    slab = [el for el in [house ->:Has:->][?:Element] if el.name == "Slab"][0];
    original_percent = slab.percent_complete;
    original_payments = len([house ->:Has:->][?:Payment]);
    _result = root spawn scenario(cement_pct=15.0, delay_days=21, delay_element="Slab");
    assert slab.percent_complete == original_percent;
    assert len([house ->:Has:->][?:Payment]) == original_payments;
}
