"""Accounts, project membership and the access check every endpoint runs.

Sign-in is Jac's built-in /user/register and /user/login (the email is the username).
After the first login the user calls create_profile once. Every other endpoint is
authenticated and goes through access() before it reads or writes anything.

Each user has their own private root. Project data is shared between the client,
architect and contractor, so projects hang off a Registry on root.shared and this
module decides who may see or change them: only members, and only in their role."""
import from twin { Profile, Registry, Member, House, Activity, Has, ROLES, now_iso }

"""Who is calling, on which project, in which role."""
obj Ctx {
    has house: House,
        me: Profile,
        member: Member;
}

def registry() -> Registry {
    regs = [root.shared -->][?:Registry];
    if len(regs) > 0 { return regs[0]; }
    reg = Registry();
    root.shared ++> reg;
    grant(reg, level=WritePerm);
    return reg;
}

def me_or_none() -> Profile | None {
    profiles = [root -->][?:Profile];
    if len(profiles) > 0 { return profiles[0]; }
    return None;
}

def me() -> Profile {
    p = me_or_none();
    if p is None { raise PermissionError("No profile yet. Call create_profile after signing in."); }
    return p;
}

def initials(name: str) -> str {
    parts = [w for w in name.split() if w != ""];
    if len(parts) == 0 { return "?"; }
    if len(parts) == 1 { return parts[0][0:2].upper(); }
    return (parts[0][0] + parts[len(parts) - 1][0]).upper();
}

def profile_view(p: Profile) -> dict[str, any] {
    return {"root_id": p.root_id, "email": p.email, "name": p.name, "initials": initials(p.name), "default_role": p.default_role, "phone": p.phone};
}

def members(house: House) -> list[Member] {
    return [house ->:Has:->][?:Member];
}

"""The caller's membership on a project. An invite sent to the caller's email is claimed on first use."""
def membership(house: House, p: Profile) -> Member | None {
    for m in members(house) {
        if m.root_id == p.root_id and m.status != "removed" { return m; }
    }
    for m in members(house) {
        if m.root_id == "" and m.email == p.email and m.status == "invited" {
            m.root_id = p.root_id;
            m.status = "active";
            m.joined_at = now_iso();
            if m.name == "" { m.name = p.name; }
            return m;
        }
    }
    return None;
}

def project_node(project_id: str) -> House {
    n = jobj(project_id);
    if not isinstance(n, House) { raise ValueError(f"Unknown project {project_id}."); }
    return n;
}

"""Load a project for the caller, or refuse. roles = who may do this action (empty = any member)."""
def access(project_id: str, roles: list[str] = []) -> Ctx {
    p = me();
    house = project_node(project_id);
    m = membership(house, p);
    if m is None { raise PermissionError("You are not a member of this project."); }
    if len(roles) > 0 and m.role not in roles {
        raise PermissionError(f"Only the {' or '.join(roles)} can do this. You are the {m.role} on this project.");
    }
    return Ctx(house=house, me=p, member=m);
}

"""Every project the caller belongs to, with their role on it."""
def my_projects() -> list[Ctx] {
    p = me();
    out: list[Ctx] = [];
    for house in [registry() ->:Has:->][?:House] {
        m = membership(house, p);
        if m is not None { out.append(Ctx(house=house, me=p, member=m)); }
    }
    return out;
}

"""Write to the audit trail. category: money, approvals, progress, project."""
def log(ctx: Ctx, kind: str, text: str, category: str) -> Activity {
    act = Activity(actor=ctx.me.name, kind=kind, text=text, role=ctx.member.role, category=category, at=now_iso());
    ctx.house +>:Has():+> act;
    grant(act, level=WritePerm);
    return act;
}

def team(house: House) -> list[dict[str, any]] {
    rows: list[dict[str, any]] = [];
    for m in members(house) {
        if m.status == "removed" { continue; }
        rows.append({"name": m.name, "email": m.email, "role": m.role, "status": m.status, "initials": initials(m.name if m.name != "" else m.email)});
    }
    return rows;
}

# ---------------------------------------------------------------- endpoints

"""Create (or update) the caller's profile. role is the default role picked on the sign-in screen."""
def create_profile(name: str, email: str, role: str = "client", phone: str = "") -> dict[str, any] {
    clean_email = email.strip().lower();
    if role not in ROLES { raise ValueError(f"role must be one of {ROLES}."); }
    if clean_email == "" or "@" not in clean_email { raise ValueError("A valid email is required."); }
    reg = registry();
    for other in [reg ->:Has:->][?:Profile] {
        if other.email == clean_email and other.root_id != jid(root) {
            raise ValueError("That email already belongs to another account.");
        }
    }
    existing = me_or_none();
    if existing is not None {
        existing.name = name;
        existing.email = clean_email;
        existing.default_role = role;
        existing.phone = phone;
        return profile_view(existing);
    }
    p = Profile(root_id=jid(root), email=clean_email, name=name, default_role=role, phone=phone, created_at=now_iso());
    root ++> p;
    reg +>:Has():+> p;
    grant(p, level=ReadPerm);
    return profile_view(p);
}

"""The caller's profile and the projects they are on."""
def get_me() -> dict[str, any] {
    p = me();
    projects: list[dict[str, any]] = [];
    for ctx in my_projects() {
        projects.append({"id": jid(ctx.house), "name": ctx.house.name, "role": ctx.member.role});
    }
    view = profile_view(p);
    view["projects"] = projects;
    return view;
}

test "profile, registry and membership checks" {
    p = create_profile("Nimali Perera", "Nimali@Example.com", "client");
    assert p["email"] == "nimali@example.com";
    assert p["initials"] == "NP";
    house = House(name="Test House");
    registry() +>:Has():+> house;
    house +>:Has():+> Member(email="nimali@example.com", role="client");
    ctx = access(jid(house));
    assert ctx.member.role == "client";
    assert ctx.member.status == "active";
    refused = False;
    try { access(jid(house), ["architect"]); } except PermissionError { refused = True; }
    assert refused;
    assert len(my_projects()) == 1;
}
