# DESIGN.md — nBhumi Design System

> Source of truth is **code**, not this document. Every value below names the
> file and constant that owns it, so the doc can rot without the UI following
> suit. When a token changes, fix the constant — this file follows.
>
> Tokens are mandatory (Rule 43): colors from `ColorScheme` roles,
> `BrandColors` or `MarketplaceColors`; spacing/radii from `AppSpacing` /
> `AppRadius`; sizes and timings from `AppSizes` / `AppDurations`. Test
> fixtures and framework constants are exempt.

---

## 1. Principles

1. **One brand mark, one source.** The logo SVG is the only origin of brand
   color. `BrandColors` samples it; the theme and every accent reference
   `BrandColors` rather than repeating hex literals, so the icon and UI cannot
   drift.
2. **Restraint over decoration.** Blue is reserved for CTAs, active states,
   links and focus rings. Content is carried by neutral surfaces and type, not
   by accent noise.
3. **Hierarchy rides on weight, not size.** Semibold titles over regular body
   keeps the scale short — and short scales survive bilingual layout.
4. **Semantic roles, never hex literals in widgets.**
5. **Mobile-first, window-driven.** Layout follows the available window, not
   the device (see §6). Nepal is ~73% smartphone with only ~15% computer
   penetration, so compact correctness is the default and wider windows are
   upgrades.

---

## 2. Color

### 2.1 Brand palette — `packages/core/lib/src/theme/brand_colors.dart`

| Token | Value | Role |
|---|---|---|
| `logoBlue` | `#002C6D` | Deep brand blue — Material seed, splash background, favicon/theme-color |
| `logoBlueBright` | `#0B3F94` | Logo gradient start |
| `logoGreen` | `#4FD166` | Logo land arc and pin dot; verified-badge fill |
| `logoGradient` | blueBright → logoBlue | Logo background, top-left → bottom-right |

The logo green / logo blue pair is deliberate: green fill with blue foreground
is ≈6.3:1 (WCAG AA), mirroring the logo's own dark pupil on the green dot.

### 2.2 Schemes — `packages/core/lib/src/theme/app_theme.dart`

`ColorScheme.fromSeed(seedColor: BrandColors.logoBlue)`, with logo-keyed
*whole families* transplanted in via `_withLogoFamilies`.

**Why whole families.** `fromSeed`'s `secondary:` / `tertiary:` parameters
replace one role while the `on*` / container mates stay seed-derived, which
breaks pairs (white on raw logo green is 2:1). Each family is therefore
transplanted from a scheme *seeded with that logo key*, preserving the pairing.

`secondary` is keyed to `logoBlueBright`, `tertiary` to `logoGreen`. The one
hand-set pair is `tertiary`/`onTertiary` = logoGreen/logoBlue (≈6.8:1) — the
same brand pair as the verified badge.

**Surfaces** are explicitly set, not seed-derived:

| Light | `#FAFAF8` surface · `#F5F5F2` low · `#EDEDEA` · `#E4E4E0` · `#DCDCD7` highest |
|---|---|
| Dark | `#121417` surface · `#1A1D21` low · `#22262B` · `#2A2F35` · `#33383F` highest |

Warm neutral in light, deep charcoal in dark. Components sit **one step
higher in dark mode** so they lift off the background.

### 2.3 Marketplace accents — `marketplace_colors.dart`

Reached via `Theme.of(context).extension<MarketplaceColors>()`. Widgets must
**never** hard-code these hex values.

| Token | Light | Dark | Use |
|---|---|---|---|
| `verifiedGreen` | `logoGreen` | `logoGreen` | KYC-verified badge fill (logo-locked in **both** schemes) |
| `onVerifiedGreen` | `logoBlue` | `logoBlue` | Verified badge foreground |
| `saleOrange` | `#E65100` | `#FF8A65` | `ListingPurpose.sale` chips |
| `rentBlue` | `#1565C0` | `#64B5F6` | `ListingPurpose.rent` chips |
| `leaseTeal` | `#00695C` | `#4DB6AC` | `ListingPurpose.lease` chips |

Every accent has a matching `on*` foreground. Material 3 asks for on-color
pairs, and a chip filled with `saleOrange` under default black text fails
contrast on the light scheme — hence pairs rather than single values.

### 2.4 Contrast rule

Any foreground/background pair that carries meaning must meet WCAG AA. The
theme exposes `AppTheme.lightScheme` / `AppTheme.darkScheme` separately from
`AppTheme.light` / `.dark` so **tests can assert contrast on generated roles
without building the GoogleFonts text theme** (font bytes never load under
`flutter test`).

---

