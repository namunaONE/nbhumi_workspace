import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import 'app_shimmer.dart';

/// Network image with consistent loading, error, and decode behaviour.
///
/// Every remote photo in the app renders through [AppImage] so grids, detail
/// heroes, and wizard previews cannot drift apart. Loading shows a shimmer
/// over the theme surface; failures show a muted icon rather than a hole.
///
/// [cacheWidth] targets roughly display size times device pixel ratio. Callers
/// that know their layout width should pass it; otherwise a sensible 400px
/// default keeps grid decoding cheap without visibly softening cards.
///
/// Presentation only: this never claims to repair low-resolution source
/// uploads and never alters backend image processing.
class AppImage extends StatelessWidget {
  /// Creates an app image.
  const AppImage({
    required this.url,
    this.fit = BoxFit.cover,
    this.cacheWidth = 400,
    this.placeholderIcon = Icons.home_work_outlined,
    this.semanticLabel,
    super.key,
  });

  /// Remote image URL. Null or empty renders the placeholder directly.
  final String? url;

  /// How the image fills its bounds. Deliberate crop by default.
  final BoxFit fit;

  /// Decode width hint passed to [Image.network].
  final int cacheWidth;

  /// Icon shown while loading, on error, or when [url] is absent.
  final IconData placeholderIcon;

  /// Accessibility label for the image.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (url == null || url!.isEmpty) {
      return _Placeholder(icon: placeholderIcon);
    }
    return Image.network(
      url!,
      fit: fit,
      cacheWidth: cacheWidth,
      semanticLabel: semanticLabel,
      errorBuilder: (context, error, stackTrace) =>
          const _Placeholder(icon: Icons.broken_image_outlined),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return AppShimmer(
          child: Container(
            color: theme.colorScheme.surfaceContainerHighest,
            width: double.infinity,
            height: double.infinity,
          ),
        );
      },
    );
  }
}

/// Muted placeholder box used for loading, error, and absent URLs.
class _Placeholder extends StatelessWidget {
  /// Creates a placeholder.
  const _Placeholder({required this.icon});

  /// Icon centred in the box.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Icon(
          icon,
          size: 40,
          color: theme.colorScheme.outline.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

/// Swipeable photo gallery with count badge and progress dots.
///
/// Used on the listing detail hero. Falls back to a placeholder when [photos]
/// is empty so layout never collapses. The `n / total` badge and dots make
/// multi-photo listings discoverable without extra taps.
class AppImageGallery extends StatefulWidget {
  /// Creates an image gallery.
  const AppImageGallery({
    required this.photos,
    this.height = 260,
    this.title,
    super.key,
  });

  /// Photo URLs in display order.
  final List<String> photos;

  /// Gallery viewport height.
  final double height;

  /// Listing title, used as the semantic label for photos.
  final String? title;

  @override
  State<AppImageGallery> createState() => _AppImageGalleryState();
}

class _AppImageGalleryState extends State<AppImageGallery> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (widget.photos.isEmpty) {
      return SizedBox(
        height: widget.height,
        width: double.infinity,
        child: ColoredBox(
          color: theme.colorScheme.surfaceContainerHighest,
          child: Center(
            child: Icon(
              Icons.home,
              size: 64,
              color: theme.colorScheme.outline.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          PageView.builder(
            controller: _controller,
            itemCount: widget.photos.length,
            onPageChanged: (next) => setState(() => _index = next),
            itemBuilder: (context, page) => AppImage(
              url: widget.photos[page],
              cacheWidth: 1000,
              semanticLabel: widget.title,
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppGradients.topScrim,
              ),
            ),
          ),
          if (widget.photos.length > 1)
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  // M3 scrim role (Rule 43); white content per the comment in
                  // price_photos_step: no onScrim role, ~21:1 by construction.
                  color: Theme.of(context)
                      .colorScheme
                      .scrim
                      .withValues(alpha: 0.6),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Text(
                  '${_index + 1} / ${widget.photos.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          if (widget.photos.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.sm,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for (var dot = 0; dot < widget.photos.length; dot++)
                    Container(
                      width: dot == _index ? 20 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: dot == _index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
