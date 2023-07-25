<div align="center">
    <h1>kiss-repo</h1>
    <p>My repository for KISS linux</p>
</div>

## migrating to libressl
- force remove openssl
```sh
$ KISS_FORCE=1 kiss r openssl
```
- build and install libressl
```sh
$ kiss build libressl
```
- check which packages depends on openssl and rebuild them(kiss-revdepends comes with kiss-utils package. its in my repo)
```sh
$ kiss b $(kiss revdepends openssl | sed -e 's#/.*##g' | tr '\n' ' ')
```

## migrating to netbsd-curses
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
