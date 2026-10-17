"""Shared app state (who is signed in, toast, overlays) exposed through a React context, plus the data hook."""

import from react { createContext, useContext }
import from ..backend.index { query }

glob:pub AppCtx: any = createContext(None);

def:pub useApp() -> any {
    ctx: any = useContext(AppCtx);
    return ctx;
}

"""Fetch one backend resource. Returns {data, loading, error, reload}; refetches when resource or params change."""
def:pub useResource(resource: str, params: dict[str, any] = {}) -> dict[str, any] {
    has data: any = None,
        loading: bool = True,
        error: str = "",
        tick: int = 0;
    key = resource + JSON.stringify(params);

    async can with (key, tick) entry {
        loading = True;
        error = "";
        try {
            result: any = await query(resource, params);
            data = result;
        } except Exception as e {
            error = str(e);
        }
        loading = False;
    }

    def reload() { tick = tick + 1; }
    return {"data": data, "loading": loading, "error": error, "reload": reload, "resource": resource};
}
