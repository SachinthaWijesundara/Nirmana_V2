"""The house cross-section: one row per layer, each element tinted by status."""

glob LAYER_BG: dict[str, str] = {"done": "#dde6d7", "active": "#fce4cc", "delayed": "#f6d9cf", "idle": "#f5ead5"};

def:pub HouseLayers(layers: list[any], legend: bool = True) -> JsxElement {
    return <div className="col g12">
        <div className="col g6">
            {for (i, layer) in enumerate(layers) {
                <div key={str(i)} className="row g6" style={{"padding": "0 48px" if (len(layer) == 1 and layer[0]["name"] == "Roof") else 0}}>
                    {for el in layer {
                        <div key={el["name"]} className={"row between grow r10" + (" bd" if el["status"] == "idle" else "")} style={{"background": LAYER_BG[el["status"]], "padding": "9px 10px", "fontSize": 12, "lineHeight": "16px", "minWidth": 0}}>
                            <span className="b">{el["name"]}</span>
                            <span className="xb t2">{str(el["pct"]) + "%"}</span>
                        </div>
                    }}
                </div>
            }}
        </div>
        {legend and <div className="row g16 sm t2 wrap">
            <span className="row g6"><i style={{"width": 10, "height": 10, "borderRadius": 5, "background": "#708c69", "display": "block"}} />Done</span>
            <span className="row g6"><i style={{"width": 10, "height": 10, "borderRadius": 5, "background": "#f4a258", "display": "block"}} />Active</span>
            <span className="row g6"><i style={{"width": 10, "height": 10, "borderRadius": 5, "background": "#c4553b", "display": "block"}} />Delayed</span>
            <span className="row g6"><i style={{"width": 10, "height": 10, "borderRadius": 5, "background": "#cdbb9a", "display": "block"}} />Not started</span>
        </div>}
    </div>;
}
