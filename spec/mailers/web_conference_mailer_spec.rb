# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe WebConferenceMailer do

  subject { WebConferenceMailer }

  let(:user) { FactoryGirl.create(:user) }
  let(:email) { "test@test.com" }
  let(:invitation) {
    { "from" => {"approved"=>true, "can_record"=>nil, "created_at"=>"2014-06-06T20:56:53Z", "disabled"=>false, "email"=>"admin@test.org", "expanded_post"=>false, "id"=>1, "locale"=>nil, "notification"=>1, "receive_digest"=>0, "superuser"=>true, "timezone"=>"UTC", "updated_at"=>"2014-06-09T17:11:18Z", "username"=>"admin"},
      "room" => {"attendee_password"=>"123456", "created_at"=>"2014-06-06T20:56:54Z", "dial_number"=>nil, "duration"=>0, "external"=>false, "id"=>1, "logout_url"=>"/feedback/webconf/", "max_participants"=>nil, "meetingid"=>"d19d4596-8486-4d4a-97a05ff42122-1402088214", "moderator_password"=>"123456", "name"=>"Admin Admin", "owner_id"=>1, "owner_type"=>"User", "param"=>"admin", "private"=>false, "record"=>false, "server_id"=>1, "updated_at"=>"2014-06-06T20:56:54Z", "voice_bridge"=>"78824", "welcome_msg"=>nil},
      "starts_on" => "2014-06-10T09:00:00-03:00",
      "ends_on" => "2014-06-10T10:00:00-03:00",
      "title" => "test",
      "url" => "http://test.test/webconf/admin",
      "description" => "test"
    }
  }

  describe ".invitation_mail" do
    describe "queued the email to resque" do
      context "receiver is a user" do
        before do
          ResqueSpec.reset!
          WebConferenceMailer.invitation_mail(invitation, user.email).deliver
        end

        subject { WebConferenceMailer }
        it { should have_queue_size_of(1) }
        it { should have_queued(:invitation_mail, invitation, user.email).in(:mailer) }
      end

      context "receiver is a email" do
        before do
          ResqueSpec.reset!
          WebConferenceMailer.invitation_mail(invitation, email).deliver
        end

        it { should have_queue_size_of(1) }
        it { should have_queued(:invitation_mail, invitation, email).in(:mailer) }
      end
    end
  end

end
