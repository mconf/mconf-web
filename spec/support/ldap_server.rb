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

  def default_options
    { :operation_class => SpecLdapOperation, :operation_args => [self] }
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
    end
    raise LDAP::ResultError::UnwillingToPerform, "Only some matches are supported"
  end
end
