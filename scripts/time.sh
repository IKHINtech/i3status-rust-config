#!/usr/bin/env bash
set -euo pipefail
printf '{"icon":"time","state":"Idle","text":"%s"}\n' "$(date '+%a %d/%m %H:%M:%S')"
