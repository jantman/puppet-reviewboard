require 'spec_helper'

describe 'reviewboard::provider::web::puppetlabsapache', :type => :define do
  let(:title) { '/sitename' }

  let :pre_condition do
    "package {'python-pip': ensure => present, }"
  end

  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      describe "with example parameters on #{osfamily}" do
        let(:params) {{
            :vhost    => 'fqdn.example.com',
            :location => '/',
        }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }
        let :pre_condition do
          <<-eos
          package {'python-pip': ensure => present, }
          class {'reviewboard': }
          class {'apache': }
          class {'postgresql::server': version => '9.3' }
          eos
        end

        it { should compile.with_all_deps }

        it { should contain_class('Apache::Mod::Wsgi') }
        it { should contain_class('Apache::Mod::Mime') }

        error_docs = [{'error_code' => '500', 'document' => '/errordocs/500.html'}]
        wsgi_aliases = {"/" => "/sitename/htdocs/reviewboard.wsgi"}
        directories = ''
        aliases = ''
        it { should contain_apache__vhost('fqdn.example.com').with({
                                                                     :port                => 80,
                                                                     :docroot             => '/sitename/htdocs',
                                                                     :error_documents     => error_docs,
                                                                     :wsgi_script_aliases => wsgi_aliases,
                                                                     :custom_fragment     => 'WSGIPassAuthorization On',
                                                                     :directories         => directories,
                                                                     :aliases             => aliases,
                                                                   }) }

        it { should contain_exec('Update /sitename').with({
                                                            :command     => '/bin/true',
                                                            :refreshonly => true,
                                                            :notify      => 'Class[Apache::Service]',
                                                            }) }

      end
    end
  end
end
