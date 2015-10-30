#!/bin/bash -x
bundle install --path vendor
bundle exec rake acceptance
