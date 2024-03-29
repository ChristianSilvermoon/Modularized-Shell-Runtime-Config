#!/bin/bash
# =========================================
# Modularized Shell Runtime Configuration
# GitHub: https://github.com/ChristianSilvermoon/Modularized-Shell-Runtime-Config
# =================================================================================
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
#
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <https://unlicense.org>
# =========================================
declare -gr BASH_MSRC_VERSION="23.12.28"
declare -gr BASH_MSRC_CORE="$BASH_SOURCE"
declare -gr BASH_MSRC_MD5=3a25377df47b6a21717b25bc1886b215

# Load System BASH Completions: Standard
[ -r "/etc/bash_completion" ] && source "/etc/bash_completion"

# Load System BASH Completions: Termux
[ -r "/data/data/com.termux/files/usr/share/bash-completion/bash_completion" ] && source "/data/data/com.termux/files/usr/share/bash-completion/bash_completion"

# MSRC Directory Setup
BASH_MSRC_DIR="${BASH_MSRC_DIR:="$HOME/.bashrc.d"}"
[ -d "$BASH_MSRC_DIR" ] || mkdir -p "$BASH_MSRC_DIR"

# BASH Completion
_msrc() {
	# Completion Script for msrc command
	local cur prev words cword f
	_init_completion || return

	if [ "$cword" = "1" ]; then
		COMPREPLY=($(
			compgen -W '-? -i -l -L -s -t -o -x -n -r -m -c -e +x -v -E -C -S -5 --help cd issue restart ls list source times order enable disable new rm remove mv rename check edit version editcore md5check' -- "$cur"
		))
		return
	fi

	case $prev in

		-c|-m|-e|-r|check|edit|mv|rm|remove|rename)
			local scripts=""

			for f in "$BASH_MSRC_DIR"/*.bashrc; do
				scripts+="$(basename "${f/%.bashrc/}") "
			done

			COMPREPLY=($(
				compgen -W "${scripts}" -- "$cur"
			))
			return

			;;
		-x|disable)
			local scripts=""

			for f in "$BASH_MSRC_DIR"/*.bashrc; do
				[ -x "$f" ] && scripts+="$(basename "${f%.bashrc}") "
			done

			COMPREPLY=($(
				compgen -W "${scripts}" -- "$cur"
			))
			return

			;;
		+x|enable)
			local scripts=""
			for f in "$BASH_MSRC_DIR"/*.bashrc; do
				[ ! -x "$f" ] && scripts+="$(basename "${f/%.bashrc/}") "
			done

			COMPREPLY=($(
				compgen -W "${scripts}" -- "$cur"
			))
			return

			;;
		-l|ls|list)
			COMPREPLY=($(
				compgen -W "--fancy" -- "$cur"
			))
			return
			;;
		md5check|-5)
			COMPREPLY=($(
				compgen -W "--only" -- "$cur"
			))
			return

			;;
		editcore|-E)
			COMPREPLY=($(
				compgen -W "--unsafe" -- "$cur"
			))
			return
			;;
		*)
			:
			return
			;;
	esac
} && complete -F _msrc msrc


# MSRC Function
msrc() {
	local -r MSRC_SRC="https://github.com/ChristianSilvermoon/Modularized-Shell-Runtime-Config"
	local -r MSRC_ISSUE_URL="https://github.com/ChristianSilvermoon/Modularized-Shell-Runtime-Config/issues"

	case "$1" in
		"md5check"|"-5")
			local match
			local BASH_MSRC_CMD5=$(
				shopt -s extglob
				mapfile -t bashrc < $BASH_MSRC_CORE
				for line in "${bashrc[@]}"; do
					line=${line/#+($'\t'| )} # Let's not count indentation, let users use whatever indentation they like :)

					# Ignore everything after the MSRC config loads
					[ "$line" = "} && readonly -f msrc && msrc -s # Prevent changes at runtime & load initial config" ] && break

					[[ $line =~ ^declare\ \-gr\ BASH_MSRC_MD5= ]] && continue # The intended MD5 cannot be factored into the MD5 check
					[[ $line =~ ^$ ]] && continue # We can ignore empty lines :)
					[[ $line =~ ^# ]] && continue # We can ignore comment lines :)
					finalrc+=( "$line" )
				done

				# Calculate & return md5sum of relevant BASHRC sections
				s=$(printf "%s\n" "${finalrc[@]}" | md5sum )
				printf "${s// *}"
			)

			[ "$BASH_MSRC_MD5" = "$BASH_MSRC_CMD5" ]
			match="$?"

			[ "$2" = "--only" ] && echo "$BASH_MSRC_CMD5" && return "$match"

			echo "MD5 Sum Check for: $BASH_MSRC_CORE"
			printf "  %-10s : %s\n" \
				"Correct" "$BASH_MSRC_MD5" \
				"Yours"   "${BASH_MSRC_CMD5}"

			if [ "$match" != "0" ]; then
				echo -e "\nRelevant portions of your primary BASHRC have been modified!"
				echo
				echo "To preserve the correct MD5, observe the following"
				printf "  %-10s : %s\n" \
					"Do Not"  "Alter end-line comments" \
					"Do Not"  "Alter any of the script's lines" \
					"Do Not"  "Alter the value of the \$BASH_MSRC_MD5" \
					"Do Not"  "Add anything before the MSRC Section" \
					"You May" "Add or Remove empty lines." \
					"You May" "Add or Remove Full Line Coments." \
					"You May" "Add or indentation in the form of SPACES or TABS" \
					"You May" "Add or remove things below the MSRC Section"
			fi

			return "$match"

			;;
		"new"|"-n")
			if [ "$(echo "$2" | grep ".bashrc$")" ]; then
				echo "The extension \".bashrc\" is automatically appended, please don't include it." 1>&2
				return 1
			elif [ "$(echo "$2" | grep "/")" ]; then
				echo "You cannot use \"/\" in file names." 1>&2
				return 1
			elif [ -e "$BASH_MSRC_DIR/$2.bashrc" ]; then
				echo "The file \"$2.bashrc\" already exists! Please specify a different name." 1>&2
				return 1
			elif [ ! "$EDITOR" ]||[ ! "$(command -v "$EDITOR")" ]; then
				echo "Ensure \"\$EDITOR\" is set to a valid command." 1>&2
				return 1
			else
				echo -e "#!/bin/bash\n# Description: New BASHRC" > "$BASH_MSRC_DIR/$2.bashrc"
				$EDITOR "$BASH_MSRC_DIR/$2.bashrc"
				echo "Remember to enable your new file!" 1>&2
				return 0
			fi
			;;
		"remove"|"rm"|"-r")
			if [ "$(echo "$2" | grep ".bashrc$")" ]; then
				echo "The extension \".bashrc\" is automatically appended, please don't include it." 1>&2
				return 1
			elif [ "$(echo "$2" | grep "/")" ]; then
				echo "You cannot use \"/\" in file names." 1>&2
				return 1
			elif [ ! -e "$BASH_MSRC_DIR/$2.bashrc" ]; then
				echo "The file \"$2.bashrc\" does not exist! Please specify a different name." 1>&2
				return 1
			else
				local yorn

				echo -n "Remove \"$2\" "
				[ -f "$BASH_MSRC_DIR/$2.config" ] && echo -n "and its associated config file? "
				echo -n "(Y/N*) "
				read -rsn1 yorn
				echo ""
				[ "${yorn,,}" = "y" ] || return

				rm -v "$BASH_MSRC_DIR/$2.bashrc"
				[ -f "$BASH_MSRC_DIR/$2.config" ] && rm -v "$BASH_MSRC_DIR/$2.config"
				return 0
			fi
			;;

		"rename"|"mv"|"-m")
			if [ "$(echo "$2" | grep ".bashrc$")" -o "$(echo "$3" | grep ".bashrc$")" ]; then
				echo "The extension \".bashrc\" is automatically appended, please don't include it." 1>&2
				return 1
			elif [ "$(echo "$2" | grep "/")" -o "$(echo "$3" | grep "/")" ]; then
				echo "You cannot use \"/\" in file names." 1>&2
				return 1
			elif [ ! -e "$BASH_MSRC_DIR/$2.bashrc" ]; then
				echo "The file \"$2.bashrc\" does not exist! Please specify a different name." 1>&2
				return 1
			else
				local yorn
				echo -n "Rename \"$2\" to \"$3\" (Y/N*) "
				read -rsn1 yorn
				echo ""

				# Prompt for confirmation
				[ "${yorn,,}" = "y" ] || return

				# Prompt for overwrite
				if [ -f "$3.bashrc" ]; then
					echo -n "File \"$3\" Already exists! Overwrite? (Y/N*) "
					read -rsn1 yorn
					echo ""
					[ "${yorn,,}" = "y" ]|| return
				fi

				# Move both the `.bashrc` and `.config` if it exists
				mv -v "$BASH_MSRC_DIR/$2.bashrc" "$BASH_MSRC_DIR/$3.bashrc"
				[ -f "$BASH_MSRC_DIR/$2.config" ] && mv -v "$BASH_MSRC_DIR/$2.config" "$BASH_MSRC_DIR/$3.config"
				return 0
			fi

			;;
		"editcore"|"-E")
			local content line file core noncore section=0 nsum pesum
			local endcomment="# Modularized Shell Runtime Config -- end"
			if [ ! "$EDITOR" ]||[ ! "$(command -v "$EDITOR")" ]; then
				echo "Ensure \"\$EDITOR\" is set to a valid command." 1>&2
				return 1
			fi

			if [ "$2" =  "--unsafe" ]; then
				echo "Directly editing: $BASH_MSRC_CORE"
				$EDITOR "$BASH_MSRC_CORE"
				if ! msrc -5 --only >/dev/null 2>&1; then
					echo "WARNING: MD5 Integrity Check was invalid!" 1>&2
					return 1
				fi
				return 0
			else
				echo "Protecting MSRC while editing: $BASH_MSRC_CORE"
				mapfile -t file < "$BASH_MSRC_CORE"

				for line in "${file[@]}"; do

					if [ "$section" = "0" ]; then
						# Seperate MSRC Core Section
						core+=( "$line" )
						[ "$line" = '} && readonly -f msrc && msrc -s # Prevent changes at runtime & load initial config' ] && section=1
						[ "$section" = "1" ] && core+=( "$endcomment" )
						continue
					else
						# Seperate After MSRC Section
						[ "$line" != "$endcomment" ] && noncore+=( "$line" ) # Don't include the seperator comment
						continue
					fi
				done

				printf "%s\n" "${noncore[@]}" > "${BASH_MSRC_CORE}.new"
				nsum=$(md5sum "$BASH_MSRC_CORE.new" ) # MD5 of New
				$EDITOR "${BASH_MSRC_CORE}.new"
				pesum=$(md5sum "${BASH_MSRC_CORE}.new" ) # MD5 after edit

				if [ "${nsum// *}" = "${pesum// *}" ]; then
					echo "No change, aborting."
					rm "${BASH_MSRC_CORE}.new"
					return
				else
					mv "$BASH_MSRC_CORE"{,.old} # Backup Old

					mapfile -t noncore < "${BASH_MSRC_CORE}.new"
					printf "%s\n" "${core[@]}" "${noncore[@]}" > "$BASH_MSRC_CORE"
					rm "${BASH_MSRC_CORE}.new"

					echo "Updated: $BASH_MSRC_CORE"
					echo "Restart BASH for changes to take effect."
				fi

			fi
			;;
		"edit"|"-e")

			if [ ! "$EDITOR" ]||[ ! "$(command -v "$EDITOR")" ]; then
				echo "Ensure \"\$EDITOR\" is set to a valid command." 1>&2
				return 1

			elif [ ! "$2" ]; then
				echo -e "\e[1mSelect a config file to edit:\e[22m"
				local editable_files=()
				local i

				for i in $BASH_MSRC_DIR/*.bashrc; do
					editable_files+=( "$(basename "${i%.bashrc}")" )
				done

				local PS3="$(echo -e "\e[1mEnter a #: \e[22m")"
				select i in "${editable_files[@]}"; do
					if [ "$i" ]; then
						$EDITOR "$BASH_MSRC_DIR/$i.bashrc"
						return 0
					else
						echo "No valid file was selected, aborting." 1>&2
						return 1
					fi
				done

				return 0
			elif [ "$(echo "$2" | grep ".bashrc$")" ]; then
				echo "The extension \".bashrc\" is automatically appended, please don't include it." 1>&2
				return 1

			elif [ "$(echo "$2" | grep "/")" ]; then
				echo "You cannot use \"/\" in file names." 1>&2
				return 1

			elif [ ! -e "$BASH_MSRC_DIR/$2.bashrc" ]; then
				echo "The file \"$2.bashrc\" does not exist! Please specify a different name." 1>&2
				return 1

			else
				$EDITOR "$BASH_MSRC_DIR/$2.bashrc"
				return 0
			fi
			;;
		"check"|"-c")
				if [ ! "$(command -v shellcheck)" ]; then
					echo "This feature requires shellcheck in \$PATH"
					return 1
				elif [ "$(echo "$2" | grep ".bashrc$")" ]; then
					echo "The extension \".bashrc\" is automatically appended, please don't include it." 1>&2
					return 1
				elif [ "$(echo "$2" | grep "/")" ]; then
					echo "You cannot use \"/\" in file names." 1>&2
					return 1
				elif [ ! -e "$BASH_MSRC_DIR/$2.bashrc" ]; then
					echo "The file \"$2.bashrc\" does not exist! Please specify a different name." 1>&2
					return 1
				else
					shellcheck -a --color=always --shell=bash "$BASH_MSRC_DIR/$2.bashrc"
					return $?
				fi
				;;
		"enable"|"+x")
			if [ -e "$BASH_MSRC_DIR/$2.bashrc" ]; then
				if [ ! -x "$BASH_MSRC_DIR/$2.bashrc" ]; then
					chmod +x "$BASH_MSRC_DIR/$2.bashrc"
					echo "Set \"$2.bashrc\" as executable" 1>&2
					return 0
				else
					echo "The bashrc file \"$2.bashrc\" is already executable." 1>&2
					return 1
				fi
			else
				echo "The bashrc file \"$2.bashrc\" does not exist." 1>&2
				return 1
			fi
			return 0
			;;

		"disable"|"-x")
			if [ -e "$BASH_MSRC_DIR/$2.bashrc" ]; then
				if [ -x "$BASH_MSRC_DIR/$2.bashrc" ]; then
					chmod -x "$BASH_MSRC_DIR/$2.bashrc"
					echo "Set \"$2.bashrc\" as non-executable" 1>&2
					return 0
				else
					echo "The bashrc file \"$2.bashrc\" is already not executable." 1>&2
					return 1
				fi
			else
				echo "The bashrc file \"$2.bashrc\" does not exist." 1>&2
				return 1
			fi
			return 0
			;;
		"list"|"ls"|"-l"|"-L")
			local x y
			local pBuffer=""
			local longestName=0
			local name
			local desc
			local descs=()
			local names=()

			if [ ! "$2" = "--fancy" ]&&[ "$1" != "-L" ]; then
				# Simpler List Format for lower end systems
				local dm
				local maxDescLength=9999
				local names=()
				local descs=()

				for x in $BASH_MSRC_DIR/*.bashrc; do
					if [ -x "$x" ]; then
						name=$(echo -en "\e[32;1m")
					else
						name=$(echo -en "\e[31;1m")
					fi

					y=${x/*\/}
					y=${y/%.bashrc}
					name+=$y
					mapfile -t dm < "$x"
					for desc in "${dm[@]}"; do
						[[ "$desc" =~ ^# ]] || continue
						if [[ "$desc" =~ ^#[[:blank:]]*(D|d)escription:[[:blank:]]* ]]; then
							desc=${desc#${BASH_REMATCH[0]}}
							break
						else
							desc=""
						fi
					done

					[ "$longestName" -lt "${#name}" ] && longestName=${#name}
					names+=( "$name" )

					descs+=( "$desc" )
				done
				longestName=$((longestName + 1))

				if [ -t 1 ]&&[ "$COLUMNS" ]; then
					maxDescLength=$((COLUMNS - longestName + 5))
				fi

				echo -en "\e[1m"
				pBuffer+=$(printf "%-$((longestName - 7))s %s" "NAME" "DESCRIPTION")$'\n'

				for ((x=0; x < ${#names[@]}; x++)); do
					pBuffer+=$(printf "%-${longestName}s %s" "${names[x]}" "${descs[x]:0:maxDescLength}")$'\n'
				done

				echo "$pBuffer"

				echo -en "\e[37;22m" 1>&2
				return 0
			fi

			local file=()
			local tdesc=""
			local tname=""
			local status=()
			local longestDesc=0
			local maxWidth="$COLUMNS"
			local truncPoint=""
			local tableWidth=""
			local tableTop=""
			local tableMid=""
			local tableBot=""

			# Get data on all files
			for x in $BASH_MSRC_DIR/*.bashrc; do
				tname=${x/*\/}
				tname=${tname/%.bashrc}

				mapfile -t dm < "$x"
				for tdesc in "${dm[@]}"; do
					[[ "$tdesc" =~ ^# ]] || continue
					if [[ "$tdesc" =~ ^#[[:blank:]]*(D|d)escription:[[:blank:]]* ]]; then
						tdesc="${tdesc#${BASH_REMATCH[0]}}"
						break
					else
						tdesc=""
					fi
				done

				[ "$longestName" -lt "${#tname}" ] && longestName="${#tname}"
				[ "$longestDesc" -lt "${#tdesc}" ] && longestDesc="${#tdesc}"

				name+=( "$tname" )
				desc+=( "$tdesc" )
				if [ -x "$x" ]; then
					# Green for Executable
					status+=( $(echo -ne "\e[32;1m") )
				else
					# Red for Not Executable
					status+=( $(echo -ne "\e[31;1m") )
				fi
			done

			# Set point at which to truncate descriptions
			truncPoint=$(( maxWidth - longestName - 10 ))

			# Calculate Table Width
			tableWidth="$((longestName + 5 + longestDesc))"
			[ "$tableWidth" -gt "$((maxWidth -2 ))" ] && tableWidth=$((maxWidth - 2))

			# Generate Table Parts
			tableTop+="╔"
			tableTop+="$(printf '%*s' $((longestName + 2)))"
			tableTop+="╦"
			tableTop+="$(printf '%*s' $(( tableWidth - longestName - 3 )))"
			tableTop+="╗"
			tableTop=${tableTop// /═}

			tableMid=${tableTop//╔/╠}
			tableMid=${tableMid//╦/╬}
			tableMid=${tableMid//╗/╣}

			tableBot=${tableTop//╔/╚}
			tableBot=${tableBot//╦/╩}
			tableBot=${tableBot//╗/╝}

			# Draw Table
			pBuffer+=$(echo -e "\e[37;1m$tableTop")$'\n'
			pBuffer+=$(printf "║ %-${longestName}s ║ %-$((tableWidth - longestName - 5))s ║\n" "Name" "Description")$'\n'
			pBuffer+=${tableMid}$'\n'

			# List Config Files and Descriptions
			for ((x=0; x < ${#name[@]}; x++)); do
				pBuffer+=$(echo -ne "\e[37;1m║ ${status[x]}")

				pBuffer+=$(printf "%-${longestName}s" "${name[x]}")
				pBuffer+=$(echo -ne "\e[37;1m ║ ${status[x]}")

				tdesc="${desc[x]:0:$truncPoint}"
				if [ "$tdesc" ]; then
					[ "${#desc[x]}" -ge "$truncPoint" ] && tdesc+="..."
					pBuffer+=$(printf "%-$((tableWidth - longestName - 5))s" "$tdesc")
				else
					pBuffer+=$(printf "%-$((tableWidth - longestName + 9))s" "$(echo -ne "\e[2;3mNo Description\e[22;23m")")
				fi

				pBuffer+=$(echo -en " \e[37;1m║")$'\n'
			done

			pBuffer+=${tableBot}
			echo "$pBuffer"
			echo -en "\e[0m"
			# End Table

			return 0
			;;
		"source"|"-s")
			# Source executable .bashrc files in $XDG_CONFIG_HOME/

			MSRC_LOAD_TIMES=""
			MSRC_LOAD_TIME_TOTAL=""

			local sloadtime
			local eloadtime

			if [ "$(command -v bc)" ]; then
				local tstime="$EPOCHREALTIME"
			else
				local tstime="$EPOCHSECONDS"
			fi

			local MSRC_FILE
			local MSRC_FILE_CONFIG
			for MSRC_FILE in $BASH_MSRC_DIR/*.bashrc; do
				# Skip Iteration if not executable
				[ ! -x "$MSRC_FILE" ] && continue

				# Store time before execution
				if [ "$(command -v bc)" ]; then
					sloadtime="$EPOCHREALTIME"
				else
					sloadtime="$EPOCHSECONDS"
				fi

				# Set variable MSRC_FILE_CONFIG for convenient access
				MSRC_FILE_CONFIG="${MSRC_FILE/%.bashrc/.config}"

				# Source if executable
				source "$MSRC_FILE"

				# Store time After Execution
				if [ "$(command -v bc)" ]; then
					eloadtime="$EPOCHREALTIME"
				else
					eloadtime="$EPOCHSECONDS"
				fi

				MSRC_LOAD_TIMES+="${sloadtime} ${eloadtime} ${MSRC_FILE}"$'\n'
			done

			# Store total load time
			if [ "$(command -v bc)" ]; then
				MSRC_LOAD_TIME_TOTAL="$(echo "$EPOCHREALTIME - $tstime" | bc)"
			else
				MSRC_LOAD_TIME_TOTAL="$(($EPOCHSECONDS - $tstime))"
			fi

			return 0
			;;

		"-S"|"restart")
			local jcount="$(jobs -p | wc -l)"
			if [ "$jcount" = "0" ]; then
				echo "Restarting Shell..." >&2
				exec bash
			else
				echo -e "Your shell has $jcount stopped job$([ "$jcount" = "1" ] || echo -ne 's').\nPlease \e[1mterminate\e[22m or \e[1mdisown\e[22m any jobs before restarting to avoid losing work.\nYou can see your jobs with \"jobs -l\"" 1>&2
				return 1
			fi
			;;
		"-C"|"cd")
			cd "$BASH_MSRC_DIR"
			;;
		"-t"|"times")
			echo -e "Total: ${MSRC_LOAD_TIME_TOTAL}s\n\n" 1>&2

			local OIFS=$IFS
			local IFS=$'\n'
			local list

			for f in $MSRC_LOAD_TIMES; do
				local stime=${f/ *}
				local etime="$(echo "$f" | cut -d ' ' -f 2)"
				local etime=${f#* }; etime=${etime%% *}
				local file="$(echo "$f" | cut -d ' ' -f 3-)"

				if [ "$(command -v bc)" ]; then
					list+="$(echo "$etime - $stime" | bc)s $file"$'\n'
				else
					list+="$((etime - stime))s $file"$'\n'
				fi
			done
			echo "$list" | sort -r
			;;
		"-o"|"order")
			echo "$MSRC_LOAD_TIMES" | cut -d ' ' -f 3-
			# Attempts at replacing cut in this case with internals-only are usually 1ms slower.
			;;
		"-v"|"version")
			echo "v$BASH_MSRC_VERSION $BASH_MSRC_MD5"
			;;
		"issue"|"-i")
			local OSRF
			local url="${MSRC_ISSUE_URL}/new?template=bug-report.yml&labels=bug%2Cneeds+review&template=bug-report.yml&title=[Bug]%3A+"
			local -A OSR
			local x
			local k
			local v
			local -A params

			# Get Distro Info
			if [ -f /etc/os-release ]; then
				mapfile -t OSRF </etc/os-release
				for x in "${OSRF[@]}"; do
					k="${x/%=*/}"
					v="${x/#*=/}"
					v="${v//\"/}"
					v="${v//\'/}"
					OSR["$k"]="$v"
				done

				params[platform]="${OSR[NAME]:-}${OSR[VERSION]:+ ${OSR[VERSION]}}"

			elif [ "$PREFIX" = "/data/data/com.termux/files/usr" ]; then
				# Special handling for Termux
				if [ "$(command -v getprop)" ]; then
					OSR[NAME]="Android"
					OSR[VERSION]=$(getprop ro.build.version.release)
				fi
				params[platform]="${OSR[NAME]:+${OSR[NAME]}${OSR[VERSION]:+ ${OSR[VERSION]}} + Termux${TERMUX_VERSION:+ $TERMUX_VERSION}}${TERMUX_APK_RELEASE:+ ($TERMUX_APK_RELEASE)}"
			fi

			params[shopts]="${BASHOPTS//:/$'\n'}"
			params[shell]="${BASH/#*\//} - $BASH_VERSION"
			params[system]="$(uname -spr)"

			# Attempt to Indetify C Library
			case "${BASH_VERSINFO[5]}" in
				*-gnu)
					params[libc]="GNU Libc"
					;;
				*-androideabi)
					params[libc]="Bionic Libc"
					;;
				*-musl)
					params[libc]="Musl Libc"
					;;
				*)
					params[libc]="Unknown Libc"
					;;
			esac
			params[libc]+=" (${BASH_VERSINFO[5]})"
			params[msrcver]="$BASH_MSRC_VERSION"
			params[md5]="$(msrc -5 --only)"

			# Special Thanks For URL Encoding
			#  * https://askubuntu.com/questions/53770/how-can-i-encode-and-decode-percent-encoded-strings-on-the-command-line#answer-295312
			#  * https://askubuntu.com/users/78223/kenorb
			#
			#  Question was asked by someone else; but the answer is very useful.
			for x in "${!params[@]}"; do
				k=
				for ((v = 0; v < ${#params[$x]}; v++)); do
					local c="${params[$x]:v:1}"
					case $c in
						[a-zA-Z0-9.~_-]) k+=$(printf "$c") ;;
						*) k+=$(printf '%%%02X' "'$c") ;;
					esac
				done

				url+="&$x=$k"

			done

			echo -e "\e[1mSystem Info\e[22m"
			printf "  \e[1m%-20s :\e[22m %s\n" \
				"MSRC Verison" "${params[msrcver]}" \
				"Correct MSRC MD5" "$BASH_MSRC_MD5" \
				"YOUR MSRC MD5" "${params[md5]}" \
				"Platform" "${params[platform]}" \
				"Shell" "${params[shell]}" \
				"C Library" "${params[libc]}" \
				"System Architecture" "${params[system]}" \
				"Shell Options" "${BASHOPTS//:/ }"

			echo -e "\n\e[1mYou can report your issue here:\e[22m"
			echo "$url"
			echo -e "\n\e[2;3mNote: This link will autofill fields of the Issue Report with your System Info\e[22;23m\n"

			if [ "$DISPLAY" ]&&[ "$(command -v xdg-open)" ]||[ "$(command -v termux-open-url)" ]; then
				local yorn
				echo -en "\e[1mOpen this link in your default browser now? (Y/N*) \e[22m"
				read -rn1 yorn
				echo ""
				if [ "${yorn,,}" = "y" ]; then
					echo -e "\e[2;3mOpening Link...\e[22;23m"
					$(command -v termux-open-url || command -v xdg-open || echo echo Cannot open ) "$url" 2>/dev/null
				fi
			fi

			;;
		"--help"|"-?")
			echo -e "\e[1mInfo:\e[0m"
			echo -e "MSRC - Modularized Shell Runtime Configuration"
			echo "$MSRC_SRC"
			echo -e "\n\e[1mUSAGE:\e[0m\nmsrc <options>\n"

			echo -e "\e[1mARGUMENTS:\e[0m"

			# Display Shellcheck, width details
			printf "  %-28s %s\n" "-c, check" "Check a config file with shellcheck"
			if [ ! "$(command -v shellcheck)" ]; then
				# Warn if shellcheck is missing
				echo -en "\e[31;2;3m"
				printf "  %-28s %s\n" '' "Note: \"shellcheck\" is not available in \$PATH!"
				echo -en "\e[22;23;37m"
			fi
			printf "  %-28s %s\n" "-C, cd" "cd to Config Path"

			# edit argument, with details
			printf "  %-28s %s" "-e, edit" "edit an existing config file using "
			if [ "$EDITOR" ]; then
				# warn if valid EDITOR or not
				[ "$(command -v $EDITOR)" ] && echo -ne "\e[32m" || echo -ne "\e[31m"
				echo -e "$EDITOR\e[31;2;3m"
				[ ! "$(command -v $EDITOR)" ] && printf "  %-30s %s\n\n" "" "note: \"$EDITOR\" isn't a valid command!"

			else
				# warn that $EDITOR isn't set
				echo -e "\e[35m\$EDITOR\e[31;2;3m"
				printf "  %-30s %s\n\n" "" "note: your \$EDITOR isn't set."

			fi
			echo -en "\e[22;23;37m"

			# editcore argument, with details
			printf "  %-28s %s" "-E, editcore [--unsafe]" "Safely edit main BASHRC file using "
			if [ "$EDITOR" ]; then
				# warn if valid EDITOR or not
				[ "$(command -v $EDITOR)" ] && echo -ne "\e[32m" || echo -ne "\e[31m"
				echo -e "$EDITOR\e[31;2;3m"
				[ ! "$(command -v $EDITOR)" ] && printf "  %-30s %s\n\n" "" "note: \"$EDITOR\" isn't a valid command!"

			else
				# warn that $EDITOR isn't set
				echo -e "\e[35m\$EDITOR\e[31;2;3m"
				printf "  %-30s %s\n\n" "" "note: your \$EDITOR isn't set."

			fi
			echo -en "\e[22;23;37m"

			printf "  %-28s %s\n" \
				"-i, issue"                   "Submit An Issue Report on GitHub" \
				"-l, ls, list [--fancy]"      "List config files, optionally with pretty border." \
				"-L"                          "Equivalent to 'msrc ls --fancy' (pretty border)." \
				"-m, mv, rename <old> <new>"  "Rename a config file" \
				"-n, new <file>"              "Create and edit new non-executable config file" \
				"-r, rm, remove <file>"       "Delete a config file" \
				"-s, source"                  "Source Executable config files from Config Path" \
				"-S, restart"                 "Restart Shell, potentially losing work" \
				"-t, times"                   "Print (Rough) Time It Took Sourcing Files" \
				"-v, version"                 "Print Version Information"

			if [ ! "$(command -v bc)" ]; then
				# Warn if bc is missing
				echo -en "\e[31;2;3m"
				printf "  %-28s %s\n" '' "Note: having \"bc\" GREATLY improves accuracy!"
				echo -en "\e[22;23;37m"
			fi

			printf "  %-28s %s\n" \
				"-o, order"             "Print Order each file was sourced" \
				"+x, enable <file>"     "Set a config file as executable" \
				"-x, disable <file>"    "Set a config file as non-executable" \
				"-5, md5check [--only]" "Check MSRC Integrity: $BASH_MSRC_CORE" \
				"-?, --help"            "Display this message"

			echo -e "\n\e[1mConfig Path:\e[0m\n$BASH_MSRC_DIR"
			echo -e "\e[2;3mNote: You can change this path by setting the value of \$BASH_MSRC_DIR\e[22;23m"

			return 0
			;;
		*)
			echo "Invalid Option: See \"msrc --help\"" 1>&2
			return 1
			;;
	esac

} && readonly -f msrc && msrc -s # Prevent changes at runtime & load initial config
# Modularized Shell Runtime Config -- end
