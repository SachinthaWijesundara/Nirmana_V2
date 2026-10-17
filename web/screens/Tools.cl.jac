"""10 Estimator, 11 Calculators, 12 Market prices."""

import from "@jac/runtime" { useNavigate }
import from ..components.Icon { Icon }
import from ..components.ui { Btn, Pill, Chip, Seg, Tabs, Field }
import from ..components.Cards { Note }
import from ..components.Charts { LineChart }
import from ..components.States { Gate }
import from ..components.Shell { Page }
import from ..hooks.app { useApp, useResource }
import from ..backend.index { command }
import from ..lib.fmt { rs }

def:pub Estimator() -> JsxElement {
    app = useApp();
    nav = useNavigate();
    res = useResource("estimator", {});
    has prompt: str = "",
        area: str = "",
        contingency: str = "",
        finish: str = "",
        calc: any = None,
        busy: bool = False;
    base: any = res["data"];
    est: any = calc or base;
    area_v: str = area or (str(est["area"]) if est else "");
    cont_v: str = contingency or (str(est["contingency"]) if est else "");
    fin_v: str = finish or (est["finish"] if est else "Mid-range");
    async def recalc() -> None {
        busy = True;
        r: any = await command("estimate", {"area": float(area_v or "2150"), "contingency": float(cont_v or "10"), "finish": fin_v});
        calc = r;
        busy = False;
    }
    def fill_from_prompt() {
        text: str = (prompt or str(base["prompt"])).lower();
        if "sq" in text {
            words: list[str] = text.split("sq")[0].strip().split(" ");
            token: str = words[len(words) - 1].replace(",", "");
            if token.isdigit() { area = token; }
        }
        if "premium" in text or "luxury" in text { finish = "Premium"; }
        elif "basic" in text { finish = "Basic"; }
        elif "mid" in text { finish = "Mid-range"; }
        app["toast"]("Form filled", "Check the details, then recalculate");
    }
    return <Page title="Estimator" subtitle="Get a cost range for a house before you sign a contract">
        <Gate res={res} what="estimator">
            {est and <div className="col g16">
                <div className="row g20 top">
                    <div className="col g16" style={{"width": 400, "flexShrink": 0}}>
                        <div className="col g12 r24" style={{"background": "#013d5a", "padding": 24, "borderRadius": 28}}>
                            <div className="row g12"><span className="chip s" style={{"background": "#0b4e6e", "color": "#f4a258", "width": 32, "height": 32}}><Icon name="sparkles" size={16} /></span><span className="h3 tinv">Describe your house</span></div>
                            <textarea className="tinv r16" rows={3} style={{"background": "#0b4e6e", "border": 0, "padding": 14, "outline": "none", "resize": "none"}} value={prompt or base["prompt"]} onChange={lambda (e: ChangeEvent) { prompt = e.target.value; }} />
                            <Btn label="Fill the form from this" icon="sparkles" kind="accent" block={True} lg={True} onClick={fill_from_prompt} />
                        </div>
                        <div className="card col g12" style={{"borderRadius": 28}}>
                            <p className="h3">Details</p>
                            <Field label="Building type" value={est["building"]} onChange={lambda v: str { }} />
                            <Field label="District" value={est["district"]} onChange={lambda v: str { }} />
                            <Field label="Floor area (sq ft)" value={area_v} onChange={lambda v: str { area = v; }} />
                            <Field label="Contingency (%)" value={cont_v} onChange={lambda v: str { contingency = v; }} />
                            <div className="field"><label className="label">Finish level</label><Seg options={["Basic", "Mid-range", "Premium"]} value={fin_v} onChange={lambda v: str { finish = v; }} /></div>
                            <Btn label={"Recalculating…" if busy else "Recalculate"} onClick={recalc} block={True} lg={True} disabled={busy} />
                        </div>
                    </div>
                    <div className="col g16 grow" style={{"minWidth": 0}}>
                        <div className="col g12 r24" style={{"background": "#bdd3ce", "padding": "28px", "borderRadius": 28}}>
                            <div className="row"><span className="b">Likely cost</span><div className="grow" /><Pill label={est["range"]} tone="info" /></div>
                            <div className="row g12 bot"><span className="huge" style={{"fontSize": 56, "lineHeight": "64px"}}>{est["likely"]}</span><span className="t2 sm" style={{"paddingBottom": 12}}>{est["per_sqft"]}</span></div>
                            <div style={{"position": "relative", "height": 12, "background": "#fff", "borderRadius": 999, "marginTop": 4}}>
                                <div style={{"position": "absolute", "left": "20%", "width": "60%", "height": 12, "background": "#013d5a", "borderRadius": 999}} />
                                <span style={{"position": "absolute", "left": "48%", "top": -4, "width": 20, "height": 20, "borderRadius": 10, "background": "#f4a258", "border": "3px solid #fff"}} />
                            </div>
                            <div className="row between sm b" style={{"padding": "0 18% 0 18%"}}><span>{"Low · " + est["low"]}</span><span>{"High · " + est["high"]}</span></div>
                        </div>
                        <div className="card col g4" style={{"borderRadius": 28, "padding": "24px 24px 12px"}}>
                            <div className="row"><span className="h3 grow">Bill of quantities</span><Btn label="Edit lines" icon="plus" kind="text" onClick={lambda { app["toast"]("Lines are editable once a backend is connected", ""); }} /></div>
                            <div className="thead" style={{"marginTop": 12}}><span className="over t2 grow">Item</span><span className="over t2" style={{"width": 110}}>Qty</span><span className="over t2 right" style={{"width": 90}}>Rate</span><span className="over t2 right" style={{"width": 120}}>Amount</span></div>
                            {for l in est["lines"] {
                                <div key={l["item"]} className="trow" style={{"padding": "12px 16px"}}><span className="grow">{l["item"]}</span><span className="t2" style={{"width": 110}}>{l["qty"]}</span><span className="t2 right" style={{"width": 90}}>{l["rate"]}</span><span className="b right" style={{"width": 120}}>{rs(l["amount"])}</span></div>
                            }}
                            <div className="row bg-tmar r12 b" style={{"padding": "12px 16px"}}><span className="grow">Likely total</span><span>{rs(est["total"] if "total" in est else 8245000)}</span></div>
                        </div>
                    </div>
                </div>
                <div className="row g12 end">
                    <Btn label="Download PDF" icon="file" kind="ghost" onClick={lambda { window.print(); }} />
                    <Btn label="Create project from estimate" icon="arrow-up-right" kind="accent" onClick={lambda { app["run"]("create_project", {"from": "estimate"}, "Project created from estimate (demo)"); nav("/projects"); }} />
                </div>
            </div>}
        </Gate>
    </Page>;
}

