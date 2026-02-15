import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/filou_state.dart';

/// TutorialService — mascot-integrated coach marks.
///
/// Every tutorial tooltip includes Filou holding / presenting the popup,
/// making the experience feel guided by the mascot rather than generic
/// system-driven overlays.
class TutorialService {
  static void showTutorial({
    required BuildContext context,
    required List<TargetFocus> targets,
    required Function() onFinish,
  }) {
    TutorialCoachMark(
      targets: targets,
      colorShadow: const Color(0xFF0F172A),
      textSkip: "PASSER ✕",
      paddingFocus: 10,
      opacityShadow: 0.85,
      onFinish: onFinish,
      onSkip: () {
        onFinish(); // Mark as seen even if skipped
        return true;
      },
      textStyleSkip: GoogleFonts.nunito(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ).show(context: context);
  }

  /// Creates a tutorial target with Filou mascot integrated into the tooltip.
  ///
  /// [filou] determines which mascot pose to show (defaults to [FilouState.waving]).
  /// The tooltip displays Filou's image alongside the title, description,
  /// a step counter, and a "Suivant" / "C'est parti !" button.
  static TargetFocus createTarget({
    required GlobalKey key,
    required String title,
    required String description,
    ContentAlign align = ContentAlign.bottom,
    ShapeLightFocus shape = ShapeLightFocus.RRect,
    double radius = 10,
    FilouState filou = FilouState.waving,
    int? stepNumber,
    int? totalSteps,
    bool isLast = false,
  }) {
    return TargetFocus(
      identify: title,
      keyTarget: key,
      alignSkip: Alignment.topRight,
      shape: shape,
      radius: radius,
      enableOverlayTab: true,
      contents: [
        TargetContent(
          align: align,
          builder: (context, controller) {
            return _FilouTooltip(
              title: title,
              description: description,
              filou: filou,
              stepNumber: stepNumber,
              totalSteps: totalSteps,
              isLast: isLast,
              onNext: () => controller.next(),
            );
          },
        ),
      ],
    );
  }
}

/// Animated mascot tooltip widget used inside tutorial coach marks.
class _FilouTooltip extends StatefulWidget {
  final String title;
  final String description;
  final FilouState filou;
  final int? stepNumber;
  final int? totalSteps;
  final bool isLast;
  final VoidCallback onNext;

  const _FilouTooltip({
    required this.title,
    required this.description,
    required this.filou,
    this.stepNumber,
    this.totalSteps,
    required this.isLast,
    required this.onNext,
  });

  @override
  State<_FilouTooltip> createState() => _FilouTooltipState();
}

class _FilouTooltipState extends State<_FilouTooltip>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _slideUp;
  late final Animation<double> _fadeIn;
  late final AnimationController _bounceController;

  @override
  void initState() {
    super.initState();

    // Entrance: slide up + fade in
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideUp = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _entranceController.forward();

    // Mascot idle bounce
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entranceController, _bounceController]),
      builder: (context, child) {
        final bounce = (_bounceController.value - 0.5) * 6.0; // ±3px

        return Transform.translate(
          offset: Offset(0, _slideUp.value),
          child: Opacity(
            opacity: _fadeIn.value,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // ── Filou mascot ──
                Transform.translate(
                  offset: Offset(0, -bounce),
                  child: SizedBox(
                    width: 120,
                    height: 150,
                    child: Image.asset(
                      widget.filou.assetPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Text(
                        widget.filou.fallbackEmoji,
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // ── Speech bubble ──
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                        bottomLeft: Radius.circular(4), // "tail" toward Filou
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Step counter
                        if (widget.stepNumber != null && widget.totalSteps != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                ...List.generate(widget.totalSteps!, (i) {
                                  final isActive = i < widget.stepNumber!;
                                  return Container(
                                    width: isActive ? 18 : 8,
                                    height: 4,
                                    margin: const EdgeInsets.only(right: 4),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  );
                                }),
                                const Spacer(),
                                Text(
                                  '${widget.stepNumber}/${widget.totalSteps}',
                                  style: GoogleFonts.nunito(
                                    color: Colors.white60,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Title
                        Text(
                          widget.title,
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontSize: 18,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Description
                        Text(
                          widget.description,
                          style: GoogleFonts.nunito(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Next / Done button
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: widget.onNext,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.white.withValues(alpha: 0.18),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.isLast ? "C'est parti !" : "SUIVANT",
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  widget.isLast
                                      ? Icons.rocket_launch_rounded
                                      : Icons.arrow_forward_rounded,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
