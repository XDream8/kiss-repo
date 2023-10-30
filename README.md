<div align="center">
    <h1>kiss-repo</h1>
    <p>My repository for KISS linux</p>
</div>

## switching to netbsd-curses
- switch to tty because most probably your terminal may break after we remove ncurses
- force remove ncurses
```sh
$ KISS_FORCE=1 kiss r ncurses
```
- build and install netbsd-curses
```sh
$ kiss build netbsd-curses
```
- check which packages depends on ncurses and rebuild them(kiss-revdepends comes with kiss-utils package. its in my repo)
```sh
$ kiss b $(kiss revdepends ncurses | sed -e 's#/.*##g' | tr '\n' ' ')
```

## switching to toybox
- build and install gnugrep(for grep), mawk(for awk), oksh(for /bin/sh), rinit(for init system, you can use any init system you want), rsv(for service management), mdevd(for device management) and toybox(for coreutils)
```sh
$ kiss b gnugrep mawk oksh rinit rsv mdevd toybox
```
- switch to toybox utils
```sh
$ kiss a | grep ^toybox | kiss a -
```
- switch to gnugrep mawk and oksh
```sh
$ kiss a | grep ^gnugrep | kiss a -
$ kiss a | grep ^mawk | kiss a -
$ kiss a | grep ^oksh | kiss a -
$ kiss a | grep ^rinit | kiss a -
```
- build patched baseinit package from my repo
```sh
$ kiss b baseinit
```
- remove busybox
```sh
$ kiss r busybox
```
