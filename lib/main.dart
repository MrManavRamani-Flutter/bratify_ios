import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'my_app.dart';
import 'screens/maintenance_screen.dart';
import 'services/logger_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Global Flutter Framework Error Interceptor
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.logError(
      'FlutterFramework',
      details.exceptionAsString(),
      details.exception,
      details.stack,
    );
  };

  // 2. Global Uncaught Async Platform Error Interceptor
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    AppLogger.logError(
      'UncaughtAsync',
      error.toString(),
      error,
      stack,
    );
    return true; // Handled safely to prevent app process termination
  };

  // 3. User-Facing Error Boundary (Replaces Red Screen of Death with Positive Maintenance UI)
  ErrorWidget.builder = (FlutterErrorDetails details) {
    AppLogger.logError(
      'WidgetRender',
      'UI Render exception captured',
      details.exception,
      details.stack,
    );

    return MaintenanceScreen(
      featureName: 'UIRenderBoundary',
      errorDetails: details.exceptionAsString(),
      stackTrace: details.stack,
    );
  };

  // 4. Modern iOS System UI Overlay Style (Transparent Status Bar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  AppLogger.logAction('Bootstrap', 'App initialized with global error boundary and diagnostic logging');

  // Fast zero-delay startup: SplashScreen handles diagnostics and progress tracking
  runApp(const MyApp());
}
