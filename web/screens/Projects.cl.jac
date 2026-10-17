"""02 Projects: one card per project, filter tabs and a start-a-project card."""

import from "@jac/runtime" { useNavigate }
import from ..components.Icon { Icon }
import from ..components.ui { Btn, Pill, Avatar, Ring, Bar, Tabs }
import from ..components.States { Gate, EmptyState }
import from ..components.Shell { Page }
import from ..hooks.app { useApp, useResource }

glob COVER: dict[str, list[str]] = {"celeste": ["#bdd3ce", "#0b2b3c"], "herb": ["#708c69", "#fcf3e3"], "marigold": ["#f4a258", "#0b2b3c"], "midnight": ["#013d5a", "#fcf3e3"]};
glob AV_TONES: list[str] = ["celeste", "marigold", "herb"];

def:pub ProjectCard(p: any, onOpen: Callable[[], None]) -> JsxElement {
    cv = COVER[p["cover"]];
    done: bool = p["pct"] >= 60;
    return <div className="col g16 click" style={{"width": 360, "background": "#fff", "borderRadius": 26, "padding": "12px 12px 20px"}} onClick={lambda { onOpen(); }}>
        <div className="col between" style={{"height": 132, "background": cv[0], "color": cv[1], "borderRadius": 18, "padding": 16}}>
            <div className="row g8"><Pill label={p["status"]} tone={p["status_tone"]} /><div className="grow" /><span className="chip s bg-surface" style={{"width": 32, "height": 32, "color": "#0b2b3c"}}><Icon name="arrow-up-right" size={16} /></span></div>
            <div className="row g10 bot"><span className="huge" style={{"fontSize": 40, "lineHeight": "48px"}}>{str(p["pct"]) + "%"}</span><span className="b" style={{"paddingBottom": 6}}>built</span><div className="grow" /><Icon name="home" size={40} /></div>
        </div>
        <div className="col g14" style={{"padding": "0 8px"}}>
            <div className="col g2"><p className="h2">{p["name"]}</p><p className="t2">{p["place"]}</p></div>
            <div className="col g8"><div className="row between sm"><span className="t2">Stage</span><span className="b">{p["stage"]}</span></div><Bar pct={p["pct"]} tone={"herb" if done else "marigold"} /></div>
            <div className="row g12">
                <div className="col g2 grow bg-page r14" style={{"padding": "10px 12px"}}><span className="sm t2">Paid</span><span className="b">{p["paid"]}</span></div>
                <div className="col g2 grow bg-page r14" style={{"padding": "10px 12px"}}><span className="sm t2">Contract</span><span className="b">{p["contract"]}</span></div>
            </div>
            <div className="row g10">
                <div className="row">{for (i, t) in enumerate(p["team"]) { <span key={t} style={{"marginRight": -10, "border": "2px solid #fff", "borderRadius": 999}}><Avatar initials={t} tone={AV_TONES[i]} size={34} /></span> }}</div>
                <div className="grow" />
                <Ring score={p["score"]} size={40} tone={"herb" if p["score"] >= 70 else "danger"} />
                <div className="col sm"><span className="t2">Transparency</span><span className="b">{p["score_label"]}</span></div>
            </div>
            <div className="row g8 sub r12 sm" style={{"padding": "10px 12px"}}><Icon name="calendar" size={16} />{p["next"]}</div>
        </div>
    </div>;
}

def:pub Projects() -> JsxElement {
    app = useApp();
    nav = useNavigate();
    res = useResource("projects", {});
    has filter: str = "All";
    items: list[any] = res["data"] or [];
    active = len([p for p in items if p["group"] == "active"]);
    handover = len([p for p in items if p["group"] == "handover"]);
    labels = ["All · " + str(len(items)), "Active · " + str(active), "Handover · " + str(handover), "Archived"];
    shown = [p for p in items if filter.startswith("All") or (filter.startswith("Active") and p["group"] == "active") or (filter.startswith("Handover") and p["group"] == "handover")];
    current = labels[0];
    for l in labels { if l.startswith(filter.split(" ")[0]) { current = l; } }
    return <Page title="Projects" subtitle={str(len(items)) + " projects · " + str(active) + " active, " + str(handover) + " in handover"}>
        <div className="row g8">
            <Tabs items={labels} value={current} onChange={lambda v: str { filter = v.split(" ")[0]; }} />
            <div className="grow" />
            <Btn label="From estimate" icon="sparkles" kind="ghost" onClick={lambda { nav("/estimator"); }} />
            <Btn label="New project" icon="plus" kind="accent" onClick={lambda { app["run"]("create_project", {"name": "Untitled"}, "Project created (demo)"); }} />
        </div>
        <Gate res={res} what="projects">
            <div className="row wrap g20 top">
                {for p in shown { <ProjectCard key={p["id"]} p={p} onOpen={lambda { nav("/projects/" + p["id"] + "/overview"); }} /> }}
                {len(shown) == 0 and <EmptyState title="No projects here" body="Projects in this state will show up here." />}
                <div className="col g12 dash" style={{"width": 360, "height": 486, "alignItems": "center", "justifyContent": "center", "padding": 24}}>
                    <span className="chip bg-marigold" style={{"width": 56, "height": 56, "borderRadius": 19}}><Icon name="plus" size={28} /></span>
                    <p className="h3">Start a new project</p>
                    <p className="t2 cent" style={{"width": 260}}>Begin from an estimate, or set up a blank project and invite your contractor and architect.</p>
                    <div className="row g8"><Btn label="From estimate" icon="sparkles" kind="ghost" onClick={lambda { nav("/estimator"); }} /><Btn label="Blank" kind="text" onClick={lambda { app["run"]("create_project", {"name": "Blank"}, "Project created (demo)"); }} /></div>
                </div>
            </div>
        </Gate>
    </Page>;
}
