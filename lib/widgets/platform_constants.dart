import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlatformConstants {
  PlatformConstants._();


  static double get buttonHeight => kIsWeb || Platform.isIOS || Platform.isMacOS ? 44.0 : 48.0;
  static double get buttonHeightTablet => kIsWeb || Platform.isIOS || Platform.isMacOS ? 44.0 : 48.0;


  static double get buttonBorderRadius => kIsWeb || Platform.isIOS || Platform.isMacOS ? 8.0 : 4.0;
  static double get cardBorderRadius => kIsWeb || Platform.isIOS || Platform.isMacOS ? 8.0 : 4.0;

  static double get tileBorderRadius => kIsWeb || Platform.isIOS || Platform.isMacOS ? 8.0 : 4.0; 

  /// SnackBar spezifische Konstanten
  static double get snackBarBorderRadius => kIsWeb || Platform.isIOS || Platform.isMacOS ? 8.0 : 4.0;
  static (double, double) get snackBarMargin => kIsWeb || Platform.isIOS || Platform.isMacOS ? (8.0, 4.0) : (8.0, 4.0);
  static (double, double) get snackBarPadding => kIsWeb || Platform.isIOS || Platform.isMacOS ? (16.0, 12.0) : (16.0, 12.0);
  static int get snackBarErrorDurationSeconds => 4;
  static int get snackBarSuccessDurationSeconds => 4;
  static int get snackBarInfoDurationSeconds => 4;
  static int get snackBarWarningDurationSeconds => 4;

  /// Inputfields
  static double get inputFieldRadius => kIsWeb || Platform.isIOS || Platform.isMacOS ? 8.0 : 4.0;

  static EdgeInsets get buttonPadding => kIsWeb || Platform.isIOS ? const EdgeInsets.symmetric(horizontal: 24.0) : const EdgeInsets.symmetric(horizontal: 20.0);
  static double get buttonElevation => kIsWeb || Platform.isIOS ? 0.0 : 4.0;
  static Duration get buttonAnimationDuration => const Duration(milliseconds: 180);
  static double get buttonMinWidth => kIsWeb || Platform.isIOS ? 120.0 : 100.0;
  static Color get buttonShadowColor => Platform.isIOS ? Colors.black12 : Colors.black26;

  
}