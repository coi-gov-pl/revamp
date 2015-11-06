require 'revamp'
require 'zlib'
require 'json'
require 'rubygems/package'
require 'revamp/model/puppet-module'

# This class is a parser for Puppet's tarballs format
class Revamp::Parser::PuppetTarball
  def initialize(tarball_file)
    @tarball = tarball_file
  end

  def parse
    model = nil
    File.open(@tarball, 'rb') do |file|
      Zlib::GzipReader.wrap(file) do |gz|
        Gem::Package::TarReader.new(gz) do |tar|
          model = Revamp::Model::PuppetModule.new
          tar.each do |tarfile|
            entry = Entry.new(tarfile)
            parse_metadata(model, entry) if entry.metadata?
            model.add_file(entry.name, entry.content) if entry.file?
          end
        end
      end
    end
    normalize(model)
  end

  private

  def normalize(model)
    strip = "#{model.slugname}-#{model.version}/"
    model.files = Hash[model.files.map { |file, content| [file.gsub(strip, ''), content] }]
    model
  end

  def parse_metadata(model, entry)
    data = JSON.parse(entry.content)
    model.metadata = data
    model.name = data['name'].tr('-', '/') if data['name']
    model.attributes.each do |attr|
      value = data[attr.to_s]
      fail ArgumentError, "No #{attr} module metadata provided for #{name}" unless value
      parse_dependencies(attr, value)
      model.send(attr.to_s + '=', value)
    end
  end

  def parse_dependencies(attr, value)
    return unless attr == :dependencies
    value.tap do |dependencies|
      dependencies.each do |dep|
        dep['version_requirement'] ||= dep['versionRequirement'] || '>= 0.0.0'
      end
    end
  end

  # An entry from tarball
  class Entry
    attr_accessor :content
    attr_accessor :name
    def initialize(tarfile)
      @tarfile = tarfile
      @name    = tarfile.full_name
      @content = nil
      @content = tarfile.read unless @tarfile.directory?
    end

    def metadata?
      !@tarfile.directory? && name.end_with?('metadata.json')
    end

    def file?
      !content.nil?
    end
  end
end
