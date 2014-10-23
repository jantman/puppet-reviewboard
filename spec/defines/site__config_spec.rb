require 'spec_helper'

describe 'reviewboard::site::config', :type => :define do
  let(:title) { 'foo' }

  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      describe "on #{osfamily}" do
        let(:params) {{
            :site      => '/opt/reviewboard/site',
            :key       => 'foo',
            :value     => 'bar',
            :venv_path => '/opt/reviewboard',
        }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }
        let :pre_condition do
          <<-eos
          package {'python-pip': ensure => present, }
          class {'reviewboard': }
          reviewboard::provider::web {'/opt/reviewboard/site': vhost => 'foo', location => '/', webuser => 'apache', venv_path => '/opt/reviewboard', venv_python => '/usr/bin/python2.7', base_venv => '/opt/empty_base_venv', }
          eos
        end

        it { should compile.with_all_deps }

        it { should contain_class('reviewboard') }

        setcommand = "/opt/reviewboard/bin/rb-site manage /opt/reviewboard/site set-siteconfig -- --key 'foo' --value 'bar'"
        getcommand = "/opt/reviewboard/bin/rb-site manage /opt/reviewboard/site get-siteconfig -- --key 'foo' | grep '^bar$'"
        it { should contain_exec('rb-site /opt/reviewboard/site set foo=bar').with({
                                                                                     :command => setcommand,
                                                                                     :unless  => getcommand,
                                                                                     :require => 'Class[Reviewboard::Package]',
                                                                                     :notify  => 'Reviewboard::Provider::Web[/opt/reviewboard/site]'
                                                                                   })
        }
      end
      describe "handle alternate venv path on #{osfamily}" do
        let(:params) {{
            :site      => '/opt/reviewboard/site',
            :key       => 'foo',
            :value     => 'bar',
            :venv_path => '/foo/bar',
        }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }
        let :pre_condition do
          <<-eos
          package {'python-pip': ensure => present, }
          class {'reviewboard':
            venv_path => '/foo/bar',
          }
          reviewboard::provider::web {'/opt/reviewboard/site': vhost => 'foo', location => '/', webuser => 'apache', venv_path => '/foo/bar', venv_python => '/usr/bin/python2.7', base_venv => '/opt/empty_base_venv', }
          eos
        end

        it { should compile.with_all_deps }

        it { should contain_class('reviewboard') }

        setcommand = "/foo/bar/bin/rb-site manage /opt/reviewboard/site set-siteconfig -- --key 'foo' --value 'bar'"
        getcommand = "/foo/bar/bin/rb-site manage /opt/reviewboard/site get-siteconfig -- --key 'foo' | grep '^bar$'"
        it { should contain_exec('rb-site /opt/reviewboard/site set foo=bar').with({
                                                                                     :command => setcommand,
                                                                                     :unless  => getcommand,
                                                                                     :require => 'Class[Reviewboard::Package]',
                                                                                     :notify  => 'Reviewboard::Provider::Web[/opt/reviewboard/site]'
                                                                                   })
        }
      end
    end
  end
end
