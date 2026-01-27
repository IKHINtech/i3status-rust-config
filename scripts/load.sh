#!/usr/bin/env bash
set -euo pipefail
read -r one five fifteen _ </proc/loadavg

# state sederhana
state="Idle"
# kalau 1-min load > 2.0 kasih Warning, > 4.0 Critical (silakan adjust)
awk -v v="$one" 'BEGIN{exit !(v>4.0)}' && state="Critical" || true
awk -v v="$one" 'BEGIN{exit !(v>2.0 && v<=4.0)}' && state="Warning" || true

printf '{"icon":"cogs","state":"%s","text":"%s %s %s"}\n' "$state" "$one" "$five" "$fifteen"
