require 'revamp'

# A module with models for application
module Revamp::Model
  # This class describes a puppet dependency
  class PuppetDependency
    attr_accessor :name, :version

    def initialize(hash)
      @name = hash['name']
      @version = Gem::Requirement.new(hash['version_requirement'].split(/\s+/))
    end
  end

  # This class describes a puppet module
  class PuppetModule
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
        @dependencies << PuppetDependency.new(dep)
      end
    end

    def slugname
      name.tr('/', '-')
    end
  end
end
