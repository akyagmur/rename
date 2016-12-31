<h1 align="center">
Rename
  <br>
</h1>

<h4 align="center">Rename files as date modified or add text to file names on Mac OS and GNU/Linux</h4>

## How to install?

```
$ git clone https://github.com/akyagmur/rename.git
$ cd rename
$ mv rename.sh /your/path/rename
```

### How to use?

```
$ rename -p="*xyz*"               #rename all files by pattern                                          -p or --pattern
$ rename -e=doc                   #rename .doc files                                                    -e or --extension
$ rename -v                       #rename all files and print verbose                                   -v or --verbose
$ rename -f                       #rename all files renamed with same format before                     -f --force
$ rename --format="%Y:%m:%d"      #rename by given pattern (Y/m/d)                                      --format
$ rename -b="BEFORE_" -a="_AFTER" #add text before and after file names (BEFORE_file_AFTER.extension)   -b or --before,-a or --after
```
