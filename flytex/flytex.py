#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#
# DESCRIPTION
#
# This small script installs TeX Live packages on the fly, that is:
#
# 1. It attempts the processing of them main TeX file to create a document
# 2. It inspects corresponding log file for missing files.
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

from re import findall, I, M
from subprocess import run
import sys

# Just print a message with some small decoration, to distinguish it from
# the output of TeX.
def say(text):
  print(f':: {text}')

# There are two kinds of error messages here: some just tell something is
# wrong but they won't crush the program, whereas others will immediately
# halt the execution. By default, error messages are not fatal.
def say_error(text, fatal=False):
  print(f'!!! {text}', file=sys.stderr)
  if fatal:
    sys.exit()

# The USAGE string. It will be used for a description of the program later.
usage = 'USAGE: flytex engine file.tex'

# Read a TeX log file and list all the missing files.
def get_missing_fnames(texlogfile):
  with open(texlogfile) as file:
    # !!! What if the log file is very big? Could that ever happen?
    contents = file.read().replace('\n', '')
    fnames = findall(r"['\"\`]([^'\"\`]+)['\"\`] not found", contents, I)
  return fnames

# Given a filename, get from CTAN all the names of the packages owning it.
# More precisely, parse the output of
#
#  $ tlmgr search --global --file "/FILENAME"
#
# to extract the names of the resulting packages.
# !!! The output of tlmgr is not exactly "machine readable", resulting in
# !!! this part of code being rather delicate.
def tlmgr_search(fname):
  search_proc = run(['tlmgr', 'search', '--global', '--file', '/'+fname],
                    capture_output=True)
  if search_proc.returncode == 0:
    stdout_str = search_proc.stdout.decode()
    return findall(r'\n([^:]+):\n', stdout_str, M)
  else:
    say_error(search_proc.stderr.decode())

# Run some TeX command. We may leave users the bother to hit Enter every
# time the compilation halts for some reason (for instance, for some file
# cannot be found), but we choose to not do so here.
# !!! There is a limited tolerance though: the script can handle up to 50
# !!! halts by itself. After this amount it is up to the user to hit Enter
# !!! until TeX terminates.
def flytex(engine, ftex):
  run([engine, ftex], input=(50*'\n').encode())
  ftexlog = ftex.replace('.tex', '.log')
  missing_fnames = get_missing_fnames(ftexlog)
  if missing_fnames == []:
    say('no missing files!')
  else:
    packages = []
    for fname in missing_fnames:
      packages_for_fname = tlmgr_search(fname)
      if packages_for_fname is None or packages_for_fname == []:
        say_error('orphan file: ' + fname)
      else:
        packages = packages + packages_for_fname
    installation = run(['tlmgr', 'install'] + packages)
    if installation.returncode != 0:
      say_error(installation.stderr)

if __name__ == '__main__':
  # !!! The arguments of flytex come from the command-line without any kind
  # !!! of sophistication. No argparse or similar modules for now.
  try:
    engine, ftex = sys.argv[1:3]
    try:
      flytex(engine, ftex)
    except Exception as some_exception:
      say_error(some_exception)
  except ValueError:
    say_error(f'{usage}')
