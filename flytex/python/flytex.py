#!/usr/bin/env python

import subprocess as prc
import shlex as sh
import sys
import re

# -------------------------------------------------------------------------
# HOW THE PROGRAM COMMUNICATES
# -------------------------------------------------------------------------

# The general way, to say things.
def say(hdl, who, text):
  print('[' + who + '] ' + text, file=hdl)

def flytex_says(text):
  say(sys.stdout, 'flytex', text)

def flytex_says_error(text):
  say(sys.stderr, 'flytex-error', text)

def tlmgr_says(text):
  say(sys.stdout, 'tlmgr', text)

def tlmgr_says_error(text):
  say(sys.stderr, 'tlmgr-error', text)


#--------------------------------------------------------------------------
# MAKE THE UNDERLYING SYSTEM DO THINGS
#--------------------------------------------------------------------------

# There ought be no surprise if we say this program intimately relies on
# the OS that hosts this program. Our ideal user, as we have already said,
# is a GNU/Linux user, or even a *nix one.

# Thus we need a function that sends commands to the system and makes them
# run. This function is a mere combination of a couple of functions from 
# System.Process and the return type slightly changed: take a string as
# input, which is assumed to be a shell command, and make the underlying 
# system run it.
def exec_sys_cmd(cmd, inp=''):
  process = prc.Popen(
        sh.split(cmd), stdin=prc.PIPE, stdout=prc.PIPE, stderr=prc.PIPE)
  out, err = process.communicate(input=inp)
  exit_code = process.returncode
  return \
      exit_code \
    , out.decode('UTF-8').strip() \
    , err.decode('UTF-8').strip()

# For the future, it s best we use the following functions, which wraps
# the previous one.
def flytex_exec(cmd, inp=''):
  flytex_says('running \'' + cmd + '\'...')
  return exec_sys_cmd(cmd)


#--------------------------------------------------------------------------
# INVOKING TLMGR
#--------------------------------------------------------------------------

# A minimal TeX Live has tlmgr who handles packages: not only you install
# packages with it, but you can search packages containing a given file!
# They are both interesting for our purpose.

# Installing packages is the simpler part here, you just have to type
#
#  $ tlmgr install <pkg>
#
# and wait tlmgr to end.
def tlmgr_install(pkg):
  exit_code = flytex_exec('tlmgr install ' + pkg)[0]
  exit_text = \
    'installed \'' + pkg + '\'' if exit_code == 0 \
    else 'cannot install \'' + pkg + '\'!'
  return exit_code, exit_text

# It is best we provide a function to perform multiple installations. For
# a list of packages corresponding to a given missing file, install them
# one by one; just stop with a Left message as one cannot be installed.
def tlmgr_multiple_install(fp, pkgs):
  for pkg in pkgs:
    (exit_code, exit_text) = tlmgr_install(pkg)
    if exit_code != 0:
      return (exit_code, exit_text)
  return (0, 'all missing packages for \'' + fp + '\' installed')

# Let us turn our focus on searching packages now. To do so, let us start
# from a descriptive example.
#
# | $ tlmgr search --global --file caption.sty
# | tlmgr: package repository [...]
# | caption:
# | 	 texmf-dist/tex/latex/caption/bicaption.sty
# | 	 texmf-dist/tex/latex/caption/caption.sty
# | 	 texmf-dist/tex/latex/caption/ltcaption.sty
# | 	 texmf-dist/tex/latex/caption/subcaption.sty
# | ccaption:
# | 	 texmf-dist/tex/latex/ccaption/ccaption.sty
# | lwarp:
# | 	 texmf-dist/tex/latex/lwarp/lwarp-caption.sty
# | 	 texmf-dist/tex/latex/lwarp/lwarp-ltcaption.sty
# | 	 texmf-dist/tex/latex/lwarp/lwarp-mcaption.sty
# | 	 texmf-dist/tex/latex/lwarp/lwarp-subcaption.sty
# | mcaption:
# | 	 texmf-dist/tex/latex/mcaption/mcaption.sty
#
# The first line just tells the repository interrogated, we cannot do not
# care here. The other lines are the ones very interesting: there is a
# sequence of
# 
#  package:
#    path1
#    path2
#    ...
#    pathN
#
# In our example, the paths end with `caption.sty`. In this case, we are
# looking for exactly `caption.sty` and not for, say, `ccaption.sty`. This
# problem can be easily solved putting a "/", as follows:
#
# | $ tlmgr search --global --file /caption.sty
# | tlmgr: package repository [...]
# | caption:
# | 	 texmf-dist/tex/latex/caption/caption.sty
#
# Thus part of the work is to extract from such lines only the names of 
# the packages containing the given file: concretely, this means to filter
# the lines ending with ":".
def find_packages(lns):
  pkgs = []
  for ln in lns:
    if ln.endswith(':'):
      pkg = ln[:-1]
      pkgs.append(pkg)
  return pkgs

