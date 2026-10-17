"""Project tabs: Overview, Schedule, Progress, Plans."""

import from ..components.Icon { Icon }
import from ..components.ui { Btn, Pill, Avatar, Chip, Bar, Ring, Tabs, TONE_SOLID, TONE_TINT }
import from ..components.Cards { KpiCard, Lock }
import from ..components.Charts { LineChart }
import from ..components.House { HouseLayers }
import from ..components.States { EmptyState }
import from ..lib.roles { allowed, why }

def:pub OverviewTab(d: any) -> JsxElement {
    c: any = d["curve"];
    return <div className="col g20">
        <div className="grid5">
            {for k in d["kpis"] { <KpiCard key={k["label"]} label={k["label"]} value={k["value"]} pill={k["pill"]} tone={k["tone"]} /> }}
        </div>
        <div className="row g16 top">
            <div className="card col g16" style={{"width": 380, "flexShrink": 0, "borderRadius": 28}}>
                <div className="row"><span className="h3 grow">Transparency score</span><span className="sm t2">How is this worked out?</span></div>
                <div className="row g16">
                    <div style={{"position": "relative", "width": 120, "height": 120}}>
                        <Ring score={d["score"]} size={120} stroke={12} label={False} />
                        <div className="col" style={{"position": "absolute", "inset": 0, "alignItems": "center", "justifyContent": "center"}}><span className="xl" style={{"fontSize": 36, "lineHeight": "40px"}}>{d["score"]}</span><span className="sm t2">of 100</span></div>
                    </div>
                    <div className="col g8 grow"><div><Pill label={d["score_label"]} tone="done" /></div><p className="sm t2">{d["score_note"]}</p></div>
                </div>
                <div className="col g12">
                    {for b in d["bars"] {
                        <div key={b["label"]} className="col g4"><div className="row between sm"><span>{b["label"]}</span><span className="b">{str(b["n"]) + " / " + str(b["of"])}</span></div><Bar pct={b["n"] * 100 / b["of"]} tone={b["tone"]} /></div>
                    }}
                </div>
            </div>
            <div className="card col g12 grow" style={{"borderRadius": 28, "minWidth": 0}}>
                <div className="row"><span className="h3 grow">Cost curve</span><span className="sm t2">Planned · earned · actual</span></div>
                <div className="row g20 sm t2">
                    <div className="col"><span className="row g6"><i style={{"width": 8, "height": 8, "borderRadius": 4, "background": "#bdd3ce", "display": "block"}} />Planned (PV)</span><span className="h3" style={{"color": "#0b2b3c"}}>{c["pv"]}</span></div>
                    <div className="col"><span className="row g6"><i style={{"width": 8, "height": 8, "borderRadius": 4, "background": "#708c69", "display": "block"}} />Earned (EV)</span><span className="h3" style={{"color": "#0b2b3c"}}>{c["ev"]}</span></div>
                    <div className="col"><span className="row g6"><i style={{"width": 8, "height": 8, "borderRadius": 4, "background": "#f4a258", "display": "block"}} />Actual (AC)</span><span className="h3" style={{"color": "#0b2b3c"}}>{c["ac"]}</span></div>
                </div>
                <LineChart series={[{"pts": c["planned"], "color": "#bdd3ce", "dash": True, "fill": False, "dot": False}, {"pts": c["earned"], "color": "#708c69", "dash": False, "fill": False, "dot": True}, {"pts": c["actual"], "color": "#f4a258", "dash": False, "fill": False, "dot": True}]} xmax={11} ymin={0} ymax={c["max"]} labels={[[i, m] for (i, m) in enumerate(c["months"])]} width={760} height={300} today={c["today"]} />
            </div>
        </div>
        <div className="row g16 top">
            <div className="col g12 grow" style={{"background": "#013d5a", "borderRadius": 28, "padding": 24, "minWidth": 0}}>
                <div className="row"><span className="h3 tinv grow">Risk forecast</span><span className="sm tmut">AI · updated today</span></div>
                {for r in d["risks"] {
                    <div key={r["title"]} className="row g12 r16" style={{"background": "#0b4e6e", "padding": "14px 16px"}}>
                        <span className="chip" style={{"background": "#013d5a", "color": "#f4a258", "width": 40, "height": 40, "borderRadius": 13}}><Icon name={r["icon"]} size={20} /></span>
                        <div className="col g2 grow"><span className="b tinv">{r["title"]}</span><span className="sm tmut">{r["body"]}</span></div>
                        <Pill label={r["tag"]} tone={r["tone"]} />
                    </div>
                }}
            </div>
            <div className="card col g12" style={{"width": 440, "flexShrink": 0, "borderRadius": 28}}>
                <div className="row"><span className="h3 grow" style={{"fontSize": 18}}>Stages</span><span className="sm t2">{d["stage_label"]}</span></div>
                {for s in d["stages"] {
                    <div key={s["name"]} className="row g12" style={{"padding": "6px 0"}}>
                        <i style={{"width": 12, "height": 12, "borderRadius": 6, "background": TONE_SOLID[s["tone"]], "display": "block"}} />
                        <span className={"grow b" if s["tone"] != "muted" else "grow t2"}>{s["name"]}</span><span className="sm t2">{s["note"]}</span>
                    </div>
                }}
            </div>
        </div>
    </div>;
}

