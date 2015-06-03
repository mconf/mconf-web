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

    site = Site.current
    port = args[:port] || site.ldap_port || 1389
    server = SpecLdapServer.new(:port => port)

    # 'admin' toplevel user with password 'admin' or use info from the db
    toplevel = site.ldap_user || "cn=admin,cn=TOPLEVEL,dc=example,dc=com"
    toplevel_password = site.ldap_user_password || "admin"
    server.add_user toplevel, toplevel_password

    # add a user 'mconf' with password 'mconf'
    user_tree = site.ldap_user_treebase || "ou=USERS,dc=example,dc=com"
    uid = site.ldap_username_field || 'uid'
    name = site.ldap_name_field || 'cn'
    mail = site.ldap_email_field || 'mail'
    server.add_user "#{uid}=mconf,#{user_tree}", 'mconf', { uid => 'mconf', name => 'mconf', mail => 'mconf@test.mconf.org' }

    server.run_tcpserver
    puts "LDAP test server started on port #{port}"
    loop do
      sleep 30
    end
  end
end
