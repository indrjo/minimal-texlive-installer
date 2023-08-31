#!/usr/bin/env sh

set -e -o pipefail

# USAGE: get_answer text_prompt default
get_answer () {
  if [ -z "$2" ]
    then defprompt=""
    else defprompt="[default=$2] "
  fi
  read -p "> $1 $defprompt"
  ans=$(echo "$REPLY" | sed -E 's,^\s+,,' | sed -E 's,\s+$,,')
  [ -z "$ans" ] && echo "$2" || echo "$ans"
}

expand_tilde () {
  echo "$1" | sed -E "s,~,$HOME,"
}

cat <<EOF

This script will install TeX Live on your machine.

You will be asked to decide some details of the installation.
If you choose to not answer, the default indicated between the
brackets is assumed. Defaults should be sensible for most of 
the cases.

EOF

#go=$(get_answer "ready to go? y/n" "y") 
#[ $go = y ] || exit

# DETERMINE THE DETAILS FO THE INSTALLATION *******************************

texdir=$(get_answer "where to install TeX Live?" "~/texlive")
texdir=$(expand_tilde $texdir)

if [ -d $texdir ]; then
  echo "$texdir already exixts!"
  exit
fi

texuserdir=$HOME/.$(basename $texdir)

if [ -d $texuserdir ]; then
  echo "$texuserdir already exixts!"
  exit
fi

scheme=$(get_answer "select the scheme" "scheme-minimal")

other_options=$(get_answer "any other option for install-tl?")

tlrc=$(get_answer "where to write paths for TeX Live?" "~/.tlrc")
tlrc=$(expand_tilde $tlrc)

if [ -f $tlrc ]; then
  echo "$tlrc already exixts!"
  exit
fi

installer_dir=$HOME/.texlive-installer

# GET READY FOR THE INSTALLATION ******************************************

# Create, if needed, a directory and download there the TeX Live installer.
# !!! This directory will eventually be deleted. This behaviour will likely
# !!! change in future, for it is not unreasonable to keep the installer.

[ -d $installer_dir ] || mkdir -p $installer_dir
cd $installer_dir

wget --continue --no-clobber --no-verbose \
  "https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz"

tar -xzf install-tl-unx.tar.gz --strip-components 1

# INSTALLATION ************************************************************

# Start the installer with some changes and append certain directories of
# TeX Live to some `PATH`s.

./install-tl --no-interaction         \
             --scheme     $scheme     \
             --texdir     $texdir     \
             --texuserdir $texuserdir \
             $other_options

# Now write paths to $tlrc
cat <<EOF > $tlrc
#!/bin/sh
# TeX Live paths.
export PATH=$texdir/bin/x86_64-linux:\$PATH
export MANPATH=$texdir/texmf-dist/doc/man:\$MANPATH
export INFOPATH=$texdir/texmf-dist/doc/info:\$INFOPATH
EOF

# Install some highly recommended packages in case the user decides to not
# install the full scheme. This step is quite important: so far, you have
# only a bare skeleton, you cannot even do the most basic stuff.
if [ $scheme != "scheme-full" ]; then
  source $tlrc
  tlmgr install latex-bin
  tlmgr install latex-base-dev
  tlmgr install texlive-scripts
  tlmgr install texdoc
fi

# POST INSTALLATION REFINEMENT ********************************************

# After you have done all the work above, prepare the an uninstaller for 
# the installed TeX Live. As you know, you have to annually get rid of TeX
# Live in order to install the newer version. Removing TeX Live should not 
# be difficult (is you remember where you have installed all the stuff), 
# but pay attention to not remove the uninstaller.

cat <<EOF > ~/.texlive-uninstaller
#!/bin/sh
# The TeX Live uninstaller script
rm -rfv $texdir
rm -rfv $texuserdir
rm -rfv $tlrc
rm -rfv $HOME/.texlive-uninstaller
EOF

chmod u+x ~/.texlive-uninstaller

# END *********************************************************************

cat <<EOF

!!! ABOUT YOUR INSTALLATION

1. Copy the line

   [ -f $tlrc ] && source $tlrc

   at the bottom of your ~/.bashrc, if you haven't done so.

2. The installer in $installer_dir. That directoy isn't needed
   anymore, thus you can delete it.

3. In ./scripts there is tlmgr-install-extras.pl which installs
   extra packages. If you have selected the full scheme, you do
   not have to worry about this point.

4. To uninstall TeX Live, use the script ~/.texlive-uninstaller

EOF

