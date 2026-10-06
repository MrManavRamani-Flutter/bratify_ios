import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import 'logger_service.dart';

class AppUpdateService {
  // Method to check if the app needs an update and show a dialog
  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentAppVersion = packageInfo.version;
      final liveAppVersion = await _getAppStoreVersion(AppConfig.appRateId);

      AppLogger.logInfo(
        'UPDATE',
        'Version check - Local: $currentAppVersion, Store: $liveAppVersion',
      );

      bool isUpdateAvailable = false;
      if (liveAppVersion != null) {
        int result = _compareVersions(currentAppVersion, liveAppVersion);
        isUpdateAvailable = result == -1;
      }

      if (isUpdateAvailable && context.mounted) {
        AppLogger.logInfo('UPDATE', 'Update prompt initiated for user');
        _showUpdateDialog(context);
      } else {
        AppLogger.logInfo('UPDATE', 'App is running the latest version');
      }
    } catch (e, stack) {
      AppLogger.logError(
        'UPDATE',
        'Failed to check for app updates',
        e,
        stack,
      );
    }
  }

  static int _compareVersions(String version1, String version2) {
    final v1Clean = version1.split('+').first;
    final v2Clean = version2.split('+').first;
    final v1Parts = v1Clean.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final v2Parts = v2Clean.split('.').map((p) => int.tryParse(p) ?? 0).toList();

    final length = v1Parts.length > v2Parts.length ? v1Parts.length : v2Parts.length;
    v1Parts.addAll(List.filled(length - v1Parts.length, 0));
    v2Parts.addAll(List.filled(length - v2Parts.length, 0));

    for (int i = 0; i < length; i++) {
      if (v1Parts[i] < v2Parts[i]) {
        return -1;
      } else if (v1Parts[i] > v2Parts[i]) {
        return 1;
      }
    }
    return 0;
  }

  static Future<String?> _getAppStoreVersion(String appId) async {
    try {
      final url = Uri.parse("https://itunes.apple.com/lookup?id=$appId");
      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && (data['results'] as List).isNotEmpty) {
          return data['results'][0]["version"] as String?;
        }
      }
    } catch (e, stack) {
      AppLogger.logError(
        'UPDATE',
        'App Store lookup network timeout/failure',
        e,
        stack,
      );
    }
    return null;
  }

  static void _showUpdateDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return PopScope(
          canPop: true,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: AppColors.whiteColor.withValues(alpha: 0.98),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.fillColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.system_update_rounded,
                      color: AppColors.fillColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.updatedReq,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textBlackColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.updateVersion,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textBlackColor.withValues(alpha: 0.75),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Later',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textBlackColor.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: _openAppStore,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: AppColors.fillColor,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              AppStrings.updateNow,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.whiteColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> _openAppStore() async {
    final String appStoreUrl = "https://apps.apple.com/app/id${AppConfig.appRateId}";
    final Uri url = Uri.parse(appStoreUrl);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e, stack) {
      AppLogger.logError(
        'UPDATE',
        'Failed to launch App Store link',
        e,
        stack,
      );
    }
  }
}
