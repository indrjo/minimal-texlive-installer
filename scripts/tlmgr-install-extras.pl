#!/usr/bin/env -S perl -W

# This tiny Perl script installs some basic packages after you have got a 
# minimal TeX Live on your machine.
# Here, there is a short code, concluded by __DATA__. The list of packages
# starts directly below __DATA__. Feel free to edit this list as per your
# personal needs. Blank lines and lines starting by "#" are not considered.

while (my $ln = <DATA>) {
  if ($ln !~ /^\s*(#|$)/) {
    $ln =~ s/^\s+|\s+$//g;
    system "tlmgr install $ln";
  }
}

__DATA__

# !!!
# this is the core of packages we shall have on our machine:
# do not remove the following packages
# !!!

latex-bin
texdoc
texlive-scripts-extra

# !!! customize the list below, instead !!!

# classes
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

# fonts
anyfontsize
libertine
sourcecodepro

# mathematical fonts
libertinust1math
mathalpha
mathtools
mnsymbol
amsthm

# other mathematical stuff
pgf
tikz-cd
commutative-diagrams
tcolorbox
