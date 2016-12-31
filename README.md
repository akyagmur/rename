<h1 align="center">
Rename
  <br>
</h1>

<h4 align="center">Rename files as date modified on Mac OS and GNU/Linux</h4>

## How to install?

```
$ git clone https://github.com/akyagmur/rename.git
$ cd rename
$ mv rename.sh /your/path/rename
```

### How to use?

```
$ rename -p="*"                 #rename all files -p or --pattern
$ rename -e=doc                 #rename .doc files -e or --extension
$ rename -v                     #rename .jpg files and print verbose -v or --verbose
$ rename -f                     #rename files renamed with same format before -f --force
$ rename --format="%Y:%m:%d"    #rename by given pattern (Y/m/d.jpg)
```
