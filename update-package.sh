#!/bin/sh -e

##################
##  By XDream8  ##
##################

help() {
	printf '%s\n%s\n' "-- Update package version --" "Usage: $0 <package path> <version>"
	exit 0
}

update_version() {
	ver="$(cut -d' ' -f1 <version)"

	sed -i "s/$ver/$package_version/g" sources
	sed -i "s/$ver/$package_version/g" version

	kiss c >/dev/null && printf '%s\n' "Generated checksums" || {
		printf '%s\n' "Generating checksums failed, reverting chamges"
		sed -i "s/$package_version/$ver/g" sources
		sed -i "s/$package_version/$ver/g" version
		exit 1
	}
}

git_commit() {
	git add sources version checksums
	git commit -o sources version checksums -m "$package_name: bump to version $package_version"
}

main() {
	current_dir="$(pwd)"

	package_path="$1"
	package_version="$2"

	[ "$package_path" ] || help
	[ "$package_version" ] || help

	package_name="${package_path%/}"
	package_name="${package_name#./}"
	package_name="${package_name#*/}"

	cd "$package_path" || exit

	update_version

	git_commit

	cd "$current_dir" || exit
}

main "$@"
exit 0
