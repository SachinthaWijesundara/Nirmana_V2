"""Midnight sidebar: brand, homeowner card, navigation and the builder note (Figma "Sidebar · Hackathon")."""
import from .Icon { Icon }

glob NAV_ITEMS: list[tuple[str, str, str]] = [
    ("twin", "Twin", "home"),
    ("guard", "Payment Guard", "shield"),
    ("forecast", "Forecast & what-if", "trend"),
    ("graph", "Twin graph", "layers"),
    ("ask", "Ask the twin", "sparkle")
];

def:pub Sidebar(active: str, heldCount: int, onNavigate: Callable[[str], None]) -> JsxElement {
    return <aside className="sidebar">
        <div className="row" style={{"gap": "12px"}}>
            <span className="brand-mark"><Icon name="logo" size={20}/></span>
            <div>
                <div className="h2">Nirmana</div>
                <div className="small" style={{"color": "var(--text-inverse-muted)"}}>Digital twin</div>
            </div>
        </div>

        <div className="profile">
            <div className="avatar">NP</div>
            <div className="small" style={{"color": "var(--text-inverse-muted)"}}>Homeowner</div>
            <div className="h3">Nimal Perera</div>
            <span className="pill" style={{"background": "var(--marigold)", "color": "var(--midnight)", "marginTop": "6px"}}>
                Watching from Doha, Qatar
            </span>
        </div>

        <nav className="nav" aria-label="Main">
            <div className="overline" style={{"color": "var(--text-inverse-muted)", "padding": "0 0 8px"}}>Perera House, Kandy</div>
            {for (key, label, icon) in NAV_ITEMS {
                <button key={key} className={"nav-item active" if key == active else "nav-item"}
                    aria-current={"page" if key == active else None}
                    onClick={lambda { onNavigate(key); }}>
                    <Icon name={icon} size={18}/>
                    <span>{label}</span>
                    {key == "guard" and heldCount > 0 and <span className="badge">{heldCount}</span>}
                </button>
            }}
        </nav>

        <div className="sidebar-note">
            <div className="row small"><Icon name="chat" size={16}/> <span>Builder: Ruwan Silva</span></div>
            <p className="small" style={{"color": "var(--text-inverse-muted)", "margin": "8px 0 0"}}>
                Sends updates by text, the stand-in for WhatsApp.
            </p>
        </div>
    </aside>;
}
