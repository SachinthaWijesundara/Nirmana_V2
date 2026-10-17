"""Project tabs: Materials, Budget, Changes, Payments, Ledger, Activity, Tour."""

import from ..components.Icon { Icon }
import from ..components.ui { Btn, Pill, Avatar, Chip, Bar, Tabs, Seg, TONE_SOLID, TONE_TINT }
import from ..components.Cards { StatCard, Note, Lock }
import from ..components.States { EmptyState }
import from ..lib.roles { allowed, why }

def:pub MaterialsTab(d: any) -> JsxElement {
    has filter: str = "All";
    rows: list[any] = [r for r in d["rates"] if filter == "All" or r["flag"]];
    return <div className="col g16">
        <div className="row g16 stretch">
            {for k in d["kpis"] { <StatCard key={k["label"]} tone={k["tone"]} icon={k["icon"]} label={k["label"]} value={k["value"]} sub={k["sub"]} /> }}
        </div>
        <div className="row g16 top">
            <div className="card col g8 grow" style={{"borderRadius": 28, "minWidth": 0}}>
                <div className="row"><span className="h3 grow">Rates paid vs market</span><Btn label={"Show all" if filter == "Flagged" else "Filter"} icon="filter" kind="text" onClick={lambda { filter = "All" if filter == "Flagged" else "Flagged"; }} /></div>
                <div className="thead" style={{"marginTop": 8}}><span className="over t2 grow">Material</span><span className="over t2" style={{"width": 90}}>Used</span><span className="over t2 right" style={{"width": 90}}>Paid</span><span className="over t2 right" style={{"width": 90}}>Market</span><span className="over t2 right" style={{"width": 130}}>Diff</span></div>
                {for r in rows {
                    <div key={r["name"]} className="trow" style={{"background": "#f6d9cf" if r["flag"] else "transparent", "borderRadius": 12 if r["flag"] else 0, "padding": "14px 16px"}}>
                        <span className="b grow">{r["name"]}</span><span className="t2" style={{"width": 90}}>{r["used"]}</span><span className="right" style={{"width": 90}}>{r["paid"]}</span><span className="t2 right" style={{"width": 90}}>{r["market"]}</span>
                        <span className="right" style={{"width": 130}}><Pill label={r["diff"]} tone={"delayed" if r["flag"] else "done"} /></span>
                    </div>
                }}
            </div>
            <div className="col g16" style={{"width": 340, "flexShrink": 0}}>
                <div className="card col g12" style={{"borderRadius": 24}}>
                    <div className="row"><span className="h3 grow">On site now</span><span className="sm t2">{d["updated"]}</span></div>
                    {for s in d["site"] { <div key={s["name"]} className="col g4"><div className="row between"><span className="b">{s["name"]}</span><span className="sm"><span className="b">{s["have"]}</span><span className="t2">{" / " + s["need"]}</span></span></div><Bar pct={s["pct"]} tone={s["tone"]} /></div> }}
                </div>
                <div className="row g12 top r24" style={{"background": "#013d5a", "padding": 18, "borderRadius": 22}}>
                    <span className="chip" style={{"background": "#0b4e6e", "color": "#f4a258", "width": 36, "height": 36, "borderRadius": 12}}><Icon name="shield" size={18} /></span>
                    <div className="col g2"><span className="b tinv">{d["tip"]["title"]}</span><span className="sm tmut">{d["tip"]["body"]}</span></div>
                </div>
            </div>
        </div>
    </div>;
}

