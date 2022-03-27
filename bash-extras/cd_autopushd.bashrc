#!/bin/bash
# Description: 'cd' automatically pushes directories onto the Directory Stack.

cd() {
	builtin cd "$@"
	[ "$OLDPWD" != "$PWD" ] && pushd "$PWD" >/dev/null
}