## 3. Typography — `app_text_theme.dart`

**Plus Jakarta Sans** over the M3 baseline (`Typography.material2021()`).
Devanagari falls back to the system face — Latin-first glyphs, bilingual-safe.

Hierarchy is weight-led; the scale is intentionally short.

| Role | Size / Weight | Tracking | Color |
|---|---|---|---|
| `displayLarge` | 32 / bold | −0.8 | onSurface |
| `displayMedium` | 28 / bold | −0.6 | onSurface |
| `headlineMedium` | 24 / w700 | −0.4 | onSurface |
| `headlineSmall` | 20 / w700 | −0.2 | onSurface |
| `titleLarge` | 18 / w700 | −0.1 | onSurface |
| `titleMedium` | 16 / w600 | — | onSurface |
| `titleSmall` | 14 / w600 | — | onSurface |
| `bodyLarge` | 16 / normal | height 1.5 | onSurface |
| `bodyMedium` | 14 / normal | height 1.45 | onSurface |
| `bodySmall` | 12 / normal | — | onSurfaceVariant |
| `labelLarge` | 14 / w600 | 0.1 | — |
| `labelMedium` | 12 / w600 | — | — |
| `labelSmall` | 11 / w600 | — | — |

App bar and component styles are built directly in `app_theme.dart` from
`GoogleFonts.plusJakartaSans` so they share the family without an extra theme
indirection.

---

## 4. Tokens — `app_tokens.dart`

### 4.1 `AppSpacing` — 4dp base grid, 2dp micro steps

`xxs 2` · `xs 4` · `sm 8` · `md 12` · `lg 16` · `xl 20` · `xxl 24` ·
`xxxl 32` · `huge 48` (also the minimum accessible touch-target height)

### 4.2 `AppRadius`

`xs 6` · `sm 8` (chips/badges) · `md 12` (fields, buttons, alerts) ·
`lg 16` (cards, dialogs) · `xl 20` (bottom sheets, feature cards) ·
`xxl 24` (modals, heroes) · `pill 999`

Prebuilt `radiusSm`…`radiusPill` bridge to `BorderRadius`.

### 4.3 `AppShadows`

`card` (light ambient) · `elevated` (FABs, float) · `darkCard` (separation in
dark mode). Cards also carry a hairline border — shadow alone is not the
separator.

### 4.4 `AppSizes`

| Token | Value | Meaning |
|---|---|---|
| `horizontalCardHeight` | 136 | Row-card height |
| `horizontalThumbWidth` | 128 | Row-card thumbnail width |
| `compactCardThreshold` | 220 | Below this card width the grid uses compact density |
| `loadingRowHeight` | 64 | List-mode footer cell |
| `splashGlyph` | 200 | Splash brand glyph |
| `contentMaxWidth` | 960 | Feed cap; beyond it content centers instead of stretching |

### 4.5 `AppDurations`

`splashFallback 3s` (must exceed the 90-frame @30fps Lottie) ·
`splashBuffer 300ms` · `shimmerCycle 1400ms` · `snackBarShort 2s`

### 4.6 `AppGradients`

`photoScrim` (guarantees white overlay text stays legible over arbitrary
seller photos) · `topScrim` (back/bookmark controls on photo headers) ·
`shimmerLight` / `shimmerDark` (skeleton states)

### 4.7 `AppBreakpoints`

| Token | Value | Effect |
|---|---|---|
| `medium` | 600 | Below → compact bottom bar |
| `expanded` | 840 | At/above → permanent drawer + master-detail |
| `twoPane` | 1000 | At/above → list screens may show the detail pane beside the feed |

`twoPane` sits higher than `expanded` because the pane splits the tab content
that *remains beside the permanent drawer* — both panes need room to breathe.

These live in `core`, not in an app, so features can read them: a feature
cannot import an app (Rule 10), and an app-local copy forces every feature to
restate the numbers — which is how two constants drift apart.

---

## 5. Component themes

Built in `_buildTheme()`. Only four things vary by brightness — the sheet
surface, hairline alphas, text theme, and marketplace tokens. Everything else
is identical by design.

