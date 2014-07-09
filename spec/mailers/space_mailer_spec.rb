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
    context "creates the email" do
      let(:mail) { SpaceMailer.invitation_email(join_request.id) }
      let(:subject) {
        "[#{Site.current.name}] " + I18n.t("invitation.to_space", :space => join_request.group.name,
                                          :username => join_request.introducer.full_name)
      }

      it 'renders the receiver email' do
        expect(mail.to).to eql([join_request.email])
      end

      it 'renders the reply email' do
        expect(mail.reply_to).to eql([join_request.introducer.email])
      end

      it 'renders the subject' do
        expect(mail.subject).to eq(subject)
      end
    end

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
    describe "creates the email" do
      context "with request approved" do
        before(:each) do
          allow_any_instance_of(JoinRequest).to receive(:accepted?).and_return(true)
        end
        let(:mail) { SpaceMailer.processed_invitation_email(join_request.id) }
        let(:subject) {
          "[#{Site.current.name}] " + I18n.t("space_mailer.processed_invitation_email.subject",
                                             :name => join_request.candidate.name,
                                             :action => I18n.t("space_mailer.processed_invitation_email.accepted"))
        }

        it 'renders the receiver email' do
          expect(mail.to).to eql([join_request.introducer.email])
        end

        it 'renders the reply email' do
          expect(mail.reply_to).to eql([])
        end

        it 'renders the subject' do
          expect(mail.subject).to eq(subject)
        end
      end

      context "with request rejected" do
        before(:each) do
          allow_any_instance_of(JoinRequest).to receive(:accepted?).and_return(false)
        end

        let(:mail) { SpaceMailer.processed_invitation_email(join_request.id) }
        let(:subject) {
          "[#{Site.current.name}] " + I18n.t("space_mailer.processed_invitation_email.subject",
                                             :name => join_request.candidate.name,
                                             :action => I18n.t("space_mailer.processed_invitation_email.rejected"))
        }

        it 'renders the receiver email' do
          expect(mail.to).to eql([join_request.introducer.email])
        end

        it 'renders the reply email' do
          expect(mail.reply_to).to eql([])
        end

        it 'renders the subject' do
          expect(mail.subject).to eq(subject)
        end
      end
    end

    context "queued the email to resque" do
      before do
        ResqueSpec.reset!
        SpaceMailer.processed_invitation_email(join_request.id).deliver
      end

      it { should have_queue_size_of(1) }
      it { should have_queued(:processed_invitation_email, join_request.id).in(:mailer) }
    end
  end

  describe ".join_request_email" do
    context "creates the email" do
      before do
        space = join_request.group
        space.add_member!(admin, "Admin")
        @space_admin = space.admins.first
      end

      let(:mail) { SpaceMailer.join_request_email(join_request.id, @space_admin.id) }
      let(:subject) {
        "[#{Site.current.name}] " + I18n.t("space_mailer.join_request_email.subject",
                                           :candidate => join_request.candidate.full_name,
                                           :space => join_request.group.name)
      }

      it 'renders the receiver email' do
        expect(mail.to).to eql([@space_admin.email])
      end

      it 'renders the reply email' do
        expect(mail.reply_to).to eql([join_request.candidate.email])
      end

      it 'renders the subject' do
        expect(mail.subject).to eq(subject)
      end
    end

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
    describe "creates the email" do
      context "with request approved" do
        before(:each) do
          allow_any_instance_of(JoinRequest).to receive(:accepted?).and_return(true)
        end

        let(:mail) { SpaceMailer.processed_join_request_email(join_request.id) }
        let(:subject) {
          "[#{Site.current.name}] " + I18n.t("space_mailer.processed_join_request_email.subject",
                                             :action => I18n.t("space_mailer.processed_join_request_email.accepted"),
                                             :space => join_request.group.name)
        }

        it 'renders the receiver email' do
          expect(mail.to).to eql([join_request.candidate.email])
        end

        it 'renders the reply email' do
          expect(mail.reply_to).to eql([])
        end

        it 'renders the subject' do
          expect(mail.subject).to eq(subject)
        end
      end

      context "with request rejected" do
        before(:each) do
          allow_any_instance_of(JoinRequest).to receive(:accepted?).and_return(false)
        end

        let(:mail) { SpaceMailer.processed_join_request_email(join_request.id) }
        let(:subject) {
          "[#{Site.current.name}] " + I18n.t("space_mailer.processed_join_request_email.subject",
                                             :action => I18n.t("space_mailer.processed_join_request_email.rejected"),
                                             :space => join_request.group.name)
        }

        it 'renders the receiver email' do
          expect(mail.to).to eql([join_request.candidate.email])
        end

        it 'renders the reply email' do
          expect(mail.reply_to).to eql([])
        end

        it 'renders the subject' do
          expect(mail.subject).to eq(subject)
        end
      end
    end

    context "queued the email to resque" do
      before do
        ResqueSpec.reset!
        SpaceMailer.processed_join_request_email(join_request.id).deliver
      end

      it { should have_queue_size_of(1) }
      it { should have_queued(:processed_join_request_email, join_request.id).in(:mailer) }
    end
  end

end
