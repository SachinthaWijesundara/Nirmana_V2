"""Nirmana dashboard: the stateful shell. It owns all page state and calls the agent walkers;
the section components only render props and send events back up."""

import from .MoneyPanel { MoneyPanel }
import from .ElementTable { ElementTable }
import from .BuilderMessage { BuilderMessage }
import from .PaymentRequest { PaymentRequest }
import from .ForecastPanel { ForecastPanel }
import from .ActivityFeed { ActivityFeed }
import from ..lib.format { rs, nice_date }

sv import from dashboard_api { DashboardView, dashboard_view }
sv import from agents.intake { Intake }
sv import from agents.payment { PaymentGuard, ReleaseOnProof }
sv import from agents.delay { DelayDetector }
sv import from agents.scenario { scenario }

# Fixed demo day so the demo is the same every time it is recorded (matches the forecast walker).
glob DEMO_TODAY: str = "2026-09-18";

def:pub Dashboard -> JsxElement {
    has view: DashboardView | None = None,
        message: str = "slab eka iwarai, cement bag 40k gaththa",
        intakeResult: dict[str, any] = {},
        amount: str = "800000",
        payNote: str = "slab balance",
        payResult: dict[str, any] = {},
        proofResult: dict[str, any] = {},
        cementPct: str = "15",
        delayDays: str = "0",
        delayElement: str = "",
        whatIf: dict[str, any] = {},
        delays: list[any] = [],
        delayChecked: bool = False,
        busy: str = "",
        error: str = "";

    async can with entry {
        await refresh();
    }

    async def refresh -> None;
    async def sendMessage -> None;
    async def requestPayment -> None;
    async def verify(name: str, percent: float) -> None;
    async def runScenario -> None;
    async def runDelayCheck -> None;

    return <div>
        <header className="topbar">
            <div className="brand">Nirmana<span>.</span></div>
            <div className="house">{view.house_name if view else "Loading house..."}</div>
            <div className="meta">
                <div>Budget <b>{rs(view.money.budget) if view else "-"}</b></div>
                <div>Started <b>{nice_date(view.start_date) if view else "-"}</b></div>
                <div>Demo day <b>{nice_date(DEMO_TODAY)}</b></div>
            </div>
        </header>
        <main className="page">
            {error and <div className="error">{error}</div>}
            {if view {
                <MoneyPanel key="money" money={view.money} payments={view.payments}/>
                <div key="work" className="row">
                    <ElementTable elements={view.elements} today={DEMO_TODAY} busy={busy} onVerify={verify}/>
                    <div className="stack">
                        <BuilderMessage
                            message={message}
                            busy={busy == "intake"}
                            result={intakeResult}
                            onChange={lambda v: str -> None { message = v; }}
                            onSend={sendMessage}
                        />
                        <PaymentRequest
                            amount={amount}
                            note={payNote}
                            busy={busy == "payment"}
                            result={payResult}
                            proof={proofResult}
                            onAmount={lambda v: str -> None { amount = v; }}
                            onNote={lambda v: str -> None { payNote = v; }}
                            onRequest={requestPayment}
                        />
                    </div>
                </div>
                <div key="plan" className="row">
                    <ForecastPanel
                        forecast={view.forecast}
                        names={[e.name for e in view.elements]}
                        cementPct={cementPct}
                        delayDays={delayDays}
                        delayElement={delayElement}
                        whatIf={whatIf}
                        delays={delays}
                        delayChecked={delayChecked}
                        busy={busy}
                        onCement={lambda v: str -> None { cementPct = v; }}
                        onDelayDays={lambda v: str -> None { delayDays = v; }}
                        onDelayElement={lambda v: str -> None { delayElement = v; }}
                        onScenario={runScenario}
                        onDelayCheck={runDelayCheck}
                    />
                    <ActivityFeed activities={view.activities}/>
                </div>
            }}
        </main>
    </div>;
}
