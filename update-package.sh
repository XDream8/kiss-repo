#!/bin/sh -e

##################
##  By XDream8  ##
##################

help() {
	printf '%s\n%s\n' "-- Update package version --" "Usage: $0 <package path> <version>"
	exit 0
}

update_version() {
	ver="$(cut -d' ' -f1 < version)"

	sed -i "s/$ver/$package_version/g" sources
	sed -i "s/$ver/$package_version/g" version

	kiss c 1>/dev/null
}

main() {
	current_dir="$(pwd)"

	package_path="$1"
	package_version="$2"

	[ "$package_path" ] || help
	[ "$package_version" ] || help

	cd "$package_path" || exit

	update_version

	cd "$current_dir" || exit
}

main "$@"
exit 0
