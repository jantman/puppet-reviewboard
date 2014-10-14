require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  c.before do
    # avoid "Only root can execute commands as other users"
    Puppet.features.stubs(:root? => true)
  end
end

class Undef
  def inspect
    'undef'
  end
end