def:pub ScheduleTab(d: any, role: str, openCertify: Callable[[], None]) -> JsxElement {
    mw = 42;
    cert: any = d["certify"];
    may = allowed(role, "certify");
    return <div className="row g16 top">
        <div className="card col g12 grow" style={{"borderRadius": 28, "minWidth": 0}}>
            <div className="row g12 wrap"><span className="h3 grow">Phases</span>
                <span className="row g16 sm t2">
                    <span className="row g6"><i style={{"width": 14, "height": 10, "borderRadius": 5, "background": "#dceae6", "display": "block"}} />Planned</span>
                    <span className="row g6"><i style={{"width": 14, "height": 10, "borderRadius": 5, "background": "#708c69", "display": "block"}} />Done</span>
                    <span className="row g6"><i style={{"width": 14, "height": 10, "borderRadius": 5, "background": "#c4553b", "display": "block"}} />Late</span>
                    <span className="row g6"><i style={{"width": 14, "height": 10, "borderRadius": 5, "background": "#f4a258", "display": "block"}} />Active</span>
                    <span className="row g6"><i style={{"width": 3, "height": 12, "background": "#f4a258", "display": "block"}} />Today</span>
                </span></div>
            <div style={{"overflowX": "auto"}}>
                <div style={{"minWidth": 760, "position": "relative"}}>
                    <div className="row hr" style={{"paddingBottom": 8}}>
                        <span className="over t2" style={{"width": 200}}>Phase</span>
                        {for m in d["months"] { <span key={m} className="sm t2 cent" style={{"width": mw}}>{m}</span> }}
                    </div>
                    {for (i, p) in enumerate(d["phases"]) {
                        <div key={p["name"]} className="row hr" style={{"height": 49}}>
                            <span className="row g8 grow" style={{"width": 200, "flex": "0 0 200px"}}><i style={{"width": 8, "height": 8, "borderRadius": 4, "background": TONE_SOLID[p["tone"]], "display": "block"}} /><span className={"b" if p["tone"] != "muted" else "t2"}>{p["name"]}</span></span>
                            <div style={{"position": "relative", "width": mw * 12, "height": 49}}>
                                <div style={{"position": "absolute", "left": p["plan"][0] * mw, "width": (p["plan"][1] - p["plan"][0]) * mw, "top": 10, "height": 12, "borderRadius": 6, "background": "#dceae6"}} />
                                {p["act"][1] > 0 and <div style={{"position": "absolute", "left": p["act"][0] * mw, "width": Math.max(8, (p["act"][1] - p["act"][0]) * mw), "top": 26, "height": 12, "borderRadius": 6, "background": TONE_SOLID[p["tone"]]}} />}
                            </div>
                        </div>
                    }}
                    <div style={{"position": "absolute", "left": 200 + d["today"] * mw, "top": 30, "bottom": 0, "width": 2, "background": "#f4a258"}} />
                </div>
            </div>
        </div>
        <div className="col g16" style={{"width": 330, "flexShrink": 0}}>
            <div className="card col g12" style={{"borderRadius": 24}}>
                <span className="h3">Next up</span>
                {for n in d["next"] { <div key={n["title"]} className="row g12"><Chip icon={n["icon"]} tone="subtle" size={36} iconSize={18} /><div className="col"><span className="b">{n["title"]}</span><span className="sm t2">{n["sub"]}</span></div></div> }}
            </div>
            <div className="card col g12" style={{"borderRadius": 24}}>
                <span className="h3">Certify a phase</span>
                <div className="row g8 bg-sub r16" style={{"padding": "12px 14px"}}><div className="col grow"><span className="b">{cert["phase"]}</span><span className="sm t2">{cert["note"]}</span></div><Pill label={cert["tag"]} tone="delayed" /></div>
                <Btn label="Certify phase" icon="check" block={True} lg={True} disabled={not may} onClick={openCertify} />
                <p className="sm t2 row g8 top"><Icon name="shield" size={14} />{"Only the architect can certify phases. You'll get a notification when it's done." if not may else "Certifying is logged under your name."}</p>
            </div>
            <div className="card col g12" style={{"borderRadius": 24}}>
                <div className="row"><span className="h3 grow">Delays logged</span><span className="sm t2">{d["delays_total"]}</span></div>
                {for x in d["delays"] { <div key={x["title"]} className="row g12"><Chip icon={x["icon"]} tone="marigold" size={36} iconSize={18} /><div className="col grow"><span className="b">{x["title"]}</span><span className="sm t2">{x["sub"]}</span></div><span className="b sm">{x["days"]}</span></div> }}
            </div>
        </div>
    </div>;
}

