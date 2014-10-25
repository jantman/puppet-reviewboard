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
        class {'reviewboard::rbtool': }
    EOS

    describe 'prerequisites' do
      it 'installs them' do
        # cleanup
        shell('rm -Rf /opt/reviewboard /opt/empty_base_venv /opt/otherrbvenv /tmp/thirdrbvenv /tmp/fourthrbvenv /tmp/basevenv')
        shell('yum -y install python-virtualenv python-pip')
        shell('su -l -c \'echo "DROP DATABASE IF EXISTS reviewboard;" | psql\' postgres')

        apply_manifest(pre, :catch_failures => true)
      end
    end

    describe 'manifest application' do
      it 'runs cleanly' do
        # run the code
        pp = <<-EOS.unindent
            #{pre}
            class {'apache':
              default_vhost => false,
            }
            class {'reviewboard':
              mod_wsgi_package_name => 'python27-mod_wsgi',
              mod_wsgi_so_name      => 'python27-mod_wsgi.so',
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
      # enable debug so we get more helpful diff output for HTTP errors
      describe 'enable django debug' do
        describe command('sed -i "s/DEBUG = False/DEBUG = True/" /opt/reviewboard/site/conf/settings_local.py && service httpd restart') do
          its(:exit_status) { should eq 0 }
        end
      end
    end

    context 'site on disk' do
      describe 'directory is created' do
        describe file('/opt/reviewboard/site') do
          it { should be_directory }
        end
      end

      describe 'configuration' do
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
    end

    describe 'apache' do
      describe service('httpd') do
        it { should be_enabled }
        it { should be_running }
      end
      describe port(80) do
        it { should be_listening }
      end
      describe 'mod_wsgi configuration' do
        describe file('/etc/httpd/conf.d/wsgi.conf') do
          it { should be_file }
          its(:content) { should match %r"WSGIPythonPath \"/opt/reviewboard/lib/python2.7/site-packages\"" }
          its(:content) { should match %r"WSGIPythonHome \"/opt/empty_base_venv\"" }
        end
        describe file('/etc/httpd/conf.d/wsgi.load') do
          it { should be_file }
          its(:content) { should match %r"LoadModule wsgi_module modules/python27-mod_wsgi.so" }
        end
        describe package('python27-mod_wsgi') do
          it { should be_installed }
        end
      end
    end

    context 'database' do
      describe 'exists' do
        describe command('su -l -c \'echo "SELECT 1;" | psql -d reviewboard\' postgres') do
          its(:exit_status) { should eq 0 }
        end
      end
      describe 'tables exist' do
        describe command('su -l -c \'echo "SELECT username FROM auth_user WHERE id=1;" | psql -d reviewboard\' postgres') do
          its(:exit_status) { should eq 0 }
          its(:stdout) { should match /admin/ }
        end
      end
    end

    context 'rbt' do
      describe 'command exists' do
        describe command('rbt --version') do
          its(:exit_status) { should eq 0 }
          its(:stderr) { should match /RBTools/ }
        end
      end
    end

    context 'application tests' do
      describe 'test prerequisites' do
        tests = <<-EOS.unindent
          python_virtualenv {'/tmp/rbtest': 
            ensure     => present,
            python     => $::python_latest_path,
          }

          # make sure we have an acceptably new pip
          python_package {'/tmp/rbtest,pip>=1.5.1':
            ensure        => present,
            python_prefix => '/tmp/rbtest',
            requirements  => 'pip>=1.5.1',
            options       => '--upgrade',
            require       => Python_virtualenv['/tmp/rbtest'],
          }

          python_package {'/tmp/rbtest,RBTools>=0.6.0':
            ensure        => present,
            python_prefix => '/tmp/rbtest',
            requirements  => 'RBTools>=0.6.0',
            options       => ['--allow-unverified', 'RBTools'],
            require       => Python_virtualenv['/tmp/rbtest'],
          }
        EOS

        # Apply twice to ensure no errors the second time.
        apply_manifest(tests, :catch_failures => true)
        shell('rm -f /root/.rbtools-cookies')
      end
      describe 'request for / works' do
        describe command('wget -O - http://localhost/') do
          its(:exit_status) { should eq 0 }
          its(:stdout) { should match /html/ }
        end
      end
      describe 'logging in' do
        describe command('/tmp/rbtest/bin/python /tmp/rb_test.py -a login') do
          its(:exit_status) { should eq 0 }
          its(:stdout) { should match /payload={u'stat': u'ok'/ }
        end
      end
      pending 'adding a repository' do
        # add /tmp/puppet-reviewboard repo
        # TODO - need to install git
      end
      pending 'posting a review' do
        # try to post a review
      end
      pending 'viewing a review' do
        # try to view the review
      end
      pending 'commenting on a review' do
        # try to comment on a review
      end
      pending 'uploading a file' do
        # try to upload a file
      end
    end
  end
  context 'with system python' do
    pending 'use system python' do
      # need to try this
    end
  end
end
