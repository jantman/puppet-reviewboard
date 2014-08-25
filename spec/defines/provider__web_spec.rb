require 'spec_helper'

describe 'reviewboard::provider::web', :type => :define do
  let(:title) { '/reviewboard' }

  let :pre_condition do
    <<-eos
    package {'python-pip': ensure => present, }
    class {'reviewboard': }
    eos
  end

  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      describe "reviewboard::provider::web class without any parameters on #{osfamily}" do
        let(:params) {{
            :vhost    => 'fqdn.example.com',
            :location => '/reviewboard',
            :webuser  => 'apache'
        }}
        let(:facts) {{
          :osfamily => osfamily,
          :operatingsystem => 'CentOS',
          :operatingsystemmajrelease => '6',
          :operatingsystemrelease => '6.5',
          :concat_basedir => '/var/lib/puppet/concat',
          :fqdn           => 'fqdn.example.com'
        }}

        it { should compile.with_all_deps }

        it { should contain_reviewboard__provider__web__puppetlabsapache('/reviewboard').with({
                                                                                                :vhost    => 'fqdn.example.com',
                                                                                                :location => '/reviewboard'
                                                                                              })
        }

        ['/reviewboard/data', '/reviewboard/htdocs/media', '/reviewboard/htdocs/media/ext'].each do |f|
          it { should contain_file(f).with({
                                             :ensure  => 'directory',
                                             :owner   => 'apache',
                                             :notify  => 'Class[Apache::Service]',
                                             :recurse => true
                                             })
          }
        end

        it { should contain_file('/reviewboard/conf').with({
                                                             :ensure  => 'directory',
                                                             :owner   => 'apache',
                                                             :recurse => true,
                                                             :mode    => 'go-rwx'
                                                             })
        }
      end
    end
  end
end
