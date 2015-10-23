source ENV['GEM_SOURCE'] || 'https://rubygems.org'

gemspec

group :test do
  gem 'rake',           '~> 10.4.0', require: false
  gem 'rspec',          '~> 3.2.0',  require: false
  gem 'simplecov-lcov', '~> 0.4.0',  require: false
  gem 'simplecov',      '~> 0.9.0',  require: false
  gem 'rubocop',        '~> 0.30.0', require: false
  gem 'inch',           '~> 0.5.0',  require: false
end

group :development do
  gem 'guard',         '~> 2.12.0', require: false
  gem 'guard-bundler', '~> 2.1.0',  require: false
  gem 'guard-rake',    '~> 1.0.0',  require: false
  gem 'guard-rubocop', '~> 1.2.0',  require: false
  gem 'pry-byebug',    '~> 3.1.0',  require: false if RUBY_VERSION > '2.0.0'
end

local_gemfile = File.join(File.dirname(__FILE__), 'Gemfile.local')
eval_gemfile local_gemfile if File.exist?(local_gemfile)

begin
  npmbin = `npm bin`.strip
  ENV['PATH'] = "#{npmbin}:#{ENV['PATH']}"
rescue # rubocop:disable Lint/HandleExceptions
  # nothing
end
# vim:ft=ruby
