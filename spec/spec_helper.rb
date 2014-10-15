require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  c.before do
    # avoid "Only root can execute commands as other users"
    Puppet.features.stubs(:root? => true)
  end
end

class Undef
  def inspect
    'undef'
  end
end

# this is used to provide a common set of facts usable by all tests,
# while allowing us to pass in some specific facts if we need them
# see: http://stackoverflow.com/a/18938866/211734
class SpecHelperFacts
  attr_accessor :facts

  def initialize(hash={})
    # default facts
    @facts = {
      :osfamily          => 'RedHat',
      :virtualenv27_path => '/usr/bin/virtualenv-2.7',
      :python27_path     => '/usr/bin/python2.7',
      :concat_basedir    => '/var/lib/puppet/concat',
      :fqdn              => 'fqdn.example.com'
    }
    # override or append specified values
    hash.each do |k, v|
      @facts[k] = v
    end
    
    # per-osfamily defaults
    if @facts[:osfamily] == 'RedHat'
      @facts[:operatingsystem] = 'CentOS'
      @facts[:operatingsystemmajrelease] = '6'
      @facts[:operatingsystemrelease] = '6.5'
    end
  end

  def [](key)
    facts[key]
  end

  def []=(key, value)
    facts[key] = value
  end
end
