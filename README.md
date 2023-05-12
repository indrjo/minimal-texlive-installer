# Get yourself a *minimal TeX Live*


* [Minimal TeX Live on GNU/Linux](#minimal-tex-live-on-gnulinux)

* [Minimal TeX Live on Android](#minimal-tex-live-on-android)

* [Adding packages to your minimal TeX Live](#adding-packages-to-your-minimal-tex-live)


## Minimal TeX Live on GNU/Linux

The procedure explained here installs TeX Live in your `$HOME`. Thus if you want TeX Live to be accessible to other users, this might not be the best choice for you.

Moreover, it is strongly recommended to read the section [Adding packages to your minimal TeX Live](#adding-packages-to-your-minimal-tex-live) and decide if it is worth.


### Installation

The installation process is thoroughly handled by one of the scripts, `install-texlive`. Running it without any command line parameter is enough:

```sh
$ ./scripts/install-texlive
```

**(Note)** We list here the defaults and how to change them.

* By default `~/.texlive-installer` is the location where the installer is downloaded and unpacked. If you want to specify another place, you can use `--installer-dir=HERE`. **(Attention)** Just be sure you have the permission to write into `HERE`.

* As `install-tl-unx.tar.gz` is downloaded in its directory, you can make `install-texlive` check its integrity for you. Just pass the option `--verify-installer` to do so, because this step is skipped by default.

* The environment variable `TEXLIVE_INSTALL_PREFIX` (the directory where all of TeX Live is allocated) is set to `~/texlive` by default. If you prefer another location, pass the option `--prefix=HERE`. **(Attention)** Just make sure you have the right to write where you want.

* You can select the scheme to install, by passing `--scheme=SCHEME`. Here, `SCHEME` could be for example: `minimal` (the default), `basic`, `small`, `medium`, `full`, etc...

* At the end of the installation an appropriate file that adds to your paths the ones of TeX Live is created. By default, the file is `~/.tlrc`, but you can choose any path you prefer, using `--tlrc=HERE`. Afterwards, you must write on `~/.bashrc` to source this file. It is done for you by default; to prevent that, just pass the option `--no-adjust-bashrc`.

Normally, the installation takes a couple of minutes. Afterwards, you should also

```sh
$ source ~/.bashrc
```

or simply close and re-open your terminal.

The Perl script `./scripts/tlmgr-install-extras.pl` installs extra packages. It is not run by the installer, so you it is up to you. You are encouraged to read and edit the lines below `__DATA__`: there, you will find a list of packages and some comments too; in particular, you will notice that some of them are *strongly recommended*.


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
$ ./scripts/termux-install-minimal-texlive
```

The script manages both installation, post installation process and applies some patches to make it work within the Termux environment.

**(Important)** `termux-install-minimal-texlive` is a modification of `installer.sh` which can be found [here](https://github.com/termux/termux-packages/blob/master/packages/texlive-installer). This piece of code is distributed under the [same licence](https://github.com/termux/termux-packages/blob/master/LICENSE.md) of that work.

**(Note)** Currently, this installer doesn't allow users to customize the installation, as you can for any other GNU/Linux.

You can use `./scripts/tlmgr-install-extras.pl` in this context as well.


### Uninstall

`./scripts/termux-uninstall-texlive` removes TeX Live and all the related stuff. You may further clean your environment using

```sh
$ apt autoremove
```

For this, you need to install `apt` in your Termux (`$ pkg install apt`).



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
# Install every TeX Live packages containing a given filename.
tlmgr-install-missing () {
  tlmgr search --global --file /$1 | \
    perl -lne 'm!^\s*([^:]+):$! && system "tlmgr install $1"'
}
```

Thus, from now on you could just:

```sh
$ tlmgr-install-missing FILENAME
```

**(Attention)** It is not required `/` anymore.

However, when your minimal TeX Live is fresh or you know there is long list of packages you do not have, it may be useful to act differently. Suppose we are within your project and you have a file, say `preamble.tex`, where you have written lines of the form `\usepackage{PACKAGE}`. Then the command:

```sh
$ perl -lne 'm!^\s*\\usepackage[^\{]*\{([^\}]+)\}! && system "tlmgr install $1"' preamble.tex
```

will install all the packages required (if a package is already installed, it is skipped). You may open `~/.bashrc` and write a shortcut:

```sh
# Install every packages required in TeX project: the function here takes the
# file of the \usepackage's as argument, grabs all the names of the packages
# required and installs them.
tlmgr-install-required () {
  perl -lne 'm!^\s*\\usepackage[^\{]*\{([^\}]+)\}! && print "tlmgr install $1"' $1
}
```

to be used as follows:

```sh
$ tlmgr-install-required preamble.tex
```


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

**(Warning)** You may have looked at `$ flytexonfly --help` and played with it. If so, it is worth to note that

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
