require 'spec_helper'
require 'revamp/persister/rpm'
require 'rbconfig'

describe Revamp::Persister::Rpm::CommandLine do
  describe '#execute' do
    before :each do
      @level = Revamp.logger.level
      Revamp.logger.level = 100
    end
    after :each do
      Revamp.logger.level = @level
    end
    let(:is_windows) { RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/ }
    let(:command) do
      is_windows ? 'dir > nul' : 'true'
    end
    let(:directory) { Dir.tmpdir }
    let(:options) do
      {
        release:   "1",
        epoch:     "6",
        outdir:    "/tmp",
        filenames: ["spec/fixtures/coi-sample-0.1.1.tar.gz"],
        verbose:   false,
        cleanup:   true
      }
    end
    subject { described_class.execute(command, directory, options) }
    it { expect(subject).to be_success }
  end
end