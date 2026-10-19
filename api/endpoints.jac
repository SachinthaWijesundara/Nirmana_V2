"""The public API: every endpoint the website and scripts call.

Each one runs the real implementation (api/access.jac, api/projects.jac) and turns an error
into a normal reply, {"error": "..."}, instead of raising. On Jac 0.34 a request that raises
is aborted, and the abort deletes every record that request had touched from the database
(TieredMemory.abort), so one refused action could wipe a project or a member. The
implementations check everything before they write, so a refused action changes nothing."""
import from api.access {
    create_profile as create_profile_impl, get_me as get_me_impl
}
import from api.projects {
    create_project as create_project_impl, invite_member as invite_member_impl, list_projects as list_projects_impl,
    update_project as update_project_impl, add_element as add_element_impl, update_element as update_element_impl,
    record_payment as record_payment_impl, get_project as get_project_impl, get_activity as get_activity_impl,
    send_builder_message as send_builder_message_impl, report_progress as report_progress_impl, request_payment as request_payment_impl,
    verify_progress as verify_progress_impl, run_delay_check as run_delay_check_impl, get_forecast as get_forecast_impl,
    run_scenario as run_scenario_impl, submit_photo_proof as submit_photo_proof_impl, ask_project as ask_project_impl
}

"""The reply for a refused or failed action; the website shows the message."""
def failed(e: Exception) -> dict[str, any] {
    return {"error": str(e)};
}

def create_profile(name: str, email: str, role: str = "client", phone: str = "") -> dict[str, any] {
    try { return create_profile_impl(name, email, role, phone); } except Exception as e { return failed(e); }
}

def get_me() -> dict[str, any] {
    try { return get_me_impl(); } except Exception as e { return failed(e); }
}

def create_project(
    name: str, location: str = "", district: str = "", building_type: str = "",
    floor_area_sqft: float = 0.0, contract_sum: float = 0.0, start_date: str = "",
    handover_date: str = "", my_role: str = "client", advance_limit_pct: float = 10.0,
    retention_pct: float = 5.0
) -> dict[str, any] {
    try { return create_project_impl(name, location, district, building_type, floor_area_sqft, contract_sum, start_date, handover_date, my_role, advance_limit_pct, retention_pct); } except Exception as e { return failed(e); }
}

def invite_member(project_id: str, email: str, role: str, name: str = "") -> dict[str, any] {
    try { return invite_member_impl(project_id, email, role, name); } except Exception as e { return failed(e); }
}

def list_projects() -> list[dict[str, any]] | dict[str, any] {
    try { return list_projects_impl(); } except Exception as e { return failed(e); }
}

def update_project(
    project_id: str, name: str = "", location: str = "", district: str = "", building_type: str = "",
    floor_area_sqft: float = -1.0, contract_sum: float = -1.0, handover_date: str = "", status: str = "",
    advance_limit_pct: float = -1.0, retention_pct: float = -1.0
) -> dict[str, any] {
    try { return update_project_impl(project_id, name, location, district, building_type, floor_area_sqft, contract_sum, handover_date, status, advance_limit_pct, retention_pct); } except Exception as e { return failed(e); }
}

def add_element(
    project_id: str, name: str, planned_cost: float, planned_start: str, planned_end: str,
    kind: str = "", floor: str = "", prerequisites: list[str] | None = None, qty: float = 0.0, unit: str = "",
    material_shares: dict[str, float] | None = None
) -> dict[str, any] {
    try { return add_element_impl(project_id, name, planned_cost, planned_start, planned_end, kind, floor, prerequisites, qty, unit, material_shares); } except Exception as e { return failed(e); }
}

def update_element(
    project_id: str, element_name: str, planned_cost: float = -1.0, planned_start: str = "",
    planned_end: str = "", kind: str = "", floor: str = ""
) -> dict[str, any] {
    try { return update_element_impl(project_id, element_name, planned_cost, planned_start, planned_end, kind, floor); } except Exception as e { return failed(e); }
}

def record_payment(
    project_id: str, amount: float, date: str = "", note: str = "", element_name: str = ""
) -> dict[str, any] {
    try { return record_payment_impl(project_id, amount, date, note, element_name); } except Exception as e { return failed(e); }
}

def get_project(project_id: str) -> dict[str, any] {
    try { return get_project_impl(project_id); } except Exception as e { return failed(e); }
}

def get_activity(project_id: str, category: str = "") -> list[dict[str, any]] | dict[str, any] {
    try { return get_activity_impl(project_id, category); } except Exception as e { return failed(e); }
}

def send_builder_message(project_id: str, message: str) -> dict[str, any] {
    try { return send_builder_message_impl(project_id, message); } except Exception as e { return failed(e); }
}

def report_progress(
    project_id: str, element_name: str, percent: float, on_date: str = "",
    started_on: str = "", actual_cost: float = 0.0
) -> dict[str, any] {
    try { return report_progress_impl(project_id, element_name, percent, on_date, started_on, actual_cost); } except Exception as e { return failed(e); }
}

def request_payment(project_id: str, amount: float, note: str = "") -> dict[str, any] {
    try { return request_payment_impl(project_id, amount, note); } except Exception as e { return failed(e); }
}

def verify_progress(
    project_id: str, element_name: str, verified_percent: float, note: str = ""
) -> dict[str, any] {
    try { return verify_progress_impl(project_id, element_name, verified_percent, note); } except Exception as e { return failed(e); }
}

def run_delay_check(project_id: str, today: str = "") -> list[dict[str, any]] | dict[str, any] {
    try { return run_delay_check_impl(project_id, today); } except Exception as e { return failed(e); }
}

def get_forecast(project_id: str, today: str = "") -> dict[str, any] {
    try { return get_forecast_impl(project_id, today); } except Exception as e { return failed(e); }
}

def run_scenario(
    project_id: str, cement_pct: float = 0.0, delay_days: int = 0, delay_element: str = "",
    today: str = ""
) -> dict[str, any] {
    try { return run_scenario_impl(project_id, cement_pct, delay_days, delay_element, today); } except Exception as e { return failed(e); }
}

def submit_photo_proof(project_id: str, element_name: str, image: str, note: str = "") -> dict[str, any] {
    try { return submit_photo_proof_impl(project_id, element_name, image, note); } except Exception as e { return failed(e); }
}

def ask_project(project_id: str, question: str, language: str = "english") -> dict[str, any] {
    try { return ask_project_impl(project_id, question, language); } except Exception as e { return failed(e); }
}
