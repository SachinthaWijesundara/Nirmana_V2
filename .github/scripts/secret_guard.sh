#!/usr/bin/env bash
# Fail if anything that looks like an OpenAI/Anthropic key is tracked.
if git grep -nIE 'sk-[A-Za-z0-9_-]{20,}' -- ':!.github/scripts/secret_guard.sh'; then
  echo "::error::Possible API key committed (see lines above). Remove it and rotate the key."
  exit 1
fi
echo "No keys found."
