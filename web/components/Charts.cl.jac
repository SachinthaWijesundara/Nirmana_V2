"""SVG line chart used by Market prices and the Overview cost curve."""

def:pub LineChart(series: list[any], xmax: float, ymin: float, ymax: float, labels: list[any], width: int = 700, height: int = 260, grid: int = 4, today: float = -1.0, todayLabel: str = "Today") -> JsxElement {
    padL = 8;
    padR = 8;
    padT = 10;
    padB = 28;
    iw = width - padL - padR;
    ih = height - padT - padB;
    def px(x: float) -> float { return padL + (x / xmax) * iw; }
    def py(y: float) -> float { return padT + ih - ((y - ymin) / (ymax - ymin)) * ih; }
    def path(pts: list[any]) -> str {
        out = "";
        for (i, p) in enumerate(pts) {
            out = out + ("M" if i == 0 else "L") + str(round(px(p[0]), 1)) + " " + str(round(py(p[1]), 1)) + " ";
        }
        return out;
    }
    def area(pts: list[any]) -> str {
        last = pts[len(pts) - 1];
        return path(pts) + "L" + str(round(px(last[0]), 1)) + " " + str(round(py(ymin), 1)) + " L" + str(round(px(pts[0][0]), 1)) + " " + str(round(py(ymin), 1)) + " Z";
    }
    return <svg viewBox={"0 0 " + str(width) + " " + str(height)} width="100%" style={{"display": "block"}}>
        {for g in range(grid + 1) {
            <line key={"g" + str(g)} x1={padL} x2={width - padR} y1={padT + ih * g / grid} y2={padT + ih * g / grid} stroke="#e8dac0" strokeWidth="1" />
        }}
        {for s in series {
            <g key={s["color"] + str(s["dash"])}>
                {s["fill"] and <path d={area(s["pts"])} fill={s["color"]} opacity="0.18" />}
                <path d={path(s["pts"])} fill="none" stroke={s["color"]} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" strokeDasharray={"6 6" if s["dash"] else "0"} />
                {s["dot"] and <circle cx={px(s["pts"][len(s["pts"]) - 1][0])} cy={py(s["pts"][len(s["pts"]) - 1][1])} r="5" fill={s["color"]} stroke="#fff" strokeWidth="2" />}
            </g>
        }}
        {today >= 0 and <g><line x1={px(today)} x2={px(today)} y1={padT} y2={padT + ih} stroke="#f4a258" strokeWidth="2" /><text x={px(today) + 6} y={padT + 12} fontSize="12" fontWeight="700" fill="#f4a258">{todayLabel}</text></g>}
        {for l in labels {
            <text key={l[1]} x={px(l[0])} y={height - 8} fontSize="12" fill="#5e6e76" textAnchor="middle">{l[1]}</text>
        }}
    </svg>;
}