def:pub ProgressTab(d: any, role: str, onPost: Callable[[], None], onRun: Callable[[str, any, str], None]) -> JsxElement {
    has filter: str = "All", local: dict[str, any] = {};
    dg: any = d["digest"];
    logs: list[any] = [l for l in d["logs"] if filter == "All" or not l["ack"]];
    may_post = allowed(role, "post_log");
    may_prog = allowed(role, "set_progress");
    may_ack = allowed(role, "ack_log");
    def move(name: str, v: str) {
        nv: dict[str, any] = {**local};
        nv[name] = v;
        local = nv;
    }
    return <div className="row g16 top">
        <div className="col g16 grow" style={{"minWidth": 0}}>
            <div className="col g12 r24" style={{"background": "#bdd3ce", "padding": 24, "borderRadius": 28}}>
                <div className="row g10"><span className="chip s bg-surface" style={{"width": 32, "height": 32, "borderRadius": 10}}><Icon name="sparkles" size={16} /></span><span className="h3 grow">{dg["title"]}</span><Pill label={dg["tag"]} tone="info" /></div>
                <p>{dg["text"]}</p>
                <div className="row g12">{for s in dg["stats"] { <div key={s[0]} className="col g2 grow bg-surface r14" style={{"padding": "12px 14px"}}><span className="sm t2">{s[0]}</span><span className="b">{s[1]}</span></div> }}</div>
            </div>
            <div className="row g12"><span className="h3 grow">Daily logs</span>
                <Tabs items={["All", "Awaiting architect"]} value={filter} onChange={lambda v: str { filter = v; }} />
                <Btn label="Post daily log" icon="plus" kind="accent" onClick={onPost} disabled={not may_post} />
            </div>
            {not may_post and <Lock title="Contractor only" body={why("post_log")} />}
            {len(logs) == 0 and <EmptyState title="No daily logs yet" body="The contractor posts one at the end of each work day. You will see photos and notes here." />}
            {for l in logs {
                <div key={l["id"]} className="card col g10 top" style={{"borderRadius": 24, "padding": 18}}>
                    <div className="row g14 top" style={{"width": "100%"}}>
                        <div className="col bg-sub r16 cent" style={{"width": 52, "padding": "8px 0", "alignItems": "center"}}><span className="h2">{l["day"]}</span><span className="sm t2">{l["mon"]}</span></div>
                        <div className="col g8 grow" style={{"minWidth": 0}}>
                            <div className="row g8 wrap"><span className="b">{l["title"]}</span><Pill label={l["weather"]} tone={"done" if l["weather"] == "Sunny" else "info"} /><Pill label={l["workers"]} tone="neutral" /><div className="grow" /><span className="sm t2">{l["when"]}</span></div>
                            <p className="t2" style={{"color": "#0b2b3c"}}>{l["text"]}</p>
                            {l["photos"] > 0 and <div className="row g10">{for i in range(l["photos"]) { <span key={str(i)} className="ph" style={{"width": 104, "height": 76, "background": ["#fce4cc", "#dceae6", "#dde6d7"][i % 3]}}><Icon name="camera" size={20} /></span> }}</div>}
                            <div className="row g10"><Avatar initials={l["initials"]} tone="marigold" size={28} /><span className="sm t2 grow">{"Posted by " + l["by"]}</span>
                                {(not l["ack"]) and may_ack and <Btn label="Acknowledge" icon="check" kind="ghost" onClick={lambda { onRun("ack_log", {"id": l["id"]}, "Log acknowledged"); }} />}
                                <Pill label={l["status"]} tone={"done" if l["ack"] else "progress"} /></div>
                        </div>
                    </div>
                </div>
            }}
        </div>
        <div className="col g16" style={{"width": 380, "flexShrink": 0}}>
            <div className="card col g12" style={{"borderRadius": 24}}>
                <div className="row"><span className="h3 grow">House</span><span className="sm t2">By element</span></div>
                <HouseLayers layers={d["layers"]} legend={True} />
            </div>
            <div className="card col g12" style={{"borderRadius": 24}}>
                <span className="h3">Update element progress</span>
                <p className="sm t2">Move a slider after each log. The architect verifies the % before it counts as "verified built".</p>
                {for s in d["sliders"] {
                    <div key={s["name"]} className="col g4"><div className="row between"><span className="b">{s["name"]}</span><span className="b sm">{str(local[s["name"]] if s["name"] in local else s["pct"]) + "%"}</span></div>
                        <input type="range" min="0" max="100" value={local[s["name"]] if s["name"] in local else s["pct"]} disabled={not may_prog} onChange={lambda (e: ChangeEvent) { move(s["name"], e.target.value); }} onMouseUp={lambda { onRun("set_progress", {"name": s["name"], "pct": float(local[s["name"]] if s["name"] in local else s["pct"])}, "Progress updated"); }} /></div>
                }}
                {not may_prog and <p className="sm t2 row g8 top"><Icon name="shield" size={14} />{why("set_progress")}</p>}
            </div>
        </div>
    </div>;
}

