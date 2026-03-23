#!/bin/bash
# Single-line statusline: folder | branch | git status | progress bar | context % | cost | duration
#
# Context % uses Claude Code's pre-calculated remaining_percentage,
# which accounts for compaction reserves. 100% = compaction fires.

# Read stdin (Claude Code passes JSON data via stdin)
stdin_data=$(cat)

# Single jq call - extract all values at once
# Prefer pre-calculated remaining_percentage (100 - remaining = used toward compact)
# Fall back to manual calc from raw tokens if not available
IFS=$'\t' read -r current_dir cost duration_ms ctx_used cache_pct < <(
    echo "$stdin_data" | jq -r '[
        .workspace.current_dir // "unknown",
        (try (.cost.total_cost_usd // 0 | . * 100 + 0.5 | floor / 100 | tostring |
            if test("\\.") then
                if test("\\.[0-9]$") then . + "0" else . end
            else . + ".00" end
        ) catch "0.00"),
        (.cost.total_duration_ms // 0),
        (try (
            if (.context_window.remaining_percentage // null) != null then
                100 - (.context_window.remaining_percentage | floor)
            elif (.context_window.context_window_size // 0) > 0 then
                (((.context_window.current_usage.input_tokens // 0) +
                  (.context_window.current_usage.cache_creation_input_tokens // 0) +
                  (.context_window.current_usage.cache_read_input_tokens // 0)) * 100 /
                 .context_window.context_window_size) | floor
            else "null" end
        ) catch "null"),
        (try (
            (.context_window.current_usage // {}) |
            if (.input_tokens // 0) + (.cache_read_input_tokens // 0) > 0 then
                ((.cache_read_input_tokens // 0) * 100 /
                 ((.input_tokens // 0) + (.cache_read_input_tokens // 0))) | floor
            else 0 end
        ) catch 0)
    ] | @tsv'
)

# Bash-level fallback: if jq crashed entirely, extract fields individually
if [ -z "$current_dir" ]; then
    current_dir=$(echo "$stdin_data" | jq -r '.workspace.current_dir // .cwd // "unknown"' 2>/dev/null)
    cost=$(echo "$stdin_data" | jq -r '(.cost.total_cost_usd // 0)' 2>/dev/null)
    duration_ms=$(echo "$stdin_data" | jq -r '(.cost.total_duration_ms // 0)' 2>/dev/null)
    ctx_used=""
    cache_pct="0"
    : "${current_dir:=unknown}"
    : "${cost:=0}"
    : "${duration_ms:=0}"
fi

# Git info
GIT="git -c core.useBuiltinFSMonitor=false"
if cd "$current_dir" 2>/dev/null; then
    git_branch=$($GIT branch --show-current 2>/dev/null)
    git_root=$($GIT rev-parse --show-toplevel 2>/dev/null)

    # Get git status indicators
    if [ -n "$git_root" ]; then
        git_status=$($GIT status --porcelain 2>/dev/null)

        # Parse all status counts in a single awk pass
        read -r staged modified untracked < <(
            echo "$git_status" | awk '
                /^[MADRC]/ { staged++ }
                /^ M/ { modified++ }
                /^\?\?/ { untracked++ }
                END { print staged+0, modified+0, untracked+0 }
            '
        )

        # Check ahead/behind remote
        upstream=$($GIT rev-parse --abbrev-ref @{upstream} 2>/dev/null)
        if [ -n "$upstream" ]; then
            ahead=$($GIT rev-list --count @{upstream}..HEAD 2>/dev/null || echo "0")
            behind=$($GIT rev-list --count HEAD..@{upstream} 2>/dev/null || echo "0")
        else
            ahead="0"
            behind="0"
        fi
    fi
fi

# Build repo path display (folder name only for brevity)
if [ -n "$git_root" ]; then
    repo_name=$(basename "$git_root")
    if [ "$current_dir" = "$git_root" ]; then
        folder_name="$repo_name"
    else
        folder_name=$(basename "$current_dir")
    fi
else
    folder_name=$(basename "$current_dir")
fi

# Generate visual progress bar for context usage
progress_bar=""
bar_width=12

if [ -n "$ctx_used" ] && [ "$ctx_used" != "null" ]; then
    filled=$((ctx_used * bar_width / 100))
    empty=$((bar_width - filled))

    if [ "$ctx_used" -lt 50 ]; then
        bar_color='\033[32m'  # Green (0-49%)
    elif [ "$ctx_used" -lt 80 ]; then
        bar_color='\033[33m'  # Yellow (50-79%)
    else
        bar_color='\033[31m'  # Red (80-100%)
    fi

    progress_bar="${bar_color}"
    for ((i=0; i<filled; i++)); do
        progress_bar="${progress_bar}█"
    done
    progress_bar="${progress_bar}\033[2m"
    for ((i=0; i<empty; i++)); do
        progress_bar="${progress_bar}⣿"
    done
    progress_bar="${progress_bar}\033[0m"

    ctx_pct="${ctx_used}%"
else
    ctx_pct=""
fi

# Session time (human-readable)
if [ "$duration_ms" -gt 0 ] 2>/dev/null; then
    total_sec=$((duration_ms / 1000))
    hours=$((total_sec / 3600))
    minutes=$(((total_sec % 3600) / 60))
    seconds=$((total_sec % 60))
    if [ "$hours" -gt 0 ]; then
        session_time="${hours}h ${minutes}m"
    elif [ "$minutes" -gt 0 ]; then
        session_time="${minutes}m ${seconds}s"
    else
        session_time="${seconds}s"
    fi
else
    session_time=""
fi

# Separator
SEP='\033[2m│\033[0m'

# Build statusline: folder | branch | git status | metrics
line1=$(printf '\033[94m📁 %s\033[0m' "$folder_name")
if [ -n "$git_branch" ]; then
    line1="$line1 $(printf '%b \033[96m🌿 %s\033[0m' "$SEP" "$git_branch")"

    # Add git status indicators
    git_indicators=""
    if [ "${staged:-0}" -gt 0 ]; then
        git_indicators="$git_indicators $(printf '\033[32m+%s\033[0m' "$staged")"
    fi
    if [ "${modified:-0}" -gt 0 ]; then
        git_indicators="$git_indicators $(printf '\033[33m~%s\033[0m' "$modified")"
    fi
    if [ "${untracked:-0}" -gt 0 ]; then
        git_indicators="$git_indicators $(printf '\033[2m?%s\033[0m' "$untracked")"
    fi
    if [ "${ahead:-0}" -gt 0 ]; then
        git_indicators="$git_indicators $(printf '\033[35m↑%s\033[0m' "$ahead")"
    fi
    if [ "${behind:-0}" -gt 0 ]; then
        git_indicators="$git_indicators $(printf '\033[35m↓%s\033[0m' "$behind")"
    fi

    if [ -n "$git_indicators" ]; then
        line1="$line1$git_indicators"
    fi
fi

# Build metrics section
metrics=""
if [ -n "$progress_bar" ]; then
    metrics=" $progress_bar"
    [ -n "$ctx_pct" ] && metrics="$metrics $(printf '\033[37m%s\033[0m' "$ctx_pct")"
    metrics="$metrics $(printf '%b \033[33m$%s\033[0m' "$SEP" "$cost")"
else
    metrics=" $(printf '\033[33m$%s\033[0m' "$cost")"
fi
[ -n "$session_time" ] && metrics="$metrics $(printf '%b \033[36m⏱ %s\033[0m' "$SEP" "$session_time")"
[ "$cache_pct" -gt 0 ] 2>/dev/null && metrics="$metrics $(printf ' \033[2m↻%s%%\033[0m' "$cache_pct")"

printf '%b %b%b' "$line1" "$SEP" "$metrics"
