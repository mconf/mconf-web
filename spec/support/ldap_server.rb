# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'fooldap'

class SpecLdapServer < Fooldap::Server
  def initialize options = {}
    super(options)
    @data = {}
  end

  def add_user user, pass, data=nil
    super(user, pass)
    @data[user] = data if data
  end

  # This method is overriden to simulate users with a blank password being permited to log in.
  # This is crazy, but reflects some LDAP configurations where it could happen
  # and we have to test for empty passwords at the application level and deny the users
  def valid_credentials?(user, pass)
    @users.has_key?(user) && (@users[user] == pass || pass.blank?)
  end

  def default_options
    { :operation_class => SpecLdapOperation, :operation_args => [self] }
  end

  def find_users(basedn, filter)
    basedn_regex = /#{Regexp.escape(basedn)}$/
    filter_regex = /^#{filter[1]}=#{filter[3]}$/

    @users.keys.select { |dn|
      attributes = dn.split(",")
      if @data[dn]
        attributes.concat @data[dn].map{ |k, v| "#{k}=#{v}" }
      end
      dn =~ basedn_regex && attributes.grep(filter_regex).any?
    }
  end

  def data
    @data
  end
end

class SpecLdapOperation < Fooldap::Operation
  def search(basedn, scope, deref, filter, attrs=nil)
    group_filter = [:eq, "objectclass", nil, "groupofNames"]

    if filter.first == :eq
      if filter == group_filter
        return @server.groups.each { |group| send_group_result(*group) }
      else
        return @server.find_users(basedn, filter).each do |dn|
          send_SearchResultEntry(dn, @server.data[dn])
        end
      end
    elsif filter.first == :and
      if filter[1] == group_filter
        member_eq = filter[2]
        if member_eq[0] == :eq and member_eq[1] == 'member'
          user_dn = member_eq[3]
          return @server.find_groups(user_dn).each { |group| send_group_result(*group) }
        end
      end
    elsif filter.first == :or
      users = []
      if filter[1].first == :eq
        result = @server.find_users(basedn, filter[1]).each do |dn|
          users << dn
          send_SearchResultEntry(dn, @server.data[dn])
        end
        return result unless result.nil? || result.empty?
      end
      if filter[2].first == :eq
        result = @server.find_users(basedn, filter[2]).each do |dn|
          users << dn
          send_SearchResultEntry(dn, @server.data[dn])
        end
        return result unless result.nil? || result.empty?
      end
    end
    raise LDAP::ResultError::UnwillingToPerform, "Only some matches are supported"
  end
end
