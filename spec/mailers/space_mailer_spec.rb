# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe SpaceMailer do

  subject { SpaceMailer }

  let(:join_request) { FactoryGirl.create(:space_join_request) }
  let(:admin) { FactoryGirl.create(:user) }

  describe ".invitation_email" do
    context "queued the email to resque" do
      before do
        ResqueSpec.reset!
        SpaceMailer.invitation_email(join_request.id).deliver
      end

      it { should have_queue_size_of(1) }
      it { should have_queued(:invitation_email, join_request.id).in(:mailer) }
    end
  end

  describe ".processed_invitation_email" do
    pending "queued the email to resque" do
    end
  end

  describe ".join_request_email" do
    context "queued the email to resque" do
      before do
        ResqueSpec.reset!
        space = join_request.group
        space.add_member!(admin, "Admin")
        space_admin = space.admins.first

        SpaceMailer.join_request_email(join_request.id, space_admin.id).deliver
      end

      it { should have_queue_size_of(1) }
      it { should have_queued(:join_request_email, join_request.id, admin.id).in(:mailer) }
    end
  end

  describe ".processed_join_request_email" do
    pending "queued the email to resque" do
    end
  end

end
