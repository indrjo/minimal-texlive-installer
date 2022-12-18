# Get yourself a minimal TeX Live

* [Preamble](#preamble)

* [Minimal TeX Live on GNU/Linux](#minimal-tex-live-on-gnulinux)

* [Minimal TeX Live on Android](#minimal-tex-live-on-android)

* [TeX Live on the fly](#tex-live-on-the-fly)

* [Flytex](#flytex)



## Preamble

We provide instructions to install a **minimal TeX Live** on GNU/Linux. Here, *minimal* means that you have a very small base that can be easily enriched through [texliveonfly](https://www.ctan.org/pkg/texliveonfly). This means you do not have all the packages you need, but you can easily add them.
For example, the command
```
$ texliveonfly --compiler lualatex hello-world.tex
```
while trying to produce ```hello-world.pdf``` with ```lualatex``` detects missing packages and install them *on the fly*. After you have all what you need, a ordinary
```
$ lualatex hello-world.tex
```
will work. There is a [dedicated section below](#tex-live-on-the-fly) for this script: you may want to read that before.



## Minimal TeX Live on GNU/Linux

**(Warning)** The procedure below installs TeX Live in your own home. So, if you want TeX Live to be accessible to other users, this might not be the best choice.

**(Warning)** In the directory ```scripts```, there is a collection of tiny shell scripts automating various parts of the installation process. They may be helpful, if you cannot be bothered. In this case, go to the ```README``` present there.


### Installation

The installation process does not mess your home up, as just two new directories are created: one is ```~/texlive``` and the other is ```~/.texlive``` (or some variation...). Thus, if you want to get rid of TeX Live, you know what to remove.

To keep things tidy, let us create a directory and move there:
```
$ mkdir install-tl
$ cd install-tl
```
The installer comes directly from CTAN as a compressed archive:
```
$ wget "https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz"
```
Decompress it:
```
$ tar -xzf install-tl-unx.tar.gz --strip-components 1
```

Now, we can start the installer:
```
$ TEXLIVE_INSTALL_PREFIX=~/texlive ./install-tl --scheme scheme-minimal --no-interaction
```
A brief explanation of this command. With ```TEXLIVE_INSTALL_PREFIX=~/texlive``` we tell the installer ```install-tl``` where all things go. With ```--scheme scheme-minimal``` we are saying just install the the core of TeX Live. Without the option ```--no-interaction```, the installer will display all the setup for your installation: from there you can change some configurations or simply confirm all and start the installation process.


### Post-installation

Once the installer has finished its work, copy the following lines and paste them at the end of your ```~/.bashrc```:
```
export PATH=~/texlive/YEAR/bin/x86_64-linux:$PATH
export MANPATH=~/texlive/YEAR/texmf-dist/doc/man:$MANPATH
export INFOPATH=~/texlive/YEAR/texmf-dist/doc/info:$INFOPATH
```
where ```YEAR``` is to be replaced with the year of the TeX Live you have just installed. Save the changes and
```
$ source ~/.bashrc
```

The TeX Live we have just installed hasn't ```pdflatex```, ```xelatex```, ```lualatex``` and some other things yet. If you want them:
```
$ tlmgr install latex-bin
```

Another package we cannot live without is ```texdoc```.
```
$ tlmgr install texdoc
```


### Uninstall TeX Live

You know, cyclically you have to get rid of the old version and leave space to the newer one.
```
$ rm -rf ~/{,.}texlive*
```
should suffice for the purpose. (You may need to employ ```sudo```...)



## Minimal TeX Live on Android

We use [Termux](https://termux.dev/en/); you may want to have a look at the [TeX Live page of Termux](https://wiki.termux.com/wiki/TeX_Live).

The installation on Android requires some work that is better not to explain in this ```README```. However, if one wants to know this work, they could read the source codes in ```scripts/termux``` directly.


### Installation and post-installation

Consider ```scripts/termux-install-minimal-texlive```.


### Uninstall

Have a look at ```scripts/termux-uninstall-texlive```.



## TeX Live on the fly

### Description

We can get it from CTAN:
```
$ tlmgr install texliveonfly
```
It is very simple to use:
```
$ texliveonfly -c COMPILER YOUR_TEX_FILE
```
Here ```COMPILER``` can be, for instance, ```pdf[la]tex```, ```lua[la]tex```, ```xe[la]tex``` or others...

**(Warning)** Although it is a great tool, in few cases it may need some help from the user. For example, you may want to install by yourself some packages after ```polyglossia``` or ```babel```.
```
$ tlmgr install hyphen-LANGUAGE
```
(Some of the hyphen packages are: ```hyphen-english```, ```hyphen-french```, ```hyphen-german```, ```hyphen-italian``` and so on...)

**(Warning)** It seems that
```
$ texliveonfly -c COMPILER -a '--synctex=1' FILE.tex
```
(and who knows what else...) turns off the ability to install packages on the fly.


### Criticisms

Truth be said, ```texliveonfly.py``` is a very old software, it was written in 2011 ([click!](https://latex.org/forum/viewtopic.php?f=12&t=15194)) and it hasn' been receiving updates since ages from its author(s). On internet, you can find some repositories providing some changes and fixes (for example [this](https://github.com/maphy-psd/texliveonfly) of 2015), but it definitely seems a dead project.

Another source of criticisms is that it was written on and for ```Ubuntu``` of that era. If you read its source code, you will notice, some software that exists no more is invoked. Fortunately, this happens if you want to use ```sudo``` or *similia*. If we install all in ```$HOME```, no problem.

Will ```texliveonfly``` return to life? Who knows. If one wants to read its source code and work on it, one hurdle could be that the code is poorly commented. If one wants to write its own *TeX Live on the fly*, this means work from zero, although the idea behind is simple. In the directory ```flytex/README.md```, you can find the basic mechanism behind.



## Flytex

In any of the languages it is written here, it is meant to do what the existing texliveonfly does. There are some points to keep in mind, though:

* *flytex* is primarily designed in *Haskell*. Yet, it is maintained a *Python* version too, that should run on any GNU/Linux distro without installing alien stuff. (In future, *flytex*-es written in other languages may come.)

* Any new feature will be implemented in *Haskell* first and only afterwards in other languages. By the way, I'll do my best to keep them at the same pace. See ```flytex/CHANGELOG.md``` for a history of enhancements, fixes and additions.

The structure of ```flytex``` is simple. If you want the *flytex* written in the language ```LANG```, just look for ```flytex/LANG```: there you will find the program in a single file, its installer (the script ```make.sh```) and uninstaller (the script ```remove.sh```).

We stick to this general rule: the installed program is called ```flytex``` and can be found in ```~/.local/bin```. Thus, make sure ```~/.local/bin``` is in your ```PATH```. The uninstaller just removes ```~/.local/bin/flytex```.

The usage is the same, or almost the same:
```
flytex --c COMPILER [--o OPTIONS] --i FILE_TO_TEX
```
We will try to comply with this convention, but always have a look to ```flytex/LANG/README.md``` for quirks related to specific implementations.
