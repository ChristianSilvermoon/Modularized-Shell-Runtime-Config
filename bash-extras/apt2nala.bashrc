#!/bin/bash
# Automatically substitute apt commands with nala variants
# Will also automatically use sudo when needed.

if [ "$(command -v "apt")" ]&&[ "$(command -v nala)" ]; then
	# Only if both apt and nala are present on system.

	apt() {
		# If pipe, fall back to real apt.
		if [ ! -t 1 ]; then
			command apt "$@"
			return
		fi

		# Substitute apt with nala when arguments are compatible.
		case $1 in
			install|remove|purge|search|history|show)
				echo -e "\e[2;3mNote: Substituting \"apt\" for \"nala\" instead.\e[22;23m" 2>&1
				sudo nala "$@" --no-update
				;;
			autoclean)
				echo -e "\e[2;3mNote: Substituting \"apt\" for \"nala\" instead.\e[22;23m" 2>&1
				sudo nala clean
				;;
			list)
				if [ "$2" = "--installed" ]; then
					echo -e "\e[2;3mNote: Substituting \"apt\" for \"nala\" instead.\e[22;23m" 2>&1
					nala search . --installed
				elif [ "$2" = "--upgradable" ]; then
					command apt list --upgradable
				else
					echo -e "\e[2;3mNote: Substituting \"apt\" for \"nala\" instead.\e[22;23m" 2>&1
					nala search .
				fi
				;;
			update)
				echo -e "\e[2;3mNote: Substituting \"apt\" for \"nala\" instead.\e[22;23m" 2>&1
				sudo nala --update
				;;
			upgrade)
				echo -e "\e[2;3mNote: Substituting \"apt\" for \"nala\" instead.\e[22;23m" 2>&1
				sudo nala update --no-update
				;;
			*)
				# Automatically fall back to real apt (no auto-sudo)
				command apt "$@"
			;;
		esac
	}
fi
