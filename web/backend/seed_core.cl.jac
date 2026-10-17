"""Seed data for the mock backend: session, dashboard, projects, approvals, messages and tools.
The shapes here ARE the backend contract (see backend/README.md); a real backend returns the same."""

glob:pub USERS: dict[str, any] = {
    "client": {"name": "Nimali Perera", "initials": "NP", "role": "Client", "email": "nimali.perera@gmail.com", "tone": "celeste"},
    "contractor": {"name": "Ruwan Silva", "initials": "RS", "role": "Contractor", "email": "ruwan@rsilvabuilders.lk", "tone": "marigold"},
    "architect": {"name": "Anushka Fernando", "initials": "AF", "role": "Architect", "email": "anushka@afdesign.lk", "tone": "herb"}
};

glob:pub ROLE_BLURBS: list[any] = [
    {"role": "client", "title": "Client", "text": "Owns and funds the build. Approves changes, plans and payments.", "icon": "home", "tone": "celeste"},
    {"role": "contractor", "title": "Contractor", "text": "Builds it. Posts daily logs, ledger entries and change orders.", "icon": "layers", "tone": "marigold"},
    {"role": "architect", "title": "Architect", "text": "Designs and certifies. Signs off phases, invoices and logs.", "icon": "check", "tone": "herb"}
];

glob:pub HOUSE_LAYERS: list[any] = [
    [{"name": "Painting", "pct": 0, "status": "idle"}, {"name": "Tiling", "pct": 0, "status": "idle"}, {"name": "Plastering", "pct": 0, "status": "idle"}],
    [{"name": "Roof", "pct": 0, "status": "idle"}],
    [{"name": "Plumbing", "pct": 0, "status": "idle"}, {"name": "Electrical", "pct": 0, "status": "idle"}],
    [{"name": "Walls", "pct": 4, "status": "active"}],
    [{"name": "Slab", "pct": 60, "status": "delayed"}],
    [{"name": "Columns", "pct": 100, "status": "done"}],
    [{"name": "Foundation", "pct": 100, "status": "done"}]
];

glob:pub DASHBOARD: dict[str, any] = {
    "subtitle": "Perera House, Kandy · 32% built · forecast March 2027",
    "stats": [
        {"tone": "celeste", "icon": "wallet", "label": "Paid to date", "value": "Rs. 4.2M", "sub": "of Rs. 8.0M contract", "delta": "52%"},
        {"tone": "marigold", "icon": "shield", "label": "Verified as built", "value": "Rs. 2.59M", "sub": "Rs. 1.61M paid ahead of work", "delta": "32%"},
        {"tone": "herb", "icon": "sparkles", "label": "Transparency", "value": "78/100", "sub": "Receipts, rates, logs", "delta": "+4"},
        {"tone": "midnight", "icon": "calendar", "label": "Forecast finish", "value": "Mar 2027", "sub": "Rs. 600,000 over", "delta": "+3 wks"}
    ],
    "layers": HOUSE_LAYERS,
    "paid_ahead": "Rs. 1.61M",
    "months": [
        {"m": "Jun", "paid": 180, "verified": 170}, {"m": "Jul", "paid": 140, "verified": 124},
        {"m": "Aug", "paid": 120, "verified": 100}, {"m": "Sep", "paid": 160, "verified": 80},
        {"m": "Oct", "paid": 200, "verified": 70}, {"m": "Nov", "paid": 40, "verified": 0}
    ],
    "alerts": [
        {"level": "danger", "title": "Payment held", "body": "Rs. 800,000 request held until the architect sees photo proof of the slab."},
        {"level": "warn", "title": "Rain delay · 3 days", "body": "Slab work stopped. Roof start moved to 12 Nov."},
        {"level": "info", "title": "AI forecast", "body": "At this pace: done March 2027, Rs. 600,000 over budget."}
    ],
    "messages": [
        {"name": "Ruwan Silva", "initials": "RS", "tone": "marigold", "when": "12 min", "text": "Slab shuttering removed, photos tonight."},
        {"name": "Anushka Fernando", "initials": "AF", "tone": "herb", "when": "2 h", "text": "Will inspect the slab on Thursday."},
        {"name": "Ruwan Silva", "initials": "RS", "tone": "marigold", "when": "Yesterday", "text": "Cement price went up, sent receipt."}
    ]
};

