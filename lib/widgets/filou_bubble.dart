import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../theme/filou_state.dart';

/// A themed speech-bubble card from Filou the mascot.
///
/// Displays Filou's PNG illustration (with emoji fallback) alongside
/// a message. Colors adapt to the current theme via [MascotColors].
///
/// Features:
/// - Bouncy entrance animation (scale + fade + slide up)
/// - Gentle idle breathing / floating animation
/// - Configurable size with larger default (160px)
class FilouBubble extends StatefulWidget {
  final FilouState state;
  final String message;
  final VoidCallback? onTap;
  final String? actionLabel;
  final double imageSize;
  /// If true, Filou does a gentle floating idle animation after entrance.
  final bool animate;

  const FilouBubble({
    super.key,
    this.state = FilouState.happy,
    required this.message,
    this.onTap,
    this.actionLabel,
    this.imageSize = 220,
    this.animate = true,
  });

  @override
  State<FilouBubble> createState() => _FilouBubbleState();
}

class _FilouBubbleState extends State<FilouBubble>
    with TickerProviderStateMixin {
  // Entrance animation
  late final AnimationController _entranceController;
  late final Animation<double> _entranceScale;
  late final Animation<double> _entranceFade;
  late final Animation<Offset> _entranceSlide;

  // Idle breathing / floating animation
  late final AnimationController _idleController;

  @override
  void initState() {
    super.initState();

    // ── Entrance: bouncy scale-up + fade-in + slide-up ──
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _entranceScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.elasticOut,
      ),
    );

    _entranceFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _entranceSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutCubic,
      ),
    );

    _entranceController.forward();

    // ── Idle: gentle floating / breathing ──
    _idleController = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );

    if (widget.animate) {
      // Start idle after entrance completes
      _entranceController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _idleController.repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mascot = context.mascotColors;

    return SlideTransition(
      position: _entranceSlide,
      child: FadeTransition(
        opacity: _entranceFade,
        child: ScaleTransition(
          scale: _entranceScale,
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacingLg,
              vertical: DesignTokens.spacingMd,
            ),
            padding: const EdgeInsets.all(DesignTokens.spacingXl),
            decoration: BoxDecoration(
              color: mascot.background,
              borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
              border: Border.all(
                color: mascot.outline.withValues(alpha: 0.12),
              ),
              boxShadow: [
                BoxShadow(
                  color: mascot.fur.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: mascot.fur.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated mascot image
                _buildAnimatedMascot(),
                const SizedBox(height: DesignTokens.spacingMd),
                // Message
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: context.colors.onSurface,
                    height: 1.45,
                  ),
                ),
                // Optional CTA button
                if (widget.actionLabel != null && widget.onTap != null) ...[
                  const SizedBox(height: DesignTokens.spacingLg),
                  FilledButton.icon(
                    onPressed: widget.onTap,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: Text(
                      widget.actionLabel!,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: mascot.fur,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacingXl,
                        vertical: DesignTokens.spacingSm + 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(DesignTokens.radiusMd),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedMascot() {
    if (!widget.animate) {
      return _buildMascotImage();
    }

    return AnimatedBuilder(
      animation: _idleController,
      builder: (context, child) {
        // Gentle floating: ±4px vertical + subtle scale breathing
        final floatOffset = math.sin(_idleController.value * math.pi) * 4.0;
        final breathScale = 1.0 + math.sin(_idleController.value * math.pi) * 0.03;

        return Transform.translate(
          offset: Offset(0, -floatOffset),
          child: Transform.scale(
            scale: breathScale,
            child: child,
          ),
        );
      },
      child: _buildMascotImage(),
    );
  }

  Widget _buildMascotImage() {
    return Image.asset(
      widget.state.assetPath,
      width: widget.imageSize,
      height: widget.imageSize,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to emoji if image not found
        return Text(
          widget.state.fallbackEmoji,
          style: TextStyle(fontSize: widget.imageSize * 0.5),
        );
      },
    );
  }
}
