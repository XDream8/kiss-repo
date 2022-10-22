#!/usr/bin/sh -e

[ -z $1 ] && echo "Provide a package name" && exit 1
pkg=$1
path=$(kiss search $pkg)
rm -rf $pkg

mkdir $pkg
cd $pkg
cp $path/version .
cp $path/depends .
sed -i '/.* make$/d' ./depends

echo "cp * /" > ./build
chmod +x ./build

version=$(sed 's/ /-/g' ./version)
echo "https://github.com/XDream8/kiss-bin/archive/${pkg}@${version}.tar.xz" \
  > ./sources

kiss c

cd ..
