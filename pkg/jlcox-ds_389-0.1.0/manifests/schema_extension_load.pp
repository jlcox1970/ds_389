define ds_389::schema_extension_load (
  $schema_file        = split($name, '[:]'),
  $server_identifier  = $server_identifier,
){
  #include ds_389::service
  $install_file       = $schema_file[1]
  $database           = "/etc/dirsrv/slapd-${server_identifier}"

  if ( $install_file != 'none') {
    file{ "$server_identifier updating schema $install_file " :
      name   => "$database/schema/$install_file",
      owner  => "nobody",
      group  => "nobody",
      mode   => "0440",
      source => "puppet:///modules/${module_name}/schema_extensions/${install_file}",
    }
  }
}
