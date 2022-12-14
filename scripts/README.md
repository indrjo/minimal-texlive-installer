# Scripts

## Install TeX Live

The script ```install-texlive``` helps you to install TeX Live on your GNU/Linux. If you accept some defaults, it is sufficient to issue the command
```
$ ./install-texlive
```
and then wait few minutes.

The defaults are the following:

* As ```install-tl-unx.tar.gz``` is downloaded, you can make ```install-texlive``` check for you the integrity of the installer. Just pass the option ```--verify-installer``` to do so, because this task is skipped by default.

* ```TEXLIVE_INSTALL_PREFIX``` (the directory where all TeX Live is allocated) is set to ```~/texlive``` by default in this script. If you prefer another location,
```
$ ./install-texlive --prefix=HERE
```
where instead of ```HERE``` put your choice. **(Attention)** Just make sure you have the right to write where you want.

* **(New)** You can select the scheme to install:
```
$ ./install-texlive --scheme=SCHEME
```
Here, ```SCHEME``` could be: ```minimal```, ```basic```, ```small```, ```medium```, ```full```, etc...


### Details

1. Downloads ```install-tl-unx.tar.gz```. If you have passed the option ```--verify-installer```, check its integrity. Then, unpack the compressed archive just downloaded.

3. Start the installer ```install-tl```, and wait it to finish all the work. It should not be required any intervention from the user.

4. Write the file ```~/.tlrc``` to adjust ```PATH``` and make visible all the TeX Live executables and other stuff related to it.

At the end, you should append the following line at the end of (for example) ```~/.bashrc```:

```
[ -f ~/.tlrc ] && source ~/.tlrc
```


### Post installation

If you have installed the ```minimal``` scheme, it is recommended to install some extra stuff to: ```latex-bin```, ```texlive-scripts-extra```, ```texdoc``` and ```texliveonfly```. It is also recommended to install the packages ```hyphen-LANG``` for the languages you use. Here, ```LANG``` could be, for example, ```english```, ```german```, ```french```, ```italian```, and so on...

You may want to remove the installer:
```
$ rm -rf ~/tl-installer
```