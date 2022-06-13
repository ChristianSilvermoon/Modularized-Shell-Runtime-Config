#!/bin/bash
# Description: Makes 'cd' super with history (directory stack), bookmarks, and improved ascension

# Ensure $CD_BKM Associative Array exists
[ -v CD_BKM ] || declare -gA CD_BKM

# Modify CD behavior
cd() {
	if [ "${1:0:1}" = "%" ] && [ ! -e "$1" ]; then
		cd -f "${1:1}"
		return "$?"
	fi

	case $1 in
		-f)
			if [ ! "$2" ]; then
				# FZF or Select if possible
				local list
				local x
				local length=0
				local selection


				# Build Pretty List for fzf & select
				for x in "${!CD_BKM[@]}"; do
						[ "${#x}" -gt "$length" ] && length="${#x}"
				done

				for x in "${!CD_BKM[@]}"; do
					list+="$(printf "%-$((length))s  %s" "${x}" "${CD_BKM[$x]}")"$'\n'
				done
				
				if [ "$(command -v fzf)" ]; then
					# Fuzzy Finder is present
					selection="$(echo -n "$list" | fzf --header "Select Bookmark To Navigate To [CTRL+C To Cancel]" | cut -d' ' -f 1)"

					if [ "$selection" ]; then
						cd -f "$selection"
					else
						echo -e "\e[2;3mCanceled...\e[22;23m" 1>&2
					fi
				else
					# Fallback on BASH Select
					local PS3="$(echo -en "\e[1mSelect Bookmark To Navigate To [CTRL+C To Cancel]: \e[22m")"
					
					local IFS=$'\n'
					select selection in $list; do
						if [ "$selection" ]; then
							cd -f "$(echo "$selection" | cut -d' ' -f 1)"
						else
							echo -e "\e[2;3mCanceled...\e[22;23m" 1>&2
						fi
						break
					done
				fi

			elif [ "${CD_BKM[$2]}" ]; then
				# Navigate to bookmark
				cd -- "${CD_BKM[$2]}"
			else
				echo "No such bookmark: $2"
				return 1
			fi
			;;
		-F)
			if [ ! "$2" ]; then
				local x
				(
				echo -e "\e[1mFavorites/Bookmarks List:\e[22m\n"
				for x in "${!CD_BKM[@]}"; do
					[ "${CD_BKM[$x]}" = "$PWD" ] && echo -en "\e[32m"
					[ -d "${CD_BKM[$x]}" ] || echo -en "\e[31m"
					printf "  \e[1m%s\e[22;37m\n    %s\n\n" "$x" "${CD_BKM[$x]}"
				done
				) | less -rF
				return
			elif [ "${CD_BKM[$2]}" ]; then
				echo "${CD_BKM[$2]}"
			else
				echo "No such bookmark: $2" 1>&2
				return 1
			fi
			;;
		-d)
			local list="$(dirs -p -l | sort -u)"
			local x
			local selection


			if [ "$(command -v fzf)" ]; then
				# Fuzzy Finder is present
				selection="$(echo -n "$list" | fzf --header "Select Directory To Navigate To [CTRL+C To Cancel]")"

				if [ "$selection" ]; then
					cd "$selection"
				else
					echo -e "\e[2;3mCanceled...\e[22;23m" 1>&2
				fi
			else
				# Fallback on BASH Select
				local PS3="$(echo -en "\e[1mSelect Directory To Navigate To [CTRL+C To Cancel]: \e[22m")"

				local IFS=$'\n'
				select selection in $list; do
					if [ "$selection" ]; then
						cd "$selection"
					else
						echo -e "\e[2;3mCanceled...\e[22;23m" 1>&2
					fi
					break
				done
			fi
			;;	
		-b)
			if [ ! "$(command -v bd)" ]; then
				echo "BD isn't in \$PATH!" 1>&2
				return 1
			fi
			shift
			cd -- "$(bd "$@")"
			;;
		-m)
			local name
			local b

			if [ ! "$2" ]; then
				for b in "${!CD_BKM[@]}"; do
					if [ "${CD_BKM[$b]}" = "$PWD" ]; then
						name="$b"
						break
					fi
				done

				if [ ! "$name" ]; then
					echo "Current directory is not bookmarked." 1>&2
					return 1
				fi
			else
				name="$2"
			fi

			if [ "${CD_BKM[$name]}" ]; then
				echo "Removed Bookmark: $name" 1>&2
				unset CD_BKM[$name]
			else
				echo "No Such Bookmark: $name" 1>&2
				return 1
			fi
			;;
		+m)
			local bookmark="$2"
			local dir

			if [ ! "$bookmark" ]; then
				echo "You MUST specify a bookmark name" 1>&2
				return 1
			fi

			if [ "$(echo "$bookmark" | grep " " | grep "%")" ]; then
				echo "Bookmark name must not contain spaces or %s" 1>&2
				return 1
			fi

			[ "$3" ] && dir="$3" || dir="$PWD"

			CD_BKM[$bookmark]="$dir"
			echo "Bookmarked \"${dir}\" as \"${bookmark}\""
			;;	
		-r)
			cd "$(stat -c %m ./)"
			;;
		-R)
			local IFS=$'\n'
			local line
			local bookmark
			local dir

			if [ ! "$CD_BKM_FILE" ]; then
				echo "Error: \$CD_BKM_FILE is not set." 1>&2
				return 1
			elif [ ! -r "$CD_BKM_FILE" ]; then
				echo "Error: Could not read \"$CD_BKM_FILE\"" 1>&2
				return 1
			fi

			for line in $(cat "$CD_BKM_FILE" | grep -v "^$" | grep -v "^#"); do
				bookmark=$(echo "$line" | cut -d' ' -f 1)
				dir=$(echo "$line" | cut -d' ' -f 2-)

				CD_BKM[$bookmark]="$dir"
			done

			;;
		-s)
			if [ ! "$CD_BKM_FILE" ]; then
				echo "Error: \$CD_BKM_FILE is not set." 1>&2
				return 1
			fi

			local b
			local bkms=$(
				for b in "${!CD_BKM[@]}"; do
					echo "$b ${CD_BKM[$b]}"
				done
			)
			echo "$bkms" > "$CD_BKM_FILE"
			echo "Wrote Bookmarks To $CD_BKM_FILE"
			;;
		-u)
			local IFS='/'
			local toasc
			local dirs=()
			local numtest='^[0-9]+$'
			local x

			[ "$2" ] && toasc="$2" || toasc=1

			if ! [[ $toasc =~ $numtest ]]; then
				echo "\"$2\" is not a numeric value!" 1>&2
				return 1
			fi


			for x in $PWD; do
				[ "$x" ] && dirs+=( "$x" )
			done

			if [ "$toasc" -gt "${#dirs[@]}" ]; then
				echo "$toasc is too high; you can go up ${#dirs[@]} at most." 1>&2
				return 1
			fi
			
			for ((x=0; $x < $toasc; x++)); do
				builtin cd ..
			done
			pushd "$PWD" > /dev/null

			;;
		"..")
			if [ "$2" ]; then
				cd -u "$2"
			else
				builtin cd .. && pushd "$PWD" > /dev/null
			fi

			;;
		"-?"|"--help")
			builtin cd --help

			echo -e "\n    Super CD Options:"

			printf "      %-17s %s\n" "-b" "Navigate using \"bd\" instead"
			if [ ! "$(command -v bd)" ]; then
				printf "      %-17s %s\n" "" "  unavailable: \"bd\" isn't in \$PATH!"
			fi
			printf "      %-17s %s\n" "-d" "Select a directory from the Directory Stack"
			printf "      %-17s %s\n" "-f [bookmark]" "Select and/or navigate to bookmark"
			printf "      %-17s %s\n" "" "  OR \"cd %bookmark\" if no dir named \"%bookmark\" exists!"
			printf "      %-17s %s\n" "-F [bookmark]" "Print bookmark list or path"
			printf "      %-17s %s\n" "+m <name> [dir]" "Add Bookmark to \$CD_BKM"
			printf "      %-17s %s\n" "-m <name>" "Remove Bookmark from \$CD_BKM"
			printf "      %-17s %s\n" "-r" "Ascend to root of the current filesystem/subvolume."
			printf "      %-17s %s\n" "-R" "Read bookmarks from \$CD_BKM_FILE"
			printf "      %-17s %s\n" "-s" "Save bookmarks to \$CD_BKM_FILE"
			printf "      %-17s %s\n" "-u, .. [integer]" "Ascend 1 directory (or more)"
			printf "      %-17s %s\n" "-?, --help" "Display these help messages."

			printf "\n    Super CD Notes:\n" 
			printf "      * History is tracked using the Directory Stack\n"
			printf "      * Bookmarks are tracked using \$CD_BKM (An Associative Array)\n"
			printf "      * Bookmarks are read/saved from/to the file defined by \$CD_BKM_FILE\n"
			printf "      * Will auto prompt for creation of non-existent directories\n"
				
				
			printf "\n    Bookmark File (\$CD_BKM_FILE):\n"
			if [ "$CD_BKM_FILE" ]; then
				printf "      $CD_BKM_FILE\n"
			else
				echo -e "      \e[5mNot Set\e[25m"
			fi

			;;
		*)
			local dir
			local yorn
			local nargproc

			for x; do
				[ "$x" = "--" ] && nargproc=1
				[ ! "$nargproc" ] && [[ $x =~ ^-(L|P|e|@)$ ]] && continue
				dir="$x"
			done

			# Offer to create directory if it doesn't exist
			if [ "$dir" ]&&[ ! -e "$dir" ]; then
				# Find at what point the directory does not exist
				local bpath
				local gpath
				local dcount=0
				local IFS='/'
				
				for x in $dir; do
					dcount="$((dcount + 1))"
					if [ -d "${gpath}/$x" ]; then
						gpath+="$x/"
					else
						bpath="$(echo "$dir" | cut -d '/' -f ${dcount}-)/"
						break
					fi

				done
				
				echo -e "Directory does not exist: \e[1;32m${gpath}\e[31m${bpath}\e[22;37m"
				tput sc
				echo -n "Do you want to create it? [Y/N*] "
				read -rsn1 yorn
				tput rc

				if [ "${yorn,,}" = "y" ]; then
					mkdir -p "$dir" || return "$?"
					echo -e "Created Directory: \e[2;1m${gpath}\e[22;1;36m${bpath}\e[22;37m"
				else
					echo "Directory not created & Directory Change aborted"
					return 1
				fi
			fi

			builtin cd "$@"
			[ "$OLDPWD" != "$PWD" ] && pushd "$PWD" >/dev/null
			;;
	esac
}

# Set/Read bookmarks file 
[ "$CD_BKM_FILE" ] || CD_BKM_FILE="$HOME/.super-cd-bookmarks"
[ -r "$CD_BKM_FILE" ] && cd -R 2>/dev/null

# Initialize some good default bookmarks if non are present
if [ ! "${CD_BKM[*]}" ]; then
	[ "$TMPDIR" ] && CD_BKM["tmp"]="$TMPDIR"
	[ -d "$HOME/Pictures" ] && CD_BKM["pics"]="$HOME/Pictures"
	[ -d "$HOME/Music" ] && CD_BKM["music"]="$HOME/Music"
	[ -d "$HOME/Documents" ] && CD_BKM["docs"]="$HOME/Documents"
	[ -d "$HOME/Desktop" ] && CD_BKM["desk"]="$HOME/Desktop"
	[ -d "$HOME/Downloads" ] && CD_BKM["dl"]="$HOME/Downloads"
	[ -d "$HOME/.local/bin" ] && CD_BKM["my-bin"]="$HOME/.local/bin"
fi

# Push current directory onto Directory Stack!
pushd "$PWD" > /dev/null
