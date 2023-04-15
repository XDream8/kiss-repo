#!/bin/sh

current_dir="$(pwd)"

for repo in *; do
	if [ ! -d "$repo" ]; then
		continue
	fi

	for package in "$repo"/*; do
		cd "$package" || exit

		ver="$(cat version)"

		sed -i "s/version/$ver/g" sources

		sed -i "s/ 1//g" sources

		cd ../.. || exit
	done
	for package in "$repo"/*; do
		cd "$package" || exit

		kiss c 1>/dev/null

		cd ../.. || exit
	done
done

cd "$current_dir" || exit
