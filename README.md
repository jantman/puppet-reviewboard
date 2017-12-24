Puppet Reviewboard
==================

[![Project Status: Unsupported – The project has reached a stable, usable state but the author(s) have ceased all work on it. A new maintainer may be desired.](http://www.repostatus.org/badges/latest/unsupported.svg)](http://www.repostatus.org/#unsupported)

DEPRECATED AND UNSUPPORTED
==========================

**I don't use this module anymore, and haven't in many years. I'm leaving it here since I don't like deleting repos (especially in case someone is, somehow, still using it) but it probably doesn't work anymore and I don't intend on resurrecting it. If you have any questions, please contact me via the email on my GitHub profile.**

Manage an install of [Reviewboard](http://www.reviewboard.org)

To install include the class 'reviewboard' in your manifest

Optionally you can install the RBtool package for submitting reviews by
including 'reviewboard::rbtool'

**Note** this branch currently relies on a module, coxmediagroup/virtualenv,
that is not yet available to the public. We're working on fixing that.

**WARNING** - ToDo - update all examples/params in docs.

Pre-Requisites
--------------

The modules available are listed below in the 'Usage' section, pull requests to
support other providers are welcome.

Required Prerequisites (required by the module, but you need to handle them yourself):

  * You must have 'nodejs' and 'npm' packages available via your default OS package
    installation method, as they will be installed by [puppetlabs-nodejs](https://forge.puppetlabs.com/puppetlabs/nodejs);
    on RedHat-based systems, this generally means you need EPEL enabled.
  * You need to have Augeas working for the postgresql module; on RedHat this seems to
    require the 'ruby-devel', 'augeas' and 'augeas-devel' packages and the 'ruby-augeas' gem.
  * This module requires puppetlabs-postgresql >= 4.0.0. This is because puppetlabs-apache
    requires puppetlabs-concat >= 1.1.1, but there is a bug in older versions of puppetlabs-postgresql
    when used with the newer (>= 1.0.0) versions of concat.
  * With default parameters, you need to have Python 2.7 installed.
  * The default values for the python and virtualenv versions come from facts in the coxmediagroup/python
    module, which is not yet released publicly.

Additionally the following optional prerequisites may be installed:

 * memcached & python-memcached for website caching
 * python bindings for your database (if not installed by the dbprovider)

Limitations
-----------

* This module now only supports ReviewBoard 2.x.
* That the database providers do not support anything other than 'localhost'.
* ReviewBoard 2.x doesn't seem to support Python < 2.7, as djblets.extensions.staticfiles
  attempts to import ``importlib``.

Usage
-----

Example of prerequisites:

    class {'python::python27':}
    class {'postgresql::globals':
      version => '9.3',
    }
    class {'postgresql::repo':
      version => '9.3',
    } ->
    class {'postgresql::server':
      version              => '9.3',
      initdb_path          => '/usr/pgsql-9.3/bin/initdb',
      package_name         => 'postgresql93-server',
      service_name         => 'postgresql-9.3',
      needs_initdb         => true,
      pg_hba_conf_path     => '/var/lib/pgsql/9.3/data/pg_hba.conf',
      datadir              => '/var/lib/pgsql/9.3/data',
      postgresql_conf_path => '/var/lib/pgsql/9.3/data/postgresql.conf',
    }
    class {'postgresql::client':
      package_name => 'postgresql93',
    }
    class {'postgresql::lib::devel':
      package_name => 'postgresql93-devel',
    }
    class {'apache':
	  default_vhost => false,
	}
    class {'memcached':
	}

Install ReviewBoard itself:

    class {'reviewboard':
    }

Create a "default" reviewboard site - based at '/opt/reviewboard/site' and available at ${::fqdn}/ :

    reviewboard::site {'/opt/reviewboard/site':
      dbpass     => 'dbpassword',
	  adminpass  => 'adminpassword',
	  adminemail => 'root@example.com',
    }

Create a reviewboard site based at '/var/www/reviewboard', available at ${::fqdn}/reviewboard:

    reviewboard::site {'/var/www/reviewboard':
      vhost      => "${::fqdn}",
      location   => '/reviewboard'
      dbpass     => 'dbpassword',
	  adminpass  => 'adminpassword',
	  adminemail => 'root@example.com',
    }

Setup LDAP Authentication for the site, authenticating against ``ldap://foo.example.com:389``
(clear text, non-SSL) and looking for users under the base DN ``ou=people,dc=example,dc=com``
with a user mask of ``samaccountname=%s`` (Active Directory):

    reviewboard::site::ldap {'/var/www/reviewboard':
	    uri      => 'ldap://foo.example.com:389',
		basedn   => 'ou=people,dc=example,dc=com',
		usermask => 'samaccountname=%s'
	}

You can change the review board version installed with the 'version' argument to the
reviewboard class. Acceptable values for the version argument look like '1.7.20' or
'2.0rc1'. You can find a catalog of versions at:

http://downloads.reviewboard.org/releases/ReviewBoard/.

You can change how the sites are configured with the 'provider' arguments to the reviewboard class. 

**webprovider**:
  * *puppetlabs/apache*: Use puppetlabs/apache to create an Apache vhost
  * *simple*: Copy the apache config file generated by reviewboard & set up a basic Apache server
  * *none*: No web provisioning is done

**dbprovider**:
  * *puppetlabs/postgresql*: Use the puppetlabs/postgresql module to create database tables & install bindings
  * *none*: No DB provisioning is done (note a database is required for the install to work)

The default settings are
    
    class reviewboard {
        version     => '1.7.24',
        webprovider => 'puppetlabs/apache',
        dbprovider  => 'puppetlabs/postgresql'
    }

To use a custom web provider set the 'webuser' parameter & subscribe the web
service to `reviewboard::provider::web<||>`:

    class reviewboard {
        webprovider => 'none',
        webuser     => 'apache',
    }
    Reviewboard::Provider::Web<||> ~> Service['apache']

You will then need to manually configure your web server, Reviewboard generates
an example Apache config file in ${site}/conf/apache-wsgi.conf.

Other Features
--------------

 * **RBTool**: Reviewboard command-line interface. To install:

        include reviewboard::rbtool

 * **Trac integration**: The [traclink](https://github.com/ScottWales/reviewboard-trac-link) Reviewboard plugin posts a notice on a Trac ticket whenever the 'Bug' field is set in a review. To install:

        package {trac: } # Make sure Trac is installed via Puppet
        include reviewboard::traclink

    There is also some setup required in your site's `trac.ini`:

        [ticket-custom]
        reviews = text
        reviews.format = wiki
        [interwiki]
        review = //reviewboard/r/

Testing
-------

Integration tests make use of [serverspec](http://serverspec.org) to check the module is applied properly on a Vagrant VM.

To setup tests

    $ gem install bundler
    $ bundle install --path vendor

To run the syntax, lint and rspec tests:

    $ bundle exec rake test

To run the beaker/serverspec integration tests:

    $ BEAKER_destroy=no bundle exec rake acceptance

To run again without re-provisioning the vm:

    $ BEAKER_destroy=no BEAKER_provision=no bundle exec rake acceptance

For more information on running the integration/acceptance tests, see [How to Write a Beaker Test for a Module](https://github.com/puppetlabs/beaker/wiki/How-to-Write-a-Beaker-Test-for-a-Module).

**Note** that ``spec_helper_acceptance.rb`` currently forces Puppet installation to 3.6.2, as I couldn't figure out how to get facts and fixture modules working right with ``puppet apply`` in 3.7.x.

Use `vagrant destroy` to stop the test VM.

