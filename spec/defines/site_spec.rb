require 'spec_helper'

describe 'reviewboard::site', :type => :define do
  let(:title) { 'sitename' }

  let :pre_condition do
    "package {'python-pip': ensure => present, }"
  end

  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      describe "reviewboard::site define without any parameters on #{osfamily}" do
        let(:params) {{
            :dbpass     => 'foo',
            :adminpass  => 'bar',
            :adminemail => 'email@fqdn.example.com'
        }}
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => 'CentOS',
          :operatingsystemmajrelease => '6',
          :operatingsystemrelease => '6.5',
          :concat_basedir => '/var/lib/puppet/concat',
          :fqdn           => 'fqdn.example.com'
        }}

        it { should contain_reviewboard__provider__db('sitename').with({
                                                                         :dbuser => 'reviewboard',
                                                                         :dbpass => 'foo',
                                                                         :dbname => 'reviewboard',
                                                                         :dbhost => 'localhost'
                                                                         })
        }

        it { should contain_reviewboard__site__install('sitename').with({
                                                                          :vhost      => 'fqdn.example.com',
                                                                          :location   => '/',
                                                                          :dbtype     => 'postgresql',
                                                                          :dbname     => 'reviewboard',
                                                                          :dbhost     => 'localhost',
                                                                          :dbuser     => 'reviewboard',
                                                                          :dbpass     => 'foo',
                                                                          :admin      => 'admin',
                                                                          :adminpass  => 'bar',
                                                                          :adminemail => 'email@fqdn.example.com',
                                                                          :cache      => 'memcached',
                                                                          :cacheinfo  => 'localhost:11211',
                                                                          :require    => 'Reviewboard::Provider::Db[sitename]',
                                                                          })
        }

        it { should contain_reviewboard__provider__web('sitename').with({
                                                                          :vhost    => 'fqdn.example.com',
                                                                          :location => '/',
                                                                          :webuser  => nil,
                                                                          :require  => 'Reviewboard::Site::Install[sitename]',
                                                                          })
        }

      end
    end
  end
end
