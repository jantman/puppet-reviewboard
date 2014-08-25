require 'spec_helper'

describe 'reviewboard::traclink' do

  let :pre_condition do
    <<-eos
    package {'python-pip': ensure => present, }
    package {'trac': ensure => present, }
    eos
  end

  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      describe "reviewboard::traclink class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { should compile.with_all_deps }

        it { should contain_package('traclink').with({
                                                       :provider => 'pip',
                                                       :source => 'git+https://github.com/ScottWales/reviewboard-trac-link',
                                                       :require => ['Class[Reviewboard::Package]', 'Package[trac]']
                                                       })
        }

      end
    end
  end
end
