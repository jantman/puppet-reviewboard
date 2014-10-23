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

  end
end
