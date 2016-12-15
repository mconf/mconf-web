# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe Mconf::ApprovalControllerModule do

  describe '#approve' do
    context "if #require_approval?" do
      it "approves the resource and saves"
      it "creates a notification"
      it "sets the correct flash message"
      it "redirects back"
    end

    context "if not #require_approval?" do
      it "sets the correct flash message"
      it "redirects back"
      it "lets the resource be approved if not approved yet"
    end
  end

  describe '#disapprove' do
    context "if #require_approval?" do
      it "disapproves the resource and saves"
      it "sets the correct flash message"
      it "redirects back"
    end

    context "if not #require_approval?" do
      it "sets the correct flash message"
      it "redirects back"
    end
  end

  describe '#require_approval?' do
    it "always false"
  end

end
