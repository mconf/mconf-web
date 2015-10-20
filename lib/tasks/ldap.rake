require './spec/support/mconf_ldap_server.rb'

def pretty_exit
  puts "Received INT signal, now exiting"
  exit 0
end

namespace :ldap do

  # To connect to this default server, use these configurations on Mconf-Web
  # (they are defined by Mconf::LdapServer::default_ldap_configs):
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

    port = args[:port] || 1389
    configs = Site.current.attributes.select{ |attr| attr.match(/^ldap_/) }.symbolize_keys
    configs[:ldap_port] = port
    server = Mconf::LdapServer.new(configs)
    puts "LDAP test server started on port #{port} with configs: #{configs.inspect}"

    server.add_default_user
    server.run
  end

  task :setup_site => :environment do |t|
    puts "Setting up the site with LDAP attributes: #{Mconf::LdapServer.default_ldap_configs.inspect}"
    Site.current.update_attributes(Mconf::LdapServer.default_ldap_configs)
  end
end
