"""Nirmana entry point: serves every agent walker plus the dashboard UI (`jac start main.jac`)."""

import from twin { get_twin }
import from agents.intake { Intake }
import from agents.payment { PaymentGuard, ReleaseOnProof }
import from agents.delay { DelayDetector }
import from agents.forecast { forecast }
import from agents.scenario { scenario }

cl {
    import ".styles.global.css";
    import from .components.Dashboard { Dashboard }

    def:pub app -> JsxElement {
        return <Dashboard/>;
    }
}
