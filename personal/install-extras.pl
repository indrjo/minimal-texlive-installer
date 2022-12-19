#!/usr/bin/env perl -W

# This tiny Perl script install some basic packages after you have got your
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

# base packages for me
suftesi
fontspec
polyglossia
mycrotype
csquotes
hyperref
biblatex
pgf

# fonts
libertine
sourcedepro

# mathematical fonts
libertinust1math
mathalfa
mathtools
MnSymbol

# other mathematical stuff
tikzcd
commutative-diagrams

