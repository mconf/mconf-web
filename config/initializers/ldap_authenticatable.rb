require 'net/ldap'
require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class LdapAuthenticatable < Authenticatable
      def authenticate!
	puts "ENTROU NA FUNCAO DO DEVISE LDAP"
        if params[:user]
          ldap_user = ldap_data
          ldap = Net::LDAP.new(:host => "200.143.193.85", :port => 636, :encryption => :simple_tls)
#         ldap = Net::LDAP.new
#          ldap.host = "200.143.193.85" 
#          ldap.port = 636
#         ldap.port = 389
#         ldap.host = ldap_user[:host]
#         ldap.port = ldap_user[:port]
#         ldap.auth ldap_user[:user], ldap_user[:password] 
	  ldap.auth "uid=app.ufrgs.w,ou=APLICACOES,dc=homolog,dc=rnp", "EYedFNFp"
          treebase = "ou=UFRGS,ou=RNP,dc=homolog,dc=rnp"
          user_dn = 'uid=' + login + ',' + treebase
          if ldap.bind
            puts "Binded with the server succesfully"
            ops = [ [:replace, :sn, ["mudei_o_sn_pelo_ldap_autenthicatable"]]]
            ldap.modify :dn => user_dn, :operations => ops
            puts "resultado do modify:" + ldap.get_operation_result.inspect
          else
            puts "Did not bind with the ldap server"
            puts "reason:" + ldap.get_operation_result.inspect
          end

          #search of the user (not necessary)
          filter = Net::LDAP::Filter.eq("uid", login)
          attrs = ["mail","cn","sn", "objectclass", "userPassword"]
          result = ldap.search(:base => treebase, :filter => filter, :attributes => attrs)
          puts "search_result:" + result.inspect

          #bind of the user
          filter = Net::LDAP::Filter.eq("mail", "teste123@teste123.mail.com")
          result = ldap.bind_as(:base => treebase, :filter => filter, :password => password)
          if result
	    puts "Authenticated #{result.first.dn}"
            puts "result: " + result.inspect
          else
            puts "Authentication failed!"
            puts "results:" + ldap.get_operation_result.inspect
            puts "params[:user]:" + params[:user].inspect
            puts "password:" + password.inspect
            puts "filter:" + filter.inspect
          end
          #puts "user_data:" + user_data.inspect
          #puts "params[:user]:" + params[:user].inspect
          #puts "resultado do search: " + ldap.get_operation_result.inspect
          #puts "o que encontrou (usuario):" + result.inspect
          #ldap.auth "uid=teste123. " + treebase, hash_password(password, salt) 
          #if ldap.bind
          #puts "bindou com o usuario uid=teste123"
          #else
          #puts "nao bindou com o usuario uid=teste123"
          #puts "resultado:" + ldap.get_operation_result.inspect
          #end
          #user = User.find_or_create_by_email(user_data)
          #success!(user)
        else
          fail(:invalid_login)
        end
      end

      def ldap_data
	
      end
     
      def login
        params[:user][:login]
      end

      def email
        params[:user][:email]
      end

      def password
        params[:user][:password]
      end

      def user_data
        {:email => email, :password => password, :password_confirmation => password}
      end

    end
  end
end

Warden::Strategies.add(:ldap_authenticatable, Devise::Strategies::LdapAuthenticatable)
