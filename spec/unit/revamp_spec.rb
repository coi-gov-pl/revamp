require 'spec_helper'
require 'revamp'

describe Revamp do
  describe '#bug' do
    let(:ex) do
      ex = nil
      begin
        raise ArgumentError, 'Sample error'
      rescue => detail
        ex = detail
      end
      ex
    end
    subject { described_class.bug(ex) }
    after :each do
      Dir.glob(Dir.tmpdir + '/revamp-bug*.log') { |file| Pathname.new(file).unlink }
    end
    it { is_expected.not_to be_nil }
  end
end