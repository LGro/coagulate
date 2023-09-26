#!/bin/bash
set -e
dart run build_runner build

pushd lib > /dev/null
protoc --dart_out=proto -I veilid_support/proto -I veilid_support/dht_support/proto -I proto veilidchat.proto
protoc --dart_out=proto -I veilid_support/proto -I veilid_support/dht_support/proto dht.proto
protoc --dart_out=proto -I veilid_support/proto veilid.proto
popd > /dev/null
