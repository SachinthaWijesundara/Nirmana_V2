"""Payment Guard: compares money paid with verified built value and acts. It holds suspicious
payment requests, and releases them (fully or in part) once proof raises the verified value.
All money rules are plain deterministic Jac. No LLM decides money.

The advance allowed on top of verified work is a per-project setting (House.advance_limit_pct),
entered when the project is created, not a constant in code."""
import from twin { House, Element, Payment, PaymentStatus, Activity, Has, now_iso, today_iso }

obj Decision {
    has verdict: str,
        release_now: float,
        hold: float,
        reason: str;
}

"""Verified built value of one element: planned cost times verified percent."""
def verified_value(planned_cost: float, verified_pct: float) -> float {
    return planned_cost * verified_pct / 100.0;
}

"""Decide a payment request. paid = already paid, verified = verified built value,
request = amount asked now, tolerance = advance allowed on top of verified work (0.10 = 10%)."""
def assess(paid: float, verified: float, request: float, tolerance: float) -> Decision {
    allowed_total = verified * (1.0 + tolerance);
    headroom = allowed_total - paid;
    if headroom < 0.0 {
        headroom = 0.0;
    }
    if request <= headroom {
        return Decision(verdict="approve", release_now=request, hold=0.0, reason="Within verified built value.");
    }
    if headroom > 0.0 {
        return Decision(verdict="partial", release_now=headroom, hold=request - headroom, reason="Part is covered by verified work; the rest is held.");
    }
    return Decision(verdict="hold", release_now=0.0, hold=request, reason="Money already paid is ahead of verified work.");
}

"""Totals for a house: money paid (PAID or RELEASED) and verified built value.
Uses verified_pct only, never the builder-reported percent_complete."""
def totals(house: House) -> dict[str, float] {
    paid = 0.0;
    for p in [house ->:Has:->[?:Payment]] {
        if p.status != PaymentStatus.HELD {
            paid += p.amount;
        }
    }
    verified = 0.0;
    for e in [house ->:Has:->[?:Element]] {
        verified += verified_value(e.planned_cost, e.verified_pct);
    }
    return {"paid": paid, "verified": verified};
}

def rs(amount: float) -> str {
    if amount >= 1000000.0 {
        whole = int(amount / 10000.0);
        return f"Rs. {whole // 100}.{whole % 100:02d}M";
    }
    return f"Rs. {int(amount / 1000.0)}k";
}

def add_payment(house: House, amount: float, status: PaymentStatus, note: str, recorded_by: str) -> Payment {
    p = Payment(amount=amount, status=status, note=note, date=today_iso(), recorded_by=recorded_by);
    house +>:Has():+> p;
    grant(p, level=WritePerm);
    return p;
}

def add_activity(house: House, actor: str, kind: str, text: str) -> None {
    a = Activity(actor=actor, kind=kind, text=text, role="system", category="money", at=now_iso());
    house +>:Has():+> a;
    grant(a, level=WritePerm);
}

"""Spawn on a House. The project's advance limit decides how much may be paid ahead of verified work."""
walker PaymentGuard {
    has request_amount: float;
    has note: str = "";
    has requested_by: str = "";

    can start with Root entry {
        visit [-->[?:House]];
    }

    can guard with House entry {
        t = totals(here);
        d = assess(t["paid"], t["verified"], self.request_amount, here.advance_limit_pct / 100.0);
        if d.release_now > 0.0 {
            add_payment(here, d.release_now, PaymentStatus.PAID, self.note, self.requested_by);
        }
        if d.hold > 0.0 {
            add_payment(here, d.hold, PaymentStatus.HELD, self.note, self.requested_by);
        }
        msg = f"Paid {rs(t['paid'])}, verified built {rs(t['verified'])}. Request {d.verdict}: released {rs(d.release_now)}, held {rs(d.hold)}.";
        add_activity(here, "payment_guard", "payment_" + d.verdict, msg);
        report {"verdict": d.verdict, "release_now": d.release_now, "hold": d.hold, "paid": t["paid"], "verified": t["verified"], "message": msg};
    }
}

"""Proof arrived: raise the element's verified progress, then release held payments the proof now covers."""
walker ReleaseOnProof {
    has element_name: str;
    has verified_percent: float;

    can start with Root entry {
        visit [-->[?:House]];
    }

    can release with House entry {
        matched = [e for e in [here ->:Has:->[?:Element]] if e.name.lower() == self.element_name.lower()];
        if len(matched) == 0 or self.verified_percent < 0.0 or self.verified_percent > 100.0 {
            report {"ok": False, "reason": "unknown element or bad percent"};
            return;
        }
        el = matched[0];
        if self.verified_percent > el.verified_pct {
            el.verified_pct = self.verified_percent;
        }
        # Proven work is at least reported work.
        if el.verified_pct > el.percent_complete {
            el.percent_complete = el.verified_pct;
        }
        tolerance = here.advance_limit_pct / 100.0;
        released = 0.0;
        for p in [here ->:Has:->[?:Payment]] {
            if p.status != PaymentStatus.HELD {
                continue;
            }
            t = totals(here);
            d = assess(t["paid"], t["verified"], p.amount, tolerance);
            if d.release_now <= 0.0 {
                continue;
            }
            if d.release_now >= p.amount {
                p.status = PaymentStatus.RELEASED;
            } else {
                p.amount = p.amount - d.release_now;
                add_payment(here, d.release_now, PaymentStatus.RELEASED, p.note, "payment_guard");
            }
            released += d.release_now;
        }
        t2 = totals(here);
        msg = f"Proof for {el.name} ({self.verified_percent}%). Released {rs(released)}; verified built now {rs(t2['verified'])}.";
        add_activity(here, "payment_guard", "release_on_proof", msg);
        report {"ok": True, "released": released, "verified": t2["verified"], "message": msg};
    }
}
