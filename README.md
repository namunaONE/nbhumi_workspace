# nBhumi — Nepal Property Marketplace

A full-stack property marketplace for Nepal built with Flutter + Supabase.

## Monorepo: Native Pub Workspaces

This repo uses **Dart's native workspace feature** (Dart 3.6+). No Melos.

```yaml
# Root pubspec.yaml
workspace:
  - apps/*
  - packages/*
  - features/*
```

Every package sets `resolution: workspace` in its `pubspec.yaml`. One `dart pub get` at root links all local packages.

## Quick Start

```bash
# Install dependencies (one command at root)
dart pub get

# Run code generation
dart run build_runner build -d

# Run analysis
dart analyze

# Run tests
dart test
(cd apps/user_app && flutter test)

# Run mobile app
flutter run apps/user_app

# Run admin panel
flutter run apps/admin_panel -d chrome
```

## Structure

```
nbhumi_workspace/
├── apps/
│   ├── user_app/          # Flutter mobile (Android/iOS)
│   └── admin_panel/       # Flutter web admin
├── packages/
│   ├── models/            # Freezed + json_serializable
│   ├── core/              # Theme, utils, validators
│   └── data/              # Repositories, services, Supabase client
├── features/
│   ├── listing_detail/    # Listing detail feature
│   ├── search/            # Search and filtering
│   ├── post_listing/      # Post listing wizard
│   ├── auth/              # Authentication
│   └── admin_queue/       # Admin verification queue
├── pubspec.yaml           # Workspace root
├── analysis_options.yaml  # Lint rules
├── Makefile               # Build commands
└── .gitignore
```

## Stack

- **Flutter 3.47** + **Dart 3.13**
- **Riverpod 3.0** (AsyncNotifier, Mutation, codegen)
- **Supabase** (Postgres, Auth magic-link, Storage, RLS, Realtime)
- **Material 3** (seed #002C6D, light+dark)
- **MVVM + Clean Architecture** (Views → ViewModels → Repositories → Services)

## Roles

Guest (browse) → Buyer (save/contact) → Seller/Agent (post listings, KYC) → Admin (verify/moderate)

## Environments & Flavors (HYA-239)

One flavor per backend. The flavor selects the *native* identity
(applicationId, display name) so builds install side-by-side; the
`ENVIRONMENT` dart-define selects the Dart-side backend and log verbosity
and **must match the flavor**.

| Flavor | Backend | Logging | App name (Android / iOS) |
|--------|---------|---------|--------------------------|
| `dev` | local Supabase (`127.0.0.1:54321`; emulator: `10.0.2.2`) | debug, everything | nBhumi Dev |
| `staging` | staging Supabase (**pending HYA-284**) | verbose, everything | nBhumi Staging |
| `prod` | `rerjioibpqvcomdingte.supabase.co` | minimal, warnings+errors | nBhumi |

```bash
make app-dev      # flutter run --flavor dev (local backend)
make app-staging  # fails fast until HYA-284 lands
make app-prod     # flutter run --flavor prod
make apk-dev      # debug APK, no secrets needed
make apk-prod     # release APK, needs SUPABASE_PUBLISHABLE_KEY in env
```

Keys come from the shell, never from git (Rule 7); `EnvConfig` defaults are a
local-dev fallback only. The admin panel is web-only, so it takes
`ENVIRONMENT` via `--dart-define` instead of flavors (see CI `build-web`).
Sentry wiring is HYA-244; flavors already carry the DSN field through.

## Launcher icons

Source of truth is the split SVG in `apps/user_app/assets/icon/` (`ic_bg.svg`
full-bleed gradient, `ic_fg.svg` glyph on transparency). Regenerate everything
from them with:

```bash
cd apps/user_app
# 1. render PNGs from SVG (needs node + sharp, one-off local step)
# 2. generate native sets:
dart run flutter_launcher_icons
```

This rewrites Android mipmaps + adaptive-icon XML and the iOS `AppIcon`
set. Store listings live in `apps/user_app/assets/store/` (`play_512.png`,
`appstore_1024.png` — full-bleed, no rounding, no alpha).

## Splash screen

`flutter_native_splash` (config in `apps/user_app/pubspec.yaml`) paints the
brand-blue `#002C6D` window with the white/green glyph centered, on Android
(incl. Android 12+ splash API + night variants) and iOS storyboard. Regenerate
with `dart run flutter_native_splash:create` from `apps/user_app`.

## Documentation

See Linear project P-HYA-10 for full documentation:
- AGENTS.md — Rules for OpenCode agent
- DESIGN.md — Design system
- DATA.md — User data, KYC & golden rules
- TOOLING.md — Pub workspaces vs Melos
- SCHEMA.md — Database schema & ERD
- API.md — Supabase RPC endpoint specs
- TESTING.md — Testing strategy
- SECURITY.md — Threat model & security checklist
- DEPLOYMENT.md — CI/CD pipeline & environments
- MONETIZATION.md — Revenue model
- WIREFRAMES.md — 5 key screen designs
- PROGRESS.md — Progress tracking

## Commands

| Command | Description |
|---------|-------------|
| `make gen` | Run code generation |
| `make analyze` | Run static analysis |
| `make test` | Run all tests |
| `make app` | Run mobile app (dev flavor) |
| `make app-dev` | Run mobile app (dev flavor, local Supabase) |
| `make app-staging` | Run mobile app (staging flavor; needs HYA-284) |
| `make app-prod` | Run mobile app (prod flavor) |
| `make apk-dev` | Debug APK, dev flavor (no secrets) |
| `make apk-prod` | Release APK, prod flavor |
| `make admin` | Run admin panel |
| `make ci` | CI pipeline (analyze + test) |
| `make clean` | Clean build artifacts |
