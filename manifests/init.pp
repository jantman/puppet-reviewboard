## \file    manifests/init.pp
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

# Install and generic configs for Reviewboard

# webprovider: Package to use to configure the web server, or 'none' for no
#              config
# webuser:     User that should own the web folders
# dbprovider:  Package to use to configure the database, or 'none' for no
#              config
# dbtype:      Type of database to use

class reviewboard (
  $version     = '1.7.24', # Current stable release
  $webprovider = 'puppetlabs/apache',
  $webuser     = undef,
  $dbprovider  = 'puppetlabs/postgresql',
  $dbtype      = 'postgresql'
) {

  class { 'reviewboard::package':
    version => $version,
  }

}
