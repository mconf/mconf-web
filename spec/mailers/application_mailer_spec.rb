# This file is part of  Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe ApplicationMailer do

  describe ".digest_email" do
    subject { ApplicationMailer }
    context "queued the email to resque" do
      let(:user) { FactoryGirl.create(:user) }
      let(:space) { FactoryGirl.create(:space) }
      let(:now) { Time.now }
      let(:date_start) { now - 1.day }
      let(:date_end) { now }

      before do
        ResqueSpec.reset!

        space.add_member!(user)
        # create the data to be returned
        @posts = [ FactoryGirl.create(:post, :space => space, :updated_at => date_start) ]
        @news = [ FactoryGirl.create(:news, :space => space, :updated_at => date_start) ]
        @attachments = [ FactoryGirl.create(:attachment, :space => space, :updated_at => date_start) ]
        @events = [ FactoryGirl.create(:event, :owner => space, :start_on => date_start, :end_on => date_start + 1.hour) ]
        @inbox = [ FactoryGirl.create(:private_message, :receiver => user, :sender => FactoryGirl.create(:user)) ]
        ApplicationMailer.digest_email(user.id, @posts, @news, @attachments, @events, @inbox).deliver
      end

      it { should have_queue_size_of(1) }
      it { should have_queued(:digest_email, user.id, @posts, @news, @attachments, @events, @inbox) }
    end
  end

  describe '.feedback_email'

end
