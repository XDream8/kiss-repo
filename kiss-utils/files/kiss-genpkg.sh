#!/usr/bin/sh -e
# Generate binary packages

[ -z "$1" ] && printf '%s\n' "Provide a package name" && exit 1
pkg="$1"
path="$(kiss search "$pkg" | awk 'FNR==1 {print $1}')"
rm -rf "$pkg"

mkdir "$pkg"
cd "$pkg"
cp "$path/version" .
cp "$path/depends" .
sed -i '/.* make$/d' depends

cat << EOF > build
#!/bin/sh -e

cp * /
EOF
chmod +x build

version="$(sed 's/ /-/g' ./version)"
printf '%s\n' "https://github.com/XDream8/kiss-bin/archive/${pkg}@${version}.tar.xz" > sources

kiss c

cd ..
