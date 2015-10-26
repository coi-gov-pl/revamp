require 'micro-optparse'
require 'revamp'

# A command line interface class
class Revamp::CLI
  # Executes an Revamp from CLI
  #
  # @param argv [Array] an argv from CLI
  # @return [Integer] a status code for program
  def run!(argv = ARGV)
    options = parse_or_kill(argv, -1)
    run_or_kill(options, 1)
    Kernel.exit(0)
  end

  protected

  # Parse an ARGV command line arguments
  # @param argv [Array] an argv from CLI
  # @return [Hash] options to use by application
  def parse(argv)
    options = parser.process!(argv)
    validate_options(options)
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

  def parse_or_kill(argv, retcode)
    parse(argv)
  rescue ArgumentError => ex
    Revamp.logger.fatal(ex)
    Kernel.exit(retcode)
  end

  def run_or_kill(options, retcode)
    require 'revamp/application'
    Revamp::Application.new(options).run!
  rescue StandardError => ex
    bug = Revamp.bug(ex)
    Revamp.logger.fatal("Unexpected error occured, mayby a bug?\n\n#{bug[:message]}\n\n#{bug[:help]}")
    Kernel.exit(retcode)
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
      p.option :release, 'A package release number, by default it is equal to \'0\'', default: '0'
      p.option(
        :outdir,
        'A directory to output converted packages, by default this is current directory: ' + Dir.pwd,
        default: Dir.pwd
      )
      p.option :filenames, 'Files which will be processed', default: []
    end
  end
end
