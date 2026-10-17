"""Who may do what. The UI hides or disables an action the current role cannot take, and always says why.
The server must check the role too; this only mirrors the rule."""

glob RULES: dict[str, list[str]] = {
    "decide_change": ["client"], "approve_plan": ["client"], "pay": ["client"], "certify": ["architect"], "post_log": ["contractor"],
    "raise_change": ["contractor"], "ledger_query": ["client", "architect"], "ledger_verify": ["architect"], "ack_log": ["architect"], "set_progress": ["contractor"]
};

glob WHO: dict[str, str] = {
    "decide_change": "Only the client decides change orders.", "approve_plan": "Only the client approves plans.", "pay": "Only the client pays milestones.",
    "certify": "Only the architect can certify phases. You will get a notification when it is done.", "post_log": "Only the contractor posts daily logs.",
    "raise_change": "Only the contractor can raise one. You decide on them here.", "ledger_query": "Only the client or architect can query a ledger entry.",
    "ledger_verify": "Only the architect can mark an entry verified.", "ack_log": "Only the architect acknowledges daily logs.", "set_progress": "Only the contractor updates element progress."
};

def:pub allowed(role: str, action: str) -> bool {
    roles: list[str] = RULES[action] if action in RULES else [];
    return role in roles;
}

def:pub why(action: str) -> str {
    return WHO[action] if action in WHO else "";
}
