require 'spec_helper_acceptance'

describe 'reviewboard' do
  context "initial run with defaults" do
    it 'runs cleanly' do
      # prerequisites
      pp = <<-EOS.unindent
          class {'python::python27':}
      EOS
      apply_manifest(pp, :catch_failures => true)

      pp = <<-EOS.unindent
          class {'reviewboard':}
      EOS

      # Apply twice to ensure no errors the second time.
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_changes => true).exit_code).to be_zero
    end

    pending 'installs OS package' do
      # TODO
      # msgfmt in path
      # uglifyjs in path
    end

    pending 'creates venvs in the correct paths, using the correct python' do
      # TODO - check that venvs exist in the right places and use the right pythons
    end

    pending 'installs no packages in the base venv' do
      # TODO
    end

    pending 'installs ReviewBoard in the venv' do
      # TODO
    end
  end

  pending "install in alternate venv path" do
    # TODO
  end

  pending "alternate venv path, python version and virtualenv" do
    # TODO
  end

  pending "initial run with specified older version" do
    # cleanup then do another run at a specified older version
  end

  pending "second run updating version" do
    # another run without cleanup, specifying a newer version (update)
  end

  # next spec test file - reviewboard_site_spec.rb
  # will need postgres and apache to start with
end
