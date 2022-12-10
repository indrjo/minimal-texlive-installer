
# Installing minimal TeX Live with Termux

The script ```install``` here is a modification of ```installer.sh```, which can be found [here](https://github.com/termux/termux-packages/blob/master/packages/texlive-installer/installer.sh).

**(Warning)** This script modifies some parts of the package ```texlive-installer``` after it is installed. This behaviour is expected to change in future.


## Usage

It is sufficient to fire
```
$ ./install-minimal
```
from within your Termux. 

**(Warning)** Currently, this installer doesn't allow users to customize the installation though, say, command-line arguments.