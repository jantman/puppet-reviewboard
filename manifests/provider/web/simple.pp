## \file    simple.pp
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

# Simple web config
#
# Reviewboard creates a default apache config, just install it and restart
# the daemon

define reviewboard::provider::web::simple (
  $vhost,
  $location,
  $venv_path,
  $base_venv,
  $venv_python,
) {

  $site = $name

  class {'reviewboard::provider::web::simplepackage':
    venv_path   => $venv_path,
    venv_python => $venv_python,
    base_venv   => $base_venv,
  }

  # Install apache config file
  file {"/etc/httpd/conf.d/${vhost}.conf":
    ensure => link,
    source => "${site}/conf/apache-wsgi.conf",
    notify => Service['httpd'],
  }

  # Propogate update events to the service
  exec {"Update ${name}":
    command     => '/bin/true',
    refreshonly => true,
    notify      => Service['httpd'],
  }

}
