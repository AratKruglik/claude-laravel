#!/usr/bin/env bash
set -euo pipefail

input="$(cat)"
url="$(jq -r '.tool_input.url // empty' <<< "$input")"

if [[ -z "$url" ]]; then
    exit 0
fi

if [[ ! "$url" =~ ^https?:// ]]; then
    exit 0
fi

if [[ "$url" =~ ^https?://[^/?#]*@ ]]; then
    exit 0
fi

if [[ "$url" =~ ^https?://([^/?#:]+) ]]; then
    host="${BASH_REMATCH[1],,}"

    case "$host" in
        r.jina.ai|localhost|127.*|0.0.0.0|10.*|192.168.*|169.254.*|*.local)
            exit 0
            ;;
    esac

    if [[ "$host" =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\. ]]; then
        exit 0
    fi
else
    exit 0
fi

rewritten_url="https://r.jina.ai/$url"

jq --arg rewritten_url "$rewritten_url" '
    .tool_input.url = $rewritten_url
    | {
        hookSpecificOutput: {
            hookEventName: "PreToolUse",
            permissionDecision: "allow",
            permissionDecisionReason: "WebFetch URL rewritten through Jina Reader to reduce token usage.",
            updatedInput: .tool_input
        }
    }
' <<< "$input"