glob CALCS: dict[str, any] = {
    "Concrete": {"title": "Slab or footing", "inputs": [["length", "Length (m)", "6.0"], ["width", "Width (m)", "4.5"], ["thick", "Thickness (mm)", "125"], ["waste", "Wastage (%)", "5"]],
                 "note": "Grade 20 suits house slabs and beams. Ask your architect before changing the mix.", "head": "Concrete needed"},
    "Brick": {"title": "Wall", "inputs": [["length", "Wall length (m)", "12"], ["height", "Wall height (m)", "3"], ["waste", "Wastage (%)", "5"]], "note": "About 58 bricks per m² for a 100 mm wall, including mortar joints.", "head": "Bricks needed"},
    "Paint": {"title": "Painted area", "inputs": [["area", "Area (m²)", "180"], ["coats", "Coats", "2"], ["waste", "Wastage (%)", "5"]], "note": "One litre covers about 10 m² per coat. Add a primer coat on new plaster.", "head": "Paint needed"},
    "Tile": {"title": "Floor", "inputs": [["area", "Floor area (m²)", "42"], ["size", "Tile size (cm)", "60"], ["waste", "Wastage (%)", "8"]], "note": "Add 8–10% wastage for diagonal layouts and cuts.", "head": "Tiles needed"},
    "Steel": {"title": "Reinforcement", "inputs": [["dia", "Bar diameter (mm)", "12"], ["total", "Total length (m)", "480"], ["waste", "Wastage (%)", "3"]], "note": "Weight per metre = d² / 162 (kg).", "head": "Steel needed"}
};

