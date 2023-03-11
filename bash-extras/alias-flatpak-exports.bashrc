#!/bin/bash
# Description: Alias all flatpaks to their logical command names, but only if they're not already commands.

local item
for item in {${XDG_DATA_HOME:-$HOME/.local/share},/var/lib}/flatpak/exports/bin/*; do
	[ -x "$item" ] || continue

	local flatpak_short_alias="${item//*.}"
	local flatpak_long_alias="${item//*\/}"
	
	if [ ! "$(command -v "$flatpak_short_alias")" ]; then
		alias "${flatpak_short_alias,,}"="$item"
	elif [ ! "$(command -v "$flatpak_long_alias")" ]; then
		alias "$flatpak_long_alias"="$item"
	fi
done
