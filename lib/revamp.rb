require 'logger'
require 'tempfile'

begin
  require 'pry'
rescue LoadError # rubocop:disable Lint/HandleExceptions
  # Do nothing here
end

# Top level module for Revamp
module Revamp
  @logger = Logger.new($stdout)
  @logger.formatter = proc { |severity, _datetime, _progname, msg| "#{severity}: #{msg}\n" }
  class << self
    # Logger for CLI interface
    # @return [Logger] logger for CLI
    attr_reader :logger

    # Reports a bug in desired format
    #
    # @param ex [Exception] an exception that was thrown
    # @return [Hash] a hash with info about bug to be displayed to user
    def bug(ex)
      file = Tempfile.new(['revamp-bug', '.log'])
      filepath = file.path
      file.close
      file.unlink
      message = "v#{Revamp::VERSION}-#{ex.class}: #{ex.message}"
      contents = message + "\n\n" + ex.backtrace.join("\n") + "\n"
      File.write(filepath, contents)
      bugo = {
        message: message,
        homepage: Revamp::HOMEPAGE,
        bugfile: filepath,
        help: "Please report this bug to #{Revamp::HOMEPAGE} by passing contents of bug file: #{filepath}"
      }
      bugo
    end
  end
  # A module for modeles
  module Model
  end

  # A module for mapper
  module Mapper
  end

  # A module for persister
  module Persister
  end

  # Parser module
  module Parser
  end

  # A module for filters of persiters
  module Filter
  end
end

require 'revamp/version'
require 'revamp/model/puppet-module'
require 'revamp/mapper/puppet-name-slugger'
require 'revamp/persister/rpm'
require 'revamp/filter/puppetver2rpmreq'
require 'revamp/parser/puppet-tarball'
