"""Money at a glance: what was paid against what is actually proven on site."""

import from ..lib.format { rs }

sv import from dashboard_api { MoneyView, PaymentView }

def:pub MoneyPanel(money: MoneyView, payments: list[PaymentView]) -> JsxElement {
    gap = money.paid - money.verified;
    scale: float = max(money.budget, money.paid, money.built, 1.0);
    held_count = len([p for p in payments if p.status == "held"]);

    def bar(label: str, value: float, color: str) -> JsxElement {
        width: float = min(100.0, value * 100.0 / scale);
        return <div key={label} className="line">
            <span>{label}</span>
            <div className="bar"><div style={{"width": f"{width:.1f}%", "background": color}}></div></div>
            <span className="amt">{rs(value)}</span>
        </div>;
    }

    return <section className="card">
        <h2>Money vs. verified work</h2>
        <p className="sub">Verified work is proven by photo. Payment Guard only trusts verified work, never the builder's reported progress.</p>
        <div className="kpis">
            <div className="kpi"><div className="label">Paid to builder</div><div className="value">{rs(money.paid)}</div></div>
            <div className="kpi"><div className="label">Verified built</div><div className="value">{rs(money.verified)}</div></div>
            <div className="kpi"><div className="label">Reported built</div><div className="value">{rs(money.built)}</div></div>
            <div className={"kpi alert" if money.held > 0 else "kpi"}>
                <div className="label">{"Held by Payment Guard (" + str(held_count) + ")"}</div>
                <div className="value">{rs(money.held)}</div>
            </div>
        </div>
        <div className="bars">
            {bar("Budget", money.budget, "#cfe3e6")}
            {bar("Paid", money.paid, "#0f2a43")}
            {bar("Reported built", money.built, "#f4b942")}
            {bar("Verified built", money.verified, "#1d5c63")}
        </div>
        {if gap > 0 {
            <div className="callout bad">Paid is <b>{rs(gap)}</b> ahead of verified work. New payment requests will be held until proof arrives.</div>
        } else {
            <div className="callout ok">Every rupee paid is covered by verified work.</div>
        }}
    </section>;
}
