require 'rspec/its'

begin
gem 'simplecov'
  require 'simplecov'
  formatters = []
  formatters << SimpleCov::Formatter::HTMLFormatter

  begin
    gem 'coveralls'
    require 'coveralls'
    formatters << Coveralls::SimpleCov::Formatter if ENV['TRAVIS']
  rescue Gem::LoadError
    # do nothing
  end

  begin
    gem 'codeclimate-test-reporter'
    require 'codeclimate-test-reporter'
    formatters << CodeClimate::TestReporter::Formatter if (ENV['TRAVIS'] and ENV['CODECLIMATE_REPO_TOKEN'])
  rescue Gem::LoadError
    # do nothing
  end
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[*formatters]
  SimpleCov.start do
    add_filter "/spec/"
    add_filter "/.vendor/"
    add_filter "/vendor/"
    add_filter "/gems/"
    minimum_coverage 95
    refuse_coverage_drop
  end
rescue Gem::LoadError
  # do nothing
end

begin
  gem 'pry'
  require 'pry'
rescue Gem::LoadError
  # do nothing
end

RSpec.configure do |c|
  c.tty = true unless ENV['JENKINS_URL'].nil?
  c.mock_with :rspec do |mock|
    mock.syntax = [:expect]
  end
end

require 'revamp'
