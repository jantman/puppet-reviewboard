# = Class reviewboard::package
#
# Install Reviewboard
#
# == Parameters
#
# [*version*]
#   (string) the version of ReviewBoard to install
#   (default: undef; install latest)
#
# [*virtualenv_script*]
#   (string, absolute path) The path to the virtualenv script to use.
#   (default: $::virtualenv27_path)
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
  $version           = undef,
  $virtualenv_script = $::virtualenv27_path,
  $venv_path         = '/opt/reviewboard',
  $venv_python       = $::python27_path,
  $base_venv         = '/opt/empty_base_venv',
) {

  validate_absolute_path($virtualenv_script)
  validate_absolute_path($venv_path)
  validate_absolute_path($venv_python)
  validate_absolute_path($base_venv)

  # empty base venv, per http://code.google.com/p/modwsgi/wiki/VirtualEnvironments
  # this will be the WSGIPythonHome setting
  python::virtualenv { $base_venv :
    ensure       => present,
    version      => 'system',
    systempkgs   => true,
    venv_dir     => $base_venv,
    timeout      => 0,
  }

python::virtualenv { $venv_path :
    ensure       => present,
    version      => 'system',
    systempkgs   => true,
    venv_dir     => $venv_path,
    timeout      => 0,
    require      => Python::Virtualenv[$base_venv],
  }


  # this is needed by djblets for i18n
  if ! defined(Package['gettext']) {
    package {'gettext':
      ensure => present,
    }
  }

  if ! defined(Package['patch']) {
    package {'patch':
      ensure => present,
    }
  }

  if ! defined(Package['git']) {
    package {'git':
      ensure => present,
    }
  }

  if $::osfamily == 'RedHat' {
    # this is in EPEL. The `npm` install seems broken on Cent6. So use the OS package.
    package {'uglifyjs':
      ensure => present,
      name   => 'uglify-js',
    }
  } else {
    # fall back to npm-based install on other OSes
    require nodejs

    package {'uglifyjs':
      ensure   => present,
      provider => 'npm',
      require  => Class['nodejs'],
    }
  }

  # the following install ugliness was created for RB 2.0.7;
  # at the very least, 1.7.27 requires 'Django>=1.4.13,<1.5'
  if ( $version != undef and $version !~ /^2\./ ) {
    fail('ERROR: reviewboard::package only supports ReviewBoard 2.x')
  }

  # these are build-time requirements for ReviewBoard 2.x
  # apparently `pip` doesn't handle these correctly, so we
  # need them installed before we try to install ReviewBoard
  $build_reqs = ['# puppet-managed - reviewboard::package class',
                  '# because of pip issues, these have to be installed before ReviewBoard',
                  'Django>=1.6.7,<1.7',
                  'django-pipeline',
                  'djblets',
                  'django-evolution',
                  'pygments',
                  'docutils',
                  'markdown',
                  'paramiko',
                  'mimeparse',
                  'haystack',
                  'psycopg2',
                  ]

  $build_req_options = ['--allow-unverified',
                        'django-evolution',
                        '--allow-unverified',
                        'djblets']

  # requirements file for the above
  file {"${venv_path}/puppet_build_requirements.txt":
    ensure  => present,
    mode    => '0644',
    content => join($build_reqs, "\n"),
    require => Python::Virtualenv[$venv_path],
  }

  # install the above requirements file
  python::requirements {"${venv_path}/puppet_build_requirements.txt":
    virtualenv        => $venv_path,
    require           => [File["${venv_path}/puppet_build_requirements.txt"],
                          Package['uglifyjs'],
                          Package['gettext'],
                          ],
  }

  if $version == undef {
    $ensure_version = 'present'
  } else {
    $ensure_version = $version
  }

  python::pip { 'ReviewBoard':
    virtualenv    => $venv_path,
    pkgname       => 'ReviewBoard',
    ensure        => $ensure_version,
    require       => Python::Requirements["${venv_path}/puppet_build_requirements.txt"],
  }

}
