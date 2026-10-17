"""Mock backend: an in-memory copy of the seed data, kept in sessionStorage so a demo survives reloads (close the tab to reset).
It is the default adapter, so the UI runs with no server.
Implements the same two verbs as every adapter: mock_query(resource, params) and mock_command(action, payload)."""

import from .seed_core { USERS, DASHBOARD, PROJECTS, APPROVALS, THREADS, MESSAGES, MESSAGE_NOTE, PINNED, MARKET, ESTIMATOR, CALC_RATES, ROLE_BLURBS }
import from .seed_project { PROJECT_TABS, TABS, ASK_PROMPTS, ASK_ANSWERS }
import from ..lib.fmt { clone, rs }

glob _db: any = None;

def _save() -> None {
    try { sessionStorage.setItem("nirmana.mock", JSON.stringify(_db)); } except Exception { }
}

def _ensure() -> any {
    if not _db {
        try {
            saved: any = sessionStorage.getItem("nirmana.mock");
            if saved { _db = JSON.parse(saved); }
        } except Exception { }
    }
    if not _db {
        _db = {
            "roles": clone(ROLE_BLURBS), "users": clone(USERS), "dashboard": clone(DASHBOARD), "projects": clone(PROJECTS),
            "approvals": clone(APPROVALS), "threads": clone(THREADS), "messages": clone(MESSAGES), "market": clone(MARKET),
            "estimator": clone(ESTIMATOR), "tabs": clone(PROJECT_TABS), "activity_extra": []
        };
    }
    return _db;
}

async def _latency() -> None {
    await new(Promise, lambda(resolve: any) { setTimeout(resolve, 140); });
}

def _find(items: any, key: str, value: any) -> any {
    for it in items {
        if it[key] == value { return it; }
    }
    return None;
}

def _log_activity(who: str, role: str, initials: str, act: str, what: any) -> None {
    db: any = _ensure();
    older = db["activity_extra"] as list[any];
    db["activity_extra"] = [{"time": "now", "icon": "check", "kind": "Approvals", "who": who, "role": role, "initials": initials, "act": act, "what": what, "tone": "herb"}] + older;
}

async def:pub mock_query(resource: str, params: dict[str, any]) -> any {
    db: any = _ensure();
    await _latency();
    if resource == "roles" { return clone(db["roles"]); }
    if resource == "session" {
        unread = 0;
        for t in db["threads"] { unread = unread + (t["unread"] as int); }
        pending = db["approvals"]["items"] as list[any];
        return {"user": clone(db["users"][params["role"]]), "badges": {"approvals": len(pending), "messages": unread}};
    }
    if resource == "dashboard" {
        d: any = clone(db["dashboard"]);
        waiting = db["approvals"]["items"] as list[any];
        d["waiting"] = clone(waiting[:3]);
        return d;
    }
    if resource == "projects" { return clone(db["projects"]); }
    if resource == "approvals" { return clone(db["approvals"]); }
    if resource == "threads" { return clone(db["threads"]); }
    if resource == "thread" {
        return {"messages": clone(db["messages"][params["id"]]), "note": MESSAGE_NOTE if params["id"] == "ph" else "", "pinned": clone(PINNED)};
    }
    if resource == "market" { return clone(db["market"]); }
    if resource == "estimator" { return clone(db["estimator"]); }
    if resource == "calc_rates" { return clone(CALC_RATES); }
    if resource == "ask_prompts" { return clone(ASK_PROMPTS); }
    if resource == "project" {
        p: any = _find(db["projects"], "id", params["id"]);
        return {"project": clone(p), "tabs": clone(TABS)};
    }
    if resource.startswith("project.") {
        tab: str = resource[8:];
        data: any = clone(db["tabs"][tab]);
        if tab == "ledger" {
            rows = data["entries"] as list[any];
            data["counts"] = {"all": 25, "pending": 1 + len([e for e in rows if e["status"] == "Pending review"]), "queried": len([e for e in rows if e["status"] == "Queried"]), "flagged": 1 + len([e for e in rows if e["flag"]])};
        }
        extra = db["activity_extra"] as list[any];
        if tab == "activity" and len(extra) > 0 {
            groups = data["groups"] as list[any];
            groups[0]["items"] = clone(extra) + (groups[0]["items"] as list[any]);
            data["groups"] = groups;
        }
        return data;
    }
    raise Exception("mock backend: unknown resource " + resource);
}

