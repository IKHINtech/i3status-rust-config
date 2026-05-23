#!/usr/bin/env bash
set -euo pipefail

mountpoint="${1:-/}"

read -r _ total used available percent _ < <(df -hP "$mountpoint" | awk 'NR==2 {print $1, $2, $3, $4, $5, $6}')
usage=${percent%\%}

state="Idle"
if ((usage >= 90)); then
	state="Critical"
elif ((usage >= 75)); then
	state="Warning"
fi

printf '{"icon":"disk","state":"%s","text":"Disk %s %s free"}\n' "$state" "$percent" "$available"
