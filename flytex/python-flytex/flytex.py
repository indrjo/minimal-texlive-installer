#!/usr/bin/env python

import subprocess as prc
import shlex as sh
import sys
import re

# -------------------------------------------------------------------------
# HOW THE PROGRAM COMMUNICATES
# -------------------------------------------------------------------------

# !!! No fatal massages here, that is no message will abort the execution
# !!! of flytex. This feature may change or not, but for now that's it.

# The general way, to say things.
def say(hdl, who, text):
  print('[' + who + '] ' + text, file=hdl)
  #print(f'[{who}] {text}', file=hdl)

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

# A minimal TeXlive has tlmgr who handles packages: not only you install
# packages with it, but you can search packages containing a given file!
# They are both interesting for our purpose.

# Installing packages is the simpler part here, you just have to type
#
#  $ tlmgr install <pkg>
#
# and wait tlmgr to end.
def tlmgr_install(pkg):
  exit_code = flytex_exec('tlmgr install ' + pkg)[0]
  '''
  if exit_code == 0:
    return (exit_code, 'installed \'' + pkg + '\'')
  else:
    return (exit_code, 'cannot install \'' + pkg + '\'!')
  '''
  exit_text = \
    'installed \'' + pkg + '\'' if exit_code == 0 \
    else 'cannot install \'' + pkg + '\'!'
  return exit_code, exit_text

# It is best we provide a function to perform multiple installations. For
# a list of packages corresponding to a given missing file, install them
# one by one; just stop with a Left message as one cannot be installed.
def tlmgr_multiple_install(fp, pkgs): 
#  if pkgs == []:
#    return (0, 'all missing packages for \'' + fp + '\' installed')
#  else:
#    pkg, others = pkgs[0], pkgs[1:]
#    (exit_code, res_str) = tlmgr_install(pkg)
#    if exit_code == 0:
#      return tlmgr_multiple_install(fp, others)
#    else:
#      return (exit_code, res_str)
  for pkg in pkgs:
    (exit_code, exit_text) = tlmgr_install(pkg)
    if exit_code != 0:
      return (exit_code, exit_text)
  return (0, 'all missing packages for \'' + fp + '\' installed')

# Let us turn our focus on searching packages now. To do so, let us start
# from a descriptive example.
#
#  | $ tlmgr search --global --file tikz.sty
#  | tlmgr: package repository [...]
#  | biblatex-ext:
#  |   texmf-dist/tex/latex/biblatex-ext/biblatex-ext-oasymb-tikz.sty
#  | circuitikz:
#  |   texmf-dist/tex/latex/circuitikz/circuitikz.sty
#  | hf-tikz:
#  |   texmf-dist/tex/latex/hf-tikz/hf-tikz.sty
#  | interfaces:
#  |   texmf-dist/tex/latex/interfaces/interfaces-tikz.sty
#  | kinematikz:
#  |   texmf-dist/tex/latex/kinematikz/kinematikz.sty
#  | lwarp:
#  |   texmf-dist/tex/latex/lwarp/lwarp-tikz.sty
#  | moderncv:
#  |   texmf-dist/tex/latex/moderncv/moderncviconstikz.sty
#  | pgf:
#  |   texmf-dist/tex/latex/pgf/frontendlayer/tikz.sty
#  | pinoutikz:
#  |   texmf-dist/tex/latex/pinoutikz/pinoutikz.sty
#  | puyotikz:
#  |   texmf-dist/tex/latex/puyotikz/puyotikz.sty
#  | quantikz:
#  |   texmf-dist/tex/latex/quantikz/quantikz.sty
#  | sa-tikz:
#  |   texmf-dist/tex/latex/sa-tikz/sa-tikz.sty
#
# The first line just tells the repository interrogated. Anyway, the other
# lines are the ones very interesting: there is a sequence of
# 
#  <package>:
#    <path>
#
# where the <path>s end with `tikz.sty`. In this case, we are looking for
# exactly `tikz.sty`, then we want only `pgf`.

# Thus part of the work is to extract from the sequence of
# 
#  <package>:
#    <path>
#
# the packages containing the given file.
def find_packages(fp, lns):
  if len(lns) >= 2:
    pkg, path, rem = lns[0], lns[1], lns[2:]
    if path.endswith('/' + fp):
      return [pkg[:-1]] + find_packages(fp, rem)
    else:
      return find_packages(fp, rem)
  else:
    return []

'''
  pkgs_found = []
  current_pkg = lns[0][:-1]
  for ln in lns[1:]:
    if ln.startswith('\t'):
      if ln.endswith('/' + fp):
        pkgs_found.append(current_pkg)
    else:
      current_pkg = ln[:-1]
  return pkgs_found
'''

# Make tlmgr look for packages containing the given file.
def tlmgr_search(fp):
  exit_code, out_str, err_str = \
    flytex_exec('tlmgr search --global --file ' + fp)
  if exit_code == 0:
    pkgs_paths = out_str.split('\n')
    if len(pkgs_paths) >= 1:
      pkgs_found = find_packages(fp, pkgs_paths[1:])
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
  not_found = \
    re.match('! (?:La)*TeX Error: File `([^\']+)\' not found.', err_str)
  return list(not_found.groups())

# This giant function takes a TeXCommand element and make the underlying 
# system run it. If no error arises, fine; otherwise, the program tries to
# detect missing files, looks for missing packages containing it and
# installs them; thus, a new attempt to run the same TeXCommand is made.

def find(p, xs):
  if xs == []:
    return None
  else:
    return xs[0] if p(xs[0]) else find(p, xs[1:])

def flytex(tex_cmd):
  (exit_code, out_str, _) = flytex_exec(tex_cmd)
  if exit_code == 0:
    flytex_says('END!')
  else:
    tex_err = find(lambda s: s.startswith('!'), out_str.split('\n'))
    missings = find_missings(tex_err)
    if missings == []:
      flytex_says_error(tex_err)
    else:
      (exit_code, str_res) = tlmgr_search_and_install(missings[0])
      if exit_code == 0:
        tlmgr_says(str_res)
        flytex(tex_cmd)
      else:
        tlmgr_says_error(str_res)


# -------------------------------------------------------------------------
# MAIN
# -------------------------------------------------------------------------

if __name__ == '__main__':
  flytex(make_TeX_command())

