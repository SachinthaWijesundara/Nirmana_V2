"""Backend registry. The UI only ever calls query() and command(); which adapter answers is chosen at runtime:
  ?backend=mock|rest|jac   (remembered in localStorage as nirmana.backend, default mock)
  ?api=http://host:port    (remembered as nirmana.api, used by rest and jac)
To plug in a new backend: add an adapter module exposing <name>_query(base, resource, params) and
<name>_command(base, action, payload), then add a branch below."""

import from .mock { mock_query, mock_command }
import from .rest { rest_query, rest_command }
import from .jac_server { jac_query, jac_command }

def _remember(key: str, param: str, fallback: str) -> str {
    qs: any = new(URLSearchParams, window.location.search);  # jac:ignore[E1053]
    fresh: any = qs.get(param);
    try {
        if fresh {
            localStorage.setItem(key, str(fresh));
            return str(fresh);
        }
        stored: any = localStorage.getItem(key);
        return str(stored or fallback);
    } except Exception {
        return str(fresh or fallback);
    }
}

def:pub backend_name() -> str {
    return _remember("nirmana.backend", "backend", "mock");
}

def:pub backend_base() -> str {
    return _remember("nirmana.api", "api", "");
}

async def:pub query(resource: str, params: dict[str, any] = {}) -> any {
    name = backend_name();
    base = backend_base();
    if name == "rest" { return await rest_query(base, resource, params); }
    if name == "jac" { return await jac_query(base, resource, params); }
    return await mock_query(resource, params);
}

async def:pub command(action: str, payload: dict[str, any] = {}) -> any {
    name = backend_name();
    base = backend_base();
    if name == "rest" { return await rest_command(base, action, payload); }
    if name == "jac" { return await jac_command(base, action, payload); }
    return await mock_command(action, payload);
}
