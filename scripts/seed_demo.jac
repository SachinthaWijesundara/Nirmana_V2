"""Load the demo accounts and projects into a running backend, through the public API.

    jac start main.jac --no_client          (in one terminal)
    jac run scripts/seed_demo.jac           (in another; set NIRMANA_URL if not localhost:8000)

Reads seed/demo_data.json. Every user is registered and signed in like a real user, and
every project, element, payment and progress report is created by calling the endpoints
as that user, so the role checks run exactly as they do in the app."""
import os;
import json;
import from urllib.request { Request, urlopen }
import from urllib.error { HTTPError }

glob base_url: str = os.environ.get("NIRMANA_URL", "http://localhost:8000");

def post(path: str, body: dict[str, any], token: str = "") -> dict[str, any] {
    headers: dict[str, str] = {"Content-Type": "application/json"};
    if token != "" { headers["Authorization"] = "Bearer " + token; }
    req = Request(base_url + path, data=json.dumps(body).encode("utf-8"), headers=headers, method="POST");
    text: str = "";
    try {
        resp = urlopen(req, timeout=60);
        text = str(resp.read().decode("utf-8"));
    } except HTTPError as e {
        return {"ok": False, "error": str(e)};
    }
    parsed = json.loads(text) as dict[str, any];
    return parsed;
}

def payload(res: dict[str, any]) -> dict[str, any] {
    if "data" in res and isinstance(res["data"], dict) {
        data: dict[str, any] = res["data"];
        return data;
    }
    return {};
}

def sign_in(email: str, password: str) -> str {
    creds: dict[str, any] = {"type": "password", "password": password};
    post("/user/register", {"identities": [{"type": "username", "value": email}], "credential": creds});
    res = post("/user/login", {"identity": {"type": "username", "value": email}, "credential": creds});
    data = payload(res);
    if "token" not in data { raise RuntimeError(f"Could not sign in {email}: {res}"); }
    return str(data["token"]);
}

"""Call an endpoint; raise if the backend returned an error."""
def call(token: str, name: str, args: dict[str, any]) -> any {
    res = post("/function/" + name, args, token);
    data = payload(res);
    if "error" in data { raise RuntimeError(f"{name} failed: {data['error']}"); }
    if "result" not in data { raise RuntimeError(f"{name} failed: {res}"); }
    result = data["result"];
    # endpoints report a refused action as {"error": ...} (see api/endpoints.jac)
    if isinstance(result, dict) and "error" in result { raise RuntimeError(f"{name} failed: {result['error']}"); }
    return result;
}

def resolve(value: any, saved: dict[str, str]) -> any {
    if isinstance(value, str) and value.startswith("$") and value[1:] in saved { return saved[value[1:]]; }
    return value;
}

with entry:__main__ {
    here_dir = os.path.dirname(os.path.abspath(__file__));
    data_path = os.path.join(here_dir, "..", "seed", "demo_data.json");
    demo = json.loads(open(data_path, encoding="utf-8").read()) as dict[str, any];

    tokens: dict[str, str] = {};
    for u in demo["users"] {
        email = str(u["email"]);
        tokens[email] = sign_in(email, str(u["password"]));
        call(tokens[email], "create_profile", {"name": u["name"], "email": email, "role": u["role"], "phone": u["phone"]});
        print(f"user    {u['email']} ({u['role']})");
    }

    saved: dict[str, str] = {};
    for step in demo["steps"] {
        args: dict[str, any] = {};
        for (k, v) in step["args"].items() { args[k] = resolve(v, saved); }
        result = call(tokens[str(step["as"])], str(step["call"]), args);
        if "save_as" in step { saved[str(step["save_as"])] = str(result["id"]); }
        print(f"ok      {step['call']} as {step['as']}");
    }
    print(f"Seeded {len(tokens)} users and {len(saved)} projects at {base_url}.");
}
