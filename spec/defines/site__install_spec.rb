require 'spec_helper'

describe 'reviewboard::site::install', :type => :define do

  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      describe "with example params on #{osfamily}" do
        let(:title) { '/opt/reviewboard/site' }
        let(:params) {{
            :vhost      => 'rbvhost',
            :location   => '/',
            :dbtype     => 'postgresql',
            :dbname     => 'reviewboard',
            :dbhost     => 'localhost',
            :dbuser     => 'reviewboard',
            :dbpass     => 'foobar',
            :admin      => 'admin',
            :adminpass  => 'bazblam',
            :adminemail => 'myuser@example.com',
            :cache      => 'memcached',
            :cacheinfo  => 'localhost:11211',
            :venv_path  => '/opt/reviewboard',
        }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }
        let :pre_condition do
          <<-eos
          package {'python-pip': ensure => present, }
          class {'reviewboard': }
          eos
        end

        it { should compile.with_all_deps }

        args = [ '--noinput',
                 "--domain-name rbvhost",
                 "--site-root /",
                 "--db-type postgresql",
                 "--db-name reviewboard",
                 "--db-user reviewboard",
                 "--db-pass foobar",
                 "--cache-type memcached",
                 "--cache-info localhost:11211",
                 '--web-server-type apache',
                 '--python-loader wsgi',
                 "--admin-user admin",
                 "--admin-pass bazblam",
                 "--admin-email myuser@example.com",
               ]
        argstr = args.join(" ")
        command = "/opt/reviewboard/bin/rb-site install /opt/reviewboard/site #{argstr}"
        it { should contain_exec('rb-site install /opt/reviewboard/site').with({
                                                                                 :command => command,
                                                                                 :require => 'Class[Reviewboard::Package]',
                                                                                 :creates => '/opt/reviewboard/site/conf/settings_local.py',
                                                                               })
        }
      end
      describe "non-default venv path" do
        let(:title) { '/tmp/foo/site' }
        let(:params) {{
            :vhost      => 'rbvhost',
            :location   => '/',
            :dbtype     => 'postgresql',
            :dbname     => 'reviewboard',
            :dbhost     => 'localhost',
            :dbuser     => 'reviewboard',
            :dbpass     => 'foobar',
            :admin      => 'admin',
            :adminpass  => 'bazblam',
            :adminemail => 'myuser@example.com',
            :cache      => 'memcached',
            :cacheinfo  => 'localhost:11211',
            :venv_path  => '/tmp/foo',
        }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }
        let :pre_condition do
          <<-eos
          package {'python-pip': ensure => present, }
          class {'reviewboard': venv_path => '/tmp/foo', }
          eos
        end

        it { should compile.with_all_deps }

        args = [ '--noinput',
                 "--domain-name rbvhost",
                 "--site-root /",
                 "--db-type postgresql",
                 "--db-name reviewboard",
                 "--db-user reviewboard",
                 "--db-pass foobar",
                 "--cache-type memcached",
                 "--cache-info localhost:11211",
                 '--web-server-type apache',
                 '--python-loader wsgi',
                 "--admin-user admin",
                 "--admin-pass bazblam",
                 "--admin-email myuser@example.com",
               ]
        argstr = args.join(" ")
        command = "/tmp/foo/bin/rb-site install /tmp/foo/site #{argstr}"
        it { should contain_exec('rb-site install /tmp/foo/site').with({
                                                                         :command => command,
                                                                         :require => 'Class[Reviewboard::Package]',
                                                                         :creates => '/tmp/foo/site/conf/settings_local.py',
                                                                       })
        }
      end
      pending "database on different host" do
        # need to see if we handle this
      end
    end
  end
end
