#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

repo_root = Pathname(__dir__).join("..", "..").expand_path
workflow_paths = [
  repo_root.join(".github", "workflows", "deploy-testflight.yml"),
  repo_root.join(".github", "workflows", "deploy-macos-testflight.yml")
]

failures = []

workflow_paths.each do |workflow_path|
  workflow = workflow_path.read
  relative_path = workflow_path.relative_path_from(repo_root)

  unless workflow.include?("workflow_dispatch:")
    failures << "#{relative_path} does not allow manual workflow_dispatch runs"
  end

  unless workflow.include?("workflow_run:")
    failures << "#{relative_path} does not trigger from workflow_run"
  end

  unless workflow.include?("workflows: [CI]") || workflow.include?("workflows:\n      - CI") || workflow.include?("workflows:\n    - CI")
    failures << "#{relative_path} is not wired to the CI workflow"
  end

  if workflow.match?(/^\s*push:\s*$/)
    failures << "#{relative_path} still auto-triggers directly on push"
  end

  unless workflow.include?("github.event_name == 'workflow_dispatch'")
    failures << "#{relative_path} does not explicitly allow manual dispatch in its job guard"
  end

  unless workflow.include?("github.event.workflow_run.conclusion == 'success'")
    failures << "#{relative_path} does not require a successful workflow_run conclusion"
  end

  unless workflow.include?("github.event.workflow_run.head_branch == 'main'")
    failures << "#{relative_path} does not restrict automatic deploys to CI runs from main"
  end

  unless workflow.include?("github.event.workflow_run.head_sha")
    failures << "#{relative_path} does not check out the exact CI-passed workflow_run head_sha"
  end
end

if failures.empty?
  puts "PASS: deploy workflows are gated on successful CI while preserving manual dispatch"
  exit 0
end

warn "FAIL: deploy workflow trigger gating regression detected"
failures.each do |failure|
  warn "- #{failure}"
end
exit 1
