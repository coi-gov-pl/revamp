require 'revamp'

# This class implements slugification of Puppet module name: 'puppetlabs/stdlib' <-> 'puppetlabs-stdlib'
class Revamp::Mapper::PuppetNameSlugger
  def map(slash_name)
    slash_name.tr('/', '-')
  end
end
