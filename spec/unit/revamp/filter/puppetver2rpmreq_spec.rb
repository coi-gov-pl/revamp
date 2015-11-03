require 'spec_helper'
require 'revamp/model/puppet-module'
require 'revamp/filter/puppetver2rpmreq'

describe Revamp::Filter::PuppetVerToRpmReq do
  subject { described_class.new.filter(puppetver) }
  let(:reqname) { 'puppetlabs/stdlib' }
  let(:inputhash) do
    {
      'name'                => reqname,
      'version_requirement' => version_requirement
    }
  end
  let(:puppetver) { Revamp::Model::PuppetDependency.new(inputhash) }
  let (:version_requirement) { self.class.description }

  describe '.filter()' do
    subject { described_class.new.filter(puppetver) }

    context 'for standard greater or equals cases, for ex.:' do
      describe '>=3.0.0 <4.0.0' do
        it do
          expect(subject).to eq([
            'puppetmodule(puppetlabs-stdlib) >= 3.0.0',
            'puppetmodule(puppetlabs-stdlib) < 4.0.0'
          ])
        end
      end
      describe '>= 3.0.0 < 4.0.0' do
        it do
          expect(subject).to eq([
            'puppetmodule(puppetlabs-stdlib) >= 3.0.0',
            'puppetmodule(puppetlabs-stdlib) < 4.0.0'
          ])
        end
      end
      describe '>=3.0.0' do
        it do
          expect(subject).to eq([
            'puppetmodule(puppetlabs-stdlib) >= 3.0.0'
          ])
        end
      end
      describe '>3.0' do
        it do
          expect(subject).to eq([
            'puppetmodule(puppetlabs-stdlib) > 3.0'
          ])
        end
      end
      describe '>3' do
        it do
          expect(subject).to eq([
            'puppetmodule(puppetlabs-stdlib) > 3'
          ])
        end
      end
    end
    context 'for twiddle-wakka cases, for ex.:' do
      describe '~>3.0.0' do
        it do
          expect(subject).to eq([
            'puppetmodule(puppetlabs-stdlib) >= 3.0.0',
            'puppetmodule(puppetlabs-stdlib) < 3.1.0'
          ])
        end
      end
      describe '~>3.0' do
        it do
          expect(subject).to eq([
            'puppetmodule(puppetlabs-stdlib) >= 3.0',
            'puppetmodule(puppetlabs-stdlib) < 4.0'
          ])
        end
      end
    end
    context 'for semantic versioning cases, for ex.:' do
      describe '3.x' do
        it do
          expect(subject).to eq([
            'puppetmodule(puppetlabs-stdlib) >= 3.0',
            'puppetmodule(puppetlabs-stdlib) < 4.0'
          ])
        end
      end
      describe '3.0.x' do
        it do
          expect(subject).to eq([
            'puppetmodule(puppetlabs-stdlib) >= 3.0.0',
            'puppetmodule(puppetlabs-stdlib) < 3.1.0'
          ])
        end
      end
    end
  end
end