// 3D-styled common button used for primary actions throughout the app.
// This widget displays a 3D-styled button with gradients, shadow, and customizable text for primary actions.

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:timer/widgets/platform_constants.dart';


/// A 3D-styled button for primary actions, with gradient, shadow, and customizable text.
// Stateless widget for a 3D-styled common button.

/// A 3D-styled customizable button for primary actions.
/// Supports enabled/disabled state, platform-adaptive border radius and colors.
class Button3D extends StatefulWidget {
  /// Ob der Button als Alert (rot) dargestellt wird.
  final bool isAlert;
  /// Optionaler Abstand zwischen Icon und Text.
  final double? iconTextSpacing;
  // Primary color scheme (matches previous defaults)
  static const List<Color> _primaryColorGradient = [
    Color.fromARGB(255, 30, 70, 161),  // darker blue bottom
    Color.fromARGB(255, 45, 97, 201),  // darker blue top

  ];
  static const Color _primaryShadowColor = Color.fromARGB(64, 73, 135, 251);
  static const List<Color> _primaryInnerColorGradient = [
  
    Color.fromARGB(0, 40, 91, 202),
    Color.fromARGB(126, 80, 150, 204),
  ];

  // Secondary color scheme (matches SecondaryButton3D)
  // Secondary: less 3D, lighter shadow, softer gradient
  // Slightly darker for light mode
  static const List<Color> _secondaryColorGradient = [
    Color(0xFFB0B0B0), // darker gray top
    Color(0xFF888888), // even darker gray bottom
  ];
  static const Color _secondaryShadowColor = Color(0x20202020); // much lighter shadow
  static const List<Color> _secondaryInnerColorGradient = [
    Color(0x33FFFFFF),
    Color(0x00FFFFFF),
  ];

  /// Optional leading icon (left of text).
  final IconData? leadingIcon;

  /// Optional trailing icon (right of text).
  final IconData? trailingIcon;

  /// The button label text.
  final String label;

  /// The button height. If null, will be responsive to screen size.
  final double? height;

  /// The border radius of the button.
  /// If not set, uses iOS/Android defaults.
  final double borderRadius;

  /// Optional text style for the label.
  final TextStyle? textStyle;

  /// Callback when the button is pressed.
  final VoidCallback? onPressed;

  /// Horizontal padding for the label.
  final double paddingHorizontal;

  /// Gradient colors for the button background.
  // final List<Color> colorGradient;
  /// Shadow color for the button.
  // final Color shadowColor;
  /// Inner vertical gradient overlay colors.
  // final List<Color> innerColorGradient;
  /// Whether the button is enabled (default: true).
  final bool enabled;

  /// Whether the button uses the secondary color scheme (default: false).
  final bool isSecondary;

  /// Creates a 3D-styled button with platform-adaptive border radius and disabled state.
  Button3D({
    super.key,
    required this.label,
    this.height,
    double? borderRadius,
    this.textStyle,
    this.paddingHorizontal = 32,
    this.onPressed,
    this.enabled = true,
    this.leadingIcon,
    this.trailingIcon,
    this.isSecondary = false,
    this.isAlert = false,
    this.iconTextSpacing,
  }) : borderRadius = borderRadius ?? PlatformConstants.buttonBorderRadius;
  // Alert-Farbverlauf (rot)
  static const List<Color> _alertColorGradient = [
    Color(0xFFD32F2F), // Rot oben
    Color(0xFFB71C1C), // Rot unten
  ];
  static const Color _alertShadowColor = Color(0x40D32F2F);
  static const List<Color> _alertInnerColorGradient = [
    Color(0x33FFCDD2),
    Color(0x00FFCDD2),
  ];

  @override
  State<Button3D> createState() => _Button3DState();
}

/// State for PrimaryButton3D, manages pressed and disabled visuals.
class _Button3DState extends State<Button3D> {
  /// Returns the platform-conform spacing between icon and text.
  double _iconTextSpacing() {
    if (widget.iconTextSpacing != null) {
      return widget.iconTextSpacing!;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return 8.0;
      case TargetPlatform.android:
        return 12.0;
      default:
        return 10.0;
    }
  }

  /// Returns a responsive button height based on device type and platform guidelines.
  /// Uses shortestSide to distinguish phone/tablet, so orientation does not affect the result.
  double _responsiveHeight(BuildContext context) {
    final double shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool isTablet = shortestSide >= 600;
    return isTablet
        ? PlatformConstants.buttonHeightTablet
        : PlatformConstants.buttonHeight;
  }

  /// Whether the button is currently pressed.
  bool _pressed = false;

