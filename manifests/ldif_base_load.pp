define ds_389::ldif_base_load (
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
  if ($install_ldif_file != false ){
    file{ "${server_identifier} base load ${install_ldif_file} ldif" :
      name   => "${database}/${install_ldif_file}",
      source => "puppet:///modules/${module_name}/base_data/${install_ldif_file}",
    }->
    exec {"${server_identifier} base load adding ldif ${install_ldif_file}" :
      command => "${ldapadd} -h ${dir_inst_hostname} -p ${server_port} -x -D \"${root_dn}\" -w ${root_dn_pwd} -c -f ${database}/${install_ldif_file} ; touch ${database}/${install_ldif_file}.done",
      creates => "${database}/${install_ldif_file}.done",
    }
  }
}
