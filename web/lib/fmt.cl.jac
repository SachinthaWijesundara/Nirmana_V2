"""Small display helpers shared by the screens."""

def:pub rs(n: any) -> str {
    text: any = n.toLocaleString("en-US");
    return "Rs. " + str(text);
}

def:pub pct_of(n: float, total: float) -> int {
    if total <= 0 { return 0; }
    return int(round(n * 100 / total));
}

def:pub clone(x: any) -> any {
    return JSON.parse(JSON.stringify(x));
}
