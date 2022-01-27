# Modularized Shell Runtime Config
A Shell Runtime Configuration File that loads split components. Partially inspired by [Quentin ADAM on medium.com's post](https://medium.com/@waxzce/use-bashrc-d-directory-instead-of-bloated-bashrc-50204d5389ff)

You should **always** review scripts from the internet before running them, the same goes for Shell Runtime Config files especially.

## Mutliple Toggle-able Configs
The main config `msrc.bashrc`, `msrc.zshrc`, etc. is meant to replace your original traditional config.

From there the script will automatically source executable files ending in `.bashrc` that it finds in: `~/.bashrc.d/`

## Changing Your Config Directory
This used to be based on the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html) in earlier versions of this project, however, that was dropped in favor of using `~/.bashrc.d` and so on for simplicity and not interfering with XDG Variable usage.

If you wish to change your config directory now, you will want to use the following environment variables:
```bash
BASH_MSRC_DIR="$HOME/.bashrc.d"
ZSH_MSRC_DIR="$HOME/.zshrc.d"
```

If you do not export these your shell will do so automatically at start up, defaulting to the values shown above.

## Configuration Manager
You can manage your multiple config files quickly using the `msrc` function built into main Shell config

Try out `msrc --help` to see what all it can do!

## Extras
Some extra Shell Config files are included for convenience these may be loaded as modules using this system.

See the `shell-extras` folder for those Extras. The `README.md` within should give you some insight as to what each one does.

As a note, there is *no* strict garauntee that all of the *Extras* will be compatbile with all platforms.
