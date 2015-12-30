require 'spec_helper'
require 'revamp/cli'
require 'revamp/application'
require 'stringio'

describe Revamp::CLI do
  let(:instance) { described_class.new }
  describe '.run!' do
    before :each do
      @level = Revamp.logger.level
      Revamp.logger.level = 100
    end
    after :each do
      Revamp.logger.level = @level
    end
    context 'while ARGV is equal to' do
      let (:argv) { self.class.description.split(/\s+/) }
      subject { instance.run!(argv) }
      describe '--invalid-option' do
        it do
          expect { subject }.to raise_error(SystemExit, 'exit') { |error|
            expect(error).not_to be_success
          }
        end
      end
      context 'while catching STDOUT' do
        before :each do
          @stringio = StringIO.new
          $stdout = @stringio
        end
        after :each do
          $stdout = STDOUT
        end
        describe '--help' do
          it do
            begin
              subject
            rescue SystemExit
            end
            expect(@stringio.string).to include('Revamp v', 'Usage:', '-h, --help')
          end
          it do
            expect { subject }.to raise_error(SystemExit, 'exit') { |error|
              expect(error).to be_success
            }
          end
        end
        describe '--version' do
          it do
            begin
              subject
            rescue SystemExit
            end
            expect(@stringio.string).to match(/^\d+\.\d+\.\d+/)
          end
          it do
            expect { subject }.to raise_error(SystemExit, 'exit') { |error|
              expect(error).to be_success
            }
          end
        end
      end

      context 'mocking to return' do
        before :each do
          app = Revamp::Application.new({})
          expect(app).to receive(:run!).and_return(:mock_return)
          expect(Revamp::Application).to receive(:new).and_return(app)
        end
        describe '-f spec/fixtures/coi-sample-0.1.1.tar.gz' do
          it { expect(subject).to eq(0) }
        end
      end
      context 'mocking to raise error' do
        before :each do
          app = Revamp::Application.new({})
          expect(app).to receive(:run!).and_raise(StandardError, 'mock-ex')
          expect(Revamp::Application).to receive(:new).and_return(app)
        end
        describe '-f spec/fixtures/coi-sample-0.1.1.tar.gz' do
          it { expect(subject).to eq(1) }
        end
      end
      context 'performing real operation' do
        before :each do
          require 'revamp/persister/rpm'
          ret = double(success?: true)
          expect(Revamp::Persister::Rpm::CommandLine).to receive(:execute).and_return(ret)
          expect(FileUtils).to receive(:mv)
        end
        describe '-f spec/fixtures/coi-sample-0.1.1.tar.gz -o /tmp' do
          it { expect(subject).to eq(0) }
        end
      end
    end
  end

  describe '.parse' do
    let (:argv) { eval(self.class.description) }
    subject { instance.send(:parse, argv) }
    describe([].inspect) do
      it { expect { subject }.to raise_error(ArgumentError, /You must pass filenames with `-f`/) }
    end
    describe(['-f', 'abc-lib-1.0.0.tar.gz'].inspect) do
      it { expect { subject }.to raise_error(ArgumentError, 'Can\'t read file given: abc-lib-1.0.0.tar.gz') }
    end
    describe(['-f', 'spec/fixtures/coi-sample-0.1.1.tar.gz', '-o', Dir.tmpdir].inspect) do
      it do
        expect(subject).to eq({
          release:   "1",
          epoch:     "6",
          outdir:    "/tmp",
          filenames: ["spec/fixtures/coi-sample-0.1.1.tar.gz"],
          verbose:   false,
          cleanup:   true,
          clobber:   true
        })
      end
    end
  end
end
