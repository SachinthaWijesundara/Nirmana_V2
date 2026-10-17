"""Formatting helpers. Every money value on screen goes through rs()."""

"""Group digits in threes: 4200000 -> 4,200,000."""
def:pub group_digits(n: int) -> str {
    digits = str(n);
    out = "";
    while len(digits) > 3 {
        out = "," + digits[len(digits) - 3:] + out;
        digits = digits[:len(digits) - 3];
    }
    return digits + out;
}

"""Sri Lankan rupees. Full: Rs. 4,200,000. Compact: Rs. 4.2M / Rs. 40k."""
def:pub rs(amount: float, compact: bool = False) -> str {
    sign = "-" if amount < 0.0 else "";
    value: float = -amount if amount < 0.0 else amount;
    if compact and value >= 1000000.0 {
        return f"{sign}Rs. {value / 1000000.0:.1f}M";
    }
    if compact and value >= 1000.0 {
        return f"{sign}Rs. {round(value / 1000.0)}k";
    }
    return f"{sign}Rs. {group_digits(round(value))}";
}

"""First letter upper case: singlish -> Singlish. (Client str.capitalize/str.join are not reliable.)"""
def:pub cap(text: str) -> str {
    return text[:1].upper() + text[1:] if text != "" else "";
}

"""Join parts with a separator, e.g. House › Ground floor › Slab."""
def:pub join_parts(parts: list[str], sep: str) -> str {
    out = "";
    for (i, p) in enumerate(parts) {
        out = out + (sep if i > 0 else "") + p;
    }
    return out;
}

"""Whole-number percent, rounded down so it never overstates progress: 52.5 -> 52%."""
def:pub pct(part: float, whole: float) -> str {
    if whole <= 0.0 {
        return "0%";
    }
    return f"{int(part * 100.0 / whole)}%";
}
