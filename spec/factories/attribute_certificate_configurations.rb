# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :attribute_certificate_configuration do |c|
    c.repository_url Forgery::Internet.domain_name
    c.repository_port '443'
    c.oid_eea '1.1.1.1.1.1.1.1'
    c.enabled true
  end

  factory :attr_conf, parent: :attribute_certificate_configuration
end