glob:pub PROJECTS: list[any] = [
    {"id": "perera-house", "name": "Perera House", "place": "Kandy · Two-storey house", "short": "Kandy · Two-storey · 2,150 sq ft", "status": "3 weeks behind", "status_tone": "danger",
     "cover": "celeste", "pct": 32, "stage": "Slab & first floor", "paid": "Rs. 4,200,000", "contract": "Rs. 8,000,000", "team": ["NP", "RS", "AF"],
     "score": 78, "score_label": "Good", "next": "Slab inspection · Thu 22 Oct", "group": "active"},
    {"id": "silva-residence", "name": "Silva Residence", "place": "Galle · Single-storey + annex", "short": "Galle · Single-storey + annex", "status": "On track", "status_tone": "herb",
     "cover": "herb", "pct": 68, "stage": "Roofing", "paid": "Rs. 6,900,000", "contract": "Rs. 10,400,000", "team": ["KS", "RS", "AF"],
     "score": 91, "score_label": "Good", "next": "Roof sheets arrive · Mon 26 Oct", "group": "active"},
    {"id": "jayasuriya-annex", "name": "Jayasuriya Annex", "place": "Colombo 5 · Extension", "short": "Colombo 5 · Extension", "status": "Needs attention", "status_tone": "danger",
     "cover": "marigold", "pct": 12, "stage": "Foundation", "paid": "Rs. 1,500,000", "contract": "Rs. 4,600,000", "team": ["DJ", "MW", "AF"],
     "score": 54, "score_label": "Low", "next": "3 receipts missing from ledger", "group": "active"},
    {"id": "bandara-villa", "name": "Bandara Villa", "place": "Kurunegala · Two-storey villa", "short": "Kurunegala · Two-storey villa", "status": "Complete", "status_tone": "herb",
     "cover": "midnight", "pct": 100, "stage": "Handover & defects", "paid": "Rs. 12,100,000", "contract": "Rs. 12,400,000", "team": ["TB", "RS", "AF"],
     "score": 88, "score_label": "Good", "next": "Retention release · Jan 2027", "group": "handover"}
];

