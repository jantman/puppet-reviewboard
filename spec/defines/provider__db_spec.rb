require 'spec_helper'

describe 'reviewboard::provider::db', :type => :define do
  let(:title) { '/' }

  let :pre_condition do
    <<-eos
    package {'python-pip': ensure => present, }
    class {'reviewboard': }
    class {'postgresql::server': version => '9.3' }
    eos
  end

  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      describe "reviewboard::provider::db class without any parameters on #{osfamily}" do
        let(:params) {{
            :dbname => 'reviewboard',
            :dbhost => 'localhost',
            :dbuser => 'reviewboard',
            :dbpass => 'foo'
        }}
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => 'CentOS',
          :operatingsystemmajrelease => '6',
          :operatingsystemrelease => '6.5',
          :concat_basedir => '/var/lib/puppet/concat',
          :fqdn           => 'fqdn.example.com'
        }}

        it { should compile.with_all_deps }

        it { should contain_reviewboard__provider__db__puppetlabspostgresql('/').with({
                                                                                        :dbname => 'reviewboard',
                                                                                        :dbhost => 'localhost',
                                                                                        :dbuser => 'reviewboard',
                                                                                        :dbpass => 'foo'
                                                                                      })
        }
      end
    end
  end
end