def calc_result(kind: str, v: dict[str, float]) -> dict[str, any] {
    waste = 1 + v["waste"] / 100;
    if kind == "Concrete" {
        m3 = v["length"] * v["width"] * v["thick"] / 1000 * waste;
        cement = Math.ceil(m3 * 7.9);
        sand = Math.round(m3 * 0.44 * 100) / 100;
        metal = Math.round(m3 * 0.88 * 100) / 100;
        water = Math.round(m3 * 181 / 10) * 10;
        return {"headline": str(Math.round(m3 * 100) / 100) + " m³", "sub": str(v["length"]) + " × " + str(v["width"]) + " × " + str(v["thick"] / 1000), "badge": "incl. " + str(v["waste"]) + "% wastage",
                "tiles": [["Cement", str(cement), "bags · 50 kg"], ["Sand", str(sand), "m³"], ["Metal", str(metal), "m³ · 20 mm"], ["Water", "~" + str(water), "litres"]],
                "lines": [["Cement (50 kg)", str(cement) + " bags × Rs. 2,450", cement * 2450], ["Sand", str(sand) + " m³ × Rs. 14,500", Math.round(sand * 14500 / 10) * 10], ["Metal 20 mm", str(metal) + " m³ × Rs. 8,900", Math.round(metal * 8900 / 10) * 10]]};
    }
    if kind == "Brick" {
        area = v["length"] * v["height"];
        bricks = Math.ceil(area * 58 * waste);
        cement = Math.ceil(area * 0.5);
        sand = Math.round(area * 0.03 * 100) / 100;
        return {"headline": str(bricks) + " bricks", "sub": str(area) + " m² of wall", "badge": "incl. " + str(v["waste"]) + "% wastage",
                "tiles": [["Bricks", str(bricks), "nos"], ["Cement", str(cement), "bags · 50 kg"], ["Sand", str(sand), "m³"], ["Area", str(area), "m²"]],
                "lines": [["Bricks", str(bricks) + " × Rs. 38", bricks * 38], ["Cement (mortar)", str(cement) + " bags × Rs. 2,450", cement * 2450], ["Sand", str(sand) + " m³ × Rs. 14,500", Math.round(sand * 14500 / 10) * 10]]};
    }
    if kind == "Paint" {
        litres = Math.ceil(v["area"] * v["coats"] / 10 * waste);
        return {"headline": str(litres) + " L", "sub": str(v["area"]) + " m² × " + str(v["coats"]) + " coats", "badge": "incl. " + str(v["waste"]) + "% wastage",
                "tiles": [["Paint", str(litres), "litres"], ["Primer", str(Math.ceil(v["area"] / 12)), "litres"], ["Coats", str(v["coats"]), ""], ["Cover", "10", "m² per litre"]],
                "lines": [["Emulsion paint", str(litres) + " L × Rs. 1,850", litres * 1850], ["Primer", str(Math.ceil(v["area"] / 12)) + " L × Rs. 1,200", Math.ceil(v["area"] / 12) * 1200]]};
    }
    if kind == "Tile" {
        per = (v["size"] / 100) * (v["size"] / 100);
        tiles = Math.ceil(v["area"] / per * waste);
        boxes = Math.ceil(tiles / 4);
        sqft = v["area"] * 10.764;
        return {"headline": str(tiles) + " tiles", "sub": str(v["area"]) + " m² floor", "badge": "incl. " + str(v["waste"]) + "% wastage",
                "tiles": [["Tiles", str(tiles), "nos"], ["Boxes", str(boxes), "of 4"], ["Adhesive", str(Math.ceil(v["area"] / 4)), "bags"], ["Area", str(Math.round(sqft)), "sq ft"]],
                "lines": [["Floor tiles", str(Math.round(sqft)) + " sq ft × Rs. 640", Math.round(sqft * 640 / 10) * 10], ["Adhesive", str(Math.ceil(v["area"] / 4)) + " bags × Rs. 1,650", Math.ceil(v["area"] / 4) * 1650]]};
    }
    kg = Math.round(v["dia"] * v["dia"] / 162 * v["total"] * waste);
    return {"headline": str(kg) + " kg", "sub": str(v["total"]) + " m of " + str(v["dia"]) + " mm bar", "badge": "incl. " + str(v["waste"]) + "% wastage",
            "tiles": [["Weight", str(kg), "kg"], ["Bars", str(Math.ceil(v["total"] / 12)), "× 12 m"], ["Tonnes", str(Math.round(kg / 10) / 100), "t"], ["Per m", str(Math.round(v["dia"] * v["dia"] / 1.62) / 100), "kg"]],
            "lines": [["Steel rebar", str(kg) + " kg × Rs. 292", kg * 292]]};
}

