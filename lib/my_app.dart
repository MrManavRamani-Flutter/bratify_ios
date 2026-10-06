import 'dart:ui' as ui;
import 'package:brat_generator/constants/app_colors.dart';
import 'package:brat_generator/constants/app_strings.dart';
import 'package:brat_generator/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rate_my_app/rate_my_app.dart';

import 'config/app_config.dart';

bool ipad = false;
bool iphoneX = true;

Widget _builder(BuildContext context, Widget? child) {
  return child!;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.offWhiteColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.offWhiteColor,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.bratGreen,
          primary: Colors.black,
          surface: Colors.white,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          contentTextStyle: GoogleFonts.outfit(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xff18181B),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          contentTextStyle: GoogleFonts.outfit(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      builder: _builder,
      home: const SplashScreen(),
    );
  }
}

Future<void> isIpad() async {
  try {
    final view = ui.PlatformDispatcher.instance.implicitView ??
        (ui.PlatformDispatcher.instance.views.isNotEmpty
            ? ui.PlatformDispatcher.instance.views.first
            : null);
    if (view != null) {
      final physicalSize = view.physicalSize;
      final pixelRatio = view.devicePixelRatio > 0 ? view.devicePixelRatio : 1.0;
      final logicalWidth = physicalSize.width / pixelRatio;
      final logicalHeight = physicalSize.height / pixelRatio;
      final shortestSide = logicalWidth < logicalHeight ? logicalWidth : logicalHeight;
      ipad = shortestSide >= 600;
    } else {
      ipad = false;
    }
  } catch (_) {
    ipad = false;
  }
}

Future<bool> isIphoneXSeries() async {
  try {
    final view = ui.PlatformDispatcher.instance.implicitView ??
        (ui.PlatformDispatcher.instance.views.isNotEmpty
            ? ui.PlatformDispatcher.instance.views.first
            : null);
    if (view != null) {
      final padding = view.padding;
      final pixelRatio = view.devicePixelRatio > 0 ? view.devicePixelRatio : 1.0;
      final bottomInset = padding.bottom / pixelRatio;
      // All modern notched & Dynamic Island iPhones have bottom safe area >= 20.0
      return bottomInset > 10.0;
    }
    return true; // Default to true for modern devices
  } catch (_) {
    return true;
  }
}

extension DeviceExt on BuildContext {
  bool get isTablet => MediaQuery.sizeOf(this).shortestSide >= 600;
  bool get isLandscape => MediaQuery.orientationOf(this) == Orientation.landscape;
}

// App Rate Function declaration
RateMyApp rateMyApp = RateMyApp(
  preferencesPrefix: 'rateMyApp_',
  minDays: 0,
  minLaunches: 0,
  appStoreIdentifier: AppConfig.appRateId,
);
