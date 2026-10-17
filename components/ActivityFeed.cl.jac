"""What each agent did, newest first: a timestamped record for both owner and builder."""

sv import from dashboard_api { ActivityView }

glob ACTORS: dict[str, list[str]] = {
    "builder": ["Intake", "info"],
    "payment_guard": ["Payment Guard", "bad"],
    "delay_detector": ["Delay Detector", "warn"],
    "forecaster": ["Forecaster", "muted"],
    "scenario": ["What-if", "muted"]
};

def:pub ActivityFeed(activities: list[ActivityView]) -> JsxElement {
    count = len(activities);
    newest: list[ActivityView] = [activities[count - 1 - i] for i in range(count)];
    return <section className="card">
        <h2>Agent activity</h2>
        <p className="sub">Everything the agents have done to the house model, newest first.</p>
        <div className="feed">
            {if count == 0 {
                <div key="empty" className="empty">Nothing yet. Send a builder message or a payment request.</div>
                skip;
            }}
            {for (i, a) in enumerate(newest) {
                actor: list[str] = ACTORS[a.actor] if ACTORS[a.actor] else [a.actor, "muted"];
                <div key={str(count - i)} className="item">
                    <span className={"badge " + actor[1]}>{actor[0]}</span>
                    <div className="text">{a.text}</div>
                </div>
            }}
        </div>
    </section>;
}
