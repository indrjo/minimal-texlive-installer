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

* It may be of aid to specify by yourself where the the installer is downloaded and unpacked, instead of the default ```~/.texlive-installer```. You can do that adding ```--installer-dir=HERE```. **(Attention)** Just be sure you have the permission to write into ```HERE```.

* As ```install-tl-unx.tar.gz``` is downloaded in its directory, you can make ```install-texlive``` check its integrity for you. Just pass the option ```--verify-installer``` to do so, because this step is skipped by default.

* The environment variable ```TEXLIVE_INSTALL_PREFIX``` (the directory where all TeX Live is allocated) is set to ```~/texlive``` by default. If you prefer another location, pass the option ```--prefix=HERE```. **(Attention)** Just make sure you have the right to write where you want.

* You can select the scheme to install, by passing ```--scheme=SCHEME```. Here, ```SCHEME``` could be for example: ```minimal``` (the default), ```basic```, ```small```, ```medium```, ```full```, etc...

* At the end of the installation process an appropriate file that adds to your paths the ones of TeX Live is created. By default, the file is ```~/.tlrc```, but you can choose any path you prefer, using ```--tlrc=HERE```. Afterwards, you must write on ```~/.bashrc``` to source this file. It is done for you by default; to prevent that, just pass the option ```--no-adjust-bashrc```.



## Post installation on GNU/Linux

If you have accepted ```minimal``` as scheme, you should spend some time to install some packages before. Which packages to install depends on the work you are doing. The script ```post-minimal-install``` just install some basic and necessary packages. 

A longer list of packages you are likely to need may be found in the script ```tlmgr-install-extras.pl```. Again, all this is subjective. You are encouraged to read it and add what you need or remove what you do not.

By the way, the script ```post-minimal-install``` installs ```texliveonfly``` which may dramatically automates this work. For example, you may pick any of your TeX works and give the main file to ```texliveonfly``` as follows:
```
$ texliveonfly -c COMPILER TEX_FILE
```

**(Note)** In ```../flytex``` the are some small programs intended to emulate the old ```texliveonfly```. They works fine for me, but I would be glad if you spend some time to try it and let me report bugs or suggest new features.



## Install TeX Live on Android

It is sufficient to issue the command
```
$ ./termux-install-minimal-texlive
```
from Termux. It manages both installation and post installation process and applies some patches to make it work within the Termux environment.

**(Important)** The script ```install``` here is a modification of ```installer.sh```, which can be found [here](https://github.com/termux/termux-packages/blob/master/packages/texlive-installer). This piece of code is distributed under the [same licence](https://github.com/termux/termux-packages/blob/master/LICENSE.md) of that work.

**(Note)** Currently, this installer doesn't allow users to customize the installation, as you can for any other GNU/Linux.



## Uninstall TeX Live from GNU/Linux

*To be refined...*



## Uninstall TeX Live from Android

The script ```termux-uninstall-texlive``` removes TeX Live and all its related stuff. You may further clean your environment using
```
$ apt autoremove
```
For this, you need to install ```apt``` in your Termux (```$ pkg install apt```).
