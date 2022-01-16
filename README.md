# custom-multi-bashrc
A bashrc that loads split components based on the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
Inspired by [Quentin ADAM on medium.com's post](https://medium.com/@waxzce/use-bashrc-d-directory-instead-of-bloated-bashrc-50204d5389ff)

As a note, there is *no* strict garauntee that all of the *Extras* will be compatbile with all platforms.

You should **always** review scripts from the internet before running them, the same goes for BASHRC files especially.

## Mutliple Toggle-able Configs
The `bashrc` here is meant to be placed in the traditional `~/.bashrc` location.

From there, `$XDG_CONFIG_HOME/bash` is referenced.

`$XDG_CONFIG_HOME/bash/bashrc` is meant to house *multiple* different config files. You can use this to your advantage by splitting your configuration into components instead of one large file.

Files marked executable are sourced, while files *not* marked executable will be ignored. This means that you can toggle on and off individual portions of your configuration using `chmod +x` and `chmod -x`

`$XDG_CONFIG_HOME/bash/bash-completion` works exactly the same, but is inteaded for files containing completion scripts. This seperate directory essentially exists for the sake of organization.

## History Relocated
`$HISTFILE` is set to `$XDG_DATA_HOME/bash/history` instead of `~/.bash_history`

It's not configuration, it's *data*.

## Configuration Manager
You can manage your multiple `.bashrc` files quickly using the `bashrc` function built into this `.bashrc`

Try out `bashrc --help` to see what all it can do!

For those that used earlier versions of this project, this used to be an extra, but was moved into the main `.bashrc` for ease of use and convenience. It also now features tab completion!

## Extras
Some extra .bashrc files are included for convenience.

### `alias-flatpak-exports.bashrc`
Iterates through files in `/var/lib/flatpak/exports/bin` and attempts to alias them to logical command names if they're not already taken.

If they **are** already taken, will attempt the long name (IE `tld.domain.app` instead of just `app`)

If the long name is ALSO taken, then no alias is created.

This is done for those who don't want to do `flatpak run tld.domain.app` so that you can just run `app`

run `alias | grep 'flatpak'` after this file has been sourced to see aliases it created for you.

### `cd_autopshd.bashrc`
Overrides the `cd` command with a function that calls BASH's builtin `cd` command AND also pushs your new directory to the Directory Stack (See BaSh's Manual)

This means using `cd` will automatically track the directories you've navigated with the Directory Stack, allowing you to quickly jump back to places
you've already been to in the current instance of BASH using `cd ~4` for example, to jump to the 4th directory on the stack.

To see the directories currently on your Directory Stack and their associated numbers, use `dirs -v`

To remove the overide at runtime you can use `unset -f cd`
To call BASH's *true* `cd` command and bypass the function just once, you can also use `builtin cd` instead of `cd`

### `chmod-aliases.bashrc`
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

### `terminology-extensions.bashrc`
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

### `terminology-batcat-extensions.bashrc`

Identical to terminlogy-extentions, but will also always substitute `cat` for `batcat` if available, ensuring you get syntax highlighted text files.
