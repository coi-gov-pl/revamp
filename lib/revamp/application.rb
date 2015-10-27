require 'revamp'
require 'revamp/filter/rpm'
require 'revamp/parser/puppet-tarball'

# A main application class
class Revamp::Application
  def initialize(options)
    @outdir    = options[:outdir]
    @filenames = options[:filenames]
    @release   = options[:release]
    @epoch     = options[:epoch]
    @format    = :rpm
  end

  def run!
    @filenames.each do |file|
      parser = Revamp::Parser::PuppetTarball.new(file)
      model = parser.parse
      filter = build_filter
      filter.filter(model)
    end
    Revamp.logger.info("Files successfully converted: #{@filenames.size}.")
  end

  protected

  def build_filter
    filter = case @format
             when :rpm then Revamp::Filter::Rpm.new
             else fail ArgumentError, "Unknown format: #{@format}"
             end
    filter.outdir  = @outdir
    filter.release = @release
    filter.epoch   = @epoch
    filter
  end
end
