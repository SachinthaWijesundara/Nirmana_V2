"""One building element in the house cross-section, coloured by status."""
sv import from ui.api { ElementView }

def:pub ElementBox(el: ElementView, updated: bool) -> JsxElement {
    cls = "element " + el.status + (" updated" if updated else "");
    return <div className={cls} title={f"{el.name}: {round(el.percent_complete)}% ({el.status})"}>
        <span className="row">
            {el.name}
            {updated and <span className="pill" style={{"background": "var(--tint-marigold)", "fontWeight": "600"}}>
                <span className="dot" style={{"color": "var(--marigold)"}}></span> Updated by Intake · just now
            </span>}
        </span>
        <span>{f"{round(el.percent_complete)}%"}</span>
    </div>;
}