| Component | Notable |
|---|---|
| `AppBar` | Surface background, transparent tint, elevation 0, `scrolledUnderElevation 0.5`, left-aligned title, 19/w700 |
| `Card` | Sheet surface, elevation 0, `AppRadius.lg`, hairline `outlineVariant` border, `Clip.antiAlias`, zero margin |
| `FilledButton` | min 64×48, `AppRadius.md`, 15/w600 |
| `OutlinedButton` | min 64×48, `outline` @0.5 side |
| `TextButton` | min 48×44, 14/w600 |
| `InputDecoration` | Filled with sheet colour, `lg` horizontal / `md` vertical padding, `AppRadius.md`, 1.8px brand focus ring |
| `NavigationBar` | Sheet surface, elevation 1, `primaryContainer` indicator, selected label w700 |
| `NavigationRail` | Sheet surface, `primaryContainer` indicator, brand selected label |
| `BottomSheet` | Sheet surface, transparent tint, drag handle, top `AppRadius.xxl` |
| `Dialog` | Sheet surface, transparent tint, `AppRadius.xl` |
| `Divider` | `outlineVariant` @hairline, space 1, thickness 1 |
| `SnackBar` | Floating, `AppRadius.md` |

---

## 6. Adaptive layout

The whole rule in one line: **decide from the space you were given, not from
the device you're on.**

### 6.1 Measuring

| Use | Tool |
|---|---|
| Window-level chrome (the shell's navigation affordance) | `MediaQuery.sizeOf(context)` |
| A component's own allotted space (the nav shell, the listing grid) | `LayoutBuilder` → `constraints.maxWidth` |

Prefer `MediaQuery.sizeOf(context)` over `MediaQuery.of(context).size`: the
former only notifies on size change, the latter on *every* `MediaQueryData`
change. Never cache a size from either.

### 6.2 Branching — Material 3 window size classes

| Class | Width | nBhumi effect |
|---|---|---|
| compact | <600 | Notched `BottomAppBar` + centre-docked post FAB |
| medium | 600–839 | `NavigationRail`, post action in the rail's trailing slot |
| expanded | 840–1199 | Permanent `NavigationDrawer` (220px) + `VerticalDivider` |
| large | 1200–1599 | As expanded; feed content capped at `AppSizes.contentMaxWidth` |
| extra-large | 1600+ | As large |

The two-pane threshold is **1000**, not 840 — see §4.7.

### 6.3 Feed grids — count from content, not from breakpoints

`ListingGrid.columnsFor(availableWidth)` derives the column count from a
**minimum card width** (180px) rather than stepping at a viewport breakpoint,
clamped to 1–3 (WIREFRAMES.md specifies no more). The `n−1` inter-card gaps
are folded into the divisor:

```
fit = (availableWidth + spacing) / (minCardWidth + spacing)
columns = fit.floor().clamp(1, 3)
```

Plain `availableWidth / minCardWidth` overcounts: at 362px it yields 2 columns
and then hands each card 175px — under the minimum. Solving `(w + s)/(m + s) >= n`
for `n` gives the exact fit condition, so no width ever produces a too-narrow
card. Per-card density (`AppSizes.compactCardThreshold`, 220) then picks the
compact card when the computed column is narrow.

Wide windows are handled by `Align` + `ConstrainedBox(maxWidth:
AppSizes.contentMaxWidth)` wrapped **outside** the scrollable, so
pull-to-refresh keeps full width.

### 6.4 Forbidden patterns

These crash with *"LayoutBuilder does not support returning intrinsic
dimensions"*:

- `LayoutBuilder` inside `AlertDialog` / `Dialog` content
- `LayoutBuilder` under `IntrinsicHeight` / `IntrinsicWidth`
- `LayoutBuilder` inside `CustomScrollView` / sliver subtrees (use
  `SliverLayoutBuilder` with cross-axis caching, or hoist the builder above the
  scroll view)
- Any `Ink`-based Material widget in an intrinsic context (`Ink` uses a
  `LayoutBuilder` internally)

Also avoid: `OrientationBuilder` or `MediaQuery.orientation` near the top of
the tree (orientation does not describe window space), branching on
`Platform.is*` / device type, and locking orientation.

A regression test keeps these out of our tree — see
`apps/user_app/test/layout_builder_guard_test.dart`.

### 6.5 Input beyond touch

On web and desktop, Material widgets already handle scroll-wheel,
right-click, hover and tab traversal. Custom widgets must add it explicitly:
`MouseRegion(cursor:)`, `Shortcuts` / `Actions` /
`FocusableActionDetector`, `FocusTraversalGroup`, and `VisualDensity` for
hit-area tuning.

---

## 7. Verification

Golden tests cover the five key screens × {compact, expanded} × {light, dark}
— 20 images under `apps/user_app/test/goldens/ci/`, generated by Alchemist.

> Goldens update **only on `main`** in CI (Rule 34). Golden-mismatch dumps
> land in `apps/user_app/test/failures/`, which Rule 44 names a debug dump —
> it is gitignored and must never be committed.

Layout changes that cross a breakpoint must be re-goldened on `main` only, and
never by editing the committed PNGs by hand.
