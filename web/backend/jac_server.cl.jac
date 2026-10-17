"""Jac server adapter: talks to a `jac start` server through its generated /function/<name> endpoints.
It is a hybrid: resources the Jac server implements are mapped into the contract shapes, and everything
else falls back to the mock adapter so the UI stays complete while the server grows.
Today it maps `dashboard` from ui/api.jac's get_house_view (the D1 twin dashboard branch)."""

import from .mock { mock_query, mock_command }
import from ..lib.fmt { rs }

def _unwrap(body: any) -> any {
    if body and body.data and body.data.result { return body.data.result; }
    if body and body.result { return body.result; }
    return body;
}

async def _call(base: str, name: str, args: dict[str, any]) -> any {
    resp: any = await fetch(base + "/function/" + name, {"method": "POST", "headers": {"Content-Type": "application/json"}, "body": JSON.stringify(args)});
    if not resp.ok { raise Exception(str(resp.status) + " /function/" + name); }
    body: any = await resp.json();
    return _unwrap(body);
}

def _millions(n: any) -> str {
    value: any = Math.round((n as float) / 10000.0) / 100.0;
    return "Rs. " + str(value) + "M";
}

async def:pub jac_query(base: str, resource: str, params: dict[str, any]) -> any {
    if resource == "dashboard" {
        base_view: any = await mock_query(resource, params);
        view: any = await _call(base, "get_house_view", {});
        m: any = view.money;
        stats: any = base_view["stats"];
        stats[0]["value"] = _millions(m.paid);
        stats[0]["sub"] = "of " + _millions(m.budget) + " contract";
        stats[1]["value"] = _millions(m.verified);
        stats[1]["sub"] = _millions(m.paid_ahead) + " paid ahead of work";
        stats[3]["value"] = view.forecast.finish;
        stats[3]["sub"] = str(rs(view.forecast.over_budget)) + " over";
        base_view["stats"] = stats;
        base_view["paid_ahead"] = _millions(m.paid_ahead);
        rows: any = [[], [], [], [], [], [], []];
        for el in view.elements {
            rows[el.row].push({"name": el.name, "pct": el.percent_complete, "status": el.status});
        }
        base_view["layers"] = rows.filter(lambda r: any -> bool { return bool(r.length); });
        return base_view;
    }
    return await mock_query(resource, params);
}

async def:pub jac_command(base: str, action: str, payload: dict[str, any]) -> any {
    if action == "send_message" and payload["thread"] == "ph" {
        await _call(base, "send_builder_message", {"text": payload["text"]});
    }
    return await mock_command(action, payload);
}
