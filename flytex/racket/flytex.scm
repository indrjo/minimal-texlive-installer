#lang racket

#|

  MOTIVATION
  -------------------------------------------------------------------------
  
  This machinery is not complicate at all. If you have the complete scheme
  of TeX Live, commands like
  
    $ your-tex-engine your-file.tex
  
  should conclude painlessly. The compiler will complain if it cannot find
  a package and  will simple abort all the process.
  
  Maybe you know MiKTeX, who has the remarkable feature that withe same
  commands will try to install any missing package need for the creation
  of the final product. It is not a matter of minimalism, but out there is
  a hell of packages: a complete installation of TeX Live takes around 4GB 
  of memory and a lot of time to install. Although all the vivid interest
  in this feature, TeX Live hasn't made a move in this direction yet.
  
  Of course, someone else has thought the same and created a small Python
  script called "texliveonfly" to solve the problem. Unfortunately, this
  the program hasn't been receiving any update since 2011. Although this
  possibility, if you want TeX Live you are encouraged to make a complete
  install, until TeX Live itself provides its own "TeX Live on the fly".
  
  
  THIS PROGRAM
  -------------------------------------------------------------------------
  
  The aim of this tiny program is that of the existent texliveonfly.py. If
  you want, think of this program as a wrapper:
  
    $ runghc flytex.hs --c your-TeX-engine --i your-TeX-file.tex
  
  If you do not indicate the compiler or the file to TeX, the program will
  complain and die. It is not mandatory to specify the options (default: no
  options).
  
  The most complete syntax is:
  
    $ runghc flytex.hs --c TeX-engine --o TeX-options --i TeX-file.tex
  
  (Please always refer to ```runghc flytex.hs --help-all```, since some 
  things may change in the future.)
  
  
  HOW IT WORKS
  -------------------------------------------------------------------------
  
  As we have said, this program is a wrapper of existing TeX programs, as
  pdf[la]tex, lua[la]tex, xe[la]tex, etc... When you run any of them, you
  are described quite in detailed way the process of creation. This program
  just reads all this output for you: as soon as a complaint of missing 
  package is detected, the TeX Live program tlmgr is invoked. Just make sure
  to be connected to internet.
  
  
  REQUIREMENTS
  -------------------------------------------------------------------------
  
  You must have at least a mimimal scheme of TeX Live (you cannot have less
  than this). As such, TeX Live is equipped with tlmgr.
  
  This program is designed having GHC as Haskell compiler. You can compile
  this program, or you can keep it as a script and run it via runghc.
  
|#

;; As you can see from the list of imports below, there are few modules the
;; program requires to work properly.
;;
;; !!! Write an appropriate .cabal file. !!!
;; In *.cabal specify:
;;   base, process, options, regex-pcre
;;
;; !!! No particular version?

;;; THE MAIN

;; Starting in medias res, the main amounts at two big pieces: one is the 
;; function flytex and the other is makeTeXCommand. Roughly speaking, the 
;; latter is the command to be issued to the host system, whereas the first
;; is the core of the program: while texing, needed but abset packages are
;; installed "on the fly".


;;; MAKE THE UNDERLYING SYSTEM DO THINGS

;; There ought be no surprise if we say this program intimately relies on
;; the OS that hosts this program. Our ideal user, as we have already said,
;; is a GNU/Linux user, or even a *nix one.

;; Thus we need a function that sends commands to the system and makes them
;; run. This function is a mere combination of a couple of functions from 
;; System.Process and the return type slightly changed: take a string as
;; input, which is assumed to be a shell command, and make the underlying 
;; system run it.

;; For the future, it s best we use the following functions, which wraps
;; the previous one.


;;; INVOKING TLMGR

;; A minimal TeX Live has tlmgr who handles packages: not only you install
;; packages with it, but you can search packages containing a given file!
;; They are both interesting for our purpose.

;; Installing packages is the simpler part here, you just have to type
;;
;;  $ tlmgr install <pkg>
;;
;; and wait tlmgr to end.

;; It is best we provide a function to perform multiple installations. For
;; a list of packages corresponding to a given missing file, install them
;; one by one; just stop with a Left message as one cannot be installed.

;; Let us turn our focus on searching packages now. To do so, let us start
;; from a descriptive example.
;;
;;  | $ tlmgr search --global --file tikz.sty
;;  | tlmgr: package repository [...]
;;  | biblatex-ext:
;;  |   texmf-dist/tex/latex/biblatex-ext/biblatex-ext-oasymb-tikz.sty
;;  | circuitikz:
;;  |   texmf-dist/tex/latex/circuitikz/circuitikz.sty
;;  | hf-tikz:
;;  |   texmf-dist/tex/latex/hf-tikz/hf-tikz.sty
;;  | interfaces:
;;  |   texmf-dist/tex/latex/interfaces/interfaces-tikz.sty
;;  | kinematikz:
;;  |   texmf-dist/tex/latex/kinematikz/kinematikz.sty
;;  | lwarp:
;;  |   texmf-dist/tex/latex/lwarp/lwarp-tikz.sty
;;  | moderncv:
;;  |   texmf-dist/tex/latex/moderncv/moderncviconstikz.sty
;;  | pgf:
;;  |   texmf-dist/tex/latex/pgf/frontendlayer/tikz.sty
;;  | pinoutikz:
;;  |   texmf-dist/tex/latex/pinoutikz/pinoutikz.sty
;;  | puyotikz:
;;  |   texmf-dist/tex/latex/puyotikz/puyotikz.sty
;;  | quantikz:
;;  |   texmf-dist/tex/latex/quantikz/quantikz.sty
;;  | sa-tikz:
;;  |   texmf-dist/tex/latex/sa-tikz/sa-tikz.sty
;;
;; The first line just tells the repository interrogated. Anyway, the other
;; lines are the ones very interesting: there is a sequence of
;; 
;;  <package>:
;;    <path>
;;
;; where the <path>s end with `tikz.sty`. In this case, we are looking for
;; exactly `tikz.sty`, then we want only `pgf`.

;; Thus part of the work is to extract from the sequence of
;; 
;;  <package>:
;;    <path>
;;
;; the packages containing the given file.

;; Make tlmgr look for packages containing the given file.

;; Now, let us combine the tasks above into one: search and install all the
;; packages containing a given file.


;;; PREPARE THE COMMAND TO BE RUN

;; For future readability and changes, let us take advantage of unnecessary
;; type synonyms.

;; Here the command to issue to the system with its Show instance.

;; This is the point where commandline arguments enters the scene.
;; This program supports only three options:
;;
;;   # the TeX program to be used     [mandatory, no default!]
;;   # the options to be passed to it [default: ""]
;;   # the file to be TeX-ed.         [mandatory, of course]
;;
;; For the future: maybe insert more useful defaults here.

;; Options for flytex...

;; Read the command line options passed to the program and either create a
;; TeXCommand to be issued to the system or present a complaint.


;;; TEXLIVE ON THE FLY

;; This giant function takes a TeXCommand element and make the underlying 
;; system run it. If no error arises, fine; otherwise, the program tries to
;; detect missing files, looks for missing packages containing it and
;; installs them; thus, a new attempt to run the same TeXCommand is made.

;; Inspect a string for a certain pattern to get the name of the missing
;; package. The output is always a list with length <=1.


;; HOW THE PROGRAM COMMUNICATES

;; !!! No fatal massages here, that is no message will abort the execution
;; !!! of flytex. This feature may change or not, but for now that's it.

