require 'spec_helper'

default_version = '2.0.2'

install_opts = ['--allow-unverified',
                'ReviewBoard',
               ]

describe 'reviewboard::package' do

  let :pre_condition do
    "package {'python-pip': ensure => present, }"
  end

  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      describe "class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }

        it { should compile.with_all_deps }

        it { should contain_python_virtualenv('/opt/empty_base_venv').with({
                                                                             :ensure     => 'present',
                                                                             :virtualenv => '/usr/bin/virtualenv-2.7',
                                                                             :python     => '/usr/bin/python2.7'
                                                                           })
        }

        it { should contain_python_virtualenv('/opt/reviewboard').with({
                                                                         :ensure     => 'present',
                                                                         :virtualenv => '/usr/bin/virtualenv-2.7',
                                                                         :python     => '/usr/bin/python2.7',
                                                                         :require    => 'Python_virtualenv[/opt/empty_base_venv]',
                                                                       })
        }

        it { should contain_python_package('/opt/reviewboard,pip>=1.5.1').with({
                                                                                  :ensure        => 'present',
                                                                                  :python_prefix => '/opt/reviewboard',
                                                                                  :requirements  => 'pip>=1.5.1',
                                                                                  :options       => '--upgrade',
                                                                                  :require       => 'Python_virtualenv[/opt/reviewboard]',
                                                                                })
        }

        it { should contain_package('uglifyjs').with_name('uglify-js') }

        it { should contain_package('gettext') }

        build_reqs = ['# puppet-managed - reviewboard::package class',
                       '# because of pip issues, these have to be installed before ReviewBoard',
                       'Django>=1.6.7,<1.7',
                       'django-pipeline',
                       'djblets',
                       'django-evolution',
                       'pygments',
                       'docutils',
                       'markdown',
                       'paramiko',
                       'mimeparse',
                       'haystack',
                       'psycopg2',
                      ]
        build_reqs_s = build_reqs.join("\n")

        build_req_options = ['--allow-unverified',
                             'django-evolution',
                             '--allow-unverified',
                             'djblets',
                            ]

        it { should contain_file('/opt/reviewboard/puppet_build_requirements.txt').with({
                                                                                          :ensure  => 'present',
                                                                                          :mode    => '0644',
                                                                                          :content => build_reqs_s,
                                                                                          :require => 'Python_virtualenv[/opt/reviewboard]',
                                                                                          }) }

        it { should contain_python_package('/opt/reviewboard,/opt/reviewboard/puppet_build_requirements.txt').with({
                                                                                                                     :ensure            => 'present',
                                                                                                                     :python_prefix     => '/opt/reviewboard',
                                                                                                                     :requirements_file => '/opt/reviewboard/puppet_build_requirements.txt',
                                                                                                                     :options           => build_req_options,
                                                                                                                     :require           => ['File[/opt/reviewboard/puppet_build_requirements.txt]',
                                                                                                                                            'Package[uglifyjs]',
                                                                                                                                            'Package[gettext]',
                                                                                                                                            'Python_package[/opt/reviewboard,pip>=1.5.1]',
                                                                                                                                           ]
                                                                                                                     }) }

        it { should contain_python_package('/opt/reviewboard,ReviewBoard').with({
                                                                                  :ensure        => 'present',
                                                                                  :python_prefix => '/opt/reviewboard',
                                                                                  :requirements  => 'ReviewBoard',
                                                                                  :options       => install_opts,
                                                                                  :require       => 'Python_package[/opt/reviewboard,/opt/reviewboard/puppet_build_requirements.txt]'
                                                                                })
        }
      end

      describe "class with specified version on #{osfamily}" do
        let(:params) {{ :version => '2.0.2'}}
        
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }

        it { should compile.with_all_deps }

        it { should contain_python_package('/opt/reviewboard,ReviewBoard==2.0.2').with({
                                                                                  :ensure        => 'present',
                                                                                  :python_prefix => '/opt/reviewboard',
                                                                                  :requirements  => 'ReviewBoard==2.0.2',
                                                                                  :options       => install_opts,
                                                                                  :require       => 'Python_package[/opt/reviewboard,/opt/reviewboard/puppet_build_requirements.txt]'
                                                                                })
        }
      end

      describe "class with specified virtualenv_script and python on #{osfamily}" do
        let(:params) {{
            :virtualenv_script => '/foo/bar/virtualenv',
            :venv_python       => '/foo/bar/python'
        }}
        
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }

        it { should compile.with_all_deps }

        it { should contain_python_virtualenv('/opt/empty_base_venv').with({
                                                                             :ensure     => 'present',
                                                                             :virtualenv => '/foo/bar/virtualenv',
                                                                             :python     => '/foo/bar/python'
                                                                           })
        }

        it { should contain_python_virtualenv('/opt/reviewboard').with({
                                                                         :ensure     => 'present',
                                                                         :virtualenv => '/foo/bar/virtualenv',
                                                                         :python     => '/foo/bar/python'
                                                                       })
        }
      end

      describe "class with specified venv_path on #{osfamily}" do
        let(:params) {{
            :venv_path => '/foo/bar'
        }}
        
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }

        it { should compile.with_all_deps }

        it { should contain_python_virtualenv('/foo/bar').with({
                                                                 :ensure     => 'present',
                                                                 :virtualenv => '/usr/bin/virtualenv-2.7',
                                                                 :python     => '/usr/bin/python2.7',
                                                                 :require    => 'Python_virtualenv[/opt/empty_base_venv]',
                                                               })
        }

        it { should contain_python_package('/foo/bar,pip>=1.5.1').with({
                                                                                  :ensure        => 'present',
                                                                                  :python_prefix => '/foo/bar',
                                                                                  :requirements  => 'pip>=1.5.1',
                                                                                  :options       => '--upgrade',
                                                                                  :require       => 'Python_virtualenv[/foo/bar]',
                                                                                })
        }

        build_reqs = ['# puppet-managed - reviewboard::package class',
                       '# because of pip issues, these have to be installed before ReviewBoard',
                       'Django>=1.6.7,<1.7',
                       'django-pipeline',
                       'djblets',
                       'django-evolution',
                       'pygments',
                       'docutils',
                       'markdown',
                       'paramiko',
                       'mimeparse',
                       'haystack',
                       'psycopg2',
                      ]
        build_reqs_s = build_reqs.join("\n")

        build_req_options = ['--allow-unverified',
                             'django-evolution',
                             '--allow-unverified',
                             'djblets',
                            ]

        it { should contain_file('/foo/bar/puppet_build_requirements.txt').with({
                                                                                  :ensure  => 'present',
                                                                                  :mode    => '0644',
                                                                                  :content => build_reqs_s,
                                                                                  :require => 'Python_virtualenv[/foo/bar]',
                                                                                }) }

        it { should contain_python_package('/foo/bar,/foo/bar/puppet_build_requirements.txt').with({
                                                                                                     :ensure            => 'present',
                                                                                                     :python_prefix     => '/foo/bar',
                                                                                                     :requirements_file => '/foo/bar/puppet_build_requirements.txt',
                                                                                                     :options           => build_req_options,
                                                                                                     :require           => ['File[/foo/bar/puppet_build_requirements.txt]',
                                                                                                                            'Package[uglifyjs]',
                                                                                                                            'Package[gettext]',
                                                                                                                            'Python_package[/foo/bar,pip>=1.5.1]',
                                                                                                                           ]
                                                                                                   }) }

        it { should contain_python_package('/foo/bar,ReviewBoard').with({
                                                                          :ensure        => 'present',
                                                                          :python_prefix => '/foo/bar',
                                                                          :requirements  => 'ReviewBoard',
                                                                          :options       => install_opts,
                                                                          :require       => 'Python_package[/foo/bar,/foo/bar/puppet_build_requirements.txt]'
                                                                                })
        }
      end

      describe "class with specified base_venv on #{osfamily}" do
        let(:params) {{
            :base_venv => '/foo/bar'
        }}
        
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }

        it { should compile.with_all_deps }

        it { should contain_python_virtualenv('/foo/bar').with({
                                                                             :ensure     => 'present',
                                                                             :virtualenv => '/usr/bin/virtualenv-2.7',
                                                                             :python     => '/usr/bin/python2.7'
                                                                           })
        }

        it { should contain_python_package('/opt/reviewboard,ReviewBoard').with({
                                                                                  :ensure        => 'present',
                                                                                  :python_prefix => '/opt/reviewboard',
                                                                                  :requirements  => 'ReviewBoard',
                                                                                  :options       => install_opts,
                                                                                  :require       => 'Python_package[/opt/reviewboard,/opt/reviewboard/puppet_build_requirements.txt]'
                                                                                })
        }
      end
      describe "class with specified non-2.x version on #{osfamily}" do
        let(:params) {{ :version => '1.7.27'}}
        
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }

        it do
          expect {
            should contain_python_package('/opt/reviewboard,ReviewBoard==1.7.27')
          }.to raise_error(Puppet::Error, /reviewboard::package only supports ReviewBoard 2.x/)
        end
      end
    end
  end
end
