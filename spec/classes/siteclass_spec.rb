require 'spec_helper'

describe 'reviewboard::siteclass' do

  let :pre_condition do
    "package {'python-pip': ensure => present, }"
  end

  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      describe "with only required parameters on #{osfamily}" do
        let(:params) {{
            :site_path   => '/',
            :dbpass      => 'foo',
            :adminpass   => 'bar',
            :adminemail  => 'foo@fqdn.example.com'
        }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }
        let(:pre_condition) { "class {'postgresql::server': }" }

        it { should compile.with_all_deps }

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
                                                          :adminemail => 'foo@fqdn.example.com',
                                                          :cache      => 'memcached',
                                                          :cacheinfo  => 'localhost:11211',
                                                          :webuser    => nil,
                                                        })
        }

      end

      describe "with no web provider on #{osfamily}" do
        let(:params) {{
            :site_path   => '/',
            :dbpass      => 'foo',
            :adminpass   => 'bar',
            :adminemail  => 'email@fqdn.example.com',
            :location    => '/reviewboard'
        }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }
        let(:pre_condition) { ["class {'postgresql::server': }",
                               "class {'reviewboard': webprovider => 'none', }"]}

        it { should compile.with_all_deps }

        it { should contain_reviewboard__site('/').with({
                                                          :vhost      => 'fqdn.example.com',
                                                          :location   => '/reviewboard',
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

      describe "with non-absolute-path site_path on #{osfamily}" do
        let(:params) {{
            :site_path   => 'foo',
            :dbpass      => 'foo',
            :adminpass   => 'bar',
            :adminemail  => 'email@fqdn.example.com',
            :location    => '/'
        }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }

        it do
          expect {
            should contain_class('reviewboard::siteclass')
          }.to raise_error(Puppet::Error, /"foo" is not an absolute path/)
        end

      end

      describe "with specified vhost on #{osfamily}" do
        let(:params) {{
            :site_path   => '/',
            :dbpass      => 'foo',
            :adminpass   => 'bar',
            :adminemail  => 'email@fqdn.example.com',
            :vhost       => 'reviewboard'
        }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }
        let(:pre_condition) { "class {'postgresql::server': }" }

        it { should compile.with_all_deps }

        it { should contain_reviewboard__site('/').with({
                                                          :vhost      => 'reviewboard',
                                                        })
        }

      end
    end
  end
end
