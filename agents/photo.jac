"""Photo proof check: a vision model looks at a site photo and decides whether it shows the
claimed element and how complete that element looks. A confident match counts as proof:
it raises the element's verified progress (never above what the contractor reported) and
Payment Guard releases any held money the proof now covers."""
import os;
import from byllm.lib { Model, MockLLM, Image }

obj PhotoCheck {
    has shows_element: bool;
    has estimated_percent: float;
    has confidence: float;
    has observations: str;
}
sem PhotoCheck.shows_element = "True only if the photo clearly shows the named construction element (e.g. a concrete slab, brick walls, a roof).";
sem PhotoCheck.estimated_percent = "How complete the element looks in the photo, 0 to 100.";
sem PhotoCheck.confidence = "How sure you are about shows_element and estimated_percent, from 0.0 to 1.0.";
sem PhotoCheck.observations = "One or two plain sentences on what the photo shows, for the homeowner.";

def mock_check() -> PhotoCheck {
    return PhotoCheck(shows_element=True, estimated_percent=100.0, confidence=0.9, observations="Mock check: the photo shows a finished concrete slab.");
}

# Vision model:
#   GEDARA_LLM=mock            -> MockLLM (tests, CI)
#   GEDARA_VISION_MODEL set    -> that model (any LiteLLM vision model name)
#   GROQ_API_KEY set           -> groq/qwen/qwen3.8-27b (a Groq model that accepts images)
#   nothing set                -> no vision model; photos are stored for the architect to review
glob GROQ_VISION_DEFAULT: str = "groq/qwen/qwen3.8-27b";

def build_vision_llm() -> any {
    if os.environ.get("GEDARA_LLM", "") == "mock" {
        return MockLLM(model_name="mockllm", config={"outputs": [mock_check() for _ in range(20)]});
    }
    model_name = os.environ.get("GEDARA_VISION_MODEL", "");
    if model_name == "" and os.environ.get("GROQ_API_KEY", "") != "" { model_name = GROQ_VISION_DEFAULT; }
    if model_name == "" { return None; }
    return Model(model_name=model_name);
}
glob llm = build_vision_llm();

def vision_available() -> bool {
    return llm is not None;
}

def check_photo(photo: Image, element_name: str, element_kind: str, claimed_percent: float) -> PhotoCheck by llm(temperature=0.0);
sem check_photo = "You check site photos for a house under construction in Sri Lanka. Decide whether the photo shows the named element and how complete it looks. Be strict: a photo of something else, or too unclear to judge, is not proof.";
sem check_photo.photo = "The photo the contractor sent as proof.";
sem check_photo.element_name = "The element the contractor says the photo shows, e.g. Slab or Walls.";
sem check_photo.element_kind = "The element's category, e.g. structure, services or finishes.";
sem check_photo.claimed_percent = "The progress the contractor reported for this element, 0 to 100.";

"""How much of the photo's estimate counts as verified: a confident match, capped at what was reported."""
def proven_percent(check: PhotoCheck, reported_percent: float, min_confidence: float) -> float {
    if not check.shows_element or check.confidence < min_confidence { return 0.0; }
    return min(check.estimated_percent, reported_percent);
}

test "proof counts only for a confident match, capped at the reported progress" {
    good = PhotoCheck(shows_element=True, estimated_percent=90.0, confidence=0.8, observations="");
    assert proven_percent(good, 60.0, 0.6) == 60.0;
    assert proven_percent(good, 100.0, 0.6) == 90.0;
    unsure = PhotoCheck(shows_element=True, estimated_percent=90.0, confidence=0.4, observations="");
    assert proven_percent(unsure, 100.0, 0.6) == 0.0;
    wrong = PhotoCheck(shows_element=False, estimated_percent=90.0, confidence=0.9, observations="");
    assert proven_percent(wrong, 100.0, 0.6) == 0.0;
}
