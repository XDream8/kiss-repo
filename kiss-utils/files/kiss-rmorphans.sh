#!/bin/sh -e
# List real orphaned packages by reading base packages from a file

world_file="${KISS_WORLD:-/etc/kiss-base}"

n='
'

remove=0

help() {
	printf '%s\n' "--- $(basename $0) ---
Usage: $0 <option>

  -h, --help		Shows this help page
  -r, --remove		Remove orphans
	"
	exit 0
}

case "$1" in
--) ;;

-h | --help)
	help
	;;
-r | --remove)
	remove=1
	;;
"") ;;

*)
	help
	;;
esac

cd "$KISS_ROOT/var/db/kiss/installed"
set -- *

l=$n$(
	for pkg; do
		shift
		set -- "$@" -e "$pkg"
	done

	# Get a list of non-orphans.
	grep -Fx "$@" -- */depends |
		{
			# Strip filename.
			sed s,.\*/depends:,,

			# Exclude packages which are not really orphans.
			xargs printf '%s\n' baseinit baselayout busybox bzip2 e2fsprogs gcc git grub kiss make musl <"$world_file"
		} |

		# Remove duplicates.
		sort -u
)$n

# Generate the list of orphans by finding the inverse of the non-orphan list.
for pkg; do
	shift
	case $l in *"$n$pkg$n"*)
		continue
		;;
	esac

	set -- "$@" "$pkg"
done

if [ "$*" ]; then
	printf '%s\n' "$@"
	if [ "$remove" -eq 1 ]; then
		[ "$(command -v kiss-rmdeps)" ] && kiss-rmdeps "$@" 2>/dev/null ||
			# this is when kiss-rmdeps is not available
			printf '\n%s\n' "kiss remove $*"
	fi
else
	printf '%s\n' "no orphan packages found"
fi