def:pub PlanDrawing(selected: str) -> JsxElement {
    return <svg viewBox="0 0 446 470" width="100%" style={{"display": "block", "borderRadius": 16, "background": "#fcf3e3"}}>
        <defs><pattern id="g" width="22" height="22" patternUnits="userSpaceOnUse"><path d="M22 0H0V22" fill="none" stroke="#f0e2c8" strokeWidth="1" /></pattern></defs>
        <rect width="446" height="470" fill="url(#g)" />
        <g stroke="#013d5a" strokeWidth="4" fill="none">
            <rect x="34" y="50" width="378" height="326" />
            <path d="M251 50V376 M251 156H412 M34 226H412 M180 226V376 M186 308H250" />
        </g>
        <rect x="34" y="380" width="218" height="38" fill="#dceae6" stroke="#013d5a" strokeWidth="2" strokeDasharray="5 4" />
        <g fontSize="12" fontWeight="700" fill="#013d5a" textAnchor="middle">
            <text x="142" y="143">Living</text><text x="330" y="106">Kitchen</text><text x="330" y="198">Dining</text><text x="108" y="308">Bed 1</text><text x="218" y="274">Bath</text><text x="218" y="346">Stairs</text><text x="330" y="308">Bed 2</text><text x="150" y="403">Verandah</text>
        </g>
        {for p in [[1, 346, 103], [2, 156, 303], [3, 106, 406]] {
            <g key={str(p[0])}><circle cx={p[1]} cy={p[2]} r="13" fill="#f4a258" stroke="#fff" strokeWidth="2" /><text x={p[1]} y={p[2] + 4} fontSize="12" fontWeight="800" fill="#0b2b3c" textAnchor="middle">{p[0]}</text></g>
        }}
    </svg>;
}