glob:pub APPROVALS: dict[str, any] = {
    "subtitle": "4 items waiting on you as Client, across 2 projects",
    "items": [
        {"id": "co-004", "kind": "change", "icon": "layers", "chip": "celeste", "title": "Upgrade roof to Calicut tiles", "meta": "CO-004 · Perera House · Ruwan Silva · 2 days ago",
         "amount": "+ Rs. 180,000", "pill": "Change order", "pill_tone": "info", "open": True},
        {"id": "plan-a102", "kind": "plan", "icon": "file", "chip": "midnight", "title": "Ground floor plan A-102, rev C", "meta": "Plans · Perera House · Anushka Fernando · 4 days ago",
         "amount": "3 comments", "pill": "Plan sheet", "pill_tone": "neutral", "open": True},
        {"id": "m3", "kind": "payment", "icon": "wallet", "chip": "danger", "title": "Milestone 3 · Slab complete", "meta": "Payments · Perera House · held by architect · 1 week ago",
         "amount": "Rs. 800,000", "pill": "Held · needs photos", "pill_tone": "delayed", "open": True},
        {"id": "ledger-cement", "kind": "ledger", "icon": "receipt", "chip": "marigold", "title": "Cement rate query answered", "meta": "Ledger · Jayasuriya Annex · contractor replied · 3 h ago",
         "amount": "Rs. 312,000", "pill": "Response in", "pill_tone": "progress", "open": True}
    ],
    "done": [
        {"title": "Kitchen layout · A-104 rev B", "meta": "Approved by you · 9 Oct"},
        {"title": "Extra column footing · CO-003", "meta": "Approved by you · 2 Oct · + Rs. 64,000"}
    ],
    "details": {
        "co-004": {"tag": "Change order · CO-004", "status": "Pending client", "title": "Upgrade roof to Calicut tiles",
                   "body": "Client asked for clay Calicut tiles instead of the specified roof sheets on the main roof. Quote attached.",
                   "by": "Ruwan Silva", "initials": "RS", "role": "Contractor · raised 15 Oct 2026",
                   "facts": [["Cost impact", "+ Rs. 180,000", True], ["Time impact", "+ 4 days", False], ["Revised if approved", "Rs. 8,244,000", False], ["Pending changes", "Rs. 180,000", False]],
                   "ai_title": "Rate check · looks fair", "ai_body": "Rs. 85 per tile is 6% below the Kandy market average this month.",
                   "file": "calicut-tile-quote.pdf", "file_meta": "220 KB · uploaded 15 Oct", "approve": "Approve change", "confirm": "Adds Rs. 180,000 to the contract. Change-order decisions are final and logged under your name.", "done_msg": "Change order approved"},
        "plan-a102": {"tag": "Plan sheet · A-102", "status": "Awaiting you", "title": "Ground floor plan A-102, rev C",
                      "body": "Rev C replaces rev B. The kitchen window moved 600 mm left. Three comments are open on the sheet.",
                      "by": "Anushka Fernando", "initials": "AF", "role": "Architect · uploaded 13 Oct 2026",
                      "facts": [["Sheet", "A-102 · rev C", False], ["Open comments", "3", False], ["Replaces", "rev B · 13 Oct", False], ["Cost impact", "Rs. 95,000 (verandah)", False]],
                      "ai_title": "Plan check · one cost flag", "ai_body": "The verandah extension adds about Rs. 95,000 to the slab and is not in the contract yet.",
                      "file": "A-102-rev-C.pdf", "file_meta": "1.4 MB · uploaded 13 Oct", "approve": "Approve rev C", "confirm": "Approving sets rev C as the build plan and is logged under your name.", "done_msg": "Plan rev C approved"},
        "m3": {"tag": "Payment · M3", "status": "Held by architect", "title": "Milestone 3 · Slab complete",
               "body": "The architect asked for photos of the slab underside before certifying. Invoice sent 9 Oct.",
               "by": "Ruwan Silva", "initials": "RS", "role": "Contractor · invoiced 9 Oct 2026",
               "facts": [["Invoice", "Rs. 800,000", False], ["Retention 5%", "Rs. 40,000", False], ["Client pays", "Rs. 760,000", False], ["Paid ahead of work", "Rs. 1,608,000", True]],
               "ai_title": "Payment guard · hold", "ai_body": "Paid is already ahead of verified work. Pay unlocks after the architect certifies.",
               "file": "invoice-m3.pdf", "file_meta": "96 KB · uploaded 9 Oct", "approve": "Pay Rs. 760,000", "confirm": "Payment unlocks only after the architect certifies. This is logged under your name.", "done_msg": "Payment released", "locked": "Held until the architect certifies"},
        "ledger-cement": {"tag": "Ledger query", "status": "Response in", "title": "Cement rate query answered",
                          "body": "The contractor replied with the supplier quote for the cement purchase you queried.",
                          "by": "Ruwan Silva", "initials": "RS", "role": "Contractor · replied 3 h ago",
                          "facts": [["Entry", "Rs. 312,000", False], ["Paid rate", "Rs. 2,720 / bag", True], ["Fair price", "Rs. 2,548 / bag", False], ["Variance", "+ 6.8%", True]],
                          "ai_title": "Rate check · slightly high", "ai_body": "Two other Kandy suppliers listed Rs. 2,480–2,560 this week.",
                          "file": "supplier-quote.pdf", "file_meta": "180 KB · uploaded today", "approve": "Accept reply", "confirm": "Accepting closes the query and is logged under your name.", "done_msg": "Query closed"}
    }
};

