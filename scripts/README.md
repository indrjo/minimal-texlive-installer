# Helper scripts



## Install TeX Live on GNU/Linux

The shell script ```install-texlive``` helps you to install TeX Live on GNU/Linux. You may want to read [this section](#defaults-and-customizations) before. If you accept the defaults, it is sufficient to issue the command
```
$ ./install-texlive
```
and then wait few minutes.

This script write a file called ```.tlrc``` in you home which adjusts some paths for TeX Live. You should append the following line at the end of (for example) ```~/.bashrc```:
```
[ -f ~/.tlrc ] && source ~/.tlrc
```

If you have installed the ```minimal``` scheme (the default scheme, read [this](#defaults-and-customizations)), it is recommended to install some extra stuff:
```
$ tlmgr install latex-bin
$ tlmgr install texlive-scripts-extra
$ tlmgr install texdoc
$ tlmgr install texliveonfly
```
It is also recommended to install the packages ```hyphen-LANG``` for the languages you use:
```
$ tlmgr install hyphen-LANG
```
Here, ```LANG``` could be, for example, ```english```, ```german```, ```french```, ```italian```, and so on...

Once all it is fine, you may want to remove the installer with all the annexed stuff: to do so
```
$ rm -rf ~/.texlive-installer
```

### Defaults and customizations

* As ```install-tl-unx.tar.gz``` is downloaded, you can make ```install-texlive``` check its integrity for you. Just pass the option ```--verify-installer``` to do so, because this step is skipped by default.

* The environment variable ```TEXLIVE_INSTALL_PREFIX``` (the directory where all TeX Live is allocated) is set to ```~/texlive``` by default. If you prefer another location, pass the option ```--prefix=HERE```, where instead of ```HERE``` put your choice. **(Attention)** Just make sure you have the right to write where you want.

* You can select the scheme to install, by passing ```--scheme=SCHEME```. Here, ```SCHEME``` could be for example: ```minimal``` (the default), ```basic```, ```small```, ```medium```, ```full```, etc... **(Attention)** This repository is thought to offer a valid *minimal* TeX Live primarily, although it works fine for any scheme you prefer.

* An appropriate file that adds to your paths the ones of TeX Live
is created. By default, the file is ```~/.tlrc```, but you can choose any path you prefer, using ```--tlrc=HERE```. Afterwards, you must write on ```~/.bashrc``` to source this file. It is done for you by default; to prevent that, just pass the option ```--no-adjust-bashrc```.



## Install TeX Live on Android

**(Important)** The script ```install``` here is a modification of ```installer.sh```, which can be found [here](https://github.com/termux/termux-packages/blob/master/packages/texlive-installer/installer.sh).

It is sufficient to issue the command
```
$ ./termux-install-minimal-texlive
```
from Termux. It manages both installation and post installation process and applies some patches to make it work within the Termux environment.

**(Note)** Currently, this installer doesn't allow users to customize the installation as you can for any other GNU/Linux.