def:pub Calculators() -> JsxElement {
    app = useApp();
    has kind: str = "Concrete", vals: dict[str, any] = {};
    cfg: any = CALCS[kind];
    cur: dict[str, float] = {};
    for inp in cfg["inputs"] { cur[inp[0]] = float(vals[kind + inp[0]] or inp[2]); }
    r: any = calc_result(kind, cur);
    total = 0;
    for l in r["lines"] { total = total + (l[2] as int); }
    others = [k for k in ["Brick", "Paint", "Tile", "Steel"] if k != kind];
    if kind != "Concrete" { others = [k for k in ["Concrete", "Brick", "Paint", "Tile", "Steel"] if k != kind][:4]; }
    def set_val(k: str, v: str) {
        nv: dict[str, any] = {**vals};
        nv[k] = v;
        vals = nv;
    }
    ICONS = {"Brick": ["layers", "Walls → bricks, mortar"], "Paint": ["home", "Area → litres, coats"], "Tile": ["box", "Floor → boxes, adhesive"], "Steel": ["ruler", "Bar size → kg, lengths"], "Concrete": ["box", "Slab → cement, sand, metal"]};
    return <Page title="Calculators" subtitle="Quick material quantities, priced at this month's Kandy rates">
        <Tabs items={["Concrete", "Brick", "Paint", "Tile", "Steel"]} value={kind} onChange={lambda v: str { kind = v; }} />
        <div className="row g20 top">
            <div className="card col g12" style={{"width": 420, "flexShrink": 0, "borderRadius": 28}}>
                <p className="h3">{cfg["title"]}</p>
                <div style={{"display": "grid", "gridTemplateColumns": "1fr 1fr", "gap": 12}}>
                    {for inp in cfg["inputs"] {
                        <Field key={kind + inp[0]} label={inp[1]} value={str(vals[kind + inp[0]] if (kind + inp[0]) in vals else inp[2])} onChange={lambda v: str { set_val(kind + inp[0], v); }} />
                    }}
                </div>
                <Note text={cfg["note"]} />
            </div>
            <div className="col g16 grow" style={{"minWidth": 0}}>
                <div className="col g12 r24" style={{"background": "#bdd3ce", "padding": 28, "borderRadius": 28}}>
                    <div className="row"><span className="b">{cfg["head"]}</span><div className="grow" /><Pill label={r["badge"]} tone="info" /></div>
                    <div className="row g12 bot"><span className="huge" style={{"fontSize": 56, "lineHeight": "64px"}}>{r["headline"]}</span><span className="t2" style={{"paddingBottom": 10}}>{r["sub"]}</span></div>
                    <div className="grid4">{for t in r["tiles"] { <div key={t[0]} className="col g2 bg-surface r16" style={{"padding": "14px 16px"}}><span className="sm t2">{t[0]}</span><span className="h2" style={{"fontWeight": 800}}>{t[1]}</span><span className="sm t2">{t[2]}</span></div> }}</div>
                </div>
                <div className="card col g8" style={{"borderRadius": 28}}>
                    <div className="row"><span className="h3 grow">Estimated cost</span><span className="sm t2">Kandy · Oct 2026</span></div>
                    {for l in r["lines"] { <div key={l[0]} className="row hr" style={{"padding": "12px 0"}}><span className="grow">{l[0]}</span><span className="sm t2" style={{"paddingRight": 12}}>{l[1]}</span><span className="b right" style={{"width": 110}}>{rs(l[2])}</span></div> }}
                    <div className="row bg-tmar r12 b" style={{"padding": "12px 16px"}}><span className="grow">Total materials</span><span>{rs(total)}</span></div>
                    <div className="row g12 end"><Btn label="Copy result" kind="text" onClick={lambda { navigator.clipboard.writeText(r["headline"] + " · " + rs(total)); app["toast"]("Copied", r["headline"]); }} /><Btn label="Add to Perera House materials" icon="plus" onClick={lambda { app["toast"]("Added to Perera House materials", rs(total)); }} /></div>
                </div>
            </div>
        </div>
        <div className="grid4">
            {for k in others { <button key={k} className="card-sm row g12" style={{"textAlign": "left"}} onClick={lambda { kind = k; }}><Chip icon={ICONS[k][0]} tone="subtle" size={40} iconSize={20} /><div className="col grow"><span className="b">{k}</span><span className="sm t2">{ICONS[k][1]}</span></div><Icon name="chevron-right" size={16} /></button> }}
        </div>
    </Page>;
}

