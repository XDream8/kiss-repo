#!/bin/sh -e
# List real orphaned packages by reading base packages from a file

SUDO="${KISS_SU:-doas}"
world_file="${KISS_WORLD:-/etc/kiss-base}"
db="/var/db/kiss/installed"

n='
'

remove=0
select=0
check=0

if [ ! -f "$world_file" ]; then
    $SUDO touch $world_file
fi

world() {
	pac="$1"
	## check if it is in world
	if grep -qx "$pac" "$world_file"; then
		$SUDO sed -i "/^$pac$/d" "$world_file"
		printf '%s\n' "$pac removed from world"
	else
		[ -d "$db/$pac" ] || {
			printf '%s\n' "$pac is not installed"
			return
		}
		$SUDO sh -c "printf '%s\n' $pac >> $world_file"
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
  -c, --check       Check world file ($world_file)

  -s, --select      Add/Remove from $world_file"
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
-c | --check)
	check=1
	;;
"") ;;

*)
	help
	;;
esac

if [ "$select" -eq 1 ]; then
	for pac in "$@"; do
		case "$pac" in
		-h | --help | -r | --remove | -s | --select | "") ;;

		*)
			world "$pac"
			;;
		esac
	done
	set --
	exit 0
fi

if [ "$check" -eq 1 ]; then
	while read -r PAC; do
		[ -d "$db/$PAC" ] || {
			printf '%s\n' "$PAC seems to be not installed"
			world "$PAC"
		}
	done <"$world_file"
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
			xargs printf '%s\n' baseinit baselayout busybox bzip2 e2fsprogs f2fs-tools gcc git grub syslinux kiss make musl <"$world_file"
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
