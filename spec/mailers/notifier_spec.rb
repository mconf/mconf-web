# This file is part of  Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe Notifier do

  describe '.invitation_email' do
    let(:invitation) { FactoryGirl.create(:space_join_request, :request_type => 'invite') }
    let(:mail) { Notifier.invitation_email(invitation) }

    it 'renders the subject' do
      expect(mail.subject).to be_present
    end

    it 'renders the receiver email' do
      expect(mail.to).to eql([invitation.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to be_present
    end
    it 'assigns @name' do
      expect(mail.body.encoded).to match(invitation.candidate.full_name)
    end
  end

  describe '.join_request_email' do
    let(:request) { FactoryGirl.create(:space_join_request, :request_type => 'request') }
    let(:admin) { FactoryGirl.create(:user) }
    let(:mail) { Notifier.join_request_email(request, admin) }

    before(:each) { request.group.add_member!(admin, 'Admin') }

    it 'renders the subject' do
      expect(mail.subject).to be_present
    end

    it 'renders the receiver email' do
      expect(mail.to).to eql([admin.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to be_present
    end
  end

  describe '.event_notification_email'
  describe '.permission_update_notification_email'
  describe '.processed_invitation_email'

  describe '.processed_join_request_email'
  describe '.confirmation_email'
  describe '.activation'
  describe '.lost_password'
  describe '.reset_password'
  describe '.feedback_email'

  describe ".digest_email" do
    subject { Notifier }
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
        Notifier.digest_email(user.id, @posts, @news, @attachments, @events, @inbox).deliver
      end

      it { should have_queue_size_of(1) }
      it { should have_queued(:digest_email, user.id, @posts, @news, @attachments, @events, @inbox) }
    end
  end

  describe '.create_default_mail'

end