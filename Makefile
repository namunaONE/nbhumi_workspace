.PHONY: gen analyze test app admin ci clean

gen: ## Run code generation
	dart run build_runner build -d

analyze: ## Run static analysis
	dart analyze

# The admin panel's suite is the only guard on the router redirect logic. It was
# missing here while CI ran it, so `make test` passed locally with a regression
# CI would have caught.
test: ## Run all tests
	dart test
	(cd apps/user_app && flutter test)
	(cd apps/admin_panel && flutter test)

app: app-dev ## Run mobile app (dev flavor)

# HYA-239: flavors. The flavor selects the *native* identity (applicationId,
# display name) so dev/staging/prod install side-by-side; ENVIRONMENT selects
# the Dart-side backend and log verbosity and MUST match the flavor, or the
# icon will disagree with the config. Keys come from the shell (Rule 7) and
# are never committed — the EnvConfig defaults are only a local-dev fallback.
# Android emulator reaches local Supabase via 10.0.0.2.2 instead of 127.0.0.1.
SUPABASE_URL_DEV ?= http://127.0.0.1:54321
SUPABASE_URL_PROD ?= https://rerjioibpqvcomdingte.supabase.co

app-dev: ## Run mobile app (dev flavor, local Supabase, debug logging)
	flutter run --flavor dev \
	  --dart-define=ENVIRONMENT=dev \
	  --dart-define=SUPABASE_URL=$(SUPABASE_URL_DEV) \
	  --dart-define=SUPABASE_PUBLISHABLE_KEY=$(SUPABASE_PUBLISHABLE_KEY)

app-staging: ## Run mobile app (staging flavor; needs HYA-284 backend)
	@if [ -z "$(SUPABASE_URL_STAGING)" ]; then echo "Staging backend missing (HYA-284 not done). Set SUPABASE_URL_STAGING and SUPABASE_PUBLISHABLE_KEY_STAGING."; exit 1; fi
	flutter run --flavor staging \
	  --dart-define=ENVIRONMENT=staging \
	  --dart-define=SUPABASE_URL=$(SUPABASE_URL_STAGING) \
	  --dart-define=SUPABASE_PUBLISHABLE_KEY=$(SUPABASE_PUBLISHABLE_KEY_STAGING)

app-prod: ## Run mobile app (prod flavor, minimal logging)
	flutter run --flavor prod \
	  --dart-define=ENVIRONMENT=prod \
	  --dart-define=SUPABASE_URL=$(SUPABASE_URL_PROD) \
	  --dart-define=SUPABASE_PUBLISHABLE_KEY=$(SUPABASE_PUBLISHABLE_KEY)

apk-dev: ## Debug APK, dev flavor (validates flavor wiring, no secrets needed)
	flutter build apk --flavor dev --debug \
	  --dart-define=ENVIRONMENT=dev

apk-prod: ## Release APK, prod flavor (needs SUPABASE_PUBLISHABLE_KEY)
	flutter build apk --flavor prod --release \
	  --dart-define=ENVIRONMENT=prod \
	  --dart-define=SUPABASE_URL=$(SUPABASE_URL_PROD) \
	  --dart-define=SUPABASE_PUBLISHABLE_KEY=$(SUPABASE_PUBLISHABLE_KEY)

admin: ## Run admin panel
	flutter run apps/admin_panel -d chrome

ci: analyze test ## CI pipeline

clean: ## Clean build artifacts
	flutter clean
	dart run build_runner clean
