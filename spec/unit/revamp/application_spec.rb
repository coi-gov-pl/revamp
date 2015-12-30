require 'spec_helper'

describe Revamp::Application do
  before(:each) do
    # Testing protected methods!!
    described_class.send(:public, *described_class.protected_instance_methods)
    @level = Revamp.logger.level
    Revamp.logger.level = 100
  end
  after(:each) do
    Revamp.logger.level = @level
  end
  let(:options) { {} }
  let(:converted) { [] }
  let(:target) { '/a/target/file.o' }
  let(:instance) { described_class.new(options)}

  describe '#report' do
    subject { instance.report(converted, persister, target) }
    context 'on non supporting :persisted?' do
      let(:persister) { double() }
      it { expect(subject).to eq([target]) }
    end
    context 'on non persisted one' do
      let(:persister) { double(:persisted? => false) }
      it { expect(subject).to eq([]) }
      it { expect(subject).to be_empty }
    end
    context 'on persisted one' do
      let(:persister) { double(:persisted? => true) }
      it { expect(subject).to eq([target]) }
    end
  end

end
