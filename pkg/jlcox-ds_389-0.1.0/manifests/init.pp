# == Class: ds_389
#
#
# To set up a server with the DS389 service you will need to add the following classes to you manifest
#
# class {'ds_389::install' : }                                                                                                                                                                        
# class {'ds_389::service' : }                                                                                                                                                                        
#
# These Classes will install the packages and also set the service to start on boot.
#
# === To create a new directory site  you can use the following format
#
#  ds_389::site { 'api' :
#    suite_spot_group   => 'nobody',
#    suite_spot_user_id => 'nobody',
#    modify_ldif_file  => [
#      'base_api.ldif',
#      'ssl.ldif',
#      'plugin.ldif',
#    ],
#    add_ldif_file   => [
#      'top_dn.ldif',
#      'user_group_ou.ldif',
#    ],
#    schema_extension => [
#      '99user.ldif',
#    ],
#    root_dn         => 'cn=Directory Manager',
#    root_dn_pwd     => '1234qwer',
#    server_port     => '4389',
#    server_ssl_port => '4636',
#    suffix          => 'dc=api.blah.com.au',
#    base_data       => 'true',
#  }
#
# *** modify_ldif_file ***
# This array is a list of template names (less the .erb extension) that are located in the templates folder in this module.
# If there are no files to be imported into the database then this can be set to 'none'.
#
# *** add_ldif_file ***
# This array list contains ldif files that do not have any local customisations that need to be applied.
#
# *** schema_extension ***
# These are extension files that need to be copied into the ldap site directory
#
# *** base_data ***
# base ldif files files that need to appied o a site. This can either be a single file or 'true' which will deploy all files listed in 'manifests/base_load_list.pp'
#
# === Authors
#
# Jason Cox <j_cox@bigpond.com>
#
# === Copyright
#
# Copyright 2014 Jason Cox, unless otherwise noted.
#
class ds_389 (

 ){

   #   class { 'ds_389::install' : }
}
