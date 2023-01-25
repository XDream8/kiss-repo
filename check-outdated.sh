#!/bin/sh -e
## check all outdated packages in this repo

for repo in ./*; do
	repo="${repo##./}"
	if [ ! -d "$repo" ]; then
		continue
	fi

	outdated="$(kiss outdated "$repo" 2>&1 | sed 's/\[Checking.*//g')"
	# shellcheck disable=2295
	outdated="${outdated#${outdated%%[![:space:]]*}}"

	printf '%s\n' "$repo:"
	printf '%s\n\n' "$outdated"
done
