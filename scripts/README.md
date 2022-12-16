# Scripts

## Install TeX Live

The shell script ```install-texlive``` helps you to install TeX Live on your GNU/Linux. If you accept the defaults listed below, it is sufficient to issue the command
```
$ ./install-texlive
```
and then wait few minutes.

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

### Details

1. Downloads ```install-tl-unx.tar.gz```. If you have passed the option ```--verify-installer```, check its integrity. Then, unpack the compressed archive just downloaded.

3. Start the installer ```install-tl```, and wait it to finish all the work. It should not be required any intervention from the user.

4. Write the file ```~/.tlrc``` to adjust ```PATH``` and make visible all the TeX Live executables and other stuff related to it.

### Post installation

You should append the following line at the end of (for example) ```~/.bashrc```:
```
[ -f ~/.tlrc ] && source ~/.tlrc
```

If you have installed the ```minimal``` scheme, it is recommended to install some extra stuff:
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

You may want to remove the installer:
```
$ rm -rf ~/tl-installer
```