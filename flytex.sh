#!/usr/bin/env sh

set -o pipefail

#
# This small script does is a simple TeX Live package manager on the fly
# written is sh, and does the following things:
#
# 1. It attempts the processing of them main TeX file to create a document
# 2. it inspects corresponding log file for missing files
# 3. interrogate CTAN to get the names of the packages owning them, and
#    install them right away.
#

# If you are used to write, for instance
#
#   $ lualatex --shell-escape --synctex=1 main.tex
#
# Then, if you want to use this script, you have to
#
#   $ flytex lualatex main.tex --shell-escape --synctex=1
#
# That is: prepend flytex and move the options to the end.

# Determine from the command-line interface the TeX engine to be employed,
# the options passed it and the main file to be processed.
engine="$1"
ftex="$2"
shift;shift;
opts="$@"

# The log file is just the main file's name with ".log" in place of ".tex".
flog="${ftex%.tex}.log"

_say () {
  echo ":: $1"
}

_die () {
  echo "!! $1"; exit
}

# Take a log file as argument and get all the names of the missing files.
_get_missing_fnames () {
  grep -iE 'file \S+ not found' "$1" | sed -E "s/.*\`([^']+)'.*/\1/"
}

# Interrogate CTAN and get the list of the packages owning some file.
_tlmgr_search () {
  tlmgr search --global --file "/$1" | grep -P ':$' | sed 's/:$//'
}

export -f _tlmgr_search

# Test internet connection, it will be needed.
wget -q --spider "google.com" || _die "no internet connection!"

# Run the TeX command. We may leave users the bother to hit Enter every
# time the compilation halts for some reason. Some missing files results
# entire packages not being installed, thus the compilation will halt for
# other reasons as well.
# !!! The script takes care of at most 50 halts: after this amount, it is
# !!! up to you to hit the Enter key until the TeX machinery terminates.
perl -e 'print "\n"x50' | "$engine" "$opts" "$ftex"

_say ""
_say "TeX has finished! Now it is time for flytex..."
_say ""

# All the program in one line...
_get_missing_fnames "$flog" \
  | xargs -I % sh -c '_tlmgr_search %' \
  | xargs tlmgr install
