Puppet Reviewboard
==================

Manage an install of [Reviewboard](http://www.reviewboard.org)

To install include the package 'reviewboard' in your manifest

Pre-Requisites
--------------

Puppet module pre-requisites are managed using
[librarian-puppet](https://github.com/rodjek/librarian-puppet)

Additionally the following optional prerequisites may be installed:

 * memcached & python-memcached for website caching
 * python-ldap for ldap authentication
 * python bindings for your database

Usage
-----

Create a reviewboard site based at '/var/www/reviewboard':

    reviewboard::site {'/var/www/reviewboard':
        vhost    => "${::fqdn}",
        location => "/reviewboard/"
    }

Enable LDAP authentication for the site

    reviewboard::site::ldap {'/var/www/reviewboard':
        uri    => 'ldap://example.com',
        basedn => 'dn=example,dn=com',
    }

You can change how the sites are configured with the 'provider' arguments to the reviewboard class. 

**webprovider**:
  * *simple*: Copy the apache config file generated by reviewboard & set up a basic Apache server
  * *none*: No web provisioning is done

**dbprovider**:
  * *puppetlabs/postgresql*: Use the puppetlabs/postgresql module to create database tables
  * *none*: No DB provisioning is done (note a database is required for the install to work)

The default settings are
    
    class reviewboard {
        webprovider => 'simple',
        dbprovider  => 'puppetlabs/postgresql'
    }

Testing
-------

A Vagrantfile is provided to test the module, to test provisioning run

    $ vagrant up

The Reviewboard site will then be available at http://localhost:8090/reviewboard
