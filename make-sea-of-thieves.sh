#!/bin/bash

#WINE
pushd wine
git reset --hard HEAD
git clean -xdf
popd

#Sea of Thieves
pushd patches
sh patch-sot.sh &> ../sotpatch.log
popd

#make proton-sot
build_name=proton-sot make redist | tee build-sot.log

#reset wine
pushd wine
git reset --hard HEAD
git clean -xdf
popd