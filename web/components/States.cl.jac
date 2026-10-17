"""Loading, empty and error states (design page 50) and the Gate that picks one."""

import from .Icon { Icon }
import from .ui { Btn, Chip }

def:pub Skeleton(rows: int = 3) -> JsxElement {
    return <div className="card col g12">
        <div className="skel" style={{"height": 18, "width": 160}} />
        <div className="row g12">
            <div className="skel" style={{"height": 44, "width": 44}} />
            <div className="col g6 grow"><div className="skel" style={{"height": 14, "width": "60%"}} /><div className="skel" style={{"height": 12, "width": "40%"}} /></div>
        </div>
        {for i in range(rows) {
            <div key={str(i)} className="skel" style={{"height": 40, "opacity": 1 - i * 0.2}} />
        }}
    </div>;
}

def:pub EmptyState(title: str, body: str, action: str = "", onAction: Callable[[], None] | None = None) -> JsxElement {
    def go() { if onAction { onAction(); } }
    return <div className="card col g12 cent" style={{"alignItems": "center", "padding": 48}}>
        <Chip icon="camera" tone="celeste" size={56} iconSize={28} />
        <p className="b">{title}</p>
        <p className="t2" style={{"maxWidth": 340}}>{body}</p>
        {action and <Btn label={action} kind="ghost" onClick={go} />}
    </div>;
}

def:pub ErrorState(what: str, code: str, onRetry: Callable[[], None]) -> JsxElement {
    return <div className="card col g12">
        <div className="alert">
            <span className="chip" style={{"background": "#f6d9cf", "color": "#c4553b"}}><Icon name="alert" size={18} /></span>
            <div className="col g2 grow"><p className="b">{"Couldn't load the " + what}</p><p className="sm t2">The server did not answer. Your data is safe. Try again in a moment.</p></div>
        </div>
        <div className="sub r12 pad12 col"><span className="sm t2">Error code</span><span className="b sm">{code}</span></div>
        <div><Btn label="Try again" onClick={onRetry} /></div>
    </div>;
}

"""Render children only when the resource has loaded; otherwise a skeleton or an error with retry."""
def:pub Gate(res: dict[str, any], what: str, children: any = None) -> JsxElement {
    if res["error"] {
        return <ErrorState what={what} code={"GET /api/" + str(res["resource"]) + " · failed"} onRetry={res["reload"]} />;
    }
    if res["loading"] and not res["data"] {
        return <Skeleton rows={4} />;
    }
    return <div className="col g24" style={{"width": "100%"}}>{children}</div>;
}
