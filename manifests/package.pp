# = Class reviewboard::package
#
# Install Reviewboard
#
# == Parameters
#
# [*version*]
#   (string) the version of ReviewBoard to install
#   (default: 2.0.2)
#
# [*venv_path*]
#   (string, absolute path) the path to the virtulenv to create and
#   use for ReviewBoard
#
# [*venv_python*]
#   (string, absolute path) the absolute path to the python interpreter
#   to use for the reviewboard venv
#   (default: '/usr/bin/python')
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
#
class reviewboard::package (
  $version     = undef,
  $venv_path   = '/opt/reviewboard',
  $venv_python = '/usr/bin/python',
  $base_venv   = '/opt/empty_base_venv',
) {

  validate_absolute_path($venv_path)
  validate_absolute_path($venv_python)
  validate_absolute_path($base_venv)

  # empty base venv, per http://code.google.com/p/modwsgi/wiki/VirtualEnvironments
  # this will be the WSGIPythonHome setting
  python_virtualenv {$base_venv:
    ensure     => present,
    virtualenv => $::virtualenv27_path,
  }

  python_virtualenv {$venv_path:
    ensure     => present,
    virtualenv => $::virtualenv27_path,
  }

  if $version == undef {
    $req = 'ReviewBoard'
  } else {
    $req = "ReviewBoard==${version}"
  }

  python_package {"${venv_path},${req}":
    ensure            => present,
    python_prefix     => $venv_path,
    requirements      => $req,
    require           => [Python_virtualenv[$venv_path],
                          Python_virtualenv[$base_venv],
                          ],
  }

}
