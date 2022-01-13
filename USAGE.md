# Usage
This document is an overview of how to use this system and some of the caveats that come with it.

## Installation
Installation is pretty darn easy, just follow the steps outlined here.

1. You should start by making a backup of your `~/.bashrc` file! You may not want to lose your existing customizations and/or customizations shipped by your OS!
2. Replace your original `~/.bashrc` with the `bashrc` from this repository, or append the contents to it instead (feel free to modify as you see fit)
3. Start a new instance of BASH; which will create the default directories for your new files
4. *Optionally* Copy your original `.bashrc` to `$XDG_CONFIG_HOME/bash/bashrc/00_my-original.bashrc` and mark it as **executable**, to have your original config file loaded through the system.
5. *Optionally* remove the **write** permission from your `~/.bashrc` file to prevent other programs and scripts from tampering with it behind your back.

Then, with a fresh instance of BASH, try running `bashrc --help` for more info!

## Naming Conventions
There are no enforced naming conventions other than that your config files **MUST** end in `.bashrc`

However, it is **STRONGLY RECOMMENDED** that you prefix your file's names with numbers and underscores (Like: `00_example.bashrc`), as the files are loaded in an order corresponding to their file names!

You can think of this as a *priority system*, with lower numbered files being loaded first. If the files have the same number, they're loaded alphabetically.

## Caveats & Important Notes
Using this system has a few important details you may wish to be aware of.

## Load Time Report Accuracy
BASH does not supporting Floating Point Arithmatic natively.

For this reason, the amount of detail available through `bashrc times` is not necessarily very helpful, as it doesn't understand sub-second times.

HOWEVER if `bc` is available on the system, the `bashrc` function will instead use `bc` to get more accurate, floating point calculations to show you sub-second information about how long each BASHRC file took to source.

### Using Variables In Your BASHRC Files
In some of your BASHRC files, you might want to iterate over something using a **for** loop, or define **temporary variables** that should not persist after your configuration is fully loade...

If you'd like to confine your variables to be confined to the scope of when your BASHRC file is sourced, you may define them as **Local Variables**. That might sound strange if your BASHRC file does not contain a function, however they are *loaded* by a function, so the **local** keyword is valid.

It is also very important that you do **NOT** overwrite any of the following variables names:
* `$BASHRC_LOAD_TIMES` — Global variable which stores information used by the `bashrc` function to display how long each BASHRC file took to finish execution
* `$BASHRC_LOAD_TIMES_TOTAL` — Global variable which stores information used by the `bashrc` function to display how long each BASHRC file took to finish execution
* `$sloadtime` — Variable local to `bashrc` function that stores the time prior to BASHRC execution; used to calculate load time
* `$eloadtime` — Variable local to `bashrc` function that stores the time after BASHRC execution; used to calculate load time
* `$bashrc_file` — Variable local to `bashrc` function which contains the name of the current BASHRC file being sourced.
* `$tstime` — Variable local to `bashrc` function containing the start time of the entire BASHRC sourcing process; used to calculate total load time.
* `$XDG_CONFIG_HOME` — Used by `bashrc` function to determine where BASHRC files should be loaded from.
* `$EPOCHSECONDS` — See BASH's Manual Page
* `$EPOCHREALTIME` — See BASH's Manual Page

### Calling Overidden Built-ins & Aliased Commands
Though not necessarily required or needed, some BASHRC files may **override** shell built-ins, such as `cd`

You should probably **NOT** ever override `builtin` for this reason.

If this is an issue for you, you can call the original built-in using `builtin cd`

To call the original version of an aliased command you can escape it like so `\command`

### Effects of Using XDG Variables
This system both relies on, AND sets (but does not export) the variables defined by the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html) if they are undefined.

What this means is that changing/exporting the value of `$HOME` or `$XDG_CONFIG_HOME` may cause newly started instances of BASH to create directories in potentially unwanted places as well as fail to load your configuration files.

This should not be a problem for most users, but it is something that would likely be an unwelcomed surprise, so it is noted here.