  /// Returns the background gradient colors depending on state and platform.
  List<Color> get _currentColors {
    if (!widget.enabled) {
      // Disabled: flat gradient, lighter shadow, less 3D
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return [
          const Color.fromARGB(255, 235, 235, 235),
          const Color.fromARGB(255, 225, 225, 225),
        ];
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        return [
          const Color.fromARGB(255, 200, 200, 200),
          const Color.fromARGB(255, 180, 180, 180),
        ];
      } else {
        return [
          Colors.grey.shade200,
          Colors.grey.shade400
        ];
      }
    }
    // Slightly darken when pressed
    List<Color> colors;
    if (widget.isAlert) {
      colors = Button3D._alertColorGradient;
    } else if (widget.isSecondary) {
      colors = Button3D._secondaryColorGradient;
    } else {
      colors = Button3D._primaryColorGradient;
    }
    return _pressed ? colors.map((c) => _darken(c, 0.10)).toList() : colors;
  }

  /// Returns the inner vertical gradient overlay colors depending on state and platform.
  List<Color> get _currentInnerColors {
    if (!widget.enabled) {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return [const Color(0xFFF2F2F7), const Color(0x00D1D1D6)];
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        return [const Color(0xFFE0E0E0), const Color(0x00757575)];
      } else {
        return [Colors.grey.shade100, Colors.grey.shade400.withAlpha(0)];
      }
    }
    List<Color> colors;
    if (widget.isAlert) {
      colors = Button3D._alertInnerColorGradient;
    } else if (widget.isSecondary) {
      colors = Button3D._secondaryInnerColorGradient;
    } else {
      colors = Button3D._primaryInnerColorGradient;
    }
    return _pressed ? colors.map((c) => _darken(c, 0.08)).toList() : colors;
  }

  /// Returns the shadow color depending on state and platform.
  Color get _currentShadowColor {
    if (!widget.enabled) {
      // Disabled: lighter, less blur
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return const Color(0x20D1D1D6); // much lighter
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        return const Color(0x20202020); // much lighter
      } else {
        return Colors.grey.shade300.withAlpha(32);
      }
    }
    Color color;
    if (widget.isAlert) {
      color = Button3D._alertShadowColor;
    } else if (widget.isSecondary) {
      color = Button3D._secondaryShadowColor;
    } else {
      color = Button3D._primaryShadowColor;
    }
    return _pressed ? _darken(color, 0.15) : color;
  }

  /// Utility to darken a color by a given amount (0-1).
  static Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Builds the button widget tree with all visual states and effects.
  @override
  Widget build(BuildContext context) {
    final bool isDisabled = !widget.enabled;
    final bool isSecondary = widget.isSecondary;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        onTap: isDisabled ? null : widget.onPressed,
        onTapDown: isDisabled ? null : (_) => setState(() => _pressed = true),
        onTapUp: isDisabled ? null : (_) => setState(() => _pressed = false),
        onTapCancel: isDisabled ? null : () => setState(() => _pressed = false),
        splashColor: isDisabled ? Colors.transparent : null,
        highlightColor: isDisabled ? Colors.transparent : null,
        child: Opacity(
          opacity: isDisabled ? 0.6 : 1.0,
          child: Container(
            height: widget.height ?? _responsiveHeight(context),
            // Outer decoration: less 3D for disabled
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: isDisabled
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: _currentColors,
                      stops: const [0.0, 1.0],
                    )
                  : isSecondary
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _currentColors,
                          stops: const [0.0, 1.0],
                        )
                      : RadialGradient(
                          center: const Alignment(0.7, -0.2),
                          radius: 1.2,
                          colors: _currentColors,
                          stops: const [0.0, 1.0],
                        ),
              boxShadow: [
                BoxShadow(
                  color: _currentShadowColor,
                  blurRadius: isDisabled ? 2 : (isSecondary ? 6 : 15),
                  offset: Offset(0, isDisabled ? 1 : (isSecondary ? 4 : 10)),
                ),
                if (!isSecondary && !isDisabled)
                  BoxShadow(
                    color: Colors.white.withAlpha(128),
                    blurRadius: 4,
                    offset: Offset(0, -1),
                    spreadRadius: -2,
                  ),
              ],
            ),
            child: Container(
              // Inner decoration: subtle vertical gradient overlay
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _currentInnerColors,
                  stops: const [0.0, 0.4],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.paddingHorizontal,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.leadingIcon != null) ...[
                        Icon(
                          widget.leadingIcon,
                          size: 22,
                          color: isDisabled
                              ? (defaultTargetPlatform == TargetPlatform.iOS
                                    ? const Color(0xFFAEAEB2)
                                    : defaultTargetPlatform ==
                                          TargetPlatform.android
                                    ? const Color(0xFF424242)
                                    : Colors.grey.shade600)
                              : (widget.textStyle?.color ?? Colors.white),
                        ),
                        SizedBox(width: _iconTextSpacing()),
                      ],
                      Text(
                        widget.label,
                        style:
                            (widget.textStyle ??
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17,
                                    ))
                                .copyWith(
                          color: isDisabled
                          ? (defaultTargetPlatform == TargetPlatform.iOS
                            ? const Color(0xFFB0B0B0) // medium gray for iOS
                            : defaultTargetPlatform == TargetPlatform.android
                            ? const Color(0xFF888888) // medium gray for Android
                            : Colors.grey.shade500) // medium for others
                          : (widget.textStyle?.color ?? Colors.white),
                                ),
                      ),
                      if (widget.trailingIcon != null) ...[
                        SizedBox(width: _iconTextSpacing()),
                        Icon(
                          widget.trailingIcon,
                          size: 22,
                          color: isDisabled
                              ? (defaultTargetPlatform == TargetPlatform.iOS
                                    ? const Color(0xFFAEAEB2)
                                    : defaultTargetPlatform ==
                                          TargetPlatform.android
                                    ? const Color(0xFF424242)
                                    : Colors.grey.shade600)
                              : (widget.textStyle?.color ?? Colors.white),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
