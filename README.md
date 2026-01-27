# i3status-rust configuration

This directory holds the custom `config.toml` for i3status-rust plus the helper scripts that power each status block.

## Theme & icons

- The theme is set to `srcery` with icon set `awesome6`.
- Custom icons override the default CPU and memory glyphs for each state so you get visual feedback even before reading the text: `cpu_idle`, `cpu_warning`, `cpu_critical`, `memory_idle`, `memory_warning`, `memory_critical`.

## Status blocks

Each `[[block]]` uses `json = true` and runs a script inside `scripts/`.

1. **Time** (`scripts/time.sh`): prints `Tue 27/01 08:07:57` style strings with seconds included.
2. **Now playing (MPRIS)** (`scripts/nowplaying.sh`): streams the current media via MPRIS (no changes in this repo).
3. **Load average** (`scripts/load.sh`): reports the system load (existing helper).
4. **CPU usage** (`scripts/cpu.sh`): samples `/proc/stat`, calculates usage, selects a state icon, and formats a 12-segment bar next to `CPU XX%`.
5. **Memory usage** (`scripts/mem.sh`): reads `/proc/meminfo`, computes used memory percent, selects the matching icon, and renders a 12-segment bar with `RAM XX%`.

## Scripts

- Scripts are POSIX-compatible Bash with `set -euo pipefail`.
- Each script prints a single JSON object with `icon`, `state`, and `text`.
- They are intended to be executable and called directly from `config.toml`.

## Testing & reload

1. Run any script manually, e.g. `bash scripts/cpu.sh`, to verify the JSON payload.
2. Reload i3status-rust (usually by restarting i3 or reloading the bar) to pick up changes.

## Customizing

- Update `config.toml` to add/remove blocks or adjust icon overrides.
- Tune thresholds inside `scripts/cpu.sh` and `scripts/mem.sh` if you want different warning/critical levels.
- Ensure any new script prints the same JSON shape so i3status-rust can parse it.
