"""Nirmana entry point: the dashboard API (ui/api.jac) plus the D1 twin dashboard UI."""

import from ui.api { get_house_view, send_builder_message }

cl {
    import "./ui/styles.css";
    import from .ui.App { App }

    def:pub app -> JsxElement {
        return <App/>;
    }
}
