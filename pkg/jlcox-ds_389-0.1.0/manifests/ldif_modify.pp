define ds_389::ldif_modify (
  $ldif_file          = split($name, '[:]'),
  $root_dn            = $root_dn ,
  $root_dn_pwd        = $root_dn_pwd,
  $server_identifier  = $server_identifier,
  $server_port        = $server_port,
  $server_ssl_port    = $server_ssl_port,
  $user               = $user,
  $group              = $group,
){
  include ds_389::service
  $install_ldif_file  = $ldif_file[1]
  $dir_inst_hostname  = $hostname
  $ldapmodify         = '/usr/bin/ldapmodify'
  $database           = "/etc/dirsrv/slapd-${server_identifier}"

  File {
    owner  => $user,
    group => $group,
  }
  if ( $install_ldif_file != 'none' ) and ( $install_ldif_file != 'ssl.ldif' ) and ($install_ldif_file != undef ){
    file{ "$name modify $install_ldif_file ldif" :
      name    => "$database/$install_ldif_file",
      content => template("${module_name}/${install_ldif_file}.erb"),
    }->
    exec {"$name ldif modify $install_ldif_file" :
      command => "/bin/cat ${database}/${install_ldif_file} |${ldapmodify} -h ${dir_inst_hostname} -p ${server_port} -x -D \"${root_dn}\" -w ${root_dn_pwd} ; touch ${database}/${install_ldif_file}.done",
      creates => "${database}/${install_ldif_file}.done",
    }
  }
}
