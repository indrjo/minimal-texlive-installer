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

* The directory where all of TeX Live is allocated is set to `~/texlive` by default. If you prefer another location, pass the option `--texdir HERE`.

* You can select the scheme to install, by passing `--scheme SCHEME`. Here, `SCHEME` could be for example: `minimal` (the default), `basic`, `small`, `medium`, `full`, etc...

* At the end of the installation an appropriate file that adds to your paths the ones of TeX Live is created. By default, the file is `~/.tlrc`, but you can choose any path you prefer, using `--tlrc HERE`.

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
$ termux-install-texlive
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

I have written a small Python program that takes care to understand install the the packages required by a project but that are not present in your minimal TeX Live. This is small remedy, since it is to be used just once to get the package your TeX Live doen't have.

For instance, if you run

```sh
$ lualatex --synctex=1 main.tex
```

then just prepend `flytex` and move any option passed to you TeX engine at the end:

```sh
$ flytex lualatex main.tex --synctex=1
```

To install *flytex*,

```sh
$ cp ./flytex ~/.local/bin/
```

(Just make sure `~/.local/bin` is in `PATH`.)
