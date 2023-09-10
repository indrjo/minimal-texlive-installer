#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from dataclasses import dataclass
from re          import compile, search, IGNORECASE
from subprocess  import run
import sys

# Just print a message with some small decoration.
def say(text):
  print(f':: {text}')

# There are two kinds of error messages here: some just communincate something
# is wrong but they won't crush the program, while others will halt everything.
# By default, error messages are not fatal.
def say_error(text, fatal=False):
  print(f'!! {text}', file=sys.stderr)
  if fatal:
    sys.exit()

# The USAGE string. It will be used for a description of the program later.
usage = 'USAGE: flytex engine file.tex [options]'

# We use regular expressions to hunt missing files down. Here is the pattern.
missing_pattern = compile(r"file `([^']+)' not found", IGNORECASE)

# This function take a string: if has the form of missing_pattern, then it will
# extract a filename, otherwise a None is returned.
def get_missing_fname(string):
  try:
    return search(missing_pattern, string).group(1)
  except AttributeError:
    # !!! If there is no match, search returns a None.
    return None

# Provided a log file produced by some TeX engine, extract all the names of the
# missing files, as indicated by the smaller functions above.
def get_missing_fnames(texlogfile):
  fnames = []
  with open(texlogfile) as loglines:
    for line in loglines:
      fname = get_missing_fname(line)
      if not fname is None:
        fnames.append(fname)
  return fnames

# We need a slight modification of the run command: capture exit-code and both
# stdout and stderr as strings, not as byte-strings as run return them.
@dataclass
class ShellResult:
  exit_code:  int
  stdout_str: str
  stderr_str: str

def run_shell_with_outputs(args):
  proc = run(args, capture_output=True)
  return ShellResult(proc.returncode,
                     proc.stdout.decode(),
                     proc.stderr.decode())

# Given a filename, get from CTAN all the names of the packages owning it. For
# the purpouse we will make the host system run
#
#  $ tlmgr search --global --file /fname
#
# !!! Pay attention to the "/".
def tlmgr_search(fname):
  search_proc = run_shell_with_outputs(
    ['tlmgr', 'search', '--global', '--file', '/' + fname])
  if search_proc.exit_code == 0:
    stdout_lines = search_proc.stdout_str.split('\n')
    packages = []
    for line in stdout_lines:
      if line.endswith(':'):
        pkg = line.strip(' :')
        packages.append(pkg)
    return packages
  else:
    say_error(search_proc.stderr_str)

# Run the TeX machinery, inspact the log and install all the needed packages.
def flytex(engine, ftex, options):
  # Start the creation of you pdf document
  run([engine] + options + [ftex], input=(50*'\n').encode())

  # Who cares of the result of the above process? Just inspect the log!
  ftexlog = ftex.replace('.tex', '.log')
  missing_fnames = get_missing_fnames(ftexlog)

  # See if there are packages to be installed.
  if missing_fnames == []:
    say('no missing files!')
  else:
    # Ask tlmgr to install any missing package.
    say_error('missing files: ' + ', '.join(missing_fnames))

    # Determine the packages to be installed.
    packages = []
    for fname in missing_fnames:
      packages = packages + tlmgr_search(fname)

    # Start the installation.
    installed, not_installed = [], []
    for pkg in packages:
      installation = run(['tlmgr', 'install', pkg])
      if installation.returncode == 0:
        installed.append(pkg)
      else:
        not_installed.append(pkg)

    # Enventually, present a summary of what you have done.
    print('packages installed: ' +  ', '.join(installed))
    if not_installed == []:
      say('all packages installed!')
    else:
      say_error('packages NOT installed: ' +  ', '.join(not_installed), True)

if __name__ == '__main__':
  # !!! The arguments of flytex come from the command-line without any kind of
  # !!! sophistication. Non argparse or simila modules for now.
  try:
    engine, file, *options = sys.argv[1:]
  except ValueError:
    say_error(f'{usage}', True)
  try:
    flytex(engine, file, options)
  except Exception as some_exception:
    say_error(some_exception, True)