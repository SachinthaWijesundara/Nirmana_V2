"""00 Sign in · Role picker."""

import from ..components.Icon { Icon }
import from ..components.ui { Chip, Pill, Field, Btn }
import from ..components.Shell { Logo }
import from ..hooks.app { useApp, useResource }

def:pub SignIn() -> JsxElement {
    app = useApp();
    roles = useResource("roles", {});
    has role: str = "client",
        email: str = "nimali.perera@gmail.com",
        password: str = "••••••••••",
        busy: bool = False;

    data: any = roles["data"] or [];
    label = role[0].toUpperCase() + role[1:];
    async def go() -> None {
        busy = True;
        await app["signIn"](role);
        busy = False;
    }
    return <div style={{"display": "flex", "minHeight": "100vh", "background": "#fcf3e3"}}>
        <div className="col g24" style={{"width": "47%", "minWidth": 420, "background": "#013d5a", "padding": "56px 64px"}}>
            <div className="row g12">
                <span className="logo-mark" style={{"width": 44, "height": 44, "borderRadius": 14}}><Icon name="box" size={24} /></span>
                <span className="h2 tinv">Nirmana</span>
            </div>
            <div className="col g16" style={{"marginTop": 16}}>
                <h1 className="huge tinv">One honest record of your build.</h1>
                <p className="tmut" style={{"fontSize": 16, "maxWidth": 560}}>Client, contractor and architect share one project. Every payment, change and daily log is recorded with who did it and when.</p>
            </div>
            <div className="col g14" style={{"marginTop": 16}}>
                {for f in [["shield", "Every change is logged", "An audit trail nobody can quietly edit."], ["wallet", "Paid vs verified", "See money against work the architect has certified."], ["sparkles", "AI checks receipts", "Overpriced rates are flagged against Kandy market prices."]] {
                    <div key={f[0]} className="row g14">
                        <span className="chip" style={{"background": "#0b4e6e", "color": "#f4a258"}}><Icon name={f[0]} size={22} /></span>
                        <div className="col g2"><span className="b tinv">{f[1]}</span><span className="sm tmut">{f[2]}</span></div>
                    </div>
                }}
            </div>
            <div className="grow" />
            <div className="row g16 stretch">
                <div className="stat bg-celeste"><div className="row g10"><span className="chip s bg-surface"><Icon name="wallet" size={16} /></span><div className="grow" /><span className="delta">52%</span></div><p className="b">Paid to date</p><p className="xl">Rs. 4.2M</p><p className="sm">of Rs. 8.0M</p></div>
                <div className="stat bg-marigold"><div className="row g10"><span className="chip s bg-tmar"><Icon name="shield" size={16} /></span><div className="grow" /><span className="delta" style={{"background": "#fce4cc"}}>32%</span></div><p className="b">Verified as built</p><p className="xl">Rs. 2.59M</p><p className="sm">by the architect</p></div>
            </div>
        </div>
        <div className="grow row ctr" style={{"padding": 24}}>
            <div className="card col g20" style={{"width": 480, "padding": 40, "borderRadius": 32}}>
                <div className="col g6"><h2 className="h1">Sign in</h2><p className="t2">Pick the role you have on this project. What you can approve depends on it.</p></div>
                <div className="col g10">
                    {for r in data {
                        <button key={r["role"]} className={"pbtn on" if r["role"] == role else "pbtn"} onClick={lambda { role = r["role"]; email = ""; }}>
                            <Chip icon={r["icon"]} tone={r["tone"]} />
                            <div className="col g2 grow"><span className="b">{r["title"]}</span><span className="sm t2">{r["text"]}</span></div>
                            <span className={"radio on" if r["role"] == role else "radio"} />
                        </button>
                    }}
                </div>
                <Field label="Email" value={email or (role + "@nirmana.demo")} onChange={lambda v: str { email = v; }} />
                <Field label="Password" value={password} onChange={lambda v: str { password = v; }} type="password" />
                <Btn label={"Continue as " + label} icon="arrow-up-right" onClick={go} block={True} lg={True} disabled={busy} />
                <div className="row g8 bg-tcel r14" style={{"padding": "12px 14px"}}><Pill label="Demo" tone="info" /><span className="sm grow">You can switch roles any time from the sidebar.</span></div>
            </div>
        </div>
    </div>;
}
