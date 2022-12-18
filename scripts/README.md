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

**(Future project)** We can make ```install-texlive``` write that line by itself, instead of requiring users to do so... We can implement the option ```--no-adjust-bashrc```, making the script update ```~/.bashrc``` by default.

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

### Defaults and customizations

* As ```install-tl-unx.tar.gz``` is downloaded, you can make ```install-texlive``` check its integrity. Just pass the option ```--verify-installer``` to do so, because this step is skipped by default.

* ```TEXLIVE_INSTALL_PREFIX``` (the directory where all TeX Live is allocated) is set to ```~/texlive``` by default. If you prefer another location,
```
$ ./install-texlive --prefix=HERE
```
where instead of ```HERE``` put your choice. **(Attention)** Just make sure you have the right to write where you want.

* You can select the scheme to install:
```
$ ./install-texlive --scheme=SCHEME
```
Here, ```SCHEME``` could be: ```minimal```, ```basic```, ```small```, ```medium```, ```full```, etc...

* ```install-tl-unx.tar.gz``` is downloaded inside ```~/tl-installer``` unpacked therein. Once the installation terminates, that directory will be deleted. If you want to keep it instead,
```
$ ./install-texlive --keep-installer
```



## Install TeX Live on Android

**(Important)** The script ```install``` here is a modification of ```installer.sh```, which can be found [here](https://github.com/termux/termux-packages/blob/master/packages/texlive-installer/installer.sh).

**(Important)** This script modifies some parts of the package ```texlive-installer``` after it is installed. This behaviour is expected to change in future.

It is sufficient to issue the command
```
$ ./termux-install-minimal-texlive
```
from Termux. It manages installation and post installation process and applies some patches to make it work within the Termux environment.

**(Warning)** Currently, this installer doesn't allow users to customize the installation through, say, commandline arguments.