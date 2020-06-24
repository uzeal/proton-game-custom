#!/bin/bash
pushd patches
sh patch-sot.sh &> sotpatch.log
popd
build_name=proton-sot make redist | tee build-sot.log