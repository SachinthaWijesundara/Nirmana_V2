"""Nirmana backend entry point: `jac start main.jac --no_client`.

Accounts: POST /user/register and /user/login (built into Jac; the email is the username),
then POST /function/create_profile once. Every endpoint below needs the Bearer token."""
import from api.access { create_profile, get_me }
import from api.projects {
    create_project, invite_member, list_projects, update_project, get_project, get_activity,
    add_element, update_element, record_payment,
    send_builder_message, report_progress, request_payment, verify_progress,
    run_delay_check, get_forecast, run_scenario
}
