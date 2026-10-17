"""Intake: paste the builder's message as they wrote it, in English, Sinhala, Tamil or Singlish."""

import from ..lib.format { rs, pct, field_str, field_num }

glob SAMPLES: list[str] = [
    "slab eka iwarai, cement bag 40k gaththa",
    "Roof work started today, 20% done",
    "wahina nisa wada nawaththuwa, plumbing 30%"
];

def:pub BuilderMessage(message: str, busy: bool, result: dict[str, any], onChange: Callable[[str], None], onSend: Callable[[], None]) -> JsxElement {
    return <section className="card">
        <h2>Builder message</h2>
        <p className="sub">Intake reads the message, finds the part of the house it is about and updates the model.</p>
        <div className="chips">
            {for s in SAMPLES {
                <button key={s} className="chip" onClick={lambda -> None { onChange(s); }}>{s}</button>
            }}
        </div>
        <div className="field">
            <textarea value={message} onChange={lambda e: ChangeEvent -> None { onChange(e.target.value); }}/>
        </div>
        <button className="btn" disabled={busy} onClick={lambda -> None { onSend(); }}>{"Reading..." if busy else "Send to Intake"}</button>
        {if result["ok"] {
            <div className="callout ok">
                <b>{field_str(result, "element")}</b>
                {" now " + pct(field_num(result, "percent_complete")) + " reported, " + rs(field_num(result, "actual_cost")) + " spent so far."}
                {result["delay_reason"] and <div>{"Delay reason: " + field_str(result, "delay_reason")}</div>}
                <div style={{"fontSize": "12px", "marginTop": "4px"}}>{"Read as " + field_str(result, "language")}</div>
            </div>
        } elif result["reason"] {
            <div className="callout warn">{"Not applied: " + field_str(result, "reason")}</div>
        }}
    </section>;
}
