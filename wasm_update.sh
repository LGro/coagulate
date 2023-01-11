#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $SCRIPTDIR/_script_common

pushd $SCRIPTDIR >/dev/null

# WASM output dir
WASMDIR=$SCRIPTDIR/web/wasm

# Build veilid-wasm, passing any arguments here to the build script
pushd $VEILIDDIR/veilid-wasm >/dev/null
PKGDIR=$(./wasm_build.sh $@ | grep SUCCESS:OUTPUTDIR | cut -d= -f2)
popd >/dev/null

# Copy wasm blob into place
echo Updating WASM from $PKGDIR to $WASMDIR
if [ -d $WASMDIR ]; then 
    rm -f $WASMDIR/*
fi
mkdir -p $WASMDIR
cp -f $PKGDIR/* $WASMDIR/

#### Done

popd >/dev/null
