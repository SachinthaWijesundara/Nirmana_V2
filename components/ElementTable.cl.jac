"""Every part of the house: reported progress (what the builder says) next to verified progress (what proof shows)."""

import from ..lib.format { rs, nice_date, pct, join_names }

sv import from dashboard_api { ElementView }

"""Status label and badge colour for one element on the demo day."""
def:pub element_status(el: ElementView, today: str) -> list[str] {
    if el.percent_complete >= 100 and el.verified_pct >= 100 {
        return ["Verified", "ok"];
    }
    if el.percent_complete > el.verified_pct {
        return ["Needs proof", "warn"];
    }
    if el.planned_end < today {
        return ["Late", "bad"];
    }
    if el.percent_complete > 0 {
        return ["In progress", "info"];
    }
    return ["Not started", "muted"];
}

def:pub ElementTable(elements: list[ElementView], today: str, busy: str, onVerify: Callable[[str, float], None]) -> JsxElement {
    return <section className="card">
        <h2>House model</h2>
        <p className="sub">Amber is what the builder reported, teal is what photo proof shows. "Verify" records proof, and Payment Guard releases any held money it now covers.</p>
        <div className="table-wrap">
            <table>
                <thead><tr>
                    <th>Element</th><th>Status</th><th>Progress</th><th>Planned</th>
                    <th style={{"textAlign": "right"}}>Planned cost</th><th style={{"textAlign": "right"}}>Spent</th><th></th>
                </tr></thead>
                <tbody>
                    {for el in elements {
                        status = element_status(el, today);
                        <tr key={el.name}>
                            <td>
                                <b>{el.name}</b><br/>
                                <small style={{"color": "#5d6f7c"}}>{"after " + join_names(el.depends_on) if len(el.depends_on) > 0 else el.kind}</small>
                            </td>
                            <td><span className={"badge " + status[1]}>{status[0]}</span></td>
                            <td><div className="progress">
                                <div className="bar"><div style={{"width": pct(el.percent_complete), "background": "#f4b942"}}></div></div>
                                <div className="bar"><div style={{"width": pct(el.verified_pct), "background": "#1d5c63"}}></div></div>
                                <small>{"Reported " + pct(el.percent_complete) + " · Verified " + pct(el.verified_pct)}</small>
                            </div></td>
                            <td style={{"whiteSpace": "nowrap"}}>
                                {nice_date(el.planned_start)}<br/>
                                <small style={{"color": "#5d6f7c"}}>{"to " + nice_date(el.planned_end)}</small>
                            </td>
                            <td className="num">{rs(el.planned_cost)}</td>
                            <td className="num">{rs(el.actual_cost)}</td>
                            <td>{el.percent_complete > el.verified_pct and <button
                                className="btn small"
                                disabled={busy != ""}
                                onClick={lambda -> None { onVerify(el.name, el.percent_complete); }}
                            >{"Verifying..." if busy == "verify:" + el.name else "Verify"}</button>}</td>
                        </tr>
                    }}
                </tbody>
            </table>
        </div>
    </section>;
}
