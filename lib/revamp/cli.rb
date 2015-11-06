require 'micro-optparse'
require 'revamp'

# A command line interface class
class Revamp::CLI
  # Executes an Revamp from CLI
  #
  # @param argv [Array] an argv from CLI
  # @return [Integer] a status code for program
  def run!(argv = ARGV)
    exec = parse_execution(argv)
    return -1 unless exec.success?
    exec = run_execution(exec.value)
    return 1 unless exec.success?
    0
  end

  protected

  # Parse an ARGV command line arguments
  # @param argv [Array] an argv from CLI
  # @return [Hash] options to use by application
  def parse(argv)
    options = parser.process!(argv)
    validate_options(options)
    Revamp.logger.level = Logger::INFO unless options[:verbose]
    options
  end

  private

  def validate_options(options)
    filenames = options[:filenames]
    fail ArgumentError, "You must pass filenames with `-f`. See: `#{$PROGRAM_NAME} --help`" if filenames.empty?
    filenames.each do |file|
      fail ArgumentError, "Can't read file given: #{file}" unless File.readable?(file)
    end

    outdir = options[:outdir]
    fail ArgumentError, "Can't write to output directory: #{@outdir}" unless File.writable?(outdir)
  end

  def parse_execution(argv)
    Execution.new(true, parse(argv))
  rescue ArgumentError => ex
    Revamp.logger.fatal(ex)
    Execution.new(false)
  end

  def run_execution(options)
    require 'revamp/application'
    Execution.new(true, Revamp::Application.new(options).run!)
  rescue StandardError => ex
    bug = Revamp.bug(ex)
    Revamp.logger.fatal("Unexpected error occured, mayby a bug?\n\n#{bug[:message]}\n\n#{bug[:help]}")
    Execution.new(false)
  end

  def banner
    txt = <<-eos
#{Revamp::NAME} v#{Revamp::VERSION} - #{Revamp::SUMMARY}

#{Revamp::DESCRIPTION}
Usage: #{$PROGRAM_NAME} [options]
    eos
    txt
  end

  def parser
    Parser.new do |p|
      p.banner = banner
      p.version = Revamp::VERSION
      p.option :release, 'A RPM release number, by default it is equal to \'1\'', default: '1'
      p.option :epoch, 'A RPM epoch number, by default it is equal to \'6\'', default: '6'
      p.option(
        :outdir,
        'A directory to output converted packages, by default this is current directory: ' + Dir.pwd,
        default: Dir.pwd
      )
      p.option :filenames, 'Files which will be processed', default: []
      p.option :verbose, 'Should print all information, by default: false', default: false
      p.option :cleanup, 'Should temporary files be cleaned up, by default: true', default: true
    end
  end

  # An execution wrapper
  class Execution
    attr_reader :value
    def initialize(success, value = nil)
      @success = success
      @value   = value
    end

    def success?
      @success == true
    end
  end
end
