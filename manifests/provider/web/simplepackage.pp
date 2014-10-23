## \file    provider/web/simplepackage.pp
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

# Setup for the 'simple' web provider
class reviewboard::provider::web::simplepackage (
  $venv_path,
  $base_venv,
  $venv_python,
) {

  package {'httpd':
    ensure => present,
  }

  service {'httpd':
    ensure  => running,
    enable  => true,
    require => Package['httpd'],
  }

  file {'/etc/httpd/conf.d':
    ensure  => directory,
    recurse => true,
    purge   => true,
    require => Package['httpd'],
  }

  file {'/etc/httpd/conf.d/mod_wsgi.conf':
    ensure  => present,
    content => 'LoadModule wsgi_module modules/mod_wsgi.so',
    notify  => Service['httpd'],
  }

}
