#!/usr/bin/env perl -W

# This tiny Perl script installs some basic packages after you have got your
# minimal TeX Live. The list of packages starts directly below __DATA__.
# Feel free to edit this list as your personal needs. Blank lines and lines
# starting by "#" are not taken into account, so use them to organize your
# list and add comments.

while (my $ln = <DATA>) {
  if ($ln !~ /^\s*(#|$)/) {
    $ln =~ s/^\s+|\s+$//g;
    system "tlmgr install $ln";
  }
}

__DATA__

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
pgf

# fonts
libertine
sourcecodepro

# mathematical fonts
libertinust1math
mathalpha
mathtools
mnsymbol

# other mathematical stuff
tikz-cd
commutative-diagrams

