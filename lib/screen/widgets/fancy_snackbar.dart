import 'package:flutter/material.dart';
import 'package:timer/screen/widgets/platform_constants.dart';

enum FancySnackbarType {
  success,
  error,
  info,
  warning,
}

class FancySnackbar {
  static SnackBar build(String message, {FancySnackbarType type = FancySnackbarType.info}) {
    final config = _FancySnackbarConfig.forType(type);
    return SnackBar(
      content: Row(
        children: [
          Icon(config.icon, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      backgroundColor: config.backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PlatformConstants.snackBarBorderRadius),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: PlatformConstants.snackBarMargin.$1,
        vertical: PlatformConstants.snackBarMargin.$2,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: PlatformConstants.snackBarPadding.$1,
        vertical: PlatformConstants.snackBarPadding.$2,
      ),
      duration: Duration(seconds: config.durationSeconds),
      elevation: 8,
    );
  }
}

class _FancySnackbarConfig {
  final Color backgroundColor;
  final IconData icon;
  final int durationSeconds;

  _FancySnackbarConfig({required this.backgroundColor, required this.icon, required this.durationSeconds});

  static _FancySnackbarConfig forType(FancySnackbarType type) {
    switch (type) {
      case FancySnackbarType.success:
        return _FancySnackbarConfig(
          backgroundColor: Colors.green,
          icon: Icons.check_circle,
          durationSeconds: PlatformConstants.snackBarSuccessDurationSeconds,
        );
      case FancySnackbarType.error:
        return _FancySnackbarConfig(
          backgroundColor: Colors.red,
          icon: Icons.error,
          durationSeconds: PlatformConstants.snackBarErrorDurationSeconds,
        );
      case FancySnackbarType.warning:
        return _FancySnackbarConfig(
          backgroundColor: Colors.orange,
          icon: Icons.warning,
          durationSeconds: PlatformConstants.snackBarWarningDurationSeconds,
        );
      case FancySnackbarType.info:
      //default:
        return _FancySnackbarConfig(
          backgroundColor: Colors.blue,
          icon: Icons.info,
          durationSeconds: PlatformConstants.snackBarInfoDurationSeconds,
        );
    }
  }
}