#!/bin/bash
# XDG BaseDir Spec Organized split BASH configuration

# define XDG Variables if they aren't already set
[ "$XDG_DATA_HOME" ] || XDG_DATA_HOME="$HOME/.local/share"
[ "$XDG_CONFIG_HOME" ] || XDG_CONFIG_HOME="$HOME/.config"
[ "$XDG_CACHE_HOME" ] || XDG_CACHE_HOME="$HOME/.cache"
[ "$XDG_STATE_HOME" ] || XDG_STATE_HOME="$HOME/.local/state"

# Create XDG Directories if missing
[ -d "$XDG_DATA_HOME" ] || mkdir -p "$XDG_DATA_HOME"
[ -d "$XDG_CONFIG_HOME" ] || mkdir -p "$XDG_CONFIG_HOME"
[ -d "$XDG_CACHE_HOME" ] || mkdir -p "$XDG_CACHE_HOME"
[ -d "$XDG_STATE_HOME" ] || mkdir -p "$XDG_STATE_HOME"

# Create config directories if missing
[ -d "$XDG_CONFIG_HOME/bash/bashrc" ] || mkdir -p "$XDG_CONFIG_HOME/bash/bashrc"
[ -d "$XDG_CONFIG_HOME/bash/bash-completion" ] || mkdir -p "$XDG_CONFIG_HOME/bash/bash-completion"
[ -d "$XDG_DATA_HOME/bash" ] || mkdir -p "$XDG_DATA_HOME/bash"

# Relocate .bash_history to $XDG_DATA_HOME/bash/history
HISTFILE="$XDG_DATA_HOME/bash/history"

# Source executable .bashrc files in $XDG_CONFIG_HOME/
for bashrc_file in $XDG_CONFIG_HOME/bash/bashrc/*.bashrc; do
	[ -x "$bashrc_file" ] && source "$bashrc_file"
done

# Load System BASH Completions File
[ -r "/etc/bash_completion" ] && source /etc/bash_completion # System

# Source executable bash-completion scripts
for bash_completion_file in $XDG_CONFIG_HOME/bash/bash-completion/*.bashrc; do
	[ -x "$bash_completion_file" ] && source "$bash_completion_file"
done
