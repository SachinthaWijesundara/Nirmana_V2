import from twin { House, Element, Payment, Activity, Has, today_iso, now_iso }
import from agents.forecast { WhatIf, compute_forecast }

"""Spawn on a House. Replays the forecast with a change; the real twin is never modified."""
walker scenario {
    has cement_pct: float = 0.0;
    has delay_days: int = 0;
    has delay_element: str = "";
    has today: str = "";

    can run with House entry {
        house = here;
        as_of = self.today if self.today != "" else today_iso();
        base = compute_forecast(house, as_of, WhatIf());
        prices: dict[str, float] = {};
        if self.cement_pct > 0.0 { prices["cement"] = self.cement_pct / 100.0; }
        what_if = compute_forecast(house, as_of, WhatIf(material_price=prices, delay_days=self.delay_days, delay_element=self.delay_element));
        what_total: float = what_if["projected_total"] as float;
        base_total: float = base["projected_total"] as float;
        what_slip: int = what_if["slip_days"] as int;
        base_slip: int = base["slip_days"] as int;
        extra_cost: float = what_total - base_total;
        extra_days: int = what_slip - base_slip;
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
        activity = Activity(actor="scenario", kind="what_if", text=summary, role="system", category="progress", at=now_iso());
        house +>:Has():+> activity;
        grant(activity, level=WritePerm);
        report {"base": base, "what_if": what_if, "diff": diff, "summary": summary};
    }
}
