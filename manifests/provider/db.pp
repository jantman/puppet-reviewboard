## \file    manifests/provider/db.pp
#  \author  Scott Wales <scott.wales@unimelb.edu.au>
#
#  Copyright 2014 ARC Centre of Excellence for Climate Systems Science
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

# Delegate to custom DB provider
define reviewboard::provider::db (
  $dbname,
  $dbhost,
  $dbuser,
  $dbpass,
) {

  $site = $name

  if $reviewboard::dbprovider == 'puppetlabs/postgresql' {
    reviewboard::provider::db::puppetlabspostgresql {$site:
      dbname => $dbname,
      dbhost => $dbhost,
      dbuser => $dbuser,
      dbpass => $dbpass,
    }
  } elsif $reviewboard::dbprovider == 'puppetlabs/mysql' {
    reviewboard::provider::db::puppetlabsmysql {$site:
      dbname => $dbname,
      dbhost => $dbhost,
      dbuser => $dbuser,
      dbpass => $dbpass,
    }
  } elsif $reviewboard::dbprovider == 'none' {
    # No-op
  } else {
    err("DB provider '${reviewboard::dbprovider}' not defined")
  }

}
