require 'spec_helper'

describe 'reviewboard' do
  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      describe "reviewboard class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { should compile.with_all_deps }

        it { should contain_ckass('reviewboard::package').with_version('1.7.24') }
      end
    end
  end
end
