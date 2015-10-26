require 'spec_helper'
require 'file_matchers'
require 'rspec/its'
require 'revamp/parser/puppet-tarball'

describe Revamp::Parser::PuppetTarball do
  let(:sample_file) { 'spec/fixtures/coi-sample-0.1.1.tar.gz' }
  context 'for a sample puppet tarball file' do
    it { expect(sample_file).to be_readable_file }
    let(:parser) { described_class.new(sample_file) }

    describe '.new' do
      it { expect(parser).not_to be_nil }
    end

    describe '.parse' do
      let(:model) { parser.parse }
      it { expect(model).not_to be_nil }
      
      context 'files' do
        subject { model.files }
        context 'size' do
          let (:size) { subject.size }
          it { expect(size).to eq(3) }
        end
        it { expect(subject.keys).to include 'checksums.json' }
        it { expect(subject.keys).to include 'metadata.json' }
        it { expect(subject.keys).to include 'manifests/init.pp' }
      end

      context 'model' do
        subject { model }
        it { is_expected.not_to be_nil }
        its(:metadata) { is_expected.to be_a(Hash) }
        its(:name) { is_expected.to eq('coi/sample') }
        its(:summary) { is_expected.to eq 'An example Puppet module' }
        its(:version) { is_expected.to eq '0.1.1' }
        its(:license) { is_expected.to eq 'Apache-2.0' }
        its(:author) { is_expected.to eq 'Krzysztof Suszynski' }
        context 'dependencies' do
          subject { model.dependencies }
          its(:size) { is_expected.to eq(1) }
          context 'pop' do
            subject { model.dependencies.pop }
            its(:name) { is_expected.to eq('puppetlabs/stdlib') }
            its(:version) { is_expected.to eq(Gem::Requirement.new(["< 5.0.0", ">= 3.2.0"])) }
          end
        end
      end
      
    end
  end
end