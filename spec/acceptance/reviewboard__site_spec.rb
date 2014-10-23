require 'spec_helper_acceptance'

describe 'reviewboard::site' do
  context "initial run with defaults" do
    # prereqs
    pre = <<-EOS.unindent
        class {'python::python27':}
        class {'postgresql::globals':
          version => '9.3',
        }
        class {'postgresql::server':
          version              => '9.3',
          initdb_path          => '/usr/pgsql-9.3/bin/initdb',
          package_name         => 'postgresql93-server',
          service_name         => 'postgresql-9.3',
          needs_initdb         => true,
          pg_hba_conf_path     => '/var/lib/pgsql/9.3/data/pg_hba.conf',
          datadir              => '/var/lib/pgsql/9.3/data',
          postgresql_conf_path => '/var/lib/pgsql/9.3/data/postgresql.conf',
          manage_firewall      => false,
        }
        class {'postgresql::client':
          package_name => 'postgresql93',
        }
        class {'postgresql::repo':
          version => '9.3',
        }
        class {'postgresql::lib::devel':
          package_name => 'postgresql93-devel',
        }
    EOS

    describe 'prerequisites' do
      it 'installs them' do
        # cleanup
        shell('rm -Rf /opt/reviewboard /opt/empty_base_venv /opt/otherrbvenv /tmp/thirdrbvenv /tmp/fourthrbvenv /tmp/basevenv')
        shell('yum -y install python-virtualenv')

        apply_manifest(pre, :catch_failures => true)
      end
    end

    describe 'manifest application' do
      it 'runs cleanly' do
        # run the code
        pp = <<-EOS.unindent
            #{pre}
            class {'reviewboard':
            }
            reviewboard::site { '/opt/reviewboard/site':
              dbpass     => 'rbdbpass',
              adminpass  => 'rbadminpass',
              adminemail => "root@${::fqdn}",
            }
        EOS

        # Apply twice to ensure no errors the second time.
        apply_manifest(pp, :catch_failures => true)
        expect(apply_manifest(pp, :catch_changes => true).exit_code).to be_zero
      end
    end

    describe 'site directory is created' do
      describe file('/opt/reviewboard/site') do
        it { should be_directory }
      end
    end

    describe 'site configuration' do
      describe file('/opt/reviewboard/site/conf/settings_local.py') do
        it { should be_file }
        it { should be_owned_by 'apache' }
        it { should be_grouped_into 'root' }
        it { should be_mode '600' }
        # DB config
        its(:content) { should match /'ENGINE': 'django.db.backends.postgresql_psycopg2'/ }
        its(:content) { should match /'NAME': 'reviewboard',/ }
        its(:content) { should match /'USER': 'reviewboard',/ }
        its(:content) { should match /'PASSWORD': 'rbdbpass',/ }
        its(:content) { should match /'HOST': 'localhost',/ }
        # cache config
        its(:content) { should match /'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',/ }
        its(:content) { should match /'LOCATION': 'localhost:11211',/ }
        its(:content) { should match /SITE_ROOT = '\/'/ }
        its(:content) { should match /DEBUG = False/ }
      end
    end

    describe 'upload directories' do
      describe file('/opt/reviewboard/site/data') do
        it { should be_directory }
        it { should be_owned_by 'apache' }
        it { should be_mode '755' }
      end

      describe file('/opt/reviewboard/site/htdocs/media/uploaded') do
        it { should be_directory }
        it { should be_owned_by 'apache' }
        it { should be_mode '755' }
      end
    end

    describe 'media' do
      describe file('/opt/reviewboard/site/htdocs/static/rb/js/admin.js') do
        it { should be_file }
      end
    end

    describe 'apache running' do
      describe service('httpd') do
        it { should be_enabled }
        it { should be_running }
      end
      describe port(80) do
        it { should be_listening }
      end
    end
  end
end
