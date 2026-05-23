#!/usr/bin/env bash
set -euo pipefail

find_battery() {
	local supply
	for supply in /sys/class/power_supply/BAT*; do
		[[ -d "$supply" ]] || continue
		printf "%s\n" "$supply"
		return 0
	done
	return 1
}

if ! battery_path="$(find_battery)"; then
	printf '{"icon":"plug","state":"Idle","text":"AC"}\n'
	exit 0
fi

capacity="$(<"$battery_path/capacity")"
status="$(<"$battery_path/status")"

state="Idle"
if ((capacity <= 15)); then
	state="Critical"
elif ((capacity <= 35)); then
	state="Warning"
elif [[ "$status" == "Charging" ]]; then
	state="Good"
fi

icon="battery"
case "$status" in
	Charging)
		icon="bat_charging"
		;;
	Full)
		icon="bat"
		;;
	Discharging|Not\ charging|Unknown)
		icon="bat"
		;;
esac

printf '{"icon":"%s","state":"%s","text":"Bat %s%% %s"}\n' "$icon" "$state" "$capacity" "$status"
