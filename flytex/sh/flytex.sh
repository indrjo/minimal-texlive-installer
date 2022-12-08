#!/usr/bin/env sh

set -e -o pipefail

tlmgr_search () {
  tlmgr search --global --file $1 | sed -nE "s/://p;/\/$1$/q" | tail -n 1  
}

tlmgr_install () {
  tlmgr_search $1 | xargs tlmgr install
}

