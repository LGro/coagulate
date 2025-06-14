// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

class DebugLogger {
  factory DebugLogger() => _instance;
  DebugLogger._privateConstructor();

  static final DebugLogger _instance = DebugLogger._privateConstructor();

  final List<String> _logLines = [];

  // Write a new line to the log
  void log(String message) {
    final timestamped = '[${DateTime.now().toIso8601String()}] $message';
    _logLines.add(timestamped);
  }

  // Retrieve all logs as a single string
  String get fullLog => _logLines.join('\n');

  // Retrieve last N lines
  List<String> getRecentLogs({int count = 50}) => _logLines
      .skip(_logLines.length > count ? _logLines.length - count : 0)
      .toList();
}
