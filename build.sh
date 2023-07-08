#!/bin/bash
set -e
dart run build_runner build
protoc --dart_out=lib/entities proto/veilidchat.proto
