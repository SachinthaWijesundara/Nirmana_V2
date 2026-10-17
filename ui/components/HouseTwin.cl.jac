"""House twin: the building as a cross-section, finishes on top, foundation at the bottom."""
import from .ElementBox { ElementBox }
sv import from ui.api { ElementView }

glob LEGEND: list[tuple[str, str]] = [
    ("Done", "var(--status-done)"), ("In progress", "var(--status-progress)"),
    ("Late", "var(--status-delayed)"), ("Not started", "var(--status-idle)")
];

"""Elements grouped by row, top to bottom. Rows with no elements are dropped."""
def rows_of(elements: list[ElementView]) -> list[list[ElementView]] {
    rows: list[list[ElementView]] = [];
    for r in range(7) {
        row = [e for e in elements if e.row == r];
        if len(row) > 0 {
            rows.append(row);
        }
    }
    return rows;
}

def:pub HouseTwin(elements: list[ElementView], updatedElement: str) -> JsxElement {
    return <section className="card" aria-label="House twin">
        <div className="between">
            <h2 className="h3" style={{"fontWeight": "600", "fontSize": "18px"}}>House twin</h2>
            <span className="pill" style={{"background": "var(--tint-herb)", "color": "var(--text-primary)"}}>
                <span className="dot" style={{"color": "var(--herb)"}}></span> Live
            </span>
        </div>
        <div className="twin-rows">
            {for (i, row) in enumerate(rows_of(elements)) {
                <div key={str(i)} className={"twin-row roof" if row[0].name == "Roof" else "twin-row"}>
                    {for el in row {
                        <ElementBox key={el.name} el={el} updated={el.name == updatedElement}/>
                    }}
                </div>
            }}
        </div>
        <div className="legend">
            {for (label, color) in LEGEND {
                <span key={label} className="row"><span className="dot" style={{"color": color}}></span>{label}</span>
            }}
        </div>
    </section>;
}
