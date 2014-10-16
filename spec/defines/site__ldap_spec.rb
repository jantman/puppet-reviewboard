require 'spec_helper'

describe 'reviewboard::site::ldap', :type => :define do

  context 'supported operating systems' do

    ['RedHat'].each do |osfamily|
      describe "with example params on #{osfamily}" do
        let(:title) { '/sitename' }
        let(:params) {{
            :uri        => 'ldap://foo.example.com:389',
            :basedn     => 'ou=people,dc=example,dc=com'
        }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }
        let :pre_condition do
          <<-eos
          package {'python-pip': ensure => present, }
          class {'reviewboard': webuser => 'apache' }
          reviewboard::site {'/sitename': dbpass => 'foo', adminpass => 'bar' }
          class {'postgresql::server': version => '9.3' }
          eos
        end

        it { should compile.with_all_deps }

        it { should contain_reviewboard__site__config('/sitename ldap enable').with({
                                                                                     :site    => '/sitename',
                                                                                     :require => 'Reviewboard::Site::Install[/sitename]',
                                                                                     :key     => 'auth_backend',
                                                                                     :value   => 'ldap',
                                                                                   }) }

        it { should contain_reviewboard__site__config('/sitename ldap uri').with({
                                                                                  :site    => '/sitename',
                                                                                  :require => 'Reviewboard::Site::Install[/sitename]',
                                                                                  :key     => 'auth_ldap_uri',
                                                                                  :value   => 'ldap://foo.example.com:389',
                                                                                }) }

        it { should contain_reviewboard__site__config('/sitename ldap basedn').with({
                                                                                     :site    => '/sitename',
                                                                                     :require => 'Reviewboard::Site::Install[/sitename]',
                                                                                     :key     => 'auth_ldap_base_dn',
                                                                                     :value   => 'ou=people,dc=example,dc=com',
                                                                                   }) }

        it { should contain_reviewboard__site__config('/sitename ldap mask').with({
                                                                                   :site    => '/sitename',
                                                                                   :require => 'Reviewboard::Site::Install[/sitename]',
                                                                                   :key     => 'auth_ldap_uid_mask',
                                                                                   :value   => '(uid=%s)',
                                                                                 }) }

        it { should_not contain_reviewboard__site__config('/sitename ldap email domain') }
      end
      describe "with specified emaildomain" do
        let(:title) { '/sitename' }
        let(:params) {{
            :uri         => 'ldap://foo.example.com:389',
            :basedn      => 'ou=people,dc=example,dc=com',
            :emaildomain => 'mycompany.org',
        }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }
        let :pre_condition do
          <<-eos
          package {'python-pip': ensure => present, }
          class {'reviewboard': webuser => 'apache' }
          reviewboard::site {'/sitename': dbpass => 'foo', adminpass => 'bar' }
          class {'postgresql::server': version => '9.3' }
          eos
        end

        it { should compile.with_all_deps }

        it { should contain_reviewboard__site__config('/sitename ldap email domain').with({
                                                                                           :site    => '/sitename',
                                                                                           :require => 'Reviewboard::Site::Install[/sitename]',
                                                                                           :key     => 'auth_ldap_email_domain',
                                                                                           :value   => 'mycompany.org',
                                                                                         }) }
      end
      pending "with specified usermask" do
        # specify usermask param
      end
      pending "with specified site" do
        # specify site other than namevar
      end
    end
  end
end
