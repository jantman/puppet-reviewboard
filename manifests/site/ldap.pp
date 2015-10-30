## \file    manifests/ldap.pp
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

# Enable LDAP auth for a reviewboard site
# Requires python-ldap to be already installed

# site -> Reviewboard site

define reviewboard::site::ldap (
  $uri,
  $basedn,
  $site = $name,
  $usermask = '(uid=%s)',
  $emaildomain = undef,
) {
  warning('LDAP configuration not presently working in tests')

  include reviewboard

  Reviewboard::Site::Config {
    site      => $site,
    require   => Reviewboard::Site::Install[$site],
    venv_path => $reviewboard::venv_path,
  }

  reviewboard::site::config {"${site} ldap enable":
    key   => 'auth_backend',
    value => 'ldap',
  }
  reviewboard::site::config {"${site} ldap uri":
    key   => 'auth_ldap_uri',
    value => $uri,
  }
  reviewboard::site::config {"${site} ldap basedn":
    key   => 'auth_ldap_base_dn',
    value => $basedn,
  }
  reviewboard::site::config {"${site} ldap mask":
    key   => 'auth_ldap_uid_mask',
    value => $usermask,
  }

  if $emaildomain != undef {
    reviewboard::site::config {"${site} ldap email domain":
      key   => 'auth_ldap_email_domain',
      value => $emaildomain,
    }
  }
}

