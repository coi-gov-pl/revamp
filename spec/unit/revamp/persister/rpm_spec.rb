require 'spec_helper'
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

describe Revamp::Persister::Rpm::Builder do
  let(:model) do
    mod = Revamp::Model::PuppetModule.new
    mod.name = 'puppetlabs/apache'
    mod.version = '3.5.1'
    mod.license = 'Apache-2.0'
    mod.summary = 'Installs, configures, and manages Apache virtual hosts, web services, and modules.'
    mod.dependencies = [
      {'name' => 'puppetlabs/concat', 'version_requirement' => '>= 1.0.5 <2.0.0'}
    ]
    mod
  end
  let(:spec) do
    <<-eos
Name: puppetmodule_puppetlabs-apache
Version: 3.5.1
Release: 42
Summary: Installs, configures, and manages Apache virtual hosts, web services, and modules.
Source0: puppetmodule_puppetlabs-apache-3.5.1.tar.gz
License: Apache-2.0
Group: Development
BuildArch: noarch
Provides: puppetmodule(puppetlabs-apache) = 3.5.1
Provides: puppetmodule(puppetlabs-apache) = 3.5.1-42
Provides: puppetmodule_puppetlabs-apache = 3.5.1
Provides: puppetmodule_puppetlabs-apache = 3.5.1-42
Requires: puppetmodule(puppetlabs-concat) >= 1.0.5, puppetmodule(puppetlabs-concat) < 2.0.0
%description
Installs, configures, and manages Apache virtual hosts, web services, and modules.
%prep
%setup
%build
%install
rm -rf $RPM_BUILD_ROOT
mkdir -p ${RPM_BUILD_ROOT}/etc/puppet/modules
cp -r %{_builddir}/puppetmodule_puppetlabs-apache-3.5.1 ${RPM_BUILD_ROOT}%{_sysconfdir}/puppet/modules
mv ${RPM_BUILD_ROOT}%{_sysconfdir}/puppet/modules/puppetmodule_puppetlabs-apache-3.5.1 ${RPM_BUILD_ROOT}%{_sysconfdir}/puppet/modules/apache
%clean
%post
%files
%dir %{_sysconfdir}/puppet
%dir %{_sysconfdir}/puppet/modules
%dir %{_sysconfdir}/puppet/modules/apache

    eos
  end
  let(:dir) { Dir.tmpdir }
  let(:options) { { :release => 42 } }
  let(:instance) { described_class.new(model, dir, options) }
  describe '#generate_spec' do
    subject { instance.generate_spec }
    it { expect(subject).to eq spec }
    it { expect(subject).to match /Version: 3\.5\.1/ }
  end
end
