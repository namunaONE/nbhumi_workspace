import 'package:flutter/material.dart';

/// Spacing tokens for consistent layout hierarchy across the user app.
///
/// Every screen uses these rather than ad-hoc literals so density stays
/// uniform. Values follow a 4dp base grid with 2dp micro steps for chips.
abstract final class AppSpacing {
  AppSpacing._();

  /// 2 logical pixels — hairline separation inside chips and badges.
  static const double xxs = 2;

  /// 4 logical pixels — micro spacing inside compact badges.
  static const double xs = 4;

  /// 8 logical pixels — standard small spacing between tightly paired items.
  static const double sm = 8;

  /// 12 logical pixels — medium spacing between card elements.
  static const double md = 12;

  /// 16 logical pixels — default screen margin and container padding.
  static const double lg = 16;

  /// 20 logical pixels — generous padding inside cards or modals.
  static const double xl = 20;

  /// 24 logical pixels — section separator.
  static const double xxl = 24;

  /// 32 logical pixels — major landmark spacing.
  static const double xxxl = 32;

  /// 48 logical pixels — hero and empty-state vertical padding, and the
  /// minimum accessible touch target height.
  static const double huge = 48;
}

/// Border radius tokens for smooth, modern curved surfaces.
abstract final class AppRadius {
  AppRadius._();

  /// 6 logical pixels radius.
  static const double xs = 6;

  /// 8 logical pixels radius — chips and small badges.
  static const double sm = 8;

  /// 12 logical pixels radius — text fields, buttons, and alert callouts.
  static const double md = 12;

  /// 16 logical pixels radius — listing cards and dialog containers.
  static const double lg = 16;

  /// 20 logical pixels radius — bottom sheets and feature cards.
  static const double xl = 20;

  /// 24 logical pixels radius — modals and large hero banners.
  static const double xxl = 24;

  /// Fully rounded pill radius.
  static const double pill = 999;

  /// Small border radius (8px) for chips and compact badges.
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));

  /// Medium border radius (12px) for inputs and buttons.
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(md));

  /// Large border radius (16px) for cards and containers.
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(lg));

  /// Extra-large border radius (20px) for bottom sheets.
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(xl));

  /// Double-extra-large border radius (24px) for modals.
  static const BorderRadius radiusXxl = BorderRadius.all(Radius.circular(xxl));

  /// Fully rounded pill border radius.
  static const BorderRadius radiusPill =
      BorderRadius.all(Radius.circular(pill));
}

/// Elevation and subtle shadow tokens for premium depth.
///
/// Cards use hairline borders plus [card] in light mode; dark mode prefers
/// surface-tint elevation and [darkCard] only where separation is needed.
abstract final class AppShadows {
  AppShadows._();

  /// Subtle ambient card shadow for light theme.
  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(
      color: Color(0x0A002C6D),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Elevated shadow for floating action buttons or active modal sheets.
  static const List<BoxShadow> elevated = <BoxShadow>[
    BoxShadow(
      color: Color(0x14002C6D),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  /// Soft dark theme shadow.
  static const List<BoxShadow> darkCard = <BoxShadow>[
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}

/// Fixed dimensions for card layouts and feed adornments.
///
/// Keeps magic numbers out of widgets (Rule 43): every hand-placed height,
/// width, and breakpoint threshold lives here beside the spacing tokens.
abstract final class AppSizes {
  AppSizes._();

  /// Fixed height of the horizontal row card.
  static const double horizontalCardHeight = 136;

  /// Fixed thumbnail width of the horizontal row card.
  static const double horizontalThumbWidth = 128;

  /// Per-card width below which the grid switches to compact density.
  static const double compactCardThreshold = 220;

  /// Height of the list-mode loading footer cell.
  static const double loadingRowHeight = 64;

  /// Display size of the splash-screen brand glyph (HYA-294).
  static const double splashGlyph = 200;

  /// Maximum feed content width on wide windows. Beyond this the grid would
  /// stretch three cards across the whole screen, so the content centers
  /// instead. Phones never reach it.
  static const double contentMaxWidth = 960;
}

/// Layout widths at which the navigation affordance changes.
///
/// Material's 600 and 840 breakpoints. These live in `core` rather than in an
/// app so that features can read the same thresholds: a feature cannot import
/// an app (Rule 10), so an app-local `AppBreakpoints` forces every feature to
/// restate the numbers, which is how two breakpoints drift apart.
///
/// The widths describe the *app window*, not the device: a tablet can be in
/// split-screen and a desktop window can be 500 pixels wide. Branching on the
/// window keeps the layout correct on foldables and in free-form/multi-window
/// mode, where `Platform.is`-style checks break.
abstract final class AppBreakpoints {
  AppBreakpoints._();

  /// Below this, a compact bottom navigation bar.
  static const double medium = 600;

  /// At or above this, a permanent drawer and master-detail layouts.
  static const double expanded = 840;

  /// At or above this window width, list screens may show the detail side
  /// pane next to the feed instead of pushing the full route. Higher than
  /// [expanded] because the pane splits the tab content that remains beside
  /// the permanent drawer — both panes need room to breathe.
  static const double twoPane = 1000;
}

/// Animation and timing tokens.
///
/// Durations shared by animations, splash handoffs, and transient UI
/// (snack bars) live here so motion stays uniform (Rule 43). Test
/// `pump()` durations and framework polling periods are exempt.
abstract final class AppDurations {
  AppDurations._();

  /// Splash backstop: dismiss even if the Lottie composition never loads.
  /// Must exceed the animation length (90 frames at 30fps = 3s).
  static const Duration splashFallback = Duration(seconds: 3);

  /// Grace period after the splash animation completes before dismissing.
  static const Duration splashBuffer = Duration(milliseconds: 300);

  /// One shimmer sweep cycle for skeleton loading states.
  static const Duration shimmerCycle = Duration(milliseconds: 1400);

  /// Short transient-message duration for success snack bars.
  static const Duration snackBarShort = Duration(seconds: 2);
}

/// Curated gradients for image legibility and loading states.
///
/// [photoScrim] and [topScrim] guarantee white overlay text and controls
/// stay legible over arbitrary seller photos. Shimmer gradients back the
/// skeleton loading states.
abstract final class AppGradients {
  AppGradients._();

  /// Rich dark gradient for photo overlays to ensure white text contrast.
  static const LinearGradient photoScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      Color(0x00000000),
      Color(0x33000000),
      Color(0xCC000000),
    ],
    stops: <double>[0.4, 0.7, 1],
  );

  /// Top scrim for photo headers to keep back and bookmark buttons visible.
  static const LinearGradient topScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      Color(0x88000000),
      Color(0x00000000),
    ],
  );

  /// Shimmer loading gradient for skeletons in light mode.
  static const LinearGradient shimmerLight = LinearGradient(
    begin: Alignment(-1, -0.3),
    end: Alignment(1, 0.3),
    colors: <Color>[
      Color(0xFFEBEBF0),
      Color(0xFFF7F7FA),
      Color(0xFFEBEBF0),
    ],
    stops: <double>[0.1, 0.5, 0.9],
  );

  /// Dark shimmer loading gradient.
  static const LinearGradient shimmerDark = LinearGradient(
    begin: Alignment(-1, -0.3),
    end: Alignment(1, 0.3),
    colors: <Color>[
      Color(0xFF1E2430),
      Color(0xFF2B3342),
      Color(0xFF1E2430),
    ],
    stops: <double>[0.1, 0.5, 0.9],
  );
}
