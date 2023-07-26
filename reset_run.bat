@echo off
flutter run --dart-define=DELETE_TABLE_STORE=1 --dart-define=DELETE_PROTECTED_STORE=1 --dart-define=DELETE_BLOCK_STORE=1 %*
