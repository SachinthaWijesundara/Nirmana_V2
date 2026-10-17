"""PLACEHOLDER twin graph so P2 agents compile and test before P1's real schema lands.
Field names follow PLAN-P2.md. Swap this import for P1's twin.jac once agreed."""

enum PaymentStatus { PAID, HELD, RELEASED }

node House {
    has name: str;
    has total_budget: float = 0.0;
}

node Element {
    has name: str;
    has kind: str = "";
    has planned_cost: float = 0.0;
    has actual_cost: float = 0.0;
    has percent_complete: float = 0.0;
    has planned_start: str = "";
    has planned_end: str = "";
    has materials: list[str] = [];
    has photos: list[str] = [];
}

node Payment {
    has amount: float;
    has status: PaymentStatus = PaymentStatus.PAID;
    has note: str = "";
}

node Update {
    has raw_text: str;
    has summary: str = "";
}

node Activity {
    has actor: str;
    has kind: str;
    has text: str;
}

node DelayNotice {
    has date: str;
    has element_name: str;
    has cause_chain: list[str];
    has days_behind: int;
    has evidence: str;
}

edge Has {}
edge depends_on {}
edge paid_by {}
edge reported_in {}

def seed_mock_house() -> House {
    house = (root ++> House(name="Nimal's house", total_budget=10000000.0))[0];
    slab = (house +>:Has():+> Element(name="Slab", kind="structure", planned_cost=3000000.0))[0];
    walls = (house +>:Has():+> Element(name="Walls", kind="structure", planned_cost=2500000.0))[0];
    foundation = (house +>:Has():+> Element(name="Foundation", kind="structure", planned_cost=1500000.0, percent_complete=100.0))[0];
    slab +>:depends_on():+> foundation;
    walls +>:depends_on():+> slab;
    return house;
}
