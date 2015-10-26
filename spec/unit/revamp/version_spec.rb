require 'spec_helper'
require 'revamp'

describe Revamp, '.version_prep' do
  context 'on stable version v1.2.3' do
    subject { Revamp::version_prep '1.2.3' }
    it { expect(subject).to eq '1.2.3' }
  end
  context 'on unstable version v1.2.3.pre' do
    subject { Revamp::version_prep '1.2.3.pre' }
    it { expect(subject).to match /^1\.2\.3\.pre\.?(?:v\d+\.\d+\.\d+(?:\.\d+\.g)?)?(?:[0-9a-f]{7})?(?:\.dirty)?$/ }
  end
end
