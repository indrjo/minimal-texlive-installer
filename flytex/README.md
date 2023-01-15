# TeX Live on the fly: flytex


## Usage

There is no sophistication here: after you have installed *flytex* you can use it as follows:
```
$ flytex --c COMPILER --i TEX-FILE
```
The program will try to run
```
$ COMPILER TEX-FILE
```
and install any required package that is massing from your minimal TeX Live.


## Installation

*flytex* comes here written in different languages. If you want the *flytex* written in the language ```LANG```, just look for ```flytex/LANG```: there you will find the program in a single file and its own installer.

Historically, *flytex* was first designed in Haskell. Afterwards, I decided to write it in Python too. This language is probably present in every GNU/Linux distro, so one isn't forced to install Haskell on its machine.

To install *flytex*,
```
$ cd /path/to/flytex/LANG
$ ./make.sh
```

As the installation ends, a program called ```flytex``` will appear in ```~/.local/bin``` (it will be created if absent), so make it sure this path is in your ```PATH```.

To uninstall *flytex*,
```
$ rm ~/.local/bin/flytex
```

**(Attention)** Read also ```flytex/LANG/INSTALL.md``` (if present) for other info.
