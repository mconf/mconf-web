# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe ProcessedJoinRequestNotifications do

  let(:user) { FactoryGirl.create(:user) }
  let(:space) { FactoryGirl.create(:space) }
  let(:join_request) { FactoryGirl.create(:space_join_request, :group => space) }
  let(:invitation) { FactoryGirl.create(:space_invite_request, :group => space) }
  let(:other_join_request) { FactoryGirl.create(:space_join_request, :group => space) }
  let(:space_join_activity) {
    FactoryGirl.create(:space_join_activity, :owner => space,
                       :parameters => {:join_request_id => join_request.id})
  }

  subject { SpaceMailer }

  describe "#perform" do
    describe "when have one join request in a space" do
      before do
        ResqueSpec.reset!
        join_request.group = space
        space_join_activity.owner = space
        ProcessedJoinRequestNotifications.perform
      end

      it { should have_queue_size_of(1) }
      it { should have_queued(:processed_join_request_email, join_request.id).in(:mailer) }
    end

    describe "when have two join requests in a space" do
      let(:other_space_join_activity) {
        FactoryGirl.create(:space_join_activity, :owner => space,
                           :parameters => {:join_request_id => other_join_request.id})
      }

      before do
        ResqueSpec.reset!
        join_request.group = other_join_request.group = space
        space_join_activity.owner = other_space_join_activity.owner = space

        ProcessedJoinRequestNotifications.perform
      end

      it { should have_queue_size_of(2) }
      it { should have_queued(:processed_join_request_email, join_request.id).in(:mailer) }
      it { should have_queued(:processed_join_request_email, other_join_request.id).in(:mailer) }
    end

    describe "when have one join requests and one invitation in a space" do
      let(:other_space_join_activity) {
        FactoryGirl.create(:space_join_activity, :owner => space,
                           :parameters => {:join_request_id => invitation.id})
      }

      before do
        ResqueSpec.reset!
        join_request.group = other_join_request.group = space
        space_join_activity.owner = other_space_join_activity.owner = space

        ProcessedJoinRequestNotifications.perform
      end

      it { should have_queue_size_of(2) }
      it { should have_queued(:processed_join_request_email, join_request.id).in(:mailer) }
      it { should have_queued(:processed_invitation_email, invitation.id).in(:mailer) }
    end
  end
end
