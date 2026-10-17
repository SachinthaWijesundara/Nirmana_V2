"""Money vs work: what was paid against what is verified built, and the gap Payment Guard protects."""
import from .Icon { Icon }
import from .fmt { rs }
sv import from ui.api { MoneyView }

def bar_width(part: float, whole: float) -> str {
    if whole <= 0.0 {
        return "0%";
    }
    return f"{min(100.0, part * 100.0 / whole):.1f}%";
}

def:pub MoneyBar(label: str, amount: float, budget: float, color: str) -> JsxElement {
    return <div style={{"marginTop": "18px"}}>
        <div className="between small">
            <span className="muted">{label}</span>
            <span className="strong">{rs(amount)}</span>
        </div>
        <div className="bar" role="meter" aria-label={label} aria-valuenow={round(amount)} aria-valuemin={0} aria-valuemax={round(budget)}>
            <span style={{"width": bar_width(amount, budget), "background": color}}></span>
        </div>
    </div>;
}

def:pub MoneyVsWork(money: MoneyView, onOpenGuard: Callable[[], None]) -> JsxElement {
    return <section className="card" aria-label="Money vs work">
        <h2 className="h3" style={{"fontWeight": "600", "fontSize": "18px"}}>Money vs work</h2>
        <MoneyBar label="Paid to builder" amount={money.paid} budget={money.budget} color="var(--celeste)"/>
        <MoneyBar label="Verified built" amount={money.verified} budget={money.budget} color="var(--midnight)"/>
        {if money.paid_ahead > 0.0 {
            <div key="ahead" className="ahead">
                <div className="small muted">Paid ahead of work</div>
                <div className="h2" style={{"color": "var(--status-delayed)", "margin": "4px 0"}}>{rs(money.paid_ahead)}</div>
                <div className="small muted">Payment Guard holds new requests until this gap closes.</div>
            </div>
        } else {
            <div key="covered" className="ahead" style={{"background": "var(--tint-herb)"}}>
                <div className="small muted">Payments are covered by verified work.</div>
            </div>
        }}
        <button className="btn-outline" onClick={lambda { onOpenGuard(); }}>
            <Icon name="shield-check" size={16}/> Open Payment Guard
        </button>
    </section>;
}
