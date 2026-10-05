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

app: ## Run mobile app
	flutter run apps/user_app

admin: ## Run admin panel
	flutter run apps/admin_panel -d chrome

ci: analyze test ## CI pipeline

clean: ## Clean build artifacts
	flutter clean
	dart run build_runner clean
