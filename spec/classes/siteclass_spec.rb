require 'spec_helper'

describe 'reviewboard::siteclass' do

  let :pre_condition do
    "package {'python-pip': ensure => present, }"
  end

  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      describe "reviewboard::siteclass class without any parameters on #{osfamily}" do
        let(:params) {{
            :site_path   => '/',
            :dbpass      => 'foo',
            :adminpass   => 'bar',
            :adminemail  => 'email@fqdn.example.com',
            :location    => '/'
        }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }

        it { should contain_reviewboard__site('/').with({
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
                                                          :webuser    => nil,
                                                        })
        }

      end
    end
  end
end
