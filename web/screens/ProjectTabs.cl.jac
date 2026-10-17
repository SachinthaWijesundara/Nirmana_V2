"""Project tab router: fetches project.<tab> from the backend and renders the matching tab."""

import from "@jac/runtime" { useParams }
import from ..components.Shell { ProjectShell }
import from ..components.States { Gate }
import from ..hooks.app { useApp, useResource }
import from ..backend.index { query }
import from .ProjectTabsA { OverviewTab, ScheduleTab, ProgressTab, PlansTab }
import from .ProjectTabsB { MaterialsTab, BudgetTab, ChangesTab, PaymentsTab, LedgerTab, ActivityTab, TourTab }

def:pub ProjectTab() -> JsxElement {
    params = useParams();
    tab: str = params["tab"] or "overview";
    pid: str = params["id"] or "perera-house";
    app = useApp();
    res = useResource("project." + tab, {"id": pid});
    d: any = res["data"];
    role: str = app["role"];
    reload = res["reload"];

    async def run(action: str, payload: any, msg: str) -> None {
        await app["run"](action, payload, msg, reload);
    }
    def confirm(title: str, body: str, action: str) {
        app["openOverlay"]("confirm", {"title": title, "body": body, "confirm": "Yes, approve", "run": lambda { run(action, {}, "Done"); }});
    }
    def decide(id: str, decision: str) {
        app["openOverlay"]("confirm", {
            "title": ("Approve " if decision == "approve" else "Reject ") + id + "?",
            "body": "Change-order decisions are final and logged under your name.",
            "confirm": "Yes, approve" if decision == "approve" else "Yes, reject",
            "run": lambda { run("decide_change", {"id": id, "decision": decision}, "Change order " + ("approved" if decision == "approve" else "rejected")); }
        });
    }
    async def certify() -> None {
        p: any = d if (d and "certify" in d) else await query("project.payments", {"id": pid});
        app["openOverlay"]("certify", {"id": "m3", "certify": p["certify"]});
    }
    return <ProjectShell tab={tab}>
        <Gate res={res} what={tab}>
            {d and tab == "overview" and <OverviewTab d={d} />}
            {d and tab == "schedule" and <ScheduleTab d={d} role={role} openCertify={lambda { certify(); }} />}
            {d and tab == "progress" and <ProgressTab d={d} role={role} onPost={lambda { app["openOverlay"]("daily_log", {"elements": d["elements"]}); }} onRun={run} />}
            {d and tab == "plans" and <PlansTab d={d} role={role} onRun={run} onConfirm={confirm} />}
            {d and tab == "materials" and <MaterialsTab d={d} />}
            {d and tab == "budget" and <BudgetTab d={d} onExport={lambda { window.print(); }} />}
            {d and tab == "changes" and <ChangesTab d={d} role={role} onDecide={decide} onRaise={lambda { app["toast"]("Raise change order", "Available once a backend is connected"); }} />}
            {d and tab == "payments" and <PaymentsTab d={d} role={role} onCertify={lambda { certify(); }} onPay={lambda id: str { run("pay_milestone", {"id": id}, "Payment recorded"); }} />}
            {d and tab == "ledger" and <LedgerTab d={d} role={role} onOpen={lambda e: any { app["openOverlay"]("ledger", {"entry": e, "detail": d["drawer"][e["id"]] if e["id"] in d["drawer"] else None}); }} />}
            {d and tab == "activity" and <ActivityTab d={d} />}
            {d and tab == "tour" and <TourTab d={d} onAdd={lambda { app["toast"]("Photo added to the tour", ""); }} />}
        </Gate>
    </ProjectShell>;
}
