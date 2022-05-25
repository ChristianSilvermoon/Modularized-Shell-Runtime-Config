# BASH Extras
This directory contains extras for BASH

## `alias-flatpak-exports.bashrc`
Iterates through files in `/var/lib/flatpak/exports/bin` and attempts to alias them to logical command names if they're not already taken.

If they **are** already taken, will attempt the long name (IE `tld.domain.app` instead of just `app`)

If the long name is ALSO taken, then no alias is created.

This is done for those who don't want to do `flatpak run tld.domain.app` so that you can just run `app`

run `alias | grep 'flatpak'` after this file has been sourced to see aliases it created for you.

## `apt2nala.bashrc`
Automatically substitutes `apt` commands for their [nala](https://gitlab.com/volian/nala) equivalents if possible, unless piping.

Will also auotmatically run `nala` with `sudo` for commands that require it.

This attempts to mimick `apt`'s behavior and will not update cache unless you would've asked `apt` to, etc.

This is not intended as an alias to replace `apt`, but rather to prettify the output, etc.

Examples:
* `apt update` → `sudo nala --update`
* `apt upgrade` → `sudo nala update --no-update`
* `apt list` → `nala search . --no-update`
* `apt list --installed` → `nala search . --installed`

This is achieved by defining a function called "`apt()`", to bypass this and call your system's *real* `apt` with this active, use `command apt`

If both `apt` and `nala` are not in `$PATH` while this is active, then no shell function will be created, effectively doing nothing.

## `cd_autopshd.bashrc`
Overrides the `cd` command with a function that calls BASH's builtin `cd` command AND also pushes your new directory to the Directory Stack (See BASH's Manual)

This means using `cd` will automatically track the directories you've navigated with the Directory Stack, allowing you to quickly jump back to places
you've already been to in the current instance of BASH using `cd ~4` for example, to jump to the 4th directory on the stack.

To see the directories currently on your Directory Stack and their associated numbers, use `dirs -v`

To remove the overide at runtime you can use `unset -f cd`
To call BASH's *true* `cd` command and bypass the function just once, you can also use `builtin cd` instead of `cd`

## `chmod-aliases.bashrc`
This one creates an absurd number of aliases for `chmod` and basic letter permissions, allowing you to skip typing out `chmod`

Important Notes:
* This only applies for **read**, **write**, and **execute** permissions, and NOT **setuid**/**setgid**/**sticky**
* You **MUST** specify in the correct order (`ugo+rwx`), but you can leave things out like this: `uo+rx`
* You cannot specify multiple permissions (like `ug+x,o-rwx`), you must still use `chmod` for this!

Examples
```bash
# Normally, you'd type:
chmod +x script.sh
chmod go-r senstive-file.txt
chmod -x script.sh

# With this, you get:
+x script.sh
go-r sensitive-file.txt
chmod -x script.sh
```

## `super-cd.bashrc`
Overrides the `cd` command to make it more **SUPER** with a variety of new features.

Its options are displayed with `cd --help` or `cd -?` alongside vanilla `cd` options.


### History
`cd` will automatically push your new `$PWD`

You could always navigate using the directory stack with `cd ~3`

But now the Directory Stack is tracking everywhere you've been in your current session!

`cd ~2` will take you back to the previous directory!

`cd -d` will run `dirs -v`, allowing you to see the directory stack with relevant numbers.

### Favorites / Bookmarks
Bookmarks at the GUI are great, but what about in the terminal?

You can view your bookmarks with `cd -f` or go to one with `cd -f bookmark-name`!

By default, Super CD will define the following bookmarks:

| Bookmark | Directory     | Condition           |
| -------- | ------------- | ------------------- |
| my-bin   |`~/.local/bin` | If directory exists |
| desk     |`~/Desktop`    | If directory exists |
| docs     |`~/Documents`  | If directory exists |
| dl       |`~/Downloads`  | If directory exists |
| music    |`~/Music`      | If directory exists |
| pics     |`~/Pictures`   | If directory exists |
| tmp      |`$TMPDIR`      | If `$TMPDIR` is set |

Bookmarks are stored/refererenced from an *Associative Array* named `$CD_BKM` (CD Bookmarks)

If `$CD_BKM` already populated, then Super CD will not create the default bookmarks

Super CD saves and loads bookmarks from `$CD_BKM_FILE` (`~/.super-cd-bookmarks` by default).

The bookmarks file syntax is:
```
# Comment
bookmark-name /path/to/directory
other-bookmark /path/to/directory
```
You may **NOT** have a space or % in your bookmark names.
Do **NOT** include more than one space after the bookmark name.

Example Usage:
```bash
# Reading Bookmarks from $CD_BKM_FILE
cd -R

# Adding/Changing Bookmarks
cd +m pwd
cd +m git "$HOME/Dev/my-github"
cd +m www "/var/www/html"

# Removing Bookmarks
cd -m pwd
cd -m git
cd -m www

# Saving Bookmarks to $CD_BKM_FILE
cd -s

# Using Bookmarks
cd %git                      # IF `./%git` does not exist
cd -f git                    # ANY TIME
cd "$(cd -F git)/something"  # Subdirectory of bookmark

```

When listing Bookmarks, a bookmark corresponding to your current directory is listed in green and invalid bookmarks are listed in red. 

Note: You unfortunately **CANNOT** use bookmark short hand with `shopt -s autocd` like you can with the Directory Stack. The "%" with a word is normally reserved `fg` shorthand in BASH anyhow.

### Improved Directory Asscension
Tired of typing `cd ../../../..` ?

With Super CD you can type `cd .. 4` or `cd -u 4` instead!

You can also ascend to the root of your current filesystem or subvolume with `cd -r`

If you use `cd -b ho` Super CD will attempt to use [bd](https://github.com/vigneshwaranr/bd) to find a parent directory to go to.


## `terminology-extensions.bashrc`
If you're using [Terminology](https://github.com/borisfaure/terminology), the EFL-based Terminal Emulator...

This will automatically substitute `ls` for `tyls` and `cat` for `tycat` when appropriate.

It's unlikely you'll want to `cat` a PNG to your terminal for a bunch of garbage data...
but you might want to `tycat` it for a pretty picture within Terminology.

This allows you to use Terminology's fancy versions of these commands by default so you can
get the most out of Terminology without having to remember to substitute your usual commands.

This will **ALWAYS** fall back on standard `ls` and `cat` if you attempt to pipe them to ensure
that you can still use them the ways you would normally.

If you need to examine their usual output, try: `ls | less -R`
Or disable this.

This will **NOT** use `tyls` or `tycat` if:
* The arguments you pass are unsupported by them (example: `ls -l1ha`)
* `$TERMINOLOGY` is undefined
* `tycat` doesn't support the mimetype of the file you're trying to `cat`
* You pipe `cat` or `ls` to another command or file
* The `mimetype` command is unavailable or returns unexpected results
* The `grep` command is unavailable

## `terminology-batcat-extensions.bashrc`

Identical to terminlogy-extentions, but will also always substitute `cat` for `batcat` if available, ensuring you get syntax highlighted text files.
