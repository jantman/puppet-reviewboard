require 'spec_helper'

default_version = '2.0.2'

describe 'reviewboard' do

  let :pre_condition do
    "package {'python-pip': ensure => present, }"
  end

  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      describe "reviewboard class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { should compile.with_all_deps }

        it { should contain_class('reviewboard::package').with({
                                                                 :version     => default_version,
                                                                 :venv_path   => '/opt/reviewboard',
                                                                 :venv_python => '/usr/bin/python',
                                                                 :base_venv   => '/opt/empty_base_venv'
                                                               })
        }
      end
    end
  end
end
