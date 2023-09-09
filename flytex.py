#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Created on Fri Sep  8 13:16:08 2023

@author: indrjo
"""

from dataclasses import dataclass
from re          import compile, match
from subprocess  import run
#from shutil      import which
import sys

def say(text):
  print(f':: {text}')

def say_error(text, fatal=False):
  print(f'!! {text}', file=sys.stderr)
  if fatal:
    sys.exit()

usage = f'USAGE: {__file__} engine file.tex [options]'

# This is the pattern to be looked for through all the logs.
missing_pattern = compile(r"! LaTeX Error: File `([^']+)' not found.")

# This function dedicated isolates of the name within the brakets as indicated
# in the pattern above. If the match occurs, then the name is returned, else
# a None a given.
def get_missing_fname(string):
  try:
    return match(missing_pattern, string).group(1)
  except (AttributeError, IndexError):
    # If there is no match, a None is returned, thus the AttributeError here.
    # IndexError is just in case the match operation doesn't produce another
    # element after the first.
    return None

# Give a log file produced by some TeX engine, extract alle the names of the
# missing files, as indicated by the smaller functions above.
def get_missing_fnames(texlogfile):
  fnames = []
  with open(texlogfile) as loglines:
    for line in loglines:
      fname = get_missing_fname(line)
      if not fname is None:
        fnames.append(fname)
  return fnames

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

# Provided a filename, interrogate CTAN to get all the names of the packages
# containing that file. For the purpouse we will make the host system run
#
#  $ tlmgr search --global --file /fname
#
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
    print(search_proc.stderr_str)

# Run the TeX machinery, inspact the log and install all the needed packages.
def flytex(engine, ftex, options):
  # Start the creation of you pdf document
  run([engine] + options + [ftex], input=50*'\n'.encode())

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
  # Parse CLI arguemnts.
  try:
    engine, file, *options = sys.argv[1:]
  except ValueError:
    say_error(f'not enough arguments.\n\n{usage}\n', True)

  # Attempt flytex.
  try:
    flytex(engine, file, options)
  except Exception as any_exception:
    say_error(any_exception, True)