# Make tlmgr look for packages containing the given file.
def tlmgr_search(fp):
  exit_code, out_str, err_str = \
    flytex_exec('tlmgr search --global --file /' + fp)
  if exit_code == 0:
    pkgs_paths = out_str.split('\n')
    if len(pkgs_paths) >= 1:
      pkgs_found = find_packages(pkgs_paths[1:])
      return exit_code, None if pkgs_found == [] else pkgs_found
    else:
      return exit_code, None
  else:
    return exit_code, err_str

# Now, let us combine the tasks above into one: search and install all the
# packages containing a given file.
def tlmgr_search_and_install(fp):
  (exit_code, search_res) = tlmgr_search(fp)
  if exit_code == 0:
    if search_res == None:
      return (1, 'nothing to install for \'' + fp + '\'!')
    else:
      # search_res in this case is a list
      return tlmgr_multiple_install(fp, search_res)
  else:
    return (exit_code, search_res)


#--------------------------------------------------------------------------
# PREPARE THE COMMAND TO BE RUN
#--------------------------------------------------------------------------

# This is the point where commandline arguments enters the scene.
# This program supports only three options:
#
#   # the TeX program to be used     [mandatory, no default!]
#   # the options to be passed to it [default: ""]
#   # the file to be TeX-ed.         [mandatory, of course]
#
# For the future: maybe insert more useful defaults here.

# Options for flytex...

# Read the command line options passed to the program and either create a
# TeXCommand to be issued to the system or present a complaint.
# !!! Temporary!
def make_TeX_command():
  try:
    opts = sys.argv[1:4]
    return ' '.join(opts)
  except:
    return 'error making command...'


#--------------------------------------------------------------------------
# TEXLIVE ON THE FLY
#--------------------------------------------------------------------------

# Inspect a string for a certain pattern to get the name of the missing
# package. The output is always a list with length <=1.
def find_missings(err_str):
  try:
    # !!! The unique failure reason here is that err_str cannot match the
    # !!! given pattern, in which case re.match returns None. In fact the
    # !!! method .groups() cannot be applied to a None object.
    not_found = \
      re.match('! (?:La)*TeX Error: File `([^\']+)\' not found.', err_str)
    return list(not_found.groups())
  except:
    # If no match, just return the empty list.
    return []

# This giant function takes a TeXCommand element and make the underlying 
# system run it. If no error arises, fine; otherwise, the program tries to
# detect missing files, looks for missing packages containing it and
# installs them; thus, a new attempt to run the same TeXCommand is made.
def flytex(tex_cmd):
  (exit_code, out_str, _) = flytex_exec(tex_cmd)
  while exit_code != 0:
    # !!! Since the exit status in this case is non zero, then it must be
    # !!! some line starting with '!' in the output.
    tex_err = next(ln for ln in out_str.split('\n') if ln.startswith('!')) 
    missings = find_missings(tex_err)
    if missings == []:
      flytex_says_error(tex_err)
      return None
    else:
      (exit_code, str_res) = tlmgr_search_and_install(missings[0])
      if exit_code == 0:
        tlmgr_says(str_res)
        (exit_code, out_str, _) = flytex_exec(tex_cmd)
      else:
        tlmgr_says_error(str_res)
  flytex_says('END!')


# -------------------------------------------------------------------------
# MAIN
# -------------------------------------------------------------------------

if __name__ == '__main__':
  flytex(make_TeX_command())