def:pub BudgetTab(d: any, onExport: Callable[[], None]) -> JsxElement {
    return <div className="col g16">
        <div className="card col g16" style={{"borderRadius": 28}}>
            <div className="row g16 wrap bot">
                <div className="col"><span className="sm t2">Contract sum</span><span className="xl" style={{"fontSize": 28, "lineHeight": "36px"}}>{d["contract"]}</span></div><span className="h2 t2">+</span>
                <div className="col"><span className="sm t2">Approved changes</span><span className="xl" style={{"fontSize": 28, "lineHeight": "36px"}}>{d["approved"]}</span></div><span className="h2 t2">=</span>
                <div className="col"><span className="sm t2">Revised sum</span><span className="xl tmid" style={{"fontSize": 28, "lineHeight": "36px"}}>{d["revised"]}</span></div>
                <div className="grow" />
                <div className="col bg-tmar r16" style={{"padding": "10px 16px"}}><span className="sm t2">Pending changes</span><span className="b">{d["pending"]}</span></div>
                <div className="col bg-tdan r16" style={{"padding": "10px 16px"}}><span className="sm t2">Forecast final cost</span><span className="b tdan">{d["forecast"]}</span></div>
            </div>
            <div className="bar" style={{"height": 12}}>{for sg in d["segments"] { <div key={sg[0]} style={{"width": str(sg[1]) + "%", "background": TONE_SOLID[sg[2]], "borderRadius": 0}} /> }}</div>
            <div className="row g20 sm t2 wrap">{for sg in d["segments"] { <span key={sg[0]} className="row g6"><i style={{"width": 10, "height": 10, "borderRadius": 5, "background": TONE_SOLID[sg[2]], "display": "block"}} />{sg[0]}</span> }}</div>
        </div>
        <div className="row g16 top">
            <div className="card col g8 grow" style={{"borderRadius": 28, "minWidth": 0}}>
                <div className="row"><span className="h3 grow">By BOQ item</span><Btn label="Export" icon="file" kind="text" onClick={onExport} /></div>
                <div className="thead" style={{"marginTop": 8}}><span className="over t2 grow">Item</span><span className="over t2 right" style={{"width": 120}}>Budget</span><span className="over t2 right" style={{"width": 120}}>Spent</span><span className="over t2" style={{"width": 170}}>Used</span><span style={{"width": 90}} /></div>
                {for r in d["boq"] {
                    <div key={r["item"]} className="trow" style={{"padding": "14px 16px"}}>
                        <span className="b grow ell">{r["item"]}</span><span className="right" style={{"width": 120}}>{r["budget"]}</span><span className="right" style={{"width": 120}}>{r["spent"]}</span>
                        <span className="row g10" style={{"width": 170}}><div className="grow"><Bar pct={r["pct"]} tone={r["tone"]} /></div><span className="sm b">{str(r["pct"]) + "%"}</span></span>
                        <span className="right" style={{"width": 90}}><Pill label={r["status"]} tone={"delayed" if r["tone"] == "danger" else ("muted" if r["status"] == "Not started" else "done")} /></span>
                    </div>
                }}
                <div className="row g16 bg-tmar r12 b" style={{"padding": "14px 16px"}}><span className="grow">Total</span><span className="right" style={{"width": 120}}>{d["total"]["budget"]}</span><span className="right" style={{"width": 120}}>{d["total"]["spent"]}</span><span className="row g10" style={{"width": 170}}><div className="grow"><Bar pct={d["total"]["pct"]} tone="midnight" /></div><span className="sm">{str(d["total"]["pct"]) + "%"}</span></span><span style={{"width": 90}} /></div>
            </div>
            <div className="col g16" style={{"width": 340, "flexShrink": 0}}>
                <div className="card col g12" style={{"borderRadius": 24}}>
                    <span className="h3">Where the money went</span>
                    {for m in d["money"] { <div key={m["name"]} className="col g4"><div className="row between"><span className="b">{m["name"]}</span><span className="sm t2">{m["amount"]}</span></div><Bar pct={m["pct"]} tone={m["tone"]} /></div> }}
                </div>
                <Note text={d["note"]} />
            </div>
        </div>
    </div>;
}

def:pub Step(label: str, state: str) -> JsxElement {
    return <span className="row g6 sm" style={{"whiteSpace": "nowrap"}}>
        {state == "done" and <span className="chip s" style={{"width": 20, "height": 20, "borderRadius": 10, "background": "#708c69", "color": "#fff"}}><Icon name="check" size={12} /></span>}
        {state == "no" and <span className="chip s" style={{"width": 20, "height": 20, "borderRadius": 10, "background": "#c4553b", "color": "#fff"}}><Icon name="x" size={12} /></span>}
        {state == "wait" and <span style={{"width": 20, "height": 20, "borderRadius": 10, "background": "#f5ead5", "display": "block"}} />}
        <span className={"t2" if state == "wait" else "b"}>{label}</span>
    </span>;
}

