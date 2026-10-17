"""Global overlays: toast, confirm dialog, ledger drawer, certify modal, daily-log drawer and the Ask Nirmana panel."""

import from ..components.Icon { Icon }
import from ..components.ui { Btn, Pill, Avatar, Check, Seg, Chip }
import from ..components.Cards { Lock }
import from ..backend.index { query, command }
import from ..lib.roles { allowed, why }

def:pub Toast(msg: str, sub: str) -> JsxElement {
    return <div className="toast">
        <span className="chip s" style={{"background": "#708c69", "color": "#fff", "borderRadius": 10}}><Icon name="check" size={16} /></span>
        <div className="col"><span className="b">{msg}</span>{sub and <span className="sm tmut">{sub}</span>}</div>
    </div>;
}

def:pub Confirm(data: any, onClose: Callable[[], None]) -> JsxElement {
    def go() {
        onClose();
        data["run"]();
    }
    return <div className="scrim" onClick={lambda { onClose(); }}>
        <div className="modal" style={{"width": 440, "borderRadius": 24, "border": "1px solid #e8dac0"}} onClick={lambda (e: MouseEvent) { e.stopPropagation(); }}>
            <p className="h3">{data["title"]}</p>
            <p className="sm t2">{data["body"]}</p>
            <div className="row g12 end"><Btn label="Cancel" kind="text" onClick={onClose} /><Btn label={data["confirm"]} icon="check" onClick={go} /></div>
        </div>
    </div>;
}

def:pub LedgerDrawer(data: any, role: str, onClose: Callable[[], None], onRun: Callable[[str, any, str], None]) -> JsxElement {
    e: any = data["entry"];
    d: any = data["detail"];
    flagged: bool = bool(e["flag"]);
    can_query = allowed(role, "ledger_query");
    can_verify = allowed(role, "ledger_verify");
    return <div className="scrim" onClick={lambda { onClose(); }}>
        <div className="drawer" onClick={lambda (e2: MouseEvent) { e2.stopPropagation(); }}>
            <div className="row g8">
                {flagged and <Pill label="Flagged · overpriced" tone="delayed" />}
                <Pill label={e["status"]} tone={e["status_tone"]} />
                <div className="grow" />
                <button className="iconbtn" style={{"width": 40, "height": 40, "background": "#fce4cc"}} onClick={lambda { onClose(); }}><Icon name="x" size={18} /></button>
            </div>
            <div className="col g4"><h2 className="huge" style={{"fontSize": 36, "lineHeight": "44px"}}>{d["title"] if d else e["name"]}</h2><p className="t2">{d["sub"] if d else e["date"] + " 2026"}</p></div>
            <div className="row g12 bot"><span className="xl" style={{"fontSize": 36, "lineHeight": "44px"}}>{d["amount"] if d else e["amount"]}</span><span className="t2">{d["qty"] if d else e["qty"]}</span></div>
            <div className="row g12 r16" style={{"background": "#fcf3e3", "padding": 14}}>
                <span className="chip bg-surface" style={{"width": 64, "height": 90, "borderRadius": 12, "background": "#fff"}}><Icon name="receipt" size={26} /></span>
                <div className="col g2 grow"><span className="b">{d["file"] if d else "receipt.jpg"}</span><span className="sm t2">{d["file_meta"] if d else "Uploaded by Ruwan Silva"}</span></div>
                <span className="b tinfo">Open</span>
            </div>
            {d and <div className="col g8 r16" style={{"background": "#f6d9cf", "padding": 16}}>
                <p className="b">Rate check</p>
                {for r in d["rate"] {
                    <div key={r[0]} className="row between t2"><span>{r[0]}</span><span className="b" style={{"color": "#0b2b3c"}}>{r[1]}</span></div>
                }}
                <div className="sep" style={{"background": "#c4553b", "opacity": 0.4}} />
                <div className="row between"><span className="b">Above fair price</span><span className="row g6 sm b"><i style={{"width": 7, "height": 7, "borderRadius": 4, "background": "#c4553b", "display": "block"}} />{d["over"]}</span></div>
            </div>}
            {d and <div className="row g12 top r16 bg-tcel" style={{"padding": 14}}>
                <span className="chip s bg-surface" style={{"borderRadius": 10}}><Icon name="sparkles" size={16} /></span>
                <div className="col g2 grow"><span className="b">{d["ai"]}</span><span className="sm t2">{d["ai_body"]}</span></div>
            </div>}
            <p className="over t2">History</p>
            <div className="col g12">
                {for h in (d["history"] if d else [["RS", "Ruwan Silva added this entry", e["date"]]]) {
                    <div key={h[1]} className="row g10"><Avatar initials={h[0]} tone="marigold" size={32} /><span className="sm grow">{h[1]}</span><span className="sm t2">{h[2]}</span></div>
                }}
            </div>
            <div className="grow" />
            <div className="row g12">
                <div className="grow"><Btn label="Query this entry" icon="alert" kind="accent" block={True} lg={True} disabled={not can_query} onClick={lambda { onRun("ledger_query", {"id": e["id"]}, "Entry sent back to the contractor"); }} /></div>
                <div className="grow"><Btn label="Mark verified" icon="check" kind="ghost" block={True} lg={True} disabled={not can_verify} onClick={lambda { onRun("ledger_verify", {"id": e["id"]}, "Entry marked verified"); }} /></div>
            </div>
            <p className="sm t2 row g8 top"><Icon name="shield" size={14} />{why("ledger_verify") if not can_verify else "A query sends the entry back to the contractor. Their reply moves it back to \"Pending review\"."}</p>
        </div>
    </div>;
}

