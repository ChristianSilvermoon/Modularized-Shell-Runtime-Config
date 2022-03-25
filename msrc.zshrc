#!/bin/zsh
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

# Enable required ZSH Modules
zmodload zsh/datetime

# MSRC Directory Setup
[ "$ZSH_MSRC_DIR" ] || export ZSH_MSRC_DIR="$HOME/.zshrc.d"
[ -d "$ZSH_MSRC_DIR" ] || mkdir -p "$ZSH_MSRC_DIR" 

# MSRC Function
msrc() {
	case "$1" in
		"new"|"-n")
			if [ "$(echo "$2" | grep ".zshrc$")" ]; then
				echo "The extension \".zshrc\" is automatically appended, please don't include it." 1>&2
				return 1
			elif [ "$(echo "$2" | grep "/")" ]; then
				echo "You cannot use \"/\" in file names." 1>&2
				return 1
			elif [ -e "$ZSH_MSRC_DIR/$2.zshrc" ]; then
				echo "The file \"$2.zshrc\" already exists! Please specify a different name." 1>&2
				return 1
			elif [ ! "$EDITOR" ]||[ ! "$(command -v "$EDITOR")" ]; then
				echo "Ensure \"\$EDITOR\" is set to a valid command." 1>&2
				return 1
			else
				echo -e "#!/bin/zsh\n# New zshrc\n" > "$ZSH_MSRC_DIR/$2.zshrc"
				$EDITOR "$ZSH_MSRC_DIR/$2.zshrc"
				echo "Remember to enable your new file!" 1>&2
				return 0
			fi
			;;
		"remove"|"rm"|"-r")
			if [ "$(echo "$2" | grep ".zshrc$")" ]; then
				echo "The extension \".zshrc\" is automatically appended, please don't include it." 1>&2
				return 1
			elif [ "$(echo "$2" | grep "/")" ]; then
				echo "You cannot use \"/\" in file names." 1>&2
				return 1
			elif [ ! -e "$ZSH_MSRC_DIR/$2.zshrc" ]; then
				echo "The file \"$2.zshrc\" does not exist! Please specify a different name." 1>&2
				return 1
			else
				rm -iv "$ZSH_MSRC_DIR/$2.zshrc"
				return 0
			fi
			;;

		"rename"|"mv"|"-m")
			if [ "$(echo "$2" | grep ".zshrc$")" -o "$(echo "$3" | grep ".zshrc$")" ]; then
				echo "The extension \".zshrc\" is automatically appended, please don't include it." 1>&2
				return 1
			elif [ "$(echo "$2" | grep "/")" -o "$(echo "$3" | grep "/")" ]; then
				echo "You cannot use \"/\" in file names." 1>&2
				return 1
			elif [ ! -e "$ZSH_MSRC_DIR/$2.zshrc" ]; then
				echo "The file \"$2.zshrc\" does not exist! Please specify a different name." 1>&2
				return 1
			else
				mv -iv "$ZSH_MSRC_DIR/$2.zshrc" "$ZSH_MSRC_DIR/$3.zshrc"
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

				for i in $ZSH_MSRC_DIR/*.zshrc; do
					editable_files+=( "$(basename "$i" | sed 's/\.zshrc$//g')" )
				done

				local PS3="$(echo -e "\e[1mEnter a #: \e[22m")"
				select i in "${editable_files[@]}"; do
					if [ "$i" ]; then
						$EDITOR "$ZSH_MSRC_DIR/$i.zshrc"
						return 0
					else
						echo "No valid file was selected, aborting." 1>&2
						return 1
					fi
				done

				return 0

			elif [ "$(echo "$2" | grep ".zshrc$")" ]; then
				echo "The extension \".zshrc\" is automatically appended, please don't include it." 1>&2
				return 1

			elif [ "$(echo "$2" | grep "/")" ]; then
				echo "You cannot use \"/\" in file names." 1>&2
				return 1

			elif [ ! -e "$ZSH_MSRC_DIR/$2.zshrc" ]; then
				echo "The file \"$2.zshrc\" does not exist! Please specify a different name." 1>&2
				return 1

			else
				$EDITOR "$ZSH_MSRC_DIR/$2.zshrc"
				return 0
			fi
			;;
		"check"|"-c")
				echo "Shell check does not support ZSH."
				;;
		"enable"|"+x")
			if [ -e "$ZSH_MSRC_DIR/$2.zshrc" ]; then
				if [ ! -x "$ZSH_MSRC_DIR/$2.zshrc" ]; then
					chmod +x "$ZSH_MSRC_DIR/$2.zshrc"
					echo "Set \"$2.zshrc\" as executable" 1>&2
					return 0
				else
					echo "The zshrc file \"$2.zshrc\" is already executable." 1>&2
					return 1
				fi
			else
				echo "The zshrc file \"$2.zshrc\" does not exist." 1>&2
				return 1
			fi
			return 0
			;;
			
		"disable"|"-x")
			if [ -e "$ZSH_MSRC_DIR/$2.zshrc" ]; then
				if [ -x "$ZSH_MSRC_DIR/$2.zshrc" ]; then
					chmod -x "$ZSH_MSRC_DIR/$2.zshrc"
					echo "Set \"$2.zshrc\" as non-executable" 1>&2
					return 0
				else
					echo "The zshrc file \"$2.zshrc\" is already not executable." 1>&2
					return 1
				fi
			else
				echo "The zshrc file \"$2.zshrc\" does not exist." 1>&2
				return 1
			fi
			return 0
			;;
		"list"|"ls"|"-l")
			ls --color=always -p "$ZSH_MSRC_DIR" | grep -v "/$" | sed 's/\.zshrc//g'
			return 0
			;;
		"source"|"-s")	
			MSRC_LOAD_TIMES=""
			MSRC_LOAD_TIME_TOTAL=""
			
			local sloadtime
			local eloadtime
			
			local tstime="$EPOCHREALTIME"

			local MSRC_FILE
			for MSRC_FILE in $ZSH_MSRC_DIR/*.zshrc; do
				# Skip Iteration if not executable
				[ ! -x "$MSRC_FILE" ] && continue
				
				# Store time before execution
				sloadtime="$EPOCHREALTIME"

				# Source if executable
				source "$MSRC_FILE"
		
				# Store time After Execution
				eloadtime="$EPOCHREALTIME"

				MSRC_LOAD_TIMES+="${sloadtime} ${eloadtime} ${MSRC_FILE}"$'\n'
			done

			# Store total load time	
			MSRC_LOAD_TIME_TOTAL="$((EPOCHREALTIME - tstime))"

			return 0
			;;

		"-S"|"restart")
			local jcount="$(jobs -p | wc -l)"
			if [ "$jcount" = "0" ]; then
				echo "Restarting Shell..." >&2
				exec zsh
			else
				echo -e "Your shell has $jcount stopped job$([ "$jcount" = "1" ] || echo -ne 's').\nPlease \e[1mterminate\e[22m or \e[1mdisown\e[22m any jobs before restarting to avoid losing work.\nYou can see your jobs with \"jobs -l\"" 1>&2
				return 1
			fi
			return
			;;
		"-C"|"cd")
			cd "$ZSH_MSRC_DIR"
			;;
		"-t"|"times")
			echo -e "Total: ${MSRC_LOAD_TIME_TOTAL}s\n\n" 1>&2	
			local list

			for f in ${(@f)MSRC_LOAD_TIMES}; do
				local stime="$(echo "$f" | cut -d ' ' -f 1)"
				local etime="$(echo "$f" | cut -d ' ' -f 2)"
				local file="$(echo "$f" | cut -d ' ' -f 3-)"

				list+="$((etime - stime))s $file"$'\n'
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
			#printf "  %-28s %s\n" "-c, check" "Check a config file with shellcheck"
			printf "  %-28s %s\n" "-C, cd" "cd to Config Path"
			
			printf "  %-28s %s\n" "-e, edit" "Edit an existing config file using \$EDITOR"

			echo -e "\n\e[1mConfig Path:\e[0m\n$ZSH_MSRC_DIR"

			return 0
			;;
		*)
			echo "Invalid Option: See \"msrc --help\"" 1>&2
			return 1
			;;
	esac

}

msrc -s
