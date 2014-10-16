require 'spec_helper_acceptance'

describe 'reviewboard' do
  describe "initial run with defaults" do
    it 'installs cleanly' do
      pp = <<-EOS.unindent
          class {'reviewboard':}
      EOS

      # Apply twice to ensure no errors the second time.
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_changes => true).exit_code).to be_zero
    end
  end
  pending "initial run with specified older version" do
    # cleanup then do another run at a specified older version
  end

  pending "second run updating version" do
    # another run without cleanup, specifying a newer version (update)
  end
end
