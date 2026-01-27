#!/usr/bin/env bash
set -euo pipefail

build_bar() {
	local percent=$1
	local length=12
	local filled=$((percent * length / 100))
	((filled > length)) && filled=$length
	local empty=$((length - filled))

	local bar=""
	for ((i = 0; i < filled; i++)); do
		bar+="█"
	done
	for ((i = 0; i < empty; i++)); do
		bar+="░"
	done

	printf "%s" "$bar"
}

# Ambil dari /proc/meminfo (lebih cepat dari free)
mem_total_kb=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
mem_avail_kb=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)

used_kb=$((mem_total_kb - mem_avail_kb))
pct=$(((100 * used_kb) / mem_total_kb))

state="Idle"
if ((pct >= 90)); then
	state="Critical"
elif ((pct >= 75)); then
	state="Warning"
fi

icon="memory_idle"
case "$state" in
	Warning)
		icon="memory_warning"
		;;
	Critical)
		icon="memory_critical"
		;;
esac

bar=$(build_bar "$pct")
printf '{"icon":"%s","state":"%s","text":"RAM %s%% %s"}\n' "$icon" "$state" "$pct" "$bar"
