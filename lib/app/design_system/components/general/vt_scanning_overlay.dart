import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_motion.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';

// The full-screen animation shown while an AI scan runs (meal photo, nutrition
// label). A sweeping scan line over the captured photo plus rotating captions -
// a multi-second model call is a payoff moment, not a spinner. The sweep and the
// caption rotation are continuous loops, not transitions (see the motion scan's
// _allowed). Honours reduce-motion by holding still on the first caption.
class VTScanningOverlay extends StatefulWidget {
  const VTScanningOverlay({required this.captions, this.imageBytes, super.key});

  final List<String> captions;
  final Uint8List? imageBytes;

  @override
  State<VTScanningOverlay> createState() => _VTScanningOverlayState();
}

class _VTScanningOverlayState extends State<VTScanningOverlay> with SingleTickerProviderStateMixin {
  static const double _frameSize = 220;

  late final AnimationController _sweep;
  Timer? _captionTimer;
  int _captionIndex = 0;

  @override
  void initState() {
    super.initState();
    _sweep = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);
    if (widget.captions.length > 1) {
      _captionTimer = Timer.periodic(const Duration(milliseconds: 1600), (_) {
        if (mounted) {
          setState(() => _captionIndex = (_captionIndex + 1) % widget.captions.length);
        }
      });
    }
  }

  @override
  void dispose() {
    _captionTimer?.cancel();
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    // Opaque, not a scrim. At 94% the page underneath still bled through, and on
    // the meal scan that page is showing its own "take a photo" CTA at exactly
    // the height of the caption - so the ghost of that button read as a pill the
    // caption sat crooked inside, with two labels overlapping (issue #235).
    // Nothing behind is worth reading during a scan: the photo being scanned is
    // already the hero of this overlay.
    return ColoredBox(
      color: colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisSize: .min,
          children: [
            ClipRRect(
              borderRadius: VTRadius.borderRadiusL,
              child: SizedBox(
                width: _frameSize,
                height: _frameSize,
                child: Stack(
                  fit: .expand,
                  children: [
                    if (widget.imageBytes case final bytes?)
                      Image.memory(bytes, fit: .cover)
                    else
                      ColoredBox(
                        color: colorScheme.primary.withValues(alpha: 0.10),
                        child: Icon(Icons.center_focus_strong_outlined, size: 72, color: colorScheme.primary),
                      ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: VTRadius.borderRadiusL,
                        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.6), width: 2),
                      ),
                    ),
                    if (!reduceMotion)
                      AnimatedBuilder(
                        animation: _sweep,
                        builder: (context, _) => Align(
                          alignment: Alignment(0, _sweep.value * 2 - 1),
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [colorScheme.primary.withValues(alpha: 0), colorScheme.primary, colorScheme.primary.withValues(alpha: 0)]),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const VTGap.l(),
            // The caption is unconstrained otherwise, so it lays out at the full
            // screen width and the longest one ("Extraindo as informações
            // nutricionais…") runs into both edges before it agrees to wrap.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: VTSpacing.l),
              child: AnimatedSwitcher(
                duration: VTMotion.transition,
                child: Text(
                  widget.captions[_captionIndex],
                  key: ValueKey(_captionIndex),
                  textAlign: .center,
                  style: VTTextStyles.title(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
