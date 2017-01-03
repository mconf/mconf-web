# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2016 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

feature 'Space admin edits user permission' do
  it "should show pagination links when there's more than 10 user permissions"
  it "should not show pagination links when there's less than 10 user permissions"
end
