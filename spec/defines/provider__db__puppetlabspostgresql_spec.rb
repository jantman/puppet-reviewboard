require 'spec_helper'

describe 'reviewboard::provider::db::puppetlabspostgresql', :type => :define do
  let(:title) { '/sitename' }

  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      describe "with example parameters on #{osfamily}" do
        let(:params) {{
            :dbname => 'reviewboard',
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

        it { should contain_class('Postgresql::Lib::Python') }

        it { should contain_postgresql__server__db('reviewboard').with({
                                                                         :user     => 'reviewboard',
                                                                         # see the postgresql_password function
                                                                         :password => 'md5ebc70987a8848e0292375d06496d2bb2'
                                                                       })
        }
      end

      describe "with non-localhost dbhost on #{osfamily}" do
        let(:params) {{
            :dbhost => 'otherhost',
            :dbname => 'reviewboard',
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
            should contain_postgresql__server__db('reviewboard')
          }.to raise_error(Puppet::Error, /Remote db hosts not implemented/)
        end
      end
    end
  end
end
