## \file    manifests/provider/web/puppetlabsapache.pp
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

# Set up the website using puppetlabs/apache

define reviewboard::provider::web::puppetlabsapache (
  $vhost,
  $location,
  $venv_path,
  $base_venv,
  $venv_python,
  $mod_wsgi_package_name = undef,
  $mod_wsgi_so_name      = undef,
) {

  $site = $name

  if $mod_wsgi_package_name == undef {
    class {'apache::mod::wsgi':
      wsgi_python_path => "${venv_path}/lib/python2.7/site-packages",
      wsgi_python_home => $base_venv,
    }
  } else {
    # TODO: until https://tickets.puppetlabs.com/browse/MODULES-1458 is closed
    $mod_path = "${::apache::params::lib_path}/${mod_wsgi_so_name}"

    ::apache::mod { 'wsgi':
      package => $mod_wsgi_package_name,
      path    => $mod_path,
    }

    $wsgi_python_path = "${venv_path}/lib/python2.7/site-packages"
    $wsgi_python_home = $base_venv
    $wsgi_socket_prefix = $::apache::params::wsgi_socket_prefix
    # Template uses:
    # - $wsgi_socket_prefix
    # - $wsgi_python_path
    # - $wsgi_python_home
    file {'wsgi.conf':
      ensure  => file,
      path    => "${::apache::mod_dir}/wsgi.conf",
      content => template('apache/mod/wsgi.conf.erb'),
      require => Exec["mkdir ${::apache::mod_dir}"],
      before  => File[$::apache::mod_dir],
      notify  => Service['httpd']
    }
  }

  include apache::mod::mime

  $error_documents = [{error_code => '500', document => '/errordocs/500.html'}]
  if ($location == '/') {
    $locationfragment = ''
  } else {
    $locationfragment = $location
  }

  # lint:ignore:only_variable_string - this is a hack to make a var work as a hash key
  $script_aliases  = {"${location}" => "${site}/htdocs/reviewboard.wsgi${locationfragment}"}
  # lint:endignore

  $directories = [
    {path   => "${site}/htdocs",
    options => ['-Indexes','+FollowSymLinks']
    },
    {path           => "${locationfragment}/media/uploaded",
    provider        => 'location',
    custom_fragment => '
      SetHandler None
      Options None

      AddType text/plain .html .htm .shtml .php .php3 .php4 .php5 .phps .asp
      AddType text/plain .pl .py .fcgi .cgi .phtml .phtm .pht .jsp .sh .rb

      <IfModule mod_php5.c>
        php_flag engine off
      </IfModule>
    '}
  ]

  $aliases = [
    {alias => "${locationfragment}/media",
    path => "${site}/htdocs/media"
    },
    {alias => "${locationfragment}/static",
    path => "${site}/htdocs/static"
    },
    {alias => "${locationfragment}/errordocs",
    path => "${site}/htdocs/errordocs"
    },
    {alias => "${locationfragment}/favicon.ico",
    path => "${site}/htdocs/static/rb/images/favicon.png"
    },
  ]

  apache::vhost {$vhost:
    port                => 80,
    docroot             => "${site}/htdocs",
    error_documents     => $error_documents,
    wsgi_script_aliases => $script_aliases,
    custom_fragment     => 'WSGIPassAuthorization On',
    directories         => $directories,
    aliases             => $aliases,
  }

  # Propogate update events to the service
  exec {"Update ${name}":
    command     => '/bin/true',
    refreshonly => true,
    notify      => Class['apache::service'],
  }
}
