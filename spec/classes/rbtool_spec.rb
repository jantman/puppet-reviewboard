require 'spec_helper'

describe 'reviewboard::rbtool' do

  let :pre_condition do
    "package {'python-pip': ensure => present, }"
  end

  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      describe "reviewboard::rbtool class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) { SpecHelperFacts.new({:osfamily => osfamily}).facts }

        it { should compile.with_all_deps }

        it { should contain_package('RBTools').with({
                                                      :ensure   => 'present',
                                                      :provider => 'pip'
                                                    })
        }
      end
    end
  end
end
