#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

repo_root = Pathname(__dir__).join("..", "..").expand_path
project_path = repo_root.join("ios", "Runner.xcodeproj", "project.pbxproj")
project = project_path.read

expected_profile = 'PROVISIONING_PROFILE_SPECIFIER = "match AppStore com.nyhasinavalona.rhythm";'
expected_identity = 'CODE_SIGN_IDENTITY = "Apple Distribution";'
expected_style = 'CODE_SIGN_STYLE = Manual;'
expected_team = 'DEVELOPMENT_TEAM = 6B673XM2ST;'
expected_bundle = 'PRODUCT_BUNDLE_IDENTIFIER = com.nyhasinavalona.rhythm;'

blocks = project.scan(/\b\w+ \/\* (Release|Profile) \*\/ = \{.*?\n\t\t\tname = \1;\n\t\t\};/m)
full_blocks = project.scan(/\b\w+ \/\* (?:Release|Profile) \*\/ = \{.*?\n\t\t\tname = (?:Release|Profile);\n\t\t\};/m)

runner_blocks = full_blocks.select do |block|
  block.include?(expected_bundle)
end

failures = []

if runner_blocks.size != 2
  failures << "expected 2 Runner signing blocks (Release and Profile), found #{runner_blocks.size}"
end

runner_blocks.each do |block|
  header = block[/\/\* (Release|Profile) \*\//, 1] || "unknown"
  failures << "#{header} is not manual signing" unless block.include?(expected_style)
  failures << "#{header} does not use Apple Distribution identity" unless block.include?(expected_identity)
  failures << "#{header} does not use the match App Store profile" unless block.include?(expected_profile)
  failures << "#{header} does not set the expected team" unless block.include?(expected_team)
end

if failures.empty?
  puts "PASS: Runner Release/Profile signing is configured for Match App Store distribution"
  exit 0
end

warn "FAIL: Runner signing config is not ready for Match App Store archive"
failures.each do |failure|
  warn "- #{failure}"
end
exit 1
