require 'spec_helper'

describe 'reviewboard::site::config', :type => :define do
  let(:title) { 'foo' }

  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      describe "on #{osfamily}" do
        let(:params) {{
            :site   => '/opt/reviewboard/site',
            :key    => 'foo',
            :value  => 'bar'
        }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }
        let :pre_condition do
          <<-eos
          package {'python-pip': ensure => present, }
          class {'reviewboard': }
          reviewboard::provider::web {'/opt/reviewboard/site': vhost => 'foo', location => '/', webuser => 'apache' }
          eos
        end

        it { should compile.with_all_deps }

        setcommand = "rb-site manage /opt/reviewboard/site set-siteconfig -- --key 'foo' --value 'bar'"
        getcommand = "rb-site manage /opt/reviewboard/site get-siteconfig -- --key 'foo' | grep '^bar$'"
        it { should contain_exec('rb-site /opt/reviewboard/site set foo=bar').with({
                                                                                     :command => setcommand,
                                                                                     :unless  => getcommand,
                                                                                     :path    => ['/bin', '/usr/bin'],
                                                                                     :require => 'Class[Reviewboard::Package]',
                                                                                     :notify  => 'Reviewboard::Provider::Web[/opt/reviewboard/site]'
                                                                                   })
        }
      end
    end
  end
end
