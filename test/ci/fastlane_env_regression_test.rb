#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

repo_root = Pathname(__dir__).join("..", "..").expand_path
workflow_path = repo_root.join(".github", "workflows", "deploy-testflight.yml")
fastfile_path = repo_root.join("fastlane", "Fastfile")

workflow = workflow_path.read
fastfile = fastfile_path.read

failures = []

if workflow.include?("APP_STORE_CONNECT_API_KEY:")
  failures << "workflow still exports reserved env var APP_STORE_CONNECT_API_KEY"
end

unless workflow.include?("APP_STORE_CONNECT_API_KEY_CONTENT:")
  failures << "workflow does not export APP_STORE_CONNECT_API_KEY_CONTENT"
end

if fastfile.include?('key_content: ENV["APP_STORE_CONNECT_API_KEY"]')
  failures << "Fastfile still reads APP_STORE_CONNECT_API_KEY for key_content"
end

unless fastfile.include?('key_content: ENV["APP_STORE_CONNECT_API_KEY_CONTENT"]')
  failures << "Fastfile does not read APP_STORE_CONNECT_API_KEY_CONTENT for key_content"
end

if failures.empty?
  puts "PASS: Fastlane/App Store Connect env naming avoids match api_key collisions"
  exit 0
end

warn "FAIL: Fastlane/App Store Connect env naming regression detected"
failures.each do |failure|
  warn "- #{failure}"
end
exit 1
