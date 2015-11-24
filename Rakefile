require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'rubocop'
require 'fileutils'
require 'rainbow'
require 'inch/rake'

namespace :spec do
  desc 'Run all spec tests at once.'
  RSpec::Core::RakeTask.new(:all)

  desc 'Run unit spec tests.'
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern = [
      'spec/unit'
    ]
  end

  desc 'Run integration spec tests.'
  RSpec::Core::RakeTask.new(:integration) do |t|
    t.pattern = [
      'spec/integration'
    ]
  end
end

Inch::Rake::Suggest.new :inch, '--pedantic'

RuboCop::RakeTask.new(:rubocop) do |task|
  # don't abort rake on failure
  task.fail_on_error = true
end

namespace :rubocop do
  namespace :todo do
    desc 'Cleans a rubocop TODO list'
    task :clean do
      File.write('.rubocop_todo.yml', '')
      Rake::Task[:rubocop].execute
    end

    desc 'Saves actual rubocop state into TODO list'
    task :save do
      rcli = RuboCop::CLI.new
      rcli.run ['--auto-gen-config']
    end
  end
end

tests = [
  :'spec:all',
  :rubocop,
  :inch
]

desc 'Run lint, and all spec tests.'
task test: tests

desc 'test package'
task build: [:test]

task default: :test
