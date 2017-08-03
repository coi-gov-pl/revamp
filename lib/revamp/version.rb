# Top level module for Revamp
module Revamp
  # Version for Herald
  VERSION     = '1.1.1.pre'
  # Lincense for Herald
  LICENSE     = 'Apache-2.0'
  # Project name
  NAME        = 'Revamp'
  # Package (gem) for Herald
  PACKAGE     = 'revamp'
  # A summary info
  SUMMARY     = 'Converts puppet module file to valid RPM or DEB package'
  # A homepage for Herald
  HOMEPAGE    = 'https://github.com/coi-gov-pl/gem-revamp'
  # A description info
  DESCRIPTION = <<-eos
  This module can convert standard puppet module file in form of tarball to
  valid RPM or DEB package with all dependencies as references to other
  system packages. The dependencies can be packaged inside the final system
  package or just referenced as dependencies.
  eos
end
