require 'spec_helper'

default_version = '2.0.2'

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
                                                                         :python     => '/usr/bin/python2.7'
                                                                       })
        }

        it { should contain_python_package('/opt/reviewboard,ReviewBoard').with({
                                                                                  :ensure        => 'present',
                                                                                  :python_prefix => '/opt/reviewboard',
                                                                                  :requirements  => 'ReviewBoard',
                                                                                  :options       => ['--allow-external', 'ReviewBoard'],
                                                                                  :require       => ['Python_virtualenv[/opt/reviewboard]', 'Python_virtualenv[/opt/empty_base_venv]']
                                                                                })
        }
      end

      describe "class with specified version on #{osfamily}" do
        let(:params) {{ :version => '1.2.3'}}
        
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }

        it { should compile.with_all_deps }

        it { should contain_python_package('/opt/reviewboard,ReviewBoard==1.2.3').with({
                                                                                  :ensure        => 'present',
                                                                                  :python_prefix => '/opt/reviewboard',
                                                                                  :requirements  => 'ReviewBoard==1.2.3',
                                                                                  :options       => ['--allow-external', 'ReviewBoard'],
                                                                                  :require       => ['Python_virtualenv[/opt/reviewboard]', 'Python_virtualenv[/opt/empty_base_venv]']
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
                                                                         :python     => '/usr/bin/python2.7'
                                                                       })
        }

        it { should contain_python_package('/foo/bar,ReviewBoard').with({
                                                                                  :ensure        => 'present',
                                                                                  :python_prefix => '/foo/bar',
                                                                                  :requirements  => 'ReviewBoard',
                                                                                  :options       => ['--allow-external', 'ReviewBoard'],
                                                                                  :require       => ['Python_virtualenv[/foo/bar]', 'Python_virtualenv[/opt/empty_base_venv]']
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
                                                                                  :options       => ['--allow-external', 'ReviewBoard'],
                                                                                  :require       => ['Python_virtualenv[/opt/reviewboard]', 'Python_virtualenv[/foo/bar]']
                                                                                })
        }
      end
    end
  end
end
