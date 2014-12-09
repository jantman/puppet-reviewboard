source "https://rubygems.org"

group :test do
  gem "rake"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 3.6.2'
  gem "puppet-lint", '~> 1.0.0'
  gem "rspec-puppet", :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem "puppet-syntax"
  gem "puppetlabs_spec_helper"
  gem "rspec_junit_formatter"
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem "beaker", "~> 1.20.1"
  gem "beaker-rspec"
  gem "vagrant-wrapper"
  gem "puppet-blacksmith"
  gem "guard-rake"
end
