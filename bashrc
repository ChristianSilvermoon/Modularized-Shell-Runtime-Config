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

_bashrc() {
	# Completion Script for bashrc command
	local cur prev words cword
	local config_dir="$XDG_CONFIG_HOME/bash/bashrc"
	_init_completion || return

	#echo ""
	#echo "cur: $cur"
	#echo "prev: $prev"
	#echo "words: $words"
	#echo "cword: $cword"

	if [ "$cword" = "1" ]; then
		COMPREPLY=($(
			compgen -W '-? -l -s -t -o -x -n -r -m -c -e +x -C -S --help cd restart ls list source times order enable disable new rm remove mv rename check edit' -- "$cur"
		))
		return
	fi

	case $prev in

		-c|check|-e|edit|-r|rm|remove)
			local scripts=""
			
			for f in "$config_dir"/*.bashrc; do
				scripts+="$(basename "$f" | sed 's/\.bashrc$//g') "
			done

			COMPREPLY=($(
				compgen -W "${scripts}" -- "$cur"
			))
			return

			;;
		-x|disable)
			local scripts=""
			
			for f in "$config_dir"/*.bashrc; do
				[ -x "$f" ] && scripts+="$(basename "$f" | sed 's/\.bashrc$//g') "
			done

			COMPREPLY=($(
				compgen -W "${scripts}" -- "$cur"
			))
			return

			;;
		+x|enable)
			local scripts=""
			for f in "$config_dir"/*.bashrc; do
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
} && complete -F _bashrc bashrc



bashrc() {
	local config_dir="$XDG_CONFIG_HOME/bash/bashrc"

	case "$1" in
		"new"|"-n")
			if [ "$(echo "$2" | grep ".bashrc$")" ]; then
				echo "The extension \".bashrc\" is automatically appended, please don't include it." 1>&2
				return 1
			elif [ "$(echo "$2" | grep "/")" ]; then
				echo "You cannot use \"/\" in file names." 1>&2
				return 1
			elif [ -e "$config_dir/$2.bashrc" ]; then
				echo "The file \"$2.bashrc\" already exists! Please specify a different name." 1>&2
				return 1
			elif [ ! "$EDITOR" ]||[ ! "$(command -v "$EDITOR")" ]; then
				echo "Ensure \"\$EDITOR\" is set to a valid command." 1>&2
				return 1
			else
				echo -e "#!/bin/bash\n# New Bashrc\n" > "$config_dir/$2.bashrc"
				$EDITOR "$config_dir/$2.bashrc"
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
			elif [ ! -e "$config_dir/$2.bashrc" ]; then
				echo "The file \"$2.bashrc\" does not exist! Please specify a different name." 1>&2
				return 1
			else
				rm -iv "$config_dir/$2.bashrc"
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
			elif [ ! -e "$config_dir/$2.bashrc" ]; then
				echo "The file \"$2.bashrc\" does not exist! Please specify a different name." 1>&2
				return 1
			else
				mv -iv "$config_dir/$2.bashrc" "$config_dir/$3.bashrc"
				return 0
			fi
			
			;;
		"edit"|"-e")
			if [ "$(echo "$2" | grep ".bashrc$")" ]; then
				echo "The extension \".bashrc\" is automatically appended, please don't include it." 1>&2
				return 1
			elif [ "$(echo "$2" | grep "/")" ]; then
				echo "You cannot use \"/\" in file names." 1>&2
				return 1
			elif [ ! -e "$config_dir/$2.bashrc" ]; then
				echo "The file \"$2.bashrc\" does not exist! Please specify a different name." 1>&2
				return 1
			elif [ ! "$EDITOR" ]||[ ! "$(command -v "$EDITOR")" ]; then
				echo "Ensure \"\$EDITOR\" is set to a valid command." 1>&2
				return 1
			else
				$EDITOR "$config_dir/$2.bashrc"
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
				elif [ ! -e "$config_dir/$2.bashrc" ]; then
					echo "The file \"$2.bashrc\" does not exist! Please specify a different name." 1>&2
					return 1
				else
					shellcheck -a --color=always --shell=bash "$config_dir/$2.bashrc"
					return $?	
				fi
				;;
		"enable"|"+x")
			if [ -e "$config_dir/$2.bashrc" ]; then
				if [ ! -x "$config_dir/$2.bashrc" ]; then
					chmod +x "$config_dir/$2.bashrc"
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
			if [ -e "$config_dir/$2.bashrc" ]; then
				if [ -x "$config_dir/$2.bashrc" ]; then
					chmod -x "$config_dir/$2.bashrc"
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
			ls --color=always -p "$config_dir" | grep -v "/$" | sed 's/\.bashrc//g'
			return 0
			;;
		"source"|"-s")
			# Source executable .bashrc files in $XDG_CONFIG_HOME/
			
			BASHRC_LOAD_TIMES=""
			BASHRC_LOAD_TIME_TOTAL=""
			
			local sloadtime
			local eloadtime
			
			if [ "$(command -v bc)" ]; then
				local tstime="$EPOCHREALTIME"
			else
				local tstime="$EPOCHSECONDS"
			fi

			for bashrc_file in $XDG_CONFIG_HOME/bash/bashrc/*.bashrc; do
				# Skip Iteration if not executable
				[ ! -x "$bashrc_file" ] && continue
				
				# Store time before execution
				if [ "$command -v bc" ]; then
					sloadtime="$EPOCHREALTIME"
				else
					sloadtime="$EPOCHSECONDS"
				fi

				# Source if executable
				source "$bashrc_file"
		
				# Store time After Execution
				if [ "$(command -v bc)" ]; then
					eloadtime="$EPOCHREALTIME"
				else
					eloadtime="$EPOCHSECONDS"
				fi

				BASHRC_LOAD_TIMES+="${sloadtime} ${eloadtime} ${bashrc_file}"$'\n'
			done

			# Store total load time	
			if [ "$(command -v bc)" ]; then
				BASHRC_LOAD_TIME_TOTAL="$(echo "$EPOCHREALTIME - $tstime" | bc)"
			else
				BASHRC_LOAD_TIME_TOTAL="$(($EPOCHSECONDS - $tstime))"
			fi

			return 0
			;;

		"-S"|"restart")
			echo "Restarting Shell..." >&2
			exec bash
			return
			;;
		"-C"|"cd")
			cd "$XDG_CONFIG_HOME/bash/bashrc"
			;;
		"-t"|"times")
			echo -e "Total: ${BASHRC_LOAD_TIME_TOTAL}s\n\n" 1>&2
		
			local OIFS=$IFS
			local IFS=$'\n'
			local list

			for f in $BASHRC_LOAD_TIMES; do
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
			echo "$BASHRC_LOAD_TIMES" | cut -d ' ' -f 3-
			;;
		"--help"|"-?")
			echo -e "\e[1mInfo:\e[0m"
			echo -e "XDG BaseDir Spec based mutliple custom BASHRC File Management System"
			echo -e "https://github.com/ChristianSilvermoon/custom-multi-bashrc\n"
			echo -e "\e[1mUSAGE:\e[0m\nbashrc <options>\n"

			echo -e "\e[1mARGUMENTS:\e[0m"
		        printf "  %-28s %s\n" "-?, --help" "Display this message"
			printf "  %-28s %s\n" "-l, ls, list" "List config files"
			printf "  %-28s %s\n" "-s, source" "Source Executable bashrc files from Config Path"
			printf "  %-28s %s\n" "-S, restart" "Restart Shell, potentially losing work"
			printf "  %-28s %s\n" "-t, times" "Print Bashrc (Rough) Bashrc Execution Times"
			printf "  %-28s %s\n" "-o, order" "Print Order each file was sourced"
			printf "  %-28s %s\n" "+x, enable <file>" "Set a config file as executable"
			printf "  %-28s %s\n" "-x, disable <file>" "Set a config file as non-executable"
			printf "  %-28s %s\n" "-n, new <file>" "Create and edit new non-executable config file"
			printf "  %-28s %s\n" "-r, rm, remove <file>" "Delete a config file"
			printf "  %-28s %s\n" "-m, mv, rename <old> <new>" "Rename a config file"
			printf "  %-28s %s\n" "-c, check" "Check a config file with shellcheck"
			printf "  %-28s %s\n" "-C, cd" "cd to Config Path"
			
			printf "  %-28s %s\n" "-e, edit" "Edit an existing config file using \$EDITOR"

			echo -e "\n\e[1mConfig Path:\e[0m\n$XDG_CONFIG_HOME/bash/bashrc"

			return 0
			;;
		*)
			echo "Invalid Option: See \"bashrc --help\"" 1>&2
			return 1
			;;
	esac

}

bashrc -s


# Load System BASH Completions File
[ -r "/etc/bash_completion" ] && source /etc/bash_completion # System

# Source executable bash-completion scripts
for bash_completion_file in $XDG_CONFIG_HOME/bash/bash-completion/*.bashrc; do
	[ -x "$bash_completion_file" ] && source "$bash_completion_file"
done
