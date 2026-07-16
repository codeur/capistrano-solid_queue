# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create do |t|
  # Capistrano 3.20 emits circular require warnings under Ruby 3.4 with -w.
  # Keep test output clean until upstream fixes the warning path.
  t.warning = false
end

require "standard/rake"

task default: %i[test standard]
