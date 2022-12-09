# Pythonic flytex

## Install

Just run
```
$ ./make.sh
```

Alternatively, you can compile it with ```coconut``` ([click](coconut-lang.org)):
```
$ cp flytex.py ~/.local/bin/flytex.coco
$ cd ~/.local/bin
$ coconut flytex.coco
$ rm -rf flytex.coco
```


## Usage

For example, instead of writing:
```
$ lualatex --synctex=1 hello.tex
```
just put ```flytex``` before:
```
$ flytex lualatex --synctex=1 hello.tex
```
