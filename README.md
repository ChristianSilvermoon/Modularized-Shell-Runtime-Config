# custom-multi-bashrc
A bashrc that loads split components based on the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
Inspired by [Quentin ADAM on medium.com's post](https://medium.com/@waxzce/use-bashrc-d-directory-instead-of-bloated-bashrc-50204d5389ff)

# Mutliple Toggle-able Configs
The `bashrc` here is meant to be placed in the traditional `~/.bashrc` location.

From there, `$XDG_CONFIG_HOME/bash` is referenced.

`$XDG_CONFIG_HOME/bashrc` is meant to house *multiple* different config files. You can use this to your advantage by splitting your configuration into components instead of one large file.

Files marked executable are sourced, while files *not* marked executable will be ignored. This means that you can toggle on and off individual portions of your configuration using `chmod +x` and `chmod -x`

`$XDG_CONFIG_HOME/bash-completion` works exactly the same, but is inteaded for files containing completion scripts. This seperate directory essentially exists for the sake of organization.

# History relocated
`$HISTFILE` is set to `$XDG_DATA_HOME/bash/history` instead of `~/.bash_history`

It's not configuration, it's *data*.
