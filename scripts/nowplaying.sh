#!/usr/bin/env bash
set -euo pipefail

# Jika tidak ada player aktif, tampilkan kosong (atau "—")
if ! playerctl status >/dev/null 2>&1; then
	printf '{"icon":"music","state":"Idle","text":"—"}\n'
	exit 0
fi

status="$(playerctl status 2>/dev/null || true)"

artist="$(playerctl metadata artist 2>/dev/null || true)"
title="$(playerctl metadata title 2>/dev/null || true)"

text="—"
if [[ -n "${title}" && -n "${artist}" ]]; then
	text="${title} | ${artist}"
elif [[ -n "${title}" ]]; then
	text="${title}"
fi

state="Info"
[[ "${status}" == "Playing" ]] && state="Good"
[[ "${status}" == "Paused" ]] && state="Idle"

# potong biar gak kepanjangan
max=25
if ((${#text} > max)); then
	text="${text:0:max}…"
fi

# hapus newline yang bisa bikin JSON invalid
text="${text//$'\n'/ }"
text="${text//$'\r'/ }"

NOW_STATE="$state" NOW_TEXT="$text" python3 - <<'PY'
import json, os

payload = {
    "icon": "music",
    "state": os.environ["NOW_STATE"],
    "text": os.environ["NOW_TEXT"],
}
print(json.dumps(payload))
PY