glob:pub THREADS: list[any] = [
    {"id": "ph", "initials": "PH", "tone": "celeste", "name": "Perera House · everyone", "last": "Ruwan: Slab shuttering remove…", "when": "12 min", "unread": 2, "members": "Nimali (client) · Ruwan (contractor) · Anushka (architect)"},
    {"id": "ai", "initials": "AI", "tone": "herb", "icon": "sparkles", "name": "Nirmana assistant", "last": "Ask about cost, schedule or receipts", "when": "", "unread": 0, "members": "AI assistant · reads project data, never pays or approves"},
    {"id": "rs", "initials": "RS", "tone": "marigold", "name": "Ruwan Silva", "last": "Cement price went up, sent receipt.", "when": "Yesterday", "unread": 0, "members": "Ruwan Silva · contractor"},
    {"id": "af", "initials": "AF", "tone": "herb", "name": "Anushka Fernando", "last": "Will inspect the slab on Thursday.", "when": "2 h", "unread": 0, "members": "Anushka Fernando · architect"},
    {"id": "sr", "initials": "SR", "tone": "celeste", "name": "Silva Residence · everyone", "last": "Roof sheets confirmed for Monday", "when": "Mon", "unread": 0, "members": "Silva Residence team"}
];

glob:pub MESSAGES: dict[str, any] = {
    "ph": [
        {"from": "RS", "name": "Ruwan Silva", "role": "Contractor", "text": "Slab shuttering removed. Photos of the underside attached for the architect.", "photos": 2, "time": "09:12", "mine": False, "tone": "marigold"},
        {"from": "AF", "name": "Anushka Fernando", "role": "Architect", "text": "Thanks. I'll inspect on Thursday and certify M3 if it's clean.", "photos": 0, "time": "09:40", "mine": False, "tone": "herb"},
        {"from": "NP", "name": "Nimali Perera", "role": "Client", "text": "Great. Please hold the roof order until CO-004 is decided.", "photos": 0, "time": "10:02", "mine": True, "tone": "celeste"}
    ],
    "ai": [], "rs": [{"from": "RS", "name": "Ruwan Silva", "role": "Contractor", "text": "Cement price went up, sent receipt.", "photos": 0, "time": "Yesterday", "mine": False, "tone": "marigold"}],
    "af": [{"from": "AF", "name": "Anushka Fernando", "role": "Architect", "text": "Will inspect the slab on Thursday.", "photos": 0, "time": "2 h", "mine": False, "tone": "herb"}],
    "sr": [{"from": "KS", "name": "K. Samarasinghe", "role": "Client", "text": "Roof sheets confirmed for Monday", "photos": 0, "time": "Mon", "mine": False, "tone": "celeste"}]
};

glob:pub MESSAGE_NOTE: str = "Ruwan mentioned a price rise. Nirmana linked it to ledger entry \"Cement 50 kg · 16 Oct\" (flagged 6.8% over market).";

glob:pub PINNED: list[any] = [
    {"icon": "file", "text": "A-102 rev C · ground floor"}, {"icon": "alert", "text": "M3 payment on hold"}, {"icon": "file", "text": "Contract · signed 1 Jun"}
];

