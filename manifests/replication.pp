define ds_389::replication (
  $server_identifier = $server_identifier
  #  dnpass            = $dnpass
  #rep_pass          = $rep_pass
  #rep_id            = $rep_id
  #port              = $port
  #ssl_port          = $ssl_port
  #hostname_local    = $hostanme
  #hostname_alt      = $hostanme_alt
  #suffix            = $suffix
  #suffix_esc        = $suffix_esc
  #role              = $role
){
  $database          = "/etc/dirsrv/slapd-${server_identifier}"
  $certutil          = '/usr/bin/certutil'
  $ldapmodify        = '/usr/bin/ldapmodify'
  $CA1_file          ="${database}/${server_identifier}CA1.cer"

  $hostname_CA1      = inline_template('<%= puts %x[ /bin/echo iiiiiii  ] -%>')
  notify {'Ttttt' :
    message => inline_template(' puts %x[ /bin/echo iiiiiii  ] ')

  }

  notify {'DB':
    message => $database,
  }
  notify {'CA1_file':
    message => $CA1_file
  }
  notify {'test' :
    message => $hostname_CA1,
  }

}
