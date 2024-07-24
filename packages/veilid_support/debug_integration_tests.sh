#!/bin/bash
pushd example 2>/dev/null
flutter run integration_test/app_test.dart $@
popd 2>/dev/null
