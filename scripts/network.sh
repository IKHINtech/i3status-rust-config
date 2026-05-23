#!/usr/bin/env bash
set -euo pipefail

get_default_interface() {
	while read -r iface destination _; do
		[[ "$destination" == "00000000" ]] || continue
		printf "%s\n" "$iface"
		return 0
	done </proc/net/route
	return 1
}

get_active_interface() {
	local path iface operstate carrier

	for path in /sys/class/net/*; do
		iface=$(basename "$path")
		[[ "$iface" == "lo" ]] && continue
		operstate="$(cat "$path/operstate" 2>/dev/null || printf "down")"
		carrier="$(cat "$path/carrier" 2>/dev/null || printf "0")"
		if [[ "$operstate" == "up" && "$carrier" == "1" ]]; then
			printf "%s\n" "$iface"
			return 0
		fi
	done

	return 1
}

get_ipv4_from_ip() {
	local iface=$1
	local line addr

	while read -r line; do
		case "$line" in
			"2: $iface "*)
				;;
			*" inet "*)
				addr=${line#* inet }
				addr=${addr%%/*}
				printf "%s\n" "$addr"
				return 0
				;;
		esac
	done < <(ip addr show dev "$iface" 2>/dev/null || true)
	return 1
}

iface="$(get_default_interface || true)"
if [[ -z "$iface" ]]; then
	iface="$(get_active_interface || true)"
fi

if [[ -z "$iface" ]]; then
	printf '{"icon":"net_down","state":"Critical","text":"Net offline"}\n'
	exit 0
fi

operstate="$(cat "/sys/class/net/$iface/operstate" 2>/dev/null || printf "down")"
carrier="$(cat "/sys/class/net/$iface/carrier" 2>/dev/null || printf "0")"

if [[ "$operstate" != "up" || "$carrier" != "1" ]]; then
	printf '{"icon":"net_down","state":"Critical","text":"Net %s down"}\n' "$iface"
	exit 0
fi

ssid=""
if [[ -d "/sys/class/net/$iface/wireless" ]]; then
	ssid="$(iwgetid -r 2>/dev/null || true)"
	[[ -z "$ssid" ]] && ssid="$(nmcli -t -f active,ssid dev wifi 2>/dev/null | awk -F: '$1=="yes" {print $2; exit}' || true)"
fi

ip_addr="$(get_ipv4_from_ip "$iface" || true)"
if [[ -z "$ip_addr" ]]; then
	ip_addr="$(hostname -I 2>/dev/null | awk '{print $1}' || true)"
fi

state="Idle"
icon="net_up"
label="$iface"

if [[ -n "$ssid" ]]; then
	label="$ssid"
fi

if [[ -z "$ip_addr" ]]; then
	state="Warning"
	printf '{"icon":"%s","state":"%s","text":"Net %s"}\n' "$icon" "$state" "$label"
else
	printf '{"icon":"%s","state":"%s","text":"Net %s %s"}\n' "$icon" "$state" "$label" "$ip_addr"
fi