def:pub ChangesTab(d: any, role: str, onDecide: Callable[[str, str], None], onRaise: Callable[[], None]) -> JsxElement {
    has filter: str = "all";
    may = allowed(role, "decide_change");
    may_raise = allowed(role, "raise_change");
    orders: list[any] = [o for o in d["orders"] if filter == "all" or o["status"] == filter];
    def count(s: str) -> int { return len(d["orders"]) if s == "all" else len([o for o in d["orders"] if o["status"] == s]); }
    names = {"all": "All · " + str(count("all")), "pending": "Pending · " + str(count("pending")), "approved": "Approved · " + str(count("approved")), "rejected": "Rejected · " + str(count("rejected"))};
    return <div className="col g16">
        <div className="row g12">
            <Tabs items={[names["all"], names["pending"], names["approved"], names["rejected"]]} value={names[filter]} onChange={lambda v: str { filter = v.split(" ")[0].lower(); }} />
            <div className="grow" />
            <span className="row g12 bg-surface r999 sm" style={{"padding": "10px 16px"}}><span className="row g6"><i style={{"width": 8, "height": 8, "borderRadius": 4, "background": "#708c69", "display": "block"}} />Approved <span className="b">{d["summary"]["approved"]}</span></span><span className="row g6"><i style={{"width": 8, "height": 8, "borderRadius": 4, "background": "#f4a258", "display": "block"}} />Pending <span className="b">{d["summary"]["pending"]}</span></span></span>
            <Btn label="Raise change order" icon="plus" kind="accent" disabled={not may_raise} onClick={onRaise} />
        </div>
        <div className="row g20 top">
            <div className="col g12 grow" style={{"minWidth": 0}}>
                {len(orders) == 0 and <EmptyState title="No change orders here" body="Change orders in this state will show up here." />}
                {for o in orders {
                    <div key={o["id"]} className="card col g14" style={{"borderRadius": 24, "border": "2px solid #f4a258" if o["status"] == "pending" else "2px solid transparent", "padding": 20}}>
                        <div className="row g14 top">
                            <Chip icon="layers" tone={"marigold" if o["status"] == "pending" else ("danger" if o["status"] == "rejected" else "herb")} size={44} iconSize={22} />
                            <div className="col g2 grow" style={{"minWidth": 0}}><span className="row g8"><span className="sm t2">{o["id"]}</span><span className="b">{o["title"]}</span></span><span className="sm t2">{o["meta"]}</span></div>
                            <div className="col g4" style={{"alignItems": "flex-end"}}><span className="row g10"><span className="b">{o["amount"]}</span><Pill label={"Pending client" if o["status"] == "pending" else o["status"].capitalize()} tone={"progress" if o["status"] == "pending" else ("delayed" if o["status"] == "rejected" else "done")} /></span><span className="sm t2">{o["days"]}</span></div>
                        </div>
                        <div className="row g8"><Step label="Raised" state="done" /><div className="grow" style={{"height": 2, "background": "#708c69"}} /><Step label="Contractor quote" state="done" /><div className="grow" style={{"height": 2, "background": "#708c69" if o["status"] != "pending" else "#f5ead5"}} /><Step label="Client decision" state={"wait" if o["status"] == "pending" else ("no" if o["status"] == "rejected" else "done")} /></div>
                        {o["status"] == "pending" and <div className="row g12"><span className="row g6 sm t2 grow"><Icon name="sparkles" size={14} />{o["rate"]}</span><Btn label="Reject" icon="x" kind="text" disabled={not may} onClick={lambda { onDecide(o["id"], "reject"); }} /><Btn label="Approve" icon="check" disabled={not may} onClick={lambda { onDecide(o["id"], "approve"); }} /></div>}
                        {o["status"] != "pending" and <div className="row g8 sm bg-page r12" style={{"padding": "10px 14px"}}><Icon name="shield" size={14} />{o["decided"]}</div>}
                    </div>
                }}
            </div>
            <div className="col g16" style={{"width": 340, "flexShrink": 0}}>
                <div className="card col g14" style={{"borderRadius": 24}}>
                    <span className="h3">How change orders work</span>
                    {for (i, h) in enumerate(d["how"]) { <div key={h[0]} className="row g12 top"><span className="chip" style={{"width": 28, "height": 28, "borderRadius": 14, "background": "#013d5a", "color": "#fff", "fontWeight": 800, "fontSize": 12}}>{i + 1}</span><div className="col"><span className="b">{h[0]}</span><span className="sm t2">{h[1]}</span></div></div> }}
                </div>
                {not may_raise and <Note text={"\"Raise change order\" is off for you: only the contractor can raise one. You decide on them here."} icon="shield" />}
            </div>
        </div>
    </div>;
}

