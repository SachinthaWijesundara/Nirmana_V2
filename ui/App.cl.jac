"""Nirmana web UI: sign up / log in, then the projects you are on."""
# Jac 0.34's client caches server-call results for 60s and doesn't invalidate them after our writes,
# so every load and action below starts with __jacClearCache() to show fresh data.
import from "@jac/runtime" { jacLogin, jacSignup, jacLogout, jacIsLoggedIn, __jacClearCache }
sv import from ..api.access { create_profile, get_me }
sv import from ..api.projects { list_projects, create_project }
import from .ProjectView { ProjectView }

def errText(e: any) -> str {
    msg = str(e);
    if "error" in msg.lower() { return msg; }
    return "Something went wrong: " + msg;
}

def:pub App() -> JsxElement {
    has loggedIn: bool = False;
    has hasProfile: bool = False;
    has profile: dict = {};
    has projects: list[dict] = [];
    has selected: str = "";
    has mode: str = "login";
    has formEmail: str = "";
    has formPassword: str = "";
    has formName: str = "";
    has formRole: str = "client";
    has formPhone: str = "";
    has notice: str = "";
    has busy: bool = False;
    has pName: str = "";
    has pLocation: str = "";
    has pDistrict: str = "";
    has pType: str = "";
    has pArea: str = "";
    has pContract: str = "";
    has pStart: str = "";
    has pHandover: str = "";
    has pRole: str = "client";
    has pAdvance: str = "10";
    has pRetention: str = "5";
    has showNew: bool = False;

    async def refresh() -> None {

        __jacClearCache();
        me: any = None;
        rows: any = None;
        try {
            me = await get_me();
            if me and me["email"] {
                profile = me as dict;
                hasProfile = True;
                rows = await list_projects();
                projects = (rows as list[dict]) if rows else [];
            } else {
                hasProfile = False;
            }
        } except Exception {
            hasProfile = False;
        }
    }

    async can with entry {
        if jacIsLoggedIn() {
            loggedIn = True;
            await refresh();
        }
    }

    async def doLogin() -> None {

        __jacClearCache();
        ok: bool = False;
        busy = True;
        notice = "";
        try {
            ok = await jacLogin(formEmail.strip().lower(), formPassword);
            if ok {
                loggedIn = True;
                await refresh();
            } else { notice = "Wrong email or password."; }
        } except Exception as e { notice = errText(e); }
        busy = False;
    }

    async def doSignup() -> None {

        __jacClearCache();
        signup: dict | None = None;
        ok: bool = False;
        created: any = None;
        busy = True;
        notice = "";
        email = formEmail.strip().lower();
        try {
            signup = await jacSignup(email, formPassword);
            if not signup["success"] {
                notice = "Could not sign up. The email may already be registered.";
                busy = False;
                return;
            }
            ok = await jacLogin(email, formPassword);
            if not ok {
                notice = "Signed up, but logging in failed.";
                busy = False;
                return;
            }
            loggedIn = True;
            name = formName;
            role = formRole;
            phone = formPhone;
            created = await create_profile(name, email, role, phone);
            await refresh();
        } except Exception as e { notice = errText(e); }
        busy = False;
    }

    async def doCreateProfile() -> None {

        __jacClearCache();
        created: any = None;
        notice = "";
        try {
            name = formName;
            email = formEmail.strip().lower();
            role = formRole;
            phone = formPhone;
            created = await create_profile(name, email, role, phone);
            await refresh();
        } except Exception as e { notice = errText(e); }
    }

    async def doCreateProject() -> None {

        __jacClearCache();
        created: any = None;
        notice = "";
        try {
            name = pName;
            location = pLocation;
            district = pDistrict;
            building_type = pType;
            floor_area_sqft = float(pArea) if pArea != "" else 0.0;
            contract_sum = float(pContract) if pContract != "" else 0.0;
            start_date = pStart;
            handover_date = pHandover;
            my_role = pRole;
            advance_limit_pct = float(pAdvance) if pAdvance != "" else 10.0;
            retention_pct = float(pRetention) if pRetention != "" else 5.0;
            created = await create_project(name, location, district, building_type, floor_area_sqft, contract_sum, start_date, handover_date, my_role, advance_limit_pct, retention_pct);
            showNew = False;
            pName = "";
            await refresh();
        } except Exception as e { notice = errText(e); }
    }

    def doLogout(e: MouseEvent) {
        jacLogout();
        loggedIn = False;
        mode = "login";
        formEmail = "";
        formPassword = "";
        formName = "";
        formPhone = "";
        notice = "";
        hasProfile = False;
        profile = {};
        projects = [];
        selected = "";
    }

    async def backToList() -> None {

        __jacClearCache();
        selected = "";
        await refresh();
    }

    def submitAuth(e: FormEvent) {
        e.preventDefault();
        if mode == "login" { doLogin(); } else { doSignup(); }
    }

    def submitProfile(e: FormEvent) {
        e.preventDefault();
        doCreateProfile();
    }

    def submitProject(e: FormEvent) {
        e.preventDefault();
        doCreateProject();
    }

    if not loggedIn {
        return <div className="auth">
            <div className="brand">Nirmana <span>one honest record of your build</span></div>
            <form className="card" onSubmit={submitAuth}>
                <h2>{"Sign in" if mode == "login" else "Create your account"}</h2>
                <label>Email<input type="email" value={formEmail} onChange={lambda (e: ChangeEvent) { formEmail = e.target.value; }} required={True} /></label>
                <label>Password<input type="password" value={formPassword} onChange={lambda (e: ChangeEvent) { formPassword = e.target.value; }} required={True} /></label>
                {if mode == "signup" {
                    <label>Full name<input value={formName} onChange={lambda (e: ChangeEvent) { formName = e.target.value; }} required={True} /></label>
                    <label>Your role
                        <select value={formRole} onChange={lambda (e: ChangeEvent) { formRole = e.target.value; }}>
                            <option value="client">Client: owns and funds the build</option>
                            <option value="contractor">Contractor: builds and posts updates</option>
                            <option value="architect">Architect: designs and verifies work</option>
                        </select>
                    </label>
                    <label>Phone (optional)<input value={formPhone} onChange={lambda (e: ChangeEvent) { formPhone = e.target.value; }} /></label>
                }}
                <button type="submit" disabled={busy}>{"Sign in" if mode == "login" else "Sign up"}</button>
                {notice and <p className="error">{notice}</p>}
                <p className="muted">
                    {"No account? " if mode == "login" else "Have an account? "}
                    <a href="#" onClick={lambda (e: MouseEvent) { e.preventDefault(); mode = "signup" if mode == "login" else "login"; notice = ""; }}>{"Sign up" if mode == "login" else "Sign in"}</a>
                </p>
            </form>
        </div>;
    }

    if not hasProfile {
        return <div className="auth">
            <form className="card" onSubmit={submitProfile}>
                <h2>Finish your profile</h2>
                <label>Email (same as your login)<input type="email" value={formEmail} onChange={lambda (e: ChangeEvent) { formEmail = e.target.value; }} required={True} /></label>
                <label>Full name<input value={formName} onChange={lambda (e: ChangeEvent) { formName = e.target.value; }} required={True} /></label>
                <label>Your role
                    <select value={formRole} onChange={lambda (e: ChangeEvent) { formRole = e.target.value; }}>
                        <option value="client">Client</option>
                        <option value="contractor">Contractor</option>
                        <option value="architect">Architect</option>
                    </select>
                </label>
                <button type="submit">Save profile</button>
                {notice and <p className="error">{notice}</p>}
                <button type="button" className="link" onClick={doLogout}>Log out</button>
            </form>
        </div>;
    }

    return <div className="shell">
        <header className="topbar">
            <b className="logo" onClick={lambda (e: MouseEvent) { backToList(); }}>Nirmana</b>
            <span className="muted">{str(profile["name"]) + " · " + str(profile["email"])}</span>
            <button className="link" onClick={doLogout}>Log out</button>
        </header>
        {if selected != "" {
            <ProjectView projectId={selected} onBack={lambda { backToList(); }} />
        } else {
            <main className="page">
                <div className="row between">
                    <h1>Your projects</h1>
                    <button onClick={lambda (e: MouseEvent) { showNew = not showNew; }}>{"Close" if showNew else "+ New project"}</button>
                </div>
                {notice and <p className="error">{notice}</p>}
                {if showNew {
                    <form className="card grid" onSubmit={submitProject}>
                        <label>Name<input value={pName} onChange={lambda (e: ChangeEvent) { pName = e.target.value; }} required={True} /></label>
                        <label>Location<input value={pLocation} onChange={lambda (e: ChangeEvent) { pLocation = e.target.value; }} /></label>
                        <label>District<input value={pDistrict} onChange={lambda (e: ChangeEvent) { pDistrict = e.target.value; }} /></label>
                        <label>Building type<input value={pType} onChange={lambda (e: ChangeEvent) { pType = e.target.value; }} /></label>
                        <label>Floor area (sq ft)<input type="number" value={pArea} onChange={lambda (e: ChangeEvent) { pArea = e.target.value; }} /></label>
                        <label>Contract sum (Rs.)<input type="number" value={pContract} onChange={lambda (e: ChangeEvent) { pContract = e.target.value; }} /></label>
                        <label>Start date<input type="date" value={pStart} onChange={lambda (e: ChangeEvent) { pStart = e.target.value; }} /></label>
                        <label>Handover date<input type="date" value={pHandover} onChange={lambda (e: ChangeEvent) { pHandover = e.target.value; }} /></label>
                        <label>My role on it
                            <select value={pRole} onChange={lambda (e: ChangeEvent) { pRole = e.target.value; }}>
                                <option value="client">Client</option>
                                <option value="contractor">Contractor</option>
                                <option value="architect">Architect</option>
                            </select>
                        </label>
                        <label>Advance limit (%)<input type="number" value={pAdvance} onChange={lambda (e: ChangeEvent) { pAdvance = e.target.value; }} /></label>
                        <label>Retention (%)<input type="number" value={pRetention} onChange={lambda (e: ChangeEvent) { pRetention = e.target.value; }} /></label>
                        <button type="submit">Create project</button>
                    </form>
                }}
                {if len(projects) == 0 {
                    <p className="muted">No projects yet. Create one, or ask the client to invite you by email.</p>
                }}
                <div className="cards">
                    {for p in projects {
                        <div key={str(p["id"])} className="card project" onClick={lambda (e: MouseEvent) { selected = str(p["id"]); }}>
                            <div className="row between"><h3>{str(p["name"])}</h3><span className="badge">{str(p["my_role"])}</span></div>
                            <p className="muted">{str(p["location"]) + " · " + str(p["building_type"])}</p>
                            <p className="big">{str(p["built_pct"]) + "% verified built"}</p>
                            <p>{"Paid Rs. " + str(int(p["paid"] as float)) + " of Rs. " + str(int(p["revised_sum"] as float))}</p>
                            <p className="muted">{"Stage: " + (str(p["stage"]) if p["stage"] else "not started")}</p>
                        </div>
                    }}
                </div>
            </main>
        }}
    </div>;
}
