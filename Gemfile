source ENV['GEM_SOURCE'] || 'https://rubygems.org'

gemspec

group :test do
  gem 'rake',                      '~> 10.4.0', require: false
  gem 'rspec',                     '~> 3.3.0',  require: false
  gem 'rspec-its',                 '~> 1.2.0',  require: false
  gem 'simplecov',                 '~> 0.10.0', require: false
  gem 'rubocop',                   '~> 0.34.0', require: false
  gem 'inch',                      '~> 0.7.0',  require: false
  gem 'coveralls',                 '~> 0.8.9',  require: false
  gem 'codeclimate-test-reporter', '~> 0.4.8',  require: false
  gem 'tins',                      '~> 1.6.0',  require: false if RUBY_VERSION < '2.0.0'
end

group :development do
  gem 'guard',         '~> 2.13.0', require: false
  gem 'guard-bundler', '~> 2.1.0',  require: false
  gem 'guard-rake',    '~> 1.0.0',  require: false
  gem 'guard-rubocop', '~> 1.2.0',  require: false
  gem 'pry-byebug',    '~> 3.2.0',  require: false if RUBY_VERSION > '2.0.0'
end

local_gemfile = File.join(File.dirname(__FILE__), 'Gemfile.local')
eval_gemfile local_gemfile if File.exist?(local_gemfile)

# vim:ft=ruby
