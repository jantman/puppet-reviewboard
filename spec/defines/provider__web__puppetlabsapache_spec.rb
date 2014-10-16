require 'spec_helper'

describe 'reviewboard::provider::web::puppetlabsapache', :type => :define do
  let(:title) { '/sitename' }

  let :pre_condition do
    "package {'python-pip': ensure => present, }"
  end

  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      describe "with example parameters and location / on #{osfamily}" do
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

        # these need to be ruby-ized (or, un-dsl-ized)
        error_docs = [['error_code', '500'], ['document', '/errordocs/500.html']]
        wsgi_aliases = {"/" => "/sitename/htdocs/reviewboard.wsgi"}
        directories = [
                       {'path'   => "/sitename/htdocs",
                         'options' => ['-Indexes','+FollowSymLinks']
                       },
                       {'path'           => "/media/uploaded",
                         'provider'        => 'location',
                         'custom_fragment' => '
      SetHandler None
      Options None

      AddType text/plain .html .htm .shtml .php .php3 .php4 .php5 .phps .asp
      AddType text/plain .pl .py .fcgi .cgi .phtml .phtm .pht .jsp .sh .rb

      <IfModule mod_php5.c>
        php_flag engine off
      </IfModule>
    '}
                      ]
        aliases = [
                   {'alias' => "/media",
                     'path' => "/sitename/htdocs/media"
                   },
                   {'alias' => "/static",
                     'path' => "/sitename/htdocs/static"
                   },
                   {'alias' => "/errordocs",
                     'path' => "/sitename/htdocs/errordocs"
                   },
                   {'alias' => "/favicon.ico",
                     'path' => "/sitename/htdocs/static/rb/images/favicon.png"
                   },
                  ]
        # using one statement for all these complex params is too confusing when one errors
        it { should contain_apache__vhost('fqdn.example.com').with({
                                                                     :port                => 80,
                                                                     :docroot             => '/sitename/htdocs',
                                                                     :custom_fragment     => 'WSGIPassAuthorization On',
                                                                   }) }
        it { should contain_apache__vhost('fqdn.example.com').with_error_documents(error_docs) }
        it { should contain_apache__vhost('fqdn.example.com').with_wsgi_script_aliases(wsgi_aliases) }
        it { should contain_apache__vhost('fqdn.example.com').with_directories(directories) }
        it { should contain_apache__vhost('fqdn.example.com').with_aliases(aliases) }

        it { should contain_exec('Update /sitename').with({
                                                            :command     => '/bin/true',
                                                            :refreshonly => true,
                                                            :notify      => 'Class[Apache::Service]',
                                                            }) }

      end
      describe "with locatin /reviewboard on #{osfamily}" do
        let(:params) {{
            :vhost    => 'fqdn.example.com',
            :location => '/reviewboard',
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

        # these need to be ruby-ized (or, un-dsl-ized)
        error_docs = [['error_code', '500'], ['document', '/errordocs/500.html']]
        wsgi_aliases = {"/reviewboard" => "/sitename/htdocs/reviewboard.wsgi/reviewboard"}
        directories = [
                       {'path'   => "/sitename/htdocs",
                         'options' => ['-Indexes','+FollowSymLinks']
                       },
                       {'path'           => "/reviewboard/media/uploaded",
                         'provider'        => 'location',
                         'custom_fragment' => '
      SetHandler None
      Options None

      AddType text/plain .html .htm .shtml .php .php3 .php4 .php5 .phps .asp
      AddType text/plain .pl .py .fcgi .cgi .phtml .phtm .pht .jsp .sh .rb

      <IfModule mod_php5.c>
        php_flag engine off
      </IfModule>
    '}
                      ]
        aliases = [
                   {'alias' => "/reviewboard/media",
                     'path' => "/sitename/htdocs/media"
                   },
                   {'alias' => "/reviewboard/static",
                     'path' => "/sitename/htdocs/static"
                   },
                   {'alias' => "/reviewboard/errordocs",
                     'path' => "/sitename/htdocs/errordocs"
                   },
                   {'alias' => "/reviewboard/favicon.ico",
                     'path' => "/sitename/htdocs/static/rb/images/favicon.png"
                   },
                  ]
        # using one statement for all these complex params is too confusing when one errors
        it { should contain_apache__vhost('fqdn.example.com').with({
                                                                     :port                => 80,
                                                                     :docroot             => '/sitename/htdocs',
                                                                     :custom_fragment     => 'WSGIPassAuthorization On',
                                                                   }) }
        it { should contain_apache__vhost('fqdn.example.com').with_error_documents(error_docs) }
        it { should contain_apache__vhost('fqdn.example.com').with_wsgi_script_aliases(wsgi_aliases) }
        it { should contain_apache__vhost('fqdn.example.com').with_directories(directories) }
        it { should contain_apache__vhost('fqdn.example.com').with_aliases(aliases) }

        it { should contain_exec('Update /sitename').with({
                                                            :command     => '/bin/true',
                                                            :refreshonly => true,
                                                            :notify      => 'Class[Apache::Service]',
                                                            }) }

      end
    end
  end
end
