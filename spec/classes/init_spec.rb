require 'spec_helper'

describe 'reviewboard' do

  let :pre_condition do
    "package {'python-pip': ensure => present, }"
  end

  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      describe "class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }

        it { should compile.with_all_deps }

        it { should contain_class('reviewboard::package').with({
                                                                 :version           => nil,
                                                                 :venv_path         => '/opt/reviewboard',
                                                                 :venv_python       => '/usr/bin/python2.7',
                                                                 :virtualenv_script => '/usr/bin/virtualenv-2.7',
                                                                 :base_venv         => '/opt/empty_base_venv'
                                                               })
        }
      end
      describe "class with specified venv python and virtualenv_script on #{osfamily}" do
        let(:params) {{ :venv_python       => '/foo/bar',
                        :virtualenv_script => '/bar/baz' }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }

        it { should compile.with_all_deps }

        it { should contain_class('reviewboard::package').with({
                                                                 :version           => nil,
                                                                 :venv_path         => '/opt/reviewboard',
                                                                 :venv_python       => '/foo/bar',
                                                                 :virtualenv_script => '/bar/baz',
                                                                 :base_venv         => '/opt/empty_base_venv'
                                                               })
        }
      end

      describe "class with specified version on #{osfamily}" do
        let(:params) {{ :version => '2.0.2'}}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }

        it { should compile.with_all_deps }

        it { should contain_class('reviewboard::package').with({
                                                                 :version           => '2.0.2',
                                                                 :venv_path         => '/opt/reviewboard',
                                                                 :venv_python       => '/usr/bin/python2.7',
                                                                 :virtualenv_script => '/usr/bin/virtualenv-2.7',
                                                                 :base_venv         => '/opt/empty_base_venv'
                                                               })
        }
      end
    end
  end
end
