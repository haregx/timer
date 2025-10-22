import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:timer/widgets/platform_constants.dart';


/// Glass Card Widget - Simple glassmorphism-styled card component
/// 
/// Provides consistent glassmorphism styling for content cards:
/// - Semi-transparent background with blur effect
/// - Subtle border and shadow
/// - Smooth animations with customizable delay
class GlassCard extends StatefulWidget {
  /// The child widget to display inside the card
  final Widget child;
  
  /// Animation delay for the card appearance
  final Duration delay;
  
  /// Custom padding for the card content
  final EdgeInsets? padding;
  
  /// Custom margin for the card
  final EdgeInsets? margin;
  
  /// Custom border radius
  final BorderRadius? borderRadius;

  // Animation Duration
  final Duration animationDuration;

  const GlassCard({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.animationDuration = const Duration(milliseconds: 600),
    this.padding,
    this.margin,
    this.borderRadius,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Start animation with delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    //final isIOs = PlatformUtils.isIOS; // Theme.of(context).platform == TargetPlatform.iOS || Theme.of(context).platform == TargetPlatform.macOS;

    // need to add kIsWeb as otherwise got an exeption on web
    final double borderRadius =  PlatformConstants.cardBorderRadius; // kIsWeb || PlatformUtils.isIOS ? 20 : 12;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: ClipRRect(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(borderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: isDark ? 15 : 8,
                  sigmaY: isDark ? 15 : 8,
                ),
                child: Container(
                  margin: widget.margin,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withAlpha(30) : Colors.white.withAlpha(90),
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(borderRadius),
                    border: Border.all(
                      color: isDark ? Colors.white.withAlpha(60) : Colors.white.withAlpha(120),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isDark ? 77 : 26),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: widget.padding != null
                      ? Padding(
                          padding: widget.padding!,
                          child: widget.child,
                        )
                      : widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}