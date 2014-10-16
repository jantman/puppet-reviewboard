## \file    manifests/provider/db/puppetlabspostgresql.pp
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

# Sets up the site DB using puppetlabs/postgresql
define reviewboard::provider::db::puppetlabspostgresql (
  $dbuser,
  $dbpass,
  $dbname,
  $dbhost = 'localhost',
) {

  include postgresql::lib::python

  if $dbhost != 'localhost' {
    fail('Remote db hosts not implemented')
  }

  postgresql::server::db {$dbname:
    user     => $dbuser,
    password => postgresql_password($dbuser,$dbpass),
  }

}
