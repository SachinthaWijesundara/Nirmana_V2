"""Display helpers shared by the dashboard components."""

glob MONTHS: list[str] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

"""Rupees in the same short form the agents use: Rs. 4.20M, Rs. 800k."""
def:pub rs(amount: float) -> str {
    sign = "-" if amount < 0 else "";
    a: float = abs(amount);
    if a >= 1000000.0 {
        millions: float = a / 1000000.0;
        return f"{sign}Rs. {millions:.2f}M";
    }
    if a >= 1000.0 {
        thousands: float = a / 1000.0;
        return f"{sign}Rs. {thousands:.0f}k";
    }
    return f"{sign}Rs. {a:.0f}";
}

"""ISO date (2026-09-18) to a readable one (18 Sep 2026)."""
def:pub nice_date(iso: str) -> str {
    if not iso {
        return "-";
    }
    parts = iso.split("-");
    if len(parts) != 3 {
        return iso;
    }
    return f"{int(parts[2])} {MONTHS[int(parts[1]) - 1]} {parts[0]}";
}

def:pub pct(value: float) -> str {
    return f"{value:.0f}%";
}

"""Typed reads from an agent's report dict (agent walkers report plain dicts)."""
def:pub field_str(d: dict[str, any], key: str) -> str {
    return str(d[key]) if d[key] else "";
}

def:pub field_num(d: dict[str, any], key: str) -> float {
    return d[key] as float if d[key] else 0.0;
}

"""Comma-separated names (str.join does not survive the JS compile)."""
def:pub join_names(names: list[str]) -> str {
    out = "";
    for (i, n) in enumerate(names) {
        out = out + (", " if i > 0 else "") + n;
    }
    return out;
}
