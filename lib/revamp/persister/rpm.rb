require 'revamp'
require 'pathname'
require 'tmpdir'
require 'erb'
require 'ostruct'
require 'rbconfig'
require 'revamp/filter/puppetver2rpmreq'

# A main RPM persister
class Revamp::Persister::Rpm
  def initialize
    @options = nil
  end

  attr_accessor :options

  def persist(model)
    dir = File.expand_path('~')
    workdir = Pathname.new(dir).join('rpmbuild')
    builder = Builder.new(model, workdir, options)
    builder.make_structure
    builder.write_spec
    builder.write_sources
    produced = builder.produce
    builder.cleanup if options[:cleanup]
    produced
  end

  # A command line executor for command line
  class CommandLine
    class << self
      def execute(command, directory, verbose)
        Revamp.logger.debug("Executing: '#{command}' in directory: '#{directory}'")
        out = '/dev/null'
        out = $stdout if verbose
        pid = Process.spawn(command, chdir: directory, out: out, err: out)
        Process.wait pid
        $? # rubocop:disable SpecialGlobalVars
      end
    end
  end

  # A builder for RPM's packages
  class Builder
    SOURCES = 'SOURCES'
    SPECS   = 'SPECS'
    RPMS    = 'RPMS'
    SELFDIR = Pathname.new(__FILE__).dirname
    ATTRS   = [
      :name, :version, :filename, :rpm,
      :model, :tmpdir, :release, :filenames,
      :specfile, :has_requirements,
      :requirements, :options
    ]
    ATTRS.each { |attr| attr_accessor(attr) }

    def initialize(model, dir, options)
      @options   = options
      @name      = "puppetmodule_#{model.slugname}"
      @release   = options[:release]
      @version   = model.version
      @filename  = "#{name}-#{version}-#{release}.noarch.rpm"
      @rpm       = "#{name}-#{version}"
      @specfile  = rpm + '.spec'
      @model     = model
      @tmpdir    = dir
      @filenames = model.files.keys
      @has_requirements = model.dependencies.any?
      @requirements     = configure_rpm_requirements_line
    end

    def configure_rpm_requirements_line
      req = []
      model.dependencies.each do |dep|
        req += Revamp::Filter::PuppetVerToRpmReq.new.filter(dep)
      end
      req.join(', ')
    end

    def make_structure
      FileUtils.mkdir_p(tmpdir.join(SOURCES))
      FileUtils.mkdir_p(tmpdir.join(SPECS))
    end

    def erbize(template, vars)
      values = OpenStruct.new(vars).instance_eval { binding }
      ERB.new(template).result(values)
    end

    def generate_spec
      tpl = SELFDIR.join('rpm-spec.erb')
      values = Hash[ATTRS.map { |key| [key, send(key)] }]
      erbize(tpl.read, values)
    end

    def write_spec
      File.open(specfile_path, 'w') { |file| file.write(generate_spec) }
    end

    def write_sources
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

    def sources_tgz_path
      sources = tmpdir.join(SOURCES)
      sources.join("#{rpm}.tar.gz")
    end

    def specfile_path
      tmpdir.join(SPECS).join(specfile)
    end

    def target
      outdir = options[:outdir]
      Pathname.new(outdir).join(filename)
    end

    def produce
      Revamp.logger.info("Converting to RPM package #{target}...")
      cmd = "rpmbuild -ba #{SPECS}/#{specfile}"
      verbose = options[:verbose]
      ret = Revamp::Persister::Rpm::CommandLine.execute(cmd, tmpdir, verbose)
      fail "RPM Build failed with retcode = #{ret.exitstatus}" unless ret.success?
      move_produced
      target
    end

    def move_produced
      produced = tmpdir.join(RPMS).join('noarch').join(filename)
      Revamp.logger.debug("Produced RPM in build dir: #{produced}")
      FileUtils.mv(produced, target)
    end

    def cleanup
      arch = RbConfig::CONFIG['arch'].gsub('-linux', '')
      cleanup_files [
        sources_tgz_path, specfile_path, tmpdir.join('BUILD').join(rpm),
        tmpdir.join('BUILDROOT').join("#{rpm}-#{release}.#{arch}")
      ]
    end

    def cleanup_files(files)
      Revamp.logger.debug("Files to be cleaned up: #{files}")
      readable = files.reject { |path| !path.readable? }
      readable.each do |path|
        path.directory? ? FileUtils.rm_r(path) : path.unlink
      end
    end
  end
end
