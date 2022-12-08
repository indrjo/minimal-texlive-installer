# Another *TeXlive on the fly* for GNU/Linux

## Usage

For example, instead of writing:

```
$ lualatex --synctex=1 hello.tex
```

just put ```flytex.py``` before:

```
$ flytex lualatex --synctex=1 hello.tex
```


## Or compile it with coconut

```
$ pip install -U coconut
$ cp flytex.py flytex.coco
$ coconut flytex.coco
```

