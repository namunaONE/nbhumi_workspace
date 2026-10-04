import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:models/models.dart';

import '../viewmodels/listing_wizard_provider.dart';
import '../viewmodels/listing_wizard_state.dart';
import '../viewmodels/listing_wizard_validation.dart';
import 'steps/location_step.dart';
import 'steps/price_photos_step.dart';
import 'steps/review_step.dart';
import 'steps/specs_step.dart';
import 'steps/type_step.dart';

/// Post listing wizard: type -> location -> specs -> price/photos -> review.
///
/// A stepper rather than a pager, because the seller needs to see how far
/// through they are and be able to go back to any completed step. Each step is
/// validated before the wizard will advance, and the messages are inline on the
/// offending field rather than a dialog.
///
/// Submitting creates the listing as `pending_review`. It does not go live
/// until an admin approves it.
class PostListingScreen extends ConsumerWidget {
  /// Creates the wizard shell.
  const PostListingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(listingWizardProvider);
    final notifier = ref.read(listingWizardProvider.notifier);
    final districts = ref.watch(districtsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.step.title),
        // Leaving mid-form is allowed and the answers are kept, so a seller
        // interrupted by a call does not lose the listing.
        leading: CloseButton(
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _Progress(step: state.step),
        ),
      ),
      body: SafeArea(
        child: districts.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          // Reference data failing is not the seller's fault and blocks the
          // whole form, so it says what happened rather than showing empty
          // fields they cannot use.
          error: (error, stackTrace) => _DistrictsUnavailable(
            message: AppException.unmapped(error).localizedForContext(context),
          ),
          data: (loaded) => _StepBody(
            state: state,
            districts: loaded,
            notifier: notifier,
          ),
        ),
      ),
    );
  }
}

/// Renders the current step and the navigation bar.
class _StepBody extends StatelessWidget {
  const _StepBody({
    required this.state,
    required this.districts,
    required this.notifier,
  });

  final ListingWizardState state;
  final List<District> districts;
  final ListingWizard notifier;

  @override
  Widget build(BuildContext context) {
    final step = switch (state.step) {
      WizardStep.type => TypeStep(
          state: state,
          onTypeSelected: notifier.setPropertyType,
          onPurposeSelected: notifier.setPurpose,
        ),
      WizardStep.location => LocationStep(
          state: state,
          districts: districts,
          onDistrictChanged: notifier.setDistrict,
          onCityChanged: notifier.setCity,
          onWardChanged: notifier.setWard,
          onRoadAccessChanged: notifier.setRoadAccessFt,
        ),
      WizardStep.specs => SpecsStep(
          state: state,
          onUnitChanged: notifier.setAreaUnit,
          onBedroomsChanged: notifier.setBedrooms,
          onBathroomsChanged: notifier.setBathrooms,
        ),
      WizardStep.price => PricePhotosStep(
          state: state,
          onPriceChanged: notifier.setPrice,
          onAddPhotos: notifier.addPhotos,
          onRemovePhoto: notifier.removePhoto,
        ),
      WizardStep.review => ReviewStep(
          state: state,
          onEditStep: notifier.goTo,
          onSubmit: () => _submit(context),
        ),
    };

    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: step,
          ),
        ),
        _Navigation(
          state: state,
          onBack: notifier.back,
          onNext: state.step == WizardStep.review
              ? () => _submit(context)
              : notifier.next,
        ),
      ],
    );
  }

  Future<void> _submit(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final ok = await notifier.submit();
    if (!ok) return;

    messenger.showSnackBar(
      const SnackBar(
        content: Text('Sent for review. It will appear once approved.'),
      ),
    );
    router.go('/');
  }
}

/// Back / Next bar.
///
/// Next is disabled when the current step does not validate, so the seller is
/// told what is missing by pressing it rather than by the button greying out
/// with no explanation.
class _Navigation extends StatelessWidget {
  const _Navigation({
    required this.state,
    required this.onBack,
    required this.onNext,
  });

  final ListingWizardState state;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isLast = state.step == WizardStep.review;
    final isValid = state.canLeave(state.step);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          if (state.step.previous != null) ...<Widget>[
            Expanded(
              child: OutlinedButton(
                onPressed: onBack,
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: isValid ? onNext : null,
              child: Text(isLast ? 'Submit' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Linear progress through the five steps.
class _Progress extends StatelessWidget {
  const _Progress({required this.step});

  final WizardStep step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LinearProgressIndicator(
            value: (step.position + 1) / WizardStep.values.length,
          ),
          const SizedBox(height: 4),
          Text(
            'Step ${step.position + 1} of ${WizardStep.values.length}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

/// Shown when reference data cannot be loaded.
class _DistrictsUnavailable extends StatelessWidget {
  const _DistrictsUnavailable({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.cloud_off,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load districts',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Check your connection and try again.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
