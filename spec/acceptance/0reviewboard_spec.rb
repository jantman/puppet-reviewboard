# this spec MUST run first
require 'spec_helper_acceptance'

describe 'reviewboard' do
  context "initial run with defaults" do
    it 'runs cleanly' do
      # cleanup
      shell('rm -Rf /opt/reviewboard /opt/empty_base_venv /opt/otherrbvenv /tmp/thirdrbvenv /tmp/fourthrbvenv /tmp/basevenv')

      # prerequisites
      pre = <<-EOS.unindent
        class {'python::python27':}
        class {'postgresql::globals':
          version => '9.3',
        }
        class {'postgresql::repo':
          version => '9.3',
        } ->
        class {'postgresql::server':
          version              => '9.3',
          initdb_path          => '/usr/pgsql-9.3/bin/initdb',
          package_name         => 'postgresql93-server',
          service_name         => 'postgresql-9.3',
          needs_initdb         => true,
          pg_hba_conf_path     => '/var/lib/pgsql/9.3/data/pg_hba.conf',
          datadir              => '/var/lib/pgsql/9.3/data',
          postgresql_conf_path => '/var/lib/pgsql/9.3/data/postgresql.conf',
        }
        class {'postgresql::client':
          package_name => 'postgresql93',
        }
        class {'postgresql::lib::devel':
          package_name => 'postgresql93-devel',
        }
      EOS
      apply_manifest(pre, :catch_failures => true)

      pp = <<-EOS.unindent
          #{pre}
          class {'reviewboard':}
      EOS

      # Apply twice to ensure no errors the second time.
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_changes => true).exit_code).to be_zero
    end

    describe 'installs OS package' do
      describe command('which msgfmt') do
        its(:exit_status) { should eq 0 }
      end

      describe command('which uglifyjs') do
        its(:exit_status) { should eq 0 }
      end
    end

    describe 'creates venv in the correct paths, using the correct python' do
      describe file('/opt/reviewboard') do
        it { should be_directory }
      end

      describe file('/opt/reviewboard/bin/python') do
        it { should be_executable }
      end

      describe command('/opt/reviewboard/bin/python --version') do
        its(:stderr) { should match /Python 2\.7\.8/ }
      end

      describe command('/opt/reviewboard/bin/pip freeze') do
        its(:stdout) { should match /Django==1\.6/ }
        its(:stdout) { should match /django-pipeline/ }
        its(:stdout) { should match /Djblets/ }
        its(:stdout) { should match /django-evolution/ }
        its(:stdout) { should match /Pygments/ }
        its(:stdout) { should match /docutils/ }
        its(:stdout) { should match /Markdown/ }
        its(:stdout) { should match /paramiko/ }
        its(:stdout) { should match /mimeparse/ }
        its(:stdout) { should match /haystack/ }
        its(:stdout) { should match /ReviewBoard/ }
      end
    end

    describe 'empty base venv' do
      describe file('/opt/empty_base_venv') do
        it { should be_directory }
      end

      describe file('/opt/empty_base_venv/bin/python') do
        it { should be_executable }
      end

      describe command('/opt/empty_base_venv/bin/python --version') do
        its(:stderr) { should match /Python 2\.7\.8/ }
      end

      describe command('/opt/empty_base_venv/bin/pip freeze') do
        its(:stdout) { should match /^wsgiref==0\.1\.2$/m }
      end
    end
  end

  context "install in alternate venv path" do
    it 'runs cleanly' do
      # cleanup
      shell('rm -Rf /opt/reviewboard /opt/empty_base_venv /opt/otherrbvenv /tmp/thirdrbvenv /tmp/fourthrbvenv /tmp/basevenv')

      # prerequisites
      pp = <<-EOS.unindent
          class {'python::python27':}
      EOS
      apply_manifest(pp, :catch_failures => true)

      pp = <<-EOS.unindent
          class {'reviewboard':
            venv_path => '/tmp/otherrbvenv',
          }
      EOS

      # Apply twice to ensure no errors the second time.
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_changes => true).exit_code).to be_zero
    end

    describe 'installs OS package' do
      describe command('which msgfmt') do
        its(:exit_status) { should eq 0 }
      end

      describe command('which uglifyjs') do
        its(:exit_status) { should eq 0 }
      end
    end

    describe 'default venv not present' do
      describe file('/opt/reviewboard') do
        it { should_not be_directory }
      end
    end

    describe 'creates venv in the correct paths, using the correct python' do
      describe file('/tmp/otherrbvenv') do
        it { should be_directory }
      end

      describe file('/tmp/otherrbvenv/bin/python') do
        it { should be_executable }
      end

      describe command('/tmp/otherrbvenv/bin/python --version') do
        its(:stderr) { should match /Python 2\.7\.8/ }
      end

      describe command('/tmp/otherrbvenv/bin/pip freeze') do
        its(:stdout) { should match /Django==1\.6/ }
        its(:stdout) { should match /django-pipeline/ }
        its(:stdout) { should match /Djblets/ }
        its(:stdout) { should match /django-evolution/ }
        its(:stdout) { should match /Pygments/ }
        its(:stdout) { should match /docutils/ }
        its(:stdout) { should match /Markdown/ }
        its(:stdout) { should match /paramiko/ }
        its(:stdout) { should match /mimeparse/ }
        its(:stdout) { should match /haystack/ }
        its(:stdout) { should match /ReviewBoard/ }
      end
    end

    describe 'empty base venv' do
      describe file('/opt/empty_base_venv') do
        it { should be_directory }
      end

      describe file('/opt/empty_base_venv/bin/python') do
        it { should be_executable }
      end

      describe command('/opt/empty_base_venv/bin/python --version') do
        its(:stderr) { should match /Python 2\.7\.8/ }
      end

      describe command('/opt/empty_base_venv/bin/pip freeze') do
        its(:stdout) { should match /^wsgiref==0\.1\.2$/m }
      end
    end
  end

  context "alternate venv path and python version" do
    it 'runs cleanly' do
      # cleanup
      shell('rm -Rf /opt/reviewboard /opt/empty_base_venv /opt/otherrbvenv /tmp/thirdrbvenv /tmp/fourthrbvenv /tmp/basevenv')
      shell('yum -y install python-virtualenv')

      pp = <<-EOS.unindent
          class {'reviewboard':
            venv_path         => '/tmp/thirdrbvenv',
            venv_python       => '/usr/bin/python',
            virtualenv_script => '/usr/bin/virtualenv',
          }
      EOS

      # NOTE - ReviewBoard will NOT install under python 2.6;
      # this is just here to test the alternate venv/python parts, not RB itself
      # Apply twice to ensure no errors the second time.
      apply_manifest(pp)
    end

    describe 'installs OS package' do
      describe command('which msgfmt') do
        its(:exit_status) { should eq 0 }
      end

      describe command('which uglifyjs') do
        its(:exit_status) { should eq 0 }
      end
    end

    describe 'default venv not present' do
      describe file('/opt/reviewboard') do
        it { should_not be_directory }
      end
    end

    describe 'creates venv in the correct paths, using the correct python' do
      describe file('/tmp/thirdrbvenv') do
        it { should be_directory }
      end

      describe file('/tmp/thirdrbvenv/bin/python') do
        it { should be_executable }
      end

      describe command('/tmp/thirdrbvenv/bin/python --version') do
        its(:stderr) { should match /Python 2\.6/ }
      end

      describe command('/tmp/thirdrbvenv/bin/pip freeze') do
        its(:stdout) { should match /Django==1\.6/ }
        its(:stdout) { should match /django-pipeline/ }
        its(:stdout) { should match /Djblets/ }
        its(:stdout) { should match /django-evolution/ }
        its(:stdout) { should match /Pygments/ }
        its(:stdout) { should match /docutils/ }
        its(:stdout) { should match /Markdown/ }
        its(:stdout) { should match /paramiko/ }
        its(:stdout) { should match /mimeparse/ }
        its(:stdout) { should match /haystack/ }
      end
    end

    describe 'empty base venv' do
      describe file('/opt/empty_base_venv') do
        it { should be_directory }
      end

      describe file('/opt/empty_base_venv/bin/python') do
        it { should be_executable }
      end

      describe command('/opt/empty_base_venv/bin/python --version') do
        its(:stderr) { should match /Python 2\.6/ }
      end

      # 2.6 virtualenv doesn't have wsgiref, apparently
      describe command('/opt/empty_base_venv/bin/pip freeze') do
        its(:stdout) { should match // }
      end
    end
  end

  context "alternate base venv path" do
    it 'runs cleanly' do
      # cleanup
      shell('rm -Rf /opt/reviewboard /opt/empty_base_venv /opt/otherrbvenv /tmp/thirdrbvenv /tmp/fourthrbvenv /tmp/basevenv')

      # prerequisites
      pp = <<-EOS.unindent
          class {'python::python27':}
      EOS
      apply_manifest(pp, :catch_failures => true)

      pp = <<-EOS.unindent
          class {'reviewboard':
            venv_path => '/tmp/fourthrbvenv',
            base_venv => '/tmp/basevenv',
          }
      EOS

      # Apply twice to ensure no errors the second time.
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_changes => true).exit_code).to be_zero
    end

    describe 'installs OS package' do
      describe command('which msgfmt') do
        its(:exit_status) { should eq 0 }
      end

      describe command('which uglifyjs') do
        its(:exit_status) { should eq 0 }
      end
    end

    describe 'default venv not present' do
      describe file('/opt/reviewboard') do
        it { should_not be_directory }
      end
    end

    describe 'creates venv in the correct paths, using the correct python' do
      describe file('/tmp/fourthrbvenv') do
        it { should be_directory }
      end

      describe file('/tmp/fourthrbvenv/bin/python') do
        it { should be_executable }
      end

      describe command('/tmp/fourthrbvenv/bin/python --version') do
        its(:stderr) { should match /Python 2\.7\.8/ }
      end

      describe command('/tmp/fourthrbvenv/bin/pip freeze') do
        its(:stdout) { should match /Django==1\.6/ }
        its(:stdout) { should match /django-pipeline/ }
        its(:stdout) { should match /Djblets/ }
        its(:stdout) { should match /django-evolution/ }
        its(:stdout) { should match /Pygments/ }
        its(:stdout) { should match /docutils/ }
        its(:stdout) { should match /Markdown/ }
        its(:stdout) { should match /paramiko/ }
        its(:stdout) { should match /mimeparse/ }
        its(:stdout) { should match /haystack/ }
        its(:stdout) { should match /ReviewBoard/ }
      end
    end

    describe 'empty base venv' do
      describe file('/opt/empty_base_venv') do
        it { should_not be_directory }
      end

      describe file('/tmp/basevenv') do
        it { should be_directory }
      end

      describe file('/tmp/basevenv/bin/python') do
        it { should be_executable }
      end

      describe command('/tmp/basevenv/bin/python --version') do
        its(:stderr) { should match /Python 2\.7\.8/ }
      end

      describe command('/tmp/basevenv/bin/pip freeze') do
        its(:stdout) { should match /^wsgiref==0\.1\.2$/m }
      end
    end
  end

  context "initial run with specified older version" do
    it 'runs cleanly' do
      # cleanup
      shell('rm -Rf /opt/reviewboard /opt/empty_base_venv /opt/otherrbvenv /tmp/thirdrbvenv /tmp/fourthrbvenv /tmp/basevenv')

      # prerequisites
      pp = <<-EOS.unindent
          class {'python::python27':}
      EOS
      apply_manifest(pp, :catch_failures => true)

      pp = <<-EOS.unindent
          class {'reviewboard': version => '2.0.3', }
      EOS

      # Apply twice to ensure no errors the second time.
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_changes => true).exit_code).to be_zero
    end

    describe 'installs OS package' do
      describe command('which msgfmt') do
        its(:exit_status) { should eq 0 }
      end

      describe command('which uglifyjs') do
        its(:exit_status) { should eq 0 }
      end
    end

    describe 'creates venv in the correct paths, using the correct python' do
      describe file('/opt/reviewboard') do
        it { should be_directory }
      end

      describe file('/opt/reviewboard/bin/python') do
        it { should be_executable }
      end

      describe command('/opt/reviewboard/bin/python --version') do
        its(:stderr) { should match /Python 2\.7\.8/ }
      end

      describe command('/opt/reviewboard/bin/pip freeze') do
        its(:stdout) { should match /Django==1\.6/ }
        its(:stdout) { should match /django-pipeline/ }
        its(:stdout) { should match /Djblets/ }
        its(:stdout) { should match /django-evolution/ }
        its(:stdout) { should match /Pygments/ }
        its(:stdout) { should match /docutils/ }
        its(:stdout) { should match /Markdown/ }
        its(:stdout) { should match /paramiko/ }
        its(:stdout) { should match /mimeparse/ }
        its(:stdout) { should match /haystack/ }
        its(:stdout) { should match /ReviewBoard==2\.0\.3/ }
      end
    end

    describe 'empty base venv' do
      describe file('/opt/empty_base_venv') do
        it { should be_directory }
      end

      describe file('/opt/empty_base_venv/bin/python') do
        it { should be_executable }
      end

      describe command('/opt/empty_base_venv/bin/python --version') do
        its(:stderr) { should match /Python 2\.7\.8/ }
      end

      describe command('/opt/empty_base_venv/bin/pip freeze') do
        its(:stdout) { should match /^wsgiref==0\.1\.2$/m }
      end
    end
  end

  context "second run updating version" do
    it 'runs cleanly' do
      # cleanup
      shell('rm -Rf /opt/otherrbvenv /tmp/thirdrbvenv /tmp/fourthrbvenv /tmp/basevenv')

      # prerequisites
      pp = <<-EOS.unindent
          class {'python::python27':}
      EOS
      apply_manifest(pp, :catch_failures => true)

      pp = <<-EOS.unindent
          class {'reviewboard': version => '2.0.8', }
      EOS

      # Apply twice to ensure no errors the second time.
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_changes => true).exit_code).to be_zero
    end

    describe 'installs OS package' do
      describe command('which msgfmt') do
        its(:exit_status) { should eq 0 }
      end

      describe command('which uglifyjs') do
        its(:exit_status) { should eq 0 }
      end
    end

    describe 'creates venv in the correct paths, using the correct python' do
      describe file('/opt/reviewboard') do
        it { should be_directory }
      end

      describe file('/opt/reviewboard/bin/python') do
        it { should be_executable }
      end

      describe command('/opt/reviewboard/bin/python --version') do
        its(:stderr) { should match /Python 2\.7\.8/ }
      end

      describe command('/opt/reviewboard/bin/pip freeze') do
        its(:stdout) { should match /Django==1\.6/ }
        its(:stdout) { should match /django-pipeline/ }
        its(:stdout) { should match /Djblets/ }
        its(:stdout) { should match /django-evolution/ }
        its(:stdout) { should match /Pygments/ }
        its(:stdout) { should match /docutils/ }
        its(:stdout) { should match /Markdown/ }
        its(:stdout) { should match /paramiko/ }
        its(:stdout) { should match /mimeparse/ }
        its(:stdout) { should match /haystack/ }
        its(:stdout) { should match /ReviewBoard==2\.0\.8/ }
      end
    end

    describe 'empty base venv' do
      describe file('/opt/empty_base_venv') do
        it { should be_directory }
      end

      describe file('/opt/empty_base_venv/bin/python') do
        it { should be_executable }
      end

      describe command('/opt/empty_base_venv/bin/python --version') do
        its(:stderr) { should match /Python 2\.7\.8/ }
      end

      describe command('/opt/empty_base_venv/bin/pip freeze') do
        its(:stdout) { should match /^wsgiref==0\.1\.2$/m }
      end
    end
  end
end
