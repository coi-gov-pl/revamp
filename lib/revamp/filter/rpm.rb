require 'revamp'
require 'rpm'

# A module for filters
module Revamp::Filter
  # Main RPM filter
  class Rpm
    @outdir  = nil
    @release = nil
    @epoch   = nil

    attr_accessor :outdir
    attr_accessor :release
    attr_accessor :epoch

    def filter(model)
      rpmname = "puppetmodule_#{model.slugname}"
      rpmversion = "#{model.version}-#{release}"
      filename = "#{rpmname}-#{rpmversion}.noarch.rpm"
      target = Pathname.new(outdir).join(filename)
      version = RPM::Version.new(rpmversion)
      pkg = RPM::Package.create(rpmname, version)
      puts pkg.inspect
      Revamp.logger.info("Converting to RPM package #{target}...")
    end
  end
end
