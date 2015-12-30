# A command line executor for command line
class Revamp::Persister::Rpm::CommandLine
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
