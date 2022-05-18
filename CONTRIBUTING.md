# Contributing
When contributing to this project, you should include a **detailed** 
explanation of what you have done, and *why* you have done it in your 
Pull Request.

## What this Project IS
This project's goal is to make it easy to split your Shell Configuration 
into many files that can be moved from one device to another, enabled, or 
disabled... sort of like "Modules" or "Plugins"

## What This Project ISN'T
This project is *NOT* [OhMyZSH](https://github.com/ohmyzsh/ohmyzsh)
~~It was almost called "Son Of A BASH" though~~. It is a plugin system of 
sorts, but it's scope and intent are to make it easier for the **USER**
to manage their own personal customization.

## What You SHOULD Do

Good ideas for contributions to this repo include:
* Include a __detailed__ description with your Pull Request
* Adding a new Shell Extra
* Test on [Termux](https://github.com/termux/termux-app/#Termux-App-and-Plugins), if possible. Termux is intended as a supported platform.
* Include Good Descriptions in your Extras.
* Quality of Life Features
* Bug Fixes
* Optimizations
* Reduction of unecessary globals

## What You Should NOT Do

You should **NEVER** have any file in this repo:
* Delete files it does not create without user confirmation
* Create files in innapropriate locations
* Download any files without explicit user consent
* Have a Shell Extra alter the main shell config (EX `~/.bashrc`)
* Have a Shell Extra alter other extras that it did not create.
* Place hidden files in `~/`. If you truly need to store extra content please use `~/.bashrc.d/your-extra.config`. Or, if that isn't enough please at least adhere to the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
* Delete user created files without user consent.
* Add a new Extra without documenting it in the Extras README.md
* Depend on non-standard packages. Please try and adhere to using BASH, Coreutils, and other utilities commonly installed on most Linux Distributions.
* Auto Updaters
* Include No Description in your Shell Extras
* Create unecessary Global Variables; the user's shell should *not* be polluted with globals they do not need or care about.
* Submit Malicious Sofware of any kind.
* Call External Intepreters unecessarily (such as `perl`) for things that can be done natively with `bash` itself.

# Code of Conduct

## Be Kind and Respectful To Each Other

People come from all walks of life, pathes, and histories, and in all shapes 
and sizes.

Please be respecful of others, they may be different from you, or seem
strange to you, but people's differences are what makes the world an
interesting place.

Avoid being hostile, or hurtful; For __any__ reason.

## Keep External Drama OUT of This Project
Drama from **any** social media platform, offline, etc. is *NOT* to be brought here, either in Issues, Pull Requests, Commits, or Discussions.

This project's goal is to make people's lives easier; not to moderate 
unrelated issues.

Do **NOT** start religious or political debates. This is **NOT** the place
for that.

## Zero Tolerance
Doing **ANY** of the following is not acceptable.

There is to be **NO**:
* Bullying Of Other Contributors or Users
* Passive Aggressive behavior towards others
* Harrassment of any kind
* Inclusion of Telemetry/Data Collection of any kind