def:pub PaymentsTab(d: any, role: str, onCertify: Callable[[], None], onPay: Callable[[str], None]) -> JsxElement {
    g: any = d["guard"];
    may_pay = allowed(role, "pay");
    may_cert = allowed(role, "certify");
    return <div className="col g16">
        <div className="col g14 r24" style={{"background": "#013d5a", "padding": 24, "borderRadius": 28}}>
            <div className="row g16 wrap"><span className="chip" style={{"background": "#0b4e6e", "color": "#f4a258", "width": 40, "height": 40}}><Icon name="shield" size={20} /></span>
                <div className="col grow"><span className="h3 tinv">Payment guard</span><span className="sm tmut">You can only pay for work the architect has verified.</span></div>
                <div className="col tinv"><span className="sm tmut right">Paid</span><span className="b">{g["paid"]}</span></div>
                <div className="col tinv"><span className="sm tmut right">Verified built</span><span className="b">{g["verified"]}</span></div>
                <div className="col"><span className="sm tmut right">Ahead of work</span><span className="b tmar">{g["ahead"]}</span></div></div>
            <div className="row" style={{"height": 8, "borderRadius": 999, "background": "#0b4e6e", "overflow": "hidden"}}><div style={{"width": str(g["verified_pct"]) + "%", "background": "#bdd3ce", "height": 8}} /><div style={{"width": str(g["ahead_pct"]) + "%", "background": "#f4a258", "height": 8}} /></div>
        </div>
        <div className="row g16 top">
            <div className="card col g8 grow" style={{"borderRadius": 28, "minWidth": 0}}>
                <div className="row"><span className="h3 grow">Milestones</span><span className="sm t2">Upcoming → Invoiced → Certified → Paid</span></div>
                {for m in d["milestones"] {
                    <div key={m["id"]} className="col g10 r16" style={{"background": "#f6d9cf" if m["tone"] == "danger" else "#fcf3e3", "padding": "14px 16px"}}>
                        <div className="row g12">
                            <span className="sm t2" style={{"width": 26}}>{m["code"]}</span><span className="b" style={{"flex": "1 1 190px", "minWidth": 150}}>{m["name"]}</span>
                            <span className="row g6">{for i in range(4) { <span key={str(i)} style={{"width": 26, "height": 5, "borderRadius": 3, "background": ("#c4553b" if m["tone"] == "danger" else ("#f4a258" if m["tone"] == "progress" else "#708c69")) if i < m["stage"] else "#efe0c4", "display": "block"}} /> }}</span>
                            <span className="sm t2" style={{"width": 64}}>{m["stage_label"]}</span><span className="b right" style={{"width": 110}}>{m["amount"]}</span><span style={{"width": 140}}><Pill label={m["tag"]} tone={m["tone"] if m["tone"] != "muted" else "muted"} /></span>
                        </div>
                        {"note" in m and m["note"] and <div className="row g12"><span className="row g8 sm grow"><Icon name="camera" size={16} color="#c4553b" />{m["note"]}</span>
                            {m["stage"] == 1 and may_cert and <Btn label="Certify milestone" icon="check" onClick={onCertify} />}
                            {m["stage"] == 1 and (not may_cert) and <Btn label="Pay Rs. 800,000" icon="wallet" disabled={True} onClick={lambda { }} />}
                            {m["stage"] == 2 and <Btn label="Pay Rs. 760,000" icon="wallet" disabled={not may_pay} onClick={lambda { onPay(m["id"]); }} />}</div>}
                    </div>
                }}
                {(not may_pay) and <Lock title="Client pays" body={why("pay")} />}
            </div>
            <div className="col g16" style={{"width": 340, "flexShrink": 0}}>
                <div className="card col g8" style={{"borderRadius": 24}}><span className="h3">Retention</span><span className="xl" style={{"fontSize": 28, "lineHeight": "36px"}}>{d["retention"]["amount"]}</span><p className="sm t2">{d["retention"]["text"]}</p><div><Pill label={d["retention"]["release"]} tone="neutral" /></div></div>
                <div className="card col g8" style={{"borderRadius": 24}}><span className="h3">Next payment</span><span className="b">{d["next"]["title"]}</span><span className="xl" style={{"fontSize": 28, "lineHeight": "36px"}}>{d["next"]["amount"]}</span>
                    <div className="row g8 wrap"><Pill label="Invoiced" tone="done" /><Pill label="Certified" tone="muted" /><Pill label="Paid" tone="muted" /></div>
                    <p className="sm t2 row g8 top"><Icon name="shield" size={14} />{d["next"]["note"]}</p></div>
            </div>
        </div>
    </div>;
}

