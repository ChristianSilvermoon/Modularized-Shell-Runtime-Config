#!/bin/bash
# Description: Aliases to use '+x' instead of 'chmod +x' and more. Order must always be 'ugo' and 'rwx'!

for p in +x -x +r -r +w -w +rw -rw +rwx -rwx +rx -rx +wx -wx; do
	alias -- $p="chmod $p"		# Unspecified
	alias -- u$p="chmod u$p"	# User
	alias -- o$p="chmod o$p"	# Other
	alias -- g$p="chmod g$p"	# Group

	alias -- ug$p="chmod ug$p"	# User + Group
	alias -- go$p="chmod og$p"	# Group + Other
	alias -- uo$p="chmod uo$p"	# User + Other

	alias -- ugo$p="chmod ugo$p"	# User + Group + Other
done
