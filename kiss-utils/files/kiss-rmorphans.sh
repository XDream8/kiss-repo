#!/bin/sh -e
# List real orphaned packages by reading base packages from a file

SUDO="${KISS_SU:-doas}"
world_file="${KISS_WORLD:-/etc/kiss-base}"

n='
'

remove=0
select=0

world() {
	pac="$1"
	kiss l $pac >/dev/null 2>/dev/null || {
		printf '%s\n' "$pac is not installed"
		return 1
	}
	## check if it is in world
	if grep -qx "$pac" "$world_file" 2>/dev/null ]; then
		$SUDO sed -i "/^$pac$/d" "$world_file"
		printf '%s\n' "$pac removed from world"
	else
		printf '%s\n' "$pac" | $SUDO tee -a "$world_file"
		printf '%s\n' "$pac added to world"
		$SUDO sort "$world_file" -o "$world_file"
	fi
	## delete empty lines
	$SUDO sed -i '/^$/d' "$world_file"
}

help() {
	printf '%s\n\n' "--- $(basename "$0") ---
Usage: $0 <option>

  -h, --help        Shows this help page
  -r, --remove      Remove orphans

  -s, --select      Add/Remove from /etc/kiss-base"
	exit 0
}

case "$1" in
--) ;;

-h | --help)
	help
	;;
-s | --select)
	select=1
	;;
-r | --remove)
	remove=1
	;;
"") ;;

*)
	help
	;;
esac

if [ "$select" -eq 1 ]; then
	for pac in "$@"; do
		case "$pac" in
			-h | --help | -r | --remove | -s | --select | "")
				;;
			*)
				world "$pac"
				;;
		esac
	done
	set --
	exit 0
fi

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
