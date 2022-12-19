#!/usr/bin/env perl -W

open(my $inh, '<', 'extra-installs.txt') or die "$!\n";
while (my $ln = <$inh>) {
  if ($ln !~ /^\s*(#|$)/) {
    $ln =~ s/^\s+|\s+$//g;
    system "tlmgr install $ln";
  }
}
close($inh);

