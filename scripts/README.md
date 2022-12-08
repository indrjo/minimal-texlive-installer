# Scripts

## The installer

The minimal TeX Live installer here is the shell script ```install-minimal```.

If you want to stick to few defaults, it is sufficient to issue the command
```
$ ./install-minimal
```
and wait few minutes.

Here the defaults are the following:

* As ```install-tl-unx.tar.gz``` is downloaded, you can make ```install-minimal``` check for you its integrity. If you want that, just pass the option ```--verify-installer```.

* ```TEXLIVE_INSTALL_PREFIX``` (the directory where all TeX Live is allocated) is set to ```~/texlive```. If you prefer another location,
```
$ ./install-minimal --prefix=HERE
```
where instead of ```HERE``` put your choice. Just make sure you have the right to write where you want.

### What ```install-minimal``` does

1. Downloads ```install-tl-unx.tar.gz```. If you have passed the option ```--verify-installer```, check its integrity. Then, unpack the compressed archive just downloaded.

3. Start the installer ```install-tl```, and wait it to finish all the work. It should not be required any intervention from the user.

4. Write the file ```~/.tlrc``` to adjust ```PATH``` and make visible all the TeX Live executables and other stuff related to it.

5. Install some extra stuff: ```latex-bin```, ```texlive-scripts-extra```, ```texdoc``` and ```texliveonfly```.

At the end, you should append the following line at the end of (for example) ```~/.bashrc```:

```
[ -f ~/.tlrc ] && source ~/.tlrc
```