def:pub PlansTab(d: any, role: str, onRun: Callable[[str, any, str], None], onConfirm: Callable[[str, str, str], None]) -> JsxElement {
    has selected: str = "a102", note: str = "";
    v: any = d["viewer"];
    may = allowed(role, "approve_plan");
    cur: any = d["sheets"][0];
    for s in d["sheets"] { if s["id"] == selected { cur = s; } }
    return <div className="row g16 top">
        <div className="card col g8" style={{"width": 280, "flexShrink": 0, "borderRadius": 24, "padding": 16}}>
            <div className="row" style={{"padding": "4px 8px"}}><span className="h3 grow">Sheets</span><span className="row g6 b sm"><Icon name="upload" size={14} />Upload</span></div>
            {for s in d["sheets"] {
                <button key={s["id"]} className="row g12 r16" style={{"padding": 12, "textAlign": "left", "background": "#d5e3ea" if s["id"] == selected else "transparent"}} onClick={lambda { selected = s["id"]; }}>
                    <Chip icon="file" tone="subtle" size={36} iconSize={18} />
                    <div className="col g4"><span className="b">{s["code"] + " · " + s["name"]}</span><span className="row g8 sm t2">{"rev " + s["rev"]}<Pill label={s["status"]} tone={s["tone"]} /></span></div>
                </button>
            }}
        </div>
        <div className="card col g12 grow" style={{"borderRadius": 24, "minWidth": 0}}>
            <div className="row g12 wrap"><span className="h3">{cur["code"] + " · " + cur["name"]}</span><span className="pill bd bg-surface b">{"Rev " + cur["rev"]}<Icon name="chevron-down" size={12} /></span><span className="sm t2 grow">{v["note"]}</span><span className="sm t2">{v["zoom"]}</span></div>
            <PlanDrawing selected={selected} />
        </div>
        <div className="card col g12" style={{"width": 330, "flexShrink": 0, "borderRadius": 24}}>
            <div className="row"><span className="h3 grow">Comments</span><span className="sm t2">{str(len(d["comments"])) + " open"}</span></div>
            {for c in d["comments"] {
                <div key={str(c["n"])} className="col g8 bg-page r16" style={{"padding": 14}}>
                    <div className="row g8"><span className="chip" style={{"width": 22, "height": 22, "borderRadius": 11, "background": "#f4a258", "fontSize": 11, "fontWeight": 800}}>{c["n"]}</span><Avatar initials={c["initials"]} tone="celeste" size={24} /><span className="b">{c["by"]}</span></div>
                    <p className="sm">{c["text"]}</p>
                    <div><Pill label={c["tag"]} tone={c["tone"]} /></div>
                </div>
            }}
            <div className="row g8 bd r999" style={{"padding": "4px 4px 4px 14px"}}><input style={{"border": 0, "outline": "none", "flex": 1, "background": "none"}} placeholder="Add a comment…" value={note} onChange={lambda (e: ChangeEvent) { note = e.target.value; }} /><Btn label="Post" kind="ghost" onClick={lambda { note = ""; onRun("noop", {}, "Comment posted"); }} /></div>
            <Btn label="Approve rev C" icon="check" block={True} lg={True} disabled={not may} onClick={lambda { onConfirm("Approve rev C?", "Approving sets rev C as the build plan and is logged under your name.", "approve_plan"); }} />
            <Btn label="Request revision" icon="x" kind="ghost" block={True} lg={True} disabled={not may} onClick={lambda { onRun("noop", {}, "Revision requested"); }} />
            {not may and <Lock title="Client only" body={why("approve_plan")} />}
        </div>
    </div>;
}
