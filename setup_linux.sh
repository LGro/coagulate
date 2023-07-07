#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $SCRIPTDIR/_script_common

if [[ "$(uname)" != "Linux" ]]; then 
    echo Not running Linux
    exit 1
fi

if [ "$(lsb_release -d | grep -qEi 'debian|buntu|mint')" ]; then
    echo Not a supported Linux
    exit 1
fi


# run setup for veilid
$VEILIDDIR/setup_linux.sh
# run setup for veilid_flutter
$VEILIDDIR/veilid-flutter/setup_flutter.sh


# ensure protoc is installed
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

# # ensure rsync is installed
# if command -v rsync &> /dev/null; then 
#     echo '[X] rsync is available in the path'
# else
#     echo 'rsync is not available in the path'
#     exit 1
# fi

# # ensure sed is installed
# if command -v sed &> /dev/null; then 
#     echo '[X] sed is available in the path'
# else
#     echo 'sed is not available in the path'
#     exit 1
# fi
