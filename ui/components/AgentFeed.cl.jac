"""Agent feed: every AlertView from the twin, newest first. Each agent is a walker."""
import from .Icon { Icon }
sv import from ui.api { AlertView }

glob AGENT_ICON: dict[str, str] = {
    "Intake": "sparkle", "Payment Guard": "shield-check", "Forecaster": "trend", "Delay Detector": "cloud"
};

def:pub AgentFeed(alerts: list[AlertView]) -> JsxElement {
    return <section aria-label="Agent feed">
        <div className="between">
            <h2 className="h3" style={{"fontWeight": "600", "fontSize": "17px"}}>Agent feed</h2>
            <span className="small muted">Each agent is a walker</span>
        </div>
        {if len(alerts) == 0 {
            <p key="empty" className="small muted">No agent activity yet.</p>
            skip;
        }}
        <ul style={{"listStyle": "none", "padding": "0", "margin": "6px 0 0"}}>
            {for (i, a) in enumerate(alerts) {
                <li key={str(i)} className="feed-item">
                    <span className={"feed-icon tone-" + a.tone}><Icon name={AGENT_ICON[a.agent] if a.agent in AGENT_ICON else "alert"} size={16}/></span>
                    <div style={{"flex": "1"}}>
                        <div className="between">
                            <span className="h3" style={{"fontWeight": "600", "fontSize": "15px"}}>{a.agent}</span>
                            <span className="small muted">{a.when}</span>
                        </div>
                        <div className="small muted" style={{"marginTop": "4px", "fontSize": "13px"}}>{a.text}</div>
                    </div>
                </li>
            }}
        </ul>
    </section>;
}
