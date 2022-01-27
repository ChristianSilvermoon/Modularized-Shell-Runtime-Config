#!/bin/bash
# Auto pushd

cd() {
	builtin cd "$@"
	[ "$OLDPWD" != "$PWD" ] && pushd "$PWD" >/dev/null
}
