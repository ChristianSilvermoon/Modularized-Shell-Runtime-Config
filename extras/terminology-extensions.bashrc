#!/bin/bash
# New Bashrc

if [ "$TERMINOLOGY" ]&&[ "$(command -v mimetype)" ]&&[ "$(command -v grep)" ]; then
	# Use tycat and tyls instead of cat and ls
	# UNLESS: Piping
	# UNLESS: arguments used are not tycat or tyls arguments

	_terminology_ls_extension() {
		local tyls_incomp


		# Avoid tyls within GNU Screen (It doesn't work)
		[ "${TERM:0:6}" = "screen" -o "$STY" ] && tyls_incomp=1

		for a in "$@"; do
			if [ "$(echo "$a" | grep "^-")" ]; then
				# Argument starting with "-"
				# incompatible if if not -m, -a, or --
				[ "$(echo "$a" | grep -E "^-(-|[m|a|]{1,2})$")" ] || tyls_incomp=1
			fi
		done

		if [ -t 1 ]&&[ ! "$tyls_incomp" ]; then
			# Not piped or incompatible
			tyls "$@" 2>/dev/null
		else
	 		ls --color=always "$@"
		fi
	}

	_terminology_cat_extension() {
		local tycat_incomp

		# Avoid tycat within GNU Screen (It doesn't work)
		[ "${TERM:0:6}" = "screen" -o "$STY" ] && tycat_incomp=1
		
		for a in "$@"; do
			if [ "$(echo "$a" | grep "^-")" ]; then
				# Argument starting with "-"
				# incompatible if if not -m, -a, or --
				[ "$(echo "$a" | grep -E "^-(-|[s|f|g|c]{1,2})$")" ] || tycat_incomp=1
			else
				# Don't tycat incompatible file types
				case "$(mimetype -Mb "$a")" in
					"image/"* | "audio/"* | "video/"*)
						:
						;;
					"application/x-matroska")
						:
						;;
					*)
						tycat_incomp=1
						;;
				esac

			fi
		done

		if [ -t 1 ]&&[ ! "$tycat_incomp" ]; then
			tycat "$@" 2>/dev/null
		else
			cat "$@"
		fi
	}

	alias ls="_terminology_ls_extension"
	alias cat="_terminology_cat_extension"
fi
