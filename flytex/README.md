# How flytex works


## The idea behind

First of all, your language shall be capable of running a shell command on your machine. In Haskell, we have ```readCreateProcessWithExitCode``` and ```shell``` composable in one function. In Python, there is ```Popen``` which provides a process object and the related methods ```communicate``` and ```returnexitcode```. You need such interface to make your host system run commands like ```$ pdflatex hello.tex```.

**To be continued...**