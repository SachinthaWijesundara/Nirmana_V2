"""Intake walker: a messy Singlish/Sinhala/Tamil builder message becomes a structured update on the right Element."""
import os;
import re;
import from byllm.lib { Model, MockLLM }
import from twin { House, Element, Update, Activity, Has, reported_in, now_iso }

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

# Which model Intake uses:
#   GEDARA_LLM=mock      -> MockLLM (tests, CI; no key needed)
#   GROQ_API_KEY set     -> Groq, model from GEDARA_MODEL or groq/openai/gpt-oss-120b
#   GEDARA_MODEL set     -> any other LiteLLM model name, with that provider's key in the environment
#   nothing set          -> no LLM; Intake uses the rule parser below
# Keys are only ever read from the environment, never stored in code.
glob GROQ_DEFAULT_MODEL: str = "groq/openai/gpt-oss-120b";

def build_llm() -> any {
    if os.environ.get("GEDARA_LLM", "") == "mock" {
        return MockLLM(model_name="mockllm", config={"outputs": [mock_update() for _ in range(20)]});
    }
    model_name = os.environ.get("GEDARA_MODEL", "");
    if os.environ.get("GROQ_API_KEY", "") != "" {
        if model_name == "" { model_name = GROQ_DEFAULT_MODEL; }
        if not model_name.startswith("groq/") { model_name = "groq/" + model_name; }
    }
    if model_name == "" { return None; }
    return Model(model_name=model_name);
}
glob llm = build_llm();

def llm_available() -> bool {
    return llm is not None;
}

"""Rule-based fallback parser, used when no LLM is configured. Handles the common
Singlish/English shapes: an element name, "iwarai"/"done" or "60%", and "cement 40k"."""
def parse_update_rules(message: str, element_names: list[str]) -> ParsedUpdate {
    text = message.lower();
    element = "";
    for name in element_names {
        if name.lower() in text { element = name; break; }
    }
    pct = 0.0;
    pct_match = re.search(r"(\d{1,3})\s*%", text);
    if pct_match { pct = float(pct_match.group(1)); }
    for word in ["iwarai", "ivarai", "iwara", "mudinchu", "finished", "completed", "complete", "done"] {
        if word in text { pct = 100.0; }
    }
    cost = 0.0;
    material = "";
    cost_match = re.search(r"([a-z]+)?[\s\w]*?(?:rs\.?\s*)?(\d+(?:\.\d+)?)\s*(k|m|lakh|laksha)\b", text);
    if cost_match {
        amount = float(cost_match.group(2));
        unit = cost_match.group(3);
        if unit == "k" { amount = amount * 1000.0; }
        elif unit == "m" { amount = amount * 1000000.0; }
        else { amount = amount * 100000.0; }
        cost = amount;
        before = text[0:cost_match.start(2)].replace("rs", " ").split();
        candidates = [w for w in before if w.isalpha() and w not in [element.lower(), "bag", "bags", "eka", "ekak", "walata"]];
        if len(candidates) > 0 { material = candidates[len(candidates) - 1]; }
    }
    delay = "";
    for word in ["rain", "wahina", "wassa", "shortage", "no workers", "strike"] {
        if word in text { delay = word; }
    }
    language = "english";
    for word in ["eka", "iwarai", "gaththa", "walata", "wahina", "ona"] {
        if re.search(r"\b" + word + r"\b", text) { language = "singlish"; }
    }
    return ParsedUpdate(element_name=element, percent_complete=pct, material=material, cost_spent=cost, delay_reason=delay, language=language);
}

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
    upd = Update(raw_text=message, summary=f"{el.name}: {el.percent_complete}% complete", element_name=el.name, material=parsed.material.lower(), cost=parsed.cost_spent, at=now_iso());
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

walker Intake {
    has message: str;

    can start with Root entry {
        visit [-->[?:House]];
    }

    can run with House entry {
        names = [e.name for e in [here ->:Has:->[?:Element]]];
        parsed = parse_update(self.message, names) if llm_available() else parse_update_rules(self.message, names);
        report commit_update(here, self.message, parsed);
    }
}
