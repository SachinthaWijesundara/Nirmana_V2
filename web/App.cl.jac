"""App root: shared state (context), routes and the global overlays (toast, confirm, drawers)."""

import from "@jac/runtime" { Router, Routes, Route, Navigate }
import from .hooks.app { AppCtx, useApp }
import from .backend.index { query, command }
import from .overlays.Overlays { Overlays }
import from .screens.SignIn { SignIn }
import from .screens.Dashboard { Dashboard }
import from .screens.Projects { Projects }
import from .screens.Approvals { Approvals }
import from .screens.Messages { Messages }
import from .screens.Tools { Estimator, Calculators, Market }
import from .screens.StatesPage { StatesPage }
import from .screens.ProjectTabs { ProjectTab }

def:pub Guard(children: any = None) -> JsxElement {
    app = useApp();
    if not app["signedIn"] { return <Navigate to="/" replace={True} />; }
    return <div>{children}</div>;
}

def:pub App() -> JsxElement {
    has role: str = "",
        user: any = {"name": "", "initials": "", "role": "", "tone": "celeste"},
        badges: any = {"approvals": 0, "messages": 0},
        toast: any = None,
        overlay: any = None,
        booted: bool = False;

    async def load_session(r: str) -> None {
        s: any = await query("session", {"role": r});
        user = s["user"];
        badges = s["badges"];
        role = r;
    }
    async def sign_in(r: str) -> None {
        await load_session(r);
        try { localStorage.setItem("nirmana.role", r); } except Exception { }
    }
    async def refresh() -> None {
        if role { await load_session(role); }
    }
    def sign_out() {
        role = "";
        try { localStorage.removeItem("nirmana.role"); } except Exception { }
    }
    def show_toast(msg: str, sub: str = "") {
        toast = {"msg": msg, "sub": sub};
        setTimeout(lambda { toast = None; }, 3600);
    }
    async def run_command(action: str, payload: any, msg: str, reload: any = None) -> None {
        try {
            result: any = await command(action, payload);
            show_toast(msg or str(result["message"]), "Logged to Activity · just now");
        } except Exception as e {
            show_toast("That did not go through", str(e));
        }
        await refresh();
        if reload { reload(); }
    }
    async def decide(id: str, decision: str, reload: any) -> None {
        await run_command("decide_approval", {"id": id, "decision": decision}, "", reload);
    }
    def open_overlay(name: str, data: any) { overlay = {"name": name, "data": data}; }
    def close_overlay() { overlay = None; }

    async can with entry {
        try {
            saved: any = localStorage.getItem("nirmana.role");
            if saved { await load_session(str(saved)); }
        } except Exception { }
        booted = True;
    }

    ctx = {
        "role": role, "user": user, "badges": badges, "signedIn": bool(role), "overlay": overlay,
        "signIn": sign_in, "signOut": sign_out, "switchRole": sign_in, "refresh": refresh,
        "toast": show_toast, "toastData": toast, "run": run_command, "decide": decide, "openOverlay": open_overlay, "closeOverlay": close_overlay
    };

    if not booted { return <div className="app" />; }
    return <AppCtx.Provider value={ctx}>
        <Router>
            <Routes>
                <Route path="/" element={<Navigate to="/dashboard" replace={True} /> if role else <SignIn />} />
                <Route path="/dashboard" element={<Guard><Dashboard /></Guard>} />
                <Route path="/projects" element={<Guard><Projects /></Guard>} />
                <Route path="/projects/:id" element={<Navigate to="overview" replace={True} />} />
                <Route path="/projects/:id/:tab" element={<Guard><ProjectTab /></Guard>} />
                <Route path="/approvals" element={<Guard><Approvals /></Guard>} />
                <Route path="/messages" element={<Guard><Messages /></Guard>} />
                <Route path="/estimator" element={<Guard><Estimator /></Guard>} />
                <Route path="/calculators" element={<Guard><Calculators /></Guard>} />
                <Route path="/market" element={<Guard><Market /></Guard>} />
                <Route path="/states" element={<Guard><StatesPage /></Guard>} />
                <Route path="*" element={<Navigate to="/" replace={True} />} />
            </Routes>
        </Router>
        <Overlays ctx={ctx} />
    </AppCtx.Provider>;
}
