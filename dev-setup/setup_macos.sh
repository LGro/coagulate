#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $SCRIPTDIR/_script_common

if [[ "$(uname)" != "Darwin" ]]; then 
    echo Not running MacOS
    exit 1
fi

# run setup for veilid
$VEILIDDIR/dev-setup/setup_macos.sh

# ensure packages are installed
if [ "$BREW_USER" == "" ]; then
    if [ -d /opt/homebrew ]; then
        BREW_USER=`ls -lad /opt/homebrew/. | cut -d\  -f4`
        echo "Must sudo to homebrew user \"$BREW_USER\" to install capnp package:"
    elif [ -d /usr/local/Homebrew ]; then
        BREW_USER=`ls -lad /usr/local/Homebrew/. | cut -d\  -f4`
        echo "Must sudo to homebrew user \"$BREW_USER\" to install capnp package:"
    else
        echo "Homebrew is not installed in the normal place. Trying as current user"
        BREW_USER=`whoami`
    fi
fi
sudo -H -u $BREW_USER brew install protobuf

# run setup for veilid_flutter
$VEILIDDIR/veilid-flutter/setup_flutter.sh

# ensure unzip is installed
if command -v protoc &> /dev/null; then 
    echo '[X] protoc is available in the path'
else
    echo 'protoc is not available in the path'
    exit 1
fi

# Install protoc-gen-dart
dart pub global activate protoc_plugin
if command -v protoc-gen-dart &> /dev/null; then 
    echo '[X] protoc-gen-dart is available in the path'
else
    echo 'protoc-gen-dart is not available in the path. Add "$HOME/.pub-cache/bin" to your path.'
    exit 1
fi