def:pub CertifyModal(data: any, onClose: Callable[[], None], onRun: Callable[[str, any, str], None]) -> JsxElement {
    c: any = data["certify"];
    has note: str = "Slab is sound. Minor honeycombing at grid B2, patched.";
    def on_note(e: ChangeEvent) { note = e.target.value; }
    return <div className="scrim" onClick={lambda { onClose(); }}>
        <div className="modal" onClick={lambda (e: MouseEvent) { e.stopPropagation(); }}>
            <div className="row g12">
                <Chip icon="wallet" tone="herb" size={44} />
                <div className="col g2 grow"><h2 className="h1" style={{"fontSize": 24}}>{c["title"]}</h2><p className="sm t2">{c["sub"]}</p></div>
                <button className="iconbtn" style={{"width": 40, "height": 40, "background": "#fce4cc"}} onClick={lambda { onClose(); }}><Icon name="x" size={18} /></button>
            </div>
            <div className="col g12 r16" style={{"background": "#fcf3e3", "padding": 16}}>
                <p className="over t2">Evidence</p>
                {for ev in c["evidence"] {
                    <div key={ev["t"]} className="row g12"><Check on={ev["ok"]} /><div className="col"><span className="b">{ev["t"]}</span><span className="sm t2">{ev["s"]}</span></div></div>
                }}
            </div>
            <div className="col g8 r16 bd" style={{"padding": 16}}>
                <div className="row between t2"><span>Invoice</span><span style={{"color": "#0b2b3c"}}>{c["invoice"]}</span></div>
                <div className="row between t2 hr" style={{"paddingBottom": 8}}><span>Retention 5%</span><span style={{"color": "#0b2b3c"}}>{c["retention"]}</span></div>
                <div className="row between"><span className="b">Client pays</span><span className="xl" style={{"fontSize": 24}}>{c["pays"]}</span></div>
            </div>
            <div className="field"><label className="label">Note to the client (optional)</label><input className="input" value={note} onChange={on_note} /></div>
            <div className="row g12 end"><Btn label="Keep on hold" kind="text" onClick={onClose} /><Btn label={"Certify " + c["pays"]} icon="check" onClick={lambda { onClose(); onRun("certify_milestone", {"id": data["id"], "note": note}, "Milestone certified"); }} /></div>
            <p className="sm t2 row g8"><Icon name="shield" size={14} />Certifying unlocks payment for the client and is recorded in Activity under your name.</p>
        </div>
    </div>;
}

