# Get yourself a *minimal* TeX Live


* [Minimal TeX Live on GNU/Linux](#minimal-tex-live-on-gnulinux)

* [Minimal TeX Live on Android](#minimal-tex-live-on-android)

* [Adding packages to your minimal TeX Live](#adding-packages-to-your-minimal-tex-live)



## Minimal TeX Live on GNU/Linux

The procedure explained here installs TeX Live in your `$HOME`. Thus if you want TeX Live to be accessible to other users, this might not be the best choice for you.

Moreover, it is strongly recommended to read the section [Adding packages to your minimal TeX Live](#adding-packages-to-your-minimal-tex-live) and decide if it is worth.


### Installation

The installation process is thoroughly handled by one of the scripts, `install-texlive`. Running it without any command line parameter is enough:

```sh
$ install-texlive
```

**(Note)** We list here the defaults and how to change them.

* By default `~/.texlive-installer` is the location where the installer is downloaded and unpacked. If you want to specify another place, you can use `--installer-dir=HERE`.

* The directory where all of TeX Live is allocated is set to `~/texlive` by default. If you prefer another location, pass the option `--texdir=HERE`.

* You can select the scheme to install, by passing `--scheme=SCHEME`. Here, `SCHEME` could be for example: `minimal` (the default), `basic`, `small`, `medium`, `full`, etc...

* At the end of the installation an appropriate file that adds to your paths the ones of TeX Live is created. By default, the file is `~/.tlrc`, but you can choose any path you prefer, using `--tlrc=HERE`.

Normally, the installation takes a couple of minutes. Afterwards, you should also

```sh
$ source ~/.bashrc
```

or simply close and re-open your terminal.

Another script, namely `tlmgr-install-extras`, installs extra packages. It is not run by the installer, so you it is up to you. There, you will find a list of packages and some comments too; in particular, you will notice that some of them are *strongly recommended*.


### Uninstall TeX Live

The installation script generates an appropriate uninstaller, so use it if you want to (or must) get rid of TeX Live:

```sh
$ ~/.texlive-uninstaller
```



## Minimal TeX Live on Android

We need [Termux](https://termux.dev/en/): to be precise, TeX Live will be installed within that environment. You may want to have a look at the [TeX Live page of Termux](https://wiki.termux.com/wiki/TeX_Live), just in case drastic changes occurs and this repo is not updated.


### Install

Open Termux and issue the command

```sh
$ termux-install-minimal-texlive
```

The script manages both installation, post installation process and applies some patches to make it work within the Termux environment.

**(Important)** The script is a modification of `installer.sh` which can be found [here](https://github.com/termux/termux-packages/blob/master/packages/texlive-installer). This piece of code is distributed under the [same licence](https://github.com/termux/termux-packages/blob/master/LICENSE.md) of that work.

**(Note)** Currently, this installer doesn't allow users to customize the installation, as you can for any other GNU/Linux.

You can use `tlmgr-install-extras` in this context as well.


### Uninstall

`termux-uninstall-texlive` removes TeX Live and all the related stuff. You may further clean your environment using

```sh
$ apt autoremove
```

For this, you need to install `apt` in your Termux (run `pkg install apt`).



## Adding packages to your minimal TeX Live

As we have said, we have installed a *minimal* TeX Live, thus you are supposed to install even the most basic packages. Below are some recommendations.


### Install manually

We use *tlmgr* to install packages for TeX Live:

```sh
$ tlmgr install PACKAGE_NAME
```

Now, assume you run:

```sh
$ pdflatex main.tex
```

If the TeX engine complains it cannot find some file:

```
! LaTeX Error: File `FILENAME' not found.
```

then you can get the name of the package containing it with *tlmgr*:

```sh
$ tlmgr search --global --file /FILENAME
```

which will give you a list of packages containing it.

**(Attention)** The `/` is important, make sure you type it.

It may be useful to create a function that searches packages for a given filename and installs them for you: open `~/.bashrc` and copy the following lines

```sh
# This function accepts a filename, the one of the warning
#
#  ! LaTeX Error: File `FILENAME' not found.
#
# Interrogate CTAN for packages containing that file.
tlmgr-search () {
  tlmgr search --global --file "/$1" | grep -P ':$' | tr -d ':'
}

# Install ALL the packages listed by `tlmgr-search-packages`.
tlmgr-search-install () {
  tlmgr-search "$1" | xargs tlmgr install
}
```

This provides you two new functions you can use once you have sourced `~/.bashrc`, even though you will likely use only the latter:

```sh
$ tlmgr-search-install FILENAME
```

**(Attention)** It is not required `/` anymore.


### TeX Live on the fly

The methods above should not present unpleasant surprise, but the user has the right to not be bothered. There is a tool that while producing your document installs any missing package required during that process.

Its name is *texliveonfly*, and we can get it from CTAN via *tlmgr*:

```sh
$ tlmgr install texliveonfly
```

The usage is quite simple:

```sh
$ texliveonfly -c TEXENGINE YOUR_TEX_FILE
```

Here `TEXENGINE` can be, for instance, `pdflatex`, `lualatex`, `xelatex` or others... You may drop the part `-c TEXENGINE` if you work with `pdflatex`.

**(Warning)** You may have looked at `flytexonfly --help` and played with it. If so, it is worth to note that

```sh
$ texliveonfly -c TEXENGINE -a '--synctex=1' FILE.tex
```

(and who knows what else...) turns off the ability to install packages on the fly. By the way, who cares? Use *texliveonfly* just to get all what you need and got back to the genuines engines of TeX Live.


### Criticisms

Maybe you know or have tried [MiKTeX](https://miktex.org/). Its developers have been working hard to build an ecosystem where packages are downloaded the first time they are required. `texliveonfly.py` tries to emulate this feature and bring it to TeX Live.

Truth be said, that script is a very old software, it was written in 2011 ([click!](https://latex.org/forum/viewtopic.php?f=12&t=15194)). You can find some repositories providing some changes and fixes (for example [this](https://github.com/maphy-psd/texliveonfly) of 2015), but it definitely seems a dead project, since it hasn't been receiving updates anymore from its authors.

Another problem is that it was written on and for the Ubuntu of that era. If you read its source code, you will notice, some old software is invoked. Fortunately, this happens if you want to use `sudo` or similia. If we install all in your home, it seems there is no problem.

Will *texliveonfly* return to life? I hope so, but who knows. If one wants to read its source code and work on it, one hurdle could be that the code is poorly commented. If one wants to write its own *TeX Live on the fly*, this means work from zero, although the idea behind is simple.

You may find useful this project that used to be within this repository: in that case, [click](https://github.com/indrjo/flytex). Of course, it would be finer the TeX Live team provides the *official* installer on the fly.
