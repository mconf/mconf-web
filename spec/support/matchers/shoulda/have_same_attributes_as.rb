# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Compares the attributes of two models or hashes, ignoring attributes generated only when saving in the db
# Example: user1.should have_same_attributes_as(User.last)
RSpec::Matchers.define :have_same_attributes_as do |expected, ignore=[]|
  match do |actual|
    ignored = ['id', 'updated_at', 'created_at'].push(ignore).flatten
    actual_attr = actual.attributes unless actual.instance_of?(Hash)
    expected_attr = expected.attributes unless expected.instance_of?(Hash)

    # filter ignored values
    actual = actual_attr.except(*ignored)
    expected = expected_attr.except(*ignored)

    # some values have to be adapted before comparing the hashes
    actual = adjust_hash_values(actual)
    expected = adjust_hash_values(expected)

    actual == expected
  end
end

def adjust_hash_values(hash)
  hash.each do |k,v|
    # Time objects are compared as string
    hash[k] = v.to_s if v.is_a?(Time)
  end
  hash
end
