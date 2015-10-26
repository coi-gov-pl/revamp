require 'revamp'

# A module for filters
module Revamp::Filter
  # Main RPM filter
  class Rpm
    @outdir  = nil
    @release = nil

    attr_accessor :outdir
    attr_accessor :release

    def filter(model)
      filename = "puppetmodule_#{model.slugname}-#{model.version}-#{release}.noarch.rpm"
      target = Pathname.new(outdir).join(filename)
      Revamp.logger.info("Converting to RPM package #{target}...")
    end
  end
end
