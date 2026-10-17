"""REST adapter. Point it at any server that follows the contract in backend/README.md:
  GET  {base}/api/{resource}?{params}  ->  JSON in the shape the mock returns
  POST {base}/api/commands/{action}    ->  JSON body = payload, JSON reply
Select with ?backend=rest&api=https://host or localStorage keys nirmana.backend / nirmana.api."""

async def _send(url: str, options: dict[str, any]) -> any {
    resp: any = await fetch(url, options);
    if not resp.ok {
        raise Exception(str(resp.status) + " " + url);
    }
    body: any = await resp.json();
    return body;
}

async def:pub rest_query(base: str, resource: str, params: dict[str, any]) -> any {
    parts: list[str] = [];
    for k in Object.keys(params) {
        parts = parts + [encodeURIComponent(k) + "=" + encodeURIComponent(String(params[k]))];
    }
    suffix = ("?" + "&".join(parts)) if len(parts) > 0 else "";
    return await _send(base + "/api/" + encodeURIComponent(resource) + suffix, {"headers": {"Accept": "application/json"}});
}

async def:pub rest_command(base: str, action: str, payload: dict[str, any]) -> any {
    return await _send(base + "/api/commands/" + encodeURIComponent(action), {
        "method": "POST", "headers": {"Content-Type": "application/json"}, "body": JSON.stringify(payload)
    });
}
