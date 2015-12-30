require 'revamp'
require 'revamp/persister/rpm'
require 'revamp/parser/puppet-tarball'

# A main application class
class Revamp::Application
  def initialize(options)
    @options   = options
    @filenames = options[:filenames]
    @format    = :rpm
    @log       = Revamp.logger
  end

  def run!
    converted = []
    @filenames.each do |file|
      @log.info("Processing file: #{file} ...")
      parser = Revamp::Parser::PuppetTarball.new(file)
      model = parser.parse
      persister = build_persister
      target = persister.persist(model)
      report(converted, persister, target)
    end
    @log.info("#{converted.size} files converted.")
  end

  protected

  def report(converted, persister, target)
    if persister.respond_to? :persisted?
      if persister.persisted?
        converted << target
      else
        @log.info("File #{target} is already converted and clobber is false, skipped.")
      end
    else
      converted << target
    end
    converted
  end

  def build_persister
    persister = case @format
                when :rpm then Revamp::Persister::Rpm.new
                else fail ArgumentError, "Unknown format: #{@format}"
                end
    persister.options = @options
    persister
  end
end
