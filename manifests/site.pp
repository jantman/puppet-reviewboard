#  \file    manifests/site.pp
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

# Set up a reviewboard site
#
# === Parameters
#
# [*site (namevar)*]
#   (string) The location where the site will be created on disk
#   Default: $name
#
# [*vhost*]
#   (string) The ServerName of the apache vhost.
#   Default: $::fqdn
#
# [*location*]
#   (string) The URL path where the site will be served
#   Default: '/'
#
# [*dbtype*]
#   (string) The database type to use. Passed directly to ``rb-site install``
#    as the ``--db-type`` option. Default: 'postgresql'
#
# [*dbname*]
#   (string) The name of the database to use. Using the default puppetlabs/postgresql
#   dbprovider (argument to reviewboard class), this will be created automatically.
#   Default: 'reviewboard'
#
# [*dbhost*]
#   (string) The database host/IP to connect to.
#   Default: localhost
#
# [*dbuser*]
#   (string) The database user to connect as. Using the default puppetlabs/postgresql
#   dbprovider (argument to reviewboard class), this will be created automatically.
#   Default: reviewboard
#
# [*dbpass*]
#   (string) The database password to use. This MUST be defined.
#   Default: undef
#
# [*admin*]
#   (string) The site administrator's username (admin superuser).
#   Default: 'admin'
#
# [*adminpass*]
#   (string) The site administrator's password.
#   Default: undef
#
# [*adminemail*]
#   (string) The site administrator's email address.
#   Default: "${reviewboard::webuser}@${::fqdn}"
#
# [*cache*]
#   (string) The cache server type ('memcached' or 'file').
#   Default: 'memcached'
#
# [*cacheinfo*]
#   The cache identifier (memcached connection string
#   or file cache directory).
#   Default: 'localhost:11211'
#
# [*webuser*]
#   The (system) user that will own the site's configuration files
#   and web root / htdocs.
#   Default: $reviewboard::webuser
#
#
define reviewboard::site (
  $site       = $name,
  $vhost      = $::fqdn,
  $location   = '/',
  $dbtype     = 'postgresql',
  $dbname     = 'reviewboard',
  $dbhost     = 'localhost',
  $dbuser     = 'reviewboard',
  $dbpass     = undef,
  $admin      = 'admin',
  $adminpass  = undef,
  $adminemail = "${reviewboard::webuser}@${::fqdn}",
  $cache      = 'memcached',
  $cacheinfo  = 'localhost:11211',
  $webuser    = $reviewboard::webuser,
) {
  include reviewboard

  validate_absolute_path($site)

  if $dbpass == undef {
    fail('Postgres DB password not set')
  }
  if $adminpass == undef {
    fail('Admin password not set')
  }
  if $adminemail == "@${::fqdn}" {
    fail('reviewboard::webuser must be explicitly set if adminemail is not.')
  }

  if $location != '/' and $reviewboard::webprovider == 'puppetlabs/apache' {
    fail('Due to a bug in puppet allowing only hashes keyed by string literals (not variables), the puppetlabs/apache web provider only works when location is /')
  }

  # Create the database
  reviewboard::provider::db {$site:
    dbuser => $dbuser,
    dbpass => $dbpass,
    dbname => $dbname,
    dbhost => $dbhost,
  }

  case $location { # A trailing slash is required
    /\/$/:   { $normalized_location = $location}
    default: { $normalized_location = "${location}/" }
  }

  # Run site-install
  reviewboard::site::install {$site:
    vhost      => $vhost,
    location   => $normalized_location,
    dbtype     => $dbtype,
    dbname     => $dbname,
    dbhost     => $dbhost,
    dbuser     => $dbuser,
    dbpass     => $dbpass,
    admin      => $admin,
    adminpass  => $adminpass,
    adminemail => $adminemail,
    cache      => $cache,
    cacheinfo  => $cacheinfo,
    require    => Reviewboard::Provider::Db[$site],
    venv_path  => $reviewboard::venv_path,
  }

  # Set up the web server
  reviewboard::provider::web {$site:
    vhost                 => $vhost,
    location              => $location,
    webuser               => $webuser,
    venv_path             => $reviewboard::venv_path,
    venv_python           => $reviewboard::venv_python,
    base_venv             => $reviewboard::base_venv,
    mod_wsgi_package_name => $reviewboard::mod_wsgi_package_name,
    mod_wsgi_so_name      => $reviewboard::mod_wsgi_so_name,
    require               => Reviewboard::Site::Install[$site],
  }

}
