"""Forecast, what-if scenarios and the delay detector."""

import from ..lib.format { rs, nice_date, field_str, field_num }

sv import from dashboard_api { ForecastView }

def:pub CriticalPath(steps: list[str]) -> JsxElement {
    return <div className="path">
        {for (i, s) in enumerate(steps) {
            <span key={s} className="step">{s}</span>
            if i < len(steps) - 1 { <span key={s + "-arrow"}>{"→"}</span> }
        }}
    </div>;
}

def:pub ForecastPanel(
    forecast: ForecastView, names: list[str], cementPct: str, delayDays: str, delayElement: str,
    whatIf: dict[str, any], delays: list[any], delayChecked: bool, busy: str,
    onCement: Callable[[str], None], onDelayDays: Callable[[str], None], onDelayElement: Callable[[str], None],
    onScenario: Callable[[], None], onDelayCheck: Callable[[], None]
) -> JsxElement {
    late = forecast.slip_days > 14;
    over = forecast.over_budget > 0;
    diff: dict[str, any] = whatIf["diff"] as dict[str, any] if whatIf["diff"] else {};
    alt: dict[str, any] = whatIf["what_if"] as dict[str, any] if whatIf["what_if"] else {};
    extra_cost = field_num(diff, "extra_cost");
    extra_days = field_num(diff, "extra_days");
    return <section className="card">
        <h2>Forecast</h2>
        <p className="sub">{"Walks the dependency graph from today at the pace the builder has actually kept (" + f"{forecast.pace:.2f}" + "x the plan)."}</p>
        <div className="kpis">
            <div className={"kpi alert" if late else "kpi"}><div className="label">Expected finish</div><div className="value">{nice_date(forecast.finish_date)}</div></div>
            <div className="kpi"><div className="label">Planned finish</div><div className="value">{nice_date(forecast.planned_finish_date)}</div></div>
            <div className={"kpi alert" if late else "kpi"}><div className="label">Slip</div><div className="value">{str(forecast.slip_days) + " days"}</div></div>
            <div className={"kpi alert" if over else "kpi"}><div className="label">{"Over budget" if over else "Under budget"}</div><div className="value">{rs(abs(forecast.over_budget))}</div></div>
        </div>
        <p className="sub" style={{"margin": "12px 0 6px"}}>Critical path</p>
        <CriticalPath steps={forecast.critical_path}/>

        <h2 style={{"marginTop": "22px"}}>What if?</h2>
        <p className="sub">Runs the same forecast with changes. The real house model is never touched.</p>
        <div className="inline">
            <div className="field"><label>Cement price change (%)</label>
                <input type="number" value={cementPct} onChange={lambda e: ChangeEvent -> None { onCement(e.target.value); }}/></div>
            <div className="field"><label>Delay (days)</label>
                <input type="number" min="0" value={delayDays} onChange={lambda e: ChangeEvent -> None { onDelayDays(e.target.value); }}/></div>
            <div className="field"><label>Delayed element</label>
                <select value={delayElement} onChange={lambda e: ChangeEvent -> None { onDelayElement(e.target.value); }}>
                    <option value="">All unfinished work</option>
                    {for n in names { <option key={n} value={n}>{n}</option> }}
                </select></div>
        </div>
        <button className="btn" disabled={busy != ""} onClick={lambda -> None { onScenario(); }}>{"Running..." if busy == "scenario" else "Run scenario"}</button>
        {if diff["finish_date_change"] {
            <div className="compare">
                <div className="kpi"><div className="label">Finish</div><div className="value" style={{"fontSize": "16px"}}>{nice_date(field_str(alt, "finish_date"))}</div></div>
                <div className={"kpi alert" if extra_cost > 0 else "kpi"}><div className="label">Extra cost</div><div className="value" style={{"fontSize": "16px"}}>{rs(extra_cost)}</div></div>
                <div className={"kpi alert" if extra_days > 0 else "kpi"}><div className="label">Extra days</div><div className="value" style={{"fontSize": "16px"}}>{f"{extra_days:.0f}"}</div></div>
            </div>
            <CriticalPath steps={alt["critical_path"] as list[str]}/>
        }}

        <h2 style={{"marginTop": "22px"}}>Delay check</h2>
        <p className="sub">Finds late work and traces it back through the dependencies to the real cause: a dated record that is fair to the builder.</p>
        <button className="btn ghost" disabled={busy != ""} onClick={lambda -> None { onDelayCheck(); }}>{"Checking..." if busy == "delay" else "Run delay check"}</button>
        {for d in delays {
            row = d as dict[str, any];
            <div key={field_str(row, "element")} className="callout warn">
                <b>{field_str(row, "element") + ": " + f"{field_num(row, 'days_behind'):.0f}" + " days behind."}</b>
                {" Root cause: " + field_str(row, "root_cause")}
            </div>
        }}
        {delayChecked and len(delays) == 0 and <div className="callout info">No new delay notices for today (nothing late, or already recorded).</div>}
    </section>;
}
