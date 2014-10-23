## \file    manifests/site/install.pp
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

# Helper define for running site-install

define reviewboard::site::install(
  $vhost,
  $location,
  $dbtype,
  $dbname,
  $dbhost,
  $dbuser,
  $dbpass,
  $admin,
  $adminpass,
  $adminemail,
  $cache,
  $cacheinfo,
  $venv_path,
) {

  $site = $name
  case $location { # A trailing slash is required
    /\/$/:   { $normalized_location = $location}
    default: { $normalized_location = "${location}/" }
  }

  $args = [
    '--noinput',
    "--domain-name ${vhost}",
    "--site-root ${location}",
    "--db-type ${dbtype}",
    "--db-name ${dbname}",
    "--db-user ${dbuser}",
    "--db-pass ${dbpass}",
    "--cache-type ${cache}",
    "--cache-info ${cacheinfo}",
    '--web-server-type apache',
    '--python-loader wsgi',
    "--admin-user ${admin}",
    "--admin-pass ${adminpass}",
    "--admin-email ${adminemail}",
  ]

  $argstr = join($args, ' ')

  exec {"rb-site install ${name}":
    require => Class[reviewboard::package],
    command => "${venv_path}/bin/rb-site install ${site} ${argstr}",
    creates => "${site}/conf/settings_local.py",
  }

}
