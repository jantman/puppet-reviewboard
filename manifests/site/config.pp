## \file    manifests/siteconfig.pp
#  \author  Scott Wales <scott.wales@unimelb.edu.au>
#  \brief
#
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

# Set a configuration setting then reload the web server
define reviewboard::site::config (
  $site,
  $key,
  $value,
  $venv_path,
) {

  exec {"rb-site ${site} set ${key}=${value}":
    command => "${venv_path}/bin/rb-site manage ${site} set-siteconfig -- --key '${key}' --value '${value}'",
    unless  => "${venv_path}/bin/rb-site manage ${site} get-siteconfig -- --key '${key}' | grep '^${value}$'",
    require => Class['reviewboard::package'],
    notify  => Reviewboard::Provider::Web[$site],
  }

}
