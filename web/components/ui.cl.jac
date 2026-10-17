"""Design-system atoms: Pill, Avatar, Btn, Chip, Bar, Ring, Field, Seg, Check."""

import from .Icon { Icon }

glob PILL_BG: dict[str, str] = {"done": "#dde6d7", "herb": "#dde6d7", "progress": "#fce4cc", "marigold": "#fce4cc", "delayed": "#f6d9cf", "danger": "#f6d9cf", "info": "#dceae6", "celeste": "#dceae6", "neutral": "#d5e3ea", "midnight": "#d5e3ea", "muted": "#f5ead5"};
glob PILL_DOT: dict[str, str] = {"done": "#708c69", "herb": "#708c69", "progress": "#f4a258", "marigold": "#f4a258", "delayed": "#c4553b", "danger": "#c4553b", "info": "#4f8a9e", "celeste": "#4f8a9e", "neutral": "#013d5a", "midnight": "#013d5a", "muted": "#cdbb9a"};
glob TONE_SOLID: dict[str, str] = {"celeste": "#bdd3ce", "marigold": "#f4a258", "herb": "#708c69", "midnight": "#013d5a", "danger": "#c4553b", "subtle": "#f5ead5", "muted": "#cdbb9a", "white": "#ffffff"};
glob TONE_TINT: dict[str, str] = {"celeste": "#dceae6", "marigold": "#fce4cc", "herb": "#dde6d7", "midnight": "#d5e3ea", "danger": "#f6d9cf", "neutral": "#d5e3ea", "info": "#dceae6", "progress": "#fce4cc", "delayed": "#f6d9cf", "muted": "#f5ead5", "subtle": "#f5ead5"};

def:pub Pill(label: str, tone: str = "info", dot: bool = True) -> JsxElement {
    bg = PILL_BG[tone] if tone in PILL_BG else "#dceae6";
    dc = PILL_DOT[tone] if tone in PILL_DOT else "#4f8a9e";
    return <span className="pill" style={{"background": bg}}>
        {dot and <i style={{"background": dc}} />}
        {label}
    </span>;
}

def:pub Avatar(initials: str, tone: str = "celeste", size: int = 40) -> JsxElement {
    bg = TONE_TINT[tone] if tone in TONE_TINT else "#bdd3ce";
    if tone == "celeste" { bg = "#bdd3ce"; }
    return <span className="avatar" style={{"width": size, "height": size, "background": bg, "fontSize": int(size * 0.35)}}>{initials}</span>;
}

def:pub Btn(label: str, onClick: Callable[[], None], kind: str = "primary", icon: str = "", disabled: bool = False, block: bool = False, lg: bool = False) -> JsxElement {
    def handle(e: MouseEvent) { if not disabled { onClick(); } }
    cls = "btn " + kind + (" block" if block else "") + (" lg" if lg else "");
    return <button className={cls} onClick={handle} disabled={disabled}>
        {icon and <Icon name={icon} size={16} />}
        {label}
    </button>;
}

def:pub Chip(icon: str, tone: str = "celeste", size: int = 44, iconSize: int = 22) -> JsxElement {
    bg = TONE_TINT[tone] if tone in TONE_TINT else "#dceae6";
    if tone == "celeste" { bg = "#bdd3ce"; }
    return <span className="chip" style={{"width": size, "height": size, "background": bg, "borderRadius": int(size * 0.33), "color": "#013d5a"}}>
        <Icon name={icon} size={iconSize} />
    </span>;
}

def:pub Bar(pct: float, tone: str = "herb", height: int = 8) -> JsxElement {
    fill = TONE_SOLID[tone] if tone in TONE_SOLID else "#708c69";
    width = str(Math.min(100, Math.max(0, pct))) + "%";
    return <div className="bar" style={{"height": height}}><div style={{"width": width, "background": fill}} /></div>;
}

def:pub Ring(score: int, size: int = 40, tone: str = "herb", stroke: int = 4, label: bool = True) -> JsxElement {
    r = (size - stroke) / 2;
    circ = 2 * 3.14159265 * r;
    color = TONE_SOLID[tone] if tone in TONE_SOLID else "#708c69";
    return <div style={{"position": "relative", "width": size, "height": size, "flexShrink": 0}}>
        <svg width={size} height={size} style={{"transform": "rotate(-90deg)"}}>
            <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke="#f5ead5" strokeWidth={stroke} />
            <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke={color} strokeWidth={stroke} strokeLinecap="round" strokeDasharray={str(circ * score / 100) + " " + str(circ)} />
        </svg>
        {label and <span className="xb sm" style={{"position": "absolute", "inset": 0, "display": "flex", "alignItems": "center", "justifyContent": "center"}}>{score}</span>}
    </div>;
}

def:pub Field(label: str, value: str, onChange: Callable[[str], None], type: str = "text", hint: str = "") -> JsxElement {
    def handle(e: ChangeEvent) { onChange(e.target.value); }
    return <div className="field">
        <label className="label">{label}</label>
        <input className="input" type={type} value={value} onChange={handle} placeholder={hint} />
    </div>;
}

def:pub Seg(options: list[str], value: str, onChange: Callable[[str], None]) -> JsxElement {
    return <div className="seg">
        {for o in options {
            <button key={o} className={"on" if o == value else ""} onClick={lambda { onChange(o); }}>{o}</button>
        }}
    </div>;
}

def:pub Check(on: bool) -> JsxElement {
    return <span className={"cbox on" if on else "cbox"}>{on and <Icon name="check" size={14} />}</span>;
}

def:pub Tabs(items: list[str], value: str, onChange: Callable[[str], None]) -> JsxElement {
    return <div className="row g8">
        {for t in items {
            <button key={t} className={"tab on" if t == value else "tab"} onClick={lambda { onChange(t); }}>{t}</button>
        }}
    </div>;
}

def:pub Overline(text: str) -> JsxElement {
    return <p className="over t2">{text}</p>;
}

def:pub CardHead(title: str, right: str = "") -> JsxElement {
    return <div className="row g8 between">
        <p className="h3 grow">{title}</p>
        {right and <p className="sm t2 nowrap">{right}</p>}
    </div>;
}
