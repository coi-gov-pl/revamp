require 'revamp'
require 'revamp/mapper/puppet-name-slugger'

# A filter that process Puppet dependency into RPM requirements lines
# More info: https://docs.puppetlabs.com/puppet/latest/reference/modules_publishing.html#dependencies-in-metadatajson
# Even more info: https://robots.thoughtbot.com/rubys-pessimistic-operator
class Revamp::Filter::PuppetVerToRpmReq
  PUPPETMODULE = 'puppetmodule'
  TWIDDLE_WAKKA = '~>'

  attr_accessor :slugger, :slug

  def initialize
    @slugger = Revamp::Mapper::PuppetNameSlugger.new
  end

  # Filters a Puppet version
  # @param [puppetver] Revamp::Model::PuppetDependency
  # @return String[]
  def filter(puppetver)
    @slug = slugger.map(puppetver.name)
    reqs = []
    requirements = puppetver.version.requirements
    if singular?(requirements)
      reqs += filter_single(requirements.first)
    else
      reqs += filter_many(requirements)
    end
    reqs
  end

  private

  def filter_single(requirement)
    reqs = []
    type, version = requirement
    if type == TWIDDLE_WAKKA
      reqs += filter_twiddle_wakka(version)
    elsif semver?(version)
      reqs += filter_semver(version)
    else
      reqs += process(requirement)
    end
    reqs
  end

  def filter_many(requirements)
    reqs = []
    requirements.each do |tuple|
      reqs += process(tuple)
    end
    reqs
  end

  def modulename
    "#{PUPPETMODULE}(#{slug})"
  end

  def process(requirement)
    type, version = requirement
    ["#{modulename} #{type} #{version}"]
  end

  def filter_twiddle_wakka(version)
    upper_cap = make_upper_cap(version)
    reqs = []
    reqs << "#{modulename} >= #{version}"
    reqs << "#{modulename} < #{upper_cap}"
    reqs
  end

  def filter_semver(version)
    digital = digitalize(version)
    filter_twiddle_wakka(digital)
  end

  def make_upper_cap(version)
    # take second from back and add increment
    upper_cap_digit = version.segments[-2] + 1
    segments = version.segments.dup
    segments[-2] = upper_cap_digit
    # zero last digit
    segments[-1] = 0
    Gem::Version.new(segments.join('.'))
  end

  def digitalize(version)
    Gem::Version.new(version.to_s.tr('x', '0'))
  end

  def semver?(version)
    version.to_s.include? 'x'
  end

  def singular?(list)
    list.size == 1
  end
end
