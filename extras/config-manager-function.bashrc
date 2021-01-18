#!/bin/bash

bashrc-config() {

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
					echo "this feature requires shellcheck in \$PATH"
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
		"--help"|"-?")
			echo -e "bashrc-config <options>\n"
		        printf "  %-28s %s\n" "-?, --help" "Display this message"
			printf "  %-28s %s\n" "-l, ls, list" "List config files"
			printf "  %-28s %s\n" "+x, enable <file>" "Set a config file as executable"
			printf "  %-28s %s\n" "-x, disable <file>" "Set a config file as non-executable"
			printf "  %-28s %s\n" "-n, new <file>" "Create and edit new non-executable config file"
			printf "  %-28s %s\n" "-r, rm, remove <file>" "Delete a config file"
			printf "  %-28s %s\n" "-m, mv, rename <old> <new>" "Rename a config file"
			printf "  %-28s %s\n" "-c, check" "Check a config file with shellcheck"
			printf "  %-28s %s\n" "-e, edit" "Edit an existing config file"

			echo -e "\nConfig Path: $XDG_CONFIG_HOME/bash/bashrc"
			return 0
			;;
		*)
			echo "Invalid Option" 1>&2
			return 1
			;;
	esac

}
