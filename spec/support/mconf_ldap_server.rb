require './spec/support/ldap_server'

module Mconf
  class LdapServer
    attr_accessor :running, :port, :uid_field, :name_field, :mail_field

    def initialize(ldap_configs=nil)
      ldap_configs ||= Mconf::LdapServer.default_ldap_configs

      @server = SpecLdapServer.new(port: ldap_configs[:ldap_port])

      # 'admin' toplevel user with password 'admin' or use info from the db
      toplevel = ldap_configs[:ldap_user]
      toplevel_password = ldap_configs[:ldap_user_password]
      @server.add_user toplevel, toplevel_password

      # add a user 'mconf' with password 'mconf'
      @user_tree = ldap_configs[:ldap_user_treebase]
      @uid_field = ldap_configs[:ldap_username_field]
      @name_field = ldap_configs[:ldap_name_field]
      @mail_field = ldap_configs[:ldap_email_field]
    end

    def run
      @server.run_tcpserver
      @running = true
      while @running do
        sleep 10
      end
    end

    def add_user(uid, pass, mail)
      @server.add_user "#{@uid_field}=#{uid},#{@user_tree}", pass,
        { @uid_field => uid, @name_field => uid, @mail_field => mail }
    end

    def add_default_user
      add_user(*Mconf::LdapServer.default_user.values)
    end

    def self.default_user
      {
        username: 'mconf',
        password: 'mconf',
        email: 'mconf@test.mconf.org'
      }
    end

    def self.default_ldap_configs
      {
        ldap_enabled: true,
        ldap_host: '127.0.0.1',
        ldap_port: 1389,
        ldap_user: "cn=admin,cn=TOPLEVEL,dc=example,dc=com",
        ldap_user_password: "admin",
        ldap_user_treebase: "ou=USERS,dc=example,dc=com",
        ldap_username_field: 'uid',
        ldap_name_field: 'cn',
        ldap_email_field: 'mail'
      }
    end

  end

  # A singleton class with simple start/stop interface to be used by rspec
  # TODO: why doesn't it work if we call `.add_user` after `.start`? The user can't
  # authenticate unless `.start` is called *after* `.add_user`.
  class LdapServerRunner
    def self.start(ldap_configs=nil)
      init_server(ldap_configs)

      @@pid = fork do
        @@server.run
      end
      Rails.logger.info " ---- * Starting ldap server"
    end

    def self.stop
      Rails.logger.info " ---- * Stopping ldap server "

      Process.kill('SIGTERM', @@pid)
      Process.wait
    end

    def self.add_user(uid, pass, email)
      init_server
      @@server.add_user uid, pass, email
    end

    def self.add_default_user
      init_server
      @@server.add_default_user
    end

    private

    def self.init_server(ldap_configs=nil)
      @@server ||= LdapServer.new(ldap_configs)
    end
  end
end
