"""Cards reused across screens: StatCard, AlertCard, MessageRow, KpiCard, RoleNote."""

import from .Icon { Icon }
import from .ui { Chip, Avatar, Pill }

glob STAT_STYLE: dict[str, dict[str, str]] = {
    "celeste": {"bg": "#bdd3ce", "fg": "#0b2b3c", "chip": "#ffffff", "delta": "#ffffff", "dfg": "#0b2b3c", "ico": "#013d5a"},
    "marigold": {"bg": "#f4a258", "fg": "#0b2b3c", "chip": "#fce4cc", "delta": "#fce4cc", "dfg": "#0b2b3c", "ico": "#c4553b"},
    "herb": {"bg": "#708c69", "fg": "#fcf3e3", "chip": "#dde6d7", "delta": "#dde6d7", "dfg": "#708c69", "ico": "#4c6a46"},
    "midnight": {"bg": "#013d5a", "fg": "#fcf3e3", "chip": "#0b4e6e", "delta": "#0b4e6e", "dfg": "#f4a258", "ico": "#f4a258"},
    "white": {"bg": "#ffffff", "fg": "#0b2b3c", "chip": "#fce4cc", "delta": "#f5ead5", "dfg": "#0b2b3c", "ico": "#013d5a"}
};

def:pub StatCard(tone: str, icon: str, label: str, value: str, sub: str, delta: str = "") -> JsxElement {
    st = STAT_STYLE[tone];
    return <div className="stat" style={{"background": st["bg"], "color": st["fg"]}}>
        <div className="row g10">
            <span className="chip s" style={{"background": st["chip"], "color": st["ico"]}}><Icon name={icon} size={16} /></span>
            <div className="grow" />
            {delta and <span className="delta" style={{"background": st["delta"], "color": st["dfg"]}}>{delta}</span>}
        </div>
        <p className="b">{label}</p>
        <p className="xl nowrap">{value}</p>
        <p className="sm" style={{"opacity": 0.8}}>{sub}</p>
    </div>;
}

glob ALERT_STYLE: dict[str, list[str]] = {"danger": ["#f6d9cf", "alert", "#c4553b"], "warn": ["#fce4cc", "rain", "#c4553b"], "info": ["#dceae6", "sparkles", "#4f8a9e"]};

def:pub AlertCard(level: str, title: str, body: str) -> JsxElement {
    st = ALERT_STYLE[level] if level in ALERT_STYLE else ALERT_STYLE["info"];
    return <div className="alert">
        <span className="chip" style={{"background": st[0], "color": st[2]}}><Icon name={st[1]} size={18} /></span>
        <div className="col g2 grow" style={{"minWidth": 0}}><p className="b">{title}</p><p className="sm t2">{body}</p></div>
    </div>;
}

def:pub MessageRow(name: str, initials: str, tone: str, when: str, text: str) -> JsxElement {
    return <div className="row g12 top bg-page r16 pad12">
        <Avatar initials={initials} tone={tone} size={40} />
        <div className="col g2 grow" style={{"minWidth": 0}}>
            <div className="row g6"><span className="b grow">{name}</span><span className="sm t2 nowrap">{when}</span></div>
            <p className="sm t2">{text}</p>
        </div>
    </div>;
}

def:pub KpiCard(label: str, value: str, pill: str, tone: str) -> JsxElement {
    return <div className="card col g8" style={{"padding": "18px 20px", "borderRadius": 20}}>
        <p className="sm t2">{label}</p>
        <p className="h1" style={{"fontWeight": 800}}>{value}</p>
        <div><Pill label={pill} tone={tone} /></div>
    </div>;
}

def:pub Note(text: str, tone: str = "info", icon: str = "info") -> JsxElement {
    bg = "#dceae6" if tone == "info" else "#fce4cc";
    return <div className="row g12 top r16" style={{"background": bg, "padding": "14px 16px"}}>
        <Icon name={icon} size={20} />
        <p className="sm grow">{text}</p>
    </div>;
}

def:pub Lock(title: str, body: str) -> JsxElement {
    return <div className="col g2 r12" style={{"background": "#013d5a", "padding": "12px 16px"}}>
        <p className="b tinv row g6"><Icon name="shield" size={14} color="#f4a258" />{title}</p>
        <p className="sm tmut">{body}</p>
    </div>;
}
