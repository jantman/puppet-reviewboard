require 'spec_helper'

default_version = '2.0.2'

describe 'reviewboard::package' do

  let :pre_condition do
    "package {'python-pip': ensure => present, }"
  end

  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      describe "reviewboard::package class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        
        let(:facts) {{
            :osfamily          => 'RedHat',
            :virtualenv27_path => '/usr/bin/virtualenv-2.7'
          }}

        it { should compile.with_all_deps }

        it { should contain_python_virtualenv('/opt/empty_base_venv').with({
                                                                             :ensure     => 'present',
                                                                             :virtualenv => '/usr/bin/virtualenv-2.7'
                                                                           })
        }

        it { should contain_python_virtualenv('/opt/reviewboard').with({
                                                                         :ensure     => 'present',
                                                                         :virtualenv => '/usr/bin/virtualenv-2.7'
                                                                       })
        }

        it { should contain_python_package('/opt/reviewboard,ReviewBoard').with({
                                                                                  :ensure        => 'present',
                                                                                  :python_prefix => '/opt/reviewboard',
                                                                                  :requirements  => 'ReviewBoard',
                                                                                  :require       => ['Python_virtualenv[/opt/reviewboard]', 'Python_virtualenv[/opt/empty_base_venv]']
                                                                                })
        }
      end
    end
  end
end
