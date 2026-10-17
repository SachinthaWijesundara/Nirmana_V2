"""What the Intake walker understood from the last builder message."""
import from .Icon { Icon }
import from .fmt { rs, cap, join_parts }
sv import from ui.api { IntakeResult }

def:pub IntakeRow(label: str, value: str) -> JsxElement {
    return <div className="kv">
        <span className="muted">{label}</span>
        <span className="strong">{value}</span>
    </div>;
}

def:pub IntakeCard(result: IntakeResult | None, sending: bool, error: str) -> JsxElement {
    return <section className="intake" aria-label="Intake result" aria-live="polite">
        <div className="between">
            <span className="row h3" style={{"fontWeight": "600", "fontSize": "15px"}}>
                <span style={{"color": "var(--herb)"}}><Icon name="sparkle" size={16}/></span> Intake walker · by llm()
            </span>
            {result is not None and result.ok and not sending and
                <span className="row small strong"><span className="dot" style={{"color": "var(--herb)"}}></span>{f"{round(result.confidence * 100.0)}% sure"}</span>}
        </div>
        {if sending {
            <p key="sending" className="small muted" style={{"margin": "0"}}>Intake is reading the message…</p>
        } elif error != "" {
            <p key="error" className="small error" role="alert" style={{"margin": "0"}}>{error}</p>
        } elif result is None {
            <p key="empty" className="small muted" style={{"margin": "0"}}>Send a builder update to see what Intake understood.</p>
        } elif not result.ok {
            <p key="rejected" className="small error" role="alert" style={{"margin": "0"}}>{result.reason}</p>
        } else {
            <IntakeRow key="element" label="Element" value={f"{result.element}: {round(result.before_percent)}% → {round(result.after_percent)}%"}/>
            <IntakeRow key="expense" label="Expense" value={f"{cap(result.material)} · {rs(result.cost_spent)}" if result.cost_spent > 0.0 else "None mentioned"}/>
            <IntakeRow key="path" label="Attached to" value={join_parts(result.attached_to, " › ")}/>
            <IntakeRow key="meaning" label="Meaning" value={f"\"{result.meaning}\""}/>
        }}
    </section>;
}
