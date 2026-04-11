#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

repo_root = Pathname(__dir__).join("..", "..").expand_path
fastfile_path = repo_root.join("fastlane", "Fastfile")
fastfile = fastfile_path.read

build_ios_lane = fastfile[/lane :build_ios do\n(.*?)\n  end/m, 1]

failures = []

if build_ios_lane.nil?
  failures << "Fastfile does not define lane :build_ios"
else
  unless build_ios_lane.include?("setup_ci")
    failures << "build_ios lane does not call setup_ci"
  end

  setup_ci_index = build_ios_lane.index("setup_ci")
  sync_signing_index = build_ios_lane.index("sync_signing")

  if setup_ci_index && sync_signing_index && setup_ci_index > sync_signing_index
    failures << "build_ios lane calls setup_ci after sync_signing instead of before it"
  end
end

if failures.empty?
  puts "PASS: build_ios prepares Fastlane CI keychain setup before signing"
  exit 0
end

warn "FAIL: Fastlane CI keychain setup regression detected"
failures.each do |failure|
  warn "- #{failure}"
end
exit 1
