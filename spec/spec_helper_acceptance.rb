# Adapted from the puppetlabs/postgresql tests

require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

class String
  # Provide ability to remove indentation from strings, for the purpose of
  # left justifying heredoc blocks.
  def unindent
    gsub(/^#{scan(/^\s*/).min_by{|l|l.length}}/, "")
  end
end

def shellescape(str)
  str = str.to_s

  # An empty argument will be skipped, so return empty quotes.
  return "''" if str.empty?

  str = str.dup

  # Treat multibyte characters as is.  It is caller's responsibility
  # to encode the string in the right encoding for the shell
  # environment.
  str.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/, "\\\\\\1")

  # A LF cannot be escaped with a backslash because a backslash + LF
  # combo is regarded as line continuation and simply ignored.
  str.gsub!(/\n/, "'\n'")

  return str
end

hosts.each do |host|
  if host['platform'] =~ /debian/
    on host, 'echo \'export PATH=/var/lib/gems/1.8/bin/:${PATH}\' >> ~/.bashrc'
  end
  if host.is_pe?
    install_pe
  else
    # Install Puppet
    install_package host, 'rubygems'
    # make sure we only have one
    on host, 'gem list puppet | grep -q puppet && gem uninstall puppet --all || /bin/true'
    # TODO: having issues with facts from fixture modules and 3.7's directory environments; force 3.6.2 for now
    on host, 'gem install puppet -v 3.6.2 --no-ri --no-rdoc'
    on host, "mkdir -p #{host['distmoduledir']}"
  end
  if host['platform'] =~ /el/
    # setup EPEL, until https://github.com/puppetlabs/beaker/issues/447 is done
    on host, "yum -y update ca-certificates && yum -y install epel-release && yum clean all && yum makecache"
  end
end

UNSUPPORTED_PLATFORMS = ['AIX','windows','Solaris','Suse']

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'reviewboard')
    # make sure fixtures are there
    system("bundle exec rake spec_prep")
    hosts.each do |host|
      # install fixture modules
      ['stdlib', 'apache', 'concat', 'postgresql', 'virtualenv', 'python', 'yum', 'nodejs'].each do |m|
        scp_to host, File.join(proj_root, 'spec', 'fixtures', 'modules', m), File.join('/etc/puppet/modules', m)
      end
      # facts in modules (plugins-in-modules)
      on host, shell('mkdir -p /var/lib/puppet/lib/facter/')
      on host, shell('find /etc/puppet/modules/*/lib/facter -iname "*.rb" -exec cp {} /var/lib/puppet/lib/facter/ \;')
      # boilerplate
      on host, shell('chmod 755 /root')
      if fact('osfamily') == 'Debian'
        shell("echo \"en_US ISO-8859-1\nen_NG.UTF-8 UTF-8\nen_US.UTF-8 UTF-8\n\" > /etc/locale.gen")
        shell('/usr/sbin/locale-gen')
        shell('/usr/sbin/update-locale')
      end
    end
  end
end
