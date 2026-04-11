.PHONY: setup setup-fastlane analyze test ci build-ios build-macos deploy-testflight deploy-supabase sync-signing help

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## Install Flutter deps, iOS pods, and Fastlane
	flutter pub get
	cd ios && pod install
	bundle install

setup-fastlane: ## Interactive setup — generates Appfile and Matchfile
	@mkdir -p fastlane
	@read -p "Apple ID (email): " apple_id; \
	read -p "Team ID: " team_id; \
	read -p "Bundle ID [com.nyhasinavalona.rhythm]: " bundle_id; \
	bundle_id=$${bundle_id:-com.nyhasinavalona.rhythm}; \
	read -p "Match git URL (SSH, e.g. git@github.com:you/certs.git): " match_git_url; \
	echo "app_identifier(\"$$bundle_id\")" > fastlane/Appfile; \
	echo "apple_id(\"$$apple_id\")" >> fastlane/Appfile; \
	echo "team_id(\"$$team_id\")" >> fastlane/Appfile; \
	echo "" >> fastlane/Appfile; \
	echo "git_url(\"$$match_git_url\")" > fastlane/Matchfile; \
	echo "type(\"appstore\")" >> fastlane/Matchfile; \
	echo "app_identifier(\"$$bundle_id\")" >> fastlane/Matchfile; \
	echo "" >> fastlane/Matchfile; \
	echo ""; \
	echo "Generated fastlane/Appfile and fastlane/Matchfile."

analyze: ## Run Flutter static analysis
	flutter analyze

test: ## Run Flutter tests
	flutter test

ci: analyze test ## Run analyze + test

build-ios: ## Build iOS IPA via Fastlane
	bundle exec fastlane ios build_ios

build-macos: ## Build macOS app via Fastlane
	bundle exec fastlane mac build_macos

deploy-testflight: ## Build and upload iOS to TestFlight
	bundle exec fastlane ios testflight_upload

deploy-supabase: ## Deploy Supabase migrations and edge functions
	supabase db push
	supabase functions deploy

sync-signing: ## Sync signing certificates via Match
	bundle exec fastlane ios sync_signing
