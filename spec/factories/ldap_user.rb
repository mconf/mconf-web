# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :ldap_user, class: Net::LDAP::Entry do
    skip_create

    sequence(:dn) { |n| "cn=user-#{n},o=corp" }
    sequence(:uid) { |n| "user-uid-#{n}" }
    sequence(:mail) { |n| "user-uid-#{n}@institution.com" }
    sequence(:cn) { |n| "User#{n} Full Name" }

    initialize_with do
      Net::LDAP::Entry.from_single_ldif_string(
        attributes.map { |k,v| "#{k}: #{v}" }.join("\n")
      )
    end
  end
end