def:pub LedgerTab(d: any, role: str, onOpen: Callable[[any], None]) -> JsxElement {
    has filter: str = "All";
    entries: list[any] = d["entries"];
    pending = d["counts"]["pending"];
    queried = d["counts"]["queried"];
    flagged = d["counts"]["flagged"];
    names = {"All": "All · " + str(d["counts"]["all"]), "Pending": "Pending review · " + str(pending), "Queried": "Queried · " + str(queried), "Flagged": "Flagged · " + str(flagged)};
    shown = [e for e in entries if filter == "All" or (filter == "Pending" and e["status"] == "Pending review") or (filter == "Queried" and e["status"] == "Queried") or (filter == "Flagged" and e["flag"])];
    first: any = entries[0];
    for e in entries { if e["flag"] { first = e; } }
    return <div className="col g16">
        <div className="row g12">
            <Tabs items={[names["All"], names["Pending"], names["Queried"], names["Flagged"]]} value={names[filter]} onChange={lambda v: str { filter = v.split(" ")[0]; }} />
            <div className="grow" />
            <Btn label="Export CSV" icon="file" kind="ghost" onClick={lambda { window.print(); }} />
        </div>
        <div className="card col g4" style={{"borderRadius": 28, "padding": 20}}>
            <div className="thead"><span className="over t2" style={{"width": 70}}>Date</span><span className="over t2 grow">Entry</span><span className="over t2" style={{"width": 150}}>Qty × rate</span><span className="over t2 right" style={{"width": 110}}>Amount</span><span className="over t2" style={{"width": 80}}>Receipt</span><span className="over t2" style={{"width": 110}}>AI audit</span><span className="over t2" style={{"width": 140}}>Status</span></div>
            {len(shown) == 0 and <EmptyState title="Nothing here" body="Entries in this state will show up here." />}
            {for e in shown {
                <button key={e["id"]} className="trow" style={{"background": "#f6d9cf" if e["flag"] else "transparent", "borderRadius": 12 if e["flag"] else 0, "padding": "12px 16px", "textAlign": "left", "width": "100%"}} onClick={lambda { onOpen(e); }}>
                    <span className="t2" style={{"width": 70}}>{e["date"]}</span><span className="b grow ell">{e["name"]}</span><span className="t2" style={{"width": 150}}>{e["qty"]}</span><span className="b right" style={{"width": 110}}>{e["amount"]}</span>
                    <span className="row g6" style={{"width": 80}}>{e["receipt"] and <Icon name="receipt" size={18} color="#708c69" />}{(not e["receipt"]) and <span className="row g4 sm tdan"><Icon name="alert" size={16} />Missing</span>}</span>
                    <span style={{"width": 110}}><Pill label={e["audit"]} tone={e["audit_tone"]} /></span><span style={{"width": 140}}><Pill label={e["status"]} tone={e["status_tone"]} /></span>
                </button>
            }}
        </div>
        <div className="row g16 top">
            <div className="col g12 grow r24" style={{"background": "#013d5a", "padding": 24, "borderRadius": 28, "minWidth": 0}}>
                <div className="row"><span className="row g8 h3 tinv grow"><Icon name="sparkles" size={18} color="#f4a258" />Receipt auditor</span><span className="sm tmut">Checked {d["counts"]["all"]} entries</span></div>
                <p className="tinv">{d["auditor"]}</p>
                <div className="row g12"><Btn label="Query this entry" icon="alert" kind="accent" disabled={not allowed(role, "ledger_query")} onClick={lambda { onOpen(first); }} /><Btn label="Mark reviewed" icon="check" kind="inv" onClick={lambda { onOpen(first); }} /></div>
            </div>
            <div className="card col g8" style={{"width": 360, "flexShrink": 0, "borderRadius": 24}}>
                <span className="h3">Totals</span>
                {for t in d["totals"] { <div key={t[0]} className="row between"><span className="t2">{t[0]}</span><span className="b">{t[1]}</span></div> }}
            </div>
        </div>
    </div>;
}

