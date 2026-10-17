"""Payment Guard: compares money paid with verified built value and acts. It holds suspicious
payment requests, and releases them (fully or in part) once proof raises the verified value.
All money rules are plain deterministic Jac. No LLM decides money."""
import from mock.twin { House, Element, Payment, PaymentStatus, Activity, Has }

# Advance allowed on top of verified built value (10%) before a request is held.
glob ADVANCE_TOLERANCE: float = 0.10;

obj Decision {
    has verdict: str,
        release_now: float,
        hold: float,
        reason: str;
}

"""Verified built value of one element: planned cost times percent complete."""
def verified_value(planned_cost: float, percent_complete: float) -> float {
    return planned_cost * percent_complete / 100.0;
}

"""Decide a payment request. paid = already paid, verified = verified built value, request = amount asked now."""
def assess(paid: float, verified: float, request: float) -> Decision {
    # Example: paid 4.2M, verified 2.6M -> allowed total 2.86M, headroom = max(0, 2.86M - 4.2M) = 0, so 800k is held.
    allowed_total = verified * (1.0 + ADVANCE_TOLERANCE);
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

"""Totals for a house: money paid (PAID or RELEASED) and verified built value."""
def totals(house: House) -> dict[str, float] {
    paid = 0.0;
    for p in [house ->:Has:->[?:Payment]] {
        if p.status != PaymentStatus.HELD {
            paid += p.amount;
        }
    }
    verified = 0.0;
    for e in [house ->:Has:->[?:Element]] {
        verified += verified_value(e.planned_cost, e.percent_complete);
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

walker PaymentGuard {
    has request_amount: float;
    has note: str = "";

    can start with Root entry {
        visit [-->[?:House]];
    }

    can guard with House entry {
        t = totals(here);
        d = assess(t["paid"], t["verified"], self.request_amount);
        if d.release_now > 0.0 {
            here +>:Has():+> Payment(amount=d.release_now, status=PaymentStatus.PAID, note=self.note);
        }
        if d.hold > 0.0 {
            here +>:Has():+> Payment(amount=d.hold, status=PaymentStatus.HELD, note=self.note);
        }
        msg = f"Paid {rs(t['paid'])}, verified built {rs(t['verified'])}. Request {d.verdict}: released {rs(d.release_now)}, held {rs(d.hold)}.";
        here +>:Has():+> Activity(actor="payment_guard", kind="payment_" + d.verdict, text=msg);
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
        if self.verified_percent > el.percent_complete {
            el.percent_complete = self.verified_percent;
        }
        released = 0.0;
        for p in [here ->:Has:->[?:Payment]] {
            if p.status != PaymentStatus.HELD {
                continue;
            }
            t = totals(here);
            d = assess(t["paid"], t["verified"], p.amount);
            if d.release_now <= 0.0 {
                continue;
            }
            if d.release_now >= p.amount {
                p.status = PaymentStatus.RELEASED;
            } else {
                p.amount = p.amount - d.release_now;
                here +>:Has():+> Payment(amount=d.release_now, status=PaymentStatus.RELEASED, note=p.note);
            }
            released += d.release_now;
        }
        t2 = totals(here);
        msg = f"Proof for {el.name} ({self.verified_percent}%). Released {rs(released)}; verified built now {rs(t2['verified'])}.";
        here +>:Has():+> Activity(actor="payment_guard", kind="release_on_proof", text=msg);
        report {"ok": True, "released": released, "verified": t2["verified"], "message": msg};
    }
}
