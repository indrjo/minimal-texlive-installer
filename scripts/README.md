# Helper scripts



## Install TeX Live on GNU/Linux

The script `install-texlive` helps you to install TeX Live on GNU/Linux. You may want to read [this section](#defaults-and-customizations) before. If you accept the defaults, it is sufficient to run it:

```
$ ./install-texlive
```

and then wait a few minutes.

Eventually, the script writes a file called `.tlrc` in you home, which adjusts some paths for TeX Live. Afterwards, the following lines

```sh
# Register TeX Live paths
[ -f ~/.tlrc ] && source ~/.tlrc
```

are appended to your `~/.bashrc`. Furthermore, the installer takes care to write the uninstaller `~/.texlive-uninstaller` for the TeX Live just installed.

### Options

`install-texlive` accepts some options.

* By default `~/.texlive-installer` is the location where the installer is downloaded and unpacked. If you want to specify another place, you can use `--installer-dir=HERE`. **(Attention)** Just be sure you have the permission to write into `HERE`.

* As `install-tl-unx.tar.gz` is downloaded in its directory, you can make `install-texlive` check its integrity for you. Just pass the option `--verify-installer` to do so, because this step is skipped by default.

* The environment variable `TEXLIVE_INSTALL_PREFIX` (the directory where all of TeX Live is allocated) is set to `~/texlive` by default. If you prefer another location, pass the option `--prefix=HERE`. **(Attention)** Just make sure you have the right to write where you want.

* You can select the scheme to install, by passing `--scheme=SCHEME`. Here, `SCHEME` could be for example: `minimal` (the default), `basic`, `small`, `medium`, `full`, etc...

* At the end of the installation an appropriate file that adds to your paths the ones of TeX Live is created. By default, the file is `~/.tlrc`, but you can choose any path you prefer, using `--tlrc=HERE`. Afterwards, you must write on `~/.bashrc` to source this file. It is done for you by default; to prevent that, just pass the option `--no-adjust-bashrc`.


## Uninstall TeX Live from GNU/Linux

The installer prepared for you the uninstaller, `~/.texlive-uninstaller`: use it.


## Install TeX Live on Android

It is sufficient to issue the command

```sh
$ ./termux-install-minimal-texlive
```

from Termux. It manages both installation and post installation process and applies some patches to make it work within the Termux environment.

**(Important)** The script `install` here is a modification of `installer.sh`, which can be found [here](https://github.com/termux/termux-packages/blob/master/packages/texlive-installer). This piece of code is distributed under the [same licence](https://github.com/termux/termux-packages/blob/master/LICENSE.md) of that work.

**(Note)** Currently, this installer doesn't allow users to customize the installation, as you can for any other GNU/Linux.


## Uninstall TeX Live from Android

The script `termux-uninstall-texlive` removes TeX Live and all its related stuff. You may further clean your environment using

```sh
$ apt autoremove
```

For this, you need to install `apt` in your Termux (`$ pkg install apt`).
