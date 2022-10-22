#!/bin/sh -e
# List real orphaned packages by reading base packages from a file

world_file="${KISS_WORLD:-/etc/kiss-base}"

n='
'

help() {
	printf '%s\n' "--- kiss-realorphans ---
Usage: $0 <option>

  -h, --help		Shows this help page
	"
	exit 0
}

case "$1" in
--) ;;

-h | --help)
	help
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
			printf '%s\n' baseinit baselayout busybox bzip2 e2fsprogs gcc \
				git grub kiss make musl "$(cat "$world_file" 2>/dev/null)"
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

if [ ! "$*" = "" ]; then
	pacs="$(printf '%s\n' "$@" | tr "\n" " " | sed 's/ $//')"
	printf '%s\n' "$@"
	[ "$(command -v kiss-rmdeps)" ] && kiss rmdeps "$pacs" || printf '\n%s\n' "kiss remove $pacs"
else
	printf '%s\n' "no orphan packages found"
fi
