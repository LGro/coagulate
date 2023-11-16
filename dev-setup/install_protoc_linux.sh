#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROTOC_VERSION="24.3" # Keep in sync with veilid-core/build.rs

UNAME_M=$(uname -m)
if [[ "$UNAME_M" == "x86_64" ]]; then 
    PROTOC_ARCH=x86_64
elif [[ "$UNAME_M" == "aarch64" ]]; then 
    PROTOC_ARCH=aarch_64
else 
    echo Unsupported build architecture
    exit 1
fi 

mkdir /tmp/protoc-install
pushd /tmp/protoc-install
curl -OL https://github.com/protocolbuffers/protobuf/releases/download/v$PROTOC_VERSION/protoc-$PROTOC_VERSION-linux-$PROTOC_ARCH.zip
unzip protoc-$PROTOC_VERSION-linux-$PROTOC_ARCH.zip
if [ "$EUID" -ne 0 ]; then
    if command -v checkinstall &> /dev/null; then 
        sudo checkinstall --pkgversion=$PROTOC_VERSION -y cp -r bin include /usr/local/
        cp *.deb ~
    else 
	sudo cp -r bin include /usr/local/
    fi
    popd
    sudo rm -rf /tmp/protoc-install
else
    if command -v checkinstall &> /dev/null; then 
        checkinstall --pkgversion=$PROTOC_VERSION -y cp -r bin include /usr/local/
        cp *.deb ~
    else 
        cp -r bin include /usr/local/
    fi
    popd
    rm -rf /tmp/protoc-install
fi
