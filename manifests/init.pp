# = Class reviewboard
#
# Install and generic configs for Reviewboard
#
# == Parameters
#
# [*version*]
#   (string) the version of ReviewBoard to install
#   (default: undef; install latest)
#
# [*webprovider*]
#   (string) the provider to use for web server configuration
#   see reviewboard::provider::web
#   (default: 'puppetlabs/apache')
#
# [*webuser*]
#   (string) the username for web resources to be owned by
#   (default: undef - from web provider)
#
# [*dbprovider*]
#   (string) the provider to use for DB configuration
#   see reviewboard::provider::db
#   (default: 'puppetlabs/postgresql')
#
# [*dbtype*]
#   (string) the database type to use (passed in to Django)
#   (default: 'postgresql')
#
# [*venv_path*]
#   (string, absolute path) the path to the virtulenv to create and
#   use for ReviewBoard
#
# [*venv_python*]
#   (string, absolute path) the absolute path to the python interpreter
#   to use for the reviewboard venv
#   (default: $::python27_path)
#
# [*virtualenv_script*]
#   (string, absolute path) The path to the virtualenv script to use.
#   (default: $::virtualenv27_path)
#
# [*base_venv*]
#   (string, absolute path) the path to create an empty base virtualenv in,
#   to use for the reviewboard venv per the mod_wsgi docs.
#   (default: '/opt/empty_base_venv')
#
# == Authors
#
# Scott Wales <scott.wales@unimelb.edu.au>
# Jason Antman <jason@jasonantman.com>
#
# == License
#  Copyright 2014 Scott Wales
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
class reviewboard (
  $version           = undef,
  $webprovider       = 'puppetlabs/apache',
  $webuser           = undef,
  $dbprovider        = 'puppetlabs/postgresql',
  $dbtype            = 'postgresql',
  $venv_path         = '/opt/reviewboard',
  $venv_python       = $::python27_path,
  $virtualenv_script = $::virtualenv27_path,
  $base_venv         = '/opt/empty_base_venv',
) {

  validate_absolute_path($venv_path)
  validate_absolute_path($virtualenv_script)
  validate_absolute_path($venv_python)
  validate_absolute_path($base_venv)

  class { 'reviewboard::package':
    version           => $version,
    venv_path         => $venv_path,
    venv_python       => $venv_python,
    virtualenv_script => $virtualenv_script,
    base_venv         => $base_venv,
  }

}
