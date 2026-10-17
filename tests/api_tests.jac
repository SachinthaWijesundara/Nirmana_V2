"""End-to-end API tests in one process (single user, mock LLMs): from profile to Q&A.
Test data only; run with GEDARA_LLM=mock."""
import from api.access { create_profile, get_me }
import from api.projects {
    create_project, add_element, record_payment, report_progress, request_payment,
    submit_photo_proof, ask_project, get_project, send_builder_message
}
import from agents.qa { answer_rules, project_facts }
import from twin { House, Element, Update, Has }

# A 1x1 PNG, enough for the mock vision model.
glob TINY_PNG: str = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGP4z8AAAAMBAQDJ/pLvAAAAAElFTkSuQmCC";

test "a contractor cannot change the plan, and projects live in the shared registry" {
    create_profile("Test User", "test@example.com", "contractor");
    p = create_project("Test House", "Kandy", "Kandy", "House", 1000.0, 1000000.0, "2026-01-01", "2026-12-31", "contractor", 10.0, 5.0);
    pid = str(p["id"]);
    add_element_ok = True;
    try {
        add_element(pid, "Slab", 500000.0, "2026-01-01", "2026-03-01");
    } except PermissionError { add_element_ok = False; }
    assert not add_element_ok;  # a contractor cannot change the plan

    house = [h for h in [root -->][?:House] if h.name == "Test House"];
    assert len(house) == 0;  # projects live in the shared registry, not on the user's root
    me = get_me();
    assert me["projects"][0]["role"] == "contractor";
}

test "client flow with photo proof and Q&A" {
    create_profile("Client User", "client@example.com", "client");
    p = create_project("Q House", "Galle", "Galle", "House", 1000.0, 1000000.0, "2026-01-01", "2026-12-31", "client", 10.0, 5.0);
    pid = str(p["id"]);
    add_element(pid, "Slab", 500000.0, "2026-01-01", "2026-03-01");
    record_payment(pid, 600000.0, "2026-02-01", "advance", "Slab");
    proj = get_project(pid);
    assert proj["money"]["paid"] == 600000.0;
    assert proj["money"]["verified"] == 0.0;
    # Only a contractor or architect may send photo proof.
    refused = False;
    try { submit_photo_proof(pid, "Slab", TINY_PNG); } except PermissionError { refused = True; }
    assert refused;
    answer = ask_project(pid, "How much have we paid?", "english");
    assert answer["answer"] != "";
}

test "rule answers use the graph facts" {
    house = House(name="Facts House", total_budget=1000.0, start_date="2026-01-01");
    root ++> house;
    el = Element(name="Slab", planned_cost=400.0, planned_start="2026-01-01", planned_end="2026-02-01", percent_complete=50.0);
    house +>:Has():+> el;
    house +>:Has():+> Update(raw_text="cement 40k", material="cement", cost=40000.0);
    house +>:Has():+> Update(raw_text="cement 10k", material="cement", cost=10000.0);
    facts = project_facts(house);
    assert (facts["spend_by_material"] as dict[str, float])["cement"] == 50000.0;
    a = answer_rules("How much on cement so far?", facts);
    assert "50,000" in a.answer;
    b = answer_rules("When will it be finished?", facts);
    assert "finishes" in b.answer;
}
