"""One project: the twin, the plan, every agent, photo proof, Q&A and the audit trail.
Actions are shown only to the role allowed to take them; the server checks the role too."""
# Jac 0.34's client caches server-call results for 60s and doesn't invalidate them after our writes,
# so every load and action below starts with __jacClearCache() to show fresh data.
import from "@jac/runtime" { __jacClearCache }
sv import from ..api.endpoints {
    get_project, get_activity, invite_member, add_element, record_payment,
    send_builder_message, report_progress, request_payment, verify_progress,
    submit_photo_proof, run_delay_check, get_forecast, run_scenario, ask_project
}

"""Endpoints answer {"error": ...} instead of failing (see api/endpoints.jac); raise it here
so the page shows the server's message."""
def unwrap(out: any) -> any {
    if out and out["error"] { raise Exception(str(out["error"])); }
    return out;
}

def rs(v: any) -> str {
    return "Rs. " + str(int(v as float));
}

"""Join items with a separator (str.join is not available in the browser runtime)."""
def joinWith(items: any, sep: str) -> str {
    out = "";
    if not items { return out; }
    for x in items {
        if out != "" { out = out + sep; }
        out = out + str(x);
    }
    return out;
}

def statusClass(s: any) -> str {
    return "status " + str(s);
}

def:pub ProjectView(projectId: str, onBack: Callable[[], None]) -> JsxElement {
    has project: dict = {};
    has loaded: bool = False;
    has tab: str = "overview";
    has notice: str = "";
    has result: str = "";
    has activity: list[dict] = [];
    has forecastData: dict = {};
    has scenarioData: dict = {};
    has delays: list[dict] = [];
    has answer: dict = {};
    # form fields
    has msgText: str = "";
    has elName: str = "";
    has elCost: str = "";
    has elStart: str = "";
    has elEnd: str = "";
    has elKind: str = "";
    has elFloor: str = "";
    has elPrereq: str = "";
    has payAmount: str = "";
    has payDate: str = "";
    has payNote: str = "";
    has payElement: str = "";
    has progElement: str = "";
    has progPercent: str = "";
    has progCost: str = "";
    has reqAmount: str = "";
    has reqNote: str = "";
    has verElement: str = "";
    has verPercent: str = "";
    has photoElement: str = "";
    has photoData: str = "";
    has photoNote: str = "";
    has invEmail: str = "";
    has invName: str = "";
    has invRole: str = "contractor";
    has scCement: str = "15";
    has scDays: str = "0";
    has scElement: str = "";
    has question: str = "";
    has askLang: str = "english";

    async def load() -> None {

        __jacClearCache();
        data: any = None;
        try {
            project_id = projectId;
            data = unwrap(await get_project(project_id));
            project = data as dict;
            loaded = True;
        } except Exception as e { notice = str(e); }
    }

    async can with entry {
        await load();
    }

    async def act(label: str, run: Callable[[], any]) -> None {

        __jacClearCache();
        out: any = None;
        notice = "";
        result = "";
        try {
            out = await run();
            result = label + ": " + (str(out["message"]) if out and out["message"] else "done");
            await load();
        } except Exception as e { notice = str(e); }
    }

    async def sendMessage() -> None {

        __jacClearCache();
        out: any = None;
        notice = "";
        try {
            project_id = projectId;
            message = msgText;
            out = unwrap(await send_builder_message(project_id, message));
            if out["ok"] {
                result = "Intake: " + str(out["element"]) + " is now " + str(out["percent_complete"]) + "% (cost so far " + rs(out["actual_cost"]) + ")" + ((", delay: " + str(out["delay_reason"])) if out["delay_reason"] else "");
                msgText = "";
            } else { notice = "Intake could not match an element: " + str(out["reason"]); }
            await load();
        } except Exception as e { notice = str(e); }
    }

    async def addElement() -> None {

        __jacClearCache();
        out: any = None;
        notice = "";
        try {
            project_id = projectId;
            name = elName;
            planned_cost = float(elCost) if elCost != "" else 0.0;
            planned_start = elStart;
            planned_end = elEnd;
            kind = elKind;
            floor = elFloor;
            prerequisites = [x.strip() for x in elPrereq.split(",") if x.strip() != ""];
            out = unwrap(await add_element(project_id, name, planned_cost, planned_start, planned_end, kind, floor, prerequisites));
            result = "Added " + str(out["name"]) + " to the plan.";
            elName = "";
            await load();
        } except Exception as e { notice = str(e); }
    }

    async def recordPayment() -> None {

        __jacClearCache();
        out: any = None;
        notice = "";
        try {
            project_id = projectId;
            amount = float(payAmount) if payAmount != "" else 0.0;
            date = payDate;
            note = payNote;
            element_name = payElement;
            out = unwrap(await record_payment(project_id, amount, date, note, element_name));
            result = "Recorded a payment of " + rs(out["amount"]) + ".";
            await load();
        } except Exception as e { notice = str(e); }
    }

    async def reportProgress() -> None {

        __jacClearCache();
        out: any = None;
        notice = "";
        try {
            project_id = projectId;
            element_name = progElement;
            percent = float(progPercent) if progPercent != "" else 0.0;
            on_date = "";
            started_on = "";
            actual_cost = float(progCost) if progCost != "" else 0.0;
            out = unwrap(await report_progress(project_id, element_name, percent, on_date, started_on, actual_cost));
            result = str(out["name"]) + " reported at " + str(out["percent_complete"]) + "%.";
            await load();
        } except Exception as e { notice = str(e); }
    }

    async def requestPayment() -> None {

        __jacClearCache();
        out: any = None;
        notice = "";
        try {
            project_id = projectId;
            amount = float(reqAmount) if reqAmount != "" else 0.0;
            note = reqNote;
            out = unwrap(await request_payment(project_id, amount, note));
            result = "Payment Guard: " + str(out["message"]);
            await load();
        } except Exception as e { notice = str(e); }
    }

    async def verify() -> None {

        __jacClearCache();
        out: any = None;
        notice = "";
        try {
            project_id = projectId;
            element_name = verElement;
            verified_percent = float(verPercent) if verPercent != "" else 0.0;
            note = "";
            out = unwrap(await verify_progress(project_id, element_name, verified_percent, note));
            result = str(out["message"]) if out["ok"] else ("Could not verify: " + str(out["reason"]));
            await load();
        } except Exception as e { notice = str(e); }
    }

    def pickPhoto(e: ChangeEvent) {
        files: any = e.target.files;
        if not files or files.length == 0 { return; }
        reader: any = new(FileReader);  # jac:ignore[W2001,E1053]
        reader.onload = lambda (ev: any) { photoData = str(ev.target.result); };
        reader.readAsDataURL(files[0]);
    }

    async def sendPhoto() -> None {

        __jacClearCache();
        out: any = None;
        notice = "";
        result = "Checking the photo...";
        try {
            project_id = projectId;
            element_name = photoElement;
            image = photoData;
            note = photoNote;
            out = unwrap(await submit_photo_proof(project_id, element_name, image, note));
            # build the text locally: reading `result` back here would give its old value
            message = str(out["message"]);
            if out["checked"] {
                message = message + " (AI: shows element " + str(out["shows_element"]) + ", about " + str(out["estimated_percent"]) + "% done, confidence " + str(out["confidence"]) + ")";
            }
            result = message;
            await load();
        } except Exception as e { notice = str(e); result = ""; }
    }

    async def invite() -> None {

        __jacClearCache();
        out: any = None;
        notice = "";
        try {
            project_id = projectId;
            email = invEmail;
            role = invRole;
            name = invName;
            out = unwrap(await invite_member(project_id, email, role, name));
            result = "Invited " + str(out["email"]) + " as " + str(out["role"]) + ". They see this project after they sign up with that email.";
            invEmail = "";
            invName = "";
            await load();
        } except Exception as e { notice = str(e); }
    }

    async def loadForecast() -> None {

        __jacClearCache();
        out: any = None;
        notice = "";
        try {
            project_id = projectId;
            today = "";
            out = unwrap(await get_forecast(project_id, today));
            forecastData = out as dict;
        } except Exception as e { notice = str(e); }
    }

    async def runScenario() -> None {

        __jacClearCache();
        out: any = None;
        notice = "";
        try {
            project_id = projectId;
            cement_pct = float(scCement) if scCement != "" else 0.0;
            delay_days = int(scDays) if scDays != "" else 0;
            delay_element = scElement;
            today = "";
            out = unwrap(await run_scenario(project_id, cement_pct, delay_days, delay_element, today));
            scenarioData = out as dict;
        } except Exception as e { notice = str(e); }
    }

    async def checkDelays() -> None {

        __jacClearCache();
        out: any = None;
        notice = "";
        try {
            project_id = projectId;
            today = "";
            out = unwrap(await run_delay_check(project_id, today));
            delays = (out as list[dict]) if out else [];
            result = str(len(delays)) + " new delay notice(s) written.";
            await load();
        } except Exception as e { notice = str(e); }
    }

    async def askIt() -> None {

        __jacClearCache();
        out: any = None;
        notice = "";
        try {
            project_id = projectId;
            language = askLang;
            out = unwrap(await ask_project(project_id, question, language));
            answer = out as dict;
        } except Exception as e { notice = str(e); }
    }

    async def loadActivity() -> None {

        __jacClearCache();
        out: any = None;
        try {
            project_id = projectId;
            category = "";
            out = unwrap(await get_activity(project_id, category));
            activity = (out as list[dict]) if out else [];
        } except Exception as e { notice = str(e); }
    }

    def showTab(name: str) {
        tab = name;
        result = "";
        notice = "";
        if name == "activity" { loadActivity(); }
        if name == "forecast" { loadForecast(); }
    }

    if not loaded {
        return <main className="page">
            <button className="link" onClick={lambda (e: MouseEvent) { onBack(); }}>{"< All projects"}</button>
            {notice and <p className="error">{notice}</p>}
            {not notice and <p className="muted">Loading...</p>}
        </main>;
    }

    role = str(project["my_role"]);
    money = project["money"];
    els = project["elements"] as list[dict];
    payments = project["payments"] as list[dict];
    notices = project["delay_notices"] as list[dict];
    members = project["team"] as list[dict];
    pathText = joinWith(forecastData["critical_path"], " -> ");
    factsText = joinWith(answer["facts_used"], ", ");
    tabs = ["overview", "plan", "actions", "photo", "forecast", "ask", "team", "activity"];

    return <main className="page">
        <button className="link" onClick={lambda (e: MouseEvent) { onBack(); }}>{"< All projects"}</button>
        <div className="row between">
            <div>
                <h1>{str(project["name"])}</h1>
                <p className="muted">{str(project["location"]) + " · " + str(project["building_type"]) + " · handover " + str(project["handover_date"])}</p>
            </div>
            <span className="badge">{"You are the " + role}</span>
        </div>
        <div className="stats">
            <div className="stat"><span>Paid</span><b>{rs(money["paid"])}</b></div>
            <div className="stat"><span>Verified built</span><b>{rs(money["verified"])}</b></div>
            <div className="stat"><span>Held</span><b>{rs(money["held"])}</b></div>
            <div className="stat"><span>Budget</span><b>{rs(money["budget"])}</b></div>
        </div>
        <nav className="tabs">
            {for t in tabs {
                <button key={t} className={"tab active" if tab == t else "tab"} onClick={lambda (e: MouseEvent) { showTab(t); }}>{t}</button>
            }}
        </nav>
        {notice and <p className="error">{notice}</p>}
        {result and <p className="ok">{result}</p>}

        {if tab == "overview" {
            <div className="card">
                <h3>House progress</h3>
                <table>
                    <thead><tr><th>Element</th><th>Floor</th><th>Reported</th><th>Verified</th><th>Planned</th><th>Spent</th><th>Due</th><th>Status</th></tr></thead>
                    <tbody>
                        {for el in els {
                            <tr key={str(el["id"])}>
                                <td>{str(el["name"])}</td>
                                <td>{str(el["floor"])}</td>
                                <td>{str(el["percent_complete"]) + "%"}</td>
                                <td>{str(el["verified_pct"]) + "%"}</td>
                                <td>{rs(el["planned_cost"])}</td>
                                <td>{rs(el["actual_cost"])}</td>
                                <td>{str(el["planned_end"])}</td>
                                <td><span className={statusClass(el["status"])}>{str(el["status"])}</span></td>
                            </tr>
                        }}
                    </tbody>
                </table>
                <h3>Payments</h3>
                <ul>
                    {for p in payments {
                        <li key={str(p["date"]) + str(p["amount"]) + str(p["status"])}>{str(p["date"]) + " · " + rs(p["amount"]) + " · " + str(p["status"]) + " · " + str(p["note"])}</li>
                    }}
                </ul>
            </div>
        }}

        {if tab == "plan" {
            <div className="card">
                {if role == "client" or role == "architect" {
                    <h3>Add a plan element</h3>
                    <div className="grid">
                        <label>Name<input value={elName} onChange={lambda (e: ChangeEvent) { elName = e.target.value; }} /></label>
                        <label>Planned cost (Rs.)<input type="number" value={elCost} onChange={lambda (e: ChangeEvent) { elCost = e.target.value; }} /></label>
                        <label>Planned start<input type="date" value={elStart} onChange={lambda (e: ChangeEvent) { elStart = e.target.value; }} /></label>
                        <label>Planned end<input type="date" value={elEnd} onChange={lambda (e: ChangeEvent) { elEnd = e.target.value; }} /></label>
                        <label>Kind<input value={elKind} placeholder="structure / services / finishes" onChange={lambda (e: ChangeEvent) { elKind = e.target.value; }} /></label>
                        <label>Floor<input value={elFloor} onChange={lambda (e: ChangeEvent) { elFloor = e.target.value; }} /></label>
                        <label>Must finish first (comma separated)<input value={elPrereq} placeholder="Walls, Plumbing" onChange={lambda (e: ChangeEvent) { elPrereq = e.target.value; }} /></label>
                    </div>
                    <button onClick={lambda (e: MouseEvent) { addElement(); }}>Add element</button>
                } else {
                    <p className="muted">Only the client or the architect can change the plan.</p>
                }}
                {if role == "client" {
                    <h3>Record a payment already made</h3>
                    <div className="grid">
                        <label>Amount (Rs.)<input type="number" value={payAmount} onChange={lambda (e: ChangeEvent) { payAmount = e.target.value; }} /></label>
                        <label>Date<input type="date" value={payDate} onChange={lambda (e: ChangeEvent) { payDate = e.target.value; }} /></label>
                        <label>Note<input value={payNote} onChange={lambda (e: ChangeEvent) { payNote = e.target.value; }} /></label>
                        <label>For element (optional)<input value={payElement} onChange={lambda (e: ChangeEvent) { payElement = e.target.value; }} /></label>
                    </div>
                    <button onClick={lambda (e: MouseEvent) { recordPayment(); }}>Record payment</button>
                }}
            </div>
        }}

        {if tab == "actions" {
            <div className="card">
                {if role == "contractor" {
                    <h3>Send a site update (Intake)</h3>
                    <p className="muted">Write it the way you would on WhatsApp, e.g. "slab eka iwarai, cement 40k gaththa".</p>
                    <textarea value={msgText} onChange={lambda (e: ChangeEvent) { msgText = e.target.value; }} />
                    <button onClick={lambda (e: MouseEvent) { sendMessage(); }}>Send update</button>
                    <h3>Report progress</h3>
                    <div className="grid">
                        <label>Element<input value={progElement} onChange={lambda (e: ChangeEvent) { progElement = e.target.value; }} /></label>
                        <label>Percent done<input type="number" value={progPercent} onChange={lambda (e: ChangeEvent) { progPercent = e.target.value; }} /></label>
                        <label>Cost spent now (Rs.)<input type="number" value={progCost} onChange={lambda (e: ChangeEvent) { progCost = e.target.value; }} /></label>
                    </div>
                    <button onClick={lambda (e: MouseEvent) { reportProgress(); }}>Report</button>
                    <h3>Request a payment (Payment Guard)</h3>
                    <div className="grid">
                        <label>Amount (Rs.)<input type="number" value={reqAmount} onChange={lambda (e: ChangeEvent) { reqAmount = e.target.value; }} /></label>
                        <label>For<input value={reqNote} onChange={lambda (e: ChangeEvent) { reqNote = e.target.value; }} /></label>
                    </div>
                    <button onClick={lambda (e: MouseEvent) { requestPayment(); }}>Request payment</button>
                }}
                {if role == "architect" {
                    <h3>Verify progress from proof</h3>
                    <p className="muted">Verified work releases held money that it now covers.</p>
                    <div className="grid">
                        <label>Element<input value={verElement} onChange={lambda (e: ChangeEvent) { verElement = e.target.value; }} /></label>
                        <label>Verified percent<input type="number" value={verPercent} onChange={lambda (e: ChangeEvent) { verPercent = e.target.value; }} /></label>
                    </div>
                    <button onClick={lambda (e: MouseEvent) { verify(); }}>Verify</button>
                }}
                {if role == "client" {
                    <p className="muted">As the client you watch the twin, approve with your money, and ask questions. Updates come from the contractor; verification from the architect.</p>
                }}
                <h3>Delay check</h3>
                <button onClick={lambda (e: MouseEvent) { checkDelays(); }}>Run Delay Detector</button>
                {for d in delays {
                    <p key={str(d["element"])} className="notice">{str(d["evidence"])}</p>
                }}
                {for n in notices {
                    <p key={str(n["date"]) + str(n["element"])} className="muted">{str(n["date"]) + ": " + str(n["evidence"])}</p>
                }}
            </div>
        }}

        {if tab == "photo" {
            <div className="card">
                <h3>Photo proof</h3>
                {if role == "contractor" or role == "architect" {
                    <p className="muted">Send a photo of the finished work. The AI checks it shows the element; a confident match counts as proof and releases held money it covers.</p>
                    <div className="grid">
                        <label>Element<input value={photoElement} onChange={lambda (e: ChangeEvent) { photoElement = e.target.value; }} /></label>
                        <label>Note<input value={photoNote} onChange={lambda (e: ChangeEvent) { photoNote = e.target.value; }} /></label>
                        <label>Photo<input type="file" accept="image/*" onChange={pickPhoto} /></label>
                    </div>
                    if photoData { <img className="preview" src={photoData} /> }
                    <button disabled={not photoData} onClick={lambda (e: MouseEvent) { sendPhoto(); }}>Send photo for checking</button>
                } else {
                    <p className="muted">The contractor or architect sends photo proof; you see the result here and in Activity.</p>
                }}
            </div>
        }}

        {if tab == "forecast" {
            <div className="card">
                <h3>Forecast</h3>
                <button onClick={lambda (e: MouseEvent) { loadForecast(); }}>Refresh forecast</button>
                {if forecastData and forecastData["finish_date"] {
                    <p className="big">{"Finish " + str(forecastData["finish_date"]) + " (" + str(forecastData["slip_days"]) + " days vs plan " + str(forecastData["planned_finish_date"]) + ")"}</p>
                    <p>{"Cost to complete " + rs(forecastData["cost_to_complete"]) + " · projected total " + rs(forecastData["projected_total"]) + " · over budget " + rs(forecastData["over_budget"])}</p>
                    <p className="muted">{"Critical path: " + pathText}</p>
                }}
                <h3>What if...</h3>
                <div className="grid">
                    <label>Cement price change (%)<input type="number" value={scCement} onChange={lambda (e: ChangeEvent) { scCement = e.target.value; }} /></label>
                    <label>Delay (days)<input type="number" value={scDays} onChange={lambda (e: ChangeEvent) { scDays = e.target.value; }} /></label>
                    <label>Delayed element (blank = all)<input value={scElement} onChange={lambda (e: ChangeEvent) { scElement = e.target.value; }} /></label>
                </div>
                <button onClick={lambda (e: MouseEvent) { runScenario(); }}>Run scenario</button>
                {if scenarioData and scenarioData["summary"] {
                    <p className="ok">{str(scenarioData["summary"])}</p>
                    <p className="muted">The real twin is not changed.</p>
                }}
            </div>
        }}

        {if tab == "ask" {
            <div className="card">
                <h3>Ask about this house</h3>
                <p className="muted">e.g. "How much have we spent on cement?", "When will it be finished?", "Why is a payment held?"</p>
                <textarea value={question} onChange={lambda (e: ChangeEvent) { question = e.target.value; }} />
                <label>Answer in
                    <select value={askLang} onChange={lambda (e: ChangeEvent) { askLang = e.target.value; }}>
                        <option value="english">English</option>
                        <option value="sinhala">Sinhala</option>
                        <option value="tamil">Tamil</option>
                    </select>
                </label>
                <button onClick={lambda (e: MouseEvent) { askIt(); }}>Ask</button>
                {if answer and answer["answer"] {
                    <div className="answer">
                        <p>{str(answer["answer"])}</p>
                        <p className="muted">{("Answered by AI from the graph" if answer["used_llm"] else "Answered from the graph") + " · facts: " + factsText}</p>
                    </div>
                }}
            </div>
        }}

        {if tab == "team" {
            <div className="card">
                <h3>Team</h3>
                <ul>
                    {for m in members {
                        <li key={str(m["email"])}>{str(m["name"]) + " · " + str(m["role"]) + " · " + str(m["email"]) + " · " + str(m["status"])}</li>
                    }}
                </ul>
                {if role == "client" or role == "architect" {
                    <h3>Invite someone</h3>
                    <div className="grid">
                        <label>Email<input type="email" value={invEmail} onChange={lambda (e: ChangeEvent) { invEmail = e.target.value; }} /></label>
                        <label>Name<input value={invName} onChange={lambda (e: ChangeEvent) { invName = e.target.value; }} /></label>
                        <label>Role
                            <select value={invRole} onChange={lambda (e: ChangeEvent) { invRole = e.target.value; }}>
                                <option value="contractor">Contractor</option>
                                <option value="architect">Architect</option>
                                <option value="client">Client</option>
                            </select>
                        </label>
                    </div>
                    <button onClick={lambda (e: MouseEvent) { invite(); }}>Invite</button>
                }}
            </div>
        }}

        {if tab == "activity" {
            <div className="card">
                <h3>Activity (cannot be edited)</h3>
                <ul className="activity">
                    {for a in activity {
                        <li key={str(a["at"]) + str(a["text"])}><span className="muted">{str(a["at"])}</span>{" " + str(a["actor"]) + " (" + str(a["role"]) + "): " + str(a["text"])}</li>
                    }}
                </ul>
            </div>
        }}
    </main>;
}
