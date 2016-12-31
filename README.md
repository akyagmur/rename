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

## How to use?

```
$ rename -p="*xyz*"               #rename all files by pattern
$ rename -e=doc                   #rename .doc files
$ rename -v                       #rename all files and print verbose
$ rename -f                       #rename all files renamed with same format before
$ rename --format="%Y:%m:%d"      #rename by given pattern (Y/m/d)
$ rename -b="BEFORE_" -a="_AFTER" #add text before and after file names (BEFORE_file_AFTER.extension)
```

## Options

```
-v --verbose 
-p --pattern   # -p option overwrites -e,--extension
-e --extension # use extension or pattern.not together.
-v --verbose
-f --force
-a --after
-b --before
--format
```