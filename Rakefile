# frozen_string_literal: true

require "bundler"
Bundler.setup
Bundler::GemHelper.install_tasks

require "rake"
require "rspec/core/rake_task"

require "cucumber/rake/task"
Cucumber::Rake::Task.new(:cucumber)

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.ruby_opts = %w[-w]
end

task default: %i[spec cucumber]
