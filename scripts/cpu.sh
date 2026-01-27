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

read_cpu() {
	# cpu  user nice system idle iowait irq softirq steal guest guest_nice
	read -r _ user nice system idle iowait irq softirq steal _ _ </proc/stat
	idle_all=$((idle + iowait))
	non_idle=$((user + nice + system + irq + softirq + steal))
	total=$((idle_all + non_idle))
	echo "$total $idle_all"
}

read -r total1 idle1 < <(read_cpu)
sleep 0.4
read -r total2 idle2 < <(read_cpu)

dt=$((total2 - total1))
di=$((idle2 - idle1))

usage=0
if ((dt > 0)); then
	usage=$(((100 * (dt - di)) / dt))
fi

state="Idle"
if ((usage >= 90)); then
	state="Critical"
elif ((usage >= 70)); then
	state="Warning"
fi

icon="cpu_idle"
case "$state" in
	Warning)
		icon="cpu_warning"
		;;
	Critical)
		icon="cpu_critical"
		;;
esac

bar=$(build_bar "$usage")
printf '{"icon":"%s","state":"%s","text":"CPU %s%% %s"}\n' "$icon" "$state" "$usage" "$bar"