def:pub DailyLogDrawer(data: any, onClose: Callable[[], None], onRun: Callable[[str, any, str], None]) -> JsxElement {
    has workers: str = "9",
        weather: str = "Sunny",
        text: str = "Laid 1,100 bricks on the north and east walls. Lintel shuttering started over the kitchen window.",
        chosen: list[str] = ["Walls"],
        photos: int = 3,
        digest: bool = True;
    def toggle_el(name: str) {
        chosen = [c for c in chosen if c != name] if name in chosen else chosen + [name];
    }
    def post() {
        onClose();
        onRun("post_daily_log", {"title": (chosen[0] if len(chosen) > 0 else "Site") + " · ground floor", "weather": weather, "workers": workers, "text": text, "photos": photos, "digest": digest}, "Daily log posted");
    }
    return <div className="scrim" onClick={lambda { onClose(); }}>
        <div className="drawer" onClick={lambda (e: MouseEvent) { e.stopPropagation(); }}>
            <div className="row g12 top"><div className="col g2 grow"><h2 className="huge" style={{"fontSize": 34, "lineHeight": "40px"}}>Post daily log</h2><p className="sm t2">Perera House · Saturday 17 Oct 2026</p></div>
                <button className="iconbtn" style={{"width": 40, "height": 40, "background": "#fce4cc"}} onClick={lambda { onClose(); }}><Icon name="x" size={18} /></button></div>
            <div className="row g12">
                <div className="field grow"><label className="label">Date</label><input className="input" value="17 Oct 2026" readOnly={True} /></div>
                <div className="field grow"><label className="label">Workers on site</label><input className="input" value={workers} onChange={lambda (e: ChangeEvent) { workers = e.target.value; }} /></div>
            </div>
            <div className="field"><label className="label">Weather</label><Seg options={["Sunny", "Cloudy", "Rain", "Heavy rain"]} value={weather} onChange={lambda v: str { weather = v; }} /></div>
            <div className="field"><label className="label">What was done today</label><textarea className="input" rows={4} value={text} onChange={lambda (e: ChangeEvent) { text = e.target.value; }} /></div>
            <div className="field"><label className="label">Elements worked on</label>
                <div className="row g8 wrap">
                    {for n in data["elements"] {
                        <button key={n} className={"btn " + ("primary" if n in chosen else "ghost")} style={{"padding": "7px 14px", "fontSize": 12}} onClick={lambda { toggle_el(n); }}>{n in chosen and <Icon name="check" size={12} />}{n}</button>
                    }}
                </div></div>
            <div className="field"><label className="label">Photos</label>
                <button className="row g12 r16" style={{"border": "2px dashed #e8dac0", "padding": 14, "textAlign": "left"}} onClick={lambda { photos = photos + 1; }}>
                    <Chip icon="upload" tone="marigold" size={40} iconSize={18} /><div className="col"><span className="b">Drop photos or take one</span><span className="sm t2">JPG or PNG · up to 10 MB each</span></div></button>
                <div className="row g10" style={{"marginTop": 8}}>
                    {for i in range(photos) {
                        <span key={str(i)} className="ph" style={{"width": 80, "height": 60, "background": ["#fce4cc", "#dceae6", "#dde6d7"][i % 3]}}><Icon name="camera" size={18} /></span>
                    }}
                </div></div>
            <div className="row g12 r14 bg-tcel" style={{"padding": "12px 14px"}}><Icon name="sparkles" size={16} /><span className="sm grow">Include in the weekly AI digest for the client</span><button className={"toggle on" if digest else "toggle"} onClick={lambda { digest = not digest; }} aria-label="Include in digest" /></div>
            <div className="grow" />
            <div className="row g12 end"><Btn label="Save draft" kind="text" onClick={onClose} /><Btn label="Post log" icon="check" onClick={post} /></div>
        </div>
    </div>;
}

