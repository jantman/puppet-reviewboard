all:check

export BEAKER_destory = onpass

# Beaker is slow if we install bundles to this directory
# https://github.com/puppetlabs/beaker/issues/143
bundledir    = ../bundles
puppetfiles := $(shell find . -not -path '*/\.*' -name '*.pp')
lintflags    = --with-filename --no-80chars-check

bundle:${bundledir}/.empty

${bundledir}/.empty: Gemfile
	bundle install --path ${bundledir} && touch $@

check: unit parse lint

unit: bundle parse lint
	bundle exec rspec spec/unit

accept: bundle parse lint unit
	bundle exec rspec spec/acceptance

parse: bundle
	bundle exec puppet parser validate ${puppetfiles}

lint: bundle
	bundle exec puppet-lint ${lintflags} ${puppetfiles}
