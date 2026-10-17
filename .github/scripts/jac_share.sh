#!/usr/bin/env bash
# Hackathon rule: at least 80% of code lines must be Jac.
count() { git ls-files "$@" | grep -v '^\.github/' | xargs -r cat | grep -cv '^\s*$' || true; }
jac=$(count '*.jac')
other=$(count '*.py' '*.js' '*.jsx' '*.ts' '*.tsx' '*.html' '*.css')
total=$((jac + other))
if [ "$total" -eq 0 ]; then echo "No code yet."; exit 0; fi
pct=$((100 * jac / total))
msg="Jac share: ${pct}% (${jac} Jac lines / ${total} code lines)"
echo "$msg"
[ -n "${GITHUB_STEP_SUMMARY:-}" ] && echo "### $msg" >> "$GITHUB_STEP_SUMMARY"
if [ "$pct" -lt 80 ]; then echo "::error::$msg is below 80%"; exit 1; fi
