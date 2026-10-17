"""Builder update box: the text stand-in for the builder's WhatsApp message."""
import from .Icon { Icon }
import from .fmt { cap }

def:pub MessageBox(
    message: str,
    language: str,
    sending: bool,
    onChange: Callable[[str], None],
    onSend: Callable[[], None]
) -> JsxElement {
    def handle_key(e: KeyboardEvent) {
        if e.key == "Enter" and (e.ctrlKey or e.metaKey) {
            e.preventDefault();
            onSend();
        }
    }
    can_send = not sending and message.strip() != "";
    return <section aria-label="Builder update">
        <div className="between" style={{"marginBottom": "14px"}}>
            <h2 className="h3" style={{"fontWeight": "600", "fontSize": "17px"}}>Builder update</h2>
            <span className="pill" style={{"background": "var(--tint-midnight)", "color": "var(--midnight)"}}>
                <span className="dot"></span> stand-in for WhatsApp
            </span>
        </div>
        <div className="update-box">
            <div className="row small muted"><span className="avatar-sm">RS</span> Ruwan Silva (baas)</div>
            <label className="small muted" htmlFor="builder-message">Message from the builder</label>
            <textarea id="builder-message" value={message} rows={2} maxLength={1000} disabled={sending}
                placeholder="e.g. slab eka iwarai, cement bag 40k gaththa"
                onChange={lambda e: ChangeEvent { onChange(e.target.value); }}
                onKeyDown={handle_key}></textarea>
            <div className="row small muted">
                {language != "" and <span className="pill" style={{"background": "var(--tint-herb)", "color": "var(--text-primary)"}}>
                    <span className="dot" style={{"color": "var(--herb)"}}></span>{cap(language)}
                </span>}
                <span>{"also Sinhala, Tamil, English" if language != "" else "Sinhala, Tamil, English or Singlish"}</span>
            </div>
            <button className="btn-primary" disabled={not can_send} onClick={lambda { onSend(); }}>
                <Icon name="chat" size={16}/> {"Sending to twin…" if sending else "Send to twin"}
            </button>
        </div>
    </section>;
}
