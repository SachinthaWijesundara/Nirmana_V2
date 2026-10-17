"""Intake walker: a messy Singlish/Sinhala/Tamil builder message becomes a structured update on the right Element."""
import os;
import from byllm.lib { Model, MockLLM }
import from twin { House, Element, Update, Activity, Has, reported_in }

obj ParsedUpdate {
    has element_name: str;
    has percent_complete: float;
    has material: str;
    has cost_spent: float;
    has delay_reason: str;
    has language: str;
}
sem ParsedUpdate.element_name = "Exactly one name from the allowed element names, matching what the builder is talking about (e.g. 'slab eka' means Slab). Empty string if none match.";
sem ParsedUpdate.percent_complete = "Progress of that element from 0 to 100. 'iwarai' / 'mudinchu' / 'finished' means 100. Use 0 if the message gives no progress.";
sem ParsedUpdate.material = "Main material mentioned, e.g. 'cement'. Empty string if none.";
sem ParsedUpdate.cost_spent = "Money spent in LKR as a plain number. '40k' means 40000, '4M' means 4000000. 0 if none mentioned.";
sem ParsedUpdate.delay_reason = "Reason for any delay (rain, no workers, material shortage). Empty string if none.";
sem ParsedUpdate.language = "Language of the message: english, sinhala, tamil or singlish.";

def mock_update() -> ParsedUpdate {
    return ParsedUpdate(element_name="Slab", percent_complete=100.0, material="cement", cost_spent=40000.0, delay_reason="", language="singlish");
}

# GEDARA_LLM=mock (tests, CI) swaps in MockLLM; otherwise the model comes from jac.toml / the default below.
def build_llm() -> any {
    if os.environ.get("GEDARA_LLM", "") == "mock" {
        return MockLLM(model_name="mockllm", config={"outputs": [mock_update() for _ in range(20)]});
    }
    return Model(model_name="claude-sonnet-4-6");
}
glob llm = build_llm();

def parse_update(message: str, element_names: list[str]) -> ParsedUpdate by llm(temperature=0.0);
sem parse_update = "Turn a construction site message from a Sri Lankan builder (English, Sinhala, Tamil or Singlish) into a structured update.";
sem parse_update.message = "The raw message the builder sent.";
sem parse_update.element_names = "Names of the building elements that exist in this house. element_name must be one of these.";

"""Apply a parsed update to an Element. Pure data change, no LLM. Returns False when nothing matched."""
def apply_update(element: Element, parsed: ParsedUpdate) -> bool {
    if parsed.percent_complete < 0.0 or parsed.percent_complete > 100.0 {
        return False;
    }
    if parsed.percent_complete > element.percent_complete {
        element.percent_complete = parsed.percent_complete;
    }
    element.actual_cost += parsed.cost_spent;
    if parsed.material != "" and parsed.material not in element.materials {
        element.materials.append(parsed.material);
    }
    return True;
}

"""Write a parsed update into the twin: update the Element, add an Update node and an Activity. Returns the report dict."""
def commit_update(house: House, message: str, parsed: ParsedUpdate) -> dict {
    elements = [house ->:Has:->[?:Element]];
    matched = [e for e in elements if e.name.lower() == parsed.element_name.lower()];
    if len(matched) == 0 {
        return {"ok": False, "reason": "no matching element", "parsed_element": parsed.element_name};
    }
    el = matched[0];
    if not apply_update(el, parsed) {
        return {"ok": False, "reason": "invalid percent", "element": el.name};
    }
    upd = Update(raw_text=message, summary=f"{el.name}: {el.percent_complete}% complete");
    upd +>:reported_in():+> el;
    house +>:Has():+> upd;
    house +>:Has():+> Activity(actor="builder", kind="intake", text=upd.summary);
    return {
        "ok": True,
        "element": el.name,
        "percent_complete": el.percent_complete,
        "actual_cost": el.actual_cost,
        "delay_reason": parsed.delay_reason,
        "language": parsed.language
    };
}

walker:pub Intake {
    has message: str;

    can start with Root entry {
        visit [-->[?:House]];
    }

    can run with House entry {
        names = [e.name for e in [here ->:Has:->[?:Element]]];
        parsed = parse_update(self.message, names);
        report commit_update(here, self.message, parsed);
    }
}
