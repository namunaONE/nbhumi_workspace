# AGENTS.md — nBhumi Agent Rules

> Rules for AI coding agents (OpenCode, etc.) working on the nBhumi monorepo.
> 41 rules covering security, monorepo hygiene, code standards, Nepal-specific
> logic, Dart 3.13+/Riverpod 3.0/Flutter 3.47 patterns, testing, error handling,
> and dependency management.

---

## Security (Rules 1–8)

1. **Never edit applied Supabase migrations.** Once a migration is applied to any
   environment, it is immutable. Create a new migration for every schema change.
2. **No service keys in app code.** Only the anon/publishable key goes in client
   apps. `service_role` keys never leave the server/Edge Functions.
3. **RLS in the same migration as the table.** Every `CREATE TABLE` statement must
   be accompanied by `ALTER TABLE ... ENABLE ROW LEVEL SECURITY` and its policies
   in the same migration file.
4. **Status changes via RPC only.** Listing/KYC status transitions
   (`draft → pending_review → live/rejected`) must go through
   `v1_*` RPC functions — never direct `UPDATE` on status columns from the client.
5. **KYC documents are private.** Upload to the private `kyc-documents` bucket.
   Serve via short-lived signed URLs (max 1 hour). Never make the bucket public.
6. **Validate all user input client-side AND server-side.** Use
   `package:core/src/utils/validators.dart` on the client; enforce again in RPC.
7. **No secrets in git.** `.env` files are gitignored. Use `--dart-define` for
   local runs and CI secrets for pipelines. Rotate keys immediately if committed.
8. **Audit-log admin actions.** Every admin approve/reject/suspend must insert a
   row into `audit_log` via the RPC — never silently mutate.

## Monorepo (Rules 9–14)

9. **Native pub workspaces only — no Melos.** Root `pubspec.yaml` declares
   `workspace: [apps/*, packages/*, features/*]`. Every child has
   `resolution: workspace`. One `dart pub get` at the root.
10. **Dependency direction is one-way.** `apps → features → packages`. Features
    never import other features. Packages never import features or apps.
11. **Path dependencies for internal packages.** Use relative `path:` refs
    (e.g. `models: {path: ../../packages/models}`), never published versions.
12. **Run codegen after model/provider changes.**
    `dart run build_runner build` inside the affected package
    (`packages/models`, `packages/data`, `features/auth`, …).
13. **Commits reference Linear IDs.** Format: `HYA-123: short description`.
    One Linear issue per commit where practical.
14. **Generated files are committed** (`.g.dart`, `.freezed.dart`) so CI does not
    need to run codegen — but never hand-edit them.

## Code Standards (Rules 15–24)

15. **Dart 3.13+ / Flutter 3.47.** Use modern language features: sealed classes,
    pattern matching, records where they simplify code.
16. **Riverpod 3.0 with code generation.** Use `@riverpod` annotations and
    `riverpod_generator`. State via `AsyncNotifier`; side-effects via mutations.
17. **Freezed 4 sealed classes for all models.** Pattern:
    `@freezed sealed class X with _$X { const factory X({...}) = _X; }`.
18. **MVVM + Clean Architecture.** Data flow:
    `View → ViewModel → Repository → Service → Supabase`.
    No business logic in Views or Services; no UI logic in Repositories.
19. **Sealed `AsyncValue` pattern matching in widgets** — use `switch` on
    `AsyncData` / `AsyncError` / `AsyncLoading`, never `.when` with null checks.
20. **`very_good_analysis` v11 lint set** as the baseline. Zero analyzer warnings
    allowed in CI (`--fatal-infos` on changed packages).
21. **No `print()` or `debugPrint()` in committed code.** Use
    `package:core/src/utils/logger.dart` (`AppLogger.debug/info/warning/error`).
22. **Relative imports within a package; package imports across packages.**
    `prefer_relative_imports: false` at root — cross-package imports must be
    `package:name/...`.
23. **Public API docs on all public members** in `packages/*` (models, core,
    data) — these are shared libraries.
24. **Immutability by default.** `const` constructors wherever possible; models
    are immutable via Freezed; widget state lives in Riverpod, not in widgets.

## Nepal-Specific (Rules 25–29)

25. **Area units: store sqm, display local.** Hill region: ropani-aana-paisa-dam.
    Terai region: bigha-kattha-dhur. Use
    `package:core/src/utils/area_converter.dart` — never hand-roll conversion.
26. **Phone numbers: Nepali mobile format.** `98XXXXXXXX` (10 digits, starts 97/98).
    Validate with `Validators.isValidNepaliPhone`.
27. **Currency: NPR with lakh/crore formatting.** Display "NPR 25,00,000" (Indian
    digit grouping), not Western grouping. Prices stored as integer paisa-free
    NPR (`int priceNpr`).
28. **Location: district → city/municipality → ward (1–32).** Ward is optional
    but validated as 1–32 when present. Never free-text district names in the DB.
29. **Dates: store UTC, display local (NPT, UTC+5:45).** Bikram Sambat display
    support is a later milestone — design models to allow it.

## Testing (Rules 30–34)

30. **Test pyramid per TESTING.md.** Unit ≥80% coverage on `packages/*`;
    widget tests on all feature screens; golden tests on the 5 key screens.
31. **Mock Supabase at the Service layer.** Repositories are tested against mock
    services; services are tested against a local Supabase instance only.
32. **Every validator and converter has exhaustive unit tests**, including
    Nepal-specific edge cases (boundary wards, all area unit combos, 97 vs 98
    phone prefixes).
33. **Widget tests pump with `ProviderScope` overrides** — never rely on real
    providers hitting the network in tests.
34. **Tests run with `flutter test` per package** from the workspace root.
    Golden tests update only on `main` branch in CI.

## Error Handling (Rules 35–38)

35. **Use the exception hierarchy** (HYA-237): `AppException` base →
    `ValidationException`, `AuthException`, `NetworkException`,
    `ServerException`. Never throw raw `Exception` or strings.
36. **User-facing errors in Nepali + English.** Every `AppException` carries a
    localized message pair. Snackbars show the localized message with a retry
    action for recoverable errors.
37. **Log all errors with context.** `AppLogger.error` includes user ID, screen,
    action, and the original exception/stack. Errors go to Sentry in prod.
38. **RPC failures are mapped, not leaked.** Repositories catch PostgREST errors
    and map them to `ServerException` with safe messages — never expose raw
    Postgres errors to users.

## Dependencies (Rules 39–41)

39. **Minimize dependencies.** Prefer Dart/Flutter SDK built-ins. Every new
    third-party package requires justification in the PR description.
40. **Pin major versions with caret constraints** (`^x.0.0`) and commit
    `pubspec.lock` for apps. Run `dart pub outdated` weekly.
41. **No abandoned packages.** Check pub.dev score ≥ 90%, recent publish
    (<6 months), and null-safety before adding. Prefer packages already used in
    the workspace (Riverpod, Freezed, go_router, supabase_flutter).

---

*Generated for HYA-195. Linear project: nBhumi — Nepal Property Marketplace.*
