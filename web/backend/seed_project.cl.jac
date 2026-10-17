"""Seed data for the project tabs (Overview ... Tour). One dict per tab, keyed as the backend resource project.<tab>."""

import from .seed_core { HOUSE_LAYERS }

glob:pub TABS: list[any] = [
    {"id": "overview", "label": "Overview"}, {"id": "schedule", "label": "Schedule"}, {"id": "progress", "label": "Progress"},
    {"id": "plans", "label": "Plans"}, {"id": "materials", "label": "Materials"}, {"id": "budget", "label": "Budget"},
    {"id": "changes", "label": "Changes"}, {"id": "payments", "label": "Payments"}, {"id": "ledger", "label": "Ledger"},
    {"id": "activity", "label": "Activity"}, {"id": "tour", "label": "Tour"}
];

glob:pub P_OVERVIEW: dict[str, any] = {
    "kpis": [
        {"label": "Earned value", "value": "Rs. 2.59M", "pill": "32% of Rs. 8.06M", "tone": "info"},
        {"label": "Cost performance", "value": "0.94", "pill": "Slightly over cost", "tone": "progress"},
        {"label": "Schedule performance", "value": "0.88", "pill": "3 weeks behind", "tone": "delayed"},
        {"label": "Forecast final cost", "value": "Rs. 8.60M", "pill": "+ Rs. 536,000", "tone": "delayed"},
        {"label": "Days left", "value": "148", "pill": "Handover 15 Mar", "tone": "info"}
    ],
    "score": 78, "score_label": "Good · +4 this week", "score_note": "Strongest on rates. Weakest on slow approvals: 2 items are waiting on you.",
    "bars": [
        {"label": "Receipts attached", "n": 22, "of": 25, "tone": "herb"}, {"label": "Verified by architect", "n": 9, "of": 15, "tone": "marigold"},
        {"label": "Rates within market", "n": 27, "of": 30, "tone": "herb"}, {"label": "Recent daily logs", "n": 12, "of": 15, "tone": "herb"},
        {"label": "Approvals answered", "n": 8, "of": 15, "tone": "danger"}
    ],
    "curve": {
        "months": ["Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "Jan", "Feb", "Mar", "Apr", "May"], "today": 4.5, "max": 9.0,
        "planned": [[0, 0.05], [1, 0.35], [2, 0.8], [3, 1.5], [4, 2.4], [5, 3.1], [6, 4.0], [7, 4.9], [8, 5.8], [9, 6.8], [10, 7.7], [11, 8.6]],
        "earned": [[0, 0.05], [1, 0.3], [2, 0.7], [3, 1.35], [4, 2.2], [4.5, 2.59]],
        "actual": [[0, 0.05], [1, 0.32], [2, 0.75], [3, 1.4], [4, 2.3], [4.5, 2.76]],
        "pv": "Rs. 3.10M", "ev": "Rs. 2.59M", "ac": "Rs. 2.76M"
    },
    "risks": [
        {"icon": "rain", "title": "Monsoon delays roof work", "body": "Nov rain could add 1–2 weeks to roofing.", "tag": "Likely", "tone": "delayed"},
        {"icon": "trend", "title": "Cement price still rising", "body": "+8% in 3 months. Buy for walls now.", "tag": "Possible", "tone": "progress"},
        {"icon": "wallet", "title": "Payments ahead of verified work", "body": "Rs. 1.61M paid but not yet verified.", "tag": "Watch", "tone": "info"}
    ],
    "stages": [
        {"name": "Design & approvals", "note": "Certified 28 May", "tone": "herb"}, {"name": "Foundation", "note": "Certified 4 Jul", "tone": "herb"},
        {"name": "Columns", "note": "Certified 2 Aug", "tone": "herb"}, {"name": "Slab & first floor", "note": "Due 30 Sep · 60%", "tone": "danger"},
        {"name": "Walls", "note": "Started 12 Oct", "tone": "marigold"}, {"name": "Roof", "note": "From 12 Nov", "tone": "muted"}
    ],
    "stage_label": "Stage 4 of 9"
};

glob:pub P_SCHEDULE: dict[str, any] = {
    "months": ["Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "Jan", "Feb", "Mar"], "today": 6.57,
    "phases": [
        {"name": "Design & approvals", "tone": "herb", "plan": [0, 2], "act": [0, 2]},
        {"name": "Foundation", "tone": "herb", "plan": [2, 3.2], "act": [2, 3.1]},
        {"name": "Columns", "tone": "herb", "plan": [3.2, 4], "act": [3.1, 4.1]},
        {"name": "Slab & first floor", "tone": "danger", "plan": [4, 6], "act": [4.1, 6.55]},
        {"name": "Walls", "tone": "marigold", "plan": [5.5, 7.5], "act": [6.4, 6.55]},
        {"name": "Roof", "tone": "muted", "plan": [7.3, 8.6], "act": [0, 0]},
        {"name": "Plumbing & electrical", "tone": "muted", "plan": [8, 9.5], "act": [0, 0]},
        {"name": "Plastering", "tone": "muted", "plan": [9.3, 10.3], "act": [0, 0]},
        {"name": "Tiling & painting", "tone": "muted", "plan": [10, 11.2], "act": [0, 0]},
        {"name": "Handover", "tone": "muted", "plan": [11.2, 11.6], "act": [0, 0]}
    ],
    "next": [
        {"icon": "check", "title": "Slab inspection", "sub": "Thu 22 Oct · Architect"}, {"icon": "box", "title": "Roof timber delivery", "sub": "Mon 9 Nov · Contractor"},
        {"icon": "calendar", "title": "Roof work starts", "sub": "Thu 12 Nov · Contractor"}, {"icon": "wallet", "title": "Milestone 4 invoice", "sub": "Mon 30 Nov · Contractor"}
    ],
    "certify": {"phase": "Slab & first floor", "note": "60% done · due 30 Sep", "tag": "Late"},
    "delays": [{"icon": "rain", "title": "Heavy rain", "sub": "8–10 Oct", "days": "3 days"}, {"icon": "box", "title": "Cement shortage", "sub": "21–24 Sep", "days": "4 days"}],
    "delays_total": "7 days total"
};

glob:pub P_PROGRESS: dict[str, any] = {
    "digest": {"title": "Weekly digest · 11–17 Oct", "tag": "AI summary · sent to client",
               "text": "Slab shuttering came off on Wednesday after a 3-day rain delay. Ground floor walls started Monday and are about 4% laid. Two cement receipts were added; one is 11% above market and is with the architect.",
               "stats": [["Logs posted", "5 of 6 days"], ["Crew on site", "8 avg"], ["Rain days", "2"]]},
    "logs": [
        {"id": "l17", "day": "17", "mon": "Oct", "title": "Walls · ground floor", "weather": "Sunny", "workers": "9 workers", "when": "Oct · Sat",
         "text": "Laid 1,100 bricks on the north and east walls. Lintel shuttering started over the kitchen window.", "photos": 3, "by": "Ruwan Silva", "initials": "RS", "status": "Awaiting architect", "ack": False},
        {"id": "l16", "day": "16", "mon": "Oct", "title": "Slab · curing check", "weather": "Cloudy", "workers": "4 workers", "when": "Oct · Fri",
         "text": "Removed remaining props from the verandah slab. Uploaded photos of the underside for the payment hold.", "photos": 2, "by": "Ruwan Silva", "initials": "RS", "status": "Acknowledged · A. Fernando", "ack": True},
        {"id": "l15", "day": "15", "mon": "Oct", "title": "Site closed", "weather": "Rain", "workers": "0 workers", "when": "Oct · Thu",
         "text": "Heavy rain from 9 am. Covered cement stock and stopped work.", "photos": 0, "by": "Ruwan Silva", "initials": "RS", "status": "Acknowledged · A. Fernando", "ack": True}
    ],
    "layers": HOUSE_LAYERS,
    "sliders": [{"name": "Walls", "pct": 4}, {"name": "Slab", "pct": 60}],
    "elements": ["Walls", "Slab", "Columns", "Plumbing", "Electrical"]
};

glob:pub P_PLANS: dict[str, any] = {
    "sheets": [
        {"id": "a101", "code": "A-101", "name": "Site plan", "rev": "B", "status": "Approved", "tone": "herb"},
        {"id": "a102", "code": "A-102", "name": "Ground floor", "rev": "C", "status": "Awaiting you", "tone": "progress"},
        {"id": "a103", "code": "A-103", "name": "First floor", "rev": "A", "status": "Revision asked", "tone": "delayed"},
        {"id": "s201", "code": "S-201", "name": "Slab reinforcement", "rev": "B", "status": "Approved", "tone": "herb"},
        {"id": "e301", "code": "E-301", "name": "Electrical layout", "rev": "A", "status": "Awaiting you", "tone": "progress"}
    ],
    "viewer": {"title": "A-102 · Ground floor", "rev": "Rev C", "note": "replaces rev B · 13 Oct", "zoom": "100%"},
    "comments": [
        {"n": 1, "by": "Architect", "initials": "AF", "text": "Kitchen window moved 600 mm left to clear the new column.", "tag": "Design change", "tone": "info"},
        {"n": 2, "by": "Client", "initials": "NP", "text": "Can the bathroom door open outward? Small space.", "tag": "Question", "tone": "neutral"},
        {"n": 3, "by": "Contractor", "initials": "RS", "text": "Verandah slab extension adds about Rs. 95,000.", "tag": "Cost impact", "tone": "delayed"}
    ]
};

glob:pub P_MATERIALS: dict[str, any] = {
    "kpis": [
        {"icon": "box", "label": "Materials spend", "value": "Rs. 1.42M", "sub": "51% of cost to date", "tone": "white"},
        {"icon": "trend", "label": "Rates within market", "value": "9 of 11", "sub": "Kandy prices ×1.04", "tone": "herb"},
        {"icon": "alert", "label": "Flagged rates", "value": "2", "sub": "More than 5% above market", "tone": "marigold"},
        {"icon": "receipt", "label": "Receipts attached", "value": "88%", "sub": "22 of 25 entries", "tone": "celeste"}
    ],
    "rates": [
        {"name": "Cement 50 kg", "used": "120 bags", "paid": "Rs. 2,720", "market": "Rs. 2,450", "diff": "+11% · flagged", "flag": True},
        {"name": "Steel rebar 12 mm", "used": "380 kg", "paid": "Rs. 312", "market": "Rs. 292", "diff": "+7% · flagged", "flag": True},
        {"name": "River sand", "used": "6 m³", "paid": "Rs. 14,800", "market": "Rs. 14,500", "diff": "+2%", "flag": False},
        {"name": "Metal 20 mm", "used": "9 m³", "paid": "Rs. 8,700", "market": "Rs. 8,900", "diff": "-2%", "flag": False},
        {"name": "Cement blocks", "used": "2,400 nos", "paid": "Rs. 78", "market": "Rs. 78", "diff": "0%", "flag": False},
        {"name": "Binding wire", "used": "25 kg", "paid": "Rs. 640", "market": "Rs. 620", "diff": "+3%", "flag": False},
        {"name": "Timber shuttering", "used": "80 sheets", "paid": "Rs. 3,150", "market": "Rs. 3,200", "diff": "-2%", "flag": False}
    ],
    "site": [
        {"name": "Cement", "have": "42", "need": "180 bags", "pct": 23, "tone": "marigold"}, {"name": "Bricks", "have": "6200", "need": "18500 nos", "pct": 34, "tone": "herb"},
        {"name": "Sand", "have": "3", "need": "8 m³", "pct": 38, "tone": "marigold"}, {"name": "Steel", "have": "380", "need": "1450 kg", "pct": 26, "tone": "danger"}
    ],
    "updated": "Updated 17 Oct",
    "tip": {"title": "Buy cement for walls this week", "body": "Prices have risen 8% in 3 months. 140 more bags are needed for the walls."}
};

glob:pub P_BUDGET: dict[str, any] = {
    "contract": "Rs. 8,000,000", "approved": "Rs. 64,000", "revised": "Rs. 8,064,000", "pending": "+ Rs. 180,000", "forecast": "Rs. 8,600,000",
    "segments": [["Cost to date · Rs. 2.76M", 34, "midnight"], ["Paid ahead · Rs. 1.44M", 18, "marigold"], ["Remaining · Rs. 3.86M", 48, "subtle"]],
    "boq": [
        {"item": "Foundation & substructure", "budget": "Rs. 980,000", "spent": "Rs. 1,030,000", "pct": 105, "tone": "danger", "status": "+5%"},
        {"item": "Concrete works", "budget": "Rs. 1,560,000", "spent": "Rs. 1,120,000", "pct": 72, "tone": "marigold", "status": "On track"},
        {"item": "Brickwork", "budget": "Rs. 703,000", "spent": "Rs. 120,000", "pct": 17, "tone": "herb", "status": "On track"},
        {"item": "Roof · clay tiles", "budget": "Rs. 800,000", "spent": "Rs. 0", "pct": 0, "tone": "herb", "status": "Not started"},
        {"item": "Plumbing", "budget": "Rs. 420,000", "spent": "Rs. 38,000", "pct": 9, "tone": "herb", "status": "On track"},
        {"item": "Electrical", "budget": "Rs. 460,000", "spent": "Rs. 22,000", "pct": 5, "tone": "herb", "status": "On track"},
        {"item": "Finishes", "budget": "Rs. 1,118,000", "spent": "Rs. 0", "pct": 0, "tone": "herb", "status": "Not started"},
        {"item": "Labour", "budget": "Rs. 1,180,000", "spent": "Rs. 430,000", "pct": 36, "tone": "herb", "status": "On track"}
    ],
    "total": {"budget": "Rs. 8,064,000", "spent": "Rs. 2,760,000", "pct": 34},
    "money": [
        {"name": "Materials", "amount": "Rs. 1.42M · 51%", "pct": 51, "tone": "midnight"}, {"name": "Labour", "amount": "Rs. 0.94M · 34%", "pct": 34, "tone": "herb"},
        {"name": "Equipment hire", "amount": "Rs. 0.25M · 9%", "pct": 9, "tone": "marigold"}, {"name": "Other", "amount": "Rs. 0.15M · 6%", "pct": 6, "tone": "celeste"}
    ],
    "note": "Forecast = cost to date + remaining work + cost performance (0.94). It updates every time a ledger entry is verified."
};

glob:pub P_CHANGES: dict[str, any] = {
    "summary": {"approved": "+ Rs. 64,000", "pending": "+ Rs. 180,000"},
    "orders": [
        {"id": "CO-004", "title": "Upgrade roof to Calicut tiles", "meta": "Client request · raised by Ruwan Silva · 15 Oct", "amount": "+ Rs. 180,000", "days": "+4 days", "status": "pending", "decided": "",
         "rate": "Rate check: 6% below Kandy market"},
        {"id": "CO-003", "title": "Extra column footing at grid C3", "meta": "Site condition · raised by Ruwan Silva · 28 Sep", "amount": "+ Rs. 64,000", "days": "+2 days", "status": "approved", "decided": "Approved by Nimali Perera · 2 Oct", "rate": ""},
        {"id": "CO-002", "title": "Move septic tank 3 m east", "meta": "Design change · raised by Anushka Fernando · 12 Aug", "amount": "Rs. 0", "days": "0 days", "status": "approved", "decided": "Approved by Nimali Perera · 14 Aug", "rate": ""},
        {"id": "CO-001", "title": "Add a second kitchen window", "meta": "Client request · raised by Ruwan Silva · 20 Jul", "amount": "+ Rs. 46,000", "days": "+1 day", "status": "rejected", "decided": "Rejected by Nimali Perera · 22 Jul · \"over budget\"", "rate": ""}
    ],
    "how": [["Contractor raises it", "With cost, time and a reason."], ["Client decides once", "Approve or reject. It cannot be undone."], ["Contract updates", "Approved cost is added to the revised sum."]]
};

glob:pub P_PAYMENTS: dict[str, any] = {
    "guard": {"paid": "Rs. 4,200,000", "verified": "Rs. 2,592,000", "ahead": "Rs. 1,608,000", "verified_pct": 32, "ahead_pct": 20},
    "milestones": [
        {"id": "m0", "code": "M0", "name": "Mobilisation advance", "amount": "Rs. 800,000", "stage": 4, "stage_label": "Paid", "tag": "Paid 5 Jun", "tone": "herb"},
        {"id": "m1", "code": "M1", "name": "Foundation complete", "amount": "Rs. 1,600,000", "stage": 4, "stage_label": "Paid", "tag": "Paid 10 Jul", "tone": "herb"},
        {"id": "m2", "code": "M2", "name": "Columns & ground slab", "amount": "Rs. 1,800,000", "stage": 4, "stage_label": "Paid", "tag": "Paid 12 Aug", "tone": "herb"},
        {"id": "m3", "code": "M3", "name": "Slab complete", "amount": "Rs. 800,000", "stage": 1, "stage_label": "Invoiced", "tag": "Held · needs photos", "tone": "danger",
         "note": "Architect asked for photos of the slab underside before certifying. Invoice sent 9 Oct."},
        {"id": "m4", "code": "M4", "name": "Walls to lintel", "amount": "Rs. 1,200,000", "stage": 0, "stage_label": "Upcoming", "tag": "Due 30 Nov", "tone": "muted"},
        {"id": "m5", "code": "M5", "name": "Roof complete", "amount": "Rs. 1,400,000", "stage": 0, "stage_label": "Upcoming", "tag": "Due Jan 2027", "tone": "muted"},
        {"id": "m6", "code": "M6", "name": "Finishes & handover", "amount": "Rs. 1,000,000", "stage": 0, "stage_label": "Upcoming", "tag": "Due Mar 2027", "tone": "muted"}
    ],
    "retention": {"amount": "Rs. 400,000", "text": "5% of each payment is kept back until 6 months after handover, to cover defects.", "release": "Release · Sep 2027"},
    "next": {"title": "M3 · Slab complete", "amount": "Rs. 800,000", "note": "Pay unlocks after Anushka Fernando certifies the invoice."},
    "certify": {"title": "Certify milestone", "sub": "M3 · Slab complete · invoiced 9 Oct by R. Silva Builders", "invoice": "Rs. 800,000", "retention": "- Rs. 40,000", "pays": "Rs. 760,000",
                "evidence": [{"t": "Slab element marked 100%", "s": "by contractor · 16 Oct", "ok": True}, {"t": "4 photos of the slab underside", "s": "uploaded 16 Oct", "ok": True},
                             {"t": "Daily log acknowledged", "s": "Slab · curing check", "ok": True}, {"t": "Site inspection", "s": "you · planned Thu 22 Oct", "ok": False}]}
};

glob:pub P_LEDGER: dict[str, any] = {
    "counts": {"all": 25, "pending": 3, "queried": 1, "flagged": 2},
    "entries": [
        {"id": "e1", "date": "16 Oct", "name": "Cement 50 kg · Lanka Hardware, Kandy", "qty": "120 × Rs. 2,720", "amount": "Rs. 326,400", "receipt": True, "audit": "Overpriced", "audit_tone": "delayed", "status": "Pending review", "status_tone": "progress", "flag": True},
        {"id": "e2", "date": "14 Oct", "name": "Steel rebar 12 mm · Kandy Steel Centre", "qty": "380 kg × Rs. 312", "amount": "Rs. 118,560", "receipt": True, "audit": "Review", "audit_tone": "progress", "status": "Queried", "status_tone": "info", "flag": False},
        {"id": "e3", "date": "12 Oct", "name": "Labour · masons (week 19)", "qty": "6 × Rs. 4,500 × 5", "amount": "Rs. 135,000", "receipt": False, "audit": "Review", "audit_tone": "progress", "status": "Pending review", "status_tone": "progress", "flag": False},
        {"id": "e4", "date": "10 Oct", "name": "Cement blocks · Gamini Blocks", "qty": "2,400 × Rs. 78", "amount": "Rs. 187,200", "receipt": True, "audit": "OK", "audit_tone": "herb", "status": "Verified", "status_tone": "herb", "flag": False},
        {"id": "e5", "date": "8 Oct", "name": "River sand · Mahaweli Sand Co.", "qty": "6 m³ × Rs. 14,800", "amount": "Rs. 88,800", "receipt": True, "audit": "OK", "audit_tone": "herb", "status": "Verified", "status_tone": "herb", "flag": False},
        {"id": "e6", "date": "3 Oct", "name": "Shuttering hire · 2 weeks", "qty": "80 × Rs. 3,150", "amount": "Rs. 252,000", "receipt": True, "audit": "OK", "audit_tone": "herb", "status": "Verified", "status_tone": "herb", "flag": False},
        {"id": "e7", "date": "30 Sep", "name": "Metal 20 mm · Hanthana Quarry", "qty": "9 m³ × Rs. 8,700", "amount": "Rs. 78,300", "receipt": True, "audit": "OK", "audit_tone": "herb", "status": "Verified", "status_tone": "herb", "flag": False}
    ],
    "auditor": "Cement on 16 Oct was bought at Rs. 2,720 a bag. Kandy market this month is Rs. 2,450 × 1.04 = Rs. 2,548, so this is 6.8% above the 5% tolerance. Ask the contractor for the supplier quote.",
    "totals": [["Entries", "25"], ["Verified", "Rs. 2,184,300"], ["Pending or queried", "Rs. 580,000"], ["Receipts attached", "22 of 25"]],
    "drawer": {"e1": {"title": "Cement 50 kg", "sub": "Lanka Hardware, Kandy · 16 Oct 2026", "amount": "Rs. 326,400", "qty": "120 bags × Rs. 2,720", "file": "receipt-lanka-1610.jpg", "file_meta": "Uploaded by Ruwan Silva · 16 Oct, 17:30",
               "rate": [["Market price · Oct, Sri Lanka", "Rs. 2,450"], ["Kandy cost factor", "× 1.04"], ["Fair price", "Rs. 2,548"], ["Paid", "Rs. 2,720"]], "over": "+6.8% · limit 5%",
               "ai": "AI auditor · overpriced", "ai_body": "Two other Kandy suppliers listed Rs. 2,480–2,560 this week. Suggest asking for the quote or a credit note.",
               "history": [["RS", "Ruwan Silva added this entry", "16 Oct · 17:30"], ["AI", "Nirmana AI flagged the rate", "17 Oct · 08:15"]]}}
};

glob:pub P_ACTIVITY: dict[str, any] = {
    "filters": ["Everything", "Money", "Approvals", "Daily logs", "Plans"],
    "groups": [
        {"day": "Today · Sat 17 Oct", "items": [
            {"time": "09:42", "icon": "camera", "kind": "Daily logs", "who": "Ruwan Silva", "role": "Contractor", "initials": "RS", "act": "posted a daily log", "what": "Walls · ground floor · 3 photos", "tone": "celeste"},
            {"time": "08:15", "icon": "alert", "kind": "Money", "who": "Nirmana AI", "role": "System", "initials": "AI", "act": "flagged a ledger entry", "what": "Cement 50 kg at Rs. 2,720 is 6.8% over market", "tone": "danger"}]},
        {"day": "Fri 16 Oct", "items": [
            {"time": "17:30", "icon": "receipt", "kind": "Money", "who": "Ruwan Silva", "role": "Contractor", "initials": "RS", "act": "added a ledger entry", "what": "Cement 50 kg · Rs. 326,400 · receipt attached", "tone": "marigold"},
            {"time": "11:05", "icon": "camera", "kind": "Daily logs", "who": "Anushka Fernando", "role": "Architect", "initials": "AF", "act": "acknowledged a daily log", "what": "Slab · curing check", "tone": "celeste"},
            {"time": "10:20", "icon": "wallet", "kind": "Money", "who": "Anushka Fernando", "role": "Architect", "initials": "AF", "act": "put a payment on hold", "what": "M3 · Slab complete · Rs. 800,000 · needs photos", "tone": "marigold"}]},
        {"day": "Thu 15 Oct", "items": [
            {"time": "16:48", "icon": "file", "kind": "Approvals", "who": "Ruwan Silva", "role": "Contractor", "initials": "RS", "act": "raised a change order", "what": "CO-004 · Calicut roof tiles · + Rs. 180,000", "tone": "midnight"},
            {"time": "09:00", "icon": "file", "kind": "Plans", "who": "Anushka Fernando", "role": "Architect", "initials": "AF", "act": "uploaded a plan revision", "what": "A-102 Ground floor · rev C replaces rev B", "tone": "midnight"}]},
        {"day": "Fri 2 Oct", "items": [
            {"time": "19:12", "icon": "check", "kind": "Approvals", "who": "Nimali Perera", "role": "Client", "initials": "NP", "act": "approved a change order", "what": "CO-003 · Extra column footing · + Rs. 64,000", "tone": "herb"}]}
    ],
    "this_month": "48 entries", "by_role": [["Contractor", 26, "marigold"], ["Architect", 14, "herb"], ["Client", 6, "celeste"], ["System (AI)", 2, "midnight"]]
};

glob:pub P_TOUR: dict[str, any] = {
    "note": "Proposal: the roadmap names a \"Tour\" tab but does not define it. This version is a photo walkthrough: the same spots photographed over time, so anyone can see the house grow.",
    "spots": [
        {"id": "kitchen", "name": "Kitchen · north wall", "meta": "14 photos · last Today"}, {"id": "front", "name": "Front elevation", "meta": "18 photos · last Today"},
        {"id": "living", "name": "Living room", "meta": "12 photos · last 16 Oct"}, {"id": "stairs", "name": "Stairs", "meta": "9 photos · last 12 Oct"},
        {"id": "roof", "name": "Roof slab top", "meta": "16 photos · last 10 Oct"}, {"id": "bath", "name": "Bathroom", "meta": "15 photos · last 2 Oct"}
    ],
    "summary": "6 spots · 84 photos",
    "timeline": [["3 Jun", "subtle"], ["4 Jul", "herb"], ["12 Aug", "marigold"], ["16 Sep", "celeste"], ["8 Oct", "herb"], ["17 Oct", "marigold"]],
    "compare": {"left": "12 Aug · columns", "right": "17 Oct · walls", "from": "Jun", "to": "Oct"}
};

glob:pub PROJECT_TABS: dict[str, any] = {
    "overview": P_OVERVIEW, "schedule": P_SCHEDULE, "progress": P_PROGRESS, "plans": P_PLANS, "materials": P_MATERIALS, "budget": P_BUDGET,
    "changes": P_CHANGES, "payments": P_PAYMENTS, "ledger": P_LEDGER, "activity": P_ACTIVITY, "tour": P_TOUR
};

glob:pub ASK_PROMPTS: list[any] = ["When will the roof start?", "Am I over budget?", "Summarise this week"];
glob:pub ASK_ANSWERS: dict[str, any] = {
    "transparency": {"chips": ["Transparency breakdown", "Approvals · 2 pending"], "text": "Two things pull it down. You have 2 approvals waiting (CO-004 and plan A-102), and only part of the work paid for has been verified by the architect. Deciding on CO-004 would add about 2 points.",
                     "rows": [["Approvals answered", "8 / 15"], ["Verified by architect", "9 / 15"]]},
    "roof": {"chips": ["Schedule · Roof", "Weather · Nov"], "text": "Roofing is planned from 12 Nov. The slab is 3 weeks behind and Nov rain could add 1–2 weeks, so a realistic start is early December.", "rows": []},
    "budget": {"chips": ["Budget · forecast", "Ledger"], "text": "Yes, by about Rs. 536,000 on the forecast final cost of Rs. 8.60M. Cost performance is 0.94, and Rs. 1.61M has been paid ahead of verified work.", "rows": [["Forecast final cost", "Rs. 8.60M"], ["Revised contract", "Rs. 8.06M"]]},
    "week": {"chips": ["Weekly digest · 11–17 Oct"], "text": "Slab shuttering came off after a 3-day rain delay. Ground floor walls started and are about 4% laid. One cement receipt is 11% above market and is with the architect.", "rows": []},
    "draft": {"chips": ["Ledger · Cement 16 Oct", "Market · Kandy Oct"], "text": "Here is a polite draft. It is not sent until you send it yourself.", "rows": [],
              "draft": "Hi Ruwan, the cement on 16 Oct was Rs. 2,720 a bag, about 7% above the Kandy rate. Could you share the supplier quote, or ask for a credit note? Thanks, Nimali"},
    "other": {"chips": ["Project data"], "text": "I read this project's schedule, budget, ledger and logs. Ask about cost, schedule or receipts. I never pay or approve anything.", "rows": []}
};
