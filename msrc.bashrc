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


# MSRC Directory Setup
[ "$BASH_MSRC_DIR" ] || export BASH_MSRC_DIR="$HOME/.bashrc.d"
[ -d "$BASH_MSRC_DIR" ] || mkdir -p "$BASH_MSRC_DIR" 

# BASH Completion
_msrc() {
	# Completion Script for msrc command
	local cur prev words cword f
	_init_completion || return

	if [ "$cword" = "1" ]; then
		COMPREPLY=($(
			compgen -W '-? -l -s -t -o -x -n -r -m -c -e +x -C -S --help cd restart ls list source times order enable disable new rm remove mv rename check edit' -- "$cur"
		))
		return
	fi

	case $prev in

		-c|check|-e|edit|-r|rm|remove)
			local scripts=""
			
			for f in "$BASH_MSRC_DIR"/*.bashrc; do
				scripts+="$(basename "$f" | sed 's/\.bashrc$//g') "
			done

			COMPREPLY=($(
				compgen -W "${scripts}" -- "$cur"
			))
			return

			;;
		-x|disable)
			local scripts=""
			
			for f in "$BASH_MSRC_DIR"/*.bashrc; do
				[ -x "$f" ] && scripts+="$(basename "$f" | sed 's/\.bashrc$//g') "
			done

			COMPREPLY=($(
				compgen -W "${scripts}" -- "$cur"
			))
			return

			;;
		+x|enable)
			local scripts=""
			for f in "$BASH_MSRC_DIR"/*.bashrc; do
				[ ! -x "$f" ] && scripts+="$(basename "$f" | sed 's/\.bashrc$//g') "
			done

			COMPREPLY=($(
				compgen -W "${scripts}" -- "$cur"
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
	case "$1" in
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
				echo -e "#!/bin/bash\n# New Bashrc\n" > "$BASH_MSRC_DIR/$2.bashrc"
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
				rm -iv "$BASH_MSRC_DIR/$2.bashrc"
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
				mv -iv "$BASH_MSRC_DIR/$2.bashrc" "$BASH_MSRC_DIR/$3.bashrc"
				return 0
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
					editable_files+=( "$(basename "$i" | sed 's/\.bashrc$//g')" )
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
		"list"|"ls"|"-l")
			ls --color=always -p "$BASH_MSRC_DIR" | grep -v "/$" | sed 's/\.bashrc//g'
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
			for MSRC_FILE in $BASH_MSRC_DIR/*.bashrc; do
				# Skip Iteration if not executable
				[ ! -x "$MSRC_FILE" ] && continue
				
				# Store time before execution
				if [ "$command -v bc" ]; then
					sloadtime="$EPOCHREALTIME"
				else
					sloadtime="$EPOCHSECONDS"
				fi

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
				local stime="$(echo "$f" | cut -d ' ' -f 1)"
				local etime="$(echo "$f" | cut -d ' ' -f 2)"
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
			;;
		"--help"|"-?")
			echo -e "\e[1mInfo:\e[0m"
			echo -e "MSRC - Modularized Shell Runtime Configuration"
			echo -e "https://github.com/ChristianSilvermoon/Modularized-Shell-Runtime-Config\n"
			echo -e "\e[1mUSAGE:\e[0m\nmsrc <options>\n"

			echo -e "\e[1mARGUMENTS:\e[0m"
		        printf "  %-28s %s\n" "-?, --help" "Display this message"
			printf "  %-28s %s\n" "-l, ls, list" "List config files"
			printf "  %-28s %s\n" "-s, source" "Source Executable config files from Config Path"
			printf "  %-28s %s\n" "-S, restart" "Restart Shell, potentially losing work"
			printf "  %-28s %s\n" "-t, times" "Print (Rough) Time It Took Sourcing Files"
			printf "  %-28s %s\n" "-o, order" "Print Order each file was sourced"
			printf "  %-28s %s\n" "+x, enable <file>" "Set a config file as executable"
			printf "  %-28s %s\n" "-x, disable <file>" "Set a config file as non-executable"
			printf "  %-28s %s\n" "-n, new <file>" "Create and edit new non-executable config file"
			printf "  %-28s %s\n" "-r, rm, remove <file>" "Delete a config file"
			printf "  %-28s %s\n" "-m, mv, rename <old> <new>" "Rename a config file"
			printf "  %-28s %s\n" "-c, check" "Check a config file with shellcheck"
			printf "  %-28s %s\n" "-C, cd" "cd to Config Path"
			
			printf "  %-28s %s\n" "-e, edit" "Edit an existing config file using \$EDITOR"

			echo -e "\n\e[1mConfig Path:\e[0m\n$BASH_MSRC_DIR"

			return 0
			;;
		*)
			echo "Invalid Option: See \"msrc --help\"" 1>&2
			return 1
			;;
	esac

}

msrc -s

# Load System BASH Completions: Standard
[ -r "/etc/bash_completion" ] && source "/etc/bash_completion"

# Load System BASH Completions: Termux
[ -r "/data/data/com.termux/files/usr/share/bash-completion/bash_completion" ] && source "/data/data/com.termux/files/usr/share/bash-completion/bash_completion"
