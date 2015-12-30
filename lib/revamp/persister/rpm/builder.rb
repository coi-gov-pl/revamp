require 'revamp'
require 'revamp/persister/rpm/commandline'

# A internal methods for builder
module Revamp::Persister::Rpm::BuilderInternals
  def configure_rpm_requirements_line
    req = []
    model.dependencies.each { |dep| req += Revamp::Filter::PuppetVerToRpmReq.new.filter(dep) }
    req.join(', ')
  end

  def erbize(template, vars)
    values = OpenStruct.new(vars).instance_eval { binding }
    ERB.new(template).result(values)
  end

  def cleanup_files(files)
    @log.debug("Files to be cleaned up: #{files}")
    readable = files.reject { |path| !path.readable? }
    readable.each do |path|
      path.directory? ? FileUtils.rm_r(path) : path.unlink
    end
  end
end

# A builder for RPM's packages
class Revamp::Persister::Rpm::Builder
  SOURCES = 'SOURCES'
  SPECS   = 'SPECS'
  RPMS    = 'RPMS'
  SELFDIR = Pathname.new(__FILE__).dirname
  ATTRS   = [
    :name, :version, :filename, :rpm, :model, :tmpdir, :release, :filenames,
    :specfile, :has_requirements, :requirements, :options
  ]
  ATTRS.each { |attr| attr_accessor(attr) }
  attr_reader :produced
  alias_method :produced?, :produced

  def initialize(model, dir, options)
    @options  = options
    @name     = "puppetmodule_#{model.slugname}"
    @release  = options[:release]
    assign_model(model)
    @filename = "#{name}-#{version}-#{release}.noarch.rpm"
    @rpm      = "#{name}-#{version}"
    @specfile = rpm + '.spec'
    @tmpdir   = dir
    @produced = false
    @log      = Revamp.logger
    @requirements = configure_rpm_requirements_line
    @log.debug("Target file: #{target}")
  end

  def produce
    if needs_to_write?
      @log.info("Converting to RPM package #{target}...")
      cmd = "rpmbuild -ba #{SPECS}/#{specfile}"
      verbose = options[:verbose]
      ret = Revamp::Persister::Rpm::CommandLine.execute(cmd, tmpdir, verbose)
      fail "RPM Build failed with retcode = #{ret.exitstatus}" unless ret.success?
    end
    move_produced
  end

  def make_structure
    return unless needs_to_write?
    FileUtils.mkdir_p(tmpdir.join(SOURCES))
    FileUtils.mkdir_p(tmpdir.join(SPECS))
  end

  def write_spec
    File.open(specfile_path, 'w') { |file| file.write(generate_spec) } if needs_to_write?
  end

  def write_sources
    return unless needs_to_write?
    pathsufix = Pathname.new(rpm)
    File.open(sources_tgz_path, 'wb') do |tgz|
      Zlib::GzipWriter.wrap(tgz) do |gz|
        Gem::Package::TarWriter.new(gz) do |tar|
          model.files.each do |file, content|
            full = pathsufix.join(file).to_s
            tar.add_file_simple(full, 0644, content.length) { |io| io.write(content) }
          end
        end
      end
    end
  end

  def cleanup
    arch = RbConfig::CONFIG['arch'].gsub('-linux', '')
    cleanup_files [
      sources_tgz_path, specfile_path, tmpdir.join('BUILD').join(rpm),
      tmpdir.join('BUILDROOT').join("#{rpm}-#{release}.#{arch}")
    ]
  end

  protected

  def generate_spec
    tpl = SELFDIR.join('rpm-spec.erb')
    values = Hash[ATTRS.map { |key| [key, send(key)] }]
    erbize(tpl.read, values)
  end

  private

  def assign_model(model)
    @model            = model
    @filenames        = model.files.keys
    @version          = model.version
    @has_requirements = model.dependencies.any?
  end

  def sources_tgz_path
    tmpdir.join(SOURCES).join("#{rpm}.tar.gz")
  end

  def specfile_path
    tmpdir.join(SPECS).join(specfile)
  end

  def target
    Pathname.new(options[:outdir]).join(filename)
  end

  def move_produced
    produced = tmpdir.join(RPMS).join('noarch').join(filename)
    @log.debug("Produced RPM in build dir: #{produced}")
    if needs_to_write?
      FileUtils.mv(produced, target)
      @produced = true
    end
    target
  end

  def needs_to_write?
    !File.exist?(target) || options[:clobber]
  end

  include Revamp::Persister::Rpm::BuilderInternals
end
