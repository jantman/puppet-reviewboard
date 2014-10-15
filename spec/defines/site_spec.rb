require 'spec_helper'

describe 'reviewboard::site', :type => :define do
  let(:title) { 'sitename' }

  let :pre_condition do
    "package {'python-pip': ensure => present, }"
  end

  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      describe "define without any parameters on #{osfamily}" do
        let(:params) {{
            :dbpass     => 'foo',
            :adminpass  => 'bar',
            :adminemail => 'email@fqdn.example.com'
        }}
	let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }

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

  context 'input validation' do
    let(:facts) { SpecHelperFacts.new().facts }

    describe 'dbpass undefined should fail' do
      let(:params) {{
        :dbpass => Undef.new
      }}

      it do
        expect {
          should contain_reviewboard__provider__web('sitename')
        }.to raise_error(Puppet::Error, /Postgres DB password not set/)
      end
    end

    describe 'adminpass undefined should fail' do
      let(:params) {{
        :dbpass    => 'foo',
        :adminpass => Undef.new
      }}

      it do
        expect {
          should contain_reviewboard__provider__web('sitename')
        }.to raise_error(Puppet::Error, /Admin password not set/)
      end
    end

    describe 'adminemail or web user must be set' do
      let(:params) {{
        :dbpass    => 'foo',
        :adminpass => 'foo'
      }}

      it do
        expect {
          should contain_reviewboard__provider__web('sitename')
        }.to raise_error(Puppet::Error, /webuser must be explicitly set if adminemail is not/)
      end
    end

    describe 'non-/ location with puppetlabs/apache web provider should fail' do
      let(:params) {{
        :dbpass     => 'foo',
        :adminpass  => 'foo',
        :adminemail => 'foo@example.com',
        :location   => '/foo/bar/baz'
      }}

      it do
        expect {
          should contain_reviewboard__provider__web('sitename')
        }.to raise_error(Puppet::Error, /Due to a bug in puppet allowing only hashes keyed by string literals/)
      end
    end
    describe "location /foo should be normalized to /foo/" do
      let(:params) {{
          :dbpass     => 'foo',
          :adminpass  => 'bar',
          :adminemail => 'email@fqdn.example.com',
          :location   => '/foo'
      }}
      let(:pre_condition) { "class {'reviewboard': webprovider => 'none'}" }

      it { should contain_reviewboard__site__install('sitename').with({
                                                                        :location   => '/foo/',
                                                                        })
      }

      it { should contain_reviewboard__provider__web('sitename').with({
                                                                        :location => '/foo',
                                                                        })
      }

    end
  end
end
