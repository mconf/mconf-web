# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe BigbluebuttonMeeting do

  describe "from initializers/bigbluebutton_rails" do
    context "should include PublicActivity::Common" do
      # checks a few methods included by PublicActivity::Common, but not all
      subject { BigbluebuttonMeeting.new }
      it { subject.should respond_to(:create_activity) }
      it { subject.should respond_to(:public_activity_enabled?) }
      it { subject.should respond_to(:activity_owner) }
      it { subject.should respond_to(:activity_key) }
      it { subject.should respond_to(:activity_params) }
    end
  end

  # This is a model from BigbluebuttonRails, but we have permissions set in cancan for it,
  # so we test them here.
  describe "abilities", :abilities => true do
    # TODO: permission control for meetings
  end

end
