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

define reviewboard::site (
  $site       = $name,
  $vhost      = $::fqdn,
  $location   = '/reviewboard',
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

  if $dbpass == undef {
    fail('Postgres DB password not set')
  }
  if $adminpass == undef {
    fail('Admin password not set')
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
  }

  # Set up the web server
  reviewboard::provider::web {$site:
    vhost    => $vhost,
    location => $location,
    webuser  => $webuser,
    require  => Reviewboard::Site::Install[$site],
  }

}
