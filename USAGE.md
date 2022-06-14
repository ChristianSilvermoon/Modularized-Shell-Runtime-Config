# Usage
This document is an overview of how to use this system and some of the caveats that come with it.

## Installation
Installation is pretty darn easy, just follow the steps outlined here.

1. You should start by making a backup of your Shell Config File (`~/.bashrc`, `~/.zshrc`, etc)! You may not want to lose your existing customizations and/or customizations shipped by your OS!
2. Replace your original Config with the appropriate one from this repository (`msrc.bashrc`, `msrc.zsh`, etc), or append the contents to it instead (feel free to modify as you see fit)
3. Start a new instance of your shell, which will create the default directory for your new files
4. *Optionally* Copy your original Shell Config in as a module to have your original config file loaded through the system. Example: `.bashrc` -> `~/bashrc.d/00_my-original.bashrc` and mark it as **executable**, 
5. *Optionally* remove the **write** permission from your new shell config file to prevent other programs and scripts from tampering with it behind your back.

Then, with a fresh instance of your shell, try running `msrc --help` for more info!

## Naming Conventions
There are no enforced naming conventions other than that your config files **MUST** end in the correct extension for your shell (`.bashrc`, `.zshrc`, etc)

However, it is **STRONGLY RECOMMENDED** that you prefix your file's names with numbers and underscores (Like: `00_example.bashrc`), as the files are loaded in an order corresponding to their file names!

You can think of this as a *priority system*, with lower numbered files being loaded first. If the files have the same number, they're loaded alphabetically.

## Including Metadata In Your Configs
You can add a comment in your script file like so

```bash
#!/bin/bash
# Description: Sample Description
```
This description will show in `msrc list`

You can use this to help you better identify what your particular config is for!

Currently, this behavior is only supported when using MSRC with BASH.

## Caveats & Important Notes
Using this system has a few important details you may wish to be aware of.

## Load Time Report Accuracy

### BASH
BASH does not supporting Floating Point Arithmatic natively.

For this reason, the amount of detail available through `msrc times` is not necessarily very helpful, as it doesn't understand sub-second times.

HOWEVER if `bc` is available on the system, the `msrc` function will instead use `bc` to get more accurate, floating point calculations to show you sub-second information about how long each BASHRC file took to source.

### Using Variables In Your Config Files
In some of your BASHRC files, you might want to iterate over something using a **for** loop, or define **temporary variables** that should not persist after your configuration is fully loade...

If you'd like to confine your variables to be confined to the scope of when your BASHRC file is sourced, you may define them as **Local Variables**. That might sound strange if your BASHRC file does not contain a function, however they are *loaded* by a function, so the **local** keyword is valid.

There are some variables that exist **only** for a `.bashrc` file loaded by `msrc` to reference:
* `$MSRC_CONFIG_FILE` — Variables local to msrc function loading your configs. Tis is equivalent to the path of the file currently being sourced, but with the extenion `.config` instead of `.bashrc`

It is also very important that you do **NOT** overwrite any of the following variables names:
* `$MSRC_LOAD_TIMES` — Global variable which stores information used by the `msrc` function to display how long each BASHRC file took to finish execution
* `$MSRC_LOAD_TIMES_TOTAL` — Global variable which stores information used by the `msrc` function to display how long each BASHRC file took to finish execution
* `$sloadtime` — Variable local to `msrc` function that stores the time prior to sourcing a config file; used to calculate load time
* `$eloadtime` — Variable local to `msrc` function that stores the time after sourcing a config file; used to calculate load time
* `$MSRC_FILE` — Variable local to `msrc` function which contains the name of the current config file being sourced.
* `$tstime` — Variable local to `msrc` function containing the start time of the entire BASHRC sourcing process; used to calculate total load time.
* `$EPOCHSECONDS` — See BASH's Manual Page
* `$EPOCHREALTIME` — See BASH's Manual Page

### Config Files For Your `.bashrc` files
*You dawg, I heard you liked config files, so I put some config files in your config files so you can config while you config!*

It is sometimes important that your `.bashrc` files can store additional data that persists across multiple sessions.

There are **multiple solutions** to this problem.

The **prefered solution** is to reference `$MSRC_CONFIG_FILE` for storing/loading config data. This variable exists **ONLY** at the time of sourcing, if you need continued access to its contents, store the value in your own **Global Variable**

This solution means that `$BASH_MSRC_DIR/00_my-super-awesome-thing.bashrc` should use `$BASH_MSRC_DIR/00_my-super-awesome-thing.config` as it's config file.

If this solution is not optimal you can instead follow the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html).

You're free to realistically store things wherever you like, it is *your* computer, after all, but these are the recommended guidelines.

### Calling Overidden Built-ins, Commands, and Aliased Commands
Though not necessarily required or needed, some Config files may **override** shell built-ins, such as `cd`

At least in `bash` and `zsh`:

You should probably **NOT** ever override `builtin` for this reason.

If this is an issue for you, you can call the original built-in using `builtin cd`

To call the original version of an aliased command you can escape it like so `\command`

To call an external command that's been overriden by a function, use `command YOURCOMMANDHERE`
