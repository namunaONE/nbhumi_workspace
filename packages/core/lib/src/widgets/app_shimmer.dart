import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Shimmer effect wrapping a skeleton silhouette with an animated sweep.
///
/// Used behind image placeholders and card skeletons so loading reads as
/// deliberate rather than blank. Disabling [enabled] renders [child] as-is,
/// which keeps widget tests deterministic.
class AppShimmer extends StatefulWidget {
  /// Creates a shimmer wrapper.
  const AppShimmer({required this.child, this.enabled = true, super.key});

  /// The skeleton silhouette the gradient sweeps across.
  final Widget child;

  /// Whether the sweep animation runs.
  final bool enabled;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.shimmerCycle,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseGradient =
        isDark ? AppGradients.shimmerDark : AppGradients.shimmerLight;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final slide = _controller.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-2.0 + (slide * 4.0), -0.3),
              end: Alignment(-0.5 + (slide * 4.0), 0.3),
              colors: baseGradient.colors,
              stops: baseGradient.stops,
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Skeleton placeholder matching listing card dimensions.
///
/// Rendered while the first browse page loads so the grid keeps its shape
/// instead of collapsing to a spinner. Mirrors the cover height and text
/// block of the browse card.
class ListingCardSkeleton extends StatelessWidget {
  /// Creates a skeleton card.
  const ListingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final boneColor = Theme.of(context).colorScheme.surfaceContainerHighest;

    Widget bone({required double height, required double width}) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: boneColor,
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
      );
    }

    return AppShimmer(
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 160,
              width: double.infinity,
              color: boneColor,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  bone(height: 16, width: 140),
                  const SizedBox(height: AppSpacing.sm),
                  bone(height: 12, width: 100),
                  const SizedBox(height: AppSpacing.md),
                  bone(height: 20, width: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
