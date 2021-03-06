# Revamp

[![Build Status](https://travis-ci.org/coi-gov-pl/revamp.svg)](https://travis-ci.org/coi-gov-pl/revamp) [![Coverage Status](https://coveralls.io/repos/coi-gov-pl/revamp/badge.svg?branch=develop&service=github)](https://coveralls.io/github/coi-gov-pl/revamp?branch=develop) [![Code Climate](https://codeclimate.com/github/coi-gov-pl/revamp/badges/gpa.svg)](https://codeclimate.com/github/coi-gov-pl/revamp) [![Dependency Status](https://gemnasium.com/coi-gov-pl/revamp.svg)](https://gemnasium.com/coi-gov-pl/revamp) [![Gem Version](https://badge.fury.io/rb/revamp.svg)](https://badge.fury.io/rb/revamp)

This module can convert standard puppet module file in form of tarball to valid RPM or DEB package with all dependencies as references to other system packages. The dependencies can be packaged inside the final system package or just referenced as dependencies.

## Installation

Install it yourself, globally as:

    $ sudo gem install revamp

On Debian/Ubuntu systems to convert to RPM you will need also:

    $ sudo apt-get install -y rpm
    
On RHEL systems you will need also:

    $ sudo yum install -y rpm-build
    
For convenience thare is a Docker image with system tools and revamp preinstalled: `coigovpl/revamp`. The usage is simply:

    $ docker run --rm coigovpl/revamp revamp --help

## Usage

The basic usage is really simple:

    $ revamp -f coi-jboss-1.0.0.tar.gz
    INFO: Converting to RPM package puppetmodule_coi-jboss-1.0.0-0.noarch.rpm...
    INFO: Files successfully converted: 1.

Or with extra options:

    $ revamp --release 42 --outdir /tmp -f coi-jboss-1.0.0.tar.gz
    INFO: Converting to RPM package /tmp/puppetmodule_coi-jboss-1.0.0-42.noarch.rpm...
    INFO: Files successfully converted: 1.

More on available options in help:

    $ revamp --help

## Contributing

1. Fork it ( https://github.com/coi-gov-pl/gem-revamp/fork )
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Create a new Pull Request
