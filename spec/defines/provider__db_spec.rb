require 'spec_helper'

describe 'reviewboard::provider::db', :type => :define do
  let(:title) { '/' }

  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      describe "without any parameters on #{osfamily}" do
        let(:params) {{
            :dbname => 'reviewboard',
            :dbhost => 'localhost',
            :dbuser => 'reviewboard',
            :dbpass => 'foo'
        }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }
        let :pre_condition do
          <<-eos
          package {'python-pip': ensure => present, }
          class {'reviewboard': }
          class {'postgresql::server': version => '9.3' }
          eos
        end

        it { should compile.with_all_deps }

        it { should_not contain_reviewboard__provider__db__puppetlabsmysql('/') }

        it { should contain_reviewboard__provider__db__puppetlabspostgresql('/').with({
                                                                                        :dbname => 'reviewboard',
                                                                                        :dbhost => 'localhost',
                                                                                        :dbuser => 'reviewboard',
                                                                                        :dbpass => 'foo'
                                                                                      })
        }
      end

      describe "with mysql dbprovider on #{osfamily}" do
        let(:params) {{
            :dbname => 'reviewboard',
            :dbhost => 'localhost',
            :dbuser => 'reviewboard',
            :dbpass => 'foo'
        }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }
        let :pre_condition do
          <<-eos
          package {'python-pip': ensure => present, }
          class {'reviewboard': dbprovider => 'puppetlabs/mysql',}
          class {'postgresql::server': version => '9.3' }
          eos
        end

        it { should compile.with_all_deps }

        it { should_not contain_reviewboard__provider__db__puppetlabspostgresql('/') }

        it { should contain_reviewboard__provider__db__puppetlabsmysql('/').with({
                                                                                   :dbname => 'reviewboard',
                                                                                   :dbhost => 'localhost',
                                                                                   :dbuser => 'reviewboard',
                                                                                   :dbpass => 'foo'
                                                                                 })
        }
      end

      describe "with none dbprovider on #{osfamily}" do
        let(:params) {{
            :dbname => 'reviewboard',
            :dbhost => 'localhost',
            :dbuser => 'reviewboard',
            :dbpass => 'foo'
        }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }
        let :pre_condition do
          <<-eos
          package {'python-pip': ensure => present, }
          class {'reviewboard': dbprovider => 'none',}
          class {'postgresql::server': version => '9.3' }
          eos
        end

        it { should compile.with_all_deps }

        it { should_not contain_reviewboard__provider__db__puppetlabsmysql('/') }
        it { should_not contain_reviewboard__provider__db__puppetlabspostgresql('/') }
      end

      describe "with other/invalid dbprovider on #{osfamily}" do
        let(:params) {{
            :dbname => 'reviewboard',
            :dbhost => 'localhost',
            :dbuser => 'reviewboard',
            :dbpass => 'foo'
        }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }
        let :pre_condition do
          <<-eos
          package {'python-pip': ensure => present, }
          class {'reviewboard': dbprovider => 'invaild',}
          class {'postgresql::server': version => '9.3' }
          eos
        end

        it do
          expect {
            should contain_reviewboard__provider__web('sitename')
          }.to raise_error(Puppet::Error, /DB provider 'invaild' not defined/)
        end
      end
    end
  end
end