glob:pub MARKET: dict[str, any] = {
    "districts": [{"name": "Kandy", "factor": 1.04}, {"name": "Colombo", "factor": 1.1}, {"name": "Galle", "factor": 1.02}],
    "products": ["Cement", "Steel", "Sand", "Bricks", "Roof tiles", "Timber"],
    "series": {
        "Cement": {"title": "Cement · 50 kg bag", "price": "Rs. 2,450", "delta": "+8% in 3 months", "tone": "danger",
                   "kandy": [2000, 2060, 2080, 2150, 2190, 2170, 2240, 2290, 2300, 2380, 2450, 2560], "national": [1960, 1980, 2010, 2040, 2060, 2090, 2120, 2150, 2200, 2250, 2290, 2340]},
        "Steel": {"title": "Steel rebar 12 mm · per kg", "price": "Rs. 292", "delta": "+3% in 3 months", "tone": "marigold",
                  "kandy": [270, 272, 275, 276, 280, 282, 284, 286, 288, 290, 291, 292], "national": [262, 264, 266, 268, 270, 272, 274, 276, 278, 280, 282, 284]},
        "Sand": {"title": "River sand · per m³", "price": "Rs. 14,500", "delta": "0% in 3 months", "tone": "neutral",
                 "kandy": [14200, 14300, 14400, 14400, 14500, 14500, 14500, 14500, 14500, 14500, 14500, 14500], "national": [13900, 14000, 14100, 14100, 14200, 14200, 14300, 14300, 14300, 14400, 14400, 14400]},
        "Bricks": {"title": "Cement blocks · per nos", "price": "Rs. 78", "delta": "-2% in 3 months", "tone": "herb",
                   "kandy": [80, 80, 79, 79, 80, 80, 79, 79, 79, 78, 78, 78], "national": [78, 78, 77, 77, 78, 78, 77, 77, 77, 76, 76, 76]},
        "Roof tiles": {"title": "Clay roof tiles · per nos", "price": "Rs. 85", "delta": "+1% in 3 months", "tone": "neutral",
                       "kandy": [82, 82, 83, 83, 83, 84, 84, 84, 85, 85, 85, 85], "national": [80, 80, 81, 81, 81, 82, 82, 82, 83, 83, 83, 83]},
        "Timber": {"title": "Teak (planed) · per cu ft", "price": "Rs. 9,800", "delta": "+5% in 3 months", "tone": "marigold",
                   "kandy": [9100, 9150, 9200, 9300, 9350, 9400, 9450, 9500, 9600, 9700, 9750, 9800], "national": [8900, 8950, 9000, 9100, 9150, 9200, 9250, 9300, 9400, 9500, 9550, 9600]}
    },
    "months": ["Nov", "Dec", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct"],
    "flag": {"title": "2 ledger entries above market", "body": "Perera House: cement at Rs. 2,720 is 11% over. Rebar at Rs. 312/kg is 7% over."},
    "month": [
        {"name": "Cement", "unit": "50 kg bag", "price": "Rs. 2,450", "delta": "+8%", "tone": "danger"},
        {"name": "Steel rebar 12 mm", "unit": "per kg", "price": "Rs. 292", "delta": "+3%", "tone": "marigold"},
        {"name": "River sand", "unit": "per m³", "price": "Rs. 14,500", "delta": "0%", "tone": "neutral"},
        {"name": "Cement blocks", "unit": "per nos", "price": "Rs. 78", "delta": "-2%", "tone": "herb"},
        {"name": "Clay roof tiles", "unit": "per nos", "price": "Rs. 85", "delta": "+1%", "tone": "neutral"},
        {"name": "Teak (planed)", "unit": "per cu ft", "price": "Rs. 9,800", "delta": "+5%", "tone": "marigold"}
    ],
    "note": "Ledger rates more than 5% above (market price × district factor) are flagged automatically."
};

glob:pub ESTIMATOR: dict[str, any] = {
    "prompt": "Two-storey, 3-bedroom house in Kandy, about 2,000 sq ft, clay tile roof, mid-range finishes, small garage.",
    "building": "Two-storey house", "district": "Kandy · cost factor ×1.04", "area": 2150, "contingency": 10, "finish": "Mid-range",
    "low": "Rs. 7.4M", "high": "Rs. 9.3M", "likely": "Rs. 8.24M", "per_sqft": "≈ Rs. 3,830 per sq ft", "range": "±12% range",
    "lines": [
        {"item": "Foundation & substructure", "qty": "1 lot", "rate": "—", "amount": 980000},
        {"item": "Concrete works (Grade 20)", "qty": "48 m³", "rate": "Rs. 32,500", "amount": 1560000},
        {"item": "Brickwork", "qty": "18,500 nos", "rate": "Rs. 38", "amount": 703000},
        {"item": "Roof · clay tiles", "qty": "1,250 sq ft", "rate": "Rs. 640", "amount": 800000},
        {"item": "Plumbing", "qty": "1 lot", "rate": "—", "amount": 420000},
        {"item": "Electrical", "qty": "1 lot", "rate": "—", "amount": 460000},
        {"item": "Finishes (plaster, tile, paint)", "qty": "2,150 sq ft", "rate": "Rs. 520", "amount": 1118000},
        {"item": "Allowances", "qty": "", "rate": "", "amount": 420000},
        {"item": "Labour · factor ×1.15", "qty": "", "rate": "", "amount": 1180000},
        {"item": "Contingency · 10%", "qty": "", "rate": "", "amount": 604000}
    ]
};

glob:pub CALC_RATES: dict[str, any] = {"cement": 2450, "sand": 14500, "metal": 8900, "brick": 38, "paint": 1850, "tile": 640, "steel": 292, "water": 0};
