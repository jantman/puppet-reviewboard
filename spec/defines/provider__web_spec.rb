require 'spec_helper'

describe 'reviewboard::provider::web', :type => :define do
  let(:title) { '/opt/reviewboard/site' }

  let :pre_condition do
    "package {'python-pip': ensure => present, }"
  end


  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      describe "with default parameters on #{osfamily}" do
        let(:params) {{
            :vhost       => 'fqdn.example.com',
            :location    => '/',
            :webuser     => 'apache',
            :venv_path   => '/opt/reviewboard',
            :venv_python => '/usr/bin/python2.7',
            :base_venv   => '/opt/empty_base_venv',
        }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }
        let(:pre_condition) { "class {'reviewboard': }"}

        it { should compile.with_all_deps }

        it { should contain_reviewboard__provider__web__puppetlabsapache('/opt/reviewboard/site').with({
                                                                                                         :vhost       => 'fqdn.example.com',
                                                                                                         :location    => '/',
                                                                                                         :venv_path   => '/opt/reviewboard',
                                                                                                         :venv_python => '/usr/bin/python2.7',
                                                                                                         :base_venv   => '/opt/empty_base_venv',
                                                                                                       })
        }

        ['/opt/reviewboard/site/data', '/opt/reviewboard/site/htdocs/media', '/opt/reviewboard/site/htdocs/media/ext'].each do |f|
          it { should contain_file(f).with({
                                             :ensure  => 'directory',
                                             :owner   => 'apache',
                                             :notify  => 'Class[Apache::Service]',
                                             :recurse => true
                                             })
          }
        end

        it { should contain_file('/opt/reviewboard/site/conf').with({
                                                             :ensure  => 'directory',
                                                             :owner   => 'apache',
                                                             :recurse => true,
                                                             :mode    => 'go-rwx'
                                                             })
        }
      end

      describe "with mod_wsgi params on #{osfamily}" do
        let(:params) {{
            :vhost                 => 'fqdn.example.com',
            :location              => '/',
            :webuser               => 'apache',
            :venv_path             => '/opt/reviewboard',
            :venv_python           => '/usr/bin/python3.3',
            :base_venv             => '/opt/empty_base_venv',
            :mod_wsgi_package_name => 'python33-mod_wsgi',
            :mod_wsgi_so_name      => 'python33-mod_wsgi',
        }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }
        let(:pre_condition) { "class {'reviewboard': }"}

        it { should compile.with_all_deps }

        it { should contain_reviewboard__provider__web__puppetlabsapache('/opt/reviewboard/site').with({
                                                                                                         :vhost                 => 'fqdn.example.com',
                                                                                                         :location              => '/',
                                                                                                         :venv_path             => '/opt/reviewboard',
                                                                                                         :venv_python           => '/usr/bin/python3.3',
                                                                                                         :base_venv             => '/opt/empty_base_venv',
                                                                                                         :mod_wsgi_package_name => 'python33-mod_wsgi',
                                                                                                         :mod_wsgi_so_name      => 'python33-mod_wsgi',
                                                                                                       })
        }
      end

      describe "with non-default title/name on #{osfamily}" do
        let(:title) { '/otherpath' }
        let(:params) {{
            :vhost    => 'fqdn.example.com',
            :location => '/',
            :webuser  => 'apache',
            :venv_path   => '/opt/reviewboard',
            :venv_python => '/usr/bin/python2.7',
            :base_venv   => '/opt/empty_base_venv',
        }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }
        let(:pre_condition) { "class {'reviewboard': }"}

        it { should compile.with_all_deps }

        it { should contain_reviewboard__provider__web__puppetlabsapache('/otherpath').with({
                                                                                              :vhost       => 'fqdn.example.com',
                                                                                              :location    => '/',
                                                                                              :venv_path   => '/opt/reviewboard',
                                                                                              :venv_python => '/usr/bin/python2.7',
                                                                                              :base_venv   => '/opt/empty_base_venv',
                                                                                            })
        }
        it { should_not contain_reviewboard__provider__web__simple('/opt/reviewboard/site') }

        ['/otherpath/data', '/otherpath/htdocs/media', '/otherpath/htdocs/media/ext'].each do |f|
          it { should contain_file(f).with({
                                             :ensure  => 'directory',
                                             :owner   => 'apache',
                                             :notify  => 'Class[Apache::Service]',
                                             :recurse => true
                                             })
          }
        end

        it { should contain_file('/otherpath/conf').with({
                                                           :ensure  => 'directory',
                                                           :owner   => 'apache',
                                                           :recurse => true,
                                                           :mode    => 'go-rwx'
                                                         })
        }
      end

      describe "with simple webprovider on #{osfamily}" do
        let(:params) {{
            :vhost    => 'fqdn.example.com',
            :location => '/',
            :webuser  => 'apache',
            :venv_path   => '/opt/reviewboard',
            :venv_python => '/usr/bin/python2.7',
            :base_venv   => '/opt/empty_base_venv',
        }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }
        let(:pre_condition) { "class {'reviewboard': webprovider => 'simple'}"}

        it { should compile.with_all_deps }

        it { should_not contain_reviewboard__provider__web__puppetlabsapache('/opt/reviewboard/site') }

        it { should contain_reviewboard__provider__web__simple('/opt/reviewboard/site').with({
                                                                                               :vhost       => 'fqdn.example.com',
                                                                                               :location    => '/',
                                                                                               :venv_path   => '/opt/reviewboard',
                                                                                               :venv_python => '/usr/bin/python2.7',
                                                                                               :base_venv   => '/opt/empty_base_venv',
                                                                                             })
        }

        ['/opt/reviewboard/site/data', '/opt/reviewboard/site/htdocs/media', '/opt/reviewboard/site/htdocs/media/ext'].each do |f|
          it { should contain_file(f).with({
                                             :ensure  => 'directory',
                                             :owner   => 'apache',
                                             :notify  => 'Service[httpd]',
                                             :recurse => true
                                             })
          }
        end

        it { should contain_file('/opt/reviewboard/site/conf').with({
                                                             :ensure  => 'directory',
                                                             :owner   => 'apache',
                                                             :recurse => true,
                                                             :mode    => 'go-rwx'
                                                             })
        }
      end

      describe "with none webprovider on #{osfamily}" do
        let(:params) {{
            :vhost    => 'fqdn.example.com',
            :location => '/',
            :webuser  => 'apache',
            :venv_path   => '/opt/reviewboard',
            :venv_python => '/usr/bin/python2.7',
            :base_venv   => '/opt/empty_base_venv',
        }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }
        let(:pre_condition) { "class {'reviewboard': webprovider => 'none'}"}

        it { should compile.with_all_deps }

        it { should_not contain_reviewboard__provider__web__puppetlabsapache('/opt/reviewboard/site') }

        it { should_not contain_reviewboard__provider__web__simple('/opt/reviewboard/site') }

        ['/opt/reviewboard/site/data', '/opt/reviewboard/site/htdocs/media', '/opt/reviewboard/site/htdocs/media/ext'].each do |f|
          it { should contain_file(f).with({
                                             :ensure  => 'directory',
                                             :owner   => 'apache',
                                             :recurse => true
                                             })
          }
        end

        it { should contain_file('/opt/reviewboard/site/conf').with({
                                                             :ensure  => 'directory',
                                                             :owner   => 'apache',
                                                             :recurse => true,
                                                             :mode    => 'go-rwx'
                                                             })
        }
      end

      describe "with 'invalid' webprovider on #{osfamily}" do
        let(:params) {{
            :vhost       => 'fqdn.example.com',
            :location    => '/',
            :webuser     => 'apache',
            :venv_path   => '/opt/reviewboard',
            :venv_python => '/usr/bin/python2.7',
            :base_venv   => '/opt/empty_base_venv',
        }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }
        let(:pre_condition) { "class {'reviewboard': webprovider => 'invalid'}"}

        it do
          expect {
            should contain_reviewboard__provider__db('/opt/reviewboard/site')
          }.to raise_error(Puppet::Error, /Web provider 'invalid' not defined/)
        end
      end

      describe "with mod_wsgi_package_name but not mod_wsgi_so_name on #{osfamily}" do
        let(:params) {{
            :vhost                 => 'fqdn.example.com',
            :location              => '/',
            :webuser               => 'apache',
            :venv_path             => '/opt/reviewboard',
            :venv_python           => '/usr/bin/python2.7',
            :base_venv             => '/opt/empty_base_venv',
            :mod_wsgi_package_name => 'python33-mod_wsgi',
        }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }
        let(:pre_condition) { "class {'reviewboard': webuser => 'apache'}"}

        it do
          expect {
            should contain_reviewboard__provider__db('/opt/reviewboard/site')
          }.to raise_error(Puppet::Error, /mod_wsgi_package_name and mod_wsgi_so_name must be specified together/)
        end
      end

      describe "with mod_wsgi_so_name but not mod_wsgi_package_name on #{osfamily}" do
        let(:params) {{
            :vhost            => 'fqdn.example.com',
            :location         => '/',
            :webuser          => 'apache',
            :venv_path        => '/opt/reviewboard',
            :venv_python      => '/usr/bin/python2.7',
            :base_venv        => '/opt/empty_base_venv',
            :mod_wsgi_so_name => 'python33-mod_wsgi',
        }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }
        let(:pre_condition) { "class {'reviewboard': webuser => 'apache'}"}

        it do
          expect {
            should contain_reviewboard__provider__db('/opt/reviewboard/site')
          }.to raise_error(Puppet::Error, /mod_wsgi_package_name and mod_wsgi_so_name must be specified together/)
        end
      end


      describe "with mod_wsgi_package name and mod_wsgi_so_name and web provider other than puppetlabs/apache on #{osfamily}" do
        let(:params) {{
            :vhost                 => 'fqdn.example.com',
            :location              => '/',
            :webuser               => 'apache',
            :venv_path             => '/opt/reviewboard',
            :venv_python           => '/usr/bin/python2.7',
            :base_venv             => '/opt/empty_base_venv',
            :mod_wsgi_package_name => 'python33-mod_wsgi',
            :mod_wsgi_so_name      => 'python33-mod_wsgi',
        }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }
        let(:pre_condition) { "class {'reviewboard': webuser => 'apache', webprovider => 'simple',}"}

        it do
          expect {
            should contain_reviewboard__provider__db('/opt/reviewboard/site')
          }.to raise_error(Puppet::Error, /mod_wsgi_package_name and mod_wsgi_so_name are only supported with puppetlabs\/apache webprovider/)
        end
      end

    end
  end
end
