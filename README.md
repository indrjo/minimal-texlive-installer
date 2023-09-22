# Get yourself a *minimal* TeX Live


* [Minimal TeX Live on GNU/Linux](#minimal-tex-live-on-gnulinux)

* [Minimal TeX Live on Android](#minimal-tex-live-on-android)

* [Adding packages to your minimal TeX Live](#adding-packages-to-your-minimal-tex-live)



## Minimal TeX Live on GNU/Linux

The procedure described here installs TeX Live into your `$HOME`. Thus if you want TeX Live to be accessible to other users, this might not be the best choice for you.

It is strongly recommended to read the section [Adding packages to your minimal TeX Live](#adding-packages-to-your-minimal-tex-live) and decide if it is worth.


### Installation

The installation process is thoroughly handled by `install-texlive`. Running it without any parameter is enough:

```sh
$ ./install-texlive
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

Another script, namely `tlmgr-install-extras`, installs extra packages. It is not run by the installer, so you it is up to you. There, you will find a list of packages and some comments too; in particular, you will notice that some of them are *strongly recommended*. Read and edit it, as per your needs.


### Uninstall TeX Live

The installation script generates an appropriate uninstaller, so use it if you want to (or have) get rid of TeX Live:

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

As we said, we have installed a *minimal* TeX Live: that is you are supposed to install even the most basic packages. Below there are some useful recommendations.


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
$ tlmgr search --global --file "/FILENAME"
```

which will give you a list of packages containing it.

**(Attention)** The `/` is important, make sure you type it.

It may be useful to create a function that searches packages for a given filename and installs them for you: open `~/.bashrc` and copy the following lines

```sh
# Interrogate CTAN for packages containing a given file.
tlmgr_search () {
  tlmgr search --global --file "/$1" | perl -lne "/([^:]+):$/ && print \$1"
}

# Install ALL the packages listed by `tlmgr_search`.
tlmgr_search_install () {
  tlmgr_search "$1" | xargs tlmgr install
}
```

This provides you two new functions you can use once you have sourced `~/.bashrc`, even though you will likely use only the latter:

```sh
$ tlmgr_search_install FILENAME
```

**(Attention)** It is not required `/` anymore.


### TeX Live on the fly

The instructions of the previous section might not be practical if the list of the absent packages is long. Here are some tools that automate that boring task.

In `./flytex` you can find some scripts, all doing the same thing: understanding and  installing packages required by a project but that are not present in your *minimal* TeX Live.

The programs of `./flytex` have not an official name yet, and sometimes we will happen to refer to them all as *flytex*.

These programs are rather workaraounds to enrich TeX Live as needed: as you have all the packages needed installed, you can return to how your usual workflow. Indeed, these programs should not be used more than they are supposed to.

For instance, if you run

```sh
$ lualatex --synctex=1 --shell-escape main.tex
```

then just prepend `flytex` and forget the options:

```sh
$ flytex lualatex main.tex
```

To install *flytex* just copy one of the scripts in `./flytex` to any location you want and make it executable: for example

```sh
$ cp ./flytex/flytex.py ~/.local/bin/flytex
$ chmod u+x ~/.local/bin/flytex
```

(Just make sure `~/.local/bin` is present in `PATH`.)

**(Attention)** You may have to run *flytex* more than once, because dependencies may be quite intricate.
