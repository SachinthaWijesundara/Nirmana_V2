"""01 Dashboard · Client (also shown to the other roles, with the actions they can take)."""

import from "@jac/runtime" { Link, useNavigate }
import from ..components.Icon { Icon }
import from ..components.ui { Btn, Pill, CardHead, Avatar }
import from ..components.Cards { StatCard, AlertCard, MessageRow }
import from ..components.States { Gate }
import from ..components.Shell { Page, Sidebar, TopBar }
import from ..components.House { HouseLayers }
import from ..hooks.app { useApp, useResource }
import from ..lib.roles { allowed, why }

def:pub PaidVerified(months: list[any], ahead: str) -> JsxElement {
    return <div className="card col g16 grow">
        <CardHead title="Paid vs verified" right="Last 6 months" />
        <div className="row g10"><span className="xl">{ahead}</span><Pill label="paid ahead of work" tone="delayed" /></div>
        <div className="row g12 bot">
            {for m in months {
                <div key={m["m"]} className="col g8 grow" style={{"alignItems": "center"}}>
                    <div style={{"position": "relative", "height": 200, "width": 40, "borderRadius": 14, "background": "#f5ead5", "overflow": "hidden"}}>
                        <div style={{"position": "absolute", "bottom": 0, "left": 0, "width": 40, "height": m["paid"], "background": "#bdd3ce", "borderRadius": 14}} />
                        {m["verified"] > 0 and <div style={{"position": "absolute", "bottom": 0, "left": 0, "width": 40, "height": m["verified"], "background": "#013d5a", "borderRadius": 14}} />}
                    </div>
                    <span className="sm t2">{m["m"]}</span>
                </div>
            }}
        </div>
        <div className="row g16">
            <span className="row g6 sm t2"><i style={{"width": 10, "height": 10, "borderRadius": 5, "background": "#bdd3ce", "display": "block"}} />Paid to builder</span>
            <span className="row g6 sm t2"><i style={{"width": 10, "height": 10, "borderRadius": 5, "background": "#013d5a", "display": "block"}} />Verified by architect</span>
        </div>
    </div>;
}

def:pub Dashboard() -> JsxElement {
    app = useApp();
    nav = useNavigate();
    res = useResource("dashboard", {});
    d: any = res["data"];
    role: str = app["role"];
    first: str = str(app["user"]["name"]).split(" ")[0];

    def decide(item: any, decision: str) {
        app["openOverlay"]("confirm", {
            "title": ("Approve " if decision == "approve" else "Reject ") + item["title"] + "?",
            "body": "Change-order decisions are final and logged under your name.",
            "confirm": "Yes, approve" if decision == "approve" else "Yes, reject",
            "run": lambda { app["decide"](item["id"], decision, res["reload"]); }
        });
    }

    right = <div className="col g20" style={{"width": 340, "flexShrink": 0, "background": "#fff", "padding": "32px 24px", "minHeight": "100vh"}}>
        <p className="h3">Alerts</p>
        {d and d["alerts"].map(lambda a: any -> any { return <AlertCard key={a["title"]} level={a["level"]} title={a["title"]} body={a["body"]} />; })}
        <div className="row g8"><p className="h3 grow">Builder messages</p><Link to="/messages" className="sm t2">See all</Link></div>
        {d and d["messages"].map(lambda m: any -> any { return <MessageRow key={m["when"] + m["text"]} name={m["name"]} initials={m["initials"]} tone={m["tone"]} when={m["when"]} text={m["text"]} />; })}
        <div className="row g8 bd r999" style={{"padding": "6px 6px 6px 16px"}}>
            <span className="grow t2">Message the builder…</span>
            <Btn label="Send" onClick={lambda { nav("/messages"); }} />
        </div>
    </div>;

    return <Page title={"Good morning, " + first} subtitle={d["subtitle"] if d else ""} right={right}>
        <Gate res={res} what="dashboard">
            {d and <div className="col g24">
                <div className="row g16 stretch">
                    {for s in d["stats"] {
                        <StatCard key={s["label"]} tone={s["tone"]} icon={s["icon"]} label={s["label"]} value={s["value"]} sub={s["sub"]} delta={s["delta"]} />
                    }}
                </div>
                <div className="row g16 top">
                    <div className="card col g16" style={{"width": 400, "flexShrink": 0}}>
                        <div className="row g8"><p className="h3 grow">House progress</p><Link to="/projects/perera-house/progress" className="sm t2">View →</Link></div>
                        <HouseLayers layers={d["layers"]} />
                    </div>
                    <PaidVerified months={d["months"]} ahead={d["paid_ahead"]} />
                </div>
                <div className="card col g16">
                    <div className="row g8"><p className="h3 grow">Waiting on you</p><Btn label="Open approvals" icon="chevron-right" kind="ghost" onClick={lambda { nav("/approvals"); }} /></div>
                    <div className="col">
                        <div className="thead">
                            <span className="over t2 grow">Item</span><span className="over t2" style={{"width": 130}}>Type</span>
                            <span className="over t2 right" style={{"width": 110}}>Amount</span><span style={{"width": 200}} />
                        </div>
                        {for it in d["waiting"] {
                            <div key={it["id"]} className="trow">
                                <span className="b grow ell">{it["title"] + (" · CO-004" if it["id"] == "co-004" else (" · A-102 rev C" if it["id"] == "plan-a102" else ""))}</span>
                                <span style={{"width": 130}}><Pill label={it["pill"].split(" · ")[0] if it["kind"] != "change" else "Change order"} tone={it["pill_tone"]} /></span>
                                <span className="right" style={{"width": 110}}>{it["amount"] if it["kind"] != "plan" else "—"}</span>
                                <span className="row g8 end" style={{"width": 200}}>
                                    {it["kind"] == "change" and <Btn label="Reject" kind="text" onClick={lambda { decide(it, "reject"); }} disabled={not allowed(role, "decide_change")} />}
                                    {it["kind"] == "change" and <Btn label="Approve" icon="check" onClick={lambda { decide(it, "approve"); }} disabled={not allowed(role, "decide_change")} />}
                                    {it["kind"] == "plan" and <Btn label="Review plan" icon="file" kind="ghost" onClick={lambda { nav("/projects/perera-house/plans"); }} />}
                                    {it["kind"] == "payment" and <Btn label="Needs photos" icon="camera" kind="text" onClick={lambda { nav("/projects/perera-house/payments"); }} />}
                                    {it["kind"] == "ledger" and <Btn label="Review" icon="receipt" kind="ghost" onClick={lambda { nav("/projects/perera-house/ledger"); }} />}
                                </span>
                            </div>
                        }}
                    </div>
                </div>
            </div>}
        </Gate>
    </Page>;
}