async def:pub mock_command(action: str, payload: dict[str, any]) -> any {
    result: any = await _apply(action, payload);
    _save();
    return result;
}

async def _apply(action: str, payload: dict[str, any]) -> any {
    db: any = _ensure();
    await _latency();
    if action == "decide_approval" {
        item: any = _find(db["approvals"]["items"], "id", payload["id"]);
        approved = payload["decision"] == "approve";
        if item {
            open_items = db["approvals"]["items"] as list[any];
            done_items = db["approvals"]["done"] as list[any];
            db["approvals"]["items"] = [i for i in open_items if i["id"] != payload["id"]];
            db["approvals"]["done"] = [{"title": item["title"], "meta": ("Approved by you · 17 Oct" if approved else "Rejected by you · 17 Oct")}] + done_items;
            noun = "a change order" if item["kind"] == "change" else ("a plan" if item["kind"] == "plan" else "an item");
            _log_activity("Nimali Perera", "Client", "NP", ("approved " if approved else "rejected ") + noun, item["title"]);
            if item["kind"] == "change" {
                order: any = _find(db["tabs"]["changes"]["orders"], "id", "CO-004");
                order["status"] = "approved" if approved else "rejected";
                order["decided"] = ("Approved" if approved else "Rejected") + " by Nimali Perera · 17 Oct";
            }
        }
        return {"ok": True, "message": ("Change order approved" if approved else "Change order rejected") if payload["id"] == "co-004" else ("Approved" if approved else "Rejected")};
    }
    if action == "decide_change" {
        order: any = _find(db["tabs"]["changes"]["orders"], "id", payload["id"]);
        approved = payload["decision"] == "approve";
        order["status"] = "approved" if approved else "rejected";
        order["decided"] = ("Approved" if approved else "Rejected") + " by Nimali Perera · 17 Oct";
        open_items = db["approvals"]["items"] as list[any];
        db["approvals"]["items"] = [i for i in open_items if i["id"] != "co-004"];
        _log_activity("Nimali Perera", "Client", "NP", "approved a change order" if approved else "rejected a change order", str(payload["id"]) + " · " + str(order["title"]));
        return {"ok": True, "message": "Change order approved" if approved else "Change order rejected"};
    }
    if action == "certify_milestone" {
        ms: any = _find(db["tabs"]["payments"]["milestones"], "id", payload["id"]);
        ms["stage"] = 2;
        ms["stage_label"] = "Certified";
        ms["tag"] = "Certified · ready to pay";
        ms["tone"] = "progress";
        ms["note"] = "Certified by Anushka Fernando. The client can now pay.";
        _log_activity("Anushka Fernando", "Architect", "AF", "certified a milestone", "M3 · Slab complete · Rs. 760,000");
        return {"ok": True, "message": "Milestone certified"};
    }
    if action == "pay_milestone" {
        ms: any = _find(db["tabs"]["payments"]["milestones"], "id", payload["id"]);
        ms["stage"] = 4;
        ms["stage_label"] = "Paid";
        ms["tag"] = "Paid 17 Oct";
        ms["tone"] = "herb";
        _log_activity("Nimali Perera", "Client", "NP", "paid a milestone", "M3 · Slab complete · Rs. 760,000");
        return {"ok": True, "message": "Payment recorded"};
    }
    if action == "post_daily_log" {
        logs = db["tabs"]["progress"]["logs"] as list[any];
        entry = {"id": "l" + str(len(logs) + 20), "day": "17", "mon": "Oct", "title": payload["title"], "weather": payload["weather"], "workers": str(payload["workers"]) + " workers", "when": "Oct · Sat",
                 "text": payload["text"], "photos": payload["photos"], "by": "Ruwan Silva", "initials": "RS", "status": "Awaiting architect", "ack": False};
        db["tabs"]["progress"]["logs"] = [entry] + logs;
        _log_activity("Ruwan Silva", "Contractor", "RS", "posted a daily log", payload["title"]);
        return {"ok": True, "message": "Daily log posted"};
    }
    if action == "ack_log" {
        for l in db["tabs"]["progress"]["logs"] {
            if l["id"] == payload["id"] {
                l["ack"] = True;
                l["status"] = "Acknowledged · A. Fernando";
            }
        }
        return {"ok": True, "message": "Log acknowledged"};
    }
    if action == "set_progress" {
        for s in db["tabs"]["progress"]["sliders"] {
            if s["name"] == payload["name"] { s["pct"] = payload["pct"]; }
        }
        return {"ok": True, "message": "Progress updated"};
    }
    if action == "ledger_query" or action == "ledger_verify" {
        e: any = _find(db["tabs"]["ledger"]["entries"], "id", payload["id"]);
        if action == "ledger_query" {
            e["status"] = "Queried";
            e["status_tone"] = "info";
        } else {
            e["status"] = "Verified";
            e["status_tone"] = "herb";
            e["audit"] = "OK";
            e["audit_tone"] = "herb";
            e["flag"] = False;
        }
        return {"ok": True, "message": "Entry sent back to the contractor" if action == "ledger_query" else "Entry marked verified"};
    }
    if action == "send_message" {
        thread = db["messages"][payload["thread"]] as list[any];
        db["messages"][payload["thread"]] = thread + [{"from": payload["initials"], "name": payload["name"], "role": payload["role"], "text": payload["text"], "photos": 0, "time": "now", "mine": True, "tone": payload["tone"]}];
        return {"ok": True, "message": "Sent"};
    }
    if action == "mark_read" {
        for t in db["threads"] {
            if t["id"] == payload["thread"] { t["unread"] = 0; }
        }
        return {"ok": True, "message": ""};
    }
    if action == "ask" {
        q: str = str(payload["question"]).lower();
        key = "other";
        if "transparen" in q { key = "transparency"; }
        elif "roof" in q { key = "roof"; }
        elif "budget" in q or "over" in q { key = "budget"; }
        elif "week" in q or "summar" in q { key = "week"; }
        elif "draft" in q or "reply" in q or "cement" in q { key = "draft"; }
        return clone(ASK_ANSWERS[key]);
    }
    if action == "estimate" {
        est: any = clone(db["estimator"]);
        area = payload["area"] as float;
        rate_factor = 0.85 if payload["finish"] == "Basic" else (1.25 if payload["finish"] == "Premium" else 1.0);
        factor = (area / 2150.0) * rate_factor;
        total = 0.0;
        for line in est["lines"] {
            if not str(line["item"]).startswith("Contingency") {
                line["amount"] = Math.round((line["amount"] as float) * factor / 1000.0) * 1000;
                total = total + (line["amount"] as float);
            }
        }
        cont = Math.round(total * (payload["contingency"] as float) / 100.0 / 1000.0) * 1000;
        for line in est["lines"] {
            if str(line["item"]).startswith("Contingency") {
                line["amount"] = cont;
                line["item"] = "Contingency · " + str(payload["contingency"]) + "%";
            }
        }
        grand = total + cont;
        est["total"] = grand;
        est["likely"] = "Rs. " + str(Math.round(grand / 10000.0) / 100.0) + "M";
        est["low"] = "Rs. " + str(Math.round(grand * 0.9 / 100000.0) / 10.0) + "M";
        est["high"] = "Rs. " + str(Math.round(grand * 1.13 / 100000.0) / 10.0) + "M";
        est["per_sqft"] = "≈ " + str(rs(Math.round(grand / area / 10.0) * 10)) + " per sq ft";
        est["area"] = payload["area"];
        est["finish"] = payload["finish"];
        est["contingency"] = payload["contingency"];
        return est;
    }
    if action == "approve_plan" {
        sheet: any = _find(db["tabs"]["plans"]["sheets"], "id", "a102");
        sheet["status"] = "Approved";
        sheet["tone"] = "herb";
        open_items = db["approvals"]["items"] as list[any];
        db["approvals"]["items"] = [i for i in open_items if i["id"] != "plan-a102"];
        _log_activity("Nimali Perera", "Client", "NP", "approved a plan", "A-102 Ground floor · rev C");
        return {"ok": True, "message": "Plan rev C approved"};
    }
    if action == "noop" { return {"ok": True, "message": "Done"}; }
    if action == "create_project" { return {"ok": True, "message": "Project created"}; }
    raise Exception("mock backend: unknown action " + action);
}
