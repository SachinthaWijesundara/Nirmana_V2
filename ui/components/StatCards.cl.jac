"""The four headline cards: paid, verified built, forecast finish, payment held."""
import from .Icon { Icon }
import from .fmt { rs, pct }
sv import from ui.api { MoneyView, ForecastView }

def:pub StatCard(tone: str, icon: str, title: str, value: str, note: str, chip: str = "") -> JsxElement {
    return <article className={"stat " + tone}>
        <div className="between">
            <span className="stat-icon"><Icon name={icon} size={16}/></span>
            {chip != "" and <span className="pill" style={{"background": "var(--bg-surface)", "color": "var(--midnight)"}}>{chip}</span>}
        </div>
        <div className="h3" style={{"marginTop": "14px", "fontWeight": "600"}}>{title}</div>
        <div className="number-xl">{value}</div>
        <div className="note">{note}</div>
    </article>;
}

def:pub StatCards(money: MoneyView, forecast: ForecastView) -> JsxElement {
    held_label = f"{money.held_count} held" if money.held_count > 0 else "Clear";
    held_note = f"{rs(money.held_amount)} request" if money.held_count > 0 else "No requests held";
    return <section className="stats" aria-label="Headline numbers">
        <StatCard tone="paid" icon="wallet" title="Paid to builder" value={rs(money.paid, True)}
            note={f"of {rs(money.budget, True)} budget"} chip={pct(money.paid, money.budget)}/>
        <StatCard tone="verified" icon="check" title="Verified built" value={rs(money.verified, True)}
            note={f"{rs(money.paid_ahead, True)} paid ahead of work"} chip={pct(money.verified, money.budget)}/>
        <StatCard tone="forecast" icon="calendar" title="Forecast finish" value={forecast.finish}
            note={f"{rs(forecast.over_budget)} over budget"}/>
        <StatCard tone="guard" icon="shield-check" title="Payment Guard" value={held_label} note={held_note}/>
    </section>;
}
