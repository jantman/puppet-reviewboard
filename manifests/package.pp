## \file    manifests/package.pp
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

class reviewboard::package (
  $version = undef,
) {

  $base_url = 'http://downloads.reviewboard.org/releases/ReviewBoard'
  case $version {
    /^2\.0\./: { $egg_url = "${base_url}/2.0/ReviewBoard-${version}-py2.6.egg" }
    /^1\.7\./: { $egg_url = "${base_url}/1.7/ReviewBoard-${version}-py2.6.egg" }
    default: {
      fail("reviewboard::package has not been tested with Review Board ${version}.")
    }
  }

  if ! defined(Package['python-pip']) {
    package {'python-pip':
      ensure => present,
    }
  }

  exec {'easy_install reviewboard':
    command => "easy_install '${egg_url}'",
    unless  => "pip freeze | grep 'ReviewBoard==${version}'",
    path    => ['/bin','/usr/bin' ],
    require => Package['python-pip'],
  }

}
