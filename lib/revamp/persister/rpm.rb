require 'revamp'
require 'pathname'
require 'tmpdir'
require 'erb'
require 'ostruct'
require 'rbconfig'

# A main RPM persister
class Revamp::Persister::Rpm
  def initialize
    @options = nil
  end

  attr_accessor :options

  def persist(model)
    dir = File.expand_path('~')
    workdir = Pathname.new(dir).join('rpmbuild')
    @builder = Builder.new(model, workdir, options)
    @builder.make_structure
    @builder.write_spec
    @builder.write_sources
    target = @builder.produce
    @builder.cleanup if options[:cleanup]
    target
  end

  def persisted?
    @builder.nil? ? false : @builder.produced?
  end
end

require 'revamp/persister/rpm/builder'
