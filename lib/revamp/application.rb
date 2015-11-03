require 'revamp'
require 'revamp/persister/rpm'
require 'revamp/parser/puppet-tarball'

# A main application class
class Revamp::Application
  def initialize(options)
    @options   = options
    @filenames = options[:filenames]
    @format    = :rpm
  end

  def run!
    @filenames.each do |file|
      parser = Revamp::Parser::PuppetTarball.new(file)
      model = parser.parse
      persister = build_persister
      persister.persist(model)
    end
    Revamp.logger.info("Files successfully converted: #{@filenames.size}.")
  end

  protected

  def build_persister
    persister = case @format
                when :rpm then Revamp::Persister::Rpm.new
                else fail ArgumentError, "Unknown format: #{@format}"
                end
    persister.options = @options
    persister
  end
end
