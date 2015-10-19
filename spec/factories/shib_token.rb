# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :shib_token do |s|
    s.association :user, factory: :user
    s.data {
      hash = {}
      hash["Shib-Application-ID"] = "default"
      hash["Shib-Session-ID"] = "09a612f952cds995e4a86ddd87fd9f2a"
      hash["Shib-Identity-Provider"] = "https://login.somewhere/idp/shibboleth"
      hash["Shib-Authentication-Instant"] = "2011-09-21T19:11:58.039Z"
      hash["Shib-Authentication-Method"] = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
      hash["Shib-AuthnContext-Class"] = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
      hash["Shib-brEduPerson-brEduAffiliationType"] = "student;position;faculty"
      hash["Shib-eduPerson-eduPersonPrincipalName"] = "928dhajus7ksjdu8761cfa75473ec0@instituition.eu"
      hash["Shib-inetOrgPerson-cn"] = "Rick Astley"
      hash["Shib-inetOrgPerson-sn"] = "Rick Astley"
      hash["Shib-inetOrgPerson-mail"] = "nevergonnagiveyouup@rick.com"
      hash["cn"] = "Rick Astley"
      hash["mail"] = "nevergonnagiveyouup@rick.com"
      hash["uid"] = "00000000000"
      hash
    }
    after(:build) do |obj|
      obj.identifier = obj.user.email
    end
  end
end
