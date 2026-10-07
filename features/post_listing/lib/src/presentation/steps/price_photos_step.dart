import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:post_listing/l10n/output/post_localizations.dart'
    as post_strings;

import '../../viewmodels/listing_wizard_state.dart';
import '../../viewmodels/listing_wizard_validation.dart';
import '../../widgets/wizard_fields.dart';

/// Wizard step 4: price and photos.
///
/// ### Why the price is entered as a plain number
///
/// Not a lakh/crore picker. Sellers read Nepali prices as `NPR 2.5 Cr` but they
/// *write* the digits, and a picker that guessed the unit from what they typed
/// would introduce a rounding step where a typo becomes a different price.
/// The number is stored as typed and formatted for display with
/// [NepaliCurrency] (Rule 27).
class PricePhotosStep extends StatelessWidget {
  /// Creates the price and photos step.
  const PricePhotosStep({
    required this.state,
    required this.onPriceChanged,
    required this.onAddPhotos,
    required this.onRemovePhoto,
    super.key,
  });

  /// Current wizard state.
  final ListingWizardState state;

  /// Called when the price field changes.
  final void Function(String value) onPriceChanged;

  /// Called to open the system photo picker.
  final VoidCallback onAddPhotos;

  /// Called with the index of a photo to remove.
  final void Function(int index) onRemovePhoto;

  @override
  Widget build(BuildContext context) {
    final strings = post_strings.AppLocalizations.of(context);
    final errors = state.validate(WizardStep.price, strings);
    final price = int.tryParse(state.priceNpr.trim());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        WizardSection(strings.priceTitle),
        WizardField(
          label: strings.fieldPrice,
          suffixText: 'NPR',
          value: state.priceNpr,
          error: errors['priceNpr'],
          keyboardType: TextInputType.number,
          inputFormatters: digitsOnly,
          onChanged: onPriceChanged,
        ),
        // Echoing the formatted figure catches a mistyped digit immediately,
        // which matters far more here than anywhere else in the form.
        if (price != null && price > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: WizardNote(
              icon: Icons.check_circle_outline,
              text: strings.buyersWillSee(NepaliCurrency.full(price)),
            ),
          ),
        WizardSection(
          strings.photosTitle,
          subtitle: strings.photosSubtitle,
        ),
        _PhotoGrid(
          photos: state.photos,
          error: errors['photos'],
          onAdd: onAddPhotos,
          onRemove: onRemovePhoto,
        ),
      ],
    );
  }
}

/// The photo grid, plus the add button.
///
/// Failures stay visible in place rather than disappearing, because a photo
/// that vanishes silently leaves the seller believing it was added.
class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({
    required this.photos,
    required this.onAdd,
    required this.onRemove,
    this.error,
  });

  final List<WizardPhoto> photos;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (var i = 0; i < photos.length; i++)
              _PhotoTile(
                photo: photos[i],
                onRemove: () => onRemove(i),
              ),
            _AddTile(onTap: onAdd),
          ],
        ),
        if (error case final message?) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.error),
          ),
        ],
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.photo, required this.onRemove});

  final WizardPhoto photo;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final failed = photo.error != null;

    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: photo.isUploading
                ? ColoredBox(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : failed
                    ? ColoredBox(
                        color: theme.colorScheme.errorContainer,
                        child: Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      )
                    : Image.network(
                        photo.url,
                        cacheWidth: 200,
                        fit: BoxFit.cover,
                        // A broken URL must not leave a hole in the grid.
                        errorBuilder: (context, error, stackTrace) =>
                            ColoredBox(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              iconSize: 18,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              icon: const Icon(Icons.close),
              tooltip: post_strings.AppLocalizations.of(context).removePhoto,
              onPressed: onRemove,
            ),
          ),
          if (failed)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ColoredBox(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    photo.error!.localizedForContext(context),
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.onErrorContainer),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.add_a_photo_outlined,
            color: theme.colorScheme.outline),
      ),
    );
  }
}
