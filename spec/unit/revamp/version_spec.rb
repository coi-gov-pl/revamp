require 'spec_helper'
require 'revamp'

describe Revamp, '::VERSION' do
  subject { Revamp::VERSION }
  it { expect(subject).to match /^\d+\.\d+\.\d+(?:\.pre)?$/ }
end
