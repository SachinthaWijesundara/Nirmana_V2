"""Client Q&A: answers plain-language questions about one project by walking its graph.

project_facts() walks the House and collects the numbers (money, elements, spending by
material, payments, delays, forecast). The LLM only phrases an answer from those facts, in
English, Sinhala or Tamil; it never invents numbers. Without an LLM, answer_rules() covers
the common questions."""
import os;
import json;
import from jaclang.byllm.lib { MockLLM }
import from agents.intake { build_llm }
import from agents.forecast { WhatIf, compute_forecast }
import from twin {
    House, Element, Payment, PaymentStatus, Update, DelayNotice, Has,
    elements, money_summary, element_status, today_iso
}

obj Answer {
    has answer: str;
    has facts_used: list[str];
}
sem Answer.answer = "The answer to the homeowner's question, in plain words, using only the given facts. Say so if the facts do not cover it.";
sem Answer.facts_used = "Short names of the facts the answer relies on, e.g. 'spend_by_material.cement'.";

# Same model as Intake (Groq when GROQ_API_KEY is set); its own mock for tests.
def build_qa_llm() -> any {
    if os.environ.get("GEDARA_LLM", "") == "mock" {
        return MockLLM(model_name="mockllm", config={"outputs": [Answer(answer="Mock answer.", facts_used=["money"]) for _ in range(20)]});
    }
    return build_llm();
}
glob llm = build_qa_llm();

def qa_llm_available() -> bool {
    return llm is not None;
}

def answer_question(question: str, facts: str, language: str) -> Answer by llm(temperature=0.2);
sem answer_question = "Answer a homeowner's question about their house build using ONLY the JSON facts. Money is in Sri Lankan rupees (Rs.). Keep it to two or three sentences. Write the answer in the requested language.";
sem answer_question.question = "The homeowner's question.";
sem answer_question.facts = "JSON facts walked from the project's graph: money, elements, spending by material, payments, delays and the forecast.";
sem answer_question.language = "Language for the answer: english, sinhala or tamil.";

"""Walk the project graph and collect everything the Q&A may need."""
def project_facts(house: House) -> dict[str, any] {
    today = today_iso();
    els: list[dict[str, any]] = [];
    for el in elements(house) {
        els.append({"name": el.name, "status": element_status(el, today), "reported_percent": el.percent_complete, "verified_percent": el.verified_pct, "planned_cost": el.planned_cost, "actual_cost": el.actual_cost, "planned_end": el.planned_end});
    }
    spend: dict[str, float] = {};
    for u in [house ->:Has:->][?:Update] {
        if u.material != "" and u.cost > 0.0 { spend[u.material] = spend.get(u.material, 0.0) + u.cost; }
    }
    pays = [{"amount": p.amount, "status": p.status.value, "date": p.date, "note": p.note} for p in [house ->:Has:->][?:Payment]];
    delays = [{"element": d.element_name, "days_behind": d.days_behind, "evidence": d.evidence} for d in [house ->:Has:->][?:DelayNotice]];
    facts: dict[str, any] = {"project": house.name, "today": today, "money": money_summary(house), "elements": els, "spend_by_material": spend, "payments": pays, "delay_notices": delays};
    if len(els) > 0 and house.start_date != "" {
        facts["forecast"] = compute_forecast(house, today, WhatIf());
    }
    return facts;
}

def rs(amount: float) -> str {
    return f"Rs. {amount:,.0f}";
}

"""Rule-based answers for the common questions, used when no LLM is configured."""
def answer_rules(question: str, facts: dict[str, any]) -> Answer {
    q = question.lower();
    money = facts["money"] as dict[str, float];
    spend = facts["spend_by_material"] as dict[str, float];
    for (material, amount) in spend.items() {
        if material in q {
            return Answer(answer=f"{rs(amount)} has been spent on {material} so far, from the builder's updates.", facts_used=[f"spend_by_material.{material}"]);
        }
    }
    if "finish" in q or "done" in q or "complete" in q or "when" in q {
        if "forecast" in facts {
            f = facts["forecast"] as dict[str, any];
            return Answer(answer=f"At the current pace the house finishes on {f['finish_date']}, {f['slip_days']} days after the plan ({f['planned_finish_date']}). The critical path is {' -> '.join(f['critical_path'] as list[str])}.", facts_used=["forecast"]);
        }
    }
    if "held" in q or "hold" in q or "why" in q {
        return Answer(answer=f"Paid so far is {rs(money['paid'])} but verified built work is {rs(money['verified'])}, so {rs(money['held'])} is held until proof of more work arrives.", facts_used=["money"]);
    }
    if "paid" in q or "money" in q or "spent" in q or "cost" in q or "budget" in q {
        return Answer(answer=f"Paid {rs(money['paid'])} of a {rs(money['budget'])} budget. Verified built work is {rs(money['verified'])} and {rs(money['held'])} is held.", facts_used=["money"]);
    }
    if "late" in q or "delay" in q or "behind" in q {
        notices = facts["delay_notices"] as list[dict[str, any]];
        if len(notices) == 0 { return Answer(answer="No delay notices have been written for this project.", facts_used=["delay_notices"]); }
        worst = notices[0];
        for n in notices { if (n["days_behind"] as int) > (worst["days_behind"] as int) { worst = n; } }
        return Answer(answer=f"{len(notices)} elements are behind. The worst is {worst['element']}, {worst['days_behind']} days behind.", facts_used=["delay_notices"]);
    }
    return Answer(answer="I can answer questions about money paid and held, spending on a material, delays and the finish date.", facts_used=[]);
}

"""Answer a question about a project: LLM when configured, rules otherwise."""
def ask(house: House, question: str, language: str) -> dict[str, any] {
    facts = project_facts(house);
    a = answer_rules(question, facts);
    used_llm = False;
    if qa_llm_available() {
        a = answer_question(question, json.dumps(facts), language);
        used_llm = True;
    }
    return {"question": question, "answer": a.answer, "facts_used": a.facts_used, "language": language, "used_llm": used_llm};
}
