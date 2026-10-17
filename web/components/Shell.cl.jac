"""App chrome: Sidebar, TopBar, Page and ProjectShell (project header + tabs)."""

import from "@jac/runtime" { Link, useLocation, useParams }
import from .Icon { Icon }
import from .ui { Avatar, Pill, Ring }
import from .States { Gate }
import from ..hooks.app { useApp, useResource }

def:pub Logo(size: int = 36) -> JsxElement {
    return <div className="row g12">
        <span className="logo-mark" style={{"width": size, "height": size}}><Icon name="box" size={int(size * 0.55)} /></span>
        <span className="h2 tinv">Nirmana</span>
    </div>;
}

def:pub NavItem(href: str, icon: str, label: str, active: bool, badge: int = 0) -> JsxElement {
    return <Link to={href} className={"nav on" if active else "nav"}>
        <Icon name={icon} size={20} />
        <span className="grow hide">{label}</span>
        {badge > 0 and <span className="badge hide">{badge}</span>}
    </Link>;
}

def:pub Sidebar() -> JsxElement {
    app = useApp();
    loc = useLocation();
    has menuOpen: bool = False;
    path: str = loc["pathname"];
    user: any = app["user"];
    badges: any = app["badges"];
    def toggle(e: MouseEvent) { menuOpen = not menuOpen; }
    def pick(r: str) {
        menuOpen = False;
        app["switchRole"](r);
    }
    return <aside className="side">
        <Logo />
        <div className="usercard">
            <Avatar initials={user["initials"]} tone={user["tone"]} size={64} />
            <span className="sm tmut hide">Welcome back,</span>
            <span className="h3 tinv hide">{user["name"]}</span>
            <button className="rolechip hide" onClick={toggle}>{user["role"]}<Icon name="chevron-down" size={12} /></button>
            {menuOpen and <div className="menu">
                {for r in ["client", "contractor", "architect"] {
                    <button key={r} onClick={lambda { pick(r); }}>{r[0].toUpperCase() + r[1:]}</button>
                }}
            </div>}
        </div>
        <div className="col g4">
            <p className="over tmut hide">Menu</p>
            <NavItem href="/dashboard" icon="grid" label="Dashboard" active={path == "/dashboard"} />
            <NavItem href="/projects" icon="folder" label="Projects" active={path.startsWith("/projects")} />
            <NavItem href="/approvals" icon="circle-check" label="Approvals" active={path == "/approvals"} badge={badges["approvals"]} />
            <NavItem href="/messages" icon="message" label="Messages" active={path == "/messages"} badge={badges["messages"]} />
        </div>
        <div className="col g4">
            <p className="over tmut hide">Tools</p>
            <NavItem href="/estimator" icon="calculator" label="Estimator" active={path == "/estimator"} />
            <NavItem href="/calculators" icon="ruler" label="Calculators" active={path == "/calculators"} />
            <NavItem href="/market" icon="trend" label="Market prices" active={path == "/market"} />
        </div>
        <div className="grow" />
        <div className="col g4">
            <p className="over tmut hide">Account</p>
            <NavItem href="/states" icon="sliders" label="Settings" active={path == "/states"} />
            <button className="nav" onClick={lambda { app["signOut"](); }}><Icon name="logout" size={20} /><span className="grow hide">Log out</span></button>
        </div>
    </aside>;
}

def:pub TopBar(title: str, subtitle: str) -> JsxElement {
    return <div className="topbar">
        <div className="col g2 grow" style={{"minWidth": 0}}>
            <h1 className="h1 ell">{title}</h1>
            <p className="t2 ell">{subtitle}</p>
        </div>
        <label className="search"><Icon name="search" size={18} /><input placeholder="Search projects, invoices, logs" /></label>
        <button className="iconbtn" aria-label="Notifications"><Icon name="bell" size={20} /></button>
    </div>;
}

def:pub Page(title: str, subtitle: str, children: any = None, right: any = None) -> JsxElement {
    return <div className="app">
        <Sidebar />
        <div className="main">
            <TopBar title={title} subtitle={subtitle} />
            {children}
        </div>
        {right}
    </div>;
}

def:pub ProjectShell(tab: str, children: any = None) -> JsxElement {
    params = useParams();
    pid: str = params["id"] or "perera-house";
    res = useResource("project", {"id": pid});
    app = useApp();
    data: any = res["data"];
    title = "";
    for t in (data["tabs"] if data else []) {
        if t["id"] == tab { title = t["label"]; }
    }
    sub = "Projects / " + (data["project"]["name"] if data else "");
    return <Page title={title or "Project"} subtitle={sub}>
        <Gate res={res} what="project">
            {data and <div className="card col g16" style={{"padding": 20}}>
                <div className="row g16 wrap">
                    <span className="chip" style={{"width": 56, "height": 56, "borderRadius": 18, "background": "#bdd3ce", "color": "#013d5a"}}><Icon name="home" size={26} /></span>
                    <div className="col g2">
                        <div className="row g12">
                            <h2 className="h2">{data["project"]["name"]}</h2>
                            <Pill label={data["project"]["stage"]} tone="progress" />
                        </div>
                        <p className="sm t2">{data["project"]["short"]}</p>
                    </div>
                    <div className="grow" />
                    <div className="row g12"><Avatar initials="NP" tone="celeste" size={40} /><div className="col"><span className="b">Nimali Perera</span><span className="sm t2">Client</span></div></div>
                    <div className="row g12"><Avatar initials="RS" tone="marigold" size={40} /><div className="col"><span className="b">R. Silva Builders</span><span className="sm t2">Contractor</span></div></div>
                    <div className="row g12"><Avatar initials="AF" tone="herb" size={40} /><div className="col"><span className="b">Anushka Fernando</span><span className="sm t2">Architect</span></div></div>
                    <div className="row g12 sub r16" style={{"padding": "8px 16px 8px 8px"}}>
                        <Ring score={data["project"]["score"]} size={44} stroke={4} label={True} />
                        <div className="col"><span className="sm t2">Transparency</span><span className="sm b">{data["project"]["score_label"]} · +4</span></div>
                    </div>
                </div>
                <div className="row g4 wrap">
                    {for t in data["tabs"] {
                        <Link key={t["id"]} to={"/projects/" + pid + "/" + t["id"]} className={"tab on" if t["id"] == tab else "tab"}>{t["label"]}</Link>
                    }}
                </div>
            </div>}
            {children}
        </Gate>
        <button className="fab" onClick={lambda { app["openOverlay"]("ask", {}); }}><Icon name="sparkles" size={18} />Ask Nirmana</button>
    </Page>;
}
