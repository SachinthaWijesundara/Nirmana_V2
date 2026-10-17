"""50 States & rules: loading, empty, error, not-your-role, confirm and toast patterns every screen follows."""

import from ..components.Icon { Icon }
import from ..components.ui { Btn, Chip }
import from ..components.States { Skeleton, EmptyState, ErrorState }
import from ..components.Cards { Lock }
import from ..components.Shell { Page }
import from ..hooks.app { useApp }

def:pub StatesPage() -> JsxElement {
    app = useApp();
    return <Page title="States & rules" subtitle="Every screen that loads data needs loading, empty and error states. Actions a role cannot take are shown disabled, with the reason.">
        <div className="grid3" style={{"alignItems": "start"}}>
            <div className="col g12"><p className="over t2">Loading</p><Skeleton rows={3} /></div>
            <div className="col g12"><p className="over t2">Empty</p><div className="card" style={{"minHeight": 300, "padding": 0}}><EmptyState title="No daily logs yet" body="The contractor posts one at the end of each work day. You will see photos and notes here." action="Remind contractor" onAction={lambda { app["toast"]("Reminder sent to Ruwan Silva", ""); }} /></div></div>
            <div className="col g12"><p className="over t2">Error</p><ErrorState what="ledger" code="POST /function/get_ledger · 503" onRetry={lambda { app["toast"]("Trying again…", ""); }} /></div>
            <div className="col g12"><p className="over t2">Not your role</p><div className="card col g12"><div><Btn label="Certify phase" icon="check" onClick={lambda { }} disabled={True} /></div><Lock title="Architect only" body="Only the architect can certify phases. You will get a notification when it is done." /><p className="sm t2">Rule: hide or disable actions the current role cannot take, and always say why. The server checks the role too.</p></div></div>
            <div className="col g12"><p className="over t2">Confirm an irreversible action</p><div className="card col g12 bd" style={{"borderRadius": 24}}><p className="h3">Approve CO-004?</p><p className="sm t2">Adds Rs. 180,000 to the contract. Change-order decisions are final and logged under your name.</p><div className="row g12 end"><Btn label="Cancel" kind="text" onClick={lambda { }} /><Btn label="Yes, approve" icon="check" onClick={lambda { app["toast"]("Change order approved", "Logged to Activity · just now"); }} /></div></div></div>
            <div className="col g12"><p className="over t2">Success toast</p><div className="card col g12" style={{"minHeight": 300, "justifyContent": "flex-end"}}><p className="sm t2">Decisions are final, so this toast has no Undo. Only reversible actions, like saving a draft, get one.</p><div className="row g12 r16 tinv" style={{"background": "#013d5a", "padding": "14px 16px"}}><span className="chip s" style={{"background": "#708c69", "color": "#fff", "borderRadius": 10}}><Icon name="check" size={16} /></span><div className="col"><span className="b">Change order approved</span><span className="sm tmut">Logged to Activity · 19:12</span></div></div></div></div>
        </div>
    </Page>;
}
