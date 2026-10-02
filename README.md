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
| `make app` | Run mobile app |
| `make admin` | Run admin panel |
| `make ci` | CI pipeline (analyze + test) |
| `make clean` | Clean build artifacts |
