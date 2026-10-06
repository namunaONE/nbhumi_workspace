import 'package:flutter/material.dart';
import 'package:models/models.dart';

/// The listing's photographs.
///
/// A horizontal strip rather than a full-screen gallery: an admin reviewing a
/// queue needs to see *enough* to judge whether the photos are adequate, and
/// most rejections are for "one photo of a wall". Making them tap-through to a
/// full-screen viewer would add a navigation layer for the rare case.
///
/// A fixed placeholder height rather than a zero-height one: a listing with no
/// photos must still occupy predictable space, so the specifications below it
/// do
/// not jump as images load.
class PhotoGallery extends StatelessWidget {
  /// Creates a gallery for [urls].
  const PhotoGallery({required this.urls, super.key});

  /// Photo URLs, in the server's `sort_order`.
  final List<String> urls;

  /// Height of one thumbnail.
  static const double thumbnailHeight = 180;

  /// Width of one thumbnail.
  static const double thumbnailWidth = 260;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (urls.isEmpty) {
      return _EmptyGallery(theme: theme);
    }

    // Under the floor is already called out on the queue row, but repeating it
    // here is deliberate: the row tells an admin a listing is thin *before*
    // they
    // open it, and this is the point where they decide to reject it.
    final isThin = urls.length < minPhotosPerListing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: thumbnailHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: urls.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) => _Thumbnail(url: urls[index]),
          ),
        ),
        if (isThin) _ThinGalleryNotice(count: urls.length),
      ],
    );
  }
}

/// Shown when a listing has no photos at all.
///
/// Names the problem rather than showing an empty frame: "no photos" and "the
/// photos failed to load" are different faults, and only one of them is the
/// seller's to fix.
class _EmptyGallery extends StatelessWidget {
  const _EmptyGallery({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: PhotoGallery.thumbnailHeight,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.photo_camera_back_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'No photos uploaded.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Notice that fewer photos were uploaded than the wizard asked for.
class _ThinGalleryNotice extends StatelessWidget {
  const _ThinGalleryNotice({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.info_outline,
            size: 14,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$count of the $minPhotosPerListing photos asked for.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One photo.
///
/// `loadingBuilder` is left at its default on purpose: a spinner per thumbnail
/// flashes the whole strip as images arrive, which is worse than a blank frame.
/// `errorBuilder` is not — a broken URL must degrade to a placeholder rather
/// than throw, since the admin still has to review the rest of the listing.
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: PhotoGallery.thumbnailWidth,
        height: PhotoGallery.thumbnailHeight,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => ColoredBox(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.broken_image_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
