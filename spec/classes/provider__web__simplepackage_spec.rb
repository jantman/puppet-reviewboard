require 'spec_helper'

default_version = '2.0.2'

describe 'reviewboard::provider::web::simplepackage' do

  let :pre_condition do
    "package {'python-pip': ensure => present, }"
  end

  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      describe "reviewboard::provider::web::simplepackage class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }

        it { should compile.with_all_deps }

        it { should contain_package('httpd').with_ensure('present') }

        it { should contain_service('httpd').with({
                                                    :ensure  => 'running',
                                                    :enable  => true,
                                                    :require => 'Package[httpd]'
                                                  })
        }

        it { should contain_file('/etc/httpd/conf.d').with({
                                                             :ensure  => 'directory',
                                                             :recurse => true,
                                                             :purge   => true,
                                                             :require => 'Package[httpd]'
                                                             })
        }

        it { should contain_file('/etc/httpd/conf.d/mod_wsgi.conf').with({
                                                                           :ensure  => 'present',
                                                                           :content => 'LoadModule wsgi_module modules/mod_wsgi.so',
                                                                           :notify  => 'Service[httpd]'
                                                                           })
        }
      end
    end
  end
end
