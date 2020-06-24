#!/bin/bash
pushd ../wine
    echo "sea of thieves winhttp patch"
    patch -Np1 < ../patches/game-patches/sea-of-thieves-websockets.patch
popd
    #end
