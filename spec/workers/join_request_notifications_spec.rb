# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe JoinRequestNotifications do

  let(:space) { FactoryGirl.create(:space) }
  let(:admin_1) { FactoryGirl.create(:user) }
  let(:admin_2) { FactoryGirl.create(:user) }
  let(:jr1) { FactoryGirl.create(:space_join_request, :group => space) }
  let(:jr2) { FactoryGirl.create(:space_join_request, :group => space) }
  let(:invite1) { FactoryGirl.create(:space_invite_request, :group => space) }
  let(:invite2) { FactoryGirl.create(:space_invite_request, :group => space) }

  # save all join requests to force a recent activity to be created
  before {
    jr1.save!
    jr2.save!
    invite1.save!
    invite2.save!
  }

  subject { SpaceMailer }

  describe "#perform" do
    describe "when have two invites and two join requests in a space" do
      describe "with only one admin in space" do
        before do
          ResqueSpec.reset!
          space.add_member!(admin_1, "Admin")
          JoinRequestNotifications.perform
        end

        it { should have_queue_size_of(4) }
        it { should have_queued(:join_request_email, jr1.id, admin_1.id).in(:mailer) }
        it { should have_queued(:join_request_email, jr2.id, admin_1.id).in(:mailer) }
        it { should_not have_queued(:join_request_email, jr1.id, admin_2.id).in(:mailer) }
        it { should_not have_queued(:join_request_email, jr2.id, admin_2.id).in(:mailer) }
        it { should have_queued(:invitation_email, invite1.id).in(:mailer) }
        it { should have_queued(:invitation_email, invite2.id).in(:mailer) }
      end

      describe "with two admins in space" do
        before do
          ResqueSpec.reset!
          space.add_member!(admin_1, "Admin")
          space.add_member!(admin_2, "Admin")
          JoinRequestNotifications.perform
        end

        it { should have_queue_size_of(6) }
        it { should have_queued(:join_request_email, jr1.id, admin_1.id).in(:mailer) }
        it { should have_queued(:join_request_email, jr1.id, admin_2.id).in(:mailer) }
        it { should have_queued(:join_request_email, jr2.id, admin_1.id).in(:mailer) }
        it { should have_queued(:join_request_email, jr2.id, admin_2.id).in(:mailer) }
        it { should have_queued(:invitation_email, invite1.id).in(:mailer) }
        it { should have_queued(:invitation_email, invite2.id).in(:mailer) }
      end
    end
  end
end
