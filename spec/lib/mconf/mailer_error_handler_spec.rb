# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe Mconf::MailerErrorHandler do

  describe "#handle" do
    let(:exception) { Exception.new("my custom exception") }

    context "for invitation_email" do
      context "if it can find the target Invitation" do
        let(:invitation) { FactoryGirl.create(:web_conference_invitation, sent: true, ready: true, result: true) }

        before(:each) {
          expect {
            Mconf::MailerErrorHandler.handle(ApplicationMailer, "any message", exception, "invitation_email", [invitation.id])
          }.to raise_error(exception)
        }
        it("sets the invitation as failed") { invitation.reload.result.should be(false) }
      end

      context "if it cannot find the target Invitation" do
        subject {
          Mconf::MailerErrorHandler.handle(ApplicationMailer, "any message", exception, "invitation_email", [-1])
        }
        it { expect{ subject }.to raise_error(exception) }
      end
    end

    context "for other mails" do
      subject {
        Mconf::MailerErrorHandler.handle(ApplicationMailer, "any message", exception, "another_email", nil)
      }
      it { expect{ subject }.to raise_error(exception) }
    end
  end

end
