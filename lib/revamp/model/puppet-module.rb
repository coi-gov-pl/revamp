require 'revamp'
require 'revamp/mapper/puppet-name-slugger'

# This class describes a puppet dependency
class Revamp::Model::PuppetDependency
  attr_accessor :name, :version

  def initialize(hash)
    @name = hash['name']
    versions = normalize(hash['version_requirement'])
    @version = Gem::Requirement.new(versions)
  end

  private

  def normalize(versionreq)
    re = /^(([><=~]+)?\s*([\dx]+(?:\.[\dx]+(?:\.[\dx]+)?)?))(.*)/
    m = re.match(versionreq.strip)
    first = m[1].strip
    second = m[4].strip
    reqs = [first]
    reqs << second unless second.empty?
    reqs
  end
end

# This class describes a puppet module
class Revamp::Model::PuppetModule
  def self.puppet_accessor(*vars)
    @attributes ||= []
    @attributes.concat vars
    attr_accessor(*vars)
  end

  class << self
    attr_reader :attributes
  end

  attr_accessor :files
  attr_accessor :metadata
  attr_accessor :name

  puppet_accessor :dependencies
  puppet_accessor :source
  puppet_accessor :author
  puppet_accessor :version
  puppet_accessor :license
  puppet_accessor :summary
  puppet_accessor :project_page

  def initialize
    @files = {}
    @metadata = nil
    @dependencies = []
  end

  def add_file(path, content)
    @files[path] = content
  end

  def attributes
    self.class.attributes
  end

  def dependencies=(deps)
    @dependencies = []
    deps.each do |dep|
      @dependencies << Revamp::Model::PuppetDependency.new(dep)
    end
  end

  def slugname
    Revamp::Mapper::PuppetNameSlugger.new.map(name)
  end

  def rawname
    name.split('/')[-1]
  end
end
