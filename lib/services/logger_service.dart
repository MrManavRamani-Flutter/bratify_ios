import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Centralized Diagnostic System Logger for Bratify Studio.
/// Ensures all state changes, transforms, template selections, and errors
/// are systematically logged with exact file locations, line numbers, and timestamps.
class AppLogger {
  static const String _appName = 'BratStudio';

  /// Log standard user action or state change
  static void logAction(String feature, String action, [Map<String, dynamic>? data]) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    final dataStr = data != null && data.isNotEmpty ? ' -> $data' : '';
    final message = '[$timestamp][$_appName][$feature] 🚀 $action$dataStr';

    if (kDebugMode) {
      debugPrint(message);
    }
    developer.log(message, name: '$_appName.$feature');
  }

  /// Log informational status
  static void logInfo(String feature, String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    final logText = '[$timestamp][$_appName][$feature] ℹ️ $message';

    if (kDebugMode) {
      debugPrint(logText);
    }
    developer.log(logText, name: '$_appName.$feature');
  }

  /// Log warning
  static void logWarning(String feature, String warning, [dynamic error]) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    final errStr = error != null ? ' ($error)' : '';
    final logText = '[$timestamp][$_appName][$feature] ⚠️ $warning$errStr';

    if (kDebugMode) {
      debugPrint(logText);
    }
    developer.log(logText, name: '$_appName.$feature', level: 900);
  }

  /// Log error with detailed file & line extraction
  static void logError(String feature, String message, [dynamic error, StackTrace? stackTrace]) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    final locationInfo = _extractLocation(stackTrace ?? StackTrace.current);

    final divider = '═' * 68;
    final logHeader = '\n$divider\n[$timestamp][$_appName][$feature] ❌ CRITICAL ISSUE IDENTIFIED:';
    final locationLine = '📍 Location: ${locationInfo['file']} (Line: ${locationInfo['line']}, Col: ${locationInfo['col']})';
    final callerLine = '🏷️ Function: ${locationInfo['function']}';
    final detailLine = '📝 Message:  $message';
    final errorLine = error != null ? '💥 Exception: $error' : '';
    final logFooter = '$divider\n';

    final fullReport = [
      logHeader,
      locationLine,
      callerLine,
      detailLine,
      if (errorLine.isNotEmpty) errorLine,
      logFooter,
    ].join('\n');

    if (kDebugMode) {
      debugPrint(fullReport);
      if (stackTrace != null) {
        debugPrint('Stack Trace:\n$stackTrace');
      }
    }

    developer.log(
      fullReport,
      name: '$_appName.$feature',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }

  /// Parses stack trace to pinpoint exact source file, line number, and function
  static Map<String, String> _extractLocation(StackTrace stackTrace) {
    final lines = stackTrace.toString().split('\n');
    for (final line in lines) {
      // Look for lines originating from package:brat_generator or lib/
      if ((line.contains('package:brat_generator') || line.contains('/lib/')) &&
          !line.contains('logger_service.dart')) {
        // Example: #1 _GenerateScreenState._exportToPhotos (package:brat_generator/screens/generate_screen.dart:1072:5)
        final match = RegExp(r'#\d+\s+([^\s]+)\s+\((.+?):(\d+):(\d+)\)').firstMatch(line);
        if (match != null) {
          return {
            'function': match.group(1) ?? 'Unknown',
            'file': match.group(2) ?? 'Unknown file',
            'line': match.group(3) ?? '?',
            'col': match.group(4) ?? '?',
          };
        }

        // Alternative pattern
        final altMatch = RegExp(r'\((.+?):(\d+):(\d+)\)').firstMatch(line);
        if (altMatch != null) {
          return {
            'function': 'app execution',
            'file': altMatch.group(1) ?? 'Unknown file',
            'line': altMatch.group(2) ?? '?',
            'col': altMatch.group(3) ?? '?',
          };
        }
      }
    }

    return {
      'function': 'Global scope',
      'file': 'Workspace lib/',
      'line': 'N/A',
      'col': 'N/A',
    };
  }
}
