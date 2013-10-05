# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe PostsController do
  render_views

  it "#index"
  it "#show"
  it "#new"
  it "#create"
  it "#update"
  it "#edit"
  it "#destroy"
  it "#reply_post"

  describe "include SpamControllerModule" do
    it "#spam_report_create"
  end

  describe "abilities", :abilities => true do
    it "abilities"
  end
end
