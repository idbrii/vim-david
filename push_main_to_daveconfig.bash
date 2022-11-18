#! /bin/bash

# Barf on all errors
set -e

_checkout_vimconfig_branch() {
	pushd multi/vim/bundle/aa-david
	git checkout $1
	popd
}

_f(){
	if [ $# -lt 1 ] ; then
		echo "Needs a working branch."
		return
	fi
	git checkout main
	_checkout_vimconfig_branch main
	git sub-commit-changelog --verbose multi/vim/bundle/aa-david

	git checkout $1
	_checkout_vimconfig_branch work
	git rebase main
}

_f $*
