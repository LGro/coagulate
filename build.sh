#!/bin/bash
set -e
dart run build_runner build
pushd lib/entities > /dev/null
protoc --dart_out=proto veilidchat.proto
popd > /dev/null