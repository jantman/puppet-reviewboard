# == Class: reviewboard::siteclass
#
# Wrapper class around reviewboard::site define, for users who
# only have one RB site/vhost but want to use it with an ENC or
# Hiera.
#
# === Parameters
#
# [*site*]
#   (string) The name of the site.
#   Default: undef
#
# [*vhost*]
#   (string) The ServerName of the apache vhost.
#   Default: $::fqdn
#
# [*location*]
#   (string) The path to the site relative to the domain name.
#   Default: '/reviewboard'
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
# === Authors
#
#  Jason Antman <jason@jasonantman.com>
#
# === Copyright
#
#  Copyright 2014 Jason Antman
#
# === License
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
class reviewboard::siteclass (
  $site       = undef,
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

  # wrap the define
  reviewboard::siteclass { $site:
    vhost      => $vhost,
    location   => $location,
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
    webuser    => $webuser,
  )

}
