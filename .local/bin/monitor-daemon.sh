#!/usr/bin/env bash

set -euo pipefail

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
HANDLER="monitor-reload.sh"

$HANDLER &

while [[ ! -S "$SOCKET" ]]; do
    sleep 0.2
done

socat -u UNIX-CONNECT:"$SOCKET" - | while read -r event; do
    case "$event" in
        monitoradded*|monitorremoved*)
			pkill -f "$HANDLER" 2>/dev/null || true
			"$HANDLER" &
            ;;
    esac
done