def:pub ActivityTab(d: any) -> JsxElement {
    has filter: str = "Everything";
    return <div className="col g16">
        <div className="row g12">
            <Tabs items={d["filters"]} value={filter} onChange={lambda v: str { filter = v; }} />
            <div className="grow" />
            <span className="row g6 bg-surface bd r999 sm" style={{"padding": "6px 12px"}}>Role <Avatar initials="NP" tone="celeste" size={24} /><Avatar initials="RS" tone="marigold" size={24} /><Avatar initials="AF" tone="herb" size={24} /></span>
            <Btn label="Export audit PDF" icon="file" kind="ghost" onClick={lambda { window.print(); }} />
        </div>
        <div className="row g16 top">
            <div className="card col g8 grow" style={{"borderRadius": 28, "minWidth": 0}}>
                {for g in d["groups"] {
                    <div key={g["day"]} className="col g4"><p className="over t2" style={{"padding": "12px 0 4px"}}>{g["day"]}</p>
                        {for (ix, it) in enumerate(g["items"]) {
                            <div key={str(ix) + it["what"]} className={"row g14 top hr" if (filter == "Everything" or it["kind"] == filter) else "row g14 top hr hidden"} style={{"padding": "14px 0", "display": "flex" if (filter == "Everything" or it["kind"] == filter) else "none"}}>
                                <span className="sm t2" style={{"width": 42}}>{it["time"]}</span>
                                <Chip icon={it["icon"]} tone={it["tone"]} size={40} iconSize={18} />
                                <div className="col g2 grow" style={{"minWidth": 0}}><span className="row g8 wrap"><Avatar initials={it["initials"]} tone="marigold" size={22} /><span className="b">{it["who"]}</span><span className="sm t2">{"· " + it["role"]}</span><span className="t2">{it["act"]}</span></span><span>{it["what"]}</span></div>
                                <span className="row g4 sm t2 nowrap"><Icon name="shield" size={12} />Recorded · cannot be edited</span>
                            </div>
                        }}
                    </div>
                }}
            </div>
            <div className="col g16" style={{"width": 320, "flexShrink": 0}}>
                <div className="col g12 r24" style={{"background": "#013d5a", "padding": 24, "borderRadius": 28}}>
                    <span className="chip" style={{"background": "#0b4e6e", "color": "#f4a258", "width": 40, "height": 40}}><Icon name="shield" size={20} /></span>
                    <span className="h3 tinv">Every action is on the record</span>
                    <p className="sm tmut">Approvals, payments, logs and plan changes are written here with who, which role and when. Nobody, including us, can edit or delete an entry.</p>
                </div>
                <div className="card col g12" style={{"borderRadius": 24}}>
                    <span className="h3">This month</span><span className="xl" style={{"fontSize": 28, "lineHeight": "36px"}}>{d["this_month"]}</span>
                    {for r in d["by_role"] { <div key={r[0]} className="col g4"><div className="row between"><span>{r[0]}</span><span className="b sm">{r[1]}</span></div><Bar pct={r[1] * 100 / 26} tone={r[2]} /></div> }}
                </div>
            </div>
        </div>
    </div>;
}

