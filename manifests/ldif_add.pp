define ds_389::ldif_add (
  $ldif_file          = split($name, '[:]'),
  $root_dn            = $root_dn ,
  $root_dn_pwd        = $root_dn_pwd,
  $server_identifier  = $server_identifier,
  $server_port        = $server_port,
  $server_ssl_port    = $server_ssl_port,
  $suffix             = $suffix,
  $user               = $user,
  $group              = $group,
){
  include ds_389::service
  $install_ldif_file  = $ldif_file[1]
  $dir_inst_hostname  = $::hostname
  $ldapadd            = '/usr/bin/ldapadd'
  $database           = "/etc/dirsrv/slapd-${server_identifier}"

  File {
    owner => $user,
    group => $group,
  }

  if ( $server_identifier != 'lookup' ){
    $dc_array           = split($suffix ,'[=,]')
    $dc                 = $dc_array[1]
  } else {
    $dc_array           = split($suffix ,'[=]')
    $dc                 = $dc_array[1]
  }
  if ( $install_ldif_file != 'none' ) and ( $install_ldif_file != undef ) {
    file{ "${server_identifier} add: build ${install_ldif_file} ldif" :
      name    => "${database}/${install_ldif_file}",
      content => template("${module_name}/${install_ldif_file}.erb"),
    }->
    exec {"${server_identifier} adding ldif ${install_ldif_file}" :
      command => "/bin/cat ${database}/${install_ldif_file} | ${ldapadd} -h ${dir_inst_hostname} -p ${server_port} -x -D \"${root_dn}\" -w ${root_dn_pwd} ; touch ${database}/${install_ldif_file}.done ; /bin/sleep 1",
      creates => "${database}/${install_ldif_file}.done",
    }
  }
}
