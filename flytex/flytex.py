#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#from dataclasses import dataclass
from re          import compile, search, findall, IGNORECASE, MULTILINE
from subprocess  import run
import sys

# Just print a message with some small decoration.
def say(text):
  print(f':: {text}')

# There are two kinds of error messages here: some just tell something is
# wrong but they won't crush the program, whereas others will immediately
# halt the run. By default, error messages are not fatal.
def say_error(text, fatal=False):
  print(f'!! {text}', file=sys.stderr)
  if fatal:
    sys.exit()

# The USAGE string. It will be used for a description of the program later.
usage = 'USAGE: flytex engine file.tex [options]'

# Here is the form of the string we are looking for in our logs.
missing_pattern = compile(r"file `([^']+)' not found", IGNORECASE)

# This function take a string: if has the form of missing_pattern, then it
# will extract a filename, otherwise a None is returned.
def get_missing_fname(string):
  try:
    return search(missing_pattern, string).group(1)
  except AttributeError:
    # !!! If there is no match, search returns a None.
    return None

# Provided a log file produced by some TeX engine, extract all the names of
# the missing files, as indicated by the smaller functions above.
def get_missing_fnames(texlogfile):
  fnames = []
  with open(texlogfile) as loglines:
    for line in loglines:
      fname = get_missing_fname(line)
      if not fname is None:
        fnames.append(fname)
  return fnames

# Given a filename, get from CTAN all the names of the packages owning it.
# For the purpouse we will make the host system run
#
#  $ tlmgr search --global --file /fname
#
# !!! Pay attention to the "/". Should I introduce the possible to choose a
# !!! less strict search?
def tlmgr_search(fname):
  search_proc = run(['tlmgr', 'search', '--global', '--file', '/'+fname],
                    capture_output=True)
  if search_proc.returncode == 0:
    stdout_str = search_proc.stdout.decode()
    return findall(r'\n([^:]+):\n', stdout_str, MULTILINE)
  else:
    say_error(search_proc.stderr.decode())

# Run the TeX machinery, inspect the log and install the needed packages.
def flytex(engine, ftex, options):
  # Create of a pdf document. This part will never halt if the command run
  # halts for some reason. It may halt for other reasons though, but in the
  # main the function flytex will be wrapped in a try-except block.
  run([engine] + options + [ftex], input=(50*'\n').encode())

  # Slurp the log and isolate the names of the absent files.
  ftexlog = ftex.replace('.tex', '.log')
  missing_fnames = get_missing_fnames(ftexlog)

  # See whether the files are contained in some packages. Since they come
  # from a complaint of missing files, these packages are not installed.
  if missing_fnames == []:
    say('no missing files!')
  else:
    # Determine the list of packages to be installed.
    packages = []
    for fname in missing_fnames:
      packages = packages + tlmgr_search(fname)

    # And install them. The failed installation of some package will not
    # prevent the others coming next in the list from being installed.
    installed, not_installed = [], []
    for pkg in packages:
      installation = run(['tlmgr', 'install', pkg])
      if installation.returncode == 0:
        installed.append(pkg)
      else:
        not_installed.append(pkg)

    # A summary of the process is best to be present. If some installation
    # failed, it is best the user knows.
    print('installed: ' +  ', '.join(installed))
    if not_installed == []:
      say('all packages installed!')
    else:
      say_error('NOT installed: ' +  ', '.join(not_installed), True)

if __name__ == '__main__':
  # !!! The arguments of flytex come from the command-line without any kind
  # !!! of sophistication. Non argparse or simila modules for now.
  try:
    engine, file, *options = sys.argv[1:]
  except ValueError:
    say_error(f'{usage}', True)
  try:
    flytex(engine, file, options)
  except Exception as some_exception:
    say_error(some_exception, True)
