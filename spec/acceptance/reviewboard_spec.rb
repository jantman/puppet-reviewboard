require 'spec_helper_acceptance'

describe 'reviewboard' do
    it 'installs cleanly' do
        pp = <<-EOS.unindent
            class {'reviewboard':}
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes  => true)
    end
end
