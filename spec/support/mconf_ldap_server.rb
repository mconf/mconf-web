require './spec/support/ldap_server'

module Mconf
  class LdapServer
    attr_accessor :running, :port, :uid_field, :name_field, :mail_field

    def initialize port=nil
      ldap_config = Site.current
      @port = port || ldap_config.ldap_port || 1389
      @server = SpecLdapServer.new(:port => @port)

      # 'admin' toplevel user with password 'admin' or use info from the db
      toplevel = ldap_config.ldap_user || "cn=admin,cn=TOPLEVEL,dc=example,dc=com"
      toplevel_password = ldap_config.ldap_user_password || "admin"
      @server.add_user toplevel, toplevel_password

      # add a user 'mconf' with password 'mconf'
      @user_tree = ldap_config.ldap_user_treebase || "ou=USERS,dc=example,dc=com"
      @uid_field = ldap_config.ldap_username_field || 'uid'
      @name_field = ldap_config.ldap_name_field || 'cn'
      @mail_field = ldap_config.ldap_email_field || 'mail'

      add_user 'mconf', 'mconf', 'mconf@test.mconf.org'
    end

    def run
      @server.run_tcpserver
      @running = true
      while @running do
        sleep 10
      end
    end

    def add_user uid, pass, mail
      @server.add_user "#{@uid_field}=#{uid},#{@user_tree}", pass,
        { @uid_field => uid, @name_field => uid, @mail_field => mail }
    end

  end

  # A singleton class with simple start/stop interface to be used by rspec
  class LdapServerRunner
    def self.init_server(port)
      @@server ||= LdapServer.new(port)
    end

    def self.start(port=1389)
      init_server(port)

      @@pid = fork do
        @@server.run
      end
      Rails.logger.info " ---- * Starting ldap server in port #{port} "
    end

    def self.stop
      Rails.logger.info " ---- * Stopping ldap server "

      Process.kill('SIGTERM', @@pid)
      Process.wait
    end

    def self.add_user uid, pass, email, port=1389
      init_server(port)

      @@server.add_user uid, pass, email
    end
  end
end
