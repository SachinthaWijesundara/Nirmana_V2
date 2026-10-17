"""31 Messages: project chat, direct messages and the AI assistant."""

import from ..components.Icon { Icon }
import from ..components.ui { Avatar, Btn, Pill, Chip }
import from ..components.States { Gate }
import from ..components.Shell { Page }
import from ..hooks.app { useApp, useResource }
import from ..backend.index { command }

def:pub Messages() -> JsxElement {
    app = useApp();
    threads = useResource("threads", {});
    has current: str = "ph", text: str = "", aiThread: list[any] = [], busy: bool = False, tick: int = 0;
    chat = useResource("thread", {"id": current, "tick": tick});
    tl: list[any] = threads["data"] or [];
    cd: any = chat["data"];
    user: any = app["user"];
    active: any = None;
    for t in tl { if t["id"] == current { active = t; } }

    async def send() -> None {
        body = text;
        if not body { return; }
        text = "";
        if current == "ai" {
            acc = aiThread + [{"mine": True, "text": body}];
            aiThread = acc;
            busy = True;
            a: any = await command("ask", {"question": body});
            acc = acc + [{"mine": False, "text": a["text"]}];
            aiThread = acc;
            busy = False;
        } else {
            await command("send_message", {"thread": current, "text": body, "initials": user["initials"], "name": user["name"], "role": user["role"], "tone": user["tone"]});
            tick = tick + 1;
        }
    }
    async def open_thread(id: str) -> None {
        current = id;
        await command("mark_read", {"thread": id});
        threads["reload"]();
        await app["refresh"]();
    }
    return <Page title="Messages" subtitle="Project chat, direct messages and the AI assistant">
        <Gate res={threads} what="messages">
            <div className="row g16 top" style={{"minHeight": 720}}>
                <div className="card col g8" style={{"width": 320, "flexShrink": 0, "padding": 16, "borderRadius": 28}}>
                    <label className="search" style={{"width": "100%", "background": "#fcf3e3", "border": 0, "padding": "10px 14px"}}><Icon name="search" size={16} /><input placeholder="Search messages" className="sm" /></label>
                    {for t in tl {
                        <button key={t["id"]} className="row g12 r16" style={{"padding": 10, "textAlign": "left", "background": "#d5e3ea" if t["id"] == current else "transparent"}} onClick={lambda { open_thread(t["id"]); }}>
                            {t["id"] == "ai" and <Chip icon="sparkles" tone="herb" size={44} iconSize={20} />}
                            {t["id"] != "ai" and <Avatar initials={t["initials"]} tone={t["tone"]} size={44} />}
                            <div className="col g2 grow" style={{"minWidth": 0}}>
                                <div className="row g6"><span className="b grow ell">{t["name"]}</span><span className="sm t2 nowrap">{t["when"]}</span></div>
                                <div className="row g6"><span className="sm t2 grow ell">{t["last"]}</span>{t["unread"] > 0 and <span className="badge">{t["unread"]}</span>}</div>
                            </div>
                        </button>
                    }}
                </div>
                <div className="card col grow" style={{"padding": 0, "borderRadius": 28, "minWidth": 0, "overflow": "hidden"}}>
                    <div className="row g12 hr" style={{"padding": "16px 20px"}}>
                        <Chip icon="home" tone="celeste" size={40} iconSize={20} />
                        <div className="col grow"><span className="h3">{active["name"] if active else ""}</span><span className="sm t2">{active["members"] if active else ""}</span></div>
                        <Icon name="dots" size={20} />
                    </div>
                    <div className="col g12 grow" style={{"padding": 20, "overflow": "auto"}}>
                        <div className="cent"><Pill label="Today" tone="muted" /></div>
                        {current != "ai" and cd and cd["messages"].map(lambda m: any -> any { return <div key={m["time"] + m["text"]} className="row g10 bot" style={{"justifyContent": "flex-end" if m["mine"] else "flex-start"}}>
                            {(not m["mine"]) and <Avatar initials={m["from"]} tone={m["tone"]} size={32} />}
                            <div className="col g8 r16" style={{"background": "#013d5a" if m["mine"] else "#fcf3e3", "color": "#fcf3e3" if m["mine"] else "#0b2b3c", "padding": "12px 14px", "maxWidth": "72%"}}>
                                {(not m["mine"]) and <span className="sm b">{m["name"] + " · " + m["role"]}</span>}
                                <span>{m["text"]}</span>
                                {m["photos"] > 0 and <div className="row g6">{[0, 1].slice(0, m["photos"]).map(lambda i: any -> any { return <span key={str(i)} className="ph" style={{"width": 90, "height": 64, "background": "#fce4cc" if i == 0 else "#dceae6"}}><Icon name="camera" size={16} /></span>; })}</div>}
                                <span className="sm" style={{"opacity": 0.7}}>{m["time"]}</span>
                            </div>
                        </div>; })}
                        {current == "ai" and len(aiThread) == 0 and <p className="t2 cent" style={{"marginTop": 40}}>Ask about cost, schedule or receipts. I read the project data and never pay or approve anything.</p>}
                        {current == "ai" and aiThread.map(lambda m: any -> any { return <div key={m["text"]} className="row" style={{"justifyContent": "flex-end" if m["mine"] else "flex-start"}}><div className="r16" style={{"background": "#013d5a" if m["mine"] else "#fcf3e3", "color": "#fcf3e3" if m["mine"] else "#0b2b3c", "padding": "12px 14px", "maxWidth": "72%"}}>{m["text"]}</div></div>; })}
                        {busy and <div className="skel" style={{"height": 48, "width": "50%"}} />}
                        {current == "ph" and cd and cd["note"] and <div className="row g12 r14 bg-tcel" style={{"padding": "12px 14px"}}><Icon name="alert" size={16} /><span className="sm">{cd["note"]}</span></div>}
                    </div>
                    <div className="row g8 bd r999" style={{"margin": 20, "padding": "6px 6px 6px 16px"}}>
                        <Icon name="camera" size={18} />
                        <input style={{"border": 0, "outline": "none", "flex": 1, "background": "none", "padding": "0 8px"}} placeholder="Write a message…" value={text} onChange={lambda (e: ChangeEvent) { text = e.target.value; }} onKeyDown={lambda (e: KeyboardEvent) { if e.key == "Enter" { send(); } }} />
                        <Btn label="Send" onClick={lambda { send(); }} />
                    </div>
                </div>
                <div className="col g16" style={{"width": 280, "flexShrink": 0}}>
                    <div className="card col g12" style={{"padding": 20}}>
                        <p className="h3">Pinned</p>
                        {cd and cd["pinned"].map(lambda p: any -> any { return <div key={p["text"]} className="row g10"><Chip icon={p["icon"]} tone="subtle" size={34} iconSize={16} /><span className="sm">{p["text"]}</span></div>; })}
                    </div>
                    <div className="col g8 r24" style={{"background": "#dde6d7", "padding": 20, "borderRadius": 24}}>
                        <p className="b">From WhatsApp</p>
                        <p className="sm t2">Builder messages sent on WhatsApp land here too, and become alerts when they mention money or delays.</p>
                    </div>
                </div>
            </div>
        </Gate>
    </Page>;
}
