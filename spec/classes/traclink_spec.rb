require 'spec_helper'

describe 'reviewboard::traclink' do

  let :pre_condition do
    <<-eos
    package {'python-pip': ensure => present, }
    package {'trac': ensure => present, }
    class {'reviewboard': }
    eos
  end

  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      describe "without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }

        it { should compile.with_all_deps }

        it { should contain_package('traclink').with({
                                                       :provider => 'pip',
                                                       :source => 'git+https://github.com/ScottWales/reviewboard-trac-link',
                                                       :require => ['Class[Reviewboard::Package]', 'Package[trac]']
                                                       })
        }

        it { should create_class('reviewboard::package') }
      end
      describe "notify web provider" do
        let(:params) {{ }}
        let(:pre_condition) { [ "class {'reviewboard': }",
                                "reviewboard::provider::web {'/foo': vhost => 'foo', location => '/', webuser => 'bar', venv_path => '/opt/reviewboard', venv_python => '/usr/bin/python2.7', base_venv => '/opt/empty_base_venv', }",
                                "package {'trac': }"] }
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }

        it { should compile.with_all_deps }

        it { should contain_package('traclink').that_notifies('Reviewboard::Provider::Web[/foo]') }
      end
    end
  end
end
