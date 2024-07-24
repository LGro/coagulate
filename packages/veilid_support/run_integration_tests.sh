#!/bin/bash
pushd example 2>/dev/null
flutter test -r expanded integration_test/app_test.dart $@
popd 2>/dev/null
