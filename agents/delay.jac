"""Delay Detector: finds elements behind schedule, walks depends_on to the real cause, and writes a
dated DelayNotice with evidence. This is the builder-protection side: a neutral, timestamped record."""
import from datetime { date }
import from twin { House, Element, DelayNotice, Activity, Has, depends_on }

# An element must be at least this many days behind plan to count as a delay.
glob DELAY_THRESHOLD_DAYS: int = 3;

"""Days the element is behind plan on `today` (ISO dates). Expected progress is linear between start and end."""
def days_behind(planned_start: str, planned_end: str, percent_complete: float, today: str) -> int {
    if planned_start == "" or planned_end == "" {
        return 0;
    }
    start = date.fromisoformat(planned_start);
    end = date.fromisoformat(planned_end);
    now = date.fromisoformat(today);
    total = (end - start).days;
    if total <= 0 {
        return 0;
    }
    elapsed = (now - start).days;
    if elapsed < 0 {
        return 0;
    }
    if elapsed > total {
        elapsed = total;
    }
    # Example: 40-day job, 20 days in, 25% done -> expected 50%, behind 25% of 40 days = 10 days.
    expected = elapsed * 100.0 / total;
    behind_pct = expected - percent_complete;
    if behind_pct <= 0.0 {
        return 0;
    }
    return int(behind_pct * total / 100.0);
}

def element_days_behind(el: Element, today: str) -> int {
    return days_behind(el.planned_start, el.planned_end, el.percent_complete, today);
}

"""Walk depends_on from a late element to its root cause. Chain runs from the affected element to the cause."""
def cause_chain(el: Element, today: str) -> list[str] {
    chain: list[str] = [el.name];
    current = el;
    for _ in range(20) {
        late_preds = [p for p in [current ->:depends_on:->[?:Element]] if element_days_behind(p, today) >= DELAY_THRESHOLD_DAYS];
        if len(late_preds) == 0 {
            break;
        }
        current = late_preds[0];
        chain.append(current.name);
    }
    return chain;
}

walker:pub DelayDetector {
    has today: str;

    can start with Root entry {
        visit [-->[?:House]];
    }

    can detect with House entry {
        written: list[dict] = [];
        existing = [(n.element_name, n.date) for n in [here ->:Has:->[?:DelayNotice]]];
        for el in [here ->:Has:->[?:Element]] {
            behind = element_days_behind(el, self.today);
            if behind < DELAY_THRESHOLD_DAYS or (el.name, self.today) in existing {
                continue;
            }
            chain = cause_chain(el, self.today);
            root_cause = chain[len(chain) - 1];
            evidence = f"{el.name} is {behind} days behind plan ({el.percent_complete}% done, due {el.planned_end}). Root cause traced through dependencies: {' <- '.join(chain)}.";
            notice = DelayNotice(date=self.today, element_name=el.name, cause_chain=chain, days_behind=behind, evidence=evidence);
            here +>:Has():+> notice;
            here +>:Has():+> Activity(actor="delay_detector", kind="delay_notice", text=evidence);
            written.append({"element": el.name, "days_behind": behind, "root_cause": root_cause, "evidence": evidence});
        }
        report written;
    }
}
