"""D1 twin dashboard. The stateful shell: it owns the fetched HouseView, the builder message and the
last Intake result, and passes data and callbacks down to stateless sections."""
import from .components.Sidebar { Sidebar }
import from .components.StatCards { StatCards }
import from .components.HouseTwin { HouseTwin }
import from .components.MoneyVsWork { MoneyVsWork }
import from .components.MessageBox { MessageBox }
import from .components.IntakeCard { IntakeCard }
import from .components.AgentFeed { AgentFeed }
sv import from ui.api { HouseView, IntakeResult, get_house_view, send_builder_message }

glob DEMO_MESSAGE: str = "slab eka iwarai, cement bag 40k gaththa";

glob NAV_TITLES: dict[str, str] = {
    "guard": "Payment Guard", "forecast": "Forecast & what-if", "graph": "Twin graph", "ask": "Ask the twin"
};

def:pub Header(houseName: str, location: str) -> JsxElement {
    return <header>
        <h1 className="h1">{houseName} · digital twin</h1>
        <p className="muted" style={{"margin": "4px 0 0"}}>{location} · twin synced just now · watched from Doha</p>
    </header>;
}

def:pub LoadingState() -> JsxElement {
    return <div aria-busy="true" aria-label="Loading the twin" style={{"display": "flex", "flexDirection": "column", "gap": "24px"}}>
        <div className="skeleton" style={{"height": "44px", "width": "60%"}}></div>
        <div className="stats">
            {for i in range(4) { <div key={str(i)} className="skeleton" style={{"height": "176px"}}></div> }}
        </div>
        <div className="twin-grid">
            <div className="skeleton" style={{"height": "440px"}}></div>
            <div className="skeleton" style={{"height": "320px"}}></div>
        </div>
    </div>;
}

def:pub ErrorState(message: str, onRetry: Callable[[], None]) -> JsxElement {
    return <div className="card" role="alert">
        <h2 className="h3">Could not load the twin</h2>
        <p className="small error">{message}</p>
        <button className="btn-outline" onClick={lambda { onRetry(); }}>Try again</button>
    </div>;
}

def:pub ComingNext(title: str, onBack: Callable[[], None]) -> JsxElement {
    return <div className="card">
        <h1 className="h1">{title}</h1>
        <p className="muted">This screen is not part of the D1 demo build yet.</p>
        <button className="btn-outline" onClick={lambda { onBack(); }}>Back to the twin</button>
    </div>;
}

def:pub App() -> JsxElement {
    has view: HouseView | None = None,
        loading: bool = True,
        load_error: str = "",
        page: str = "twin",
        message: str = DEMO_MESSAGE,
        sending: bool = False,
        send_error: str = "",
        intake: IntakeResult | None = None,
        updated_element: str = "";

    can with entry {
        load_view();
    }

    async def load_view {
        loading = True;
        load_error = "";
        try {
            view = await get_house_view();
        } except Exception as e {
            load_error = f"The server did not answer ({str(e)}). Check that the Jac server is running.";
        }
        loading = False;
    }

    """Refetch after a write without showing the skeleton again."""
    async def refresh_view {
        try {
            view = await get_house_view();
        } except Exception as e {
            send_error = f"Saved, but the dashboard could not refresh ({str(e)}).";
        }
    }

    async def send_message -> None {
        if sending or message.strip() == "" {
            return;
        }
        sending = True;
        send_error = "";
        try {
            result = await send_builder_message(message);
            intake = result;
            if result.ok {
                updated_element = result.element;
                await refresh_view();
            }
        } except Exception as e {
            send_error = f"Could not reach the Intake walker ({str(e)}).";
        }
        sending = False;
    }

    return <div className="shell">
        <Sidebar active={page} heldCount={view.money.held_count if view is not None else 0}
            onNavigate={lambda key: str { page = key; }}/>

        <main className="main">
            {if page != "twin" {
                <ComingNext key="next" title={NAV_TITLES[page] if page in NAV_TITLES else "Nirmana"} onBack={lambda { page = "twin"; }}/>
            } elif loading and view is None {
                <LoadingState key="loading"/>
            } elif view is None {
                <ErrorState key="error" message={load_error or "No twin data."} onRetry={load_view}/>
            } else {
                <Header key="header" houseName={view.house_name} location={view.location}/>
                <StatCards key="stats" money={view.money} forecast={view.forecast}/>
                <div key="grid" className="twin-grid">
                    <HouseTwin elements={view.elements} updatedElement={updated_element}/>
                    <MoneyVsWork money={view.money} onOpenGuard={lambda { page = "guard"; }}/>
                </div>
            }}
        </main>

        <aside className="panel" aria-label="Builder and agents">
            <MessageBox message={message} language={intake.language if intake is not None and intake.ok else ""}
                sending={sending} onChange={lambda v: str { message = v; }} onSend={send_message}/>
            <IntakeCard result={intake} sending={sending} error={send_error}/>
            {if view is not None {
                <AgentFeed key="feed" alerts={view.alerts}/>
            } elif loading {
                <p key="feed-loading" className="small muted">Loading agent feed…</p>
            } else {
                <p key="feed-error" className="small error">Agent feed unavailable until the twin loads.</p>
            }}
        </aside>
    </div>;
}
