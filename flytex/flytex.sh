#!/usr/bin/env sh

#
# DESCRIPTION
#
# This small script installs TeX Live packages on the fly, that is:
#
# 1. It attempts the processing of the main TeX file to create a document
# 2. It inspects the corresponding log file for missing files.
# 3. Interrogate CTAN to get the names of the packages owning them, and
#    install them right away.
#
# USAGE
#
# If you are used to write, for instance
#
#   $ lualatex --shell-escape --synctex=1 main.tex
#
# to create your documents, then you have just to
#
#   $ flytex lualatex main.tex
#
# That is: prepend flytex and forget the options. Indeed, this program is
# rather a workaround: use it for the first when you suspect your TeX Live
# might not have all the needed stuff and then return to your habits.
#

set -o pipefail

# Determine from the command-line interface the TeX engine to be employed,
# the options passed it and the main file to be processed.
engine="$1"
ftex="$2"

# The log file is just the main file's name with ".log" in place of ".tex".
flog="${ftex%.tex}.log"

# Communicate to user with a small decoration, in order to  distinguish it
# from the output of the employed TeX engine. 
_say () {
  echo -e "\n(flytex) $1\n"
}

# Drop some error message end halt the run of this script.
_die () {
  echo -e "\n(flytex-error) $1\n"
  exit 1
}

# Read a TeX log file and list all the missing files.
_get_missing_fnames () {
  perl -lne "/['\`\"]([^'\`\"]+)['\`\"] not found/ && print \$1" "$1"
}

# Parse the output of
#
#  $ tlmgr search --global --file "/FILENAME"
#
# to extract the names of the resulting packages.
# !!! The output of tlmgr is not exactly "machine readable", resulting in
# !!! this part of code being rather delicate.
_get_package_names () {
  perl -lne "/([^:]+):$/ && print \$1"
}

# Run some TeX command. We may leave users the bother to hit Enter every
# time the compilation halts for some reason (for instance, for some file
# cannot be found), but we choose to not do so here.
# !!! There is a limited tolerance though: the script can handle up to 50
# !!! halts by itself. After this amount it is up to the user to hit Enter
# !!! until TeX terminates. I am considering to use `timeout` here...
perl -e 'print "\n"x50' | max_print_line=1000 "$engine" "$ftex"

# Time for the actual flytex...
_say "interrogating CTAN and getting missing packages..."

# Test internet connection, it will be needed. The get the repos' urls, we
# take advantage of the output of `tlmgr repository list`.
tlmgr repository list | grep -oP 'http\S+' \
  | xargs wget -q --spider || _die "cannot reach CTAN!"

# All the program in "one" line...
_get_missing_fnames "$flog" \
  | xargs -I % sh -c 'tlmgr search --global --file "/%"' \
  | _get_package_names | xargs tlmgr install
