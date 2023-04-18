#!/usr/bin/env -S perl -W

# This tiny Perl script installs some basic packages after you have got a 
# minimal TeX Live on your machine.
# Here, there is a short code, concluded by __DATA__. The list of packages
# starts directly below __DATA__. Feel free to edit this list as per your
# personal needs. Blank lines and lines starting by "#" are not considered.
while (my $ln = <DATA>) {
  if ($ln !~ /^\s*(#|$)/) {
    $ln =~ s/^\s+|\s+$//g;
    system "tlmgr install @ARGV $ln";
  }
}

__DATA__

# The minimal installation has not the following packages shipped, although
# they are essential: latex-bin provides binaries for pdflatex, lualatex,
# xelatex and so on...; latex-base-dev is a collection of other useful code
# for the LaTeX ecosystem; texdoc allows you to access documentation for
# installed packages; texlive-scripts-extra is a collection of scripts for
# the TeX Live environment. We recommend you to install at least them.

latex-bin
latex-base-dev
texdoc
texlive-scripts-extra

# Modify the list below, instead.

# classes
standalone
suftesi

# base packages
fontspec
polyglossia
babel
hyphen-english
hyphen-german
hyphen-french
hyphen-italian
hyphen-greek
microtype
csquotes
hyperref
biblatex
biber
adjustbox
booktabs
imakeidx
geometry
enumitem
xifthen

# fonts
anyfontsize
libertine
sourcecodepro

# mathematical stuff
libertinust1math
mathalpha
mathtools
mnsymbol
amscls
amsmath
pgf
tikz-cd
commutative-diagrams
extarrows
tcolorbox
thmtools

