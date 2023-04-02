# Get yourself a *minimal TeX Live*


* [Minimal TeX Live on GNU/Linux](#minimal-tex-live-on-gnulinux)

* [Minimal TeX Live on Android](#minimal-tex-live-on-android)

* [Adding packages to your minimal TeX Live](#adding-packages-to-your-minimal-tex-live)



## Minimal TeX Live on GNU/Linux

**(Important)** This procedure installs TeX Live in your own home. So, if you want TeX Live to be accessible to other users, this might not be the best choice.


### Installation

The installation process is thoroughly handled by one of the scripts provided here:

```sh
$ ./scripts/install-texlive
```

Afterwards you should also

```sh
$ source ~/.bashrc
```

The Perl script `./scripts/tlmgr-install-extras.pl` installs extra packages that do not come with the minimal installation. You are encouraged to read it and edit as per your needs and tastes.


### Uninstall TeX Live

The installation script generates a uninstaller script, use it if you want to get rid of all TeX Live:

```sh
$ ~/.texlive-uninstaller
```



## Minimal TeX Live on Android

We use [Termux](https://termux.dev/en/). In that case, you may want to have a look at the [TeX Live page of Termux](https://wiki.termux.com/wiki/TeX_Live), just in case drastic changes occurs.


### Install

It is enough to fire:

```sh
$ ./scripts/termux-install-minimal-texlive
```

You can use `./scripts/tlmgr-install-extras.pl` in this context too.


### Uninstall

There is a script dedicated for that too:

```sh
$ ./scripts/termux-uninstall-texlive
```



## Adding packages to your minimal TeX Live

As we have said, we have installed a *minimal* TeX Live, thus you are supposed to install even the most basic packages.


### Manually

We use *tlmgr* to install packages:

```sh
$ tlmgr install PACKAGE_NAME
```

Assume you run:

```sh
$ pdflatex main.tex
```

If the TeX engine complains it cannot find some file, that is says you

```
! LaTeX Error: File `FILENAME' not found.
```

then you can get the name of the package containing it with *tlmgr*:

```sh
$ tlmgr search --global --file /FILENAME
```

which will give you a list of packages containing it. The `/` is important.

It may be useful to create a function that searches packages for a given filename and installs them for you: open ```~/.bashrc``` and copy the following lines

```sh
# install TeX Live packages
tlmgr-install () {
  tlmgr search --global --file "/$1" | \
  grep -P ':\s*$' | sed 's/\s*:$//' | \
  xargs tlmgr install
}
```


### TeX Live on the fly

We can get it from CTAN via *tlmgr*:

```sh
$ tlmgr install texliveonfly
```

The usage is quite simple:

```sh
$ texliveonfly -c COMPILER YOUR_TEX_FILE
```

Here `COMPILER` can be, for instance, `pdf[la]tex`, `lua[la]tex, `xe[la]tex` or others...

**(Warning)** Although it is a great tool, in few cases it may need some help from the user. For example, you may want to install by yourself some packages after `polyglossia` or `babel`.

```sh
$ tlmgr install hyphen-LANGUAGE
```

(Some of the hyphen packages are: `hyphen-english`, `hyphen-french`, `hyphen-german`, `hyphen-italian` and so on...)

**(Warning)** It seems that

```sh
$ texliveonfly -c COMPILER -a '--synctex=1' FILE.tex
```

(and who knows what else...) turns off the ability to install packages on the fly. However, who cares? Use *texliveonfly* just to get all what you need and got back to the unwrapped engines of TeX Live.


### Criticisms

Maybe you know or have tried [MiKTeX](https://www.miktex.org). Its developers have been working hard to build an ecosystem where packages are downloaded the first time they are required. `texliveonfly.py` tries to emulate this feature and bring it to TeX Live.

Truth be said, that script is a very old software, it was written in 2011 ([click!](https://latex.org/forum/viewtopic.php?f=12&t=15194)). You can find some repositories providing some changes and fixes (for example [this](https://github.com/maphy-psd/texliveonfly) of 2015), but it definitely seems a dead project, since it hasn't been receiving updates anymore from its authors.

Another problem is that it was written on and for the Ubuntu of that era. If you read its source code, you will notice, some old software is invoked. Fortunately, this happens if you want to use `sudo` or similia. If we install all in your home, it seems there is no problem.

Will *texliveonfly* return to life? I hope so, but who knows. If one wants to read its source code and work on it, one hurdle could be that the code is poorly commented. If one wants to write its own *TeX Live on the fly*, this means work from zero, although the idea behind is simple.

You may find useful this project that used to be within this repository: in that case, [click](https://github.com/indrjo/flytex). Of course, it would be finer the TeX Live team provides the *official* installer on the fly.