def:pub Market() -> JsxElement {
    res = useResource("market", {});
    has product: str = "Cement", range: str = "12M", district: str = "Kandy";
    m: any = res["data"];
    s: any = m["series"][product] if m else None;
    factor: float = 1.04;
    if m { for d in m["districts"] { if d["name"] == district { factor = d["factor"]; } } }
    n: int = 6 if range == "6M" else 12;
    pts: list[any] = [];
    base: list[any] = [];
    labels: list[any] = [];
    lo = 1e12;
    hi = 0;
    if s {
        k: list[any] = s["kandy"][12 - n:];
        g: list[any] = s["national"][12 - n:];
        for i in range(n) {
            pts = pts + [[i, k[i] * factor / 1.04]];
            base = base + [[i, g[i]]];
            lo = Math.min(lo, k[i] * factor / 1.04, g[i]);
            hi = Math.max(hi, k[i] * factor / 1.04, g[i]);
            if n == 12 or i % 1 == 0 { labels = labels + [[i, m["months"][12 - n + i]]]; }
        }
    }
    cycle = ["Kandy", "Colombo", "Galle"];
    return <Page title="Market prices" subtitle="Monthly material prices, adjusted for district cost factors">
        <Gate res={res} what="market prices">
            {m and <div className="col g16">
                <div className="row g8">
                    <button className="row g8 bd r999 bg-surface" style={{"padding": "10px 16px"}} onClick={lambda { district = cycle[(cycle.indexOf(district) + 1) % 3]; }}><span className="sm t2">District</span><span className="b">{district + " · ×" + str(factor)}</span><Icon name="chevron-down" size={16} /></button>
                    <Tabs items={m["products"]} value={product} onChange={lambda v: str { product = v; }} />
                </div>
                <div className="row g20 top">
                    <div className="col g16 grow" style={{"minWidth": 0}}>
                        <div className="card col g12" style={{"borderRadius": 28}}>
                            <div className="row top">
                                <div className="col g6"><span className="h3">{s["title"]}</span><div className="row g12"><span className="huge" style={{"fontSize": 36, "lineHeight": "44px"}}>{s["price"]}</span><Pill label={s["delta"]} tone={s["tone"] if s["tone"] != "danger" else "delayed"} /></div></div>
                                <div className="grow" />
                                <Seg options={["6M", "12M", "3Y"]} value={range} onChange={lambda v: str { range = v; }} />
                            </div>
                            <LineChart series={[{"pts": pts, "color": "#013d5a", "dash": False, "fill": True, "dot": True}, {"pts": base, "color": "#f4a258", "dash": True, "fill": False, "dot": False}]} xmax={n - 1} ymin={lo * 0.97} ymax={hi * 1.03} labels={labels} width={720} height={280} />
                            <div className="row g16 sm t2"><span className="row g6"><i style={{"width": 16, "height": 3, "background": "#013d5a", "display": "block"}} />{district + " (×" + str(factor) + ")"}</span><span className="row g6"><i style={{"width": 16, "height": 3, "background": "#f4a258", "display": "block"}} />National average</span></div>
                        </div>
                    </div>
                    <div className="col g16" style={{"width": 360, "flexShrink": 0}}>
                        <div className="alert" style={{"borderRadius": 20}}><span className="chip" style={{"background": "#f6d9cf", "color": "#c4553b"}}><Icon name="alert" size={18} /></span><div className="col g2 grow"><span className="b">{m["flag"]["title"]}</span><span className="sm t2">{m["flag"]["body"]}</span></div></div>
                        <div className="card col g4" style={{"borderRadius": 24}}>
                            <div className="row"><span className="h3 grow">This month</span><span className="sm t2">{district}</span></div>
                            {for r in m["month"] {
                                <div key={r["name"]} className="row hr" style={{"padding": "14px 0"}}><div className="col grow"><span className="b">{r["name"]}</span><span className="sm t2">{r["unit"]}</span></div><div className="col g4" style={{"alignItems": "flex-end"}}><span className="b">{r["price"]}</span><Pill label={r["delta"]} tone={"delayed" if r["tone"] == "danger" else ("progress" if r["tone"] == "marigold" else ("done" if r["tone"] == "herb" else "muted"))} /></div></div>
                            }}
                        </div>
                        <Note text={m["note"]} />
                    </div>
                </div>
            </div>}
        </Gate>
    </Page>;
}
