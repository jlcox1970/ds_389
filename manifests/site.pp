# == Class: ds_389
#
# Full description of class ds_389 here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { ds_389:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
define ds_389::site (
  $suite_spot_group      = $suite_spot_group,
  $suite_spot_user_id    = $suite_spot_user_id ,
  $modify_ldif_file      = pick($modify_ldif_file, 'none'),
  $add_ldif_file         = pick($add_ldif_file, 'none'),
  $schema_extension      = pick($schema_extension, 'none'),
  $base_data             = pick ($base_data, 'false'),
  $root_dn               = $root_dn,
  $root_dn_pwd           = $root_dn_pwd,
  $server_identifier     = $name,
  $server_port           = $server_port,
  $server_ssl_port       = $server_ssl_port,
  $suffix                = $suffix,
  $service               = 'dirsrv',                 
  $nsEncryptionAlgorithm = pick($nsEncryptionAlgorithm ,'AES')
 ) {
  include ds_389::base_load_list 
  include ds_389::service
  $dir_inst_hostname  = $hostname
  $pwd_file           = "/tmp/pwdfile-${server_identifier}"
  $noise_file         = "/tmp/noisefile-${server_identifier}"
  $database           = "/etc/dirsrv/slapd-${server_identifier}"
  $certutil           = '/usr/bin/certutil'
  $ldapmodify         = '/usr/bin/ldapmodify'
  $id                 = "${server_identifier}:"
  $prefix = "${server_identifier}_${hostname}"
  
  if ( "$modify_ldif_file" != 'none' ){  
    $munge_modify_ldif  = inline_template("<%= @modify_ldif_file.collect{|x| prefix.to_s+':'+x.to_s+','} %>")
    $array_modify_ldif  = split( $munge_modify_ldif, '[,]')
    @@ds_389::ldif_modify { $array_modify_ldif :
      server_identifier => $server_identifier,
      root_dn           => $root_dn,
      group             => $suite_spot_group,
      user              => $suite_spot_user_id ,
      root_dn_pwd       => $root_dn_pwd,
      server_port       => $server_port,
      server_ssl_port   => $server_ssl_port,
      tag               => "${env}_${hostname}_ldif_modify"
    }  
  }
  
  if ( "$add_ldif_file" != 'none' ){ 
    $munge_add_ldif     = inline_template("<%= @add_ldif_file.collect{|x| prefix.to_s+':'+x.to_s+','} %>")
    $array_add_ldif     = split( $munge_add_ldif, '[,]')
    @@ds_389::ldif_add { $array_add_ldif :
      server_identifier => $server_identifier,
      group             => $suite_spot_group,
      user              => $suite_spot_user_id ,
      root_dn           => $root_dn,
      root_dn_pwd       => $root_dn_pwd,
      server_port       => $server_port,
      server_ssl_port   => $server_ssl_port,
      suffix            => $suffix,
      tag               => "${env}_${hostname}_ldif_add"
    } 
  } 
  
  if ( "$schema_extension" != 'none' ) {
    $munge_schema       = inline_template("<%= @schema_extension.collect{|x| prefix.to_s+':'+x.to_s+','} %>")
    $array_schema       = split( $munge_schema, '[,]')
  } else {
    $array_schema = 'none'
  }
 
  if ( $base_data == 'true' ) {
    $base_list = $ds_389::base_load_list::load_list
    $munge_base_list = inline_template("<%= base_list.collect{|x| prefix.to_s+':'+x.to_s+','} %>")
    $array_base_list = split( $munge_base_list, '[,]')
    @@ds_389::ldif_base_load { $array_base_list :
      server_identifier => $server_identifier,
      group             => $suite_spot_group,
      user              => $suite_spot_user_id ,
      root_dn           => $root_dn,
      root_dn_pwd       => $root_dn_pwd,
      server_port       => $server_port,
      server_ssl_port   => $server_ssl_port,
      suffix            => $suffix,
      tag               => "${env}_${hostname}_base_load"
    } 
  } 
  if ( $base_data != 'true' ) and ( "$base_data" != 'false' ){
    $munge_base_list = inline_template("<%= base_data.collect{|x| prefix.to_s+':'+x.to_s+','} %>")
    $array_base_list = split( $munge_base_list, '[,]')
    @@ds_389::ldif_base_load { $array_base_list :
      server_identifier => $server_identifier,
      group             => $suite_spot_group,
      user              => $suite_spot_user_id ,
      root_dn           => $root_dn,
      root_dn_pwd       => $root_dn_pwd,
      server_port       => $server_port,
      server_ssl_port   => $server_ssl_port,
      suffix            => $suffix,
      tag               => "${env}_${hostname}_base_load"
    }
  }

  unless $root_dn_pwd {
    fail ("Directory Service 389 : rootDNPwd : No Password for RootDN :::${root_dn_pwd}:::")
  }
  
  
  anchor {"${server_identifier} ds_389::site::start" : }->
  exec { "${server_identifier} SELinux disable" : 
    command => "/bin/echo 0 > /selinux/enforce",
  }->
  #exec { "${server_identifier} Stop dirsrv":
  #  command => "/sbin/service dirsrv stop ${server_identifier} ; /bin/true",
  #}->
  exec { "${server_identifier} setup ds":
    command    => "/usr/sbin/setup-ds.pl --silent General.FullMachineName=${dir_inst_hostname} General.SuiteSpotGroup=${suite_spot_group} General.SuiteSpotUserID=${suite_spot_user_id} slapd.InstallLdifFile=none slapd.RootDN=\"${root_dn}\" slapd.RootDNPwd=${root_dn_pwd} slapd.ServerIdentifier=${server_identifier} slapd.ServerPort=${server_port} slapd.Suffix=${suffix}",
    require => Package['389-ds-base'],
    onlyif => "/usr/bin/test ! -d /etc/dirsrv/slapd-${server_identifier}",
  }->
  exec {"${server_identifier} Setup token":
    command => "/sbin/service dirsrv stop ${server_identifier} ;/bin/echo \"Internal (Software) Token:${root_dn_pwd}\" > ${database}/pin.txt ;chown -R ${suite_spot_user_id}:${suite_spot_group} ${database}*  ;/sbin/service dirsrv restart ${server_identifier}",
    require => Package['389-ds-base'],
    onlyif  => "/usr/bin/test ! -f /etc/dirsrv/slapd-${server_identifier}/pin.txt",
  }->
  exec { "${server_identifier} create noise file" :
    command => "/bin/ps -ef | /usr/bin/sha1sum | /bin/awk \'{print \$1}\' > ${noise_file}",
    require => Package['389-ds-base'],
  }->
  exec { "${server_identifier} create pwd file":
    command => "/bin/echo ${root_dn_pwd} > ${pwd_file}",
  }->
  exec { "${server_identifier} Create cert DB":
    command => "${certutil} -N -d ${database} -f ${pwd_file}",
  }->
  exec { "${server_identifier} generate key pair":
    command => "${certutil} -G -d ${database} -z ${noise_file} -f ${pwd_file}",
  }->
  exec { "${server_identifier} make certs and add to database" :
    cwd     => "${database}",
    command => "${certutil} -S -n \"${server_identifier}CA1\" -s \"cn=${server_identifier}CA1,dc=${dir_inst_hostname}\" -x -t \"CT,,\" -v 120 -d ${database} -k rsa -z ${noise_file} -f ${pwd_file}; /bin/sleep 2",
    onlyif  => "/usr/bin/test ! `${certutil} -d ${database} -L |grep -c \"${server_identifier}CA1\"` -ge 1",
    notify  => Service['dirsrv'],
  }->
  exec { "${server_identifier} make certs and add to database 2" :
    cwd     => "${database}",
    command => "${certutil} -S -n \"${server_identifier}Cert1\" -m 101 -s \"cn=${dir_inst_hostname}\" -c \"${server_identifier}CA1\" -t \"u,u,u\" -v 120 -d ${database} -k rsa -z ${noise_file} -f ${pwd_file} ; /bin/sleep 2",
    onlyif  => "/usr/bin/test ! `${certutil} -d ${database} -L |grep -c \"${server_identifier}Cert1\"` -ge 1",
    notify  => Service['dirsrv'],
  }->
  exec { "${server_identifier} List certs ":
    command => "${certutil} -d ${database} -L",
  }->
  exec {"${server_identifier} set perms on databse directory":
    command => "/bin/chown ${suie_spot_user_id}.${suite_spot_group} /etc/dirsrv/slapd-${server_identifier}",
  } ->
  exec { "${server_identifier} export CA1 cert":
    cwd     => "${database}",
    command => "${certutil} -d ${database} -L -n ${server_identifier}CA1 -a > ${server_identifier}CA1.cer",
    creates => "${database}/${server_identifier}CA1.cer",
  } ->
  exec { "${server_identifier} export Cert1 cert":
    cwd     => "${database}",
    command => "${certutil} -d ${database} -L -n ${server_identifier}Cert1 -a > ${server_identifier}Cert1.cer",
    creates => "${database}/${server_identifier}Cert1.cer",
  } ->
  exec { "${server_identifier} copy certs to openldap":
    cwd     => "${database}",
    command => "/bin/cp ${server_identifier}CA1.cer ${server_identifier}Cert1.cer /etc/openldap/cacerts",
    creates => "/etc/openldap/cacerts/${server_identifier}CA1.cer",
  } ->
  exec { "$server_identifier rehash certs":
    command => "/usr/sbin/cacertdir_rehash /etc/openldap/cacerts/",
  } ->
  exec { "${server_identifier} remove temporary files" :
    command => "/bin/rm -f ${pwd_file} ${noise_file}",
  }->
  anchor { "${server_identifier} ds_389::site::end" :}
  
  ds_389::schema_extension_load { $array_schema :
    server_identifier => $server_identifier,
    require           => Anchor["${server_identifier} ds_389::site::end"],
  } ->
  ds_389::ldif_ssl { "${server_identifier}_init:ssl.ldif" :
    server_identifier     => $server_identifier,
    root_dn               => $root_dn,
    group                 => $suite_spot_group,
    user                  => $suite_spot_user_id ,
    root_dn_pwd           => $root_dn_pwd,
    server_port           => $server_port,
    server_ssl_port       => $server_ssl_port,
    nsEncryptionAlgorithm => $nsEncryptionAlgorithm,
  } ->
  Ds_389::Ldif_modify <<| tag == "${env}_${hostname}_ldif_modify" |>> ->
  Ds_389::Ldif_add <<| tag == "${env}_${hostname}_ldif_add" |>> ->
  Ds_389::Ldif_base_load <<| tag == "${env}_${hostname}_base_load" |>>
}
