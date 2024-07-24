#!/bin/bash
echo Ensure chromedriver is running on port 4444 and you have compiled veilid-wasm with wasm_build.sh
pushd example 2>/dev/null
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d chrome $@
popd 2>/dev/null
