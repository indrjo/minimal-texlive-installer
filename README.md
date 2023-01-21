# Get yourself a minimal TeX Live

* [Preamble](#preamble)

* [Minimal TeX Live on GNU/Linux](#minimal-tex-live-on-gnulinux)

* [Minimal TeX Live on Android](#minimal-tex-live-on-android)

* [TeX Live on the fly](#tex-live-on-the-fly)



## Preamble

Here we provide some instructions to install a **minimal TeX Live** on GNU/Linux. Here, *minimal* means that you have a bare core that can be easily enriched though. This can be done via a small Python script, [```texliveonfly.py```](https://www.ctan.org/pkg/texliveonfly). From now on, we will refer to this program as *texliveonfly*.

Loosely speaking, *texliveonfly* is a wrapper of programs that TeX Live has or could be added to. For instance, the command
```
$ texliveonfly --compiler lualatex hello-world.tex
```
issues to the host system the command
```
$ lualatex hello-world.tex
```
However, this command alone would fail and complain if some package is absent. The wrapper receives that complaint for you and tries to install the necessary *on the fly*, using the package mangaer of TeX Live, *tlmgr*.

Of course, you should not use *texliveonfly* as you use your favourite TeX engine. The idea is: I know a certain TeX work needs packages I know I don't have; then, I use *texliveonfly* just once, in order to retrieve any missing package.

**(Attention)** There is a [dedicated section below](#tex-live-on-the-fly) for this script: you may want to read that before.

**(Attention)** In the directory ```./scripts```, there is a collection of tiny shell scripts automating various parts of the installation process explained in the sections below. If you cannot be bothered, then you may move there and read ```./scripts/README.md``` for a quick installation.



## Minimal TeX Live on GNU/Linux

This procedure installs TeX Live in your own home. So, if you want TeX Live to be accessible to other users, this might not be the best choice. The installation process does not mess your home up, as just two new directories are created: one is ```~/texlive``` and the other is ```~/.texlive``` (or some variation...). Thus, if you want to get rid of TeX Live, you know what to remove.


### Installation

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

We use [Termux](https://termux.dev/en/). In that case, you may want to have a look at the [TeX Live page of Termux](https://wiki.termux.com/wiki/TeX_Live), just in case drastic changes occurs.

The installation on Android requires some work that we shall not explain here. In ```./scripts``` you can find one ```README.md``` that will give you more details and some scripts you can read.



## TeX Live on the fly

We can get it from CTAN via *tlmgr*
```
$ tlmgr install texliveonfly
```
As we have anticipated, the usage is quite simple:
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
(and who knows what else...) turns off the ability to install packages on the fly. However, who cares? Use *texliveonfly* just to get all what you need and got back to the unwrapped engines of TeX Live.


### Criticisms

Maybe you know or have tried [MiKTeX](https://www.miktex.org). Its developers has been working hard to build an ecosystem where packages are downloaded the first time they are required. *texlive* on the fly tries to emulate this feature and bring it to TeX Live.

Truth be said, the script ```texliveonfly.py``` is a very old software, it was written in 2011 ([click!](https://latex.org/forum/viewtopic.php?f=12&t=15194)). You can find some repositories providing some changes and fixes (for example [this](https://github.com/maphy-psd/texliveonfly) of 2015), but it definitely seems a dead project, since it hasn't been receiving updates anymore from its authors.

Another problem is that it was written on and for the Ubuntu of that era. If you read its source code, you will notice, some old software is invoked. Fortunately, this happens if you want to use ```sudo``` or *similia*. If we install all in your home, it seems there is no problem.

Will *texliveonfly* return to life? I hope so, but who knows. If one wants to read its source code and work on it, one hurdle could be that the code is poorly commented. If one wants to write its own *TeX Live on the fly*, this means work from zero, although the idea behind is simple.

You may find useful this project that started as a part of this repo: in that case, [click](https://github.com/indrjo/flytex). Of course, it would be finer the TeX Live team provides an official installer on the fly embedded in that ecosystem.
