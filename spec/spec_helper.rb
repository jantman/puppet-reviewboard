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
      :concat_basedir             => '/var/lib/puppet/concat',
      :fqdn                       => 'fqdn.example.com',
      :osfamily                   => 'RedHat',
      :python26_path              => '/usr/bin/python2.6',
      :python27_path              => '/usr/bin/python2.7',
      :python_default_bin         => '/usr/bin/python',
      :python_default_version     => '2.6.6',
      :python_latest_path         => '/usr/bin/python2.7',
      :python_latest_version      => '2.7.8',
      :python_usrbin_version      => '2.6.6',
      :python_versions            => ["2.6.6", "2.7.8"],
      :python_versions_str        => '2.6.6,2.7.8',
      :virtualenv26_path          => '/usr/bin/virtualenv-2.6',
      :virtualenv27_path          => '/usr/bin/virtualenv-2.7',
      :virtualenv_default_bin     => '/usr/bin/virtualenv',
      :virtualenv_default_version => '1.10.1',
      :virtualenv_latest_path     => '/usr/bin/virtualenv-2.7',
      :virtualenv_latest_version  => '1.11.6',
      :virtualenv_usrbin_version  => '1.10.1',
      :virtualenv_versions        => ["1.10.1", "1.11.6"],
      :virtualenv_versions_str    => '1.10.1,1.11.6',
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
