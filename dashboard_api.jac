"""Read-only view of the twin for the dashboard, as typed objects so the client gets real fields.
Unlike the forecast walker it never writes Activity nodes, so reloading the page doesn't fill the feed."""
import from twin { House, Element, Payment, Activity, Has, depends_on, elements, money_summary, seed_house }
import from agents.forecast { WhatIf, compute_forecast }

obj ElementView {
    has name: str,
        kind: str,
        planned_cost: float,
        actual_cost: float,
        percent_complete: float,
        verified_pct: float,
        planned_start: str,
        planned_end: str,
        depends_on: list[str];
}

obj PaymentView {
    has amount: float,
        status: str,
        date: str,
        note: str;
}

obj ActivityView {
    has actor: str,
        kind: str,
        text: str;
}

obj MoneyView {
    has paid: float,
        held: float,
        built: float,
        verified: float,
        budget: float;
}

obj ForecastView {
    has finish_date: str,
        planned_finish_date: str,
        slip_days: int,
        pace: float,
        over_budget: float,
        critical_path: list[str];
}

obj DashboardView {
    has house_name: str,
        start_date: str,
        today: str,
        money: MoneyView,
        forecast: ForecastView,
        elements: list[ElementView] = [],
        payments: list[PaymentView] = [],
        activities: list[ActivityView] = [];
}

def to_forecast_view(f: dict[str, any]) -> ForecastView {
    return ForecastView(
        finish_date=f["finish_date"] as str,
        planned_finish_date=f["planned_finish_date"] as str,
        slip_days=f["slip_days"] as int,
        pace=f["pace"] as float,
        over_budget=f["over_budget"] as float,
        critical_path=f["critical_path"] as list[str]
    );
}

def build_view(house: House, today: str) -> DashboardView {
    m = money_summary(house);
    view = DashboardView(
        house_name=house.name,
        start_date=house.start_date,
        today=today,
        money=MoneyView(paid=m["paid"], held=m["held"], built=m["built"], verified=m["verified"], budget=m["budget"]),
        forecast=to_forecast_view(compute_forecast(house, today, WhatIf()))
    );
    for el in elements(house) {
        deps = [d.name for d in [el ->:depends_on:->][?:Element]];
        view.elements.append(ElementView(
            name=el.name, kind=el.kind, planned_cost=el.planned_cost, actual_cost=el.actual_cost,
            percent_complete=el.percent_complete, verified_pct=el.verified_pct,
            planned_start=el.planned_start, planned_end=el.planned_end, depends_on=deps
        ));
    }
    for p in [house ->:Has:->][?:Payment] {
        view.payments.append(PaymentView(amount=p.amount, status=p.status.value, date=p.date, note=p.note));
    }
    for a in [house ->:Has:->][?:Activity] {
        view.activities.append(ActivityView(actor=a.actor, kind=a.kind, text=a.text));
    }
    return view;
}

walker:pub dashboard_view {
    has today: str = "2026-09-18",
        reports: list[DashboardView] = [];

    can run with Root entry {
        houses = [root -->][?:House];
        house = houses[0] if houses else seed_house();
        report build_view(house, self.today);
    }
}

test "dashboard view matches the seed house and writes nothing" {
    house = seed_house();
    before = len([house -->]);
    view = build_view(house, "2026-09-18");
    assert len(view.elements) == 10;
    assert view.money.paid == 4200000.0;
    assert view.money.verified == 2600000.0;
    assert view.forecast.slip_days > 0;
    assert "Slab" in view.forecast.critical_path;
    assert len([house -->]) == before;
}