def:pub AskPanel(onClose: Callable[[], None]) -> JsxElement {
    has thread: list[any] = [],
        text: str = "",
        busy: bool = False,
        prompts: list[any] = [];
    async can with entry {
        p: any = await query("ask_prompts", {});
        prompts = p;
    }
    async def ask(q: str) -> None {
        if not q { return; }
        thread = thread + [{"me": True, "text": q}];
        text = "";
        busy = True;
        a: any = await command("ask", {"question": q});
        thread = thread + [{"me": False, "a": a}];
        busy = False;
    }
    return <div className="scrim" onClick={lambda { onClose(); }}>
        <div className="drawer" style={{"width": 460, "padding": 0, "gap": 0, "borderRadius": "32px 0 0 32px"}} onClick={lambda (e: MouseEvent) { e.stopPropagation(); }}>
            <div className="row g12" style={{"background": "#013d5a", "padding": "20px 24px", "borderRadius": "32px 0 0 0"}}>
                <span className="chip" style={{"background": "#0b4e6e", "color": "#f4a258", "width": 40, "height": 40}}><Icon name="sparkles" size={20} /></span>
                <div className="col g2 grow"><span className="b tinv">Ask Nirmana</span><span className="sm tmut">Reads Perera House data · never pays or approves</span></div>
                <button className="iconbtn" style={{"width": 36, "height": 36, "background": "#0b4e6e", "border": 0, "color": "#fcf3e3"}} onClick={lambda { onClose(); }}><Icon name="x" size={16} /></button>
            </div>
            <div className="col g12 grow" style={{"padding": 20, "overflow": "auto"}}>
                {len(thread) == 0 and <p className="t2 cent" style={{"marginTop": 40}}>Ask about cost, schedule or receipts. Answers cite the project data they used.</p>}
                {for (i, m) in enumerate(thread) {
                    <div key={str(i)} className="col" style={{"alignItems": "flex-end" if m["me"] else "flex-start"}}>
                        {m["me"] and <div className="r16 tinv" style={{"background": "#013d5a", "padding": "12px 16px", "maxWidth": "85%", "borderBottomRightRadius": 4}}>{m["text"]}</div>}
                        {(not m["me"]) and <div className="col g10 r16" style={{"background": "#fcf3e3", "padding": 16, "maxWidth": "95%"}}>
                            <div className="row g6 wrap">{for c in m["a"]["chips"] { <span key={c} className="pill bg-surface bd sm t2"><Icon name="search" size={12} />{c}</span> }}</div>
                            <p>{m["a"]["text"]}</p>
                            {for r in m["a"]["rows"] { <div key={r[0]} className="row between sm"><span>{r[0]}</span><Pill label={r[1]} tone="delayed" /></div> }}
                            {m["a"]["draft"] and <div className="col g8 r14 bg-surface bd" style={{"padding": 12}}><p className="sm">{"\"" + m["a"]["draft"] + "\""}</p><div className="row g8"><Btn label="Copy" kind="text" onClick={lambda { navigator.clipboard.writeText(m["a"]["draft"]); }} /><Btn label="Open in Messages" icon="message" kind="ghost" onClick={lambda { window.location.assign("/messages"); }} /></div></div>}
                        </div>}
                    </div>
                }}
                {busy and <div className="skel" style={{"height": 60, "width": "70%"}} />}
            </div>
            <div className="col g10" style={{"padding": "0 20px 20px"}}>
                <div className="row g8 wrap">{for p in prompts { <button key={p} className="btn ghost" style={{"padding": "7px 14px", "fontSize": 12}} onClick={lambda { ask(p); }}>{p}</button> }}</div>
                <div className="row g8 bd r999" style={{"padding": "6px 6px 6px 16px"}}>
                    <input style={{"border": 0, "outline": "none", "flex": 1, "background": "none"}} placeholder="Ask about cost, schedule, receipts…" value={text} onChange={lambda (e: ChangeEvent) { text = e.target.value; }} onKeyDown={lambda (e: KeyboardEvent) { if e.key == "Enter" { ask(text); } }} />
                    <Btn label="Ask" icon="sparkles" onClick={lambda { ask(text); }} />
                </div>
            </div>
        </div>
    </div>;
}

def:pub Overlays(ctx: any) -> JsxElement {
    ov: any = ctx["overlay"];
    toast: any = ctx["toastData"];
    name: str = ov["name"] if ov else "";
    async def run(action: str, payload: any, msg: str) -> None {
        ctx["closeOverlay"]();
        await ctx["run"](action, payload, msg);
    }
    return <div>
        {toast and <Toast msg={toast["msg"]} sub={toast["sub"]} />}
        {name == "confirm" and <Confirm data={ov["data"]} onClose={ctx["closeOverlay"]} />}
        {name == "ledger" and <LedgerDrawer data={ov["data"]} role={ctx["role"]} onClose={ctx["closeOverlay"]} onRun={run} />}
        {name == "certify" and <CertifyModal data={ov["data"]} onClose={ctx["closeOverlay"]} onRun={run} />}
        {name == "daily_log" and <DailyLogDrawer data={ov["data"]} onClose={ctx["closeOverlay"]} onRun={run} />}
        {name == "ask" and <AskPanel onClose={ctx["closeOverlay"]} />}
    </div>;
}
