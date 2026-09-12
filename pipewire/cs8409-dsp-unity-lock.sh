#!/bin/bash
# Keep the DSP sink at full scale. Omarchy volume keys resolve through it to
# analog-surround-40 (see omarchy-audio-output-sink). Locking that physical
# node (or ALSA PCM) freezes the Touch Bar fader.
set -euo pipefail
DSP=cs8409_speakers

at_unity() {
	local percentages volume
	volume=$(pactl get-sink-volume "$DSP" 2>/dev/null) || return 1
	percentages=$(printf '%s\n' "$volume" | grep -oE '[0-9]+%' | sort -u)
	[ "$percentages" = "100%" ]
}

lock() {
	at_unity || pactl set-sink-volume "$DSP" 100% >/dev/null 2>&1 || true
}

lock
pactl subscribe 2>/dev/null | while read -r event; do
	case "$event" in
		"Event 'new' on sink #"* | "Event 'change' on sink #"*) lock ;;
	esac
done
