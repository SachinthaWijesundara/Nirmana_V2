"""03 Approvals: everything waiting on the current role, with a detail panel."""

import from ..components.Icon { Icon }
import from ..components.ui { Btn, Pill, Avatar, Chip, Tabs }
import from ..components.Cards { Note, Lock }
import from ..components.States { Gate, EmptyState }
import from ..components.Shell { Page }
import from ..hooks.app { useApp, useResource }
import from ..lib.roles { allowed, why }

glob KIND_RULE: dict[str, str] = {"change": "decide_change", "plan": "approve_plan", "payment": "pay", "ledger": "ledger_query"};
glob KIND_TAB: dict[str, str] = {"change": "Change orders", "plan": "Plans", "payment": "Payments", "ledger": "Ledger queries"};

def:pub Approvals() -> JsxElement {
    app = useApp();
    res = useResource("approvals", {});
    has filter: str = "All", selected: str = "co-004";
    role: str = app["role"];
    d: any = res["data"];
    items: list[any] = d["items"] if d else [];
    shown = [i for i in items if filter == "All" or KIND_TAB[i["kind"]] == filter];
    labels = ["All"] + [KIND_TAB[k] for k in ["change", "plan", "payment", "ledger"]];
    def label_for(l: str) -> str {
        n = len(items) if l == "All" else len([i for i in items if KIND_TAB[i["kind"]] == l]);
        return l + " · " + str(n);
    }
    detail: any = d["details"][selected] if (d and selected in d["details"]) else None;
    cur: any = None;
    for i in items { if i["id"] == selected { cur = i; } }

    def decide(decision: str) {
        rule = KIND_RULE[cur["kind"]];
        app["openOverlay"]("confirm", {
            "title": ("Approve " if decision == "approve" else "Reject ") + cur["title"] + "?",
            "body": detail["confirm"] if decision == "approve" else "Rejecting is final and logged under your name.",
            "confirm": "Yes, approve" if decision == "approve" else "Yes, reject",
            "run": lambda { app["decide"](cur["id"], decision, res["reload"]); }
        });
    }
    may = bool(cur) and allowed(role, KIND_RULE[cur["kind"]]);
    locked: bool = bool(detail and "locked" in detail);
    return <Page title="Approvals" subtitle={("" if not d else str(len(items)) + " items waiting on you as " + app["user"]["role"] + ", across 2 projects")}>
        <div className="row g8">
            <Tabs items={[label_for(l) for l in labels]} value={label_for(filter)} onChange={lambda v: str { filter = v.split(" · ")[0]; }} />
            <div className="grow" />
            <Btn label="Filter" icon="filter" kind="ghost" onClick={lambda { filter = "All"; }} />
        </div>
        <Gate res={res} what="approvals">
            {d and <div className="row g20 top">
                <div className="col g12 grow" style={{"minWidth": 0}}>
                    {len(shown) == 0 and <EmptyState title="Nothing waiting on you" body="New items show up here as soon as they need your decision." />}
                    {for it in shown {
                        <button key={it["id"]} className="row g14 r16 card-sm" style={{"border": "2px solid #013d5a" if it["id"] == selected else "2px solid transparent", "textAlign": "left", "width": "100%"}} onClick={lambda { selected = it["id"]; }}>
                            <Chip icon={it["icon"]} tone={it["chip"]} />
                            <div className="col g4 grow" style={{"minWidth": 0}}><span className="b ell">{it["title"]}</span><span className="sm t2 ell">{it["meta"]}</span></div>
                            <div className="col g6" style={{"alignItems": "flex-end"}}><span className="b nowrap">{it["amount"]}</span><Pill label={it["pill"]} tone={it["pill_tone"]} /></div>
                            <Icon name="chevron-right" size={18} />
                        </button>
                    }}
                    <Note text="You only see what your role can act on. Contractors see queries to answer; architects see invoices, phases and daily logs to certify." />
                    <div className="col g8" style={{"paddingTop": 8}}>
                        <p className="over t2">Done recently</p>
                        {for x in d["done"] {
                            <div key={x["title"] + x["meta"]} className="row g12 bd r16" style={{"padding": "12px 16px"}}>
                                <Icon name="check" size={18} />
                                <div className="col g2 grow"><span className="b">{x["title"]}</span><span className="sm t2">{x["meta"]}</span></div>
                                <Pill label={"Approved" if x["meta"].startswith("Approved") else "Rejected"} tone={"done" if x["meta"].startswith("Approved") else "delayed"} />
                            </div>
                        }}
                    </div>
                </div>
                {detail and cur and <div className="card col g20" style={{"width": 440, "flexShrink": 0, "padding": 28}}>
                    <div className="row g8"><Pill label={detail["tag"]} tone="info" /><div className="grow" /><Pill label={detail["status"]} tone="progress" /></div>
                    <h2 className="h1 nowrap" style={{"whiteSpace": "normal"}}>{detail["title"]}</h2>
                    <p className="t2">{detail["body"]}</p>
                    <div className="row g12"><Avatar initials={detail["initials"]} tone="marigold" /><div className="col"><span className="b">{detail["by"]}</span><span className="sm t2">{detail["role"]}</span></div></div>
                    <div style={{"display": "grid", "gridTemplateColumns": "1fr 1fr", "gap": 10}}>
                        {for f in detail["facts"] {
                            <div key={f[0]} className="col g4 bg-page r16" style={{"padding": "14px 16px"}}><span className="sm t2">{f[0]}</span><span className="h3" style={{"color": "#c4553b" if f[2] else "#0b2b3c"}}>{f[1]}</span></div>
                        }}
                    </div>
                    <div className="row g12 top r16 bg-therb" style={{"padding": "14px 16px"}}>
                        <span className="chip s bg-surface" style={{"width": 32, "height": 32, "borderRadius": 11}}><Icon name="sparkles" size={16} /></span>
                        <div className="col g2 grow"><span className="b">{detail["ai_title"]}</span><span className="sm t2">{detail["ai_body"]}</span></div>
                    </div>
                    <div className="row g12 bd r16" style={{"padding": "12px 16px 12px 12px"}}>
                        <span className="chip bg-sub" style={{"width": 36, "height": 36, "borderRadius": 12}}><Icon name="file" size={18} /></span>
                        <div className="col grow"><span className="b">{detail["file"]}</span><span className="sm t2">{detail["file_meta"]}</span></div>
                        <span className="b tinfo">View</span>
                    </div>
                    <div className="row g10">
                        <div className="grow"><Btn label="Reject" icon="x" kind="danger" block={True} disabled={not may or locked} onClick={lambda { decide("reject"); }} /></div>
                        <div className="grow"><Btn label={detail["approve"]} icon="check" block={True} disabled={not may or locked} onClick={lambda { decide("approve"); }} /></div>
                    </div>
                    {(not may) and <Lock title={KIND_TAB[cur["kind"]] + " · not your role"} body={why(KIND_RULE[cur["kind"]])} />}
                    {may and locked and <Lock title="Locked" body={detail["locked"]} />}
                    <p className="sm t2 row g8 top"><Icon name="shield" size={16} />Decisions are final. Yours is written to the project's activity log with your name, role and time.</p>
                </div>}
            </div>}
        </Gate>
    </Page>;
}
