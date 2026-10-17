"""Payment Guard: the builder asks for money, the guard decides with fixed rules (never the AI)."""

import from ..lib.format { field_str, field_num }

glob VERDICT_STYLE: dict[str, str] = {"approve": "ok", "partial": "warn", "hold": "bad", "error": "bad"};

def:pub PaymentRequest(
    amount: str, note: str, busy: bool, result: dict[str, any], proof: dict[str, any],
    onAmount: Callable[[str], None], onNote: Callable[[str], None], onRequest: Callable[[], None]
) -> JsxElement {
    verdict = field_str(result, "verdict");
    return <section className="card">
        <h2>Payment request</h2>
        <p className="sub">Allowed total is verified built value plus a 10% advance. Anything above that is held until proof arrives.</p>
        <div className="field">
            <label>Amount requested (Rs.)</label>
            <input type="number" min="0" step="10000" value={amount} onChange={lambda e: ChangeEvent -> None { onAmount(e.target.value); }}/>
        </div>
        <div className="field">
            <label>Note</label>
            <input value={note} onChange={lambda e: ChangeEvent -> None { onNote(e.target.value); }}/>
        </div>
        <button className="btn" disabled={busy} onClick={lambda -> None { onRequest(); }}>{"Checking..." if busy else "Ask Payment Guard"}</button>
        {verdict and <div className={"callout " + VERDICT_STYLE[verdict]}>
            <b>{verdict.upper()}</b>{" " + field_str(result, "message")}
        </div>}
        {proof["message"] and <div className={"callout ok" if field_num(proof, "released") > 0 else "callout info"}>{field_str(proof, "message")}</div>}
    </section>;
}
