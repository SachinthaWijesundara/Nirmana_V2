"""Handler bodies for the Dashboard shell. Every write is followed by a refresh so the UI shows
what the graph now holds, not what the client guessed."""

impl Dashboard.refresh -> None {
    try {
        result = root spawn dashboard_view(today=DEMO_TODAY);
        if result.reports and len(result.reports) > 0 {
            view = result.reports[0];
        }
        error = "";
    } except Exception as e {
        error = "Could not reach the Nirmana server. Is `jac start main.jac` running?";
    }
}

impl Dashboard.sendMessage -> None {
    if not message.strip() {
        return;
    }
    busy = "intake";
    result = root spawn Intake(message=message);
    intakeResult = result.reports[0] as dict[str, any] if result.reports and len(result.reports) > 0 else {"ok": False, "reason": "no reply"};
    await refresh();
    busy = "";
}

impl Dashboard.requestPayment -> None {
    value = float(amount) if amount else 0.0;
    if value <= 0 {
        payResult = {"verdict": "error", "message": "Enter an amount in rupees."};
        return;
    }
    busy = "payment";
    result = root spawn PaymentGuard(request_amount=value, note=payNote);
    if result.reports and len(result.reports) > 0 {
        payResult = result.reports[0] as dict[str, any];
    }
    proofResult = {};
    await refresh();
    busy = "";
}

impl Dashboard.verify(name: str, percent: float) -> None {
    busy = "verify:" + name;
    result = root spawn ReleaseOnProof(element_name=name, verified_percent=percent);
    if result.reports and len(result.reports) > 0 {
        proofResult = result.reports[0] as dict[str, any];
    }
    await refresh();
    busy = "";
}

impl Dashboard.runScenario -> None {
    busy = "scenario";
    cement = float(cementPct) if cementPct else 0.0;
    days = int(delayDays) if delayDays else 0;
    result = root spawn scenario(cement_pct=cement, delay_days=days, delay_element=delayElement, today=DEMO_TODAY);
    if result.reports and len(result.reports) > 0 {
        whatIf = result.reports[0] as dict[str, any];
    }
    await refresh();
    busy = "";
}

impl Dashboard.runDelayCheck -> None {
    busy = "delay";
    result = root spawn DelayDetector(today=DEMO_TODAY);
    delays = result.reports[0] as list[any] if result.reports and len(result.reports) > 0 else [];
    delayChecked = True;
    await refresh();
    busy = "";
}
