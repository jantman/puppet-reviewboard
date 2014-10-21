require 'spec_helper_acceptance'

describe 'reviewboard::site' do
  context "initial run with defaults" do
    it 'runs cleanly' do
      # cleanup
      shell('rm -Rf /opt/reviewboard /opt/empty_base_venv /opt/otherrbvenv /tmp/thirdrbvenv /tmp/fourthrbvenv /tmp/basevenv')
      shell('yum -y install python-virtualenv')

      # prereqs
      pp = <<-EOS.unindent
          class {'python::python27':}
      EOS
      apply_manifest(pp, :catch_failures => true)

      # run the code
      pp = <<-EOS.unindent
          class {'python::python27':}
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

    describe 'site directory is created' do
      describe file('/opt/reviewboard/site') do
        it { should be_directory }
      end
    end

  end
end
