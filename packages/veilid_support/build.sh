#!/bin/bash
set -e
dart run build_runner build --delete-conflicting-outputs

pushd lib > /dev/null
protoc --dart_out=proto -I proto -I dht_support/proto dht.proto
protoc --dart_out=proto -I proto veilid.proto
popd > /dev/null
