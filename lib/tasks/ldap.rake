require './spec/support/mconf_ldap_server.rb'

def pretty_exit
  puts "Received INT signal, now exiting"
  exit 0
end

namespace :ldap do

  # To connect to this default server, use these configurations on Mconf-Web:
  #
  # * Server: localhost
  # * Port: 1389
  # * DN or user to bind: cn=admin,cn=TOPLEVEL,dc=example,dc=com
  # * Password to connect: admin
  # * DN for user's tree: ou=USERS,dc=example,dc=com
  # * Username field: uid
  # * Mail field: mail
  # * Full name field: cn
  # * User filter: -- leave it blank --
  desc "Run a test ldap server"
  task :server, [:port] => :environment do |t, args|
    require './spec/support/ldap_server'

    Kernel.trap( "INT" ) { pretty_exit }

    server = Mconf::LdapServer.new args[:port]
    puts "LDAP test server started on port #{args[:port] || 1389}"

    server.add_user 'mconf', 'mconf', 'mconf@test.mconf.org'
    server.run
  end
end
