"""Small stroke icons drawn inline, so the UI needs no icon package."""

glob ICON_PATHS: dict[str, list[str]] = {
    "logo": ["M12 2 3 7v10l9 5 9-5V7z", "M3 7l9 5 9-5", "M12 12v10"],
    "home": ["M3 11 12 4l9 7", "M5 10v10h5v-6h4v6h5V10"],
    "shield": ["M12 3 4 6v6c0 5 3.5 8 8 9 4.5-1 8-4 8-9V6z"],
    "shield-check": ["M12 3 4 6v6c0 5 3.5 8 8 9 4.5-1 8-4 8-9V6z", "m9 12 2 2 4-4"],
    "trend": ["m3 17 6-6 4 4 8-8", "M15 7h6v6"],
    "layers": ["m12 3 9 5-9 5-9-5z", "m3 13 9 5 9-5"],
    "sparkle": ["M12 3v4", "M12 17v4", "M3 12h4", "M17 12h4", "m6 6 2.5 2.5", "m15.5 15.5 2.5 2.5", "m18 6-2.5 2.5", "m8.5 15.5-2.5 2.5"],
    "chat": ["M4 5h16v11H9l-5 4z"],
    "wallet": ["M3 7h16a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z", "M3 7l3-3h11v3", "M16 13h2"],
    "check": ["m5 12 5 5 9-10"],
    "calendar": ["M4 6h16v14H4z", "M4 10h16", "M8 3v4", "M16 3v4"],
    "cloud": ["M7 18h10a4 4 0 0 0 .5-8A6 6 0 0 0 6 9a4.5 4.5 0 0 0 1 9z"],
    "alert": ["M12 3 2 20h20z", "M12 10v4", "M12 17v.5"]
};

def:pub Icon(name: str, size: int = 18) -> JsxElement {
    paths = ICON_PATHS[name] if name in ICON_PATHS else ICON_PATHS["alert"];
    return <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor"
        strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
        {for (i, d) in enumerate(paths) {
            <path key={str(i)} d={d}/>
        }}
    </svg>;
}
