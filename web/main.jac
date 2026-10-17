"""Nirmana web UI entry point. Screens live in screens/, data comes from the pluggable backend/."""

cl import ".styles.global.css";
cl import from .App { App }

cl def:pub app -> JsxElement {
    return <App />;
}