def:pub TourTab(d: any, onAdd: Callable[[], None]) -> JsxElement {
    has spot: str = "kitchen", split: str = "50";
    cur: any = d["spots"][0];
    for s in d["spots"] { if s["id"] == spot { cur = s; } }
    cmp: any = d["compare"];
    return <div className="col g16">
        <div className="row g10 bg-tmar r14 sm" style={{"padding": "12px 18px"}}><Icon name="info" size={16} color="#f4a258" />{d["note"]}</div>
        <div className="row g16 top">
            <div className="card col g12 grow" style={{"borderRadius": 28, "minWidth": 0}}>
                <div className="row"><span className="h3 grow">Compare</span><span className="sm t2">{cur["name"]}</span></div>
                <div style={{"position": "relative", "height": 380, "borderRadius": 20, "overflow": "hidden", "background": "#dceae6"}}>
                    <div className="col ctr" style={{"position": "absolute", "top": 0, "bottom": 0, "right": 0, "left": split + "%", "background": "#dceae6", "alignItems": "center"}}><Icon name="camera" size={28} /><span className="sm t2" style={{"marginTop": 8, "whiteSpace": "nowrap"}}>{cmp["right"]}</span></div>
                    <div className="col ctr" style={{"position": "absolute", "top": 0, "bottom": 0, "left": 0, "width": split + "%", "background": "#fce4cc", "alignItems": "center", "overflow": "hidden"}}><Icon name="camera" size={28} /><span className="sm t2" style={{"marginTop": 8, "whiteSpace": "nowrap"}}>{cmp["left"]}</span></div>
                    <div style={{"position": "absolute", "top": 0, "bottom": 0, "left": split + "%", "width": 3, "background": "#fff"}} />
                    <span style={{"position": "absolute", "top": 170, "left": "calc(" + split + "% - 20px)", "width": 40, "height": 40, "borderRadius": 20, "background": "#fff", "border": "2px solid #013d5a"}} />
                    <input type="range" min="5" max="95" value={split} onChange={lambda (e: ChangeEvent) { split = e.target.value; }} style={{"position": "absolute", "inset": 0, "width": "100%", "height": "100%", "opacity": 0, "cursor": "ew-resize"}} />
                </div>
                <div className="row between sm t2"><span>{cmp["from"]}</span><span>{cmp["to"]}</span></div>
            </div>
            <div className="card col g8" style={{"width": 330, "flexShrink": 0, "borderRadius": 24}}>
                <div className="row"><span className="h3 grow">Spots</span><span className="sm t2">{d["summary"]}</span></div>
                {for s in d["spots"] {
                    <button key={s["id"]} className="row g12 r14" style={{"padding": 10, "textAlign": "left", "background": "#d5e3ea" if s["id"] == spot else "transparent"}} onClick={lambda { spot = s["id"]; }}>
                        <Chip icon="camera" tone="subtle" size={40} iconSize={18} /><div className="col grow"><span className="b">{s["name"]}</span><span className="sm t2">{s["meta"]}</span></div><Icon name="chevron-right" size={16} />
                    </button>
                }}
            </div>
        </div>
        <div className="card col g12" style={{"borderRadius": 28}}>
            <div className="row"><span className="h3 grow">{cur["name"] + " over time"}</span><Btn label="Add photo" icon="camera" kind="ghost" onClick={onAdd} /></div>
            <div className="grid" style={{"display": "grid", "gridTemplateColumns": "repeat(6, 1fr)", "gap": 12}}>
                {for t in d["timeline"] { <div key={t[0]} className="col g6"><span className="ph" style={{"height": 100, "background": TONE_TINT[t[1]] if t[1] in TONE_TINT else "#f5ead5"}}><Icon name="camera" size={22} /></span><span className="sm t2">{t[0]}</span></div> }}
            </div>
        </div>
    </div>;
